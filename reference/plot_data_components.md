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
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", maxit = 30)
plot_data_components(fit, type = "pathway")
#>       PlotName             Component                Role ObjectType Rows
#> 1  pathway_map              expected          table_data data.frame  241
#> 2  pathway_map                 steps          table_data data.frame    3
#> 3  pathway_map       endpoint_labels          table_data data.frame    1
#> 4  pathway_map     dominance_regions          table_data data.frame    4
#> 5  pathway_map          pathway_long        primary_data data.frame  245
#> 6  pathway_map   pathway_annotations          annotation data.frame    4
#> 7  pathway_map          fit_measures          fit_review data.frame    8
#> 8  pathway_map            fit_status summary_or_guidance data.frame    3
#> 9  pathway_map      curve_fit_status summary_or_guidance data.frame    1
#> 10 pathway_map    fit_measure_status summary_or_guidance data.frame    1
#> 11 pathway_map           score_range            settings     double   NA
#> 12 pathway_map                 title    scalar_or_vector  character   NA
#> 13 pathway_map              subtitle    scalar_or_vector  character   NA
#> 14 pathway_map                preset            settings  character   NA
#> 15 pathway_map                legend               style data.frame    2
#> 16 pathway_map       reference_lines          annotation data.frame    1
#> 17 pathway_map             plot_name    scalar_or_vector  character   NA
#> 18 pathway_map         fit_readiness          fit_review data.frame    5
#> 19 pathway_map interpretation_status summary_or_guidance  character   NA
#> 20 pathway_map   interpretation_note summary_or_guidance  character   NA
#>    Columns Length IsTabular                                          Accessor
#> 1        7      7      TRUE              plot_data(x, component = "expected")
#> 2        6      6      TRUE                 plot_data(x, component = "steps")
#> 3        7      7      TRUE       plot_data(x, component = "endpoint_labels")
#> 4        6      6      TRUE     plot_data(x, component = "dominance_regions")
#> 5       12     12      TRUE          plot_data(x, component = "pathway_long")
#> 6       13     13      TRUE   plot_data(x, component = "pathway_annotations")
#> 7       12     12      TRUE          plot_data(x, component = "fit_measures")
#> 8        3      3      TRUE            plot_data(x, component = "fit_status")
#> 9       14     14      TRUE      plot_data(x, component = "curve_fit_status")
#> 10       3      3      TRUE    plot_data(x, component = "fit_measure_status")
#> 11      NA      2     FALSE           plot_data(x, component = "score_range")
#> 12      NA      1     FALSE                 plot_data(x, component = "title")
#> 13      NA      1     FALSE              plot_data(x, component = "subtitle")
#> 14      NA      1     FALSE                plot_data(x, component = "preset")
#> 15       4      4      TRUE                plot_data(x, component = "legend")
#> 16       5      5      TRUE       plot_data(x, component = "reference_lines")
#> 17      NA      1     FALSE             plot_data(x, component = "plot_name")
#> 18       2      2      TRUE         plot_data(x, component = "fit_readiness")
#> 19      NA      1     FALSE plot_data(x, component = "interpretation_status")
#> 20      NA      1     FALSE   plot_data(x, component = "interpretation_note")
#>                                                                     Notes
#> 1                                                                        
#> 2                                                                        
#> 3                                                                        
#> 4                                                                        
#> 5        Best starting point for ggplot2, plotly, or Quarto re-rendering.
#> 6  Use with primary data to draw thresholds, labels, and reference lines.
#> 7                    Use to label or filter review-relevant plotted rows.
#> 8                    Use to label or filter review-relevant plotted rows.
#> 9                    Use to label or filter review-relevant plotted rows.
#> 10                           Use for captions, QA checks, or report text.
#> 11                                                                       
#> 12                                                                       
#> 13                                                                       
#> 14                                                                       
#> 15                 Use to reproduce color, line-type, or legend mappings.
#> 16 Use with primary data to draw thresholds, labels, and reference lines.
#> 17                                                                       
#> 18                                                                       
#> 19                           Use for captions, QA checks, or report text.
#> 20                           Use for captions, QA checks, or report text.
#>                                                                                                                               ColumnNames
#> 1                                                              Theta, ExpectedScore, ScoreVariance, Information, Slope, Model, CurveGroup
#> 2                                                                           CurveGroup, Step, StepIndex, Threshold, PathY, ThresholdLabel
#> 3                                                              Theta, ExpectedScore, ScoreVariance, Information, Slope, Model, CurveGroup
#> 4                                                                            CurveGroup, Category, Region, ThetaStart, ThetaEnd, ThetaMid
#> 5                          Layer, CurveGroup, Theta, Value, ValueName, Category, Step, StepIndex, Label, DisplayedByDefault, Model, Slope
#> 6                          AnnotationType, CurveGroup, Facet, Level, X, Y, Label, Measure, SE, FitStatus, Underfit, Overfit, ReviewReason
#> 7                             Facet, Level, Measure, SE, Infit, Outfit, InfitZSTD, OutfitZSTD, FitStatus, Underfit, Overfit, ReviewReason
#> 8                                                                                                                  Facet, FitStatus, Rows
#> 9  CurveGroup, Facet, Level, Measure, SE, Infit, Outfit, InfitZSTD, OutfitZSTD, FitStatus, Underfit, Overfit, ReviewReason, MatchedFitRow
#> 10                                                                                                             Available, Status, Message
#> 11                                                                                                                                       
#> 12                                                                                                                                       
#> 13                                                                                                                                       
#> 14                                                                                                                                       
#> 15                                                                                                          label, role, aesthetic, value
#> 16                                                                                                     axis, value, label, linetype, role
#> 17                                                                                                                                       
#> 18                                                                                                                         Domain, Status
#> 19                                                                                                                                       
#> 20                                                                                                                                       

curves <- category_curves_report(fit, theta_points = 51)
plot_data_components(curves, type = "category_probability")
#>           PlotName                Component                Role ObjectType Rows
#> 1  category_curves                     plot        primary_data  character   NA
#> 2  category_curves           expected_ogive          curve_data data.frame   51
#> 3  category_curves            probabilities          curve_data data.frame  204
#> 4  category_curves cumulative_probabilities          curve_data data.frame  408
#> 5  category_curves    cumulative_boundaries          table_data data.frame    3
#> 6  category_curves     cumulative_direction            settings  character   NA
#> 7  category_curves     category_information          curve_data data.frame  204
#> 8  category_curves          overview_panels summary_or_guidance data.frame    4
#> 9  category_curves                plot_long        primary_data data.frame  918
#> 10 category_curves         plot_annotations          annotation data.frame    5
#> 11 category_curves            curve_summary summary_or_guidance data.frame    5
#> 12 category_curves              curve_style               style data.frame   13
#> 13 category_curves           boundary_lines          annotation data.frame    3
#> 14 category_curves            plot_settings            settings data.frame    1
#> 15 category_curves                   preset            settings  character   NA
#> 16 category_curves                    title    scalar_or_vector  character   NA
#> 17 category_curves                 subtitle    scalar_or_vector  character   NA
#> 18 category_curves                   legend               style data.frame    1
#> 19 category_curves          reference_lines          annotation data.frame    5
#> 20 category_curves                plot_name    scalar_or_vector  character   NA
#>    Columns Length IsTabular
#> 1       NA      1     FALSE
#> 2        7      7      TRUE
#> 3       11     11      TRUE
#> 4        9      9      TRUE
#> 5       12     12      TRUE
#> 6       NA      1     FALSE
#> 7       11     11      TRUE
#> 8        3      3      TRUE
#> 9       15     15      TRUE
#> 10       5      5      TRUE
#> 11       7      7      TRUE
#> 12       4      4      TRUE
#> 13      12     12      TRUE
#> 14       6      6      TRUE
#> 15      NA      1     FALSE
#> 16      NA      1     FALSE
#> 17      NA      1     FALSE
#> 18       4      4      TRUE
#> 19       5      5      TRUE
#> 20      NA      1     FALSE
#>                                                Accessor
#> 1                      plot_data(x, component = "plot")
#> 2            plot_data(x, component = "expected_ogive")
#> 3             plot_data(x, component = "probabilities")
#> 4  plot_data(x, component = "cumulative_probabilities")
#> 5     plot_data(x, component = "cumulative_boundaries")
#> 6      plot_data(x, component = "cumulative_direction")
#> 7      plot_data(x, component = "category_information")
#> 8           plot_data(x, component = "overview_panels")
#> 9                 plot_data(x, component = "plot_long")
#> 10         plot_data(x, component = "plot_annotations")
#> 11            plot_data(x, component = "curve_summary")
#> 12              plot_data(x, component = "curve_style")
#> 13           plot_data(x, component = "boundary_lines")
#> 14            plot_data(x, component = "plot_settings")
#> 15                   plot_data(x, component = "preset")
#> 16                    plot_data(x, component = "title")
#> 17                 plot_data(x, component = "subtitle")
#> 18                   plot_data(x, component = "legend")
#> 19          plot_data(x, component = "reference_lines")
#> 20                plot_data(x, component = "plot_name")
#>                                                                     Notes
#> 1                                                                        
#> 2                                                                        
#> 3                                                                        
#> 4                                                                        
#> 5                                                                        
#> 6                                                                        
#> 7                                                                        
#> 8                            Use for captions, QA checks, or report text.
#> 9        Best starting point for ggplot2, plotly, or Quarto re-rendering.
#> 10 Use with primary data to draw thresholds, labels, and reference lines.
#> 11                           Use for captions, QA checks, or report text.
#> 12                 Use to reproduce color, line-type, or legend mappings.
#> 13 Use with primary data to draw thresholds, labels, and reference lines.
#> 14     Records resolved plotting options and aliases after normalization.
#> 15                                                                       
#> 16                                                                       
#> 17                                                                       
#> 18                 Use to reproduce color, line-type, or legend mappings.
#> 19 Use with primary data to draw thresholds, labels, and reference lines.
#> 20                                                                       
#>                                                                                                                                                                                                    ColumnNames
#> 1                                                                                                                                                                                                             
#> 2                                                                                                                                   Theta, ExpectedScore, ScoreVariance, Information, Slope, Model, CurveGroup
#> 3                                                             Theta, Probability, ExpectedScore, ScoreVariance, Information, CategoryInformation, CategoryInformationShare, Slope, Model, Category, CurveGroup
#> 4                                                                                              CurveGroup, Theta, Direction, BoundaryCategory, BoundaryOrder, CategorySet, CumulativeProbability, Model, Slope
#> 5  CurveGroup, BoundaryOrder, LowerOrEqualCategory, AboveCategory, ThresholdCategory, CumulativeDirection, TargetProbability, ThurstonianThreshold, InThetaRange, CrossingCount, BoundaryStatus, BoundaryLabel
#> 6                                                                                                                                                                                                             
#> 7                                                             CurveGroup, Theta, Category, Probability, ExpectedScore, ScoreVariance, Information, CategoryInformation, CategoryInformationShare, Slope, Model
#> 8                                                                                                                                                                               Panel, PlotType, DataComponent
#> 9                                            PlotType, Panel, CurveGroup, Theta, Series, Category, BoundaryCategory, BoundaryOrder, CategorySet, Direction, ValueName, Value, DisplayedByDefault, Model, Slope
#> 10                                                                                                                                                                AnnotationType, Axis, Value, Label, LineType
#> 11                                                                                                                                        PlotType, Panel, ValueName, Rows, Series, CurveGroups, DisplayedRows
#> 12                                                                                                                                                                            Series, Colour, LineType, Preset
#> 13 CurveGroup, BoundaryOrder, LowerOrEqualCategory, AboveCategory, ThresholdCategory, CumulativeDirection, TargetProbability, ThurstonianThreshold, InThetaRange, CrossingCount, BoundaryStatus, BoundaryLabel
#> 14                                                                                                              RequestedType, PlotType, Preset, CumulativeDirection, ShowCumulativeBoundaries, BoundaryStatus
#> 15                                                                                                                                                                                                            
#> 16                                                                                                                                                                                                            
#> 17                                                                                                                                                                                                            
#> 18                                                                                                                                                                               label, role, aesthetic, value
#> 19                                                                                                                                                                          axis, value, label, linetype, role
#> 20                                                                                                                                                                                                            

toy$ResponseTime <- 10 + seq_len(nrow(toy)) %% 6 + as.numeric(toy$Score)
rt <- response_time_review(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  time = "ResponseTime"
)
plot_data_components(plot_response_time_review(rt, draw = FALSE))
#>                PlotName       Component                Role ObjectType Rows
#> 1  response_time_review           table        primary_data data.frame  768
#> 2  response_time_review      thresholds            settings data.frame    2
#> 3  response_time_review        overview summary_or_guidance data.frame    1
#> 4  response_time_review           notes summary_or_guidance  character   NA
#> 5  response_time_review            type    scalar_or_vector  character   NA
#> 6  response_time_review           facet    scalar_or_vector  character   NA
#> 7  response_time_review           top_n            settings    integer   NA
#> 8  response_time_review           title    scalar_or_vector  character   NA
#> 9  response_time_review        subtitle    scalar_or_vector  character   NA
#> 10 response_time_review          preset            settings  character   NA
#> 11 response_time_review          legend               style data.frame    3
#> 12 response_time_review reference_lines          annotation data.frame    2
#> 13 response_time_review       plot_name    scalar_or_vector  character   NA
#>    Columns Length IsTabular                                    Accessor
#> 1        7      7      TRUE           plot_data(x, component = "table")
#> 2        4      4      TRUE      plot_data(x, component = "thresholds")
#> 3       16     16      TRUE        plot_data(x, component = "overview")
#> 4       NA      2     FALSE           plot_data(x, component = "notes")
#> 5       NA      1     FALSE            plot_data(x, component = "type")
#> 6       NA      1     FALSE           plot_data(x, component = "facet")
#> 7       NA      1     FALSE           plot_data(x, component = "top_n")
#> 8       NA      1     FALSE           plot_data(x, component = "title")
#> 9       NA      1     FALSE        plot_data(x, component = "subtitle")
#> 10      NA      1     FALSE          plot_data(x, component = "preset")
#> 11       4      4      TRUE          plot_data(x, component = "legend")
#> 12       5      5      TRUE plot_data(x, component = "reference_lines")
#> 13      NA      1     FALSE       plot_data(x, component = "plot_name")
#>                                                                     Notes
#> 1                                                                        
#> 2                                                                        
#> 3                            Use for captions, QA checks, or report text.
#> 4                            Use for captions, QA checks, or report text.
#> 5                                                                        
#> 6                                                                        
#> 7                                                                        
#> 8                                                                        
#> 9                                                                        
#> 10                                                                       
#> 11                 Use to reproduce color, line-type, or legend mappings.
#> 12 Use with primary data to draw thresholds, labels, and reference lines.
#> 13                                                                       
#>                                                                                                                                                                                             ColumnNames
#> 1                                                                                                                                                Row, Person, Time, LogTime, RapidFlag, SlowFlag, Score
#> 2                                                                                                                                                                     Threshold, Value, Basis, TimeUnit
#> 3  Rows, ValidRows, DroppedRows, Persons, Facets, TimeColumn, ScoreColumn, TimeUnit, MedianTime, MeanLogTime, RapidThreshold, SlowThreshold, RapidRate, SlowRate, FlaggedGroups, InterpretationBoundary
#> 4                                                                                                                                                                                                      
#> 5                                                                                                                                                                                                      
#> 6                                                                                                                                                                                                      
#> 7                                                                                                                                                                                                      
#> 8                                                                                                                                                                                                      
#> 9                                                                                                                                                                                                      
#> 10                                                                                                                                                                                                     
#> 11                                                                                                                                                                        label, role, aesthetic, value
#> 12                                                                                                                                                                   axis, value, label, linetype, role
#> 13                                                                                                                                                                                                     
# }
```
