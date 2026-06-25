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

The current release supports two-way interactions between non-person
facets, for example `facet_interactions = "Rater:Criterion"`. Each
interaction matrix is identified by zero marginal sums across both
participating facets, so the interaction estimates are separable from
the two main effects. Positive values indicate higher-than-expected
scores for the facet-level combination under the additive model;
negative values indicate lower-than-expected scores.

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
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(
  toy, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", method = "JML", model = "RSM", maxit = 30
)
interaction_effect_table(fit)
#> # A tibble: 0 × 0
```
