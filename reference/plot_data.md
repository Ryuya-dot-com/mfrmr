# Extract reusable data from an mfrmr plot object

`plot_data()` is a small accessor for users who want to build custom
base-R, ggplot2, plotly, or table-based displays from mfrmr plot
helpers. It accepts an existing `mfrm_plot_data` object, or any mfrmr
object whose [`plot()`](https://rdrr.io/r/graphics/plot.default.html)
method supports `draw = FALSE`. Use
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md)
first when you want to inspect which components are available before
extracting one.

## Usage

``` r
plot_data(x, component = NULL, type = NULL, ...)
```

## Arguments

- x:

  An `mfrm_plot_data` object, or a fitted/report/review object with a
  `plot(..., draw = FALSE)` method.

- component:

  Optional single component name inside the reusable plot data. When
  `NULL`, the full plot-data list is returned.

- type:

  Optional plot type passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) when `x` is
  not already an `mfrm_plot_data` object.

- ...:

  Additional arguments passed to `plot(..., draw = FALSE)` when `x` is
  not already an `mfrm_plot_data` object.

## Value

The full reusable plot-data list, or the selected component.

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
# A balanced slice retains every Rater and Criterion while running quickly.
toy <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", maxit = 30)

wright_plot_data <- plot_data(fit, type = "wright")
names(wright_plot_data)
#>  [1] "wright_style"          "renderer"              "visual_contract"      
#>  [4] "person"                "person_exclusions"     "person_hist"          
#>  [7] "person_stats"          "locations"             "label_points"         
#> [10] "group_summary"         "group_levels"          "y_range"              
#> [13] "display_settings"      "label_limit"           "retention"            
#> [16] "retention_note"        "title"                 "subtitle"             
#> [19] "show_ci"               "uncertainty_display"   "group"                
#> [22] "preset"                "legend"                "reference_lines"      
#> [25] "scale_contract"        "plot_name"             "fit_readiness"        
#> [28] "interpretation_status" "interpretation_note"  

wright_table <- plot_data(fit, type = "wright", component = "locations")
head(wright_table)
#> # A tibble: 6 × 37
#>   Group     Label    PlotType    Estimate    SE CI_Level SE_Method PrecisionTier
#>   <fct>     <chr>    <chr>          <dbl> <dbl>    <dbl> <chr>     <chr>        
#> 1 Rater     R02      Facet level  -0.202  0.193     0.95 Observat… exploratory  
#> 2 Rater     R03      Facet level  -0.127  0.192     0.95 Observat… exploratory  
#> 3 Rater     R01      Facet level   0.0925 0.189     0.95 Observat… exploratory  
#> 4 Rater     R04      Facet level   0.236  0.188     0.95 Observat… exploratory  
#> 5 Criterion Content  Facet level  -0.428  0.197     0.95 Observat… exploratory  
#> 6 Criterion Language Facet level   0.0946 0.189     0.95 Observat… exploratory  
#> # ℹ 29 more variables: SupportsFormalInference <lgl>, SEUse <chr>,
#> #   CIBasis <chr>, CIUse <chr>, CIEligible <lgl>, CILabel <chr>,
#> #   Measure_Source <chr>, CI_Lower <dbl>, CI_Upper <dbl>, Step <chr>,
#> #   StepIndex <int>, BoundarySeparated <lgl>, XBase <dbl>, X <dbl>,
#> #   OriginalEstimate <dbl>, BelowRange <lgl>, AboveRange <lgl>,
#> #   DisplayEstimate <dbl>, DisplayLabel <chr>, OriginalCI_Lower <dbl>,
#> #   OriginalCI_Upper <dbl>, DisplayCI_Lower <dbl>, DisplayCI_Upper <dbl>, …

curves <- category_curves_report(fit, theta_points = 51)
curve_long <- plot_data(curves, component = "plot_long")
head(curve_long[, c("PlotType", "Theta", "Series", "Value")])
#>   PlotType Theta Series  Value
#> 1    ogive -6.00 Common 1.0078
#> 2    ogive -5.76 Common 1.0099
#> 3    ogive -5.52 Common 1.0125
#> 4    ogive -5.28 Common 1.0159
#> 5    ogive -5.04 Common 1.0202
#> 6    ogive -4.80 Common 1.0257

pathway_long <- plot_data(fit, type = "pathway", component = "pathway_long")
head(pathway_long[, c("Layer", "CurveGroup", "Theta", "Value")])
#>            Layer CurveGroup Theta    Value
#> 1 expected_score     Common -6.00 1.007757
#> 2 expected_score     Common -5.95 1.008154
#> 3 expected_score     Common -5.90 1.008571
#> 4 expected_score     Common -5.85 1.009010
#> 5 expected_score     Common -5.80 1.009471
#> 6 expected_score     Common -5.75 1.009956
pathway_fit <- plot_data(fit, type = "pathway", component = "fit_measures")
head(pathway_fit[, c("Facet", "Level", "Infit", "Outfit", "FitStatus")])
#>       Facet        Level     Infit    Outfit   FitStatus
#> 5 Criterion     Accuracy 0.8729305 0.8549072 within_band
#> 6 Criterion      Content 0.9993651 0.9921785 within_band
#> 7 Criterion     Language 1.0079938 1.0089226 within_band
#> 8 Criterion Organization 0.8328493 0.8059775 within_band
#> 1     Rater          R01 1.0600221 1.0481458 within_band
#> 2     Rater          R02 0.7297932 0.7494939 within_band

# Re-render one component with your own styling while keeping the
# package-generated data and interpretation metadata.
expected <- pathway_long[pathway_long$Layer == "expected_score", , drop = FALSE]
plot(expected$Theta, expected$Value, type = "l",
     xlab = "Theta", ylab = "Expected score",
     main = "Custom expected-score pathway")
abline(v = 0, lty = 2, col = "grey60")


info <- compute_information(fit, theta_points = 51)
sem_long <- plot_data(
  plot_information(info, type = "sem", draw = FALSE),
  component = "plot_long"
)
head(sem_long[, c("Metric", "Theta", "Value", "DisplayedByDefault")])
#>        Metric Theta    Value DisplayedByDefault
#> 1 Information -6.00 1.560503              FALSE
#> 2 Information -5.76 1.981827              FALSE
#> 3 Information -5.52 2.516210              FALSE
#> 4 Information -5.28 3.193553              FALSE
#> 5 Information -5.04 4.051378              FALSE
#> 6 Information -4.80 5.136583              FALSE
# }
```
