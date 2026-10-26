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
interaction_effect_table(fit, comparison_review = NULL)
```

## Arguments

- fit:

  An `mfrm_fit` or `mfrm_comparison_fit` returned by
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- comparison_review:

  Optional result of
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  with `comparisons`, or its `$comparison_review` component. Returns the
  declared interaction contrasts from a matching joint fit instead of
  individual cells.

## Value

A tibble with one row per interaction cell. Returns an empty tibble when
the fit has no model-estimated facet interactions. With
`comparison_review`, one row per requested contrast with availability,
numerical and readiness fields; attributes `comparison_review`,
`fit_checks` and `notes` preserve the prospective question, source
fingerprint and numerical evidence, and interpretation limits.

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

With `comparison_review`, first fit the declared model using the
review's `fit_arguments` and the original ratings. The fit must match
the retained responses, origins, score coding, model, constraints, facet
orientation, step owner and population design. Only native, unadjusted
RSM/PCM fits without shrinkage are supported. The contrast is the
declared weighted sum of Group1-minus-Group2 interaction effects, in
logits. Positive means a relative shift toward higher coded scores; it
is not an absolute school effect or evidence of unfairness. Location and
step effects are not added.

This route reevaluates the retained likelihood and full gradient without
optimization. Objective agreement must be within `1e-6` and the gradient
sup norm within `max(1e-4, 10 * reltol)`, matching the ordinary
numerical stopping tolerance. For MML it also evaluates `2 * q + 1`
quadrature nodes, requiring the finer-grid gradient to meet that
tolerance and the absolute negative-log-likelihood change per Person to
be at most `1e-6`. These are numerical checks, not statistical precision
criteria. A failed check retains the row with `Estimate = NA` and an
explanation; the separate `OptimizerEstimate` is a diagnostic trace. No
refit or partial fit is run.

`EstimateStatus = "descriptive_only"` requires full conditional-map
rank, numerical convergence, current readiness information and no
recorded blocking condition or boundary exclusion. It does not certify
finite-MLE existence, global marginal identification or sampling
performance. MML retains `State = "not_evaluated"` for positive
conditional ranks even when a descriptive fitted contrast is available.
`BoundaryState`, `FitReadiness`, `NumericalState` and `QuadratureState`
remain separate. `SE`, `Lower`, `Upper` remain missing and
`FormalInferenceEligible` remains false. A target-only identified
contrast in a rejected full model remains unavailable through this
route. Save the returned table with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) to preserve its
review and checks without recalculation; CSV retains the visible columns
but not the attributes.

For a `mfrm_comparison_fit` created with `fit_scope = "comparisons"`,
omit `comparison_review`: the table already contains the declared
targets and their partial-fit checks. Extraction does not fit again. See
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
for its likelihood-preserving parameterization, availability
requirements and limits. For full RSM/PCM MML fits,
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
with the same `comparison_review` separately supplies model-information
intervals and supported population-SD standardization; extraction here
stays descriptive. CML comparison fits add conditional-information SEs
and pointwise 95 percent Wald limits for identified targets, with
`conditional_wald` status; unidentified rows remain missing. The
ordinary full-fit route above remains unchanged.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
with `interaction` for supported fixed-population RSM/PCM MML cell
intervals from full joint information.

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
