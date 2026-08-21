# Summarize an APA/FACETS table object

Summarize an APA/FACETS table object

## Usage

``` r
# S3 method for class 'apa_table'
summary(object, digits = 3, top_n = 8, ...)
```

## Arguments

- object:

  Output from
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md).

- digits:

  Number of digits used for numeric summaries.

- top_n:

  Maximum numeric columns shown in `numeric_profile`.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.apa_table`.

## Details

Compact summary helper for QA of table data before manuscript export.

## Interpreting output

- `overview`: table size/composition and missingness.

- `numeric_profile`: quick distribution summary of numeric columns.

- `caption`/`note`: text metadata readiness.

## Typical workflow

1.  Build table with
    [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md).

2.  Run `summary(tbl)` and inspect `overview`.

3.  Use
    [`plot.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.apa_table.md)
    for quick numeric checks if needed.

## See also

[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
tbl <- apa_table(fit, which = "summary")
summary(tbl)
#> APA Table Summary
#>  Branch Style   Which Rows Columns NumericColumns MissingValues
#>     apa   apa summary    1      87             40            14
#> 
#> Caption
#>  - Table 1
#> Facet Summary (Measures, Precision, Fit, Reliability)
#> 
#> Note
#>  - Measures are reported in logits; higher person values indicate higher ability, and higher non-person facet values indicate greater severity/difficulty (all non-person facets used the default negative orientation in this fit). Model S.E. = exploratory standard error; Real S.E. = fit-adjusted exploratory standard error; MnSq = mean-square fit. Report CI_Lower / CI_Upper (95%, Normal approximation) alongside measures for rows flagged CIEligible. Model = RSM; estimation = JML; N = 768 observations from 48 persons on a 4-category scale (1-4).
#> 
#> Numeric profile
#>            Column N   Mean SD    Min    Max
#>               AIC 0     NA NA     NA     NA
#>               BIC 0     NA NA     NA     NA
#>        Categories 1    4.0 NA    4.0    4.0
#>   ConvergenceCode 1    1.0 NA    1.0    1.0
#>          Deviance 1 1641.9 NA 1641.9 1641.9
#>      EMIterations 0     NA NA     NA     NA
#>  EMRelativeChange 0     NA NA     NA     NA
#>   EffectiveReltol 1    0.0 NA    0.0    0.0
# }
```
