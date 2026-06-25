# Forecast population-level MFRM operating characteristics for one future design

Forecast population-level MFRM operating characteristics for one future
design

## Usage

``` r
predict_mfrm_population(
  fit = NULL,
  sim_spec = NULL,
  n_person = NULL,
  n_rater = NULL,
  n_criterion = NULL,
  raters_per_person = NULL,
  design = NULL,
  reps = 50,
  fit_method = NULL,
  model = NULL,
  maxit = 25,
  quad_points = 7,
  residual_pca = c("none", "overall", "facet", "both"),
  seed = NULL
)
```

## Arguments

- fit:

  Optional output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  used to derive a fit-based simulation specification.

- sim_spec:

  Optional output from
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  or
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md).
  Supply exactly one of `fit` or `sim_spec`.

- n_person:

  Number of persons/respondents in the future design. Defaults to the
  value stored in the base simulation specification.

- n_rater:

  Number of rater facet levels in the future design. Defaults to the
  value stored in the base simulation specification.

- n_criterion:

  Number of criterion/item facet levels in the future design. Defaults
  to the value stored in the base simulation specification.

- raters_per_person:

  Number of raters assigned to each person in the future design.
  Defaults to the value stored in the base simulation specification.

- design:

  Optional named design override supplied as a named list, named vector,
  or one-row data frame. Names may use canonical variables (`n_person`,
  `n_rater`, `n_criterion`, `raters_per_person`), current public aliases
  (for example `n_judge`, `n_task`, `judge_per_person`), or role
  keywords (`person`, `rater`, `criterion`, `assignment`). The
  schema-only future branch input
  `design$facets = c(person = ..., judge = ..., task = ...)` is also
  accepted for the currently exposed facet keys. Do not specify the same
  variable through both `design` and the scalar count arguments.

- reps:

  Number of replications used in the forecast simulation.

- fit_method:

  Estimation method used inside the forecast simulation. When `fit` is
  supplied, defaults to that fit's estimation method; otherwise defaults
  to `"MML"`.

- model:

  Measurement model used when refitting the forecasted design. Defaults
  to the model recorded in the base simulation specification.

- maxit:

  Maximum iterations passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  in each replication.

- quad_points:

  Quadrature points for `fit_method = "MML"`.

- residual_pca:

  Residual PCA mode passed to
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- seed:

  Optional seed for reproducible replications.

## Value

An object of class `mfrm_population_prediction` with components:

- `design`: requested future design

- `forecast`: facet-level forecast table

- `overview`: run-level overview

- `simulation`: underlying
  [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  result

- `sim_spec`: simulation specification used for the forecast

- `facet_names`: public non-person facet names carried by the simulation
  specification

- `design_variable_aliases`: public aliases for
  `n_person`/`n_rater`/`n_criterion`/`raters_per_person`

- `design_descriptor`: role-based description of design variables
  carried from the underlying planning object

- `planning_scope`: explicit record of the current planning contract,
  including a `facet_manifest` and future-planner scaffold marker

- `planning_constraints`: explicit record of mutable/locked design
  variables

- `planning_schema`: combined planner-schema contract carrying the role
  table, current boundary, mutability map, facet manifest, and a
  schema-only future facet-count table

- `gpcm_boundary`: bounded-`GPCM` caveat row when a `GPCM` forecast
  route is used

- `settings`: forecasting settings

- `ademp`: simulation-study metadata

- `notes`: interpretation notes

## Details

`predict_mfrm_population()` is a **scenario-level forecasting helper**
built on top of
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md).
It is intended for questions such as:

- what separation/reliability would we expect if the next administration
  had 60 persons, 4 raters, and 2 ratings per person?

- how much Monte Carlo uncertainty remains around those expected
  summaries?

The function deliberately returns **aggregate operating
characteristics** (for example mean separation, reliability, recovery
RMSE, convergence rate) rather than future individual true values for
one respondent or one rater.

If `fit` is supplied, the function first constructs a fit-derived
parametric starting point with
[`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md)
and then evaluates the requested future design under that explicit
data-generating mechanism. This should be interpreted as a fit-based
forecast under modeling assumptions, not as a guaranteed out-of-sample
prediction.

When that fit-derived or manually built simulation specification stores
an active latent-regression population generator, the helper still
operates at the **design / operating-characteristic** level. It
repeatedly simulates person-level covariates and responses, refits the
MML population-model branch, and summarizes the resulting facet-level
behavior. This is distinct from the fitted-model posterior scoring
provided by
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).

Bounded `GPCM` forecasts are available with caveats through the same
repeated simulation/refit design route used by
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md).
They summarize design-level operating characteristics under the supplied
or fit-derived slope-aware specification; they do not validate
operational scoring, diagnostic-screening or signal-detection rules,
slope-recovery adequacy, or arbitrary-facet planning.

## Interpreting output

- `forecast` contains facet-level expected summaries for the requested
  future design.

- `Mcse*` columns quantify Monte Carlo uncertainty from using a finite
  number of replications.

- `design_variable_aliases` and `design_descriptor` carry the same
  public naming metadata used by the underlying planning object. They
  rename the standard two non-person facet roles for presentation, but
  they do not turn the current planner into a fully arbitrary-facet
  simulator.

- If `sim_spec$population$active = TRUE`, the forecast summarizes
  repeated latent-regression MML refits under that stored person-level
  generator; it is still a scenario forecast rather than direct
  posterior scoring for one observed sample.

- `simulation` stores the full design-evaluation object in case you want
  to inspect replicate-level behavior.

## What this does not justify

This helper does not produce definitive future person measures or rater
severities for one concrete sample. It forecasts design-level behavior
under the supplied or derived parametric assumptions.

## References

The forecast is implemented as a one-scenario Monte Carlo / operating-
characteristic study following the general guidance of Morris, White,
and Crowther (2019) and the ADEMP-oriented reporting framework discussed
by Siepe et al. (2024). In `mfrmr`, this function is a practical wrapper
for future-design planning rather than a direct implementation of a
published many-facet forecasting procedure.

- Morris, T. P., White, I. R., & Crowther, M. J. (2019). *Using
  simulation studies to evaluate statistical methods*. Statistics in
  Medicine, 38(11), 2074-2102.

- Siepe, B. S., Bartos, F., Morris, T. P., Boulesteix, A.-L., Heck, D.
  W., & Pawel, S. (2024). *Simulation studies for methodological
  research in psychology: A standardized template for planning,
  preregistration, and reporting*. Psychological Methods.

## See also

[`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md),
[`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md),
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[summary.mfrm_population_prediction](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_population_prediction.md)

## Examples

``` r
if (FALSE) { # \dontrun{
spec <- build_mfrm_sim_spec(
  n_person = 16,
  n_rater = 3,
  n_criterion = 2,
  raters_per_person = 2,
  assignment = "rotating"
)
pred <- predict_mfrm_population(
  sim_spec = spec,
  design = list(person = 18),
  reps = 1,
  maxit = 30,
  seed = 123
)
s_pred <- summary(pred)
s_pred$forecast[, c("Facet", "MeanSeparation", "McseSeparation")]
} # }
```
