# Plot a diagnostic-screening simulation study

Builds an integrated visual summary from
[`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md)
output. The default view combines legacy residual, strict marginal,
strict pairwise, strict combined, and optional report-index review rates
so simulation results can be inspected in one operating-characteristic
surface.

## Usage

``` r
# S3 method for class 'mfrm_diagnostic_screening'
plot(
  x,
  type = c("overview", "report", "contrast", "runtime"),
  metric = NULL,
  x_var = c("n_person", "n_rater", "n_criterion", "raters_per_person"),
  group_var = NULL,
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md).

- type:

  Plot family. `"overview"` combines screening and optional report rates
  or counts. `"report"` focuses on
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  review signals. `"contrast"` plots
  misspecification-minus-well-specified contrasts. `"runtime"` plots
  elapsed-time summaries.

- metric:

  Metric family. Use `NULL` or `"auto"` for the default within each
  `type`. Supported values are documented by error messages and include
  `"rate"`, `"count"`, `"magnitude"`, `"elapsed"`, and
  `"per_observation"` depending on `type`.

- x_var:

  Design variable for the horizontal axis. Public design aliases from a
  simulation specification are accepted.

- group_var:

  Optional additional design variable to include in group labels. Public
  design aliases are accepted.

- draw:

  Logical; if `FALSE`, return the plot-data bundle without drawing.

- ...:

  Reserved for generic compatibility.

## Value

An `mfrm_plot_data` object with reusable metadata, a long-form
`plot_long` table, and interpretation handoff tables (`overview`,
`reading_order`, `next_actions`, `reporting_notes`, and
`figure_recipes`). When `draw = TRUE`, the object is returned invisibly
after drawing.

## Examples

``` r
# \donttest{
diag_eval <- evaluate_mfrm_diagnostic_screening(
  design = list(person = 10, rater = 2, criterion = 2, assignment = 2),
  reps = 1,
  maxit = 30,
  include_report = TRUE,
  seed = 123
)
#> Warning: Category support is retained but requires review: at least one fitted or local scope contains an empty or singleton category/transition cell. The fit may be inspected, but category-information strength has not been certified; inspect `fit$data_review$category_support` before inference.
#> Warning: Category support is retained but requires review: at least one fitted or local scope contains an empty or singleton category/transition cell. The fit may be inspected, but category-information strength has not been certified; inspect `fit$data_review$category_support` before inference.
plot(diag_eval, type = "overview", draw = FALSE)
#> <mfrm_plot_data>
#>   name     : diagnostic_screening
#>   title    : MFRM diagnostic screening overview
#>   subtitle : Metric family: rate
#>   data     :
#>     $type : character [1]
#>     $metric : character [1]
#>     $x_var : character [1]
#>     $x_label : character [1]
#>     $group_var : NULL
#>     $group_label : NULL
#>     $design_variable_aliases : character [4]
#>     $design_descriptor : data.frame [4 x 6]
#>     $planning_scope : list (14 slots)
#>     $planning_constraints : list (5 slots)
#>     $planning_schema : list (51 slots)
#>     $gpcm_boundary : data.frame [0 x 0]
#>     $overview : data.frame [1 x 13]
#>     $reading_order : data.frame [10 x 5]
#>     $next_actions : data.frame [6 x 7]
#>     $reporting_notes : data.frame [6 x 4]
#>     $figure_recipes : data.frame [5 x 10]
#>     $source_tables : character [3]
#>     $signals : character [7]
#>     $interpretation_note : character [1]
#>     $plot_long : data.frame [14 x 57]
#>     $plot_table : data.frame [14 x 57]
#>     $plot_name : character [1]
#>   legend   : 4 entries
#>   ref lines: 0
#> Re-render via ggplot2 / plotly using `x$data`; or pass the
#> originating `draw = FALSE` plot helper its inverse to draw it.
plot_data(diag_eval, type = "overview", component = "plot_long")
#> # A tibble: 14 × 57
#>    design_id Scenario       ScenarioClass Model DependenceFacet n_person n_rater
#>    <chr>     <chr>          <chr>         <chr> <chr>              <int>   <int>
#>  1 V01       local_depende… context_shar… RSM   Criterion             10       2
#>  2 V01       local_depende… context_shar… RSM   Criterion             10       2
#>  3 V01       local_depende… context_shar… RSM   Criterion             10       2
#>  4 V01       local_depende… context_shar… RSM   Criterion             10       2
#>  5 V01       local_depende… context_shar… RSM   Criterion             10       2
#>  6 V01       local_depende… context_shar… RSM   Criterion             10       2
#>  7 V01       local_depende… context_shar… RSM   Criterion             10       2
#>  8 V01       well_specified null_referen… RSM   Criterion             10       2
#>  9 V01       well_specified null_referen… RSM   Criterion             10       2
#> 10 V01       well_specified null_referen… RSM   Criterion             10       2
#> 11 V01       well_specified null_referen… RSM   Criterion             10       2
#> 12 V01       well_specified null_referen… RSM   Criterion             10       2
#> 13 V01       well_specified null_referen… RSM   Criterion             10       2
#> 14 V01       well_specified null_referen… RSM   Criterion             10       2
#> # ℹ 50 more variables: n_criterion <int>, raters_per_person <int>, Reps <int>,
#> #   RunOKRate <dbl>, ConvergenceRate <dbl>, MeanElapsedSec <dbl>,
#> #   MeanLegacyMeanAbsZ <dbl>, MeanLegacyFlaggedLevels <dbl>,
#> #   LegacyAnyFlagRate <dbl>, MeanMarginalOverallRMSD <dbl>,
#> #   MeanMarginalMaxAbsStdResidual <dbl>, MeanMarginalFlaggedGroups <dbl>,
#> #   MarginalAnyFlagRate <dbl>, MeanPairwiseFlaggedLevelPairs <dbl>,
#> #   PairwiseAnyFlagRate <dbl>, PairwiseAvailabilityRate <dbl>, …
plot_data(diag_eval, type = "overview", component = "next_actions")
#>   Priority                           Area Status
#> 1        1              Replication count review
#> 2        2 Run completion and convergence review
#> 3        3       Screening interpretation     ok
#> 4        4             Scenario contrasts     ok
#> 5        5           Report-index signals     ok
#> 6        6 Appendix and plot-data handoff     ok
#>                                                                                                    Evidence
#> 1                                                                                                 Reps = 1.
#> 2                                                               RunOKRate = 1.000; ConvergenceRate = 0.000.
#> 3                                                  scenario_summary rows = 2; performance_summary rows = 2.
#> 4                                                                               scenario_contrast rows = 1.
#> 5                                                                           report_signal_summary rows = 2.
#> 6 summary tables and draw-free plot-data tables are available through the package-wide bundle/export route.
#>                                                                                                             Action
#> 1 Treat this as an initial screening run; increase `reps` before interpreting operating characteristics as stable.
#> 2                     Inspect object$results for Error, RunOK, and Converged before summarizing scenario behavior.
#> 3          Read scenario_summary and performance_summary together before making legacy-vs-strict screening claims.
#> 4      Use scenario_contrast to describe misspecification-minus-baseline shifts, with the baseline scenario named.
#> 5                   Use report_signal_summary to prioritize report text review, not as a diagnostic adequacy test.
#> 6               Use build_summary_table_bundle() or export_summary_appendix(); use plot_data() for custom figures.
#>                                                                                                                                         Route
#> 1                                                                                              evaluate_mfrm_diagnostic_screening(reps = ...)
#> 2                                                                    diag_eval$results[, c("Scenario", "rep", "RunOK", "Converged", "Error")]
#> 3                                                                 summary(diag_eval)$scenario_summary; summary(diag_eval)$performance_summary
#> 4                                                                                                        summary(diag_eval)$scenario_contrast
#> 5                                                                                                    summary(diag_eval)$report_signal_summary
#> 6 build_summary_table_bundle(diag_eval); export_summary_appendix(diag_eval); plot_data(diag_eval, type = "overview", component = "plot_long")
#>                                                                                      ReportingBoundary
#> 1                              Replication count affects Monte Carlo stability and should be reported.
#> 2 Failed or non-converged runs are design/runtime evidence, not evidence about diagnostic sensitivity.
#> 3            Screening readouts compare operating behavior; they are not calibrated inferential tests.
#> 4                Contrasts are descriptive and conditional on the evaluated design grid and scenarios.
#> 5                        Report-index signals are reporting-layer prompts, not extra diagnostic tests.
#> 6                      Exports and plot data are presentation handoffs over the same summary evidence.
plot_data(diag_eval, type = "overview", component = "figure_recipes")
#>                   FigureID                    RecommendedUse
#> 1           overview_rates   main_text_or_primary_supplement
#> 2          overview_counts     supplement_or_quality_control
#> 3      report_review_rates        reporting_layer_supplement
#> 4 scenario_contrast_counts        misspecification_follow_up
#> 5          runtime_elapsed methods_or_computational_appendix
#>                                                                                                                     PrimaryQuestion
#> 1 How often do legacy, strict marginal, strict pairwise, strict combined, and optional report-review screens fire across scenarios?
#> 2                    How many levels, groups, pairs, or report-review signals are accumulated under each scenario/design condition?
#> 3            When report signals were retained, how often does the reporting layer route fit, precision, or misfit areas to review?
#> 4                              How much do misspecification scenarios shift flagged counts relative to the well-specified baseline?
#> 5                        How much elapsed time does the diagnostic-screening workflow require under each design/scenario condition?
#>                                                              PlotCall
#> 1   plot(diag_eval, type = "overview", metric = "rate", draw = FALSE)
#> 2  plot(diag_eval, type = "overview", metric = "count", draw = FALSE)
#> 3     plot(diag_eval, type = "report", metric = "rate", draw = FALSE)
#> 4  plot(diag_eval, type = "contrast", metric = "count", draw = FALSE)
#> 5 plot(diag_eval, type = "runtime", metric = "elapsed", draw = FALSE)
#>                                                                          PlotDataCall
#> 1   plot_data(diag_eval, type = "overview", metric = "rate", component = "plot_long")
#> 2  plot_data(diag_eval, type = "overview", metric = "count", component = "plot_long")
#> 3     plot_data(diag_eval, type = "report", metric = "rate", component = "plot_long")
#> 4  plot_data(diag_eval, type = "contrast", metric = "count", component = "plot_long")
#> 5 plot_data(diag_eval, type = "runtime", metric = "elapsed", component = "plot_long")
#>          SummaryTable
#> 1  plot_overview_rate
#> 2 plot_overview_count
#> 3    plot_report_rate
#> 4 plot_contrast_count
#> 5        plot_runtime
#>                                                                    DisplaySuggestion
#> 1          Line or point plot by design variable; facet or color by scenario/signal.
#> 2        Small-multiple count plot or appendix table when raw signal burden matters.
#> 3    Focused report-readiness panel; suppress when include_report was not requested.
#> 4 Diverging or signed count display with the baseline scenario named in the caption.
#> 5   Line or point plot with units stated as seconds or seconds per 100 observations.
#>                                                                                             CaptionFocus
#> 1 Describe operating-characteristic signal rates and identify whether report-review rates were included.
#> 2                           Describe signal burden, not statistical significance or diagnostic adequacy.
#> 3                     Describe reporting-layer review routing, not model validity or diagnostic success.
#> 4                       Describe misspecification-minus-baseline deltas and name the evaluated baseline.
#> 5                      Describe computational cost under the evaluated design grid and fitting settings.
#>                                                                                       InterpretationBoundary
#> 1              Rates are simulation summaries and should not be read as calibrated inferential test results.
#> 2 Counts are presentation summaries over the same simulation evidence and should not define pass/fail gates.
#> 3           Report-review signals are prompts for text and evidence review, not additional diagnostic tests.
#> 4      Contrasts are descriptive and conditional on scenarios, baseline, design grid, and replication count.
#> 5        Runtime evidence describes this implementation and settings, not a general computational guarantee.
#>                                                             Availability
#> 1                                         available_when_plot_rows_exist
#> 2                                         available_when_plot_rows_exist
#> 3                                       available_when_report_rows_exist
#> 4 available_when_well_specified_baseline_and_misspecification_rows_exist
#> 5                                  available_when_performance_rows_exist
plot(diag_eval, type = "report", metric = "rate", draw = FALSE)
#> <mfrm_plot_data>
#>   name     : diagnostic_screening
#>   title    : MFRM diagnostic screening report
#>   subtitle : Metric family: rate
#>   data     :
#>     $type : character [1]
#>     $metric : character [1]
#>     $x_var : character [1]
#>     $x_label : character [1]
#>     $group_var : NULL
#>     $group_label : NULL
#>     $design_variable_aliases : character [4]
#>     $design_descriptor : data.frame [4 x 6]
#>     $planning_scope : list (14 slots)
#>     $planning_constraints : list (5 slots)
#>     $planning_schema : list (51 slots)
#>     $gpcm_boundary : data.frame [0 x 0]
#>     $overview : data.frame [1 x 13]
#>     $reading_order : data.frame [10 x 5]
#>     $next_actions : data.frame [6 x 7]
#>     $reporting_notes : data.frame [6 x 4]
#>     $figure_recipes : data.frame [5 x 10]
#>     $source_tables : character [1]
#>     $signals : character [4]
#>     $interpretation_note : character [1]
#>     $plot_long : data.frame [8 x 27]
#>     $plot_table : data.frame [8 x 27]
#>     $plot_name : character [1]
#>   legend   : 4 entries
#>   ref lines: 0
#> Re-render via ggplot2 / plotly using `x$data`; or pass the
#> originating `draw = FALSE` plot helper its inverse to draw it.
# }
```
