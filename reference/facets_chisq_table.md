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
  Must match this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
  for migration of saved diagnostics.

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

- `summary`: full-family available/unavailable counts and
  screen-positive counts, before `top_n` limits displayed rows.

- `thresholds`: p-value criteria used for flagging.

Use this table together with inter-rater and displacement diagnostics to
distinguish global facet effects from local anomalies.

## Typical workflow

1.  Run `facets_chisq_table(fit, ...)`.

2.  Inspect `summary(chi)` then facet rows in `chi$table`.

3.  Visualize with [plot(x, type =
    "facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md).

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

  FACETS-form random spread index and reference tail area. It does not
  establish normality or random sampling: with equal SEs and positive
  adjusted variance the statistic is identically eligible-level count
  minus one, regardless of distributional shape. Full covariance is not
  propagated.

- FixedFlag, RandomFlag:

  Logical flags for significance.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[plot(x, type =
"facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
chi <- facets_chisq_table(fit)
summary(chi)
#> mfrmr Facet Variability Summary 
#>   Class: mfrm_facets_chisq
#>   Components: 3
#> 
#> Facet variability summary
#>  Facets FixedAvailable FixedUnavailable RandomAvailable RandomUnavailable
#>       3              3                0               3                 0
#>  FixedSignificant RandomSignificant MeanRandomVar MaxFixedChiSq MaxRandomChiSq
#>                 3                 0         0.417       384.048         45.462
#> 
#> Facet rows: table
#>      Facet Levels EligibleLevels ExcludedLevels MeanMeasure    SD FixedChiSq
#>     Person     48             48              0       0.001 1.099    384.048
#>      Rater      4              4              0       0.000 0.313     30.899
#>  Criterion      4              4              0       0.000 0.288     25.914
#>  FixedDF RandomVar FixedProb RandomChiSq RandomDF RandomProb InferenceTier
#>       47     1.089         0      45.462       46      0.495     screening
#>        3     0.089         0       2.999        2      0.223     screening
#>        3     0.073         0       2.997        2      0.223     screening
#>  SupportsFormalInference
#>                    FALSE
#>                    FALSE
#>                    FALSE
#>                                               StatisticBasis FixedFlag
#>  Diagonal-SE heterogeneity screen; covariance not propagated      TRUE
#>  Diagonal-SE heterogeneity screen; covariance not propagated      TRUE
#>  Diagonal-SE heterogeneity screen; covariance not propagated      TRUE
#>  RandomFlag
#>       FALSE
#>       FALSE
#>       FALSE
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
```
