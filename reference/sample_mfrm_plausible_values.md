# Sample approximate plausible values under fitted posterior scoring

Sample approximate plausible values under fitted posterior scoring

## Usage

``` r
sample_mfrm_plausible_values(
  fit,
  new_data,
  person = NULL,
  facets = NULL,
  score = NULL,
  weight = NULL,
  person_data = NULL,
  person_id = NULL,
  population_policy = c("error", "omit"),
  n_draws = 5,
  interval_level = 0.95,
  seed = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  estimated with `method = "MML"` or `method = "JML"`.

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
  fixed-calibration scoring. Intercept-only latent-regression fits can
  reconstruct the minimal scored-person table internally. This is the
  scoring-time table for `new_data`, not the fit object's replay/export
  provenance table. For categorical background variables, supply values
  on the same coding scale used at fit time; the fitted factor levels
  and contrasts are reused when building the scoring design matrix.

- person_id:

  Optional person-ID column in `person_data`.

- population_policy:

  How missing background data are handled when `fit` uses the
  latent-regression branch. `"error"` (default) requires complete
  person-level covariates; `"omit"` drops scored persons lacking
  complete covariates and records that omission in `population_review`.

- n_draws:

  Number of posterior draws per person. Must be a positive integer.

- interval_level:

  Posterior interval level passed to
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  for the accompanying EAP summary table.

- seed:

  Optional seed for reproducible posterior draws.

## Value

An object of class `mfrm_plausible_values` with components:

- `values`: one row per person per draw

- `estimates`: companion posterior EAP summaries

- `row_review`: row-preparation review

- `population_review`: optional person-level omission review for
  latent-regression scoring

- `input_data`: cleaned canonical scoring rows retained from `new_data`

- `person_data`: cleaned or supplied person-level background data used
  for latent-regression scoring; `NULL` otherwise

- `settings`: scoring settings

- `notes`: interpretation notes

## Details

`sample_mfrm_plausible_values()` is a thin public wrapper around
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
that exposes the fixed-calibration posterior draws as a standalone
object. It is useful when downstream workflows want repeated
latent-value imputations rather than just one posterior EAP summary.

In the current `mfrmr` implementation these are **approximate plausible
values** drawn from the fitted quadrature-grid posterior under the
scoring basis implied by `fit`. For ordinary `MML` fits this is the
fitted marginal calibration; for latent-regression `MML` fits it is the
fitted conditional normal population model for the scored persons; for
`JML` fits it is the fixed facet/step calibration together with a
standard normal reference prior on the quadrature grid. They should be
interpreted as posterior uncertainty summaries for the scored persons,
not as deterministic future truth values and not as a claim of full
many-facet plausible-values equivalence with population-model software.

In other words, the `JML` path here is a practical scoring approximation
layered on top of the fitted joint-likelihood calibration, whereas the
latent-regression `MML` path uses the fitted one-dimensional conditional
normal population model. Neither path should be described as a full
many-facet plausible-values system with all ConQuest-style extensions.

## Interpreting output

- `values` contains one row per person per draw.

- `estimates` contains the companion posterior EAP summaries from
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).

- [`summary()`](https://rdrr.io/r/base/summary.html) reports draw counts
  and empirical draw summaries by person.

## What this does not justify

This helper does not update the calibration, estimate new non-person
facet levels, or provide exact future true values. It samples from the
fixed-grid posterior implied by the existing fixed calibration.

## References

The underlying posterior scoring follows the usual quadrature-based EAP
framework of Bock and Aitkin (1981). The interpretation of multiple
posterior draws as plausible-value-style summaries follows the general
logic discussed by Mislevy (1991), while the current implementation
remains a practical fixed-calibration approximation rather than a full
published many-facet plausible-values method. For `JML` source fits, the
quadrature posterior uses a package-level standard normal reference
prior for this post hoc scoring layer.

- Bock, R. D., & Aitkin, M. (1981). *Marginal maximum likelihood
  estimation of item parameters: Application of an EM algorithm*.
  Psychometrika, 46(4), 443-459.

- Mislevy, R. J. (1991). *Randomization-based inference about latent
  variables from complex samples*. Psychometrika, 56(2), 177-196.

## See also

[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
[summary.mfrm_plausible_values](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_plausible_values.md)

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
new_units <- data.frame(
  Person = c("NEW01", "NEW01"),
  Rater = unique(toy$Rater)[1],
  Criterion = unique(toy$Criterion)[1:2],
  Score = c(2, 3)
)
pv <- sample_mfrm_plausible_values(toy_fit, new_units, n_draws = 3, seed = 1)
summary(pv)$draw_summary
#> # A tibble: 1 × 6
#>   Person Draws MeanValue SDValue LowerValue UpperValue
#>   <chr>  <dbl>     <dbl>   <dbl>      <dbl>      <dbl>
#> 1 NEW01      3         0       0          0          0
```
