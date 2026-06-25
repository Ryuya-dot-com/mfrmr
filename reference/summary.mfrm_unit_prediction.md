# Summarize posterior unit scoring output

Summarize posterior unit scoring output

## Usage

``` r
# S3 method for class 'mfrm_unit_prediction'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).

- digits:

  Number of digits used in numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_unit_prediction` with:

- `estimates`: posterior summaries by person

- `row_review`: row-preparation review

- `population_review`: optional person-level omission review for
  latent-regression scoring

- `settings`: scoring settings

- `notes`: interpretation notes

## See also

[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)

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
pred_units <- predict_mfrm_units(toy_fit, new_units)
summary(pred_units)
#> mfrmr Unit Prediction Summary
#> 
#> Posterior estimates
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
#>             n_draws          0
#>         quad_points          5
#>                seed       NULL
#>              method        MML
#>      source_columns   <list 4>
#>     posterior_basis legacy_mml
#>           person_id       NULL
#>   population_policy       NULL
#>  population_formula       NULL
#> 
#> Notes
#>  - Posterior summaries are computed under the fixed fitted MML calibration.
#>  - Non-person facets in `new_data` must already exist in the fitted calibration.
#>  - Overlapping person IDs are treated as labels in `new_data`; the original fitted person estimates are not updated.
```
