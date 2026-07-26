# Summarize a diagnostic-screening simulation study

Summarizes output from
[`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md)
for reporting, appendix export, and draw-free visualization handoff. The
summary keeps simulation operating characteristics separate from
inferential conclusions: fit, marginal, pairwise, and report-review
signals are screening readouts rather than pass/fail evidence.

## Usage

``` r
# S3 method for class 'mfrm_diagnostic_screening'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md).

- digits:

  Number of digits used in numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_diagnostic_screening` with:

- `overview`: run-level design, replication, convergence, and
  report-review metadata

- `reading_order`: recommended order for reading the summary tables

- `next_actions`: action-oriented triage for interpreting and exporting
  the summary

- `reporting_notes`: report-facing boundaries and recommended wording
  safeguards

- `figure_recipes`: recommended figure/display recipes for the draw-free
  plot-data tables

- `scenario_summary`: aggregated scenario-by-design screening summaries

- `performance_summary`: operating-characteristic rates and runtime
  summaries

- `report_signal_summary`: optional
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  readiness/review signals

- `scenario_contrast`: misspecification-minus-well-specified contrasts

- `plot_*`: long-form draw-free plot tables for overview, report,
  contrast, and runtime views

- planning metadata, settings, ADEMP metadata, and interpretation notes

## See also

[`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md),
[plot.mfrm_diagnostic_screening](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_diagnostic_screening.md),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)

## Examples

``` r
# \donttest{
diag_eval <- evaluate_mfrm_diagnostic_screening(
  design = list(person = 10, rater = 2, criterion = 2, assignment = 2),
  reps = 1,
  maxit = 30,
  seed = 123
)
summary(diag_eval)
#> mfrmr Diagnostic Screening Summary
#> 
#> Overview
#>  Designs Reps                        Scenarios Models ReplicateRows
#>        1    1 well_specified, local_dependence    RSM             2
#>  ScenarioRows PerformanceRows ReportSignalRows ContrastRows RunOKRate
#>             2               2                2            1         1
#>  ConvergenceRate IncludeReport PlotDataContract
#>                1         FALSE   mfrm_plot_data
#> 
#> Reading order
#>  Step                 Table
#>     1              overview
#>     2         reading_order
#>     3          next_actions
#>     4       reporting_notes
#>     5        figure_recipes
#>     6      scenario_summary
#>     7   performance_summary
#>     8     scenario_contrast
#>     9 report_signal_summary
#>    10    plot_overview_rate
#>                                                                                                              WhatToRead
#>               Design count, replication count, scenarios, model, convergence, and whether report signals were retained.
#>                                                        Recommended reading sequence for diagnostic-screening summaries.
#>                    Action-oriented triage for replication count, run completion, contrasts, report signals, and export.
#>                                                                Reporting boundaries and recommended wording safeguards.
#>  Figure and display recipes linking plot() calls, plot_data() extraction, caption focus, and interpretation boundaries.
#>                                    Scenario-by-design legacy, strict marginal, and strict pairwise screening summaries.
#>                Operating-characteristic rates, Type I/sensitivity proxy labels, agreement rates, and runtime summaries.
#>                                    Misspecification-minus-well-specified deltas when a baseline scenario was evaluated.
#>                                 Optional mfrm_report() report-index availability/readiness and review-signal summaries.
#>                                             Long-form draw-free visualization table for the main overview-rate display.
#>                                                                                                                       Purpose
#>                                           Confirm that the simulation ran as intended before interpreting screening behavior.
#>                                                               Avoid treating every exported table as equal-priority evidence.
#>  Decide whether to increase replications, inspect run failures, read contrasts, request report signals, or export appendices.
#>                              Keep simulation screening language distinct from inferential and parameter-recovery conclusions.
#>                                Choose the smallest figure set that matches the reporting purpose before styling or rendering.
#>                                                        Compare raw screening surfaces across scenarios and design conditions.
#>                                      Separate operating behavior from runtime and from inferential or validation conclusions.
#>                                    Inspect whether misspecification shifts strict screens beyond the well-specified baseline.
#>                                                                                         Skipped unless include_report = TRUE.
#>                                                      Reuse for ggplot2, plotly, Quarto, or supplementary figure construction.
#>                                                                                                    InterpretationBoundary
#>  Run completion and convergence are prerequisites for interpretation, not proof that the diagnostic screen is calibrated.
#>                                              Reading order is guidance for human review, not a statistical decision rule.
#>                                                             Next actions are workflow prompts, not statistical decisions.
#>                     Use cautious wording unless replication count, design, and scenario coverage support stronger claims.
#>            Figure recipes are reporting workflow guidance; they do not add evidence beyond the underlying summary tables.
#>                     Scenario means and flag rates are operating-characteristic readouts, not formal inferential p-values.
#>                                     Type I and sensitivity labels are simulation proxies tied to the evaluated scenarios.
#>                      Contrasts are descriptive deltas and depend on the selected baseline, design, and replication count.
#>                           An empty table means report-index review was not requested, not that no reporting issues exist.
#>                              Plot data are a presentation handoff and should not be reinterpreted as a separate analysis.
#> 
#> Next actions
#>  Priority                           Area   Status
#>         1              Replication count   review
#>         2 Run completion and convergence       ok
#>         3       Screening interpretation       ok
#>         4             Scenario contrasts       ok
#>         5           Report-index signals optional
#>         6 Appendix and plot-data handoff       ok
#>                                                                                                   Evidence
#>                                                                                                  Reps = 1.
#>                                                                RunOKRate = 1.000; ConvergenceRate = 1.000.
#>                                                   scenario_summary rows = 2; performance_summary rows = 2.
#>                                                                                scenario_contrast rows = 1.
#>                                           include_report = FALSE; report-index signals were not requested.
#>  summary tables and draw-free plot-data tables are available through the package-wide bundle/export route.
#>                                                                                                            Action
#>  Treat this as an initial screening run; increase `reps` before interpreting operating characteristics as stable.
#>                       Proceed to scenario and performance summaries, while still reporting the convergence basis.
#>           Read scenario_summary and performance_summary together before making legacy-vs-strict screening claims.
#>       Use scenario_contrast to describe misspecification-minus-baseline shifts, with the baseline scenario named.
#>     Rebuild with include_report = TRUE only if report-readiness operating behavior is part of the study question.
#>                Use build_summary_table_bundle() or export_summary_appendix(); use plot_data() for custom figures.
#>                                                                                                                                        Route
#>                                                                                               evaluate_mfrm_diagnostic_screening(reps = ...)
#>                                                                     diag_eval$results[, c("Scenario", "rep", "RunOK", "Converged", "Error")]
#>                                                                  summary(diag_eval)$scenario_summary; summary(diag_eval)$performance_summary
#>                                                                                                         summary(diag_eval)$scenario_contrast
#>                                                                                                     summary(diag_eval)$report_signal_summary
#>  build_summary_table_bundle(diag_eval); export_summary_appendix(diag_eval); plot_data(diag_eval, type = "overview", component = "plot_long")
#>                                                                                     ReportingBoundary
#>                               Replication count affects Monte Carlo stability and should be reported.
#>  Failed or non-converged runs are design/runtime evidence, not evidence about diagnostic sensitivity.
#>             Screening readouts compare operating behavior; they are not calibrated inferential tests.
#>                 Contrasts are descriptive and conditional on the evaluated design grid and scenarios.
#>                         Report-index signals are reporting-layer prompts, not extra diagnostic tests.
#>                       Exports and plot data are presentation handoffs over the same summary evidence.
#> 
#> Reporting notes
#>                              Area
#>        Diagnostic-screening scope
#>            Legacy residual screen
#>  Strict marginal/pairwise screens
#>                Scenario contrasts
#>              Report-index signals
#>    Appendix and plot-data handoff
#>                                                                                                                         Evidence
#>  evaluate_mfrm_diagnostic_screening() repeatedly simulates, fits, diagnoses, and aggregates selected scenario/design conditions.
#>                                                         Legacy residual summaries retain familiar ZSTD-style screening behavior.
#>                           Strict marginal and pairwise summaries add model-implied response-distribution checks where available.
#>                                         scenario_contrast subtracts the well-specified baseline from misspecification scenarios.
#>                                                            report_signal_summary is empty unless include_report = TRUE was used.
#>                                        plot_* tables expose the same summaries in long form for figure or appendix construction.
#>                                                                                                                   ReportingBoundary
#>                                       Describe as a simulation operating-characteristic study, not as a calibrated hypothesis test.
#>                                            Do not report ZSTD flags alone as final evidence that the generating mechanism is wrong.
#>  Do not treat strict marginal/pairwise flags as standalone validation criteria; interpret them relative to the evaluated scenarios.
#>                           Do not generalize contrast direction or magnitude beyond the simulated design grid and replication count.
#>                                                         Do not treat reporting-layer review signals as additional diagnostic tests.
#>                                       Do not treat exported plot data as independent evidence beyond the underlying summary tables.
#>                                                                                                    RecommendedAction
#>  Report scenarios, design grid, replication count, fitting method, diagnostic mode, and any unsupported model scope.
#>                 Pair legacy flags with strict marginal/pairwise summaries before making diagnostic-screening claims.
#>                      Use performance_summary and scenario_contrast to compare sensitivity and Type I proxy behavior.
#>                            State which scenario is the baseline and avoid strong claims when replications are small.
#>        Rebuild with include_report = TRUE only if report-readiness operating behavior is part of the study question.
#>  Use build_summary_table_bundle() or export_summary_appendix() to keep tables, roles, and appendix presets explicit.
#> 
#> Figure recipes
#>                  FigureID                    RecommendedUse        SummaryTable
#>            overview_rates   main_text_or_primary_supplement  plot_overview_rate
#>           overview_counts     supplement_or_quality_control plot_overview_count
#>       report_review_rates        reporting_layer_supplement    plot_report_rate
#>  scenario_contrast_counts        misspecification_follow_up plot_contrast_count
#>           runtime_elapsed methods_or_computational_appendix        plot_runtime
#>                                                                                            CaptionFocus
#>  Describe operating-characteristic signal rates and identify whether report-review rates were included.
#>                            Describe signal burden, not statistical significance or diagnostic adequacy.
#>                      Describe reporting-layer review routing, not model validity or diagnostic success.
#>                        Describe misspecification-minus-baseline deltas and name the evaluated baseline.
#>                       Describe computational cost under the evaluated design grid and fitting settings.
#>                                                            Availability
#>                                          available_when_plot_rows_exist
#>                                          available_when_plot_rows_exist
#>                                            requires_include_report_TRUE
#>  available_when_well_specified_baseline_and_misspecification_rows_exist
#>                                   available_when_performance_rows_exist
#> 
#> Scenario summary (preview)
#>  design_id         Scenario                         ScenarioClass Model
#>        V01 local_dependence context_shared_person_by_facet_effect   RSM
#>        V01   well_specified                        null_reference   RSM
#>  DependenceFacet n_person n_rater n_criterion raters_per_person Reps RunOKRate
#>        Criterion       10       2           2                 2    1         1
#>        Criterion       10       2           2                 2    1         1
#>  ConvergenceRate MeanElapsedSec MeanLegacyMeanAbsZ MeanLegacyFlaggedLevels
#>                1          0.994              0.589                       0
#>                1          0.985              0.563                       0
#>  LegacyAnyFlagRate MeanMarginalOverallRMSD MeanMarginalMaxAbsStdResidual
#>                  0                   0.002                         0.050
#>                  0                   0.046                         1.705
#>  MeanMarginalFlaggedGroups MarginalAnyFlagRate MeanPairwiseFlaggedLevelPairs
#>                          2                   1                             1
#>                          4                   1                             0
#>  PairwiseAnyFlagRate PairwiseAvailabilityRate
#>                    1                        1
#>                    0                        1
#> 
#> Performance summary (preview)
#>  design_id         Scenario                         ScenarioClass Model
#>        V01 local_dependence context_shared_person_by_facet_effect   RSM
#>        V01   well_specified                        null_reference   RSM
#>  DependenceFacet n_person n_rater n_criterion raters_per_person Reps
#>        Criterion       10       2           2                 2    1
#>        Criterion       10       2           2                 2    1
#>  MeanElapsedSec McseElapsedSec MeanElapsedSecPer100Obs LegacyAnyFlagRate
#>           0.994             NA                   2.485                 0
#>           0.985             NA                   2.462                 0
#>  McseLegacyAnyFlagRate MarginalAnyFlagRate McseMarginalAnyFlagRate
#>                     NA                   1                      NA
#>                     NA                   1                      NA
#>  PairwiseAnyFlagRate McsePairwiseAnyFlagRate StrictAnyFlagRate
#>                    1                      NA                 1
#>                    0                      NA                 1
#>  McseStrictAnyFlagRate LegacyVsMarginalAgreement LegacyVsPairwiseAgreement
#>                     NA                         0                         0
#>                     NA                         0                         1
#>  LegacyVsStrictAgreement MarginalVsPairwiseAgreement     EvaluationUse
#>                        0                           1 sensitivity_proxy
#>                        0                           0      type_I_proxy
#>  LegacyTypeIProxy StrictTypeIProxy LegacySensitivityProxy
#>                NA               NA                      0
#>                 0                1                     NA
#>  StrictSensitivityProxy DeltaStrictMinusLegacyFlagRate
#>                       1                              1
#>                      NA                              1
#> 
#> Report signal summary (preview)
#>  design_id         Scenario                         ScenarioClass Model
#>        V01 local_dependence context_shared_person_by_facet_effect   RSM
#>        V01   well_specified                        null_reference   RSM
#>  DependenceFacet n_person n_rater n_criterion raters_per_person Reps
#>        Criterion       10       2           2                 2    1
#>        Criterion       10       2           2                 2    1
#>  ReportIndexAvailabilityRate ReportAuditErrorRows MeanReportReviewAreas
#>                            0                    0                    NA
#>                            0                    0                    NA
#>  MeanReportReadyAreas MeanReportRequestIfNeededAreas FitReportReviewRate
#>                    NA                             NA                   0
#>                    NA                             NA                   0
#>  MeanFitReportSignals PrecisionReportReviewRate MeanPrecisionReportSignals
#>                    NA                         0                         NA
#>                    NA                         0                         NA
#>  MisfitReportReviewRate MeanMisfitReportSignals
#>                       0                      NA
#>                       0                      NA
#> 
#> Scenario contrast (preview)
#>          Scenario                         ScenarioClass design_id Model
#>  local_dependence context_shared_person_by_facet_effect       V01   RSM
#>  DependenceFacet n_person n_rater n_criterion raters_per_person
#>        Criterion       10       2           2                 2
#>  MeanLegacyMeanAbsZ_Scenario MeanLegacyFlaggedLevels_Scenario
#>                        0.589                                0
#>  MeanMarginalOverallRMSD_Scenario MeanMarginalMaxAbsStdResidual_Scenario
#>                             0.002                                   0.05
#>  MeanMarginalFlaggedGroups_Scenario MeanPairwiseFlaggedLevelPairs_Scenario
#>                                   2                                      1
#>  PairwiseAnyFlagRate_Scenario MeanLegacyMeanAbsZ_WellSpecified
#>                             1                            0.563
#>  MeanLegacyFlaggedLevels_WellSpecified MeanMarginalOverallRMSD_WellSpecified
#>                                      0                                 0.046
#>  MeanMarginalMaxAbsStdResidual_WellSpecified
#>                                        1.705
#>  MeanMarginalFlaggedGroups_WellSpecified
#>                                        4
#>  MeanPairwiseFlaggedLevelPairs_WellSpecified PairwiseAnyFlagRate_WellSpecified
#>                                            0                                 0
#>  DeltaLegacyMeanAbsZ DeltaLegacyFlaggedLevels DeltaMarginalOverallRMSD
#>                0.026                        0                   -0.045
#>  DeltaMarginalMaxAbsStdResidual DeltaMarginalFlaggedGroups
#>                          -1.655                         -2
#>  DeltaPairwiseFlaggedLevelPairs DeltaPairwiseAnyFlagRate StrictSignalImproved
#>                               1                        1                 TRUE
#>  StrictSignalDominatesLegacy
#>                         TRUE
#> 
#> Notes
#>  - Well-specified rows report screening-oriented Type I proxies from any-flag rates; they are not calibrated inferential alpha estimates.
#>  - Misspecification rows report screening-oriented sensitivity proxies from any-flag rates; they summarize detection behavior rather than formal power.
#>  - At least one misspecification scenario increased a strict screening signal relative to the well-specified baseline for an evaluated design row.
#>  - At least one misspecification scenario increased strict pairwise flagging relative to the well-specified baseline for an evaluated design row.
#>  - At least one strict screening signal reacted more strongly than the legacy |ZSTD| screen for an evaluated design row.
#>  - Draw-free diagnostic-screening plot tables are exported as operating-characteristic readouts, not validation pass/fail gates.
#>  - Planning helpers vary one person count and two named non-person facet roles (Rater and Criterion). Estimation may contain additional facets, but planning and forecasting are limited to this role-based design.
#>  - Current scalar-argument planning paths allow `n_person`, `n_rater`, `n_criterion`, and `raters_per_person` to vary subject to `raters_per_person <= n_rater`.
#>  - Named-facet structural design metadata for person count, non-person facet counts, and assignments per person. These deterministic design summaries do not establish arbitrary-facet simulation support or parameter-recovery performance.
# }
```
