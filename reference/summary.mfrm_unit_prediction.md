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
toy_fit <- fit_mfrm(
  toy[toy$Person %in% keep_people, , drop = FALSE],
  "Person", c("Rater", "Criterion"), "Score",
  method = "MML",
  quad_points = 5,
  maxit = 30
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
#>   Calibration estimated by MML; scoring uses posterior EAP. Prior: Standard
#>   normal N(0,1).
#>   95% intervals: continuous posterior quantiles.
#>   Posterior SDs and intervals condition on point estimates of the calibration
#>   and prior; their estimation uncertainty is excluded.
#> 
#> Fixed-parameter integration review (adaptive minus fixed)
#>  FixedNodes AdaptiveNodes Persons Unavailable MaxAbsLogMarginalChange
#>          31            31       1           0            1.360903e-10
#>          31            61       1           0            1.360911e-10
#>  MaxAbsEAPChange MaxAbsSDChange
#>     3.276639e-10   1.296825e-09
#>     3.276640e-10   1.296825e-09
#> 
#> Posterior estimates (first 10)
#>  Person Estimate    SD  Lower Upper Observations                       Review
#>   NEW01   -0.112 0.683 -1.448 1.235            2 Source scoring checks passed
#> 
#> Response rows
#>  InputRows KeptRows DroppedRows DroppedMissing DroppedBadScore DroppedBadWeight
#>          2        2           0              0               0                0
#>  DroppedNonpositiveWeight
#>                         0
#>   Non-person facets in `new_data` must already exist in the fitted calibration.
#>   Overlapping person IDs are treated as labels in `new_data`; the original
#>   fitted person estimates are not updated.
#>   Scoring integration compares the reported EAP and SD with adaptive reference
#>   orders under the same calibration and prior. Passing does not validate the
#>   scoring prior for another population.
```
