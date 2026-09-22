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
pv <- sample_mfrm_plausible_values(toy_fit, new_units, n_draws = 3, seed = 1)
summary(pv)
#> mfrmr Plausible Values Summary
#>   Calibration estimated by MML; scoring uses posterior EAP. Prior: Standard
#>   normal N(0,1).
#>   95% intervals: continuous posterior quantiles.
#>   Posterior SDs and intervals condition on point estimates of the calibration
#>   and prior; their estimation uncertainty is excluded.
#> 
#> Empirical draw summaries (first 10)
#>  Person Draws MeanValue SDValue LowerValue UpperValue
#>   NEW01     3    -0.373   0.323      -0.56          0
#>   Draw limits are empirical quantiles at the requested level. With few draws
#>   they are coarse; use the companion posterior interval and its stated
#>   calculation method for interval reporting.
#> 
#> Posterior estimates (first 10)
#>  Person Estimate    SD  Lower Upper Observations                         Review
#>   NEW01   -0.112 0.683 -1.448 1.235            2 No source restriction recorded
#> 
#> Response rows
#>  InputRows KeptRows DroppedRows DroppedMissing DroppedBadScore DroppedBadWeight
#>          2        2           0              0               0                0
#>  DroppedNonpositiveWeight
#>                         0
#>   These draws are sampled from the quadrature-grid posterior under the existing
#>   MML calibration and its fixed or adaptive integration setting.
#>   Use them as approximate plausible-value summaries for posterior uncertainty,
#>   not as deterministic future truth values.
#>   Draws alone do not validate downstream group comparisons or regressions;
#>   check the conditioning model and sampling design for the intended analysis.
#>   Non-person facets in `new_data` must already exist in the fitted calibration.
#>   Overlapping person IDs are treated as labels in `new_data`; the original
#>   fitted person estimates are not updated.
#>   The `draws` component contains quadrature-grid posterior draws that can be
#>   used as approximate plausible-value summaries.
```
