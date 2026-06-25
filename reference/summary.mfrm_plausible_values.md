# Summarize approximate plausible values from posterior scoring

Summarize approximate plausible values from posterior scoring

## Usage

``` r
# S3 method for class 'mfrm_plausible_values'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md).

- digits:

  Number of digits used in numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_plausible_values` with:

- `draw_summary`: empirical summaries of the sampled values by person

- `estimates`: companion posterior EAP summaries

- `row_review`: row-preparation review

- `population_review`: optional person-level omission review for
  latent-regression scoring

- `settings`: scoring settings

- `notes`: interpretation notes

## See also

[`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)

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
summary(pv)
#> mfrmr Plausible Values Summary
#> 
#> Draw summary
#>  Person Draws MeanValue SDValue LowerValue UpperValue
#>   NEW01     3         0       0          0          0
#> 
#> Companion estimates
#>  Person Estimate    SD  Lower Upper Observations WeightedN
#>   NEW01   -0.097 0.648 -1.356 1.356            2         2
#> 
#> Row preparation review
#>  InputRows KeptRows DroppedRows DroppedMissing DroppedBadScore DroppedBadWeight
#>          2        2           0              0               0                0
#>  DroppedNonpositiveWeight
#>                         0
#> 
#> Settings
#>             Setting      Value
#>      interval_level       0.95
#>             n_draws          3
#>         quad_points          5
#>                seed          1
#>              method        MML
#>      source_columns   <list 4>
#>     posterior_basis legacy_mml
#>           person_id       NULL
#>   population_policy       NULL
#>  population_formula       NULL
#> 
#> Notes
#>  - These draws are sampled from the fixed quadrature-grid posterior under the existing MML calibration.
#>  - Use them as approximate plausible-value summaries for posterior uncertainty, not as deterministic future truth values.
```
