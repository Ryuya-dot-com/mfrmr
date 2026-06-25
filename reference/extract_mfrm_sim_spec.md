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
  group = NULL
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
the returned specification before using it for design planning.

First-release `GPCM` fits are now supported here for direct data
generation and parameter-recovery checks, provided that the returned
simulation specification stores both a threshold table and a parallel
slope table. The same fit-derived specification can feed caveated
role-based design evaluation, population forecasting, and fit-based
report/export bundles. Diagnostic/signal-detection design screening,
full FACETS score-side contract review, posterior predictive checks, and
heavy backend extensions remain outside the bounded-`GPCM` boundary
until those downstream contracts are widened explicitly.

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
if (FALSE) { # \dontrun{
toy <- simulate_mfrm_data(
  n_person = 8,
  n_rater = 3,
  n_criterion = 2,
  seed = 123
)
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
spec <- extract_mfrm_sim_spec(fit, latent_distribution = "empirical")
spec$assignment
spec$model
head(spec$threshold_table)
} # }
```
