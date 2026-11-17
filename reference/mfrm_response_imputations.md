# Pool common facet targets across imputed rating analyses

Combine results such as rater severity or a prespecified difference
between raters across completed-data fits. Rubin's rules include
uncertainty within each fit and variation between imputations. The
calculation uses the full covariance for one non-Person facet; it does
not pool Person ability scores.

Fit a separate MFRM to each completed version of the ratings reviewed by
`review_mfrm_imputations()`. All fits use the same model and measurement
scale so eligible estimates can be combined with `pool_mfrm_imputed()`.
Failed fits and their messages are retained for review.

Check several completed versions of a rating table before analyzing
them. Supply these completed data from an imputation model; this
function checks that observed scores, rating assignments and identifiers
are preserved. No person-by-facet grid is constructed. This function
validates supplied imputations; it does not choose or fit an imputation
model. Start with `review_mfrm_imputations()`, then use
`fit_mfrm_imputed()` and `pool_mfrm_imputed()` for eligible fixed-facet
analyses. The former `mfrm_response_imputations()` name has been
removed; use `review_mfrm_imputations()` with `impute_ids` for the
selected event IDs.

Use `review_mfrm_imputations()` to review supplied completions, with
`impute_ids` naming the selected event IDs. The former
`mfrm_response_imputations()` name is no longer exported. This review
does not fit an imputation model or generate completed ratings.

## Usage

``` r
pool_mfrm_imputed(
  x,
  facet,
  contrasts = NULL,
  ci_level = 0.95,
  df_complete = Inf
)

fit_mfrm_imputed(x, model = c("RSM", "PCM"), step_facet = NULL, ...)

# S3 method for class 'mfrm_imputed_fits'
print(x, ...)

# S3 method for class 'mfrm_imputed_fits'
summary(object, ...)

# S3 method for class 'mfrm_pooled'
print(x, ...)

# S3 method for class 'mfrm_pooled'
summary(object, ...)

# S3 method for class 'mfrm_pooled'
plot(
  x,
  draw = TRUE,
  preset = "standard",
  title = paste("Pooled", x$settings$facet, "estimates and contrasts"),
  subtitle = sprintf("%d imputations | %.0f%% pointwise MI intervals",
    x$settings$imputations, 100 * x$settings$ci_level),
  ...
)

review_mfrm_imputations(
  data,
  completed,
  person,
  facets,
  score,
  event_id,
  impute_ids,
  categories,
  assigned = NULL,
  imputation_model = NULL,
  missing = c("error", "omit")
)

# S3 method for class 'mfrm_response_imputations'
print(x, ...)

# S3 method for class 'mfrm_response_imputations'
summary(object, ...)
```

## Arguments

- x:

  An object returned by `review_mfrm_imputations()`.

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

- model:

  `"RSM"` or `"PCM"`.

- step_facet:

  Required for PCM: the facet with separate step parameters.

- ...:

  Unused for print and summary methods.

- object:

  An object returned by `review_mfrm_imputations()`.

- draw:

  Logical. With `FALSE`, return the exact plot data without opening a
  graphics device.

- preset:

  A package plotting preset, such as `"standard"` or `"monochrome"`.

- title:

  Optional text; `NULL` omits it. The default subtitle retains a notice
  when complete-data information is weak. Full cautions remain in the
  returned plot data even with custom or omitted text.

- subtitle:

  Optional text; `NULL` omits it. The default subtitle retains a notice
  when complete-data information is weak. Full cautions remain in the
  returned plot data even with custom or omitted text.

- data:

  Original long-format rating roster, including missing scores.

- completed:

  A list of at least two completed data frames, or a `mids` object from
  [`mice::mice()`](https://amices.org/mice/reference/mice.html) fitted
  to the long-format roster. Each completion must contain all original
  columns and rows. Row order may differ; rows are matched by
  `event_id`.

- person:

  Column names. `event_id` uniquely identifies a rating event, including
  repeated ratings of the same person and facets.

- facets:

  Nonempty character vector of facet column names.

- score:

  Column names. `event_id` uniquely identifies a rating event, including
  repeated ratings of the same person and facets.

- event_id:

  Column names. `event_id` uniquely identifies a rating event, including
  repeated ratings of the same person and facets.

- impute_ids:

  Character vector of event IDs explicitly selecting missing scores on
  assigned ratings. Observed scores cannot be selected. These are values
  from the `event_id` column, not a column name or a logical switch. For
  example, `c("E2", "E7")` selects those two rating events.

- categories:

  The full intended contiguous integer category vector, for example
  `0:4`. It is preserved across all completed analyses.

- assigned:

  Optional name of a complete logical column: `TRUE` denotes an assigned
  rating and `FALSE` an unassigned combination. Without this column
  every supplied row is declared assigned. Unassigned rows must have
  missing scores in the original and every completion.

- imputation_model:

  For a list of completions, the saved model or a nonempty list
  containing its specification, settings and diagnostics. Required so
  that the provenance is retained. For a `mids` input, that object is
  retained automatically; omit this argument.

- missing:

  How to handle assigned missing scores not selected by `impute_ids`:
  `"error"` (default) or explicit `"omit"`. Omitted events remain in the
  roster and every completion, with missing scores, and are excluded
  from each analysis. This choice is not a correction for nonresponse.

## Value

An `mfrm_pooled` object containing `table`, `within`, `between` and
`total` covariance matrices, `estimates` by imputation, each
`complete_covariance`, the exact `contrasts`, `facet_levels`, `settings`
and source `analyses`. `MonteCarloSE` is the estimated Monte Carlo SE of
the pooled point estimate, `sqrt(B / m)`; it is not its inferential SE.
`MissingVarianceFraction` is `(1 + 1/m) B / T`, not the raw
missing-rate. Fixed targets retain their value and zero variance, but no
inferential interval or degrees of freedom. No imputation is omitted.
`information_review` retains any numerical-refinement review at each
imputation's list position. `cautions` identifies affected imputations;
when present, `InferenceCaution` also accompanies the pooled table.
`IntervalReason` distinguishes available intervals, fixed targets,
numerical resolution loss and intervals outside the numeric range. An
unavailable interval retains its point estimate and variance. `notes`
records the imputation and inference assumptions for saved reuse.

An `mfrm_imputed_fits` object with the `imputations` review, all `fits`
(including `NULL` for failures), `analysis_summary` recording every
fit's status, error and warnings, and common `settings`. Use
`pool_mfrm_imputed()` for eligible non-person facet targets.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object;
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
extracts the plotted `table`, exact contrast coefficients and inference
settings. The plot uses the saved pointwise MI interval endpoints; it
does not substitute normal intervals from the standard errors. Default
and `component = "table"` retain the complete interval view. Target
order, contrasts, degrees of freedom, confidence level and complete-data
information cautions remain attached through
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
Numerical interval-availability reasons and saved inference notes are
retained. Both base and ggplot views show a cross for a missing
interval. Fixed targets have open diamonds without intervals. In ggplot
conversion, infinite endpoints have arrows (their tips are display
limits, not finite bounds); missing intervals have crosses at the saved
estimate. Missing point estimates cause an error rather than being
placed at zero. Use source `title`/`subtitle` arguments or
[`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html)
to change text; hiding headings does not remove the attached inference
cautions.

An `mfrm_response_imputations` object containing the original `data`,
aligned `completed` data sets, `imputation_model`, an `events` table
with assignment/observation/imputation/omission status, a `support`
table counting original observed and imputed scores by person/facet
level, and `settings`. No imputations or failed analyses are silently
discarded.

## Details

For a common target, `Qbar` is the mean completed-data estimate, `Ubar`
the mean complete-data covariance and `B` their between-imputation
covariance. The total is `T = Ubar + (1 + 1/m) B`. The scalar
t-reference degrees of freedom are `(m - 1) / lambda^2`, with
`lambda = (1 + 1/m) B / T`, before any finite complete-data adjustment.
A zero between-imputation variance has infinite large-sample degrees of
freedom. Full covariances are transformed before scalar inference, so
rater differences include covariance between the two estimates. The
finite-data adjustment uses
\\\nu\_{obs}=\nu\_{com}(\nu\_{com}+1)/(\nu\_{com}+3)\\\bar U/T\\ and
\\1/\nu=1/\nu\_{old}+1/\nu\_{obs}\\. These t references are
approximations, not exact finite-sample pivots for an MFRM. Positive
interval widths that cannot be distinguished from zero at the returned
estimate, and endpoints outside floating-point range, are withheld with
a reason rather than reported as zero uncertainty or infinite bounds.

All fits must share categories, facet levels, signs, anchors,
interactions and identification. Known anchors are fixed and their
uncertainty is excluded. Singular or regularized free-parameter
information and any failed/ineligible completion prevent pooling. A
target fixed by a constraint is labelled `"fixed"`; it is not evidence
of perfect precision. A verified unregularized inverse of
ill-conditioned information can be used with a warning identifying the
affected imputations. Rubin pooling does not repair unreliable
complete-data approximations. Review interval widths, boundary proximity
and quadrature sensitivity before interpreting the pool.

The intervals are pointwise model-based multiple-imputation intervals,
conditional on adequate proper imputations and complete-data inference.
They are not robust intervals, simultaneous rater decisions or general
coverage guarantees. Do not pool EAPs, posterior SDs, fit statistics,
cluster labels or likelihood-ratio tests with this function. See the
executable assigned-score example in [online response-imputation
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-response-imputation.html).
It compares joint RSM predictive completions with direct observed-score
inference. Proper calibration priors in the imputer and MML estimates in
the completed-data analyses do not give exactly identical Bayesian
moments: that interpretation is a large-sample approximation requiring
review. The finite-imputation correction and `MonteCarloSE` assume
independent completed-data draws. Repeating completions is not
additional Monte Carlo evidence; correlated MCMC draws require sampling
review. Identical completed values can occur legitimately and are not
automatically rejected.

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

Every fit uses the same original category ladder, facet levels, anchors
and other supplied constraints, with fixed-standard-normal person MML
identification. `keep_original = TRUE` prevents per-completion category
collapsing. An unsupported category contrast, insufficient observed
information or failed optimization is retained as a failed or ineligible
analysis; subsequent pooling requires every imputation to qualify.

A common coordinate system does not establish model adequacy. Review the
imputation model, rating design and numerical integration. The fit
objects retain conditional person scores for individual review; those
EAPs and posterior SDs are not ordinary complete-data parameter
estimates and standard errors for Rubin pooling.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
pooled facet estimates or prespecified contrasts

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Plots use
the stored pointwise multiple-imputation intervals and preserve target
order. Open diamonds identify fixed targets without an inferential
interval. A zero reference line does not define a practical importance
threshold. The plot does not refit, select significant raters, adjust
for multiplicity or turn severity differences into rater quality.

The score must contain numeric integer category labels (numeric vectors,
or character/factor labels such as `"0"`, `"1"`). Recoded sentinel
missing values must already be `NA`. Identifiers, assignment indicators
and observed values must not change. Only selected scores may be filled;
missing auxiliary predictors may also be completed. For a `mids` input,
its original data and score `where` selection must agree with this
review. Numeric identifiers must remain distinct when converted to text.
Numeric observed predictors are compared exactly, without rounding to
text, and must remain numeric in completions; integer/double storage may
differ.

A sparse assignment and a missing assigned score are different events.
Neither absent roster rows nor explicit unassigned rows are imputed. An
entirely imputed person or facet level is visible in `support`; its
analysis depends on the imputation model, not on observed ratings for
that level. Imputed links do not establish empirical connectedness.

Proper multiple imputation must include uncertainty about missing values
and imputation parameters, reflect the ordinal score support and the
person/facet dependence, and be compatible with the intended analysis.
Include relevant observed predictors of nonresponse. An MAR analysis
requires an adequate conditional model; informative missingness beyond
observed predictors requires sensitivity analysis. Passing these
software checks does not establish MAR, model adequacy or interval
coverage.

For a wide-format or multilevel imputation model, reshape each
completion back to the original long roster using event identities and
supply the resulting list with the saved model. Do not average completed
scores. See [online response-imputation
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-response-imputation.html)
for a joint RSM example with supplied posterior predictive completions,
shared Person draws, sampling diagnostics, direct observed-score
inference and a separate lower-score sensitivity analysis. The
accompanying R/Stan script regenerates that example; it is not a general
imputation engine. Under the same score model and ignorable missingness,
observed-score MML can directly estimate the fixed-facet target without
completing scores. MI does not create additional observed information.

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

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

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
`review_mfrm_imputations()`, `fit_mfrm_imputed()`

`review_mfrm_imputations()`, `pool_mfrm_imputed()`

`pool_mfrm_imputed()`

`fit_mfrm_imputed()`, `pool_mfrm_imputed()`,
[`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)

## Examples

``` r
# Small supplied completions to illustrate input checks, not a fitted imputer.
ratings <- data.frame(Event = paste0("E", 1:4), Person = c("P1", "P1", "P2", "P2"),
  Rater = c("A", "B", "A", "B"), Score = c(0, NA, 1, 2))
first <- second <- ratings
first$Score[2] <- 1
second$Score[2] <- 2
reviewed <- review_mfrm_imputations(ratings, list(first, second),
  person = "Person", facets = "Rater", score = "Score", event_id = "Event",
  impute_ids = "E2", categories = 0:2,
  imputation_model = list(method = "Illustrative supplied completions"))
reviewed$events  # Only E2 is imputed; the three observed scores are retained.
#>   ID Assigned Observed Imputed Omitted
#> 1 E1     TRUE     TRUE   FALSE   FALSE
#> 2 E2     TRUE    FALSE    TRUE   FALSE
#> 3 E3     TRUE     TRUE   FALSE   FALSE
#> 4 E4     TRUE     TRUE   FALSE   FALSE
summary(reviewed)  # Original observed support and imputation counts per level.
#>    Facet Level Assigned Observed Imputed Omitted
#> 1 Person    P1        2        1       1       0
#> 2 Person    P2        2        2       0       0
#> 3  Rater     A        2        2       0       0
#> 4  Rater     B        2        1       1       0
```
