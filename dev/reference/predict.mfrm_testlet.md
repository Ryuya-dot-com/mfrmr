# Score Persons using a fixed testlet calibration

Recompute Person scores from all supplied rows, integrating local
effects within each Person/testlet block and conditioning on fitted
calibration.

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

# S3 method for class 'mfrm_testlet_scores'
summary(object, ...)

# S3 method for class 'mfrm_testlet_scores'
print(x, ...)

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
```

## Arguments

- object:

  A ready
  [`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm_testlet.md)
  result.

- newdata:

  Long-format ratings with the fitted column names. `NULL` reuses the
  source assignment, including missing-score rows. New Person and
  testlet labels are allowed; every fixed-facet level must be known. If
  the testlet column is also a fixed facet, its labels must therefore be
  known. For example, with `testlet = "Rater"` and `"Rater"` in
  `facets`, this function cannot score a new rater whose fixed severity
  was not fitted.

- level:

  Conditional equal-tail posterior interval probability; default 0.95.
  These are not calibration-adjusted frequentist confidence intervals.

- quad_points:

  Local-effect quadrature order, 7 to 121. Default uses the fitting
  order; each Person is also checked at `2 * quad_points + 1`.

- missing:

  `"fail"` or `"omit"`. Default reuses the fit's missing-score policy
  for source replay and requires explicit omission for new data.

- persons:

  Distinct Person IDs to return, or `NULL` for all. This selects outputs
  while retaining the complete supplied scoring roster.

- ...:

  Unused.

- x:

  For `predict.mfrm_testlet()`: A scoring result.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): A result
  from `predict.mfrm_testlet()`.

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

## Value

An `mfrm_testlet_scores` object with one table row per requested Person,
omitted-row accounting, block sizes, settings, calibration and
prediction-source metadata for
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_results.md).
[`summary()`](https://rdrr.io/r/base/summary.html) reports all statuses;
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
when `draw = FALSE`. Saved scoring results need no live optimizer. Keep
`table$Status` and `table$Reason` with exported scores: `prior_only`
describes the assumed population without observed responses for that
Person; `unavailable` withholds the estimate, SD and bounds with a
recorded cause.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object;
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
retains all requested Persons, their statuses, interval endpoints and
settings.

## Details

All supplied rows for a Person are scored jointly. This does not append
to cached responses or condition on a stored local-effect mode. The
saved settings retain this integration, effect-sharing and roster
interpretation.
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_results.md)
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

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
conditional Person scores from a testlet model

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): In the
default interval view, empty rows remain labeled. Open circles mark
prior-only results; filled points are response-based conditional scores.
The intervals exclude calibration-estimation uncertainty and are not
tests of Person differences.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
preserves all labeled rows, prior-only symbols and the
conditional-interval note.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
retains statuses and reasons for custom graphics or table export;
conversion does not rerun scoring.

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
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
retains the complete source `table`, `display_data` with inclusion
reasons, `alt_text`, interpretation `notes`, and display settings.
Supply the text alternative and table alongside exported figures; image
files alone do not automatically expose that information to screen
readers.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
preserves the view and display controls, supplies `labs(alt = ...)`, and
allows further `labs()`, `theme()` and scale edits. Rendering does not
fit, score or resample. Use the same controls through
`plot(results, type = "scores", style = "precision")`.

## See also

[`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm_testlet.md),
`plot.mfrm_testlet_scores()`,
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_results.md)

[`plot.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm_testlet.md),
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data_components.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_output_guide.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
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
```
