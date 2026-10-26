# Confidence-interval and uncertainty route guide

Return a compact map of the public `mfrmr` routes that can expose
confidence intervals or interval-like uncertainty displays. Use this
when you need to know which helper accepts `show_ci` or `ci_level`,
which columns to look for in `draw = FALSE` output, and how strongly the
resulting interval should be interpreted.

## Usage

``` r
mfrmr_interval_guide(
  scope = c("all", "visual", "table", "reporting", "fit", "bias", "linking", "gpcm",
    "equivalence", "hierarchical", "shrinkage")
)
```

## Arguments

- scope:

  Which rows to return: `"all"` (default), `"visual"`, `"table"`,
  `"reporting"`, `"fit"`, `"bias"`, `"linking"`, `"gpcm"`,
  `"equivalence"`, `"hierarchical"`, or `"shrinkage"`.

## Value

A data.frame with columns:

- `Route`

- `Scope`

- `PrimaryHelper`

- `DisplayRoute`

- `DefaultLevel` (missing for an uncertainty-only route without
  intervals)

- `IntervalColumns`

- `Basis`

- `UseFor`

- `InterpretationBoundary`

- `GPCMStatus`

- `Notes`

## Details

The guide is deliberately conservative. It is a namespace and
interpretation map, not a fitted result and not proof that a given
interval is available for a particular run. For run-specific
availability, call the listed helper with `draw = FALSE` or inspect the
relevant result table.

Most rows use `ci_level = 0.95` by default. Some intervals are
model-based Wald intervals, some are delta-method intervals, some are
profile or profile-like intervals when available, and some are plotting
overlays around already-estimated quantities. The `Basis` and
`InterpretationBoundary` columns are the important guardrails.

## Why an estimate or interval is missing

A finite printed value may be a usable estimate, an optimizer value
retained for review, a constraint-fixed value, or a prior-only score.
Read the result's status and explanation before interpreting it. An `NA`
bound is not an infinite limit, zero uncertainty, or evidence of no
effect.

- **Fit and parameter readiness:** start with `summary(fit)$decision`,
  `$readiness` and `$key_warnings` for ordinary fits. For CML inspect
  `summary(fit)$checks` and `$notes`; comparison-only CML retains
  `EstimateStatus` and `EstimateReason` in `fit$comparisons`.
  Identification failure or absence of a finite MLE cannot be repaired
  merely by increasing optimizer iterations. A refused calculation
  explains the restriction in its error instead of returning an
  inferential result.

- **Facet and population intervals:** inspect `ci$table$Status`,
  `$CIEligible` and `$InferenceReview`, together with the result's
  checks and cautions. Missing SEs or bounds may coexist with a retained
  point; that does not certify the point as reliable. `fixed` refers to
  a target fixed by constraints, not an estimate with perfect measured
  precision.

- **GPCM slope/profile intervals:** use `attr(ci, "diagnostics")` and
  the saved endpoint checks. They distinguish an unavailable interval
  from a partially resolved profile;
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
  describes each method.

- **Testlet and shared-rater normal intervals:** use
  `attr(ci, "diagnostics")` and `attr(ci, "checks")`; default summary
  tables also retain `IntervalStatus` and `InferenceReview`. These
  distinguish intervals not requested, unsupported targets, failed
  numerical/information checks, and estimated zero-variance boundaries.
  The boundary restriction applies even when optimization has converged.
  See
  [`confint.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_testlet.md)
  and
  [`confint.mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_random_rater.md).

- **Person scores:**
  [`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md)
  and the extension scoring functions retain row-level `Status` and
  `Reason`. `prior_only` means no observed responses: the reported mean
  and interval describe the assumed population. `unavailable` withholds
  individual estimates and intervals. Review the stated cause; more
  quadrature nodes cannot supply observations or remedy a zero
  ability-variance restriction.

- **G/D-study intervals:** read the metric-specific `Status`,
  diagnostics and notes. A width below numerical resolution is a
  calculation limitation, not perfect reliability; raw log-ratio or
  pivot diagnostics may still be retained. An explicitly reported zero
  endpoint, a constraint boundary and an unresolved numerical interval
  have different meanings.

Increase integration precision or revise optimizer controls only when
the saved diagnostics identify those numerical issues. Model
assumptions, insufficient design information and unsupported boundary
inference need substantive review. Numerical success alone does not
resolve them. Keep explanations with saved results: use
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) for the whole object,
and export the status/reason table with CSV. Older saved tables do not
gain fields merely by being read; recreate summaries or interval
displays from their source fit where supported. Do not rewrite
historical fit checks.

## Availability is not coverage

Read the target, interval method and assumptions before interpreting
bounds. Numerical availability, sampling coverage and public API support
are separate questions. Where returned, `CIEligible` records the source
and method's eligibility checks, which can include model, design and
numerical restrictions; `CoverageQualified = FALSE` means nominal
sampling coverage is not established for that procedure. It is not a
measured coverage rate and does not erase computed bounds. Absence of
that field is not evidence of coverage either.

A partial profile retains computed endpoints and the unresolved side's
reason. An unresolved search is not an infinite limit or a calibrated
one-sided interval. Inspect
`apa_table(result, which = "profile_endpoints")` and retain the method's
notes when reporting or exporting it.

Corrected-JML `RootSE` describes variation around an adjusted-equation
root; residual bias can separate that root from the true structural
parameter. It must not be turned into a structural confidence interval
by multiplying it by 1.96. This guide includes that uncertainty-only
route with no default confidence level. Unavailable public structural
intervals do not establish that every interval method is mathematically
impossible.

Conditional Person posterior intervals hold calibration fixed. A full
external Bayesian analysis, for example through
[`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md),
has different assumptions and returns credible intervals; export alone
neither runs the sampler nor validates its intervals. Inspect sampler
precision, convergence and prior sensitivity. Neither type of posterior
interval is automatically a frequentist confidence interval with nominal
coverage. See
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
for estimator-specific routes and restrictions. For coefficients,
conditional population means and residual variance in an estimated
RSM/PCM population, use
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md).
Its [plot()
method](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_population_intervals.md)
displays coefficients or saved contrasts, retaining unavailable
intervals and experimental status. Residual variance stays in the table
because its units differ. This route is separate from Person scoring and
facet-location intervals.

Native RSM/PCM CML intervals use conditional information, with no
estimated Person abilities or population SD. The guide gives a dedicated
route for saved comparison-only targets and explains the facet argument
for full CML results. A separate full-MML interaction route accepts
`comparison_review` and optional `scale = "standardized"`; estimated-SD
standardization includes the same fit's population-SD uncertainty and
its covariance with the contrast. It requires an intercept-only normal
population rather than substituting a regression residual SD. Neither
numerical eligibility nor a positive conditional identification check
establishes global MML identification or finite-sample interval
coverage.

## See also

[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
[`visual_reporting_template()`](https://ryuya-dot-com.github.io/mfrmr/reference/visual_reporting_template.md),
[plot(x, type =
"fair_average")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"bias")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"displacement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type = "wright", view =
"unified")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"rater_severity")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"apa_summary")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md),
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md),
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md),
[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md),
[`mfrm_random_rater_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md),
[`confint.mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_random_rater.md),
[`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md),
[`predict.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_testlet.md)

## Examples

``` r
mfrmr_interval_guide()
#>                                                  Route
#> 1                              Facet-measure fit table
#> 2                              Fit-measure forest plot
#> 3                       Wright map uncertainty overlay
#> 4               Unified Wright map uncertainty overlay
#> 5                               Rater severity profile
#> 6                        Manuscript Figure 1 composite
#> 7                     Fair-average diagnostic interval
#> 8                    Bias-interaction interval overlay
#> 9                        Displacement interval overlay
#> 10                              Group contrast summary
#> 11                       Facet-equivalence ROPE review
#> 12                            Anchor drift forest plot
#> 13                               Rater trajectory plot
#> 14                    Empirical-Bayes shrinkage funnel
#> 15                           Facet ICC interval review
#> 16                Fixed-facet model/sandwich intervals
#> 17                   Assigned-score MI facet intervals
#> 18               CML conditional-information intervals
#> 19                  MML interaction-contrast intervals
#> 20             Conditional-normal population intervals
#> 21 Observed random-rater explicit normal approximation
#> 22           Observed random-rater bootstrap intervals
#> 23                  Random-rater population SD profile
#> 24                     Testlet fixed-facet calibration
#> 25                   Testlet conditional Person scores
#> 26       Shared-rater fixed-facet and step calibration
#> 27              Shared-rater conditional Person scores
#> 28                       GPCM relative-slope intervals
#> 29                     GMFRM component-slope intervals
#> 30                        GPCM slope profile intervals
#> 31                Corrected-JML local root uncertainty
#> 32                              GPCM curve uncertainty
#> 33                      GPCM bootstrap slope intervals
#> 34          Binary rater-network coefficient intervals
#>                                  Scope
#> 1                  table,fit,reporting
#> 2                 visual,fit,reporting
#> 3                 visual,fit,reporting
#> 4                 visual,fit,reporting
#> 5                 visual,fit,reporting
#> 6                 visual,fit,reporting
#> 7          table,visual,gpcm,reporting
#> 8           visual,bias,gpcm,reporting
#> 9             visual,linking,reporting
#> 10          visual,bias,gpcm,reporting
#> 11  table,visual,equivalence,reporting
#> 12       visual,linking,gpcm,reporting
#> 13       visual,linking,gpcm,reporting
#> 14          visual,shrinkage,reporting
#> 15 table,visual,hierarchical,reporting
#> 16     table,visual,fit,gpcm,reporting
#> 17          table,visual,fit,reporting
#> 18          table,visual,fit,reporting
#> 19          table,visual,fit,reporting
#> 20          table,fit,reporting,visual
#> 21          table,visual,fit,reporting
#> 22          table,visual,fit,reporting
#> 23                 table,fit,reporting
#> 24          table,visual,fit,reporting
#> 25          table,visual,fit,reporting
#> 26                 table,fit,reporting
#> 27          table,visual,fit,reporting
#> 28     gpcm,visual,table,fit,reporting
#> 29     gpcm,visual,table,fit,reporting
#> 30     gpcm,visual,table,fit,reporting
#> 31            gpcm,table,fit,reporting
#> 32         gpcm,visual,table,reporting
#> 33         gpcm,visual,table,reporting
#> 34              table,visual,reporting
#>                                                                                                                                      PrimaryHelper
#> 1                                                                                                              fit_measures_table(ci_level = 0.95)
#> 2                                                                              fit_measures_table(...); plot(type = "measure_ci", ci_level = 0.95)
#> 3                                                                                      plot(fit, type = "wright", show_ci = TRUE, ci_level = 0.95)
#> 4                                                                    plot(fit, type = "wright", view = "unified", show_ci = TRUE, ci_level = 0.95)
#> 5                                                                                              plot(fit, type = "rater_severity", ci_level = 0.95)
#> 6                                                                                                 plot(fit, type = "apa_summary", ci_level = 0.95)
#> 7                 plot(fit, type = "fair_average", show_ci = TRUE, ci_level = 0.95); fair_average_table(fit_gpcm, fair_se = TRUE, ci_level = 0.95)
#> 8                                                                                        plot(..., type = "bias", show_ci = TRUE, ci_level = 0.95)
#> 9                                                                                plot(..., type = "displacement", show_ci = TRUE, ci_level = 0.95)
#> 10                                                                                                                     plot(..., type = "summary")
#> 11                                                                 analyze_facet_equivalence(ci_level = 0.95); plot(x, type = "facet_equivalence")
#> 12                                                                         detect_anchor_drift(...); plot(drift, type = "forest", ci_level = 0.95)
#> 13                                            plot(fits[[1L]], type = "trajectory", comparison = fits[-1L], labels = names(fits), ci_level = 0.95)
#> 14 plot(..., type = "shrinkage", view = "funnel", show_ci = TRUE, ci_level = 0.95); plot(fit, type = "shrinkage", show_ci = TRUE, ci_level = 0.95)
#> 15                                               compute_facet_icc(ci_method = "boot", ci_level = 0.95); plot(analyze_hierarchical_structure(...))
#> 16                                                                                mfrm_facet_intervals(fit, facet, method = "model", level = 0.95)
#> 17                                                                                             pool_mfrm_imputed(analyses, facet, ci_level = 0.95)
#> 18                                                                                                         mfrm_facet_intervals(fit, level = 0.95)
#> 19                                                     mfrm_facet_intervals(fit, comparison_review = review, scale = "standardized", level = 0.95)
#> 20                                                                                     mfrm_population_intervals(fit, level = 0.95, contrasts = L)
#> 21                                                                                                     confint(fit, parm = "raters", level = 0.95)
#> 22                                                                          mfrm_random_rater_intervals(fit, nsim = 499, seed = 123, level = 0.95)
#> 23                                                                                                   confint(fit, parm = "rater_sd", level = 0.95)
#> 24                                                                                                confint(fit, parm = 'calibration', level = 0.95)
#> 25                                                                                                                   predict(testlet_fit, newdata)
#> 26                                                                                                confint(fit, parm = 'calibration', level = 0.95)
#> 27                                                                                                     score_mfrm_random_rater(fit, persons = ids)
#> 28                                                                                                     confint(fit, parm = "slopes", level = 0.95)
#> 29                                                                                                     confint(fit, parm = "slopes", level = 0.95)
#> 30                                                         confint(fit, parm = "slopes", method = "profile", slope = selected_slope, level = 0.95)
#> 31                                                                                     summary(fit)$tables$uncertainty; summary(fit)$tables$slopes
#> 32                                                                                                                 mfrm_curve_intervals(fit, grid)
#> 33                                                                                                   confint(bootstrap_mfrm_gpcm(fit, seed = 123))
#> 34                                                                                            fit_rater_network(...); confint(model, level = 0.95)
#>                                                                                                                                                                                                                                DisplayRoute
#> 1                                                                                                                                                                                                   Use the returned table or facets_table.
#> 2                                                                                                                                                         Use plot(fit_measures, type = "measure_ci", draw = FALSE) for reusable plot data.
#> 3                                                                                                                                                                        Use plot(..., draw = FALSE)$data$locations or draw the base-R map.
#> 4                                                                                                                                          Use plot(..., type = "wright", view = "unified", draw = FALSE)$locations or draw the base-R map.
#> 5                                                                                                                                                                      Use draw = FALSE to reuse the ranked severity table and band labels.
#> 6                                                                                                                                                                Use draw = FALSE to reuse wright, severity, threshold, and summary panels.
#> 7                                                                                                                                     Use plot(..., type = "fair_average", show_ci = TRUE, draw = FALSE)$data; inspect plot_data and notes.
#> 8                                                                                                                                                      Use ranked or scatter views; heatmap and profile views intentionally omit intervals.
#> 9                                                                                                                                                                          Use view = "lollipop" with draw = FALSE for interval-ready data.
#> 10                                                                                                                                                                                     Use draw = FALSE when rebuilding the summary figure.
#> 11                                                                                                                                             Use eligible MML forest/ROPE output for grand-mean proximity; read pairwise TOST separately.
#> 12                                                                                                                                                                         Use draw = FALSE to inspect CI_Lower / CI_Upper before plotting.
#> 13                                                                                                                                                                     Use linked-wave fit lists only; the helper does not perform linking.
#> 14                                                                                                                                 Use on fits augmented by empirical-Bayes shrinkage columns; draw = FALSE returns CI-ready table columns.
#> 15                                                                                                                                                                       Use ICC tables for interval values; plots expose them when finite.
#> 16        For supported MML fits, use plot(result), as_ggplot(result), apa_table(result), or attach it with mfrm_results(fit, intervals = list(raters = result), compute = "never"). See the separate CML and MML interaction routes below.
#> 17                                                                                                                                                                                       Use summary(result) or plot(result, draw = FALSE).
#> 18                                                                                                            summary(result), plot(result), as_ggplot(result), apa_table(result) and saveRDS(result); CML does not support mfrm_results().
#> 19 summary(result), plot(result), as_ggplot(result), apa_table(result) and saveRDS(result); attach with mfrm_results(fit, intervals = list(comparisons = result), compute = "never") for reports and saved plot type = 'facet_comparisons'.
#> 20    summary(ci), vcov(ci), apa_table(ci), plot(ci) or plot(ci, type = 'contrasts'); as_ggplot(ci) reuses saved values. Attach with mfrm_results(fit, intervals = list(population = ci), compute = "never") for reports and table exports.
#> 21                                                                                                                                                   Use plot(fit, intervals = "normal", draw = FALSE); defaults show point estimates only.
#> 22                                                                                                                                                                      Use plot(result, draw = FALSE), summary(result) or confint(result).
#> 23                                                                                                                                                                                          Inspect the interval and its profile attribute.
#> 24                                                                                              Use plot(fit, facet = 'Rater', intervals = 'normal', level = 0.95) or summary(fit, calibration_intervals = 'normal'). Defaults omit bounds.
#> 25                                                                                                                                                      Use scores$table, summary(scores), plot(scores, draw = FALSE) or as_ggplot(scores).
#> 26                                                                 Use summary(fit, calibration_intervals = 'normal', level = 0.95) or mfrm_results(fit, calibration_intervals = 'normal', calibration_level = 0.95). Defaults omit bounds.
#> 27                                                                                                                    Use scores$table, summary(scores), plot(scores) or as_ggplot(scores); attach with mfrm_results(fit, scores = scores).
#> 28                                                          plot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(slopes = result)). diagnose_mfrm() retains default relative/model intervals.
#> 29                                                                                                                                       plot(result), apa_table(result); attach with mfrm_results(fit, intervals = list(slopes = result)).
#> 30                                                                                                              print(result), plot(result), apa_table(result, which = "profile_endpoints"); attach the selected profile to mfrm_results().
#> 31                                                                                                                                   summary(fit), mfrm_results(fit), mfrm_report(); point-only plots have no structural confidence bounds.
#> 32                                                                                            plot(result), as_ggplot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(uncertainty = result)).
#> 33                                                                                            plot(result), as_ggplot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(uncertainty = result)).
#> 34                                                                                                                                                                   summary(model); plot(model, type = 'coefficients'); mfrm_report(model)
#>    DefaultLevel
#> 1          0.95
#> 2          0.95
#> 3          0.95
#> 4          0.95
#> 5          0.95
#> 6          0.95
#> 7          0.95
#> 8          0.95
#> 9          0.95
#> 10         0.95
#> 11         0.95
#> 12         0.95
#> 13         0.95
#> 14         0.95
#> 15         0.95
#> 16         0.95
#> 17         0.95
#> 18         0.95
#> 19         0.95
#> 20         0.95
#> 21         0.95
#> 22         0.95
#> 23         0.95
#> 24         0.95
#> 25         0.95
#> 26         0.95
#> 27         0.95
#> 28         0.95
#> 29         0.95
#> 30         0.95
#> 31           NA
#> 32         0.95
#> 33         0.95
#> 34         0.95
#>                                                                                                                                                                   IntervalColumns
#> 1                                                                                                                                                    CI_Lower, CI_Upper, CI_Level
#> 2                                                                                                                                                    CI_Lower, CI_Upper, CI_Level
#> 3                                                                                                                                       CI_Lower, CI_Upper, CI_Level in locations
#> 4                                                                                                                                       CI_Lower, CI_Upper, CI_Level in locations
#> 5                                                                                                                                   Level, Estimate, SE, CI_Lower, CI_Upper, Band
#> 6                                                                                                                            severity panel includes CI_Lower, CI_Upper, ci_level
#> 7  AdjustedAverageCI_* / StandardizedAdjustedAverageCI_*, FairCIEligible, FairCIReportingUse in tables; CI_Lower / CI_Upper / CI_Level, CI_Eligible, CI_ReportingUse in plot data
#> 8                                                                                                                   CI_Lower, CI_Upper, CI_Level on ranked_table and scatter_data
#> 9                                                                                                                                                    CI_Lower, CI_Upper, CI_Level
#> 10                                                                                                                   CI_Lower, CI_Upper, CI_Level when contrast SEs are available
#> 11                                                                            CI_Lower, CI_Upper; DeviationCI_Lower, DeviationCI_Upper for plots; CI90_Lower, CI90_Upper for TOST
#> 12                                                                                                                                                   CI_Lower, CI_Upper, CI_Level
#> 13                                                                                                                                                   CI_Lower, CI_Upper, CI_Level
#> 14                                                                                         RawCI_Lower, RawCI_Upper, ShrunkCI_Lower, ShrunkCI_Upper, CI_Level when show_ci = TRUE
#> 15                                                                                                                        ICC_CI_Lower, ICC_CI_Upper, ICC_CI_Level, ICC_CI_Method
#> 16                                                             Lower, Upper, SE, ModelLower, ModelUpper, ModelSE, Status; CIEligible and CoverageQualified on experimental routes
#> 17                                                                                                                                                   Lower, Upper, SE, DF, Status
#> 18                  Estimate, SE, Lower, Upper, Status, CIEligible, InferenceReview; comparison-only results also retain ConditionalState, IdentificationBasis and EstimateReason
#> 19                                                    Estimate, NativeEstimate, SE, Lower, Upper, CIEligible, CoverageQualified, IdentificationBasis, MarginalIdentificationState
#> 20                                                               Lower, Upper, SE, WorkingLower, WorkingUpper, WorkingSE, NaturalScaleStatus, Status, CIEligible, InferenceReview
#> 21                                                                              Lower, Upper; IntervalStatus, CIEligible, InferenceReview in diagnostics; source checks attribute
#> 22                                                                                                                                           Lower, Upper; availability attribute
#> 23                                                                                                                                                Lower, Upper; profile attribute
#> 24                                                                Lower, Upper; Estimate, SE, IntervalStatus, CIEligible, InferenceReview in diagnostics; source checks attribute
#> 25                                                                                                                                    Lower, Upper, ConditionalSD, Status, Reason
#> 26                                                                Lower, Upper; Estimate, SE, IntervalStatus, CIEligible, InferenceReview in diagnostics; source checks attribute
#> 27                                                                                                                                    Lower, Upper, ConditionalSD, Status, Reason
#> 28                                                                                                                Lower, Upper; CIEligible, CIUse, InferenceReview in diagnostics
#> 29                                                                                                    Lower, Upper; CIEligible, CoverageQualified, InferenceReview in diagnostics
#> 30                                                      Lower, Upper; CI_Lower, CI_Upper, CIEligible, CIUse, InferenceReview in diagnostics; endpoint status in the profile table
#> 31                                                                                                                         RootSE, LogRootSE; no structural Lower or Upper bounds
#> 32                                                                                                                                      Lower, Upper, CIEligible, InferenceReview
#> 33                                                                                                                         Matrix bounds; diagnostics and availability attributes
#> 34                                                                                                                   Percentage-labelled bounds; diagnostics and notes attributes
#>                                                                                                                                                                                                               Basis
#> 1                                                                                                                                                  Approximate Wald interval on facet measure: estimate +/- z * SE.
#> 2                                                                                                                                 Approximate Wald interval on facet measure recomputed for the requested ci_level.
#> 3                                                                                                                                                     Approximate facet-level SE overlay on the shared logit scale.
#> 4                                                                                                                                                     Approximate facet-level SE overlay on the shared logit scale.
#> 5                                                                                                                                           Approximate Wald interval around centered facet severity using ModelSE.
#> 6                                                                                                                                        Composite overview; interval evidence comes from the rater severity panel.
#> 7                  RSM/PCM plot: focal-measure delta-method interval with thresholds/references fixed. GPCM-MML table/plot: joint structural covariance for non-Person rows, with Person EAP/reference means fixed.
#> 8                                                                                                                      Profile-likelihood limits for GPCM bias rows when available, otherwise per-cell SE fallback.
#> 9                                                                                                                                               Approximate Wald interval around displacement using DisplacementSE.
#> 10                                                                    Residual contrast approximation or refit conditional plug-in interval; refit SEs omit baseline-anchor uncertainty and cross-refit covariance.
#> 11                                                                                                                   Joint MML covariance for pair differences and deviations from the equally weighted facet mean.
#> 12                                                                                                                                               Approximate drift interval using supplied anchor-drift SE columns.
#> 13                                                                                                                                             Approximate per-rater severity interval across already linked waves.
#> 14                                                                                                              Descriptive normal bands from original and plug-in shrunken SEs; variance estimates are held fixed.
#> 15                                                                                                      Explicit parametric percentile bootstrap of refitted ICC ratios; the default supplies point estimates only.
#> 16                                                                                       Pointwise normal intervals from full observed-information or one-way cluster sandwich covariance; estimates are unchanged.
#> 17                                                                                             Rubin pooling of full within-imputation model covariance and between-imputation covariance, with scalar t reference.
#> 18        Pointwise asymptotic Wald intervals from joint conditional information after conditioning on each Person's total and observed roster; comparison-only results reuse saved identified-subspace covariance.
#> 19 Pointwise model-information intervals from the full joint MML covariance. Standardized contrasts use the joint delta-method derivative of contrast/population SD, including SD uncertainty and cross-covariance.
#> 20                                            Pointwise normal coefficient/contrast intervals and exponentiated log-variance intervals, using the inverse full joint MML information including nuisance parameters.
#> 21                                                                                                                                  Normal prediction interval with first-order calibration-adjusted prediction SE.
#> 22                                                                                                   Full-refit parametric prediction-error bootstrap; studentized by default, unscaled error comparison available.
#> 23                                                                                                                               Profile likelihood with an asymptotic one-degree chi-square cutoff; includes zero.
#> 24                                                                                                Explicit observed-information normal approximation for fixed facets and steps in the Person-specific testlet RSM.
#> 25                                                                                       Continuous equal-tail posterior intervals conditional on calibration and the fitted or specified normal Person population.
#> 26                                                                                                           Explicit observed-information normal approximation for fixed facets and steps in the shared-rater RSM.
#> 27                                                                                                       Continuous marginal posterior with joint conditional rater Laplace integration and calibration held fixed.
#> 28                                                                                       Pointwise log-Wald intervals from the inverse full joint MML observed information, with sum-zero log-slope transformation.
#> 29                                                                                                  Experimental component log-Wald intervals from full joint MML information on the fixed N(0,1) population scale.
#> 30                                                                                                       Experimental likelihood-ratio inversion for one selected slope with an asymptotic chi-square(1) reference.
#> 31                                                                                         Experimental full estimating-equation covariance around the adjusted root under the declared Person/roster sampling law.
#> 32                                                                                                       Full calibration covariance at fixed native-scale ability and rating context; logit or log transformation.
#> 33                                                                                                                    Fitted-model basic bootstrap errors; unresolved refits enclose all possible empirical limits.
#> 34                                                                                                                     Approximate pointwise normal ERGM coefficient intervals in conditional log-odds coordinates.
#>                                                                                                                                                       UseFor
#> 1                                                                                                         Report facet estimates with uncertainty in tables.
#> 2                                                                         Show which facet levels have wide measure uncertainty before discussing fit flags.
#> 3                                                                                         Show targeting and location uncertainty on a compact variable map.
#> 4                                                                                     Show targeting and uncertainty across persons, facets, and thresholds.
#> 5                                                                     Compare signed rater locations and qualified uncertainty; neutral guides are optional.
#> 6                                                                                 Build a manuscript Figure 1 overview while preserving reusable panel data.
#> 7                                                Inspect fair-score uncertainty separately from historical measure-level SE columns; FairZ is not a z-score.
#> 8                                                                     Screen interaction-bias cells while showing uncertainty around the bias-size estimate.
#> 9                                                                   Review anchor or calibration tension without treating displacement as a binary decision.
#> 10                                                          Describe group residual differences; linked refit intervals require separate uncertainty review.
#> 11                                                        Decide whether an interval lies within, overlaps, or falls outside the practical equivalence band.
#> 12                                                                                    Review whether common elements drift materially across forms or waves.
#> 13                                                                                       Inspect rater movement across anchored waves or training occasions.
#> 14                                                                                                Show how much partial pooling moved noisy facet estimates.
#> 15                                                                  Report clustering / nesting uncertainty without treating ICC alone as a design decision.
#> 16               Compare uncertainty for fixed facet estimates and prespecified within-facet contrasts from supported MML fits, including rater differences.
#> 17                                                   Report eligible fixed facet estimates and contrasts after proper imputation of missing assigned scores.
#> 18 Read requested contrasts from a CML fit_scope = 'comparisons' result. For a full mfrm_cml_fit, add facet and optional named contrasts to the helper call.
#> 19          Read declared facet-by-origin contrasts from a matching full native RSM/PCM MML interaction fit; use scale = 'native' for original fitted units.
#> 20               Estimate conditional population means, prespecified linear combinations and residual population variance under the fitted predictor coding.
#> 21                                                                         Describe realized observed-rater effects relative to the assumed population mean.
#> 22                                                           Compare model-based pointwise prediction intervals for the same realized observed-rater target.
#> 23                                                          Estimate variation across the assumed rater population, including at an estimated zero variance.
#> 24                                                                      Describe fixed facet effects while modeling dependence within Person/testlet blocks.
#> 25                                                                        Score all supplied ratings jointly for a Person without re-estimating calibration.
#> 26                                                                   Describe calibration effects separately from realized rater effects and population SDs.
#> 27                                                         Score requested Persons while retaining the complete scoring roster and shared-rater uncertainty.
#> 28                                                                                 Sampling uncertainty in relative discriminations with geometric mean one.
#> 29                                                                                        Inspect uncertainty about either owner's component discrimination.
#> 30                                                                            Inspect asymmetric slope uncertainty and retain partial or unbounded outcomes.
#> 31                                                                            Describe local variation separately from remaining structural estimation bias.
#> 32                                                                                          Uncertainty in category probabilities or information per rating.
#> 33                                                                        Approximate slope uncertainty under the fitted population and analyzed assignment.
#> 34                                                              Prespecified binary network configurations or node covariates, after estimation diagnostics.
#>                                                                                                                                                                                                                                                                                                                                                                       InterpretationBoundary
#> 1                                                                                                                                                                                                                                                                                                                                  CI width is precision evidence, not a fit pass/fail rule.
#> 2                                                                                                                                                                                                                                                                                                          Fit status still comes from MnSq/ZSTD review; the CI plot is a precision display.
#> 3                                                                                                                                                                                                                                                                                                               Use for targeting and uncertainty context; it is not global model-fit proof.
#> 4                                                                                                                                                                                                                                                                                                               Use for targeting and uncertainty context; it is not global model-fit proof.
#> 5                                                                                                                                                                                                                                     Distance-from-zero guides are not homogeneity, equivalence or rater-quality decisions; use covariance-aware contrasts and a justified practical bound.
#> 6                                                                                                                                                                                                                                                                                         Composite figures orient readers; panel intervals should be interpreted through the source helper.
#> 7                                                                                                                                                                                                            Diagnostic-only: CI_Eligible / FairCIEligible remain FALSE; finite or regularized covariance does not establish full-refit coverage. Gap whiskers hold the observed mean fixed.
#> 8                                                                                                                                                                                                                                                                                    Bias intervals remain screening evidence unless the study design supports stronger inferential wording.
#> 9                                                                                                                                                                                                                                                                                                      Intervals support follow-up review; they do not decide anchor validity by themselves.
#> 10                                                                                                                                                                                   Both routes remain screening-only; adequate linking does not make refit uncertainty formally eligible. Inspect ContrastDirection because residual and severity contrasts use different units and signs.
#> 11                                                                                                                                                                                                                                                                           Requires inference-ready MML and unregularized covariance; pairwise TOST is unadjusted and ROPE is descriptive.
#> 12                                                                                                                                                                                                                                                                                                                             Drift claims require explicit multi-fit wave or form designs.
#> 13                                                                                                                                                                                                                                                                                                  Trajectory movement is interpretable only after the supplied fits are on a common scale.
#> 14                                                                                                                                                                                                    No calibrated coverage or automatic rater-quality decision: prior-variance uncertainty and cross-level covariance are omitted; zero width after full pooling is not perfect precision.
#> 15                                                                                                                                                                                                                                                                                                          ICC intervals describe clustering uncertainty, not model adequacy by themselves.
#> 16                 Sandwich support is limited to fixed-population RSM/PCM and requires many independent Persons or declared larger clusters. One-family GPCM locations use model-information Wald intervals under regular MML assumptions; two-family locations remain experimental. Location differences need not be uniform rating differences. Finite-sample coverage is not guaranteed.
#> 17                                                                                                                                                                                                                                                     Depends on adequate imputations and complete-data inference; excludes EAP pooling, sandwich pooling and simultaneous rater decisions.
#> 18                                                                                                                                                           Native units only; CML supplies no population SD, Person abilities, ordinary diagnostics or consolidated reports. Unidentified targets stay missing. Finite-MLE and information checks do not guarantee finite-sample coverage.
#> 19 Estimated-SD standardization requires a common intercept-only normal population; a regression residual SD is not marginal population SD. Native intervals also admit origin-specific population means. Numerical eligibility and conditional identification are separate from global marginal identification and finite-sample coverage. JML/MML comparison-only fits remain descriptive.
#> 20                                                                                                                                              Experimental RSM/PCM direct MML only. CIEligible describes numerical availability, not established coverage. Not individual ability differences, causal effects, zero-variance boundary inference or calibration-inclusive Person intervals.
#> 21                                                                                                                                                                                                                                                            Nominal coverage is not established; explicit approximation only, not a quality classification. Automatic bounds are withheld.
#> 22                                                                                                                                                                                                                                                                  Positive source SD/SE required. Unresolved roots can give unbounded limits; no general coverage or familywise guarantee.
#> 23                                                                                                                                                                                                                                                       This is a population-variation target, not an interval for any one rater or future score; finite-sample accuracy is not guaranteed.
#> 24                                                                                                                                                                                                                                                       Finite-sample coverage is not established. Estimated variance boundaries withhold bounds; no regular variance interval is supplied.
#> 25                                                                                                                                                                                              Excludes calibration/population estimation uncertainty, Person-contrast inference and simultaneous decisions. Missing Persons return the prior only; zero ability variance withholds scores.
#> 26                                                                                                                                                                                                                                                              Finite-sample coverage is not established. Numerical/information failures and estimated variance boundaries withhold bounds.
#> 27                                                                                                                                                                                                                                       Excludes calibration/population estimation uncertainty, Person contrasts and coverage guarantees. Numerical checks do not certify Laplace accuracy.
#> 28                                                                                                                                                                                            Default relative/model target; explicit options select standardized slopes, contrasts, sandwich or Bonferroni intervals. These are not rater-quality intervals or general coverage guarantees.
#> 29                                                                                                                                                                                                   CIEligible is numerical availability; CoverageQualified remains FALSE. The first family has geometric mean one; the second is free. No two-family sandwich or slope-contrast intervals.
#> 30                                                                                                                                                                                                                           Computed bounds do not prove nominal coverage. An unresolved side is not an infinite limit or a calibrated one-sided interval; search limits are not endpoints.
#> 31                                                                                                                                                                                                                                                                 RootSE is not a qualified structural confidence interval. A covariance or t adjustment alone cannot remove residual bias.
#> 32                                                                                                                                                                                                                                                                                                                  Not Person-score intervals or a continuous simultaneous confidence band.
#> 33                                                                                                                                                                                                                                                            Not an exact small-sample method; failed refits can leave infinite bounds. Null-model LRT draws cannot supply slope intervals.
#> 34                                                                                                                                                                                                                                                                                     Not MFRM parameters, causal halo or estimated-edge uncertainty; backend failure keeps missing bounds.
#>                                                                                          GPCMStatus
#> 1                                                                             supported_with_caveat
#> 2                                                                             supported_with_caveat
#> 3                                                                             supported_with_caveat
#> 4                                                                             supported_with_caveat
#> 5                                                                             supported_with_caveat
#> 6                          rsm_pcm_route; GPCM manuscript claims require explicit capability caveat
#> 7                                                                             supported_with_caveat
#> 8                                                                             supported_with_caveat
#> 9                                                                                  exploratory_only
#> 10                                                                            supported_with_caveat
#> 11                                                    unavailable_when_gpcm_inference_is_ineligible
#> 12                                    exploratory_for_gpcm; linking synthesis supported_with_caveat
#> 13                                    exploratory_for_gpcm; linking synthesis supported_with_caveat
#> 14                                                                                not_gpcm_specific
#> 15                                                                                not_gpcm_specific
#> 16 supported_with_caveat one-family MML locations; experimental two-family; no JML or GPCM sandwich
#> 17                                                                    unavailable; RSM/PCM MML only
#> 18                                                                        unavailable; RSM/PCM only
#> 19                                                                        unavailable; RSM/PCM only
#> 20                                            unavailable; estimated normal RSM/PCM population only
#> 21                                                               unavailable; shared-rater RSM only
#> 22                                                               unavailable; shared-rater RSM only
#> 23                                                               unavailable; shared-rater RSM only
#> 24                                                    unavailable; Person-specific testlet RSM only
#> 25                                                    unavailable; Person-specific testlet RSM only
#> 26                                                               unavailable; shared-rater RSM only
#> 27                                                               unavailable; shared-rater RSM only
#> 28                                         supported_with_caveat; eligible one-family GPCM MML only
#> 29                                           experimental two-family MML only; coverage unqualified
#> 30                                       experimental one- and two-family MML only; no JML profiles
#> 31                                experimental corrected JML only; structural intervals unavailable
#> 32                                         supported_with_caveat; eligible one-family GPCM MML only
#> 33                                         supported_with_caveat; eligible one-family GPCM MML only
#> 34                                                 Network likelihood, not a GPCM rating likelihood
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Notes
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  The helper already adds CI columns to the returned fit-measure table.
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Use this when reviewers ask for a forest-style estimate display.
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             The standard plot route also accepts show_ci and ci_level.
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             This explicit helper is useful for publication-style maps.
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         Use facet = ... for non-Rater severity facets.
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                Designed for RSM/PCM manuscript routes; inspect returned panel data before publication.
#> 7                                                                                                                                                                                                                                                                                                                                                                                                      The table fair_se option provides GPCM-MML structural SEs, not RSM/PCM fair-score SEs; RSM/PCM conditional plot intervals require a fitted model, not only a stored table bundle.
#> 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Heatmaps remain pattern displays and do not draw intervals.
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           Best used after reviewing the underlying displacement table.
#> 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Use together with dif_report() for narrative boundaries.
#> 11                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              The deprecated conf_level alias still routes to ci_level with a warning.
#> 12                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   Pair with build_linking_review() only where that route is in scope.
#> 13                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Use with anchor-linked waves, not independent raw calibrations.
#> 14                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          Requires empirical-Bayes shrinkage output; ordinary fits do not carry all shrinkage columns.
#> 15                                                                                                                                                                                                                                                                                                                                                                                                                                            Requires lme4 for the fitted random-intercept model. Inspect bootstrap failures and ICC_CI_Status; the former profile method is withdrawn.
#> 16                                                                                                                                                                                                                                                     Unit weights and unregularized joint information. Native-location extensions include estimated normal RSM/PCM populations and fixed or intercept-only normal one-family GPCM; two families use fixed N(0,1). Inspect helper-specific scope, Status and scale; standardized contrasts include estimated population-SD uncertainty.
#> 17                                                                                                                                                                                                                                                                                                                                                                                                                                                All completions must qualify on a common identified scale; unassigned events stay unassigned. Inspect Status and the imputation model.
#> 18                                                                                                                                                                                                                                                                                                            Requires method = 'model' and scale = 'native'. Omit comparison_review and contrasts for comparison-only fits: targets and checks are already saved. Retain missing rows, reasons, target weights and joint covariance when saving; see vignette('mfrmr-linking-and-dff').
#> 19                                                                                                                                                                                                                                                               Requires method = 'model', unit weights and a matching review. Fixed N(0,1) has known SD 1; an estimated SD comes from this same fit, never external or empirical Person scores. Inspect helper-specific model, source and numerical checks and retained population assumptions; see vignette('mfrmr-linking-and-dff').
#> 20 Use contrasts = NULL for coefficients and variance only, or supply L with fitted coefficient column names. Requires unit weights, full-rank coding, unanchored centered facets/steps and no interactions. Retain checks, unavailable rows and interpretation_notes; vcov(ci) uses coefficient/log-variance coordinates, with contrast_covariance stored separately. Plots separate coefficients from contrasts, retain unavailable rows and exclude residual variance from their native-ability axis; inspect population_coding, population_spec and contrast_weights in plot_data().
#> 21                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          Numerical/information failures and estimated variance boundaries withhold regular intervals.
#> 22                                                                                                                                                                                                                                                                                                                                                                                                        Generate from the fitted ability population and refit estimated SDs. Preserve all planned draws and inspect tail resolution; saved roots support new levels without refitting.
#> 23                                                                                                                                                                                                                                                                                                                                                                                                                            Profiles need RTMB and refit estimated ability SD; an estimated ability-variance boundary blocks this profile. Failed checks retain the evaluated profile.
#> 24                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Numerical and information checks must pass. Not a random rater shared across Persons.
#> 25                                                                                                                                                                                                                                                                                                                                                                 Unavailable rows retain reasons; new fixed-facet levels are refused. Supply the complete rating set for each Person. Small calibration samples can reduce marginal interval coverage; see vignette('mfrmr-testlets').
#> 26                                                                                                                                                                                                                                                                                                                                                                                                                                 Uses saved estimates and SEs without refitting. Rebuild output from older fits to apply the default; older result bundles retain their stored tables.
#> 27                                                                                                                                                                                                                                                                                                                                                                                                                                                               persons selects outputs, not data. newdata replaces the entire roster. Prior-only and unavailable rows remain explicit.
#> 28                                                                                                                                                                                                                                                                                                                                                                                 Requires current likelihood metadata, adequate convergence/categories, unit weights, q>=31 and positive unregularized information. Ordinary Wright/Pathway maps do not display these slope intervals.
#> 29                                                                                                                                                                                                                                                                                                                                                                                                               Uses the fitted fixed-grid EM or adaptive direct integration route; scale defaults to standardized. Not an interval for the product of two slopes or for rater quality.
#> 30                                                                                                                                                                                                                                                                                                                                                                                                        Select one exact slope level; for two families use a named owner/level value. Profiling refits nuisance parameters and can be costly; displaying saved results does not refit.
#> 31                                                                                                                                                                                                                                                                                                                                                                                                              Inspect correction order, sampling law, point status and covariance reason. Conditional Person posterior intervals are a different target; see gpcm_capability_matrix().
#> 32                                                                                                                                                                                                                                                                                                                                                                                                                                                                           Default model covariance and pointwise intervals; sandwich and finite-grid Bonferroni are explicit options.
#> 33                                                                                                                                                                                                                                                                                                                                                                                                               Default relative 95% pointwise intervals; select scale, level and contrasts explicitly. Generating the bootstrap can be costly; displaying saved output does not refit.
#> 34                                                                                                                                                                                                                                                                                                                                                                                                                           Changing confint level does not change the stored 95% coefficient table/plot. Review MCMC and GOF; numerical availability is not convergence certification.
mfrmr_interval_guide("visual")[, c("Route", "DisplayRoute", "Basis")]
#>                                                  Route
#> 2                              Fit-measure forest plot
#> 3                       Wright map uncertainty overlay
#> 4               Unified Wright map uncertainty overlay
#> 5                               Rater severity profile
#> 6                        Manuscript Figure 1 composite
#> 7                     Fair-average diagnostic interval
#> 8                    Bias-interaction interval overlay
#> 9                        Displacement interval overlay
#> 10                              Group contrast summary
#> 11                       Facet-equivalence ROPE review
#> 12                            Anchor drift forest plot
#> 13                               Rater trajectory plot
#> 14                    Empirical-Bayes shrinkage funnel
#> 15                           Facet ICC interval review
#> 16                Fixed-facet model/sandwich intervals
#> 17                   Assigned-score MI facet intervals
#> 18               CML conditional-information intervals
#> 19                  MML interaction-contrast intervals
#> 20             Conditional-normal population intervals
#> 21 Observed random-rater explicit normal approximation
#> 22           Observed random-rater bootstrap intervals
#> 24                     Testlet fixed-facet calibration
#> 25                   Testlet conditional Person scores
#> 27              Shared-rater conditional Person scores
#> 28                       GPCM relative-slope intervals
#> 29                     GMFRM component-slope intervals
#> 30                        GPCM slope profile intervals
#> 32                              GPCM curve uncertainty
#> 33                      GPCM bootstrap slope intervals
#> 34          Binary rater-network coefficient intervals
#>                                                                                                                                                                                                                                DisplayRoute
#> 2                                                                                                                                                         Use plot(fit_measures, type = "measure_ci", draw = FALSE) for reusable plot data.
#> 3                                                                                                                                                                        Use plot(..., draw = FALSE)$data$locations or draw the base-R map.
#> 4                                                                                                                                          Use plot(..., type = "wright", view = "unified", draw = FALSE)$locations or draw the base-R map.
#> 5                                                                                                                                                                      Use draw = FALSE to reuse the ranked severity table and band labels.
#> 6                                                                                                                                                                Use draw = FALSE to reuse wright, severity, threshold, and summary panels.
#> 7                                                                                                                                     Use plot(..., type = "fair_average", show_ci = TRUE, draw = FALSE)$data; inspect plot_data and notes.
#> 8                                                                                                                                                      Use ranked or scatter views; heatmap and profile views intentionally omit intervals.
#> 9                                                                                                                                                                          Use view = "lollipop" with draw = FALSE for interval-ready data.
#> 10                                                                                                                                                                                     Use draw = FALSE when rebuilding the summary figure.
#> 11                                                                                                                                             Use eligible MML forest/ROPE output for grand-mean proximity; read pairwise TOST separately.
#> 12                                                                                                                                                                         Use draw = FALSE to inspect CI_Lower / CI_Upper before plotting.
#> 13                                                                                                                                                                     Use linked-wave fit lists only; the helper does not perform linking.
#> 14                                                                                                                                 Use on fits augmented by empirical-Bayes shrinkage columns; draw = FALSE returns CI-ready table columns.
#> 15                                                                                                                                                                       Use ICC tables for interval values; plots expose them when finite.
#> 16        For supported MML fits, use plot(result), as_ggplot(result), apa_table(result), or attach it with mfrm_results(fit, intervals = list(raters = result), compute = "never"). See the separate CML and MML interaction routes below.
#> 17                                                                                                                                                                                       Use summary(result) or plot(result, draw = FALSE).
#> 18                                                                                                            summary(result), plot(result), as_ggplot(result), apa_table(result) and saveRDS(result); CML does not support mfrm_results().
#> 19 summary(result), plot(result), as_ggplot(result), apa_table(result) and saveRDS(result); attach with mfrm_results(fit, intervals = list(comparisons = result), compute = "never") for reports and saved plot type = 'facet_comparisons'.
#> 20    summary(ci), vcov(ci), apa_table(ci), plot(ci) or plot(ci, type = 'contrasts'); as_ggplot(ci) reuses saved values. Attach with mfrm_results(fit, intervals = list(population = ci), compute = "never") for reports and table exports.
#> 21                                                                                                                                                   Use plot(fit, intervals = "normal", draw = FALSE); defaults show point estimates only.
#> 22                                                                                                                                                                      Use plot(result, draw = FALSE), summary(result) or confint(result).
#> 24                                                                                              Use plot(fit, facet = 'Rater', intervals = 'normal', level = 0.95) or summary(fit, calibration_intervals = 'normal'). Defaults omit bounds.
#> 25                                                                                                                                                      Use scores$table, summary(scores), plot(scores, draw = FALSE) or as_ggplot(scores).
#> 27                                                                                                                    Use scores$table, summary(scores), plot(scores) or as_ggplot(scores); attach with mfrm_results(fit, scores = scores).
#> 28                                                          plot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(slopes = result)). diagnose_mfrm() retains default relative/model intervals.
#> 29                                                                                                                                       plot(result), apa_table(result); attach with mfrm_results(fit, intervals = list(slopes = result)).
#> 30                                                                                                              print(result), plot(result), apa_table(result, which = "profile_endpoints"); attach the selected profile to mfrm_results().
#> 32                                                                                            plot(result), as_ggplot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(uncertainty = result)).
#> 33                                                                                            plot(result), as_ggplot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(uncertainty = result)).
#> 34                                                                                                                                                                   summary(model); plot(model, type = 'coefficients'); mfrm_report(model)
#>                                                                                                                                                                                                               Basis
#> 2                                                                                                                                 Approximate Wald interval on facet measure recomputed for the requested ci_level.
#> 3                                                                                                                                                     Approximate facet-level SE overlay on the shared logit scale.
#> 4                                                                                                                                                     Approximate facet-level SE overlay on the shared logit scale.
#> 5                                                                                                                                           Approximate Wald interval around centered facet severity using ModelSE.
#> 6                                                                                                                                        Composite overview; interval evidence comes from the rater severity panel.
#> 7                  RSM/PCM plot: focal-measure delta-method interval with thresholds/references fixed. GPCM-MML table/plot: joint structural covariance for non-Person rows, with Person EAP/reference means fixed.
#> 8                                                                                                                      Profile-likelihood limits for GPCM bias rows when available, otherwise per-cell SE fallback.
#> 9                                                                                                                                               Approximate Wald interval around displacement using DisplacementSE.
#> 10                                                                    Residual contrast approximation or refit conditional plug-in interval; refit SEs omit baseline-anchor uncertainty and cross-refit covariance.
#> 11                                                                                                                   Joint MML covariance for pair differences and deviations from the equally weighted facet mean.
#> 12                                                                                                                                               Approximate drift interval using supplied anchor-drift SE columns.
#> 13                                                                                                                                             Approximate per-rater severity interval across already linked waves.
#> 14                                                                                                              Descriptive normal bands from original and plug-in shrunken SEs; variance estimates are held fixed.
#> 15                                                                                                      Explicit parametric percentile bootstrap of refitted ICC ratios; the default supplies point estimates only.
#> 16                                                                                       Pointwise normal intervals from full observed-information or one-way cluster sandwich covariance; estimates are unchanged.
#> 17                                                                                             Rubin pooling of full within-imputation model covariance and between-imputation covariance, with scalar t reference.
#> 18        Pointwise asymptotic Wald intervals from joint conditional information after conditioning on each Person's total and observed roster; comparison-only results reuse saved identified-subspace covariance.
#> 19 Pointwise model-information intervals from the full joint MML covariance. Standardized contrasts use the joint delta-method derivative of contrast/population SD, including SD uncertainty and cross-covariance.
#> 20                                            Pointwise normal coefficient/contrast intervals and exponentiated log-variance intervals, using the inverse full joint MML information including nuisance parameters.
#> 21                                                                                                                                  Normal prediction interval with first-order calibration-adjusted prediction SE.
#> 22                                                                                                   Full-refit parametric prediction-error bootstrap; studentized by default, unscaled error comparison available.
#> 24                                                                                                Explicit observed-information normal approximation for fixed facets and steps in the Person-specific testlet RSM.
#> 25                                                                                       Continuous equal-tail posterior intervals conditional on calibration and the fitted or specified normal Person population.
#> 27                                                                                                       Continuous marginal posterior with joint conditional rater Laplace integration and calibration held fixed.
#> 28                                                                                       Pointwise log-Wald intervals from the inverse full joint MML observed information, with sum-zero log-slope transformation.
#> 29                                                                                                  Experimental component log-Wald intervals from full joint MML information on the fixed N(0,1) population scale.
#> 30                                                                                                       Experimental likelihood-ratio inversion for one selected slope with an asymptotic chi-square(1) reference.
#> 32                                                                                                       Full calibration covariance at fixed native-scale ability and rating context; logit or log transformation.
#> 33                                                                                                                    Fitted-model basic bootstrap errors; unresolved refits enclose all possible empirical limits.
#> 34                                                                                                                     Approximate pointwise normal ERGM coefficient intervals in conditional log-odds coordinates.
mfrmr_interval_guide("gpcm")[, c("Route", "GPCMStatus", "InterpretationBoundary")]
#>                                   Route
#> 7      Fair-average diagnostic interval
#> 8     Bias-interaction interval overlay
#> 10               Group contrast summary
#> 12             Anchor drift forest plot
#> 13                Rater trajectory plot
#> 16 Fixed-facet model/sandwich intervals
#> 28        GPCM relative-slope intervals
#> 29      GMFRM component-slope intervals
#> 30         GPCM slope profile intervals
#> 31 Corrected-JML local root uncertainty
#> 32               GPCM curve uncertainty
#> 33       GPCM bootstrap slope intervals
#>                                                                                          GPCMStatus
#> 7                                                                             supported_with_caveat
#> 8                                                                             supported_with_caveat
#> 10                                                                            supported_with_caveat
#> 12                                    exploratory_for_gpcm; linking synthesis supported_with_caveat
#> 13                                    exploratory_for_gpcm; linking synthesis supported_with_caveat
#> 16 supported_with_caveat one-family MML locations; experimental two-family; no JML or GPCM sandwich
#> 28                                         supported_with_caveat; eligible one-family GPCM MML only
#> 29                                           experimental two-family MML only; coverage unqualified
#> 30                                       experimental one- and two-family MML only; no JML profiles
#> 31                                experimental corrected JML only; structural intervals unavailable
#> 32                                         supported_with_caveat; eligible one-family GPCM MML only
#> 33                                         supported_with_caveat; eligible one-family GPCM MML only
#>                                                                                                                                                                                                                                                                                                                                                       InterpretationBoundary
#> 7                                                                                                                                                                                            Diagnostic-only: CI_Eligible / FairCIEligible remain FALSE; finite or regularized covariance does not establish full-refit coverage. Gap whiskers hold the observed mean fixed.
#> 8                                                                                                                                                                                                                                                                    Bias intervals remain screening evidence unless the study design supports stronger inferential wording.
#> 10                                                                                                                                                                   Both routes remain screening-only; adequate linking does not make refit uncertainty formally eligible. Inspect ContrastDirection because residual and severity contrasts use different units and signs.
#> 12                                                                                                                                                                                                                                                                                                             Drift claims require explicit multi-fit wave or form designs.
#> 13                                                                                                                                                                                                                                                                                  Trajectory movement is interpretable only after the supplied fits are on a common scale.
#> 16 Sandwich support is limited to fixed-population RSM/PCM and requires many independent Persons or declared larger clusters. One-family GPCM locations use model-information Wald intervals under regular MML assumptions; two-family locations remain experimental. Location differences need not be uniform rating differences. Finite-sample coverage is not guaranteed.
#> 28                                                                                                                                                                            Default relative/model target; explicit options select standardized slopes, contrasts, sandwich or Bonferroni intervals. These are not rater-quality intervals or general coverage guarantees.
#> 29                                                                                                                                                                                   CIEligible is numerical availability; CoverageQualified remains FALSE. The first family has geometric mean one; the second is free. No two-family sandwich or slope-contrast intervals.
#> 30                                                                                                                                                                                                           Computed bounds do not prove nominal coverage. An unresolved side is not an infinite limit or a calibrated one-sided interval; search limits are not endpoints.
#> 31                                                                                                                                                                                                                                                 RootSE is not a qualified structural confidence interval. A covariance or t adjustment alone cannot remove residual bias.
#> 32                                                                                                                                                                                                                                                                                                  Not Person-score intervals or a continuous simultaneous confidence band.
#> 33                                                                                                                                                                                                                                            Not an exact small-sample method; failed refits can leave infinite bounds. Null-model LRT draws cannot supply slope intervals.
```
