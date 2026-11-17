# Score Persons using a fixed testlet calibration

Recompute Person scores from all supplied rows, integrating local
effects within each Person/testlet block and conditioning on fitted
calibration.

Account for extra dependence among ratings of the same person, for
example several rubric criteria from one performance. A testlet
identifies the ratings sharing this local effect within that person. The
rating-scale model (RSM) estimates fixed facets, normal ability variance
and one common local variance. For a rater effect shared across people
instead, see
[`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md).

## Usage

``` r
# S3 method for class 'mfrm_testlet'
predict(
  object,
  newdata = NULL,
  level = 0.95,
  quad_points = object$settings$quad_points,
  missing = if (is.null(newdata)) object$settings$missing else "fail",
  persons = NULL,
  ...
)

fit_mfrm_testlet(
  data,
  person,
  score,
  testlet,
  facets = character(),
  score_levels,
  testlet_variance = NULL,
  quad_points = 31L,
  maxit = 300L,
  variance_max = 16,
  missing = c("fail", "omit"),
  person_sd = NULL,
  person_variance_max = 16
)

# S3 method for class 'mfrm_testlet'
confint(object, parm = "calibration", level = 0.95, ...)

# S3 method for class 'mfrm_testlet_scores'
summary(object, ...)

# S3 method for class 'mfrm_testlet_scores'
print(x, ...)

# S3 method for class 'mfrm_testlet'
plot(
  x,
  facet = x$input$columns$facets[1],
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
  level = 0.95,
  ...
)

# S3 method for class 'mfrm_testlet_scores'
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
  ...
)

# S3 method for class 'mfrm_testlet'
summary(object, ..., calibration_intervals = c("none", "normal"), level = 0.95)

# S3 method for class 'mfrm_testlet'
print(x, ...)
```

## Arguments

- object:

  A result from `fit_mfrm_testlet()`.

- newdata:

  Long-format ratings with the fitted column names. `NULL` reuses the
  source assignment, including missing-score rows. New Person and
  testlet labels are allowed; every fixed-facet level must be known. If
  the testlet column is also a fixed facet, its labels must therefore be
  known. For example, with `testlet = "Rater"` and `"Rater"` in
  `facets`, this function cannot score a new rater whose fixed severity
  was not fitted.

- level:

  For `summary.mfrm_testlet()`: Nominal level for explicitly requested
  summary calibration intervals; default 0.95. Numerical and
  variance-boundary restrictions remain.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Nominal
  level of explicitly requested calibration intervals; default 0.95.
  This does not establish finite-sample coverage.

- quad_points:

  Standard-normal quadrature order for both integrals, from 7 to 121;
  default 31. Results are checked at `2 * quad_points + 1`.

- missing:

  `"fail"` (default) refuses missing assigned scores; `"omit"` analyzes
  observed rows and records the omissions.

- persons:

  Distinct Person IDs to return, or `NULL` for all. This selects outputs
  while retaining the complete supplied scoring roster.

- ...:

  Unused.

- data:

  Long-format ratings; each row is one assigned rating.

- person:

  Column names. `testlet` identifies a group within a Person and may
  also occur in `facets`, for example a fixed Rater effect.

- score:

  Column names. `testlet` identifies a group within a Person and may
  also occur in `facets`, for example a fixed Rater effect.

- testlet:

  Column names. `testlet` identifies a group within a Person and may
  also occur in `facets`, for example a fixed Rater effect.

- facets:

  Fixed-facet column names; default none. A column used as `testlet` is
  not automatically a fixed facet. For example, `testlet = "Task"`
  models local dependence; also specify `facets = "Task"` if the model
  should estimate fixed task difficulties.

- score_levels:

  Consecutive integer categories in increasing order.

- testlet_variance:

  `NULL` estimates the common local variance. A nonnegative number fixes
  it as known; zero removes local dependence.

- maxit:

  Maximum iterations per optimization start; default 300.

- variance_max:

  Upper search bound for an estimated variance; default 16. A fit
  reaching this bound is not numerically ready.

- person_sd:

  `NULL` (default) estimates the SD of a mean-zero normal ability
  population. A positive number fixes the SD as known. Use `1` to
  reproduce the earlier fixed N(0,1) model; this is a population
  assumption, not merely a choice of units.

- person_variance_max:

  Upper search bound for estimated ability variance (not SD);
  default 16. Reaching it withholds numerical readiness.

- parm:

  `"calibration"` returns all fixed-facet and step intervals. Variance
  components and Person abilities are not included.

- x:

  An object from `fit_mfrm_testlet()`.

  Also for `fit_mfrm_testlet()`: An `mfrm_testlet` result.

- facet:

  A fixed facet to display; defaults to the first fixed facet.

- draw:

  `FALSE` returns plot data without opening a device.

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

  `"none"` (default) shows points only; `"normal"` explicitly requests
  observed-information normal-approximation bounds. Interval-width views
  or sorting require this explicit selection.

- calibration_intervals:

  For summaries, `"none"` (default) omits calibration bounds; `"normal"`
  explicitly requests their pointwise normal approximation. Person
  scoring remains a separate conditional output.

## Value

An `mfrm_testlet_scores` object with one table row per requested Person,
omitted-row accounting, block sizes, settings, calibration and
prediction-source metadata for
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).
[`summary()`](https://rdrr.io/r/base/summary.html) reports all statuses;
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
when `draw = FALSE`. Saved scoring results need no live optimizer. Keep
`table$Status` and `table$Reason` with exported scores: `prior_only`
describes the assumed population without observed responses for that
Person; `unavailable` withholds the estimate, SD and bounds with a
recorded cause.

An `mfrm_testlet` object with calibration, covariance, calibration
table, checks, all optimization runs, input/omission accounting and
settings. It contains no native pointers; use
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) and
[`readRDS()`](https://rdrr.io/r/base/readRDS.html). Calibration tables
retain `IntervalStatus`, `CIEligible` and `InferenceReview` for missing
or explicitly requested normal bounds; see `confint.mfrm_testlet()` for
the status meanings. A retained point is not certified by interval
availability. Inspect `checks` before interpreting it.

A matrix with `Lower` and `Upper`, one row per fixed-facet level or
step, and attributes `level`, `method`, `target`, `note`, `checks` and
`diagnostics`. `attr(ci, "diagnostics")` retains each estimate, SE,
`IntervalStatus`, `CIEligible` and plain-language `InferenceReview`;
`checks` retains the source checks without recomputing them. Save the
whole object with [`saveRDS()`](https://rdrr.io/r/base/readRDS.html);
for CSV, export the diagnostics table to retain reasons.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object; use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object;
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
retains all requested Persons, their statuses, interval endpoints and
settings.

## Details

All supplied rows for a Person are scored jointly. This does not append
to cached responses or condition on a stored local-effect mode. The
saved settings retain this integration, effect-sharing and roster
interpretation.
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
retains the complete `scoring_data` as its `scoring_roster` table,
including explicitly omitted scores, alongside observed block counts.
Column names and row order are preserved. To add ratings for an existing
Person, supply that Person's complete set of ratings once, with
memberships that correctly identify effects shared within that set.
Scores from separate calls are not automatically linked within a Person
or testlet. No fixed effects are re-estimated. Unequal block sizes do
not imply equal block weights. The influence of an additional response
depends on its block and the fitted model; integrating local effects is
not a general correction for assignment or content bias. See [online
testlet-applications
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-testlet-applications.html)
for a complete-roster comparison of one-point changes in five- versus
two-criterion tasks.

EAP, posterior SD and intervals use continuous ability integration.
Interval endpoints invert the continuous CDF rather than a finite
quadrature-grid CDF. Local-effect integration is compared at two orders;
errors or unresolved differences retain a row with unavailable scores
and an explanation. An explicitly omitted, entirely missing Person
returns the fitted or specified mean-zero normal ability population with
status `"prior_only"`, not evidence of measured average ability.

Calibration is held fixed, including ability and testlet variances. If
the fitted ability variance is zero, all requested Persons retain
unavailable rows with a reason; no zero-width ability interval is
reported. At an estimated zero variance this is scoring under that
fitted submodel, not evidence that dependence is absent. Prior/posterior
terminology refers to latent Person scoring; calibration remains
frequentist MML. A 480-dataset same-source simulation estimating both
variances, replayed after correcting numerical start selection, found
Person-interval coverage of 94.4% with 120 Persons and 91.7% with 24
Persons under balanced positive local dependence; coverage was 93.3% in
one sparse, unequal-block condition with 120 Persons. The original
numerical failures and their repair remain separately documented.
Accounting for dependence improved coverage relative to ordinary RSM,
but did not consistently improve EAP mean squared error. See [online
testlet
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-testlets.html)
for the comparison, Monte Carlo uncertainty and numerical-selection
correction. These intervals neither correct calibration-estimation
uncertainty nor guarantee 95% coverage for each fixed ability. Person
contrasts and simultaneous decisions are not provided by this route.

Fits the Person-specific testlet RSM
\$\$\log\\P(Y\_{pbi}=k)/P(Y\_{pbi}=k-1)\\ = \theta_p + \gamma\_{pb} -
x\_{pbi}'\beta - \delta_k,\$\$ with independent \\\theta_p \sim N(0,
\sigma_p^2)\\ and Person-block local effects \\\gamma\_{pb} \sim N(0,
v)\\, sum-to-zero fixed facets \\\beta\\, and free steps \\\delta_k\\
via nested Gaussian quadrature (unit weights, non-overlapping blocks, at
least two multi-testlet Persons and two repeated-rating testlets).
Zero-variance boundaries (one-sided variance scores), `[-20, 20]`
parameter bounds, quadrature stability, gradient, and information are
recorded in `checks`.

Calibration bounds are omitted by default and requested explicitly via
`confint(fit, parm = "calibration")`; zero estimated ability variance
leaves `predict.mfrm_testlet()` Person scores unavailable rather than
zero-width. See
[`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
for raters shared across Persons and the [online testlet-applications
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-testlet-applications.html)
for task-allocation examples.

The explicit request computes estimate plus/minus a normal quantile
times the saved observed-information SE. It needs no fitting, scoring or
live optimizer and does not change the source fit. Nominal finite-sample
coverage is not established. Estimated variance boundaries, unresolved
numerical/information checks and invalid SEs retain missing bounds. No
regular variance interval, simultaneous comparison or automatic rater
classification is supplied. Default fit tables, summaries and plots omit
these bounds. Use `summary(fit, calibration_intervals = "normal")`,
`plot(fit, intervals = "normal")`, or
`mfrm_results(fit, calibration_intervals = "normal")` to select the same
approximation in those outputs; their level arguments retain its nominal
interpretation. `predict.mfrm_testlet()` supplies the separate
conditional Person-scoring intervals.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
testlet-model fixed-facet estimates

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Requested
whiskers are observed-information normal approximations for calibration
parameters; finite-sample coverage is not established. Missing intervals
remain missing; points do not classify rater quality.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
and
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
provide the same table without drawing.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
preserves the interval meaning and missing whiskers.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
conditional Person scores from a testlet model

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): In the
default interval view, empty rows remain labeled. Open circles mark
prior-only results; filled points are response-based conditional scores.
The intervals exclude calibration-estimation uncertainty and are not
tests of Person differences.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
preserves all labeled rows, prior-only symbols and the
conditional-interval note.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
retains statuses and reasons for custom graphics or table export;
conversion does not rerun scoring.

## Reading missing bounds

`estimated_variance_boundary` means an estimated variance is at zero;
regular normal inference is withheld even when a point is retained.
`numerical_review_failed` means numerical readiness or positive
information has not been established; `InferenceReview` retains all
detected reasons, including any simultaneous boundary. Increasing
iterations alone does not repair a variance-boundary restriction.
Inspect `attr(ci, "checks")` first. `invalid_estimate_or_se` and
`nonfinite_bounds` identify row-specific calculation failures. Missing
bounds are neither zero uncertainty nor infinite endpoints. Retaining a
point does not certify its reliability. Default calibration tables also
distinguish `not_requested` from `unsupported_target` (population
SDs/variances). `CIEligible` is true only for a returned normal
interval; it is not a coverage guarantee.

## Choosing a view

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

Interval plots answer where estimates lie and how uncertain they are.
Precision plots help identify estimates with wider intervals; width is
neither a fit statistic nor a reliability coefficient. Finite intervals
are required and excluded rows remain in `display_data` with reasons.
Distribution plots summarize the selected point estimates, which are
affected by shrinkage and the selected roster. They do not estimate the
latent population distribution, show posterior densities, or imply
independent observations.

## Accessible and reusable output

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

Colours are supplemented by point shapes; open circles mean prior only.
Use `palette = "mono"` for monochrome reproduction.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
retains the complete source `table`, `display_data` with inclusion
reasons, `alt_text`, interpretation `notes`, and display settings.
Supply the text alternative and table alongside exported figures; image
files alone do not automatically expose that information to screen
readers.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
preserves the view and display controls, supplies `labs(alt = ...)`, and
allows further `labs()`, `theme()` and scale edits. Rendering does not
fit, score or resample. Use the same controls through
`plot(results, type = "scores", style = "precision")`.

## References

Wang, W.-C. and Wilson, M. (2005). The Rasch testlet model. *Applied
Psychological Measurement*, 29, 126–149.
[doi:10.1177/0146621604271053](https://doi.org/10.1177/0146621604271053)
.

Wang, W.-C. and Wilson, M. (2005). Exploring local item dependence using
a random-effects facet model. *Applied Psychological Measurement*, 29,
296–318.
[doi:10.1177/0146621605276281](https://doi.org/10.1177/0146621605276281)
.

## See also

`fit_mfrm_testlet()`, `plot.mfrm_testlet_scores()`,
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)

`predict.mfrm_testlet()`, `plot.mfrm_testlet()`,
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
for descriptive posterior predictive residuals.

[`confint.mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
`plot.mfrm_testlet_scores()`

`plot.mfrm_testlet()`,
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("predict.mfrm_testlet", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
example <- readRDS(system.file("examples", "extended-models.rds", package = "mfrmr"))
fit <- example$testlet$fit
scores <- example$testlet$scores
# To recompute these conditional scores:
# ratings <- load_mfrmr_data("example_core")
# scores <- predict(fit, persons = as.character(unique(ratings$Person)[1:4]))
# Selecting outputs retains the complete source roster for model maps.
scores$table
plot(scores)
} # }
# Optional workflow; run the example explicitly as shown below.
# example("fit_mfrm_testlet", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved fit for the synthetic example_core ratings.
example <- readRDS(system.file("examples", "extended-models.rds", package = "mfrmr"))
fit <- example$testlet$fit
# To refit instead (this takes longer than inspecting the saved result):
# ratings <- load_mfrmr_data("example_core")
# fit <- fit_mfrm_testlet(ratings, "Person", "Score", "Rater",
#   facets = c("Rater", "Criterion"), score_levels = 1:4, quad_points = 121)
fit$checks
plot(fit, facet = "Rater")
# The complete regeneration recipe is included with the package:
recipe <- system.file("examples", "extended-models.R", package = "mfrmr")
# Run source(recipe) separately to regenerate the saved fits.
} # }
```
