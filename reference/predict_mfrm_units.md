# Score future or partially observed units under the fitted scoring basis

Score future or partially observed units under the fitted scoring basis

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
  n_draws = 0,
  seed = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  estimated with `method = "MML"` or `method = "JML"`. When `fit` uses
  the latent-regression MML branch
  (`posterior_basis = "population_model"`), score the target persons
  with the same background-variable contract via `person_data`.

- new_data:

  Long-format data for the future or partially observed units to be
  scored.

- person:

  Optional person column in `new_data`. Defaults to the person column
  recorded in `fit`.

- facets:

  Optional facet-column mapping for `new_data`. Supply either an unnamed
  character vector in the calibrated facet order or a named vector whose
  names are the calibrated facet names and whose values are the column
  names in `new_data`.

- score:

  Optional score column in `new_data`. Defaults to the score column
  recorded in `fit`.

- weight:

  Optional weight column in `new_data`. Defaults to the weight column
  recorded in `fit`, if any.

- person_data:

  Optional one-row-per-person data.frame with the background variables
  required by a latent-regression fit. Ignored for ordinary
  fixed-calibration scoring. For intercept-only latent-regression fits
  (`population_formula = ~ 1`), `mfrmr` reconstructs the minimal
  one-row-per-person table internally from the scored person IDs. This
  is the scoring-time table for `new_data`, not the fit object's
  replay/export provenance table. For categorical background variables,
  supply values on the same coding scale used at fit time; the fitted
  factor levels and contrasts are reused when building the scoring
  design matrix.

- person_id:

  Optional person-ID column in `person_data`. Defaults to `person` when
  that column exists, otherwise `"Person"` for the canonical scoring
  layout.

- population_policy:

  How missing background data are handled when `fit` uses the
  latent-regression branch. `"error"` (default) requires complete
  person-level covariates for all scored persons; `"omit"` drops scored
  persons lacking complete covariates and records that omission in
  `population_review`.

- interval_level:

  Posterior interval level returned in `Lower`/`Upper`.

- n_draws:

  Optional number of quadrature-grid posterior draws to return per
  scored person. Use 0 to skip draws.

- seed:

  Optional seed for reproducible posterior draws.

## Value

An object of class `mfrm_unit_prediction` with components:

- `estimates`: posterior summaries by person

- `draws`: optional quadrature-grid posterior draws

- `row_review`: row-level preparation review for `new_data`

- `population_review`: optional person-level omission review for
  latent-regression scoring

- `input_data`: cleaned canonical scoring rows retained from `new_data`

- `person_data`: cleaned or supplied person-level background data used
  for latent-regression scoring; `NULL` otherwise

- `settings`: scoring settings

- `notes`: interpretation notes

## Details

`predict_mfrm_units()` is the **individual-unit companion** to
[`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md).
It uses the fitted calibration and, when available, the fitted
one-dimensional population model to score new or partially observed
persons via Expected A Posteriori (EAP) summaries on a quadrature grid.

When the original fit uses ordinary `method = "MML"`, the posterior
summaries are taken under that fitted MML calibration. When the original
fit uses the latent-regression MML branch, the scoring prior is the
fitted conditional normal population model \\\theta \mid x \sim
N(x^\top\hat\beta, \hat\sigma^2)\\, so the returned summaries are
population-model-aware posterior EAP estimates. When the original fit
uses `method = "JML"`, `mfrmr` applies the fitted facet/step parameters
with a standard normal reference prior on the quadrature grid, so the
returned person scores remain fixed-calibration EAP summaries rather
than direct JML estimates from the fitting step.

When the fitted population model is intercept-only
(`population_formula = ~ 1`), `predict_mfrm_units()` still uses the
fitted population-model basis, but it can reconstruct the minimal
scored-person table internally because no background covariates are
needed beyond the person IDs in `new_data`.

The current bounded `GPCM` branch is included in this scoring layer, so
fitted `GPCM` objects can be used for the same fixed-calibration
posterior summaries. This does not imply that every downstream
diagnostic or reporting helper has already been generalized to `GPCM`.

This is appropriate for questions such as:

- what posterior location/uncertainty do these partially observed new
  respondents have under the existing calibration?

- how uncertain are those scores, given the observed response pattern?

All non-person facet levels in `new_data` must already exist in the
fitted calibration. The function does **not** recalibrate the model,
update facet estimates, or treat overlapping person IDs as the same
latent units from the training data. Person IDs in `new_data` are
treated as labels for the rows being scored.

When `n_draws > 0`, the returned `draws` component contains discrete
quadrature-grid posterior draws that can be used as approximate
plausible values under the fitted scoring basis. They should be
interpreted as posterior uncertainty summaries, not as deterministic
future truth values.

For `JML` fits, this scoring stage is intentionally post hoc: `mfrmr`
uses the fitted facet and step parameters from the joint-likelihood fit,
then adds a standard normal reference prior only for the scoring layer
so that new or partially observed units can be summarized on a
quadrature grid. This is a practical fixed-calibration EAP procedure,
not a claim that the original `JML` fit itself estimated a population
model.

## Interpreting output

- `estimates` contains posterior EAP summaries for each person in
  `new_data`.

- `Lower` and `Upper` are quadrature-grid posterior interval bounds at
  the requested `interval_level`.

- `SD` is posterior uncertainty under the fitted scoring basis used for
  scoring.

- `draws`, when requested, contains approximate plausible values on the
  fitted quadrature grid.

- `population_review`, when present, records whether scored persons were
  omitted because their background data were incomplete for a
  latent-regression fit.

## What this does not justify

This helper does not update the original calibration, estimate new
non-person facet levels, or produce deterministic future person true
values. It scores new response patterns under the fitted calibration
and, when applicable, the fitted one-dimensional population model.

## References

The posterior summaries follow the usual quadrature-based EAP scoring
framework used in item response modeling under calibrated parameters
(for example Bock & Aitkin, 1981). When `fit` uses the latent-regression
branch, `mfrmr` scores under the fitted conditional normal population
model in the general plausible-values spirit discussed by Mislevy
(1991). Optional posterior draws are exposed as quadrature-grid
plausible-value-style summaries for practical many-facet scoring rather
than as a claim of full ConQuest numerical equivalence. When the source
fit is `JML`, the same literature supports the quadrature-based scoring
layer, but the standard normal prior is a package-level reference prior
introduced for post hoc scoring rather than an estimated population
distribution.

- Bock, R. D., & Aitkin, M. (1981). *Marginal maximum likelihood
  estimation of item parameters: Application of an EM algorithm*.
  Psychometrika, 46(4), 443-459.

- Mislevy, R. J. (1991). *Randomization-based inference about latent
  variables from complex samples*. Psychometrika, 56(2), 177-196.

- Muraki, E. (1992). *A generalized partial credit model: Application of
  an EM algorithm*. Applied Psychological Measurement, 16(2), 159-176.

## See also

[`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[summary.mfrm_unit_prediction](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_unit_prediction.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
keep_people <- unique(toy$Person)[1:18]
toy_fit <- suppressWarnings(
  fit_mfrm(
    toy[toy$Person %in% keep_people, , drop = FALSE],
    "Person", c("Rater", "Criterion"), "Score",
    method = "MML",
    quad_points = 5,
    maxit = 30
  )
)
raters <- unique(toy$Rater)[1:2]
criteria <- unique(toy$Criterion)[1:2]
new_units <- data.frame(
  Person = c("NEW01", "NEW01", "NEW02", "NEW02"),
  Rater = c(raters[1], raters[2], raters[1], raters[2]),
  Criterion = c(criteria[1], criteria[2], criteria[1], criteria[2]),
  Score = c(2, 3, 2, 4)
)
pred_units <- predict_mfrm_units(toy_fit, new_units, n_draws = 0)
summary(pred_units)$estimates[, c("Person", "Estimate", "Lower", "Upper")]
#> # A tibble: 2 × 4
#>   Person Estimate Lower Upper
#>   <chr>     <dbl> <dbl> <dbl>
#> 1 NEW01    -0.149 -1.36  1.36
#> 2 NEW02     0.279 -1.36  1.36
```
