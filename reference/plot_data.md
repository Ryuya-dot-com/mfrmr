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
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", maxit = 30)

wright_plot_data <- plot_data(fit, type = "wright")
names(wright_plot_data)
#>  [1] "wright_style"          "renderer"              "visual_contract"      
#>  [4] "person"                "person_hist"           "person_stats"         
#>  [7] "locations"             "label_points"          "group_summary"        
#> [10] "group_levels"          "y_range"               "display_settings"     
#> [13] "label_limit"           "retention"             "retention_note"       
#> [16] "title"                 "subtitle"              "show_ci"              
#> [19] "uncertainty_display"   "group"                 "preset"               
#> [22] "legend"                "reference_lines"       "plot_name"            
#> [25] "fit_readiness"         "interpretation_status" "interpretation_note"  

wright_table <- plot_data(fit, type = "wright", component = "locations")
head(wright_table)
#> # A tibble: 6 × 30
#>   Group     Label     PlotType Estimate     SE CI_Level SE_Method Measure_Source
#>   <fct>     <chr>     <chr>       <dbl>  <dbl>    <dbl> <chr>     <chr>         
#> 1 Rater     R02       Facet l…  -0.309  0.0942     0.95 Observat… fit + observa…
#> 2 Rater     R01       Facet l…  -0.184  0.0938     0.95 Observat… fit + observa…
#> 3 Rater     R03       Facet l…   0.180  0.0937     0.95 Observat… fit + observa…
#> 4 Rater     R04       Facet l…   0.313  0.0941     0.95 Observat… fit + observa…
#> 5 Criterion Content   Facet l…  -0.390  0.0946     0.95 Observat… fit + observa…
#> 6 Criterion Organiza… Facet l…   0.0649 0.0936     0.95 Observat… fit + observa…
#> # ℹ 22 more variables: CI_Lower <dbl>, CI_Upper <dbl>, Step <chr>,
#> #   StepIndex <int>, BoundarySeparated <lgl>, XBase <dbl>, X <dbl>,
#> #   OriginalEstimate <dbl>, BelowRange <lgl>, AboveRange <lgl>,
#> #   DisplayEstimate <dbl>, DisplayLabel <chr>, OriginalCI_Lower <dbl>,
#> #   OriginalCI_Upper <dbl>, DisplayCI_Lower <dbl>, DisplayCI_Upper <dbl>,
#> #   CIClippedLower <lgl>, CIClippedUpper <lgl>, CIClipped <lgl>,
#> #   BoundaryEnd <chr>, CISuppressed <lgl>, CIDisplayStatus <chr>

curves <- category_curves_report(fit, theta_points = 51)
curve_long <- plot_data(curves, component = "plot_long")
head(curve_long[, c("PlotType", "Theta", "Series", "Value")])
#>   PlotType Theta Series  Value
#> 1    ogive -6.00 Common 1.0084
#> 2    ogive -5.76 Common 1.0106
#> 3    ogive -5.52 Common 1.0135
#> 4    ogive -5.28 Common 1.0171
#> 5    ogive -5.04 Common 1.0217
#> 6    ogive -4.80 Common 1.0276

pathway_long <- plot_data(fit, type = "pathway", component = "pathway_long")
head(pathway_long[, c("Layer", "CurveGroup", "Theta", "Value")])
#>            Layer CurveGroup Theta    Value
#> 1 expected_score     Common -6.00 1.008368
#> 2 expected_score     Common -5.95 1.008796
#> 3 expected_score     Common -5.90 1.009245
#> 4 expected_score     Common -5.85 1.009717
#> 5 expected_score     Common -5.80 1.010214
#> 6 expected_score     Common -5.75 1.010735
pathway_fit <- plot_data(fit, type = "pathway", component = "fit_measures")
head(pathway_fit[, c("Facet", "Level", "Infit", "Outfit", "FitStatus")])
#>       Facet        Level     Infit    Outfit   FitStatus
#> 5 Criterion     Accuracy 0.9449289 0.9263038 within_band
#> 6 Criterion      Content 0.9404034 1.0039236 within_band
#> 7 Criterion     Language 1.0231425 1.0169830 within_band
#> 8 Criterion Organization 0.8029402 0.7948371     overfit
#> 1     Rater          R01 0.9798296 0.9701823 within_band
#> 2     Rater          R02 0.8528519 0.9143938 within_band

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
#>        Metric Theta     Value DisplayedByDefault
#> 1 Information -6.00  6.802651              FALSE
#> 2 Information -5.76  8.630228              FALSE
#> 3 Information -5.52 10.942778              FALSE
#> 4 Information -5.28 13.865339              FALSE
#> 5 Information -5.04 17.552972              FALSE
#> 6 Information -4.80 22.196632              FALSE
# }
```
