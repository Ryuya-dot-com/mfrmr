# Fit a rating-scale model with shared random rater severity

Estimate rater severity when the raters are modeled as draws from a
specified population. Each rater has one effect shared across everyone
they rate. The rating-scale model (RSM) uses approximate marginal
maximum likelihood, with optional additive fixed facets. For a local
effect within one person's performance instead, see
[`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md).

Evaluate a shared-rater RSM at explicitly supplied ability values.

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
predict(
  object,
  newdata,
  ability,
  rater = c("observed", "new"),
  quad_points = 41L,
  ...
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
confint(object, parm = "rater_sd", level = 0.95, ...)

# S3 method for class 'mfrm_random_rater'
summary(object, ..., calibration_intervals = c("none", "normal"), level = 0.95)

# S3 method for class 'mfrm_random_rater'
print(x, ...)
```

## Arguments

- data:

  Long-format data, one row per observed or assigned rating.

- person:

  Names of the person, rater and numeric score columns.

- rater:

  `"observed"` uses the approximate conditional distribution of an
  observed rater given the calibration responses. `"new"` integrates a
  replacement rater from the estimated population distribution. The
  target is explicit; an unfamiliar label is never silently treated as
  observed.

- score:

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

  Normal quadrature points for the prediction integral, from 7 to 121;
  default 41. Compare orders when needed.

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

- object:

  A fitted `mfrm_random_rater` object.

- newdata:

  Data frame with the fitted rater column and every fixed-facet column.
  Observed-rater labels must be known; replacement-rater labels must be
  new. Fixed-facet levels must always be known.

- ability:

  A finite numeric value for all rows, one value per row, or the name of
  a numeric column of `newdata`. These are specified abilities on the
  fitted logit scale (mean ability zero, Rasch slope one), not estimated
  person scores. A value of one is one logit, not one population SD.

- ...:

  For `summary.mfrm_random_rater()`: Unused by summary and print.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Unused.

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

- title:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- caption:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- show_title:

  Show the title and caption, respectively. `FALSE` hides text without
  deleting its metadata.

- show_notes:

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

- parm:

  `"rater_sd"` (default) profiles population variation. `"raters"`
  explicitly requests first-order normal prediction intervals for all
  observed raters. These are not supplied automatically because their
  nominal coverage is not established. `"calibration"` explicitly
  requests observed-information normal approximations for fixed-facet
  levels and steps, excluding population SDs.

- level:

  Nominal level for explicitly requested summary calibration intervals;
  default 0.95. Numerical and variance-boundary restrictions remain.

- calibration_intervals:

  For summaries, `"none"` (default) omits calibration bounds; `"normal"`
  explicitly requests their pointwise normal approximation. This does
  not select individual-rater intervals.

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
checks or variance boundaries; see `confint.mfrm_random_rater()`.
Retained points require the separate fit checks and are not certified by
these fields.

A list with `probabilities` (rows by categories), `expected_scores`,
`newdata`, `ability`, `settings` and matching `source` metadata for
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).
No model is refitted. Save this list together with the fitted model and
prediction inputs. The settings record the effect-sharing unit and
whether integration uses the observed rater's conditional distribution
or the replacement-rater population. These are preserved in the
prediction settings table of
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
extracts the rater table, display metadata, and settings.

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
[`confint.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
for the status meanings. A missing interval does not turn a retained
point into a reliable estimate, and more iterations cannot by themselves
remove an estimated-variance boundary restriction.

## Details

Fits the crossed random-rater RSM
\$\$\log\\P(Y\_{prj}=k)/P(Y\_{prj}=k-1)\\ = \theta_p - u_r -
x\_{prj}'\beta - \delta_k,\$\$ with independent \\\theta_p \sim N(0,
\sigma_p^2)\\ and shared rater severities \\u_r \sim N(0, \sigma_r^2)\\,
sum-to-zero fixed-facet effects \\\beta\\, and free adjacent steps
\\\delta_k\\. Person integrals use Gauss-Hermite quadrature conditional
on \\u\\, and the joint shared-rater integral uses RTMB's Laplace
approximation (unit weights, connected design, observed categories).
Extreme fixed-facet separation and zero-variance boundaries (checked via
one-sided variance scores) fail `checks$NumericalReady` or withhold
regular intervals.

Calibration and conditional-mode rater bounds (`ConditionalSD` vs
`PredictionSE`) are omitted by default and requested explicitly via
`confint(fit, parm = "calibration" | "rater_sd" | "raters")`;
finite-sample coverage is not guaranteed with few raters (see the
[online random-rater
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-random-raters.html)
for likelihood and coverage benchmarks, and
[`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
for Person-specific local dependence).

Predictions condition on estimated calibration and supplied ability.
They do not propagate calibration-estimation uncertainty or uncertainty
about ability. Observed-rater integration uses the conditional Laplace
mean/mode and covariance, not the calibration-adjusted prediction SE.
New-rater integration uses the population SD: substituting severity zero
generally produces different probabilities.

Rows are marginal probabilities for individual future ratings, not a
joint distribution or an interval for their average. Ratings with the
same new rater ID share one random severity in the model; multiplying
these row probabilities would discard that dependence. This function
does not score latent abilities from responses or impute missing
assigned scores. Use
[`score_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md)
for conditional Person scoring from a complete joint response roster.
Supplying a score column in `newdata` does not update rater
distributions or estimate abilities. Use the scoring function and its
complete-roster rules when the input is a new batch of observed
responses.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
observed-rater severity under a shared-rater RSM

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Points are
conditional modes of severity relative to the rater population mean
zero; positive values mean more severe ratings. No individual rater
intervals are supplied automatically, including for earlier saved fits.
Explicit normal whiskers are approximate 95% prediction intervals, not
qualified rater classifications. At an estimated zero variance or with
unresolved numerical checks, even requested whiskers are unavailable.

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
particular, few-rater coverage remains unresolved; see [online
random-rater
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-random-raters.html).
Requesting this approximation does not make it qualified for
classification or exclusion of raters. It is not a profile interval, a
bootstrap or an interval for a difference of raters.

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

Self, S. G. and Liang, K.-Y. (1987). Asymptotic properties of maximum
likelihood estimators and likelihood ratio tests under nonstandard
conditions. *Journal of the American Statistical Association*, 82,
605–610.
[doi:10.1080/01621459.1987.10478472](https://doi.org/10.1080/01621459.1987.10478472)
.

## See also

[`score_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md),
`predict.mfrm_random_rater()`, `plot.mfrm_random_rater()`,
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
for descriptive posterior predictive residuals,
`confint.mfrm_random_rater()`,
[`mfrm_random_rater_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md),
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)

[`plot.mfrm_testlet_scores()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
for view selection and accessible output. The distribution view
summarizes the observed conditional modes, not the assumed rater
population.

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
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
