# Build a bias-interaction plot-data bundle (FACETS Table 13: ranked bias list)

Bundles the **ranked flagged-cells** view of a bias-interaction run for
downstream printing and plotting. The three sibling reports in this
family are intentionally distinct:

- `bias_interaction_report()` (this one) = FACETS Table 13: a ranked
  list of interaction cells with `t`, `bias size`, and screening tail
  area – use when reviewing which `(facet_a, facet_b)` cells deserve
  follow-up.

- [`bias_iteration_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_iteration_report.md)
  = iteration history / convergence trace for the bias recalibration
  (FACETS Table 9 territory) – use when diagnosing whether the bias run
  itself stabilised.

- [`bias_pairwise_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_pairwise_report.md)
  = pairwise contrast table for a target facet (FACETS Table 14
  territory) – use when comparing levels within a facet while
  controlling for the other.

## Usage

``` r
bias_interaction_report(
  x,
  diagnostics = NULL,
  facet_a = NULL,
  facet_b = NULL,
  interaction_facets = NULL,
  max_abs = 10,
  omit_extreme = TRUE,
  max_iter = 4,
  tol = 0.001,
  top_n = 50,
  abs_t_warn = 2,
  abs_bias_warn = 0.5,
  p_max = 0.05,
  sort_by = c("abs_t", "abs_bias", "prob")
)
```

## Arguments

- x:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  or
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  (used when `x` is fit).

- facet_a:

  First facet name (required when `x` is fit and `interaction_facets` is
  not supplied).

- facet_b:

  Second facet name (required when `x` is fit and `interaction_facets`
  is not supplied).

- interaction_facets:

  Character vector of two or more facets.

- max_abs:

  Bound for absolute bias size when estimating from fit.

- omit_extreme:

  Omit extreme-only elements when estimating from fit.

- max_iter:

  Iteration cap for bias estimation when `x` is fit.

- tol:

  Convergence tolerance for bias estimation when `x` is fit.

- top_n:

  Maximum number of ranked rows to keep.

- abs_t_warn:

  Warning cutoff for absolute t statistics.

- abs_bias_warn:

  Warning cutoff for absolute bias size.

- p_max:

  Warning cutoff for p-values.

- sort_by:

  Ranking key: `"abs_t"`, `"abs_bias"`, or `"prob"`.

## Value

A named list with bias-interaction plotting/report components. Class:
`mfrm_bias_interaction`.

## Details

Preferred bundle API for interaction-bias diagnostics. The function can:

- use a precomputed bias object from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
  or

- estimate internally from `mfrm_fit` + facet specification.

## Interpreting output

Focus on ranked rows where multiple screening criteria converge:

- large absolute t statistic

- large absolute bias size

- small screening tail area

The bundle is optimized for downstream
[`summary()`](https://rdrr.io/r/base/summary.html) and
[`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md)
views.

## Typical workflow

1.  Run
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
    (or provide `mfrm_fit` here).

2.  Build `bias_interaction_report(...)`.

3.  Review `summary(out)` and visualize with
    [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md).

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md),
[`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
out <- bias_interaction_report(bias, top_n = 10)
summary(out)
#> mfrmr Bias Interaction Summary 
#>   Class: mfrm_bias_interaction
#>   Components: 14
#> 
#> Interaction summary
#>  InteractionFacets InteractionOrder InteractionMode FacetA    FacetB Cells
#>  Rater x Criterion                2        pairwise  Rater Criterion    16
#>  Flagged FlaggedPercent MeanAbsT MeanAbsBias               FlagStatus
#>        3          18.75    1.008        0.31 3 of 16 cell(s) flagged.
#> 
#> Ranked interaction rows: ranked_table
#>  InteractionFacets InteractionOrder InteractionMode FacetA    FacetB Level1
#>  Rater x Criterion                2        pairwise  Rater Criterion    R04
#>  Rater x Criterion                2        pairwise  Rater Criterion    R01
#>  Rater x Criterion                2        pairwise  Rater Criterion    R04
#>  Rater x Criterion                2        pairwise  Rater Criterion    R01
#>  Rater x Criterion                2        pairwise  Rater Criterion    R03
#>  Rater x Criterion                2        pairwise  Rater Criterion    R01
#>  Rater x Criterion                2        pairwise  Rater Criterion    R02
#>  Rater x Criterion                2        pairwise  Rater Criterion    R04
#>  Rater x Criterion                2        pairwise  Rater Criterion    R03
#>  Rater x Criterion                2        pairwise  Rater Criterion    R02
#>        Level2 ObsExpAverage BiasSize    SE      t  Prob ObservedCount LRChiSq
#>      Accuracy             0   -1.102 0.333 -3.310 0.003            24      NA
#>      Accuracy             0    0.777 0.308  2.521 0.019            24      NA
#>  Organization             0    0.683 0.299  2.281 0.032            24      NA
#>  Organization             0   -0.362 0.293 -1.235 0.229            24      NA
#>  Organization             0   -0.313 0.296 -1.059 0.301            24      NA
#>       Content             0   -0.277 0.301 -0.921 0.367            24      NA
#>      Accuracy             0    0.247 0.288  0.856 0.401            24      NA
#>      Language             0    0.234 0.297  0.788 0.439            24      NA
#>       Content             0    0.247 0.315  0.783 0.442            24      NA
#>      Language             0   -0.208 0.294 -0.709 0.485            24      NA
#>  LRDF LRProb ProfileCILower ProfileCIUpper ProfileCILevel ProfileCIStatus
#>    NA     NA             NA             NA             NA            <NA>
#>    NA     NA             NA             NA             NA            <NA>
#>    NA     NA             NA             NA             NA            <NA>
#>    NA     NA             NA             NA             NA            <NA>
#>    NA     NA             NA             NA             NA            <NA>
#>    NA     NA             NA             NA             NA            <NA>
#>    NA     NA             NA             NA             NA            <NA>
#>    NA     NA             NA             NA             NA            <NA>
#>    NA     NA             NA             NA             NA            <NA>
#>    NA     NA             NA             NA             NA            <NA>
#>  LikelihoodBasis               Pair  AbsT AbsBias TFlag BiasFlag PFlag  Flag
#>             <NA>     R04 | Accuracy 3.310   1.102  TRUE     TRUE  TRUE  TRUE
#>             <NA>     R01 | Accuracy 2.521   0.777  TRUE     TRUE  TRUE  TRUE
#>             <NA> R04 | Organization 2.281   0.683  TRUE     TRUE  TRUE  TRUE
#>             <NA> R01 | Organization 1.235   0.362 FALSE    FALSE FALSE FALSE
#>             <NA> R03 | Organization 1.059   0.313 FALSE    FALSE FALSE FALSE
#>             <NA>      R01 | Content 0.921   0.277 FALSE    FALSE FALSE FALSE
#>             <NA>     R02 | Accuracy 0.856   0.247 FALSE    FALSE FALSE FALSE
#>             <NA>     R04 | Language 0.788   0.234 FALSE    FALSE FALSE FALSE
#>             <NA>      R03 | Content 0.783   0.247 FALSE    FALSE FALSE FALSE
#>             <NA>     R02 | Language 0.709   0.208 FALSE    FALSE FALSE FALSE
#>  Facet1 Facet1_Level    Facet2 Facet2_Level FacetA_Level FacetB_Level
#>   Rater          R04 Criterion     Accuracy          R04     Accuracy
#>   Rater          R01 Criterion     Accuracy          R01     Accuracy
#>   Rater          R04 Criterion Organization          R04 Organization
#>   Rater          R01 Criterion Organization          R01 Organization
#>   Rater          R03 Criterion Organization          R03 Organization
#>   Rater          R01 Criterion      Content          R01      Content
#>   Rater          R02 Criterion     Accuracy          R02     Accuracy
#>   Rater          R04 Criterion     Language          R04     Language
#>   Rater          R03 Criterion      Content          R03      Content
#>   Rater          R02 Criterion     Language          R02     Language
#> 
#> Settings
#>        Setting Value
#>     abs_t_warn     2
#>  abs_bias_warn   0.5
#>          p_max  0.05
#>        sort_by abs_t
#>          top_n    10
#> 
#> Notes
#>  - Bias interaction report with ranked cells and facet-level profiles.
p_bi <- plot(out, draw = FALSE)
p_bi$data$plot
#> [1] "scatter"
# }
```
