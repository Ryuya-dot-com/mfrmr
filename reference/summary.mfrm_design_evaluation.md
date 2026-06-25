# Summarize a design-simulation study

Summarize a design-simulation study

## Usage

``` r
# S3 method for class 'mfrm_design_evaluation'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md).

- digits:

  Number of digits used in the returned numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_design_evaluation` with components:

- `overview`: run-level overview

- `design_summary`: aggregated design-by-facet metrics, with
  design-variable alias columns when applicable

- `sparse_review`: compact planned-missingness and rater-link review
  counts when sparse linked designs are active

- `ademp`: simulation-study metadata carried forward from the original
  object

- `facet_names`: public facet labels carried from the simulation
  specification

- `design_variable_aliases`: accepted public aliases for design
  variables

- `design_descriptor`: role-based design-variable metadata

- `planning_scope`: explicit record of the current planning contract

- `planning_constraints`: explicit record of mutable/locked design
  variables

- `planning_schema`: combined planner-schema contract

- `future_branch_active_summary`: compact deterministic summary of the
  schema-only future arbitrary-facet planning branch embedded in the
  current planning schema

- `notes`: short interpretation notes

## Details

The summary emphasizes condition-level averages that are useful for
practical design planning, especially:

- convergence rate

- separation and reliability by facet

- severity recovery RMSE

- mean misfit rate

## See also

[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[plot.mfrm_design_evaluation](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_design_evaluation.md)

## Examples

``` r
if (FALSE) { # \dontrun{
sim_eval <- suppressWarnings(evaluate_mfrm_design(
  n_person = c(8, 12),
  n_rater = 2,
  n_criterion = 2,
  raters_per_person = 1,
  reps = 1,
  maxit = 30,
  seed = 123
))
s <- summary(sim_eval)
s$overview
head(s$design_summary)
} # }
```
