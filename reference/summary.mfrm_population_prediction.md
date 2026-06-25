# Summarize a population-level design forecast

Summarize a population-level design forecast

## Usage

``` r
# S3 method for class 'mfrm_population_prediction'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md).

- digits:

  Number of digits used in numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_population_prediction` with:

- `design`: requested future design

- `overview`: run-level overview

- `forecast`: facet-level forecast table

- `facet_names`: public non-person facet names used in the forecast

- `design_variable_aliases`: public aliases for design variables

- `design_descriptor`: role-based description of design variables

- `planning_scope`: explicit record of the current planning contract

- `planning_constraints`: explicit record of mutable/locked design
  variables

- `planning_schema`: combined planner-schema contract

- `gpcm_boundary`: bounded-`GPCM` caveat row when present

- `future_branch_active_summary`: compact deterministic summary of the
  schema-only future arbitrary-facet planning branch embedded in the
  current planning schema

- `ademp`: simulation-study metadata

- `notes`: interpretation notes

## See also

[`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)

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
s <- summary(pred)
s$overview
s$forecast[, c("Facet", "MeanSeparation", "McseSeparation")]
} # }
```
