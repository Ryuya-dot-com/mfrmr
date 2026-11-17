# Score future or partially observed units under the fitted scoring basis

Compute conditional posterior EAP ability estimates, posterior `SD`s,
continuous equal-tail CDF intervals (`Lower`/`Upper`), optional
discrete-grid posterior draws, and optional cut-score probabilities for
`new_data` holding a fitted
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
calibration fixed.

## Usage

``` r
predict_mfrm_units(
  fit,
  new_data,
  person = NULL,
  facets = NULL,
  score = NULL,
  weight = NULL,
  person_data = NULL,
  person_id = NULL,
  population_policy = c("error", "omit"),
  interval_level = 0.95,
  scoring_quad_points = 31L,
  readiness_policy = c("error", "review"),
  n_draws = 0,
  seed = NULL,
  adaptive_quad_points = NULL,
  scoring_prior = NULL,
  cut_scores = NULL
)

# S3 method for class 'mfrm_unit_prediction'
summary(object, digits = 3, ...)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  (`method = "MML"` or `"JML"`).

- new_data:

  Long-format response `data.frame` for known non-Person facet levels
  and optional column-name mappings (defaulting to `fit`).

- person:

  Long-format response `data.frame` for known non-Person facet levels
  and optional column-name mappings (defaulting to `fit`).

- facets:

  Long-format response `data.frame` for known non-Person facet levels
  and optional column-name mappings (defaulting to `fit`).

- score:

  Long-format response `data.frame` for known non-Person facet levels
  and optional column-name mappings (defaulting to `fit`).

- weight:

  Long-format response `data.frame` for known non-Person facet levels
  and optional column-name mappings (defaulting to `fit`).

- person_data:

  Background covariate `data.frame`, ID column, and missing-covariate
  policy (`"error"` or `"omit"`) for latent-regression MML fits (`~ 1`
  reconstructs IDs automatically; fitted `xlevels`, `contrasts`, and
  spline/scale bases are reused).

- person_id:

  Background covariate `data.frame`, ID column, and missing-covariate
  policy (`"error"` or `"omit"`) for latent-regression MML fits (`~ 1`
  reconstructs IDs automatically; fitted `xlevels`, `contrasts`, and
  spline/scale bases are reused).

- population_policy:

  Background covariate `data.frame`, ID column, and missing-covariate
  policy (`"error"` or `"omit"`) for latent-regression MML fits (`~ 1`
  reconstructs IDs automatically; fitted `xlevels`, `contrasts`, and
  spline/scale bases are reused).

- interval_level:

  Posterior interval level (`0.95` default) and Gauss-Hermite node count
  (`31` default, `>= 2`; inherits fixed vs adaptive mode from `fit`).

- scoring_quad_points:

  Posterior interval level (`0.95` default) and Gauss-Hermite node count
  (`31` default, `>= 2`; inherits fixed vs adaptive mode from `fit`).

- readiness_policy:

  `"error"` (default) refuses non-scoring-ready source fits; `"review"`
  labels review-only conditional scores when parameters are finite and
  valid.

- n_draws:

  Discrete-grid posterior draw count (`0` skips draws) and optional RNG
  seed.

- seed:

  Discrete-grid posterior draw count (`0` skips draws) and optional RNG
  seed.

- adaptive_quad_points:

  Optional integer vector (`>= 2` orders `>= 3`) adding
  `quadrature_review` comparisons across fixed and adaptive grids.

- scoring_prior:

  Optional `list(mean = ..., sd = ...)` overriding the shared normal
  scoring prior (`NULL` retains the MML population prior, or `N(0, 1)`
  post-hoc reference prior for JML).

- cut_scores:

  Optional strictly increasing named/unnamed ability cuts for
  unit-weight ordinary RSM/PCM, returning continuous `above_cut`
  (\\P(\theta \> c \mid y, \widehat\psi)\\) and mutually exclusive
  `ability_band` (`Lower < ability <= Upper`) probabilities in
  `decisions`.

- object:

  Output from `predict_mfrm_units()`.

- digits:

  Number of digits used in numeric summaries. Decision probabilities,
  cut boundaries and scoring priors are not rounded.

- ...:

  Reserved for generic compatibility.

## Value

An `mfrm_unit_prediction` list with `estimates`, `decisions`, `draws`,
`fit_identity`, `row_review`, `population_review`, `quadrature_review`,
`quadrature_overview`, `input_data`, `person_data`, `settings`, and
`notes`.

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_unit_prediction` with:

- `estimates`: posterior summaries by person

- `decisions`: unrounded conditional probabilities, when requested

- `row_review`: row-preparation review

- `population_review`: optional person-level omission review for
  latent-regression scoring

- `settings`: scoring settings

- `notes`: interpretation notes

## Details

**Source and score-integration checks.** One- and two-family MML,
shared-owner GPCM JML, and corrected JML routes verify local calibration
stationarity / curvature (`settings$local_calibration_review`,
`SourceScoringReady`) and check reported EAP/SD stability (`<= 1e-5`)
against adaptive reference orders (`settings$score_integration_review`,
`ScoreIntegrationReady`, `EstimateUse`). All intervals and cut
probabilities condition on point calibration and the active prior
(`PriorSource`, `PriorMean`, `PriorSD`), excluding calibration
estimation uncertainty.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize
posterior unit scoring output

## References

- Bock, R. D., & Mislevy, R. J. (1982). *Appl. Psychol. Meas.*, 6(4),
  431–444.
  [doi:10.1177/014662168200600405](https://doi.org/10.1177/014662168200600405)
  .

- Mislevy, R. J. (1991). *Psychometrika*, 56(2), 177–196.

## See also

[`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md),
[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md),
[`classification_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/classification_table.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)

`predict_mfrm_units()` for an executable scoring and reporting example;
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
keep_people <- unique(toy$Person)[1:18]
toy_fit <- fit_mfrm(
  toy[toy$Person %in% keep_people, , drop = FALSE],
  "Person", c("Rater", "Criterion"), "Score",
  method = "MML",
  quad_points = 61
)
raters <- unique(toy$Rater)[1:2]
criteria <- unique(toy$Criterion)[1:2]
new_units <- data.frame(
  Person = c("NEW01", "NEW01", "NEW02", "NEW02"),
  Rater = c(raters[1], raters[2], raters[1], raters[2]),
  Criterion = c(criteria[1], criteria[2], criteria[1], criteria[2]),
  Score = c(2, 3, 2, 4)
)
# Illustrative boundaries only: these labels do not establish CEFR levels.
cuts <- c(Basic = -0.5, Advanced = 0.8)
pred_units <- predict_mfrm_units(toy_fit, new_units,
  scoring_quad_points = 121, cut_scores = cuts)
summary(pred_units)$estimates[, c("Person", "Estimate", "Lower", "Upper")]
#> # A tibble: 2 × 4
#>   Person Estimate Lower Upper
#>   <chr>     <dbl> <dbl> <dbl>
#> 1 NEW01    -0.162 -1.48  1.17
#> 2 NEW02     0.3   -1.02  1.67
pred_units$decisions
#>    Person         Type    Label Lower Upper Probability PriorMean PriorSD
#> 1   NEW01    above_cut    Basic  -0.5   Inf  0.69210796         0       1
#> 2   NEW01    above_cut Advanced   0.8   Inf  0.07706642         0       1
#> 3   NEW01 ability_band    Band1  -Inf  -0.5  0.30789204         0       1
#> 4   NEW01 ability_band    Band2  -0.5   0.8  0.61504154         0       1
#> 5   NEW01 ability_band    Band3   0.8   Inf  0.07706642         0       1
#> 6   NEW02    above_cut    Basic  -0.5   Inf  0.88022925         0       1
#> 7   NEW02    above_cut Advanced   0.8   Inf  0.22964641         0       1
#> 8   NEW02 ability_band    Band1  -Inf  -0.5  0.11977075         0       1
#> 9   NEW02 ability_band    Band2  -0.5   0.8  0.65058285         0       1
#> 10  NEW02 ability_band    Band3   0.8   Inf  0.22964641         0       1
#>                   Status Reason                                Uncertainty
#> 1  available_conditional        conditional_on_point_calibration_and_prior
#> 2  available_conditional        conditional_on_point_calibration_and_prior
#> 3  available_conditional        conditional_on_point_calibration_and_prior
#> 4  available_conditional        conditional_on_point_calibration_and_prior
#> 5  available_conditional        conditional_on_point_calibration_and_prior
#> 6  available_conditional        conditional_on_point_calibration_and_prior
#> 7  available_conditional        conditional_on_point_calibration_and_prior
#> 8  available_conditional        conditional_on_point_calibration_and_prior
#> 9  available_conditional        conditional_on_point_calibration_and_prior
#> 10 available_conditional        conditional_on_point_calibration_and_prior

# Optional prior-sensitivity comparison performs another scoring calculation.
# example("predict_mfrm_units", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
apa_table(pred_units, which = "decisions")
# Compare assumptions on the same response rows, without refitting.
alternative <- predict_mfrm_units(
  toy_fit, new_units, scoring_prior = list(mean = 0.5, sd = 1.5),
  scoring_quad_points = 121, cut_scores = cuts
)
comparison <- dplyr::bind_rows(
  "Retained prior" = pred_units$estimates,
  "Alternative prior" = alternative$estimates, .id = "Scenario"
)
if (requireNamespace("ggplot2", quietly = TRUE)) {
  ggplot2::ggplot(comparison, ggplot2::aes(Scenario, Estimate)) +
  ggplot2::geom_pointrange(ggplot2::aes(ymin = Lower, ymax = Upper)) +
  ggplot2::facet_wrap(~ Person) + ggplot2::theme_minimal() +
  ggplot2::labs(x = NULL, y = "Posterior EAP",
    caption = "95% posterior intervals conditional on calibration and each prior")
}
# Retain the complete result; summaries and tables do not score again.
saved <- tempfile(fileext = ".rds")
saveRDS(pred_units, saved)
apa_table(readRDS(saved), which = "decisions")
unlink(saved)
} # }
```
