# Assess whether recovery-simulation results are ready to use

Converts the numerical output from
[`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
into a reviewer-facing adequacy checklist. The goal is not to impose one
universal pass/fail rule; it is to make the main user questions
explicit: Did the runs finish? Did the fitted models converge? Are
uncertainty summaries available? Are coverage and Monte Carlo precision
plausible? If practical RMSE or bias limits are supplied, which
parameter groups need follow-up? For bounded `GPCM`, which slope-regime
generator condition frames the recovery evidence?

## Usage

``` r
assess_mfrm_recovery(
  x,
  min_reps = 30,
  min_success_rate = 0.95,
  min_convergence_rate = 0.95,
  min_se_available = 0.8,
  coverage_target = 0.95,
  coverage_tolerance = 0.05,
  max_mcse_rmse_ratio = 0.25,
  max_rmse = NULL,
  max_abs_bias = NULL,
  top_n = 6,
  digits = 3,
  ...
)

# S3 method for class 'mfrm_recovery_assessment'
plot(
  x,
  y = NULL,
  type = c("status", "metrics"),
  metric = c("rmse", "bias", "coverage", "se_available", "mcse_rmse"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  For `assess_mfrm_recovery()`, output from
  [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md).
  For `plot.mfrm_recovery_assessment()`, output from
  `assess_mfrm_recovery()`.

- min_reps:

  Minimum replication count expected before treating the simulation for
  inferential use.

- min_success_rate:

  Minimum acceptable proportion of replications that generated data and
  produced a fitted model.

- min_convergence_rate:

  Minimum acceptable proportion of replications whose fitted model
  reported convergence.

- min_se_available:

  Minimum acceptable proportion of recovery rows with standard errors in
  each parameter group. Set to `NULL` to skip this check.

- coverage_target:

  Nominal coverage target, usually `0.95`.

- coverage_tolerance:

  Absolute tolerance around `coverage_target`.

- max_mcse_rmse_ratio:

  Maximum acceptable Monte Carlo SE of RMSE divided by RMSE. Set to
  `NULL` to skip this precision check.

- max_rmse:

  Optional practical RMSE limit. Use a scalar for all parameter groups
  or a named vector/list with names such as `"facet"`, `"step"`,
  `"slope"`, `"Rater"`, or `"facet:Rater:logit"`.

- max_abs_bias:

  Optional practical absolute-bias limit. Naming follows `max_rmse`.

- top_n:

  Number of next-action lines retained in the compact output.

- digits:

  Digits used by the print method.

- ...:

  Reserved for generic compatibility.

- y:

  Reserved for S3 generic compatibility.

- type:

  Assessment plot route. `"status"` summarizes checklist status counts;
  `"metrics"` plots a parameter-group assessment metric colored by its
  status.

- metric:

  Metric used when `type = "metrics"`. Supported values are `"rmse"`,
  `"bias"`, `"coverage"`, `"se_available"`, and `"mcse_rmse"`.

- draw:

  If `TRUE`, draw with base graphics. If `FALSE`, return an
  `mfrm_plot_data` object with reusable plot tables and metadata.

## Value

An object of class `mfrm_recovery_assessment` with:

- `overview`: compact run-level status.

- `checklist`: reviewer-facing adequacy checks.

- `condition_review`: generator-condition metadata, including bounded
  `GPCM` slope-regime interpretation and generated score-category
  support when available.

- `condition_reporting_notes`: reporter-facing generator-condition
  caveats separated from parameter-recovery conclusions.

- `diagnostic_reporting_notes`: reporter-facing fit/separation caveats
  retained as diagnostic context rather than recovery gates.

- `diagnostic_review`: optional fit/separation operating-characteristic
  context when retained by
  [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md).

- `metric_review`: parameter-group metric checks.

- `uncertainty_review`: compact coverage / SE availability
  interpretation.

- `reading_order`: recommended first-read order for the summary,
  condition, plot, and row-level recovery outputs.

- `next_actions`: short action list sorted by severity.

- `thresholds`: thresholds used for the assessment.

## Details

RMSE and bias adequacy depends on the substantive scale and the use
case, so the function does not mark them as failed unless the user
supplies `max_rmse` or `max_abs_bias`. Without those limits, the
corresponding rows are marked `not_assessed` and the next action asks
the user to set practical thresholds when a decision depends on the
metric.

The `condition_review` table is generator metadata for interpreting the
recovery run. For bounded `GPCM`, `GPCMSlopeRegime`, `StressLevel`, and
generated score-category support describe the data-generating condition;
they are not model-fit tests and they are not literature-derived
adequacy cut points. `condition_reporting_notes` turns those generator
conditions into reporter-facing caveats, such as high-dispersion slope
stress or sparse generated score support.

The optional `diagnostic_review` table is available when
[`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
was called with `include_diagnostics = TRUE`. It summarizes fit and
separation operating characteristics as diagnostic context only. Its
availability fields do not mean that fit or separation values are
adequate, and those rows do not enter the recovery adequacy status.
`diagnostic_reporting_notes` should be read first when drafting
fit/separation language because it separates zero
separation/reliability, absolute fit-ZSTD flags, and df-sensitive ZSTD
flags from recovery gates.

`plot.mfrm_recovery_assessment()` is a user-facing review aid. Use
`type = "status"` first to see where checklist attention is needed, then
`type = "metrics"` to inspect the parameter groups behind RMSE, bias,
coverage, standard-error availability, or Monte Carlo precision
statuses. The intended reading order is `summary(recovery_review)`, then
`condition_reporting_notes` and `condition_review`, then
`diagnostic_reporting_notes` and `diagnostic_review`, then the status
plot, then the metric plot, then the row-level recovery table for the
parameter groups that need follow-up. When `draw = FALSE`, the plot data
also include `reading_order`, `guidance`, condition/diagnostic handoff
tables, and user-facing plot tables such as `section_status` for status
plots and `metric_review` for metric plots.

## See also

[`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md),
[`plot.mfrm_recovery_simulation()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_recovery_simulation.md)

## Examples

``` r
# \donttest{
rec <- evaluate_mfrm_recovery(
  n_person = 12,
  n_rater = 2,
  n_criterion = 2,
  reps = 1,
  maxit = 30,
  seed = 123
)
assess_mfrm_recovery(rec, min_reps = 1, max_rmse = 1)
#> MFRM Recovery Adequacy Assessment
#>  Reps SuccessfulRuns SuccessRate ConvergedRuns ConvergenceRate RecoveryRows
#>     1              1           1             0               0           19
#>  RecoveryGroups OverallStatus
#>               4       concern
#> 
#> Recommended reading order
#>  Step
#>     1
#>     2
#>     3
#>     4
#>     5
#>     6
#>                                                                               Route
#>                                                            summary(recovery_review)
#>    recovery_review$condition_reporting_notes, then recovery_review$condition_review
#>  recovery_review$diagnostic_reporting_notes, then recovery_review$diagnostic_review
#>                                              plot(recovery_review, type = "status")
#>                                             plot(recovery_review, type = "metrics")
#>                                                     recovery_review$source$recovery
#>                                                                                                               WhatToRead
#>                                                                 Overall run status, next actions, and compact checklist.
#>                                Generator-condition caveats, then GPCM slope-regime and generated score-support metadata.
#>  Reporter-facing fit/separation caveats, then optional operating characteristics retained by include_diagnostics = TRUE.
#>                                                                           Checklist domains ordered by attention status.
#>                                               Parameter groups behind RMSE, bias, coverage, SE, or Monte Carlo statuses.
#>                                       Row-level truth-estimate comparisons for the parameter groups that need follow-up.
#> 
#> Checklist
#>                Section                             Item       Status
#>         Run completion                Replication count           ok
#>         Run completion     Simulation and refit success           ok
#>         Run completion             Reported convergence      concern
#>       Recovery content  Recoverable truth-estimate rows           ok
#>   Generator conditions        Bounded-GPCM slope regime not_assessed
#>   Generator conditions Generated score-category support       review
#>            Uncertainty      Standard-error availability      concern
#>            Uncertainty                         Coverage       review
#>  Monte Carlo precision           RMSE Monte Carlo error       review
#>   Practical thresholds                   RMSE threshold      concern
#>   Practical thresholds                   Bias threshold not_assessed
#>                                                                                                                                   Evidence
#>                                                                                                  1 replication(s); requested minimum is 1.
#>                                                                                                       1/1 successful run(s); rate = 1.000.
#>                                                                                                        0/1 converged run(s); rate = 0.000.
#>                                                                                                       19 row-level recovery comparison(s).
#>                                                                                 Model RSM does not use bounded-GPCM slope-regime metadata.
#>  1 replication(s) retained score support; minimum category count = 2; minimum category proportion = 0.042; maximum omitted categories = 0.
#>                                                                                                                 Group statuses: concern=4.
#>                                                                                                           Group statuses: not_available=4.
#>                                                                                                            Group statuses: ok=3, review=1.
#>                                                                                                           Group statuses: concern=2, ok=2.
#>                                                                                         No practical absolute-bias threshold was supplied.
#>                                                                                                                         NextAction
#>                                                       Use as supporting evidence under the stated simulation setup and thresholds.
#>                                                       Use as supporting evidence under the stated simulation setup and thresholds.
#>              Do not use model convergence as adequacy evidence until the design, fit settings, or replication count are revisited.
#>                                                       Use as supporting evidence under the stated simulation setup and thresholds.
#>                                                                        No GPCM slope-condition follow-up is needed for this model.
#>  Report sparse generated score support explicitly and inspect category-level recovery or increase design size before generalizing.
#>    Do not use standard-error availability as adequacy evidence until the design, fit settings, or replication count are revisited.
#>                                                    Review coverage with plots and row-level output before using it for a decision.
#>                                       Review Monte Carlo precision with plots and row-level output before using it for a decision.
#>                           Do not use RMSE as adequacy evidence until the design, fit settings, or replication count are revisited.
#>                                                                Set a practical threshold if bias must support a go/no-go decision.
#> 
#> Condition review
#>  Model GPCMSlopeRegime    StressLevel SlopeLevels MaxAbsCenteredLogSlope
#>    RSM            <NA> not_applicable          NA                     NA
#>  MinScoreCount MinScoreProportion MaxZeroScoreLevels ScoreSupportStatus
#>              2              0.042                  0             review
#>        Status
#>  not_assessed
#>                                                                                              Interpretation
#>  The fitted generator is not bounded GPCM, so slope-regime metadata is not part of this recovery condition.
#> 
#> Condition reporting notes
#>  ConditionArea ReportingAttention                      ConditionFinding
#>   slope_regime            context           slope_regime_not_applicable
#>  score_support   reporting_review thin_generated_score_category_support
#>                                                                                                     Evidence
#>      model=RSM; slope_regime=NA; stress_level=not_applicable; slope_levels=NA; max_abs_centered_log_slope=NA
#>  score_support_replications=1.00; min_score_count=2.00; min_score_proportion=0.0417; max_zero_score_levels=0
#>                ValidationUse
#>  generator_condition_context
#>  generator_condition_context
#> 
#> Metric review
#>  ParameterType     Facet ComparisonScale   RMSE Bias Coverage95 SEAvailableRate
#>          facet Criterion           logit  0.013    0         NA               0
#>          facet     Rater           logit  0.222    0         NA               0
#>         person    Person           logit 11.186    0         NA               0
#>           step    Common           logit 13.703    0         NA               0
#>  McseRMSEToRMSE OverallStatus
#>            0.00       concern
#>            0.00       concern
#>            0.22       concern
#>            0.25       concern
#> 
#> Uncertainty review
#>  ParameterType     Facet ComparisonScale Coverage95 CoverageStatus
#>          facet Criterion           logit         NA  not_available
#>          facet     Rater           logit         NA  not_available
#>         person    Person           logit         NA  not_available
#>           step    Common           logit         NA  not_available
#>  SEAvailableRate SEStatus
#>                0  concern
#>                0  concern
#>                0  concern
#>                0  concern
#>                                                                                Interpretation
#>  Coverage was not computed because finite SE-based intervals were unavailable for this group.
#>  Coverage was not computed because finite SE-based intervals were unavailable for this group.
#>  Coverage was not computed because finite SE-based intervals were unavailable for this group.
#>  Coverage was not computed because finite SE-based intervals were unavailable for this group.
#> 
#> Next actions
#>  - Reported convergence: Do not use model convergence as adequacy evidence until the design, fit settings, or replication count are revisited.
#>  - Generated score-category support: Report sparse generated score support explicitly and inspect category-level recovery or increase design size before generalizing.
#>  - Standard-error availability: Do not use standard-error availability as adequacy evidence until the design, fit settings, or replication count are revisited.
#>  - Coverage: Review coverage with plots and row-level output before using it for a decision.
#>  - RMSE Monte Carlo error: Review Monte Carlo precision with plots and row-level output before using it for a decision.
#>  - RMSE threshold: Do not use RMSE as adequacy evidence until the design, fit settings, or replication count are revisited.

# Read the bounded-GPCM generator condition separately from recovery adequacy.
gpcm_spec <- build_mfrm_sim_spec(
  n_person = 14,
  n_rater = 2,
  n_criterion = 2,
  raters_per_person = 2,
  model = "GPCM",
  step_facet = "Criterion",
  slope_facet = "Criterion",
  slopes = c(0.85, 1.15),
  assignment = "crossed"
)
gpcm_rec <- suppressWarnings(evaluate_mfrm_recovery(
  sim_spec = gpcm_spec,
  reps = 1,
  fit_method = "MML",
  quad_points = 5,
  maxit = 12,
  include_diagnostics = TRUE,
  include_person = FALSE,
  seed = 456
))
gpcm_review <- assess_mfrm_recovery(
  gpcm_rec,
  min_reps = 1,
  max_rmse = c(slope = 2),
  max_abs_bias = c(slope = 1),
  min_se_available = NULL,
  max_mcse_rmse_ratio = NULL
)
gpcm_review$condition_reporting_notes[, c(
  "ConditionArea", "ReportingAttention", "ConditionFinding"
)]
#> # A tibble: 2 × 3
#>   ConditionArea ReportingAttention ConditionFinding               
#>   <chr>         <chr>              <chr>                          
#> 1 slope_regime  context            moderate_slope_regime          
#> 2 score_support context            generated_score_support_context
gpcm_review$condition_review[, c(
  "Model", "GPCMSlopeRegime", "StressLevel", "ScoreSupportStatus"
)]
#> # A tibble: 1 × 4
#>   Model GPCMSlopeRegime StressLevel ScoreSupportStatus
#>   <chr> <chr>           <chr>       <chr>             
#> 1 GPCM  moderate        moderate    ok                
gpcm_review$diagnostic_reporting_notes[, c(
  "Facet", "ReportingAttention", "DiagnosticFinding"
)]
#> # A tibble: 3 × 3
#>   Facet     ReportingAttention DiagnosticFinding             
#>   <chr>     <chr>              <chr>                         
#> 1 Criterion reporting_review   zero_separation_or_reliability
#> 2 Person    context            diagnostic_context_available  
#> 3 Rater     reporting_review   zero_separation_or_reliability
summary(gpcm_review)$reading_order
#> # A tibble: 6 × 4
#>    Step Route                                                 WhatToRead Purpose
#>   <int> <chr>                                                 <chr>      <chr>  
#> 1     1 "summary(recovery_review)"                            Overall r… Decide…
#> 2     2 "recovery_review$condition_reporting_notes, then rec… Generator… Separa…
#> 3     3 "recovery_review$diagnostic_reporting_notes, then re… Reporter-… Check …
#> 4     4 "plot(recovery_review, type = \"status\")"            Checklist… Find t…
#> 5     5 "plot(recovery_review, type = \"metrics\")"           Parameter… Identi…
#> 6     6 "recovery_review$source$recovery"                     Row-level… Diagno…
# }
```
