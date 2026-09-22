# List reusable components in mfrmr plot data

`plot_data_components()` is a companion to
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
It returns a compact table that tells users which plot-data components
are available, what shape they have, and which ones are most useful for
custom graphics, dashboards, or report assembly.

## Usage

``` r
plot_data_components(x, type = NULL, ...)
```

## Arguments

- x:

  An `mfrm_plot_data` object, or a fitted/report/review object with a
  `plot(..., draw = FALSE)` method.

- type:

  Optional plot type passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) when `x` is
  not already an `mfrm_plot_data` object.

- ...:

  Additional arguments passed to `plot(..., draw = FALSE)` when `x` is
  not already an `mfrm_plot_data` object.

## Value

A data frame with one row per reusable plot-data component.

## Examples

``` r
# \donttest{
# Load the package and example ratings
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

# Discover which tables the default Wright map provides without drawing it
plot_data_components(fit)
#>      PlotName             Component                Role     ObjectType Rows
#> 1  wright_map          wright_style               style      character   NA
#> 2  wright_map              renderer    scalar_or_vector      character   NA
#> 3  wright_map       visual_contract    scalar_or_vector      character   NA
#> 4  wright_map                person          table_data     data.frame   48
#> 5  wright_map     person_exclusions          table_data     data.frame    0
#> 6  wright_map           person_hist            metadata list:histogram   NA
#> 7  wright_map          person_stats          table_data     data.frame    1
#> 8  wright_map             locations          table_data     data.frame   12
#> 9  wright_map          label_points          table_data     data.frame   12
#> 10 wright_map         group_summary summary_or_guidance     data.frame    3
#> 11 wright_map          group_levels            settings      character   NA
#> 12 wright_map               y_range            settings         double   NA
#> 13 wright_map      display_settings            settings     data.frame    1
#> 14 wright_map           label_limit    scalar_or_vector        integer   NA
#> 15 wright_map             retention          table_data     data.frame    3
#> 16 wright_map        retention_note summary_or_guidance      character   NA
#> 17 wright_map                 title    scalar_or_vector      character   NA
#> 18 wright_map              subtitle    scalar_or_vector      character   NA
#> 19 wright_map               show_ci    scalar_or_vector        logical   NA
#> 20 wright_map   uncertainty_display    scalar_or_vector      character   NA
#> 21 wright_map                 group    scalar_or_vector           NULL   NA
#> 22 wright_map                preset            settings      character   NA
#> 23 wright_map                legend               style     data.frame    5
#> 24 wright_map       reference_lines          annotation     data.frame    1
#> 25 wright_map        scale_contract          table_data     data.frame    1
#> 26 wright_map             plot_name    scalar_or_vector      character   NA
#> 27 wright_map         fit_readiness          fit_review     data.frame    6
#> 28 wright_map interpretation_status summary_or_guidance      character   NA
#> 29 wright_map   interpretation_note summary_or_guidance      character   NA
#> 30 wright_map               display            metadata      list:list   NA
#> 31 wright_map                 notes summary_or_guidance     data.frame    3
#>    Columns Length IsTabular                                          Accessor
#> 1       NA      1     FALSE          plot_data(x, component = "wright_style")
#> 2       NA      1     FALSE              plot_data(x, component = "renderer")
#> 3       NA      1     FALSE       plot_data(x, component = "visual_contract")
#> 4       22     22      TRUE                plot_data(x, component = "person")
#> 5       22     22      TRUE     plot_data(x, component = "person_exclusions")
#> 6        6      6     FALSE           plot_data(x, component = "person_hist")
#> 7        7      7      TRUE          plot_data(x, component = "person_stats")
#> 8       37     37      TRUE             plot_data(x, component = "locations")
#> 9       43     43      TRUE          plot_data(x, component = "label_points")
#> 10      16     16      TRUE         plot_data(x, component = "group_summary")
#> 11      NA      3     FALSE          plot_data(x, component = "group_levels")
#> 12      NA      2     FALSE               plot_data(x, component = "y_range")
#> 13       8      8      TRUE      plot_data(x, component = "display_settings")
#> 14      NA      1     FALSE           plot_data(x, component = "label_limit")
#> 15       6      6      TRUE             plot_data(x, component = "retention")
#> 16      NA      1     FALSE        plot_data(x, component = "retention_note")
#> 17      NA      1     FALSE                 plot_data(x, component = "title")
#> 18      NA      1     FALSE              plot_data(x, component = "subtitle")
#> 19      NA      1     FALSE               plot_data(x, component = "show_ci")
#> 20      NA      1     FALSE   plot_data(x, component = "uncertainty_display")
#> 21      NA      0     FALSE                 plot_data(x, component = "group")
#> 22      NA      1     FALSE                plot_data(x, component = "preset")
#> 23       4      4      TRUE                plot_data(x, component = "legend")
#> 24       5      5      TRUE       plot_data(x, component = "reference_lines")
#> 25      15     15      TRUE        plot_data(x, component = "scale_contract")
#> 26      NA      1     FALSE             plot_data(x, component = "plot_name")
#> 27       2      2      TRUE         plot_data(x, component = "fit_readiness")
#> 28      NA      1     FALSE plot_data(x, component = "interpretation_status")
#> 29      NA      1     FALSE   plot_data(x, component = "interpretation_note")
#> 30       2      2     FALSE               plot_data(x, component = "display")
#> 31       2      2      TRUE                 plot_data(x, component = "notes")
#>                                                                     Notes
#> 1                                                                        
#> 2                                                                        
#> 3                                                                        
#> 4                                                                        
#> 5                                                                        
#> 6                                                                        
#> 7                                                                        
#> 8                                                                        
#> 9                                                                        
#> 10                           Use for captions, QA checks, or report text.
#> 11                                                                       
#> 12                                                                       
#> 13                                                                       
#> 14                                                                       
#> 15                                                                       
#> 16                           Use for captions, QA checks, or report text.
#> 17                                                                       
#> 18                                                                       
#> 19                                                                       
#> 20                                                                       
#> 21                                                                       
#> 22                                                                       
#> 23                 Use to reproduce color, line-type, or legend mappings.
#> 24 Use with primary data to draw thresholds, labels, and reference lines.
#> 25                                                                       
#> 26                                                                       
#> 27                                                                       
#> 28                           Use for captions, QA checks, or report text.
#> 29                           Use for captions, QA checks, or report text.
#> 30                                                                       
#> 31                           Use for captions, QA checks, or report text.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ColumnNames
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
#> 4                                                                                                                                                                               Person, Estimate, SD, PosteriorSD, SE, Extreme, PrimaryEstimate, OptimizerEstimate, DisplayEstimate, DisplayAdjustment, ParameterStatus, BoundaryDirection, ResponseExtreme, ResponseRows, WeightedResponseTotal, PrimaryEstimateBasis, OptimizerEstimateUse, ReasonCodes, ReadinessContractVersion, SourceFitReadiness, SourceInferenceReady, EstimateUse
#> 5                                                                                                                                                                               Person, Estimate, SD, PosteriorSD, SE, Extreme, PrimaryEstimate, OptimizerEstimate, DisplayEstimate, DisplayAdjustment, ParameterStatus, BoundaryDirection, ResponseExtreme, ResponseRows, WeightedResponseTotal, PrimaryEstimateBasis, OptimizerEstimateUse, ReasonCodes, ReadinessContractVersion, SourceFitReadiness, SourceInferenceReady, EstimateUse
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           breaks, counts, density, mids, xname, equidist
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                         N, ReviewExcludedN, FiniteN, BoundaryExcludedN, Mean, Median, SD
#> 8                                                                    Group, Label, PlotType, Estimate, SE, CI_Level, SE_Method, PrecisionTier, SupportsFormalInference, SEUse, CIBasis, CIUse, CIEligible, CILabel, Measure_Source, CI_Lower, CI_Upper, Step, StepIndex, BoundarySeparated, XBase, X, OriginalEstimate, BelowRange, AboveRange, DisplayEstimate, DisplayLabel, OriginalCI_Lower, OriginalCI_Upper, DisplayCI_Lower, DisplayCI_Upper, CIClippedLower, CIClippedUpper, CIClipped, BoundaryEnd, CISuppressed, CIDisplayStatus
#> 9  Group, Label, PlotType, Estimate, SE, CI_Level, SE_Method, PrecisionTier, SupportsFormalInference, SEUse, CIBasis, CIUse, CIEligible, CILabel, Measure_Source, CI_Lower, CI_Upper, Step, StepIndex, BoundarySeparated, XBase, X, OriginalEstimate, BelowRange, AboveRange, DisplayEstimate, DisplayLabel, OriginalCI_Lower, OriginalCI_Upper, DisplayCI_Lower, DisplayCI_Upper, CIClippedLower, CIClippedUpper, CIClipped, BoundaryEnd, CISuppressed, CIDisplayStatus, LabelY, LabelSide, LabelX, LabelHjust, LabelText, LabelDisplaced
#> 10                                                                                                                                                                                                                                                                                                                                                                                           Group, PlotType, Min, Q1, Median, Q3, Max, DisplayMin, DisplayQ1, DisplayMedian, DisplayQ3, DisplayMax, N, XBase, TargetGap, DisplayTargetGap
#> 11                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 12                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 13                                                                                                                                                                                                                                                                                                                                                                                                       Renderer, LowerLogit, UpperLogit, AutoRangePolicy, BoundaryLevelsAtEnds, CIClippedCount, BoundaryCIEndpointCount, CIDisplayPolicy
#> 14                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 15                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Component, Shown, Total, Omitted, RequestedTopN, Complete
#> 16                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 17                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 18                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 19                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 20                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 21                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 22                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 23                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           label, role, aesthetic, value
#> 24                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      axis, value, label, linetype, role
#> 25                                                                                                                                                                                                                                                Model, Method, CoordinateBasis, PopulationSD, SlopeBasis, GpcmModelFamily, GpcmSlopeAction, GpcmSlopeComposition, GpcmLatentDimensionCount, GpcmMmlIdentification, GpcmEstimatorFamily, GpcmStatisticalPenalty, GpcmFiniteParameterBox, GpcmExtremePersonPolicy, FixedLatentSDSlopeField
#> 26                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 27                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          Domain, Status
#> 28                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 29                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#> 30                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  show_title, show_notes
#> 31                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Type, Text

# Extract one of the listed components
locations <- plot_data(fit, component = "locations")
head(locations)
#> # A tibble: 6 × 37
#>   Group Label PlotType    Estimate    SE CI_Level SE_Method        PrecisionTier
#>   <fct> <chr> <chr>          <dbl> <dbl>    <dbl> <chr>            <chr>        
#> 1 Rater R01   Facet level   -0.606 0.181     0.95 Observation-tab… exploratory  
#> 2 Rater R02   Facet level   -0.382 0.166     0.95 Observation-tab… exploratory  
#> 3 Rater R04   Facet level    0.180 0.185     0.95 Observation-tab… exploratory  
#> 4 Rater R05   Facet level    0.184 0.199     0.95 Observation-tab… exploratory  
#> 5 Rater R03   Facet level    0.212 0.179     0.95 Observation-tab… exploratory  
#> 6 Rater R06   Facet level    0.412 0.219     0.95 Observation-tab… exploratory  
#> # ℹ 29 more variables: SupportsFormalInference <lgl>, SEUse <chr>,
#> #   CIBasis <chr>, CIUse <chr>, CIEligible <lgl>, CILabel <chr>,
#> #   Measure_Source <chr>, CI_Lower <dbl>, CI_Upper <dbl>, Step <chr>,
#> #   StepIndex <int>, BoundarySeparated <lgl>, XBase <dbl>, X <dbl>,
#> #   OriginalEstimate <dbl>, BelowRange <lgl>, AboveRange <lgl>,
#> #   DisplayEstimate <dbl>, DisplayLabel <chr>, OriginalCI_Lower <dbl>,
#> #   OriginalCI_Upper <dbl>, DisplayCI_Lower <dbl>, DisplayCI_Upper <dbl>, …

# A different plot type has different reusable tables
plot_data_components(fit, type = "ccc")
#>                          PlotName             Component                Role
#> 1  category_characteristic_curves         probabilities          curve_data
#> 2  category_characteristic_curves           curve_basis          curve_data
#> 3  category_characteristic_curves                 title    scalar_or_vector
#> 4  category_characteristic_curves              subtitle    scalar_or_vector
#> 5  category_characteristic_curves                preset            settings
#> 6  category_characteristic_curves                legend               style
#> 7  category_characteristic_curves       reference_lines          annotation
#> 8  category_characteristic_curves        scale_contract          table_data
#> 9  category_characteristic_curves             plot_name    scalar_or_vector
#> 10 category_characteristic_curves         fit_readiness          fit_review
#> 11 category_characteristic_curves interpretation_status summary_or_guidance
#> 12 category_characteristic_curves   interpretation_note summary_or_guidance
#> 13 category_characteristic_curves               display            metadata
#> 14 category_characteristic_curves                 notes summary_or_guidance
#>    ObjectType Rows Columns Length IsTabular
#> 1  data.frame  964      13     13      TRUE
#> 2  data.frame    1       3      3      TRUE
#> 3   character   NA      NA      1     FALSE
#> 4   character   NA      NA      1     FALSE
#> 5   character   NA      NA      1     FALSE
#> 6  data.frame    4       4      4      TRUE
#> 7  data.frame    1       5      5      TRUE
#> 8  data.frame    1      15     15      TRUE
#> 9   character   NA      NA      1     FALSE
#> 10 data.frame    6       2      2      TRUE
#> 11  character   NA      NA      1     FALSE
#> 12  character   NA      NA      1     FALSE
#> 13  list:list   NA       2      2     FALSE
#> 14 data.frame    3       2      2      TRUE
#>                                             Accessor
#> 1          plot_data(x, component = "probabilities")
#> 2            plot_data(x, component = "curve_basis")
#> 3                  plot_data(x, component = "title")
#> 4               plot_data(x, component = "subtitle")
#> 5                 plot_data(x, component = "preset")
#> 6                 plot_data(x, component = "legend")
#> 7        plot_data(x, component = "reference_lines")
#> 8         plot_data(x, component = "scale_contract")
#> 9              plot_data(x, component = "plot_name")
#> 10         plot_data(x, component = "fit_readiness")
#> 11 plot_data(x, component = "interpretation_status")
#> 12   plot_data(x, component = "interpretation_note")
#> 13               plot_data(x, component = "display")
#> 14                 plot_data(x, component = "notes")
#>                                                                     Notes
#> 1                                                                        
#> 2                                                                        
#> 3                                                                        
#> 4                                                                        
#> 5                                                                        
#> 6                  Use to reproduce color, line-type, or legend mappings.
#> 7  Use with primary data to draw thresholds, labels, and reference lines.
#> 8                                                                        
#> 9                                                                        
#> 10                                                                       
#> 11                           Use for captions, QA checks, or report text.
#> 12                           Use for captions, QA checks, or report text.
#> 13                                                                       
#> 14                           Use for captions, QA checks, or report text.
#>                                                                                                                                                                                                                                                                                 ColumnNames
#> 1                                                                                                             Theta, Probability, ExpectedScore, ScoreVariance, Information, CategoryInformation, CategoryInformationShare, Slope, Model, Category, CurveGroup, CurveBasis, PredictorOffset
#> 2                                                                                                                                                                                                                                                  CurveBasis, PredictorOffset, Description
#> 3                                                                                                                                                                                                                                                                                          
#> 4                                                                                                                                                                                                                                                                                          
#> 5                                                                                                                                                                                                                                                                                          
#> 6                                                                                                                                                                                                                                                             label, role, aesthetic, value
#> 7                                                                                                                                                                                                                                                        axis, value, label, linetype, role
#> 8  Model, Method, CoordinateBasis, PopulationSD, SlopeBasis, GpcmModelFamily, GpcmSlopeAction, GpcmSlopeComposition, GpcmLatentDimensionCount, GpcmMmlIdentification, GpcmEstimatorFamily, GpcmStatisticalPenalty, GpcmFiniteParameterBox, GpcmExtremePersonPolicy, FixedLatentSDSlopeField
#> 9                                                                                                                                                                                                                                                                                          
#> 10                                                                                                                                                                                                                                                                           Domain, Status
#> 11                                                                                                                                                                                                                                                                                         
#> 12                                                                                                                                                                                                                                                                                         
#> 13                                                                                                                                                                                                                                                                   show_title, show_notes
#> 14                                                                                                                                                                                                                                                                               Type, Text
# }
```
