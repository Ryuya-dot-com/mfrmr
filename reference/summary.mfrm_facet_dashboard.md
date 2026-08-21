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
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
summary(facet_quality_dashboard(fit, diagnostics = diag))
#> mfrmr Facet Quality Dashboard Summary
#> 
#> Overview
#>  Facet FacetSource Levels FlaggedLevels BiasSourceBundles
#>  Rater    inferred      4             2                 0
#> 
#> Summary
#>  Facet Levels MeanEstimate    SD MinEstimate MaxEstimate MeanInfit MeanOutfit
#>  Rater      4            0 0.313      -0.329       0.333     0.994      1.019
#>  SeverityFlagged MisfitFlagged CentralTendencyFlagged BiasFlagged AnyFlagged
#>                0             0                      2           0          2
#>  BiasRows
#>         0
#> 
#> Flagged levels
#>  Facet Level Estimate ParameterStatus BoundaryDirection ResponseExtreme
#>  Rater   R01   -0.196            <NA>              <NA>            <NA>
#>  Rater   R03    0.191            <NA>              <NA>            <NA>
#>  OptimizerEstimate DisplayEstimate DisplayAdjustment PrimaryEstimateBasis
#>                 NA              NA              <NA>                 <NA>
#>                 NA              NA              <NA>                 <NA>
#>  OptimizerEstimateUse ReasonCodes ReadinessContractVersion SourceFitReadiness
#>                  <NA>        <NA>                     <NA>               <NA>
#>                  <NA>        <NA>                     <NA>               <NA>
#>  SourceInferenceReady EstimateUse N.x    SE ModelSE RealSE
#>                    NA        <NA> 192 0.097   0.097  0.100
#>                    NA        <NA> 192 0.097   0.097  0.097
#>                      SE_Method Converged InferenceReady ConvergenceSeverity
#>  Observation-table information     FALSE          FALSE                fail
#>  Observation-table information     FALSE          FALSE                fail
#>  PrecisionTier SupportsFormalInference          SEUse
#>    exploratory                   FALSE screening_only
#>    exploratory                   FALSE screening_only
#>                                                CIBasis          CIUse N.y Infit
#>  Normal interval from exploratory observation-table SE screening_only 192 1.051
#>  Normal interval from exploratory observation-table SE screening_only 192 0.964
#>  Outfit InfitZSTD OutfitZSTD DF_Infit DF_Outfit N.x.x ObservedAverage
#>   1.045     0.408      0.464  105.624       192   192           2.609
#>   0.970    -0.217     -0.263  105.751       192   192           2.396
#>  ExpectedAverage Bias MeanResidual MeanStdResidual MeanAbsStdResidual   ChiSq
#>            2.609    0            0          -0.009              0.841 200.557
#>            2.396    0            0           0.001              0.812 186.231
#>  ChiDf  ChiP SE_Residual t_Residual p_Residual SE_StdResidual t_StdResidual
#>    191 0.303       0.054          0          1          0.072        -0.122
#>    191 0.584       0.054          0          1          0.072         0.014
#>  p_StdResidual  DF PTMEA N.y.y BoundaryExcluded CI_Lower CI_Upper CI_Level
#>          0.903 191 0.623   192            FALSE   -0.386   -0.005     0.95
#>          0.989 191 0.658   192            FALSE    0.000    0.382     0.95
#>             CI_Method CIEligible                              CILabel   N
#>  Normal approximation      FALSE Approximate interval; screening only 192
#>  Normal approximation      FALSE Approximate interval; screening only 192
#>  AbsEstimate SeverityFlag MisfitFlag CentralTendencyFlag BiasCount BiasSources
#>        0.196        FALSE      FALSE                TRUE         0           0
#>        0.191        FALSE      FALSE                TRUE         0           0
#>  BiasFlag FlagCount AnyFlag FlagLabel .AbsEstimate
#>     FALSE         1    TRUE   central        0.196
#>     FALSE         1    TRUE   central        0.191
#> 
#> Settings
#>               Setting    Value
#>                 facet    Rater
#>          facet_source inferred
#>         severity_warn        1
#>           misfit_warn      1.5
#>  central_tendency_max     0.25
#>       bias_count_warn        1
#>       bias_abs_t_warn        2
#>    bias_abs_size_warn      0.5
#>            bias_p_max     0.05
#>   bias_source_bundles        0
#> 
#> Notes
#>  - Dashboard constructed successfully.
# }
```
