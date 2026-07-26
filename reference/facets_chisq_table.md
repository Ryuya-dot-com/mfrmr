# Build facet variability diagnostics with fixed/random reference tests

Build facet variability diagnostics with fixed/random reference tests

## Usage

``` r
facets_chisq_table(
  fit,
  diagnostics = NULL,
  fixed_p_max = 0.05,
  random_p_max = 0.05,
  top_n = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- fixed_p_max:

  Warning cutoff for fixed-effect chi-square p-values.

- random_p_max:

  Warning cutoff for random-effect chi-square p-values.

- top_n:

  Optional maximum number of facet rows to keep.

## Value

A named list with:

- `table`: facet-level chi-square diagnostics

- `summary`: one-row summary

- `thresholds`: applied p-value thresholds

## Details

This helper summarizes facet-level variability with fixed and random
chi-square indices for spread and heterogeneity checks.

## Interpreting output

- `table`: facet-level fixed/random chi-square and p-value flags.

- `summary`: number of significant facets and overall magnitude
  indicators.

- `thresholds`: p-value criteria used for flagging.

Use this table together with inter-rater and displacement diagnostics to
distinguish global facet effects from local anomalies.

## Typical workflow

1.  Run `facets_chisq_table(fit, ...)`.

2.  Inspect `summary(chi)` then facet rows in `chi$table`.

3.  Visualize with
    [`plot_facets_chisq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facets_chisq.md).

## Output columns

The `table` data.frame contains:

- Facet:

  Facet name.

- Levels:

  Number of estimated levels in this facet.

- MeanMeasure, SD:

  Mean and standard deviation of level measures.

- FixedChiSq, FixedDF, FixedProb:

  Fixed-effect chi-square test (null hypothesis: all levels equal).
  Significant result means the facet elements differ more than
  measurement error alone.

- RandomChiSq, RandomDF, RandomProb, RandomVar:

  Random-effect test (null hypothesis: variation equals that of a random
  sample from a single population). Significant result suggests
  systematic heterogeneity beyond sampling variation.

- FixedFlag, RandomFlag:

  Logical flags for significance.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[`plot_facets_chisq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facets_chisq.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
chi <- facets_chisq_table(fit)
summary(chi)
#> mfrmr Facet Variability Summary 
#>   Class: mfrm_facets_chisq
#>   Components: 3
#> 
#> Facet variability summary
#>  Facets FixedSignificant RandomSignificant MeanRandomVar MaxFixedChiSq
#>       3                3                 0         0.417       384.088
#>  MaxRandomChiSq
#>          45.462
#> 
#> Facet rows: table
#>      Facet Levels MeanMeasure    SD FixedChiSq FixedDF RandomVar FixedProb
#>     Person     48       0.001 1.099    384.088      47     1.089         0
#>      Rater      4       0.000 0.313     30.901       3     0.089         0
#>  Criterion      4       0.000 0.288     25.914       3     0.073         0
#>  RandomChiSq RandomDF RandomProb FixedFlag RandomFlag
#>       45.462       46      0.495      TRUE      FALSE
#>        2.999        2      0.223      TRUE      FALSE
#>        2.997        2      0.223      TRUE      FALSE
#> 
#> Settings
#>       Setting Value
#>   fixed_p_max  0.05
#>  random_p_max  0.05
#> 
#> Notes
#>  - Facet variability summary with fixed/random reference tests.
p_chi <- plot(chi, draw = FALSE)
p_chi$data$plot
#> [1] "fixed"
# }
```
