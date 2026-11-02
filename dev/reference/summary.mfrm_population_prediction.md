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
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict_mfrm_population.md).

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

[`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict_mfrm_population.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("summary.mfrm_population_prediction", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-population.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
pred <- saved$result
s <- summary(pred)
s$overview
s$forecast[, c("Facet", "MeanSeparation", "McseSeparation")]
} # }
```
