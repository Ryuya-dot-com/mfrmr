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

- `DefaultLevel`

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

## See also

[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
[`visual_reporting_template()`](https://ryuya-dot-com.github.io/mfrmr/reference/visual_reporting_template.md),
[`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md),
[`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md),
[`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
[`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md),
[`plot_rater_severity_profile()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_severity_profile.md),
[`plot_apa_figure_one()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_apa_figure_one.md),
[`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md),
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md),
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
#> 18 Observed random-rater explicit normal approximation
#> 19           Observed random-rater bootstrap intervals
#> 20                  Random-rater population SD profile
#> 21                     Testlet fixed-facet calibration
#> 22                   Testlet conditional Person scores
#> 23       Shared-rater fixed-facet and step calibration
#> 24              Shared-rater conditional Person scores
#> 25                       GPCM relative-slope intervals
#> 26                              GPCM curve uncertainty
#> 27                      GPCM bootstrap slope intervals
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
#> 16          table,visual,fit,reporting
#> 17          table,visual,fit,reporting
#> 18          table,visual,fit,reporting
#> 19          table,visual,fit,reporting
#> 20                 table,fit,reporting
#> 21          table,visual,fit,reporting
#> 22          table,visual,fit,reporting
#> 23                 table,fit,reporting
#> 24          table,visual,fit,reporting
#> 25     gpcm,visual,table,fit,reporting
#> 26         gpcm,visual,table,reporting
#> 27         gpcm,visual,table,reporting
#>                                                                                                                  PrimaryHelper
#> 1                                                                                          fit_measures_table(ci_level = 0.95)
#> 2                                                          fit_measures_table(...); plot(type = "measure_ci", ci_level = 0.95)
#> 3                                                                  plot(fit, type = "wright", show_ci = TRUE, ci_level = 0.95)
#> 4                                                                    plot_wright_unified(fit, show_ci = TRUE, ci_level = 0.95)
#> 5                                                                            plot_rater_severity_profile(fit, ci_level = 0.95)
#> 6                                                                                    plot_apa_figure_one(fit, ci_level = 0.95)
#> 7       plot_fair_average(fit, show_ci = TRUE, ci_level = 0.95); fair_average_table(fit_gpcm, fair_se = TRUE, ci_level = 0.95)
#> 8                                                                  plot_bias_interaction(..., show_ci = TRUE, ci_level = 0.95)
#> 9                                                                      plot_displacement(..., show_ci = TRUE, ci_level = 0.95)
#> 10                                                                                                       plot_dif_summary(...)
#> 11                                                        analyze_facet_equivalence(ci_level = 0.95); plot_facet_equivalence()
#> 12                                                                detect_anchor_drift(...); plot_anchor_drift(ci_level = 0.95)
#> 13                                                                                 plot_rater_trajectory(..., ci_level = 0.95)
#> 14 plot_shrinkage_funnel(..., show_ci = TRUE, ci_level = 0.95); plot(fit, type = "shrinkage", show_ci = TRUE, ci_level = 0.95)
#> 15                           compute_facet_icc(ci_method = "boot", ci_level = 0.95); plot(analyze_hierarchical_structure(...))
#> 16                                                         mfrm_facet_intervals(fit, facet, method = "sandwich", level = 0.95)
#> 17                                                                         pool_mfrm_imputed(analyses, facet, ci_level = 0.95)
#> 18                                                                                 confint(fit, parm = "raters", level = 0.95)
#> 19                                                      mfrm_random_rater_intervals(fit, nsim = 499, seed = 123, level = 0.95)
#> 20                                                                               confint(fit, parm = "rater_sd", level = 0.95)
#> 21                                                                            confint(fit, parm = 'calibration', level = 0.95)
#> 22                                                                                               predict(testlet_fit, newdata)
#> 23                                                                            confint(fit, parm = 'calibration', level = 0.95)
#> 24                                                                                 score_mfrm_random_rater(fit, persons = ids)
#> 25                                                                                 confint(fit, parm = "slopes", level = 0.95)
#> 26                                                                                             mfrm_curve_intervals(fit, grid)
#> 27                                                                               confint(bootstrap_mfrm_gpcm(fit, seed = 123))
#>                                                                                                                                                                       DisplayRoute
#> 1                                                                                                                                          Use the returned table or facets_table.
#> 2                                                                                                Use plot(fit_measures, type = "measure_ci", draw = FALSE) for reusable plot data.
#> 3                                                                                                               Use plot(..., draw = FALSE)$data$locations or draw the base-R map.
#> 4                                                                                                     Use plot_wright_unified(..., draw = FALSE)$locations or draw the base-R map.
#> 5                                                                                                             Use draw = FALSE to reuse the ranked severity table and band labels.
#> 6                                                                                                       Use draw = FALSE to reuse wright, severity, threshold, and summary panels.
#> 7                                                                                      Use plot_fair_average(..., show_ci = TRUE, draw = FALSE)$data; inspect plot_data and notes.
#> 8                                                                                             Use ranked or scatter views; heatmap and profile views intentionally omit intervals.
#> 9                                                                                                            Use plot_type = "lollipop" with draw = FALSE for interval-ready data.
#> 10                                                                                                                            Use draw = FALSE when rebuilding the summary figure.
#> 11                                                                                    Use eligible MML forest/ROPE output for grand-mean proximity; read pairwise TOST separately.
#> 12                                                                                                                Use draw = FALSE to inspect CI_Lower / CI_Upper before plotting.
#> 13                                                                                                            Use linked-wave fit lists only; the helper does not perform linking.
#> 14                                                                        Use on fits augmented by empirical-Bayes shrinkage columns; draw = FALSE returns CI-ready table columns.
#> 15                                                                                                              Use ICC tables for interval values; plots expose them when finite.
#> 16                              Use plot(result), as_ggplot(result), apa_table(result), or attach it with mfrm_results(fit, intervals = list(raters = result), compute = "never").
#> 17                                                                                                                              Use summary(result) or plot(result, draw = FALSE).
#> 18                                                                                          Use plot(fit, intervals = "normal", draw = FALSE); defaults show point estimates only.
#> 19                                                                                                             Use plot(result, draw = FALSE), summary(result) or confint(result).
#> 20                                                                                                                                 Inspect the interval and its profile attribute.
#> 21                                     Use plot(fit, facet = 'Rater', intervals = 'normal', level = 0.95) or summary(fit, calibration_intervals = 'normal'). Defaults omit bounds.
#> 22                                                                                             Use scores$table, summary(scores), plot(scores, draw = FALSE) or as_ggplot(scores).
#> 23        Use summary(fit, calibration_intervals = 'normal', level = 0.95) or mfrm_results(fit, calibration_intervals = 'normal', calibration_level = 0.95). Defaults omit bounds.
#> 24                                                           Use scores$table, summary(scores), plot(scores) or as_ggplot(scores); attach with mfrm_results(fit, scores = scores).
#> 25 plot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(slopes = result)). diagnose_mfrm() retains default relative/model intervals.
#> 26                                   plot(result), as_ggplot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(uncertainty = result)).
#> 27                                   plot(result), as_ggplot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(uncertainty = result)).
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
#> 16                                                                                                                      Lower, Upper, SE, ModelLower, ModelUpper, ModelSE, Status
#> 17                                                                                                                                                   Lower, Upper, SE, DF, Status
#> 18                                                                                                                               Lower, Upper; method, target and note attributes
#> 19                                                                                                                                           Lower, Upper; availability attribute
#> 20                                                                                                                                                Lower, Upper; profile attribute
#> 21                                                                                                                                                               Lower, Upper, SE
#> 22                                                                                                                                    Lower, Upper, ConditionalSD, Status, Reason
#> 23                                                                                                                                                               Lower, Upper, SE
#> 24                                                                                                                                    Lower, Upper, ConditionalSD, Status, Reason
#> 25                                                                                                                Lower, Upper; CIEligible, CIUse, InferenceReview in diagnostics
#> 26                                                                                                                                      Lower, Upper, CIEligible, InferenceReview
#> 27                                                                                                                         Matrix bounds; diagnostics and availability attributes
#>                                                                                                                                                                                               Basis
#> 1                                                                                                                                  Approximate Wald interval on facet measure: estimate +/- z * SE.
#> 2                                                                                                                 Approximate Wald interval on facet measure recomputed for the requested ci_level.
#> 3                                                                                                                                     Approximate facet-level SE overlay on the shared logit scale.
#> 4                                                                                                                                     Approximate facet-level SE overlay on the shared logit scale.
#> 5                                                                                                                           Approximate Wald interval around centered facet severity using ModelSE.
#> 6                                                                                                                        Composite overview; interval evidence comes from the rater severity panel.
#> 7  RSM/PCM plot: focal-measure delta-method interval with thresholds/references fixed. GPCM-MML table/plot: joint structural covariance for non-Person rows, with Person EAP/reference means fixed.
#> 8                                                                                                      Profile-likelihood limits for GPCM bias rows when available, otherwise per-cell SE fallback.
#> 9                                                                                                                               Approximate Wald interval around displacement using DisplacementSE.
#> 10                                                    Residual contrast approximation or refit conditional plug-in interval; refit SEs omit baseline-anchor uncertainty and cross-refit covariance.
#> 11                                                                                                   Joint MML covariance for pair differences and deviations from the equally weighted facet mean.
#> 12                                                                                                                               Approximate drift interval using supplied anchor-drift SE columns.
#> 13                                                                                                                             Approximate per-rater severity interval across already linked waves.
#> 14                                                                                              Descriptive normal bands from original and plug-in shrunken SEs; variance estimates are held fixed.
#> 15                                                                                      Explicit parametric percentile bootstrap of refitted ICC ratios; the default supplies point estimates only.
#> 16                                                                       Pointwise normal intervals from full observed-information or one-way cluster sandwich covariance; estimates are unchanged.
#> 17                                                                             Rubin pooling of full within-imputation model covariance and between-imputation covariance, with scalar t reference.
#> 18                                                                                                                  Normal prediction interval with first-order calibration-adjusted prediction SE.
#> 19                                                                                   Full-refit parametric prediction-error bootstrap; studentized by default, unscaled error comparison available.
#> 20                                                                                                               Profile likelihood with an asymptotic one-degree chi-square cutoff; includes zero.
#> 21                                                                                Explicit observed-information normal approximation for fixed facets and steps in the Person-specific testlet RSM.
#> 22                                                                       Continuous equal-tail posterior intervals conditional on calibration and the fitted or specified normal Person population.
#> 23                                                                                           Explicit observed-information normal approximation for fixed facets and steps in the shared-rater RSM.
#> 24                                                                                       Continuous marginal posterior with joint conditional rater Laplace integration and calibration held fixed.
#> 25                                                                       Pointwise log-Wald intervals from the inverse full joint MML observed information, with sum-zero log-slope transformation.
#> 26                                                                                       Full calibration covariance at fixed native-scale ability and rating context; logit or log transformation.
#> 27                                                                                                    Fitted-model basic bootstrap errors; unresolved refits enclose all possible empirical limits.
#>                                                                                                         UseFor
#> 1                                                           Report facet estimates with uncertainty in tables.
#> 2                           Show which facet levels have wide measure uncertainty before discussing fit flags.
#> 3                                           Show targeting and location uncertainty on a compact variable map.
#> 4                                       Show targeting and uncertainty across persons, facets, and thresholds.
#> 5                            Give rater-training feedback with uncertainty and gentle / strict severity bands.
#> 6                                   Build a manuscript Figure 1 overview while preserving reusable panel data.
#> 7  Inspect fair-score uncertainty separately from historical measure-level SE columns; FairZ is not a z-score.
#> 8                       Screen interaction-bias cells while showing uncertainty around the bias-size estimate.
#> 9                     Review anchor or calibration tension without treating displacement as a binary decision.
#> 10            Describe group residual differences; linked refit intervals require separate uncertainty review.
#> 11          Decide whether an interval lies within, overlaps, or falls outside the practical equivalence band.
#> 12                                      Review whether common elements drift materially across forms or waves.
#> 13                                         Inspect rater movement across anchored waves or training occasions.
#> 14                                                  Show how much partial pooling moved noisy facet estimates.
#> 15                    Report clustering / nesting uncertainty without treating ICC alone as a design decision.
#> 16      Compare uncertainty for fixed facet estimates and prespecified contrasts, including rater differences.
#> 17     Report eligible fixed facet estimates and contrasts after proper imputation of missing assigned scores.
#> 18                           Describe realized observed-rater effects relative to the assumed population mean.
#> 19             Compare model-based pointwise prediction intervals for the same realized observed-rater target.
#> 20            Estimate variation across the assumed rater population, including at an estimated zero variance.
#> 21                        Describe fixed facet effects while modeling dependence within Person/testlet blocks.
#> 22                          Score all supplied ratings jointly for a Person without re-estimating calibration.
#> 23                     Describe calibration effects separately from realized rater effects and population SDs.
#> 24           Score requested Persons while retaining the complete scoring roster and shared-rater uncertainty.
#> 25                                   Sampling uncertainty in relative discriminations with geometric mean one.
#> 26                                            Uncertainty in category probabilities or information per rating.
#> 27                          Approximate slope uncertainty under the fitted population and analyzed assignment.
#>                                                                                                                                                                                     InterpretationBoundary
#> 1                                                                                                                                                CI width is precision evidence, not a fit pass/fail rule.
#> 2                                                                                                                        Fit status still comes from MnSq/ZSTD review; the CI plot is a precision display.
#> 3                                                                                                                             Use for targeting and uncertainty context; it is not global model-fit proof.
#> 4                                                                                                                             Use for targeting and uncertainty context; it is not global model-fit proof.
#> 5                                                                                                                    Severity bands are calibration feedback, not automatic operational removal decisions.
#> 6                                                                                                       Composite figures orient readers; panel intervals should be interpreted through the source helper.
#> 7                          Diagnostic-only: CI_Eligible / FairCIEligible remain FALSE; finite or regularized covariance does not establish full-refit coverage. Gap whiskers hold the observed mean fixed.
#> 8                                                                                                  Bias intervals remain screening evidence unless the study design supports stronger inferential wording.
#> 9                                                                                                                    Intervals support follow-up review; they do not decide anchor validity by themselves.
#> 10 Both routes remain screening-only; adequate linking does not make refit uncertainty formally eligible. Inspect ContrastDirection because residual and severity contrasts use different units and signs.
#> 11                                                                                         Requires inference-ready MML and unregularized covariance; pairwise TOST is unadjusted and ROPE is descriptive.
#> 12                                                                                                                                           Drift claims require explicit multi-fit wave or form designs.
#> 13                                                                                                                Trajectory movement is interpretable only after the supplied fits are on a common scale.
#> 14                  No calibrated coverage or automatic rater-quality decision: prior-variance uncertainty and cross-level covariance are omitted; zero width after full pooling is not perfect precision.
#> 15                                                                                                                        ICC intervals describe clustering uncertainty, not model adequacy by themselves.
#> 16                                               Requires many independent Persons or declared larger clusters; covariance correction does not remove misspecification bias or establish general coverage.
#> 17                                                                   Depends on adequate imputations and complete-data inference; excludes EAP pooling, sandwich pooling and simultaneous rater decisions.
#> 18                                                                          Nominal coverage is not established; explicit approximation only, not a quality classification. Automatic bounds are withheld.
#> 19                                                                                Positive source SD/SE required. Unresolved roots can give unbounded limits; no general coverage or familywise guarantee.
#> 20                                                                     This is a population-variation target, not an interval for any one rater or future score; finite-sample accuracy is not guaranteed.
#> 21                                                                     Finite-sample coverage is not established. Estimated variance boundaries withhold bounds; no regular variance interval is supplied.
#> 22            Excludes calibration/population estimation uncertainty, Person-contrast inference and simultaneous decisions. Missing Persons return the prior only; zero ability variance withholds scores.
#> 23                                                                            Finite-sample coverage is not established. Numerical/information failures and estimated variance boundaries withhold bounds.
#> 24                                                     Excludes calibration/population estimation uncertainty, Person contrasts and coverage guarantees. Numerical checks do not certify Laplace accuracy.
#> 25          Default relative/model target; explicit options select standardized slopes, contrasts, sandwich or Bonferroni intervals. These are not rater-quality intervals or general coverage guarantees.
#> 26                                                                                                                                Not Person-score intervals or a continuous simultaneous confidence band.
#> 27                                                                          Not an exact small-sample method; failed refits can leave infinite bounds. Null-model LRT draws cannot supply slope intervals.
#>                                                                  GPCMStatus
#> 1                                                     supported_with_caveat
#> 2                                                     supported_with_caveat
#> 3                                                     supported_with_caveat
#> 4                                                     supported_with_caveat
#> 5                                                     supported_with_caveat
#> 6  rsm_pcm_route; GPCM manuscript claims require explicit capability caveat
#> 7                                                     supported_with_caveat
#> 8                                                     supported_with_caveat
#> 9                                                          exploratory_only
#> 10                                                    supported_with_caveat
#> 11                            unavailable_when_gpcm_inference_is_ineligible
#> 12            exploratory_for_gpcm; linking synthesis supported_with_caveat
#> 13            exploratory_for_gpcm; linking synthesis supported_with_caveat
#> 14                                                        not_gpcm_specific
#> 15                                                        not_gpcm_specific
#> 16                                            unavailable; RSM/PCM MML only
#> 17                                            unavailable; RSM/PCM MML only
#> 18                                       unavailable; shared-rater RSM only
#> 19                                       unavailable; shared-rater RSM only
#> 20                                       unavailable; shared-rater RSM only
#> 21                            unavailable; Person-specific testlet RSM only
#> 22                            unavailable; Person-specific testlet RSM only
#> 23                                       unavailable; shared-rater RSM only
#> 24                                       unavailable; shared-rater RSM only
#> 25                     supported_with_caveat; eligible native GPCM MML only
#> 26                     supported_with_caveat; eligible native GPCM MML only
#> 27                     supported_with_caveat; eligible native GPCM MML only
#>                                                                                                                                                                                                                    Notes
#> 1                                                                                                                                                  The helper already adds CI columns to the returned fit-measure table.
#> 2                                                                                                                                                       Use this when reviewers ask for a forest-style estimate display.
#> 3                                                                                                                                                             The standard plot route also accepts show_ci and ci_level.
#> 4                                                                                                                                                             This explicit helper is useful for publication-style maps.
#> 5                                                                                                                                                                         Use facet = ... for non-Rater severity facets.
#> 6                                                                                                                                Designed for RSM/PCM manuscript routes; inspect returned panel data before publication.
#> 7                                      The table fair_se option provides GPCM-MML structural SEs, not RSM/PCM fair-score SEs; RSM/PCM conditional plot intervals require a fitted model, not only a stored table bundle.
#> 8                                                                                                                                                            Heatmaps remain pattern displays and do not draw intervals.
#> 9                                                                                                                                                           Best used after reviewing the underlying displacement table.
#> 10                                                                                                                                                              Use together with dif_report() for narrative boundaries.
#> 11                                                                                                                                              The deprecated conf_level alias still routes to ci_level with a warning.
#> 12                                                                                                                                                   Pair with build_linking_review() only where that route is in scope.
#> 13                                                                                                                                                       Use with anchor-linked waves, not independent raw calibrations.
#> 14                                                                                                                          Requires empirical-Bayes shrinkage output; ordinary fits do not carry all shrinkage columns.
#> 15                                                                            Requires lme4 for the fitted random-intercept model. Inspect bootstrap failures and ICC_CI_Status; the former profile method is withdrawn.
#> 16                                                                Fixed-standard-normal MML, unit weights, fixed quadrature and unregularized information. Inspect Status; not replacement-rater or G/D-study inference.
#> 17                                                                                All completions must qualify on a common identified scale; unassigned events stay unassigned. Inspect Status and the imputation model.
#> 18                                                                                                                          Numerical/information failures and estimated variance boundaries withhold regular intervals.
#> 19                                        Generate from the fitted ability population and refit estimated SDs. Preserve all planned draws and inspect tail resolution; saved roots support new levels without refitting.
#> 20                                                            Profiles need RTMB and refit estimated ability SD; an estimated ability-variance boundary blocks this profile. Failed checks retain the evaluated profile.
#> 21                                                                                                                                 Numerical and information checks must pass. Not a random rater shared across Persons.
#> 22 Unavailable rows retain reasons; new fixed-facet levels are refused. Supply the complete rating set for each Person. Small calibration samples can reduce marginal interval coverage; see vignette('mfrmr-testlets').
#> 23                                                                 Uses saved estimates and SEs without refitting. Rebuild output from older fits to apply the default; older result bundles retain their stored tables.
#> 24                                                                                               persons selects outputs, not data. newdata replaces the entire roster. Prior-only and unavailable rows remain explicit.
#> 25                 Requires current likelihood metadata, adequate convergence/categories, unit weights, q>=31 and positive unregularized information. Ordinary Wright/Pathway maps do not display these slope intervals.
#> 26                                                                                                           Default model covariance and pointwise intervals; sandwich and finite-grid Bonferroni are explicit options.
#> 27                                               Default relative 95% pointwise intervals; select scale, level and contrasts explicitly. Generating the bootstrap can be costly; displaying saved output does not refit.
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
#> 18 Observed random-rater explicit normal approximation
#> 19           Observed random-rater bootstrap intervals
#> 21                     Testlet fixed-facet calibration
#> 22                   Testlet conditional Person scores
#> 24              Shared-rater conditional Person scores
#> 25                       GPCM relative-slope intervals
#> 26                              GPCM curve uncertainty
#> 27                      GPCM bootstrap slope intervals
#>                                                                                                                                                                       DisplayRoute
#> 2                                                                                                Use plot(fit_measures, type = "measure_ci", draw = FALSE) for reusable plot data.
#> 3                                                                                                               Use plot(..., draw = FALSE)$data$locations or draw the base-R map.
#> 4                                                                                                     Use plot_wright_unified(..., draw = FALSE)$locations or draw the base-R map.
#> 5                                                                                                             Use draw = FALSE to reuse the ranked severity table and band labels.
#> 6                                                                                                       Use draw = FALSE to reuse wright, severity, threshold, and summary panels.
#> 7                                                                                      Use plot_fair_average(..., show_ci = TRUE, draw = FALSE)$data; inspect plot_data and notes.
#> 8                                                                                             Use ranked or scatter views; heatmap and profile views intentionally omit intervals.
#> 9                                                                                                            Use plot_type = "lollipop" with draw = FALSE for interval-ready data.
#> 10                                                                                                                            Use draw = FALSE when rebuilding the summary figure.
#> 11                                                                                    Use eligible MML forest/ROPE output for grand-mean proximity; read pairwise TOST separately.
#> 12                                                                                                                Use draw = FALSE to inspect CI_Lower / CI_Upper before plotting.
#> 13                                                                                                            Use linked-wave fit lists only; the helper does not perform linking.
#> 14                                                                        Use on fits augmented by empirical-Bayes shrinkage columns; draw = FALSE returns CI-ready table columns.
#> 15                                                                                                              Use ICC tables for interval values; plots expose them when finite.
#> 16                              Use plot(result), as_ggplot(result), apa_table(result), or attach it with mfrm_results(fit, intervals = list(raters = result), compute = "never").
#> 17                                                                                                                              Use summary(result) or plot(result, draw = FALSE).
#> 18                                                                                          Use plot(fit, intervals = "normal", draw = FALSE); defaults show point estimates only.
#> 19                                                                                                             Use plot(result, draw = FALSE), summary(result) or confint(result).
#> 21                                     Use plot(fit, facet = 'Rater', intervals = 'normal', level = 0.95) or summary(fit, calibration_intervals = 'normal'). Defaults omit bounds.
#> 22                                                                                             Use scores$table, summary(scores), plot(scores, draw = FALSE) or as_ggplot(scores).
#> 24                                                           Use scores$table, summary(scores), plot(scores) or as_ggplot(scores); attach with mfrm_results(fit, scores = scores).
#> 25 plot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(slopes = result)). diagnose_mfrm() retains default relative/model intervals.
#> 26                                   plot(result), as_ggplot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(uncertainty = result)).
#> 27                                   plot(result), as_ggplot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(uncertainty = result)).
#>                                                                                                                                                                                               Basis
#> 2                                                                                                                 Approximate Wald interval on facet measure recomputed for the requested ci_level.
#> 3                                                                                                                                     Approximate facet-level SE overlay on the shared logit scale.
#> 4                                                                                                                                     Approximate facet-level SE overlay on the shared logit scale.
#> 5                                                                                                                           Approximate Wald interval around centered facet severity using ModelSE.
#> 6                                                                                                                        Composite overview; interval evidence comes from the rater severity panel.
#> 7  RSM/PCM plot: focal-measure delta-method interval with thresholds/references fixed. GPCM-MML table/plot: joint structural covariance for non-Person rows, with Person EAP/reference means fixed.
#> 8                                                                                                      Profile-likelihood limits for GPCM bias rows when available, otherwise per-cell SE fallback.
#> 9                                                                                                                               Approximate Wald interval around displacement using DisplacementSE.
#> 10                                                    Residual contrast approximation or refit conditional plug-in interval; refit SEs omit baseline-anchor uncertainty and cross-refit covariance.
#> 11                                                                                                   Joint MML covariance for pair differences and deviations from the equally weighted facet mean.
#> 12                                                                                                                               Approximate drift interval using supplied anchor-drift SE columns.
#> 13                                                                                                                             Approximate per-rater severity interval across already linked waves.
#> 14                                                                                              Descriptive normal bands from original and plug-in shrunken SEs; variance estimates are held fixed.
#> 15                                                                                      Explicit parametric percentile bootstrap of refitted ICC ratios; the default supplies point estimates only.
#> 16                                                                       Pointwise normal intervals from full observed-information or one-way cluster sandwich covariance; estimates are unchanged.
#> 17                                                                             Rubin pooling of full within-imputation model covariance and between-imputation covariance, with scalar t reference.
#> 18                                                                                                                  Normal prediction interval with first-order calibration-adjusted prediction SE.
#> 19                                                                                   Full-refit parametric prediction-error bootstrap; studentized by default, unscaled error comparison available.
#> 21                                                                                Explicit observed-information normal approximation for fixed facets and steps in the Person-specific testlet RSM.
#> 22                                                                       Continuous equal-tail posterior intervals conditional on calibration and the fitted or specified normal Person population.
#> 24                                                                                       Continuous marginal posterior with joint conditional rater Laplace integration and calibration held fixed.
#> 25                                                                       Pointwise log-Wald intervals from the inverse full joint MML observed information, with sum-zero log-slope transformation.
#> 26                                                                                       Full calibration covariance at fixed native-scale ability and rating context; logit or log transformation.
#> 27                                                                                                    Fitted-model basic bootstrap errors; unresolved refits enclose all possible empirical limits.
mfrmr_interval_guide("gpcm")[, c("Route", "GPCMStatus", "InterpretationBoundary")]
#>                                Route
#> 7   Fair-average diagnostic interval
#> 8  Bias-interaction interval overlay
#> 10            Group contrast summary
#> 12          Anchor drift forest plot
#> 13             Rater trajectory plot
#> 25     GPCM relative-slope intervals
#> 26            GPCM curve uncertainty
#> 27    GPCM bootstrap slope intervals
#>                                                       GPCMStatus
#> 7                                          supported_with_caveat
#> 8                                          supported_with_caveat
#> 10                                         supported_with_caveat
#> 12 exploratory_for_gpcm; linking synthesis supported_with_caveat
#> 13 exploratory_for_gpcm; linking synthesis supported_with_caveat
#> 25          supported_with_caveat; eligible native GPCM MML only
#> 26          supported_with_caveat; eligible native GPCM MML only
#> 27          supported_with_caveat; eligible native GPCM MML only
#>                                                                                                                                                                                     InterpretationBoundary
#> 7                          Diagnostic-only: CI_Eligible / FairCIEligible remain FALSE; finite or regularized covariance does not establish full-refit coverage. Gap whiskers hold the observed mean fixed.
#> 8                                                                                                  Bias intervals remain screening evidence unless the study design supports stronger inferential wording.
#> 10 Both routes remain screening-only; adequate linking does not make refit uncertainty formally eligible. Inspect ContrastDirection because residual and severity contrasts use different units and signs.
#> 12                                                                                                                                           Drift claims require explicit multi-fit wave or form designs.
#> 13                                                                                                                Trajectory movement is interpretable only after the supplied fits are on a common scale.
#> 25          Default relative/model target; explicit options select standardized slopes, contrasts, sandwich or Bonferroni intervals. These are not rater-quality intervals or general coverage guarantees.
#> 26                                                                                                                                Not Person-score intervals or a continuous simultaneous confidence band.
#> 27                                                                          Not an exact small-sample method; failed refits can leave infinite bounds. Null-model LRT draws cannot supply slope intervals.
```
