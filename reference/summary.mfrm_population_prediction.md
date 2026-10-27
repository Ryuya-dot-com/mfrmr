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

- `planning_schema`: structured planning metadata

- `gpcm_boundary`: `GPCM` caveat row when present

- `structural_design_review`: deterministic structural review of the
  named-facet design grid; it is not a forecast-uncertainty result

- `ademp`: simulation-study metadata

- `notes`: interpretation notes

## See also

[`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)

## Examples

``` r
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-population.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
pred <- saved$result
s <- summary(pred)
s$overview
#> # A tibble: 1 × 5
#>   Designs Replications SuccessfulRuns ConvergedRuns MeanElapsedSec
#>     <dbl>        <dbl>          <dbl>         <dbl>          <dbl>
#> 1       1            1              1             1          0.341
s$forecast[, c("Facet", "MeanSeparation", "McseSeparation")]
#> # A tibble: 3 × 3
#>   Facet     MeanSeparation McseSeparation
#>   <chr>              <dbl>          <dbl>
#> 1 Criterion           0                NA
#> 2 Person              1.25             NA
#> 3 Rater               0                NA
```
