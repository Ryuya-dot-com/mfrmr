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
[`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md)

## Examples

``` r
mfrmr_interval_guide()
#>                                     Route                               Scope
#> 1                 Facet-measure fit table                 table,fit,reporting
#> 2                 Fit-measure forest plot                visual,fit,reporting
#> 3          Wright map uncertainty overlay                visual,fit,reporting
#> 4  Unified Wright map uncertainty overlay                visual,fit,reporting
#> 5                  Rater severity profile                visual,fit,reporting
#> 6           Manuscript Figure 1 composite                visual,fit,reporting
#> 7        Fair-average structural interval         table,visual,gpcm,reporting
#> 8       Bias-interaction interval overlay          visual,bias,gpcm,reporting
#> 9           Displacement interval overlay            visual,linking,reporting
#> 10             DFF / DIF contrast summary          visual,bias,gpcm,reporting
#> 11          Facet-equivalence ROPE review  table,visual,equivalence,reporting
#> 12               Anchor drift forest plot       visual,linking,gpcm,reporting
#> 13                  Rater trajectory plot       visual,linking,gpcm,reporting
#> 14       Empirical-Bayes shrinkage funnel          visual,shrinkage,reporting
#> 15              Facet ICC interval review table,visual,hierarchical,reporting
#>                                                                                                                  PrimaryHelper
#> 1                                                                                          fit_measures_table(ci_level = 0.95)
#> 2                                                          fit_measures_table(...); plot(type = "measure_ci", ci_level = 0.95)
#> 3                                                                  plot(fit, type = "wright", show_ci = TRUE, ci_level = 0.95)
#> 4                                                                    plot_wright_unified(fit, show_ci = TRUE, ci_level = 0.95)
#> 5                                                                            plot_rater_severity_profile(fit, ci_level = 0.95)
#> 6                                                                                    plot_apa_figure_one(fit, ci_level = 0.95)
#> 7                                                                          fair_average_table(fair_se = TRUE, ci_level = 0.95)
#> 8                                                                  plot_bias_interaction(..., show_ci = TRUE, ci_level = 0.95)
#> 9                                                                      plot_displacement(..., show_ci = TRUE, ci_level = 0.95)
#> 10                                                                                      plot_dif_summary(..., ci_level = 0.95)
#> 11                                                        analyze_facet_equivalence(ci_level = 0.95); plot_facet_equivalence()
#> 12                                                                detect_anchor_drift(...); plot_anchor_drift(ci_level = 0.95)
#> 13                                                                                 plot_rater_trajectory(..., ci_level = 0.95)
#> 14 plot_shrinkage_funnel(..., show_ci = TRUE, ci_level = 0.95); plot(fit, type = "shrinkage", show_ci = TRUE, ci_level = 0.95)
#> 15                                               compute_facet_icc(ci_level = 0.95); plot(analyze_hierarchical_structure(...))
#>                                                                                                DisplayRoute
#> 1                                                                   Use the returned table or facets_table.
#> 2                         Use plot(fit_measures, type = "measure_ci", draw = FALSE) for reusable plot data.
#> 3                                        Use plot(..., draw = FALSE)$data$locations or draw the base-R map.
#> 4                              Use plot_wright_unified(..., draw = FALSE)$locations or draw the base-R map.
#> 5                                      Use draw = FALSE to reuse the ranked severity table and band labels.
#> 6                                Use draw = FALSE to reuse wright, severity, threshold, and summary panels.
#> 7                          Use plot_fair_average(..., show_ci = TRUE, draw = FALSE) for CI-ready plot data.
#> 8                      Use ranked or scatter views; heatmap and profile views intentionally omit intervals.
#> 9                                     Use plot_type = "lollipop" with draw = FALSE for interval-ready data.
#> 10                                                     Use draw = FALSE when rebuilding the summary figure.
#> 11                                         Use forest/ROPE review output for equivalence-focused reporting.
#> 12                                         Use draw = FALSE to inspect CI_Lower / CI_Upper before plotting.
#> 13                                     Use linked-wave fit lists only; the helper does not perform linking.
#> 14 Use on fits augmented by empirical-Bayes shrinkage columns; draw = FALSE returns CI-ready table columns.
#> 15                                       Use ICC tables for interval values; plots expose them when finite.
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
#>                                                                                                                  IntervalColumns
#> 1                                                                                                   CI_Lower, CI_Upper, CI_Level
#> 2                                                                                                   CI_Lower, CI_Upper, CI_Level
#> 3                                                                                      CI_Lower, CI_Upper, CI_Level in locations
#> 4                                                                                      CI_Lower, CI_Upper, CI_Level in locations
#> 5                                                                                  Level, Estimate, SE, CI_Lower, CI_Upper, Band
#> 6                                                                           severity panel includes CI_Lower, CI_Upper, ci_level
#> 7  AdjustedAverageCI_Lower, AdjustedAverageCI_Upper, AdjustedAverageCI_Level; plot data also uses CI_Lower / CI_Upper / CI_Level
#> 8                                                                  CI_Lower, CI_Upper, CI_Level on ranked_table and scatter_data
#> 9                                                                                                   CI_Lower, CI_Upper, CI_Level
#> 10                                                                  CI_Lower, CI_Upper, CI_Level when contrast SEs are available
#> 11                                                           CI_Lower, CI_Upper, CI_Level plus equivalence / ROPE status columns
#> 12                                                                                                  CI_Lower, CI_Upper, CI_Level
#> 13                                                                                                  CI_Lower, CI_Upper, CI_Level
#> 14                                        RawCI_Lower, RawCI_Upper, ShrunkCI_Lower, ShrunkCI_Upper, CI_Level when show_ci = TRUE
#> 15                                                                       ICC_CI_Lower, ICC_CI_Upper, ICC_CI_Level, ICC_CI_Method
#>                                                                                                                                    Basis
#> 1                                                                       Approximate Wald interval on facet measure: estimate +/- z * SE.
#> 2                                                      Approximate Wald interval on facet measure recomputed for the requested ci_level.
#> 3                                                                          Approximate facet-level SE overlay on the shared logit scale.
#> 4                                                                          Approximate facet-level SE overlay on the shared logit scale.
#> 5                                                                Approximate Wald interval around centered facet severity using ModelSE.
#> 6                                                             Composite overview; interval evidence comes from the rater severity panel.
#> 7  Structural delta-method fair-average interval when the MML covariance route is available; otherwise interval status remains explicit.
#> 8                                   Profile-likelihood limits for bounded GPCM bias rows when available, otherwise per-cell SE fallback.
#> 9                                                                    Approximate Wald interval around displacement using DisplacementSE.
#> 10                                              Approximate contrast interval from the DFF / DIF contrast table when SE evidence exists.
#> 11                                                                  Model-based interval compared with the requested equivalence bounds.
#> 12                                                                    Approximate drift interval using supplied anchor-drift SE columns.
#> 13                                                                  Approximate per-rater severity interval across already linked waves.
#> 14                                           Approximate Wald-style whiskers around original and shrunken estimates using SE / ShrunkSE.
#> 15                                                     Profile or fallback interval for ICC, depending on optional backend availability.
#>                                                                                                UseFor
#> 1                                                  Report facet estimates with uncertainty in tables.
#> 2                  Show which facet levels have wide measure uncertainty before discussing fit flags.
#> 3                                  Show targeting and location uncertainty on a compact variable map.
#> 4                              Show targeting and uncertainty across persons, facets, and thresholds.
#> 5                   Give rater-training feedback with uncertainty and gentle / strict severity bands.
#> 6                          Build a manuscript Figure 1 overview while preserving reusable panel data.
#> 7    Report slope-aware fair-average uncertainty separately from historical measure-level SE columns.
#> 8              Screen interaction-bias cells while showing uncertainty around the bias-size estimate.
#> 9            Review anchor or calibration tension without treating displacement as a binary decision.
#> 10               Display group-by-facet contrast uncertainty before writing DFF / DIF interpretation.
#> 11 Decide whether an interval lies within, overlaps, or falls outside the practical equivalence band.
#> 12                             Review whether common elements drift materially across forms or waves.
#> 13                                Inspect rater movement across anchored waves or training occasions.
#> 14                                         Show how much partial pooling moved noisy facet estimates.
#> 15           Report clustering / nesting uncertainty without treating ICC alone as a design decision.
#>                                                                                     InterpretationBoundary
#> 1                                                CI width is precision evidence, not a fit pass/fail rule.
#> 2                        Fit status still comes from MnSq/ZSTD review; the CI plot is a precision display.
#> 3                             Use for targeting and uncertainty context; it is not global model-fit proof.
#> 4                             Use for targeting and uncertainty context; it is not global model-fit proof.
#> 5                    Severity bands are calibration feedback, not automatic operational removal decisions.
#> 6       Composite figures orient readers; panel intervals should be interpreted through the source helper.
#> 7         Keep structural fair-average intervals distinct from historical FACETS-style measure SE columns.
#> 8  Bias intervals remain screening evidence unless the study design supports stronger inferential wording.
#> 9                    Intervals support follow-up review; they do not decide anchor validity by themselves.
#> 10     DFF / DIF wording still depends on grouping design, linking support, and the chosen analysis route.
#> 11                Equivalence is a practical review against stated bounds, not a universal validity claim.
#> 12                                           Drift claims require explicit multi-fit wave or form designs.
#> 13                Trajectory movement is interpretable only after the supplied fits are on a common scale.
#> 14               Shrinkage intervals describe estimation stability, not automatic rater-quality decisions.
#> 15                        ICC intervals describe clustering uncertainty, not model adequacy by themselves.
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
#> 11           rsm_pcm_route; use GPCM only as documented sensitivity context
#> 12            exploratory_for_gpcm; linking synthesis supported_with_caveat
#> 13            exploratory_for_gpcm; linking synthesis supported_with_caveat
#> 14                                                        not_gpcm_specific
#> 15                                                        not_gpcm_specific
#>                                                                                           Notes
#> 1                         The helper already adds CI columns to the returned fit-measure table.
#> 2                              Use this when reviewers ask for a forest-style estimate display.
#> 3                                    The standard plot route also accepts show_ci and ci_level.
#> 4                                    This explicit helper is useful for publication-style maps.
#> 5                                                Use facet = ... for non-Rater severity facets.
#> 6       Designed for RSM/PCM manuscript routes; inspect returned panel data before publication.
#> 7                            Under bounded GPCM this is slope-aware direct output with caveats.
#> 8                                   Heatmaps remain pattern displays and do not draw intervals.
#> 9                                  Best used after reviewing the underlying displacement table.
#> 10                                     Use together with dif_report() for narrative boundaries.
#> 11                     The deprecated conf_level alias still routes to ci_level with a warning.
#> 12                          Pair with build_linking_review() only where that route is in scope.
#> 13                              Use with anchor-linked waves, not independent raw calibrations.
#> 14 Requires empirical-Bayes shrinkage output; ordinary fits do not carry all shrinkage columns.
#> 15                              Optional profile intervals depend on installed backend support.
mfrmr_interval_guide("visual")[, c("Route", "DisplayRoute", "Basis")]
#>                                     Route
#> 2                 Fit-measure forest plot
#> 3          Wright map uncertainty overlay
#> 4  Unified Wright map uncertainty overlay
#> 5                  Rater severity profile
#> 6           Manuscript Figure 1 composite
#> 7        Fair-average structural interval
#> 8       Bias-interaction interval overlay
#> 9           Displacement interval overlay
#> 10             DFF / DIF contrast summary
#> 11          Facet-equivalence ROPE review
#> 12               Anchor drift forest plot
#> 13                  Rater trajectory plot
#> 14       Empirical-Bayes shrinkage funnel
#> 15              Facet ICC interval review
#>                                                                                                DisplayRoute
#> 2                         Use plot(fit_measures, type = "measure_ci", draw = FALSE) for reusable plot data.
#> 3                                        Use plot(..., draw = FALSE)$data$locations or draw the base-R map.
#> 4                              Use plot_wright_unified(..., draw = FALSE)$locations or draw the base-R map.
#> 5                                      Use draw = FALSE to reuse the ranked severity table and band labels.
#> 6                                Use draw = FALSE to reuse wright, severity, threshold, and summary panels.
#> 7                          Use plot_fair_average(..., show_ci = TRUE, draw = FALSE) for CI-ready plot data.
#> 8                      Use ranked or scatter views; heatmap and profile views intentionally omit intervals.
#> 9                                     Use plot_type = "lollipop" with draw = FALSE for interval-ready data.
#> 10                                                     Use draw = FALSE when rebuilding the summary figure.
#> 11                                         Use forest/ROPE review output for equivalence-focused reporting.
#> 12                                         Use draw = FALSE to inspect CI_Lower / CI_Upper before plotting.
#> 13                                     Use linked-wave fit lists only; the helper does not perform linking.
#> 14 Use on fits augmented by empirical-Bayes shrinkage columns; draw = FALSE returns CI-ready table columns.
#> 15                                       Use ICC tables for interval values; plots expose them when finite.
#>                                                                                                                                    Basis
#> 2                                                      Approximate Wald interval on facet measure recomputed for the requested ci_level.
#> 3                                                                          Approximate facet-level SE overlay on the shared logit scale.
#> 4                                                                          Approximate facet-level SE overlay on the shared logit scale.
#> 5                                                                Approximate Wald interval around centered facet severity using ModelSE.
#> 6                                                             Composite overview; interval evidence comes from the rater severity panel.
#> 7  Structural delta-method fair-average interval when the MML covariance route is available; otherwise interval status remains explicit.
#> 8                                   Profile-likelihood limits for bounded GPCM bias rows when available, otherwise per-cell SE fallback.
#> 9                                                                    Approximate Wald interval around displacement using DisplacementSE.
#> 10                                              Approximate contrast interval from the DFF / DIF contrast table when SE evidence exists.
#> 11                                                                  Model-based interval compared with the requested equivalence bounds.
#> 12                                                                    Approximate drift interval using supplied anchor-drift SE columns.
#> 13                                                                  Approximate per-rater severity interval across already linked waves.
#> 14                                           Approximate Wald-style whiskers around original and shrunken estimates using SE / ShrunkSE.
#> 15                                                     Profile or fallback interval for ICC, depending on optional backend availability.
mfrmr_interval_guide("gpcm")[, c("Route", "GPCMStatus", "InterpretationBoundary")]
#>                                Route
#> 7   Fair-average structural interval
#> 8  Bias-interaction interval overlay
#> 10        DFF / DIF contrast summary
#> 12          Anchor drift forest plot
#> 13             Rater trajectory plot
#>                                                       GPCMStatus
#> 7                                          supported_with_caveat
#> 8                                          supported_with_caveat
#> 10                                         supported_with_caveat
#> 12 exploratory_for_gpcm; linking synthesis supported_with_caveat
#> 13 exploratory_for_gpcm; linking synthesis supported_with_caveat
#>                                                                                     InterpretationBoundary
#> 7         Keep structural fair-average intervals distinct from historical FACETS-style measure SE columns.
#> 8  Bias intervals remain screening evidence unless the study design supports stronger inferential wording.
#> 10     DFF / DIF wording still depends on grouping design, linking support, and the chosen analysis route.
#> 12                                           Drift claims require explicit multi-fit wave or form designs.
#> 13                Trajectory movement is interpretable only after the supplied fits are on a common scale.
```
