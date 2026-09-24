# Summarize a facet-quality dashboard

Summarize a facet-quality dashboard

## Usage

``` r
# S3 method for class 'mfrm_facet_dashboard'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md).

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of flagged levels to preview.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_facet_dashboard`.

## See also

[`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md),
[`plot_facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_quality_dashboard.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
diag <- diagnose_mfrm(fit, residual_pca = "none")
summary(facet_quality_dashboard(fit, diagnostics = diag))
#> mfrmr Facet Quality Dashboard Summary
#> 
#> Overview
#>  Facet FacetSource Levels FlaggedLevels IncompleteLevels BiasSourceBundles
#>  Rater    inferred      4             0                0                 0
#> 
#> Summary
#>  Facet Levels MeanEstimate    SD MinEstimate MaxEstimate MeanInfit MeanOutfit
#>  Rater      4            0 0.313      -0.329       0.333     0.993      1.019
#>  SeverityFlagged MisfitFlagged CentralTendencyFlagged BiasFlagged AnyFlagged
#>                0             0                      0           0          0
#>  BiasRows
#>         0
#> 
#> Settings
#>               Setting    Value
#>                 facet    Rater
#>          facet_source inferred
#>         severity_warn        1
#>           misfit_warn      1.5
#>          misfit_lower      0.5
#>  central_tendency_max       NA
#>       bias_count_warn        1
#>       bias_abs_t_warn        2
#>    bias_abs_size_warn      0.5
#>            bias_p_max     0.05
#>   bias_source_bundles        0
#> 
#> Notes
#>  - Flags are screening prompts, not evidence of invalid ratings or grounds for automatic exclusion.
#>  - Severity is relative to the fitted reference; inspect workload, category use and common ratings before comparing levels.
#>  - FlagCount counts observed flags only. MissingMetrics identifies unavailable diagnostics; zero flags does not mean all checks passed.
#>  - BiasCount counts flagged cells in supplied bias results only; zero does not establish absence of bias.
#>  - Stored fit readiness plus numerical, data-support, connectivity, and stability checks passed. Treat this display as diagnostic evidence, not automatic publication approval.
#>  - Legacy CentralTendencyFlag is disabled by default because origin proximity does not diagnose observed category avoidance or range restriction.
#>  - No level-level flags were triggered under the current thresholds.
# }
```
