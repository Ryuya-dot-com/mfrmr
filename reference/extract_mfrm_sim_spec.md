# Derive a simulation specification from a fitted MFRM object

Derive a simulation specification from a fitted MFRM object

## Usage

``` r
extract_mfrm_sim_spec(
  fit,
  assignment = c("auto", "crossed", "rotating", "resampled", "skeleton"),
  latent_distribution = c("normal", "empirical"),
  source_data = NULL,
  person = NULL,
  group = NULL,
  population_assignment = c("matched", "independent")
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- assignment:

  Assignment design to record in the returned specification. Use
  `"resampled"` to reuse empirical person-level rater-assignment
  profiles from the fitted data, or `"skeleton"` to reuse the observed
  person-by-facet design skeleton from the fitted data.

- latent_distribution:

  Latent-value generator to record in the returned specification.
  `"normal"` stores spread summaries for parametric draws; `"empirical"`
  additionally activates centered empirical resampling from the fitted
  person/rater/criterion estimates.

- source_data:

  Optional original source data used to recover additional
  non-calibration columns, currently person-level `group` labels, when
  building a fit-derived observed response skeleton.

- person:

  Optional person column name in `source_data`. Defaults to the person
  column recorded in `fit`.

- group:

  Optional group column name in `source_data` to merge into the returned
  `design_skeleton` as person-level metadata.

- population_assignment:

  How an active population model is associated with `"resampled"` or
  `"skeleton"` assignments. The default `"matched"` draws one template
  Person jointly for covariates and assignments. Both tables must cover
  the same `TemplatePerson` IDs, with matching `Group` labels if present
  in both. `"independent"` samples covariate rows separately and
  intentionally breaks these associations. In that case both tables
  cannot define `Group`; rename a covariate if it represents a different
  grouping. For other assignment designs this setting has no effect.
  Population-template `Group`, when present, supplies the response
  group; `group_levels` must include all template labels and does not
  rebalance them.

## Value

An object of class `mfrm_sim_spec`.

## Details

`extract_mfrm_sim_spec()` uses a fitted model as a practical starting
point for later simulation studies. It extracts:

- design counts from the fitted data

- empirical spread of person and facet estimates

- optional empirical support values for semi-parametric draws

- fitted threshold values

- either a simplified assignment summary (`"crossed"` / `"rotating"`),
  empirical resampled assignment profiles (`"resampled"`), or an
  observed response skeleton (`"skeleton"`, optionally carrying
  `Group`/`Weight`)

- when the fit used the latent-regression branch, the fitted
  `population_formula`, coefficient vector, residual variance, and the
  stored person-level covariate table, including model-matrix xlevel and
  contrast provenance for categorical covariates

This is intended as a **fit-derived parametric starting point**, not as
a claim that the fitted object perfectly recovers the true
data-generating mechanism. Users should review and, if necessary, edit
the returned specification before using it for design planning. Observed
skeleton rows retain repeated rating occasions. Remove accidental
duplicate source rows before fitting; the generator cannot distinguish
them from intentional repeated ratings. Covariates and assignment
templates are linked by `TemplatePerson` under
`population_assignment = "matched"`.

Without an active population regression, `theta_sd` is the empirical SD
of the reported Person estimates, including any shrinkage in those
estimates. It is not an estimate of the latent population SD corrected
for measurement error. The empirical option resamples centered estimates
independently of their original IDs; it is not a draw from the source
posterior. With an active population model, its coefficients, residual
variance and fitted transformation basis replace this Person-spread
approximation. Neither route propagates uncertainty in the source fit's
generating parameters.

`GPCM` fits with the same slope and step owner are supported here for
direct data generation and parameter-recovery checks, provided that the
returned simulation specification stores both a threshold table and a
parallel slope table. The same fit-derived specification can feed
caveated role-based design evaluation, population forecasting, and
fit-based report/export bundles. Diagnostic and signal-detection design
screening is available with explicit caveats. Full FACETS score-side
contract review, posterior predictive checks, and MCMC estimation are
not available for `GPCM`.

If you want to carry person-level group labels into a fit-derived
observed response skeleton, provide the original `source_data` together
with `person` and `group`. Group labels are treated as person-level
metadata and are checked for one-label-per-person consistency before
being merged.

## Interpreting output

The returned object is a simulation specification, not a prediction
about one future sample. It captures one convenient approximation to the
observed design and estimated spread in the fitted run.

## See also

[`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md),
[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)

## Examples

``` r
toy <- simulate_mfrm_data(
  n_person = 8,
  n_rater = 3,
  n_criterion = 2,
  seed = 123
)
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Category support is retained but requires review: at least one fitted or local scope contains an empty or singleton category/transition cell. The fit may be inspected, but category-information strength has not been certified; inspect `fit$data_review$category_support` before inference.
spec <- extract_mfrm_sim_spec(fit, latent_distribution = "empirical")
spec$assignment
#> [1] "crossed"
spec$model
#> [1] "RSM"
head(spec$threshold_table)
#> # A tibble: 3 × 4
#>   StepFacet StepIndex Step   Estimate
#>   <chr>         <int> <chr>     <dbl>
#> 1 Common            1 Step_1   -2.79 
#> 2 Common            2 Step_2   -0.583
#> 3 Common            3 Step_3    3.37 
```
