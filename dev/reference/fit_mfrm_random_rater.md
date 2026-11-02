# Fit a rating-scale model with shared random rater severity

Estimate rater severity when the raters are modeled as draws from a
specified population. Each rater has one effect shared across everyone
they rate. The rating-scale model (RSM) uses approximate marginal
maximum likelihood, with optional additive fixed facets. For a local
effect within one person's performance instead, see
[`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm_testlet.md).

## Usage

``` r
fit_mfrm_random_rater(
  data,
  person,
  rater,
  score,
  facets = character(),
  score_levels,
  rater_sd = NULL,
  quad_points = 31L,
  maxit = 300L,
  missing = c("fail", "omit"),
  person_sd = NULL,
  person_variance_max = 16
)

# S3 method for class 'mfrm_random_rater'
plot(
  x,
  draw = TRUE,
  style = c("interval", "precision", "distribution"),
  sort = c("input", "estimate", "uncertainty"),
  palette = c("accessible", "mono"),
  title = NULL,
  caption = NULL,
  show_title = FALSE,
  show_notes = FALSE,
  show_labels = TRUE,
  reference = 0,
  text_scale = 1,
  point_size = 2.5,
  intervals = c("none", "normal"),
  ...
)

# S3 method for class 'mfrm_random_rater'
summary(object, ..., calibration_intervals = c("none", "normal"), level = 0.95)

# S3 method for class 'mfrm_random_rater'
print(x, ...)
```

## Arguments

- data:

  Long-format data, one row per observed or assigned rating.

- person, rater, score:

  Names of the person, rater and numeric score columns.

- facets:

  Character vector of fixed-facet columns; default none. Include task or
  criterion columns explicitly when their difficulties are part of the
  intended model; their presence in `data` alone does not include them.

- score_levels:

  Required consecutive integer score categories, in order.

- rater_sd:

  `NULL` estimates the population SD of rater severity. A nonnegative
  number fixes it as known; zero removes rater heterogeneity.

- quad_points:

  Number of standard-normal Gauss-Hermite points for each person
  integral, from 7 to 241; default 31. The result is also evaluated at
  `2 * quad_points + 1` points to check this integral's numerical
  stability. This check does not assess the separate rater Laplace
  approximation. If `checks$PersonQuadratureStable` is false, refit with
  more points and recheck all of `checks`; a higher-order evaluation
  alone does not refit the calibration. No allowed order is universally
  sufficient.

- maxit:

  Maximum optimizer iterations per start; default 300.

- missing:

  `"fail"` (default) refuses missing assigned scores; `"omit"`
  explicitly analyzes observed scores and records omitted rows.

- person_sd:

  `NULL` (default) estimates the normal ability SD. A finite positive
  number fixes it as known; `person_sd = 1` retains the standard normal
  population. This is a population restriction with Rasch slope one.

- person_variance_max:

  Positive upper search bound for estimated ability variance;
  default 16. Reaching it fails numerical readiness; increase the bound
  and refit rather than interpreting a capped estimate as a solution.

- x:

  A result from `fit_mfrm_random_rater()`.

  Also for [`summary()`](https://rdrr.io/r/base/summary.html): A fitted
  `mfrm_random_rater` object.

- draw:

  Logical; `FALSE` returns plot data without opening a device.

- style:

  `"interval"` keeps every labeled row; `"precision"` plots estimates
  against interval width (upper minus lower bound); `"distribution"`
  shows the empirical cumulative distribution of finite point estimates,
  excluding prior-only and unavailable scores. No density is
  reconstructed.

- sort:

  Row order for interval plots: input order, increasing estimate, or
  increasing interval width. Missing values come last; ties retain input
  order. Sorting is descriptive, not a test of differences.

- palette:

  `"accessible"` uses blue and dark orange with filled/open symbols;
  `"mono"` uses dark grey with the same symbol distinctions.

- title, caption:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- show_title, show_notes:

  Show the title and caption, respectively. `FALSE` hides text without
  deleting its metadata.

- show_labels:

  Show IDs on interval and precision plots. Distribution plots summarize
  estimates and do not label individual IDs. For crowded precision plots
  use `FALSE` and consult the retained table.

- reference:

  Vertical reference line in logits; `NULL` omits it. This is an
  orientation aid, not a quality threshold.

- text_scale:

  Positive multiplier for text size.

- point_size:

  Positive point size in ggplot millimetres; base graphics use the
  corresponding relative size (2.5 is the default).

- intervals:

  `"none"` (default) displays point estimates without automatic
  prediction intervals. `"normal"` explicitly requests the first-order
  approximation from `confint(x, parm = "raters")`; nominal coverage is
  not established. Required for the interval-width precision view and
  sorting by interval width (`sort = "uncertainty"`).

- ...:

  For `summary.mfrm_random_rater()`: Unused by summary and print.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Unused.

- object:

  A fitted `mfrm_random_rater` object.

- calibration_intervals:

  For summaries, `"none"` (default) omits calibration bounds; `"normal"`
  explicitly requests their pointwise normal approximation. This does
  not select individual-rater intervals.

- level:

  Nominal level for explicitly requested summary calibration intervals;
  default 0.95. Numerical and variance-boundary restrictions remain.

## Value

An `mfrm_random_rater` object with `calibration_table`, `raters`, full
covariance matrices, `checks`, analysis data/omitted-row accounting,
model settings and optimizer records. It contains no native pointers;
save it with [`saveRDS()`](https://rdrr.io/r/base/readRDS.html). Its
summary, plot and prediction methods are specific to this model; it is
not an ordinary `mfrm_fit` or portable fixed-facet calibration object.
Calibration and summary rater tables retain `IntervalStatus`,
`CIEligible` and `InferenceReview` for normal-interval availability.
These distinguish unrequested bounds, unsupported targets and unresolved
checks or variance boundaries; see
[`confint.mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/confint.mfrm_random_rater.md).
Retained points require the separate fit checks and are not certified by
these fields.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
extracts the rater table, display metadata, and settings.

## Details

The adjacent-category logit is \$\$\log\\P(Y\_{prj}=k)/P(Y\_{prj}=k-1)\\
= \theta_p-u_r-x\_{prj}'\beta-\delta_k.\$\$ Persons are independent
\\N(0,\sigma_p^2)\\ and raters independent \\N(0,\sigma_r^2)\\,
independent of persons and assignment. Fixed-facet level effects sum to
zero. Steps are unconstrained adjacent thresholds; they need not be
ordered or sum to zero. Their mean sets the overall location. Rater
effects are not centered within the observed sample.

This is a frequentist likelihood fit, with no priors on calibration or
variance parameters. Person effects are integrated by quadrature
conditional on all shared rater effects; the resulting joint rater
integral uses the Laplace approximation through the optional RTMB
package. Integrating a new rater separately for each person would fit a
different model. After marginalization, Persons sharing a rater are
dependent. Adding Persons rated by the same fixed panel does not add
independent draws from the rater population. Even if those rater effects
became known exactly, a fixed number of draws would not consistently
estimate a positive population variance. Person count or total rating
count alone therefore cannot justify ordinary large-sample population-SD
inference. The full calibration information includes all estimated
population SDs, but this does not establish the required asymptotic
regime or Laplace accuracy.

The initial scope is RSM, unit weights, a connected person-rater design,
multiple persons per rater, and full-rank additive fixed-facet coding.
Every declared category must occur. Nonassigned combinations are absent;
omitted scores are not imputed. Informative assignment, nonnormal rater
populations, PCM, anchors, interactions, testlets and latent regression
are not implemented by this route. Connectedness alone does not
guarantee adequate information about rater variance. A fixed-facet level
with only minimum or only maximum scores has no finite calibration
estimate. Such separation fails `checks$NumericalReady` and
`checks$InformationPositive`, even if the optimizer reports convergence.
`checks$FixedFacetSeparation` records this sufficient separation check;
its absence does not exclude separation along combinations of facets.

Both estimated zero variances are considered explicitly. One-sided
variance scores check these boundaries; the derivative with respect to
SD alone cannot establish them. The ability-variance score uses checked
one-sided differences of the complete approximate marginal likelihood,
including the rater Laplace determinant. At either estimated boundary,
regular calibration and rater intervals are withheld. A fixed zero SD is
a known submodel, not a fitted model with arbitrary fixed rater
severities.

Fixed-facet and step tables retain estimates and approximate SEs but
omit bounds by default.
`confint(fit, parm = "calibration", level = 0.95)` or
`summary(fit, calibration_intervals = "normal", level = 0.95)`
explicitly requests observed-information normal approximations at an
interior fit. Their finite-sample coverage is not established.
Rebuilding summaries or
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_results.md)
from an older saved fit applies this policy without refitting or
changing the saved fit. Population-SD intervals are requested separately
with `confint(fit, parm = "rater_sd")`; no ability-SD interval is
supplied. This avoids a Wald interval that excludes zero by
construction. Rater estimates are conditional modes. Their
`ConditionalSD` holds calibration fixed; `PredictionSE` adds first-order
calibration uncertainty through RTMB's generalized delta method.
Individual rater interval bounds are missing by default: nominal
coverage is not established. `confint(fit, parm = "raters")` explicitly
requests the normal approximation from saved estimates without
refitting; `plot(fit, intervals = "normal")` displays it. These target
realized random effects, not fixed-rater coefficients, and do not
classify or exclude raters. This output restriction does not correct
interval coverage.

With estimated ability SD, a four-condition study (200 datasets per
condition) found conditional individual-rater coverage of 91.6–91.8%
with six raters and 94.0–94.1% with 24 raters; finite-interval
availability was 99% and 87–88%, respectively. None met the prespecified
combined coverage and availability criterion. Six-rater Monte Carlo
uncertainty also prevented a conclusive material-undercoverage decision
in this study. An earlier known-ability-SD pilot found 84.2% six-rater
coverage. See [online random-rater
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-random-raters.html)
for designs and Monte Carlo intervals. These studies do not establish a
safe minimum rater count. Numerical checks do not certify statistical
validity or shared-rater Laplace accuracy.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
observed-rater severity under a shared-rater RSM

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Points are
conditional modes of severity relative to the rater population mean
zero; positive values mean more severe ratings. No individual rater
intervals are supplied automatically, including for earlier saved fits.
Explicit normal whiskers are approximate 95% prediction intervals, not
qualified rater classifications. At an estimated zero variance or with
unresolved numerical checks, even requested whiskers are unavailable.

## Numerical evidence

An independent comparison evaluated local marginal-likelihood changes at
eight saved calibrations for three-category RSMs with 240 Persons, six
or 24 raters, and rotating or weakly linked assignments. Displacements
spanned all six calibration coordinates and named contrast/SD
directions, scaled to one local information unit. All 144 planned
comparisons (128 distinct parameter points) met a
0.05-log-likelihood-unit tolerance including Monte Carlo uncertainty.
The largest difference was 0.005 log-likelihood units. The reference
reused joint posterior samples with an exact change-of-variables
identity; the package likelihood and estimator were unchanged.

This supports the tested local likelihood changes, not an exact maximum-
likelihood solution, an absolute likelihood normalization, the entire SD
profile, variance boundaries or repeated-sampling interval coverage.
Person quadrature checks remain distinct from this comparison. See
[online random-rater
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-random-raters.html)
for the reference-precision limits and scope.

## Model assumptions and related research

A shared rater effect represents differences in usual severity across
raters, not inconsistency within a rater or differential severity toward
a subgroup. Van den Noortgate et al. (2003, equation 7) describe crossed
normal effects for binary responses. The binary case here has that
sharing structure, with the rater sign reversed and unit Rasch slope.
Huang and Cai (2024) extend crossed effects to item-level ordinal
responses, using cumulative graded-response probabilities and estimated
slopes. Their model and estimator are not this adjacent-category RSM and
Laplace fit.

Fixing ability variance at one while keeping the Rasch slope at one is a
population restriction, not merely a change of units. The default
estimates this variance, keeping the ability mean zero and step location
free. It does not fit group-specific distributions or latent regression.
Unequal ability populations across rater panels can violate its
assumptions even when the assignment is connected. A successful
numerical check cannot assess those population assumptions. Earlier
saved fits without ability-population parameters retain their original
known N(0,1) meaning for predictions, profiles and bootstrap refits.

## Relation to testlets and discrimination

A shared severity effect is not a random discrimination parameter. This
RSM does not estimate GPCM slopes. Its rater effect spans persons,
whereas
[`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm_testlet.md)
uses a distinct effect for each Person/block pair, even when the block
is named Rater. These sharing structures lead to different marginal
likelihoods and prediction targets; the two routes cannot currently be
combined. See
[mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_gpcm_scope.md)
for the relationship to fixed slope families and local independence.

## Comparison with fixed-rater MFRM

Compare the same observed rating events, categories, fixed facets and
ability population. Fixed rater effects describe the observed panel;
random effects refer to a population and are shrunk toward its mean.
Their raw locations need not share an origin. Compare aligned rater
contrasts or predictions at the same ability and facet settings. Setting
`rater_sd = 0` removes all rater differences; it does not recover a
model with freely estimated fixed rater effects. Shared raters induce
dependence across Persons after marginalization, so a Person-count BIC
or ordinary chi-squared likelihood-ratio test must not be copied from
the fixed-facet model.
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/compare_mfrm.md)
checks matched events and compares centered facet summaries, retaining
each model's assumptions and readiness. It does not rank models or
calculate intervals for their differences.

## References

Van den Noortgate, W., De Boeck, P. and Meulders, M. (2003).
Cross-classification multilevel logistic models in psychometrics.
*Journal of Educational and Behavioral Statistics*, 28, 369–386.
[doi:10.3102/10769986028004369](https://doi.org/10.3102/10769986028004369)
.

Huang, S. and Cai, L. (2024). Cross-classified item response theory
modeling with an application to student evaluation of teaching. *Journal
of Educational and Behavioral Statistics*, 49, 311–341.
[doi:10.3102/10769986231193351](https://doi.org/10.3102/10769986231193351)
.

Kristensen, K., Nielsen, A., Berg, C. W., Skaug, H. and Bell, B. M.
(2016). TMB: Automatic differentiation and Laplace approximation.
*Journal of Statistical Software*, 70(5), 1–21.
[doi:10.18637/jss.v070.i05](https://doi.org/10.18637/jss.v070.i05) .

## See also

[`score_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/score_mfrm_random_rater.md),
[`predict.mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict.mfrm_random_rater.md),
`plot.mfrm_random_rater()`,
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_response_diagnostics.md)
for descriptive posterior predictive residuals,
[`confint.mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/confint.mfrm_random_rater.md),
[`mfrm_random_rater_intervals()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_random_rater_intervals.md),
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_results.md)

[`plot.mfrm_testlet_scores()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict.mfrm_testlet.md)
for view selection and accessible output. The distribution view
summarizes the observed conditional modes, not the assumed rater
population.

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("fit_mfrm_random_rater", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Inspecting this saved synthetic fit does not require RTMB.
example <- readRDS(system.file("examples", "extended-models.rds", package = "mfrmr"))
fit <- example$random_rater$fit
# To refit instead, install optional RTMB >= 2.0 and run:
# ratings <- load_mfrmr_data("example_core")
# fit <- fit_mfrm_random_rater(ratings, "Person", "Rater", "Score",
#   facets = "Criterion", score_levels = 1:4, quad_points = 121)
summary(fit)
plot(fit)
recipe <- system.file("examples", "extended-models.R", package = "mfrmr")
# Run source(recipe) separately to regenerate the saved fits.
} # }
```
