# Build a weighting-policy review between Rasch-family and bounded GPCM fits

Build a weighting-policy review between Rasch-family and bounded GPCM
fits

## Usage

``` r
build_weighting_review(
  rasch_fit,
  gpcm_fit,
  theta_range = c(-6, 6),
  theta_points = 101L,
  top_n = 10L
)
```

## Arguments

- rasch_fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  using `model = "RSM"` or `"PCM"`.

- gpcm_fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  using bounded `model = "GPCM"`.

- theta_range:

  Numeric vector of length 2 passed to
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  for the information-redistribution comparison.

- theta_points:

  Integer number of theta grid points passed to
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md).

- top_n:

  Maximum number of rows to keep in compact summary outputs.

## Value

An object of class `mfrm_weighting_review`.

## Details

`build_weighting_review()` is an operational model-choice review helper.
It is designed for the common question:

- what changes when a Rasch-family equal-weighting model is replaced
  with a bounded `GPCM` that allows discrimination-based reweighting?

The helper does not estimate a new model. Instead, it synthesizes four
package-native evidence sources:

- [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  for same-data model comparison

- the non-person facet measures from each fit

- the bounded `GPCM` slope table

- [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  for design-weighted information redistribution

The result is intended for substantive review, not for automatic model
selection. In particular, a better-fitting `GPCM` should not by itself
be interpreted as a reason to discard an equal-weighting Rasch-family
route.

## Recommended input route

1.  Fit an equal-weighting reference model with `model = "RSM"` or
    `"PCM"`.

2.  Fit a bounded `GPCM` on the same prepared response data.

3.  Run `build_weighting_review(rasch_fit, gpcm_fit)`.

4.  Read `summary(review)` before deciding whether the
    discrimination-based reweighting is substantively acceptable.

## What the returned tables mean

- `model_comparison`: same-data model-comparison bundle from
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).

- `facet_shift`: how non-person facet estimates move under bounded
  `GPCM`.

- `slope_profile`: which `slope_facet` levels are upweighted or
  downweighted.

- `information_redistribution`: within-facet information-share changes
  between the Rasch-family fit and bounded `GPCM`.

- `top_reweighted_levels`: compact triage table for the strongest
  slope-facet-level redistribution signals.

## GPCM boundary

This helper is available only for the current bounded `GPCM` branch. It
requires the package's existing `slope_facet == step_facet` contract and
should be read as an operational weighting-policy review, not as a
formal validity adjudication.

## See also

[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
rasch_fit <- fit_mfrm(
  toy,
  "Person",
  c("Rater", "Criterion"),
  "Score",
  method = "MML",
  model = "RSM",
  quad_points = 9
)
gpcm_fit <- fit_mfrm(
  toy,
  "Person",
  c("Rater", "Criterion"),
  "Score",
  method = "MML",
  model = "GPCM",
  step_facet = "Criterion",
  slope_facet = "Criterion",
  quad_points = 9
)
review <- build_weighting_review(rasch_fit, gpcm_fit, theta_points = 41)
summary(review)
#> mfrm Weighting Review Summary
#> 
#> Overview
#>  ReferenceModel ComparisonModel ReferenceMethod ComparisonMethod SlopeFacet
#>             RSM            GPCM             MML              MML  Criterion
#>                 ReviewStatus            ComparisonMode MaxAbsLogSlope
#>  reweighting_review_required same_basis_fit_comparison          0.138
#>  MaxAbsInfoShareDelta
#>                 0.024
#> 
#> Status
#>                 Item
#>       Overall status
#>  Weighting principle
#>     Comparison basis
#>                                                                          Value
#>                                                    reweighting_review_required
#>  Rasch-family equal weighting vs bounded GPCM discrimination-based reweighting
#>                                                      same_basis_fit_comparison
#> 
#> Key Warnings
#>  - Largest bounded GPCM slope deviation is at Criterion = Organization
#>    (Estimate = 1.148).
#>  - Largest within-facet information-share shift is -0.024 for Criterion =
#>    Organization.
#>  - Largest facet-measure shift is -0.032 for Criterion = Content.
#> 
#> Next Actions
#>  - Read summary(model_comparison) before interpreting any fit advantage as a
#>    scoring recommendation.
#>  - Use slope_profile and top_reweighted_levels to inspect whether Criterion
#>    levels are being upweighted or downweighted in substantively acceptable
#>    ways.
#>  - Use plot_information(compute_information(rasch_fit), type = "iif", facet =
#>    "Criterion", draw = FALSE) and the bounded GPCM analogue to inspect
#>    precision redistribution visually.
#>  - If equal contributions of items and raters are part of the score
#>    interpretation, retain the Rasch-family fit as the operational reference
#>    even when bounded GPCM fits better.
#> 
#> Top Measure Shifts
#>      Facet        Level ReferenceEstimate ReferenceRank ComparisonEstimate
#>  Criterion      Content            -0.401             1             -0.433
#>  Criterion     Language             0.094             3              0.122
#>  Criterion     Accuracy             0.240             4              0.258
#>  Criterion Organization             0.067             2              0.053
#>      Rater          R03             0.184             3              0.177
#>      Rater          R04             0.321             4              0.329
#>      Rater          R01            -0.189             2             -0.188
#>      Rater          R02            -0.317             1             -0.318
#>  ComparisonRank DeltaEstimate AbsDeltaEstimate RankShift              Direction
#>               1        -0.032            0.032         0  Lower in bounded GPCM
#>               3         0.028            0.028         0 Higher in bounded GPCM
#>               4         0.018            0.018         0 Higher in bounded GPCM
#>               2        -0.014            0.014         0  Lower in bounded GPCM
#>               3        -0.008            0.008         0  Lower in bounded GPCM
#>               4         0.007            0.007         0 Higher in bounded GPCM
#>               2         0.001            0.001         0 Higher in bounded GPCM
#>               1        -0.001            0.001         0  Lower in bounded GPCM
#> 
#> Top Reweighted Levels
#>      Facet        Level ReferenceIntegratedInfo ReferenceExposure
#>  Criterion Organization                1909.750               192
#>  Criterion     Accuracy                1909.445               192
#>  Criterion      Content                1909.047               192
#>  Criterion     Language                1909.722               192
#>  ReferenceInfoShare ReferenceExposureShare ComparisonIntegratedInfo
#>                0.25                   0.25                 2196.386
#>                0.25                   0.25                 1730.686
#>                0.25                   0.25                 1757.373
#>                0.25                   0.25                 1983.700
#>  ComparisonExposure ComparisonInfoShare ComparisonExposureShare InfoShareDelta
#>                 192               0.226                    0.25         -0.024
#>                 192               0.226                    0.25         -0.024
#>                 192               0.226                    0.25         -0.024
#>                 192               0.226                    0.25         -0.024
#>  ExposureShareDelta IntegratedInfoRatio AbsInfoShareDelta AbsLogInfoRatio
#>                   0               1.150             0.024           0.140
#>                   0               0.906             0.024           0.098
#>                   0               0.921             0.024           0.083
#>                   0               1.039             0.024           0.038
#>  SlopeEstimate SlopeLogEstimate SlopeDirection SlopeExposure SlopeExposureShare
#>          1.148            0.138     Upweighted           192               0.25
#>          0.910           -0.094   Downweighted           192               0.25
#>          0.924           -0.079   Downweighted           192               0.25
#>          1.036            0.036      Near unit           192               0.25
#> 
#> Support Status
#>                    Scope                Status
#>      RSM / PCM reference             supported
#>  bounded GPCM comparison supported_with_caveat
#>                                                                                                                                                                      Note
#>                                                                                                            Supported as the equal-weighting reference side of the review.
#>  Supported with caveat as a slope-aware comparison model. Use it to inspect discrimination-based reweighting, not as an automatic replacement for the Rasch-family route.
#> 
#> Notes
#>  - Observation weights and discrimination-based reweighting are separate
#>    concepts in this package.
#>  - The review is intended to make reweighting visible; it does not decide by
#>    itself whether bounded GPCM should replace the Rasch-family operational
#>    model.
#>  - Information-share changes are computed within each facet because the same
#>    total information is partitioned separately by facet.
review$top_reweighted_levels
#> # A tibble: 4 × 20
#>   Facet     Level    ReferenceIntegratedI…¹ ReferenceExposure ReferenceInfoShare
#>   <chr>     <chr>                     <dbl>             <dbl>              <dbl>
#> 1 Criterion Organiz…                  1910.               192              0.250
#> 2 Criterion Accuracy                  1909.               192              0.250
#> 3 Criterion Content                   1909.               192              0.250
#> 4 Criterion Language                  1910.               192              0.250
#> # ℹ abbreviated name: ¹​ReferenceIntegratedInfo
#> # ℹ 15 more variables: ReferenceExposureShare <dbl>,
#> #   ComparisonIntegratedInfo <dbl>, ComparisonExposure <dbl>,
#> #   ComparisonInfoShare <dbl>, ComparisonExposureShare <dbl>,
#> #   InfoShareDelta <dbl>, ExposureShareDelta <dbl>, IntegratedInfoRatio <dbl>,
#> #   AbsInfoShareDelta <dbl>, AbsLogInfoRatio <dbl>, SlopeEstimate <dbl>,
#> #   SlopeLogEstimate <dbl>, SlopeDirection <chr>, SlopeExposure <dbl>, …
# }
```
