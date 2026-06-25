# Recommend a design condition from simulation results

Recommend a design condition from simulation results

## Usage

``` r
recommend_mfrm_design(
  x,
  facets = c("Rater", "Criterion"),
  min_separation = 2,
  min_reliability = 0.8,
  max_severity_rmse = 0.5,
  max_misfit_rate = 0.1,
  min_convergence_rate = 1,
  prefer = c("n_person", "raters_per_person", "n_rater", "n_criterion")
)
```

## Arguments

- x:

  Output from
  [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  or
  [`summary.mfrm_design_evaluation()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_design_evaluation.md).

- facets:

  Facets that must satisfy the planning thresholds.

- min_separation:

  Minimum acceptable mean separation.

- min_reliability:

  Minimum acceptable mean reliability.

- max_severity_rmse:

  Maximum acceptable severity recovery RMSE.

- max_misfit_rate:

  Maximum acceptable mean misfit rate.

- min_convergence_rate:

  Minimum acceptable convergence rate.

- prefer:

  Ranking priority among design variables. Earlier entries are optimized
  first when multiple designs pass. Custom public aliases from
  `sim_spec` are also accepted, as are the role keywords `person`,
  `rater`, `criterion`, and `assignment`.

## Value

A list of class `mfrm_design_recommendation` with:

- `facet_table`: facet-level threshold checks, including design-variable
  alias columns when applicable

- `design_table`: design-level aggregated checks, including
  design-variable alias columns when applicable

- `recommended`: the first passing design after ranking

- `thresholds`: thresholds used in the recommendation

- `design_variable_aliases`: accepted public aliases for design
  variables

- `design_descriptor`: role-based design-variable metadata

- `planning_scope`: explicit record of the current planning contract

- `planning_constraints`: explicit record of mutable/locked design
  variables

- `planning_schema`: combined planner-schema contract

- `caveats`: structured warning rows for situations where the
  recommendation rests on weak evidence (e.g., no design met every
  threshold; the recommended design is at the boundary of the evaluated
  grid; only one rep was simulated). Empty `tibble()` when no caveats
  apply.

## Details

This helper converts a design-study summary into a simple planning
table.

A design is marked as recommended when all requested facets satisfy all
selected thresholds simultaneously. If multiple designs pass, the helper
returns the smallest one according to `prefer` (by default: fewer
persons first, then fewer ratings per person, then fewer raters, then
fewer criteria).

## Typical workflow

1.  Run
    [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md).

2.  Review
    [`summary.mfrm_design_evaluation()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_design_evaluation.md)
    and
    [`plot.mfrm_design_evaluation()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_design_evaluation.md).

3.  Use `recommend_mfrm_design(...)` to identify the smallest acceptable
    design.

## See also

[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[summary.mfrm_design_evaluation](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_design_evaluation.md),
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
rec <- recommend_mfrm_design(sim_eval)
rec$recommended
} # }
```
