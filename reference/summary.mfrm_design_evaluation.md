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

- `planning_schema`: structured planning metadata

- `structural_design_review`: deterministic structural review of the
  named-facet design grid; it reports design bookkeeping rather than
  simulation performance

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
# \donttest{
sim_eval <- suppressWarnings(evaluate_mfrm_design(
  n_person = c(8, 12),
  n_rater = 2,
  n_criterion = 2,
  raters_per_person = 2,
  reps = 1,
  maxit = 30,
  seed = 123
))
s <- summary(sim_eval)
s$overview
#> # A tibble: 1 × 5
#>   Designs Replications SuccessfulRuns ConvergedRuns MeanElapsedSec
#>     <dbl>        <dbl>          <dbl>         <dbl>          <dbl>
#> 1       2            2              2             1          0.892
head(s$design_summary)
#> # A tibble: 6 × 44
#>   design_id Facet     n_person n_rater n_criterion raters_per_person  Reps
#>   <chr>     <chr>        <dbl>   <dbl>       <dbl>             <dbl> <dbl>
#> 1 D01       Criterion        8       2           2                 2     1
#> 2 D02       Criterion       12       2           2                 2     1
#> 3 D01       Person           8       2           2                 2     1
#> 4 D02       Person          12       2           2                 2     1
#> 5 D01       Rater            8       2           2                 2     1
#> 6 D02       Rater           12       2           2                 2     1
#> # ℹ 37 more variables: ConvergenceRate <dbl>, McseConvergenceRate <dbl>,
#> #   MeanSeparation <dbl>, SdSeparation <dbl>, McseSeparation <dbl>,
#> #   MeanReliability <dbl>, McseReliability <dbl>, MeanInfit <dbl>,
#> #   McseInfit <dbl>, MeanOutfit <dbl>, McseOutfit <dbl>, MeanMisfitRate <dbl>,
#> #   McseMisfitRate <dbl>, MeanSeverityRMSE <dbl>, McseSeverityRMSE <dbl>,
#> #   MeanSeverityBias <dbl>, McseSeverityBias <dbl>, MeanSeverityRMSERaw <dbl>,
#> #   McseSeverityRMSERaw <dbl>, MeanSeverityBiasRaw <dbl>, …
# }
```
