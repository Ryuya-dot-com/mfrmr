# Extract model-estimated facet interaction effects

`interaction_effect_table()` returns the fixed-effect interaction block
estimated by
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
when `facet_interactions` is supplied. These are model-estimated
deviations from the additive main-effects MFRM, not the residual
screening statistics returned by
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

## Usage

``` r
interaction_effect_table(fit)
```

## Arguments

- fit:

  An `mfrm_fit` object returned by
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## Value

A tibble with one row per interaction cell. Returns an empty tibble when
the fit has no model-estimated facet interactions.

## Details

mfrmr supports two-way interactions between non-person facets, for
example `facet_interactions = "Rater:Criterion"`. Each interaction
matrix is identified by zero marginal sums across both participating
facets, so the interaction estimates are separable from the two main
effects. Positive values indicate higher-than-expected scores for the
facet-level combination under the additive model; negative values
indicate lower-than-expected scores.

Use this table for confirmatory model review after specifying the facet
pair of substantive interest. For exploratory screening without adding
parameters to the fitted model, use
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
or
[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md).

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)

## Examples

``` r
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(
  toy, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", method = "MML", model = "RSM",
  facet_interactions = "Rater:Criterion",
  quad_points = 7, maxit = 30
)
head(interaction_effect_table(fit))
#> # A tibble: 6 × 10
#>   Interaction   FacetA FacetA_Level FacetB FacetB_Level Estimate     N WeightedN
#>   <chr>         <chr>  <chr>        <chr>  <chr>           <dbl> <int>     <dbl>
#> 1 Rater:Criter… Rater  R01          Crite… Content         0.130    15        15
#> 2 Rater:Criter… Rater  R02          Crite… Content        -0.123    19        19
#> 3 Rater:Criter… Rater  R03          Crite… Content        -0.382    17        17
#> 4 Rater:Criter… Rater  R04          Crite… Content        -0.308    15        15
#> 5 Rater:Criter… Rater  R05          Crite… Content         0.543    15        15
#> 6 Rater:Criter… Rater  R06          Crite… Content         0.140    13        13
#> # ℹ 2 more variables: Sparse <lgl>, Identification <chr>
```
