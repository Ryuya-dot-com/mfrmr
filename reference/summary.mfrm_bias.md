# Summarize an `mfrm_bias` object in a user-friendly format

Summarize an `mfrm_bias` object in a user-friendly format

## Usage

``` r
# S3 method for class 'mfrm_bias'
summary(object, digits = 3, top_n = 10, p_cut = 0.05, ...)
```

## Arguments

- object:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of strongest bias rows to keep.

- p_cut:

  Tail-area cutoff used for counting screen-positive rows.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_bias` with:

- `overview`: interaction facets/order, cell counts, and effect-size
  profile

- `chi_sq`: fixed-effect chi-square block

- `final_iteration`: end-of-iteration status row

- `top_rows`: highest-`|t|` interaction rows

- `notes`: short interpretation notes

## Details

This method returns a compact interaction-bias summary:

- interaction facets/order and analyzed cell counts

- effect-size profile (`|bias|` mean/max, screen-positive cell count)

- fixed-effect chi-square block

- iteration-end convergence indicators

- top rows ranked by absolute t

## Interpreting output

- `overview`: interaction order, analyzed cells, and effect-size
  profile.

- `chi_sq`: fixed-effect test block.

- `final_iteration`: end-of-loop status from the bias routine.

- `top_rows`: strongest bias contrasts by `|t|`; bounded `GPCM`
  summaries also retain the profile-likelihood review columns when
  present.

## Typical workflow

1.  Estimate interactions with
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

2.  Check `summary(bias)` for screen-positive and unstable cells.

3.  Use
    [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
    or
    [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md)
    for details.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_bias")
toy <- toy[toy$Person %in% unique(toy$Person)[1:8], ]
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Category support is retained but requires review: at least one fitted or local scope contains an empty or singleton category/transition cell. The fit may be inspected, but category-information strength has not been certified; inspect `fit$data_review$category_support` before inference.
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 1)
summary(bias)
#> Many-Facet Measurement Bias Summary
#>   Interaction facets: Rater x Criterion | Cells: 16
#>   Order: 2 | Mode: pairwise
#>   Mean |Bias|: 0.304 | Max |Bias|: 0.909 | Screen-positive (p <= 0.050): 0
#>   Bonferroni screen-positive: 0 | Holm screen-positive: 0 (cut = 0.050, m = 16)
#> 
#> Fixed-effect chi-square
#>  FixedChiSq FixedDF FixedProb InferenceTier SupportsFormalInference
#>       3.521      15     0.999     screening                   FALSE
#>  FormalInferenceEligible PrimaryReportingEligible   ReportingUse
#>                    FALSE                    FALSE screening_only
#>                                 TestBasis InteractionFacets InteractionOrder
#>  conditional plug-in heterogeneity screen Rater x Criterion                2
#>  InteractionMode
#>         pairwise
#> 
#> Final iteration status
#>  Iteration MaxScoreResidual MaxScoreResidualPct MaxScoreResidualCategories
#>          1                0                   0                         NA
#>  MaxLogitChange BiasCells
#>          -0.909        16
#> 
#> Top |t| bias rows
#>                Pair Rater    Criterion Bias Size  S.E.      t Prob.
#>      R04 | Accuracy   R04     Accuracy    -0.909 0.929 -0.979 0.431
#>       R04 | Content   R04      Content     0.759 0.982  0.773 0.520
#>  R04 | Organization   R04 Organization     0.759 0.982  0.773 0.520
#>  R01 | Organization   R01 Organization    -0.384 0.624 -0.615 0.572
#>       R02 | Content   R02      Content    -0.473 0.783 -0.604 0.588
#>      R04 | Language   R04     Language    -0.470 0.929 -0.506 0.663
#>      R02 | Accuracy   R02     Accuracy     0.248 0.735  0.337 0.758
#>      R01 | Language   R01     Language     0.203 0.624  0.325 0.761
#>      R01 | Accuracy   R01     Accuracy     0.163 0.643  0.253 0.813
#>      R03 | Accuracy   R03     Accuracy     0.134 0.823  0.163 0.881
#>  Obs-Exp Average  AbsT
#>                0 0.979
#>                0 0.773
#>                0 0.773
#>                0 0.615
#>                0 0.604
#>                0 0.506
#>                0 0.337
#>                0 0.325
#>                0 0.253
#>                0 0.163
#> 
#> Notes
#>  - Bias iteration may not have fully stabilized (BiasCells > 0 at final step).
# }
```
