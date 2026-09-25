# Build a weighting-policy review between Rasch-family and GPCM fits

Build a weighting-policy review between Rasch-family and GPCM fits

## Usage

``` r
build_weighting_review(
  rasch_fit,
  gpcm_fit,
  theta_range = c(-6, 6),
  theta_points = 101L,
  top_n = 10L,
  nested = FALSE
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
  using `model = "GPCM"`.

- theta_range:

  Numeric vector of length 2 passed to
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  for the information-redistribution comparison.

- theta_points:

  Integer number of theta grid points passed to
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md).

- top_n:

  Maximum number of rows to keep in compact summary outputs.

- nested:

  Request the PCM/GPCM equal-slope likelihood-ratio test. Default
  `FALSE`. Requires matched MML fits and the checks in
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).

## Value

An object of class `mfrm_weighting_review`.

## Details

`build_weighting_review()` is an operational model-choice review helper.
It is designed for the common question:

- what changes when a Rasch-family equal-weighting model is replaced
  with a `GPCM` that allows discrimination-based reweighting?

The helper does not estimate a new model. Instead, it synthesizes four
package-native evidence sources:

- [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  for same-data model comparison

- the non-person facet measures from each fit

- the `GPCM` slope table

- [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  for design-weighted information redistribution

The result is intended for substantive review, not for automatic model
selection. In particular, a better-fitting `GPCM` should not by itself
be interpreted as a reason to discard an equal-weighting Rasch-family
route. The fitted GPCM contains one slope for every level of one
designated facet, not one common slope and not simultaneous
criterion-by-rater slope blocks. The overview records the slope owner,
step owner, level count, free relative slope contrasts, and whether the
supplied reference is the exact unit-slope PCM response-kernel
reduction. MML information-criterion ranking requires the likelihood and
local-solution checks in
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).
With `nested = TRUE`, a PCM/GPCM asymptotic chi-square LRT additionally
requires matching population, step and facet settings and G-1 free slope
contrasts. The returned `comparison_contract` records the comparison and
test status; observed changes in scores and information need substantive
interpretation. A JML log-likelihood increase is not promoted to
automatic PCM-versus-GPCM model selection because it is unpenalized and
the GPCM contains additional slope parameters. FACETS may serve as a
direct comparator for the PCM/JML side only; its post-fit discrimination
statistic is not a jointly estimated free-slope GPCM counterpart.

## Recommended input route

1.  Fit an equal-weighting reference model with `model = "RSM"` or
    `"PCM"`.

2.  Fit a `GPCM` on the same prepared response data.

3.  Run `build_weighting_review(rasch_fit, gpcm_fit)`.

4.  Read `summary(review)` before deciding whether the
    discrimination-based reweighting is substantively acceptable.

## What the returned tables mean

- `model_comparison`: same-data model-comparison bundle from
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).
  AIC/Person-BIC/SABIC ranking is available only when `ICComparable` is
  true. Inspect `$lrt` and `$comparison_basis$lrt_reason` for a
  requested test.

- `comparison_contract`: one-row evidence-tier table stating whether
  formal model selection is available, how any observed log-likelihood
  difference may be read, and the bounded role of FACETS in a JML
  review.

- `facet_shift`: how non-person facet estimates move under `GPCM`.

- `slope_profile`: which `slope_facet` levels are upweighted or
  downweighted.

- `information_redistribution`: within-facet information-share changes
  between the Rasch-family fit and `GPCM`.

- `top_reweighted_levels`: compact triage table for the strongest
  slope-facet-level redistribution signals.

## GPCM boundary

This helper is available only for the current `GPCM` branch. It requires
the package's existing `slope_facet == step_facet` contract and should
be read as an operational weighting-policy review, not as a formal
validity adjudication.

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
#>  StepFacet SlopeLevelCount FreeRelativeSlopeContrasts
#>  Criterion               4                          3
#> 
#> Comparison interpretation
#>   Numerical convergence checks passed for both fits; inference eligibility is
#>   assessed separately.
#>   Log-likelihood difference: 8.593 
#>   Inspect changes in facet measures, relative slopes and information shares.
#>   The supplied fits do not satisfy the information-criterion comparison checks.
#>   An equal-slope PCM/GPCM test requires two MML fits with the same step facet
#>   and population model.
#> 
#> Key Warnings
#>  - Model-comparison weights are descriptive only because the two fits do not
#>    share a fully comparable formal MML basis.
#>  - Largest GPCM slope deviation is at Criterion = Organization (Estimate =
#>    1.148).
#>  - Largest within-facet information-share shift is -0.026 for Criterion =
#>    Organization.
#>  - Largest facet-measure shift is -0.020 for Criterion = Organization.
#> 
#> Next Actions
#>  - Read summary(model_comparison) before interpreting any fit advantage as a
#>    scoring recommendation.
#>  - Use IC ranking only when ICComparable is true; weighting consequences
#>    require a separate substantive decision.
#>  - Use slope_profile and top_reweighted_levels to inspect whether Criterion
#>    levels are being upweighted or downweighted in substantively acceptable
#>    ways.
#>  - Use plot_information(compute_information(rasch_fit), type = "iif", facet =
#>    "Criterion", draw = FALSE) and the GPCM analogue to inspect precision
#>    redistribution visually.
#> 
#> Top Measure Shifts
#>      Facet        Level ReferenceEstimate ReferenceRank ComparisonEstimate
#>  Criterion Organization             0.067             2              0.047
#>  Criterion     Language             0.094             3              0.113
#>  Criterion     Accuracy             0.240             4              0.257
#>  Criterion      Content            -0.401             1             -0.417
#>      Rater          R03             0.184             3              0.172
#>      Rater          R02            -0.317             1             -0.309
#>      Rater          R01            -0.189             2             -0.183
#>      Rater          R04             0.321             4              0.320
#>  ComparisonRank DeltaEstimate AbsDeltaEstimate RankShift      Direction
#>               2        -0.020            0.020         0  Lower in GPCM
#>               3         0.019            0.019         0 Higher in GPCM
#>               4         0.017            0.017         0 Higher in GPCM
#>               1        -0.017            0.017         0  Lower in GPCM
#>               3        -0.013            0.013         0  Lower in GPCM
#>               1         0.008            0.008         0 Higher in GPCM
#>               2         0.006            0.006         0 Higher in GPCM
#>               4        -0.002            0.002         0  Lower in GPCM
#> 
#> Top Reweighted Levels
#>      Facet        Level ReferenceIntegratedInfo ReferenceExposure
#>  Criterion Organization                1909.750               192
#>  Criterion     Accuracy                1909.445               192
#>  Criterion      Content                1909.047               192
#>  Criterion     Language                1909.722               192
#>  ReferenceInfoShare ReferenceExposureShare ComparisonIntegratedInfo
#>                0.25                   0.25                 2196.635
#>                0.25                   0.25                 1721.569
#>                0.25                   0.25                 1763.436
#>                0.25                   0.25                 1989.414
#>  ComparisonExposure ComparisonInfoShare ComparisonExposureShare InfoShareDelta
#>                 192               0.224                    0.25         -0.026
#>                 192               0.224                    0.25         -0.026
#>                 192               0.224                    0.25         -0.026
#>                 192               0.224                    0.25         -0.026
#>  ExposureShareDelta IntegratedInfoRatio AbsInfoShareDelta AbsLogInfoRatio
#>                   0               1.150             0.026           0.140
#>                   0               0.902             0.026           0.104
#>                   0               0.924             0.026           0.079
#>                   0               1.042             0.026           0.041
#>  SlopeEstimate SlopeLogEstimate SlopeDirection SlopeExposure SlopeExposureShare
#>          1.148            0.138     Upweighted           192               0.25
#>          0.905           -0.100   Downweighted           192               0.25
#>          0.926           -0.077   Downweighted           192               0.25
#>          1.039            0.038      Near unit           192               0.25
#> 
#> Notes
#>  - Observation weights and discrimination-based reweighting are separate
#>    concepts in this package.
#>  - The fitted slopes vary across levels of `Criterion`; other facets have no
#>    separate slope block.
#>  - Criterion-owned and rater-owned GPCM fits are separate restricted models;
#>    both blocks cannot be estimated together by the current GPCM interface.
#>  - FACETS is a direct JML comparator only for the aligned equal-discrimination
#>    PCM side; its reported discrimination is a post-fit diagnostic, not the
#>    fitted free-slope GPCM parameter.
#>  - The review is intended to make reweighting visible; it does not decide by
#>    itself whether GPCM should replace the Rasch-family operational model.
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
