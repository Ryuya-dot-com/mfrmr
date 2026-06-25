# Figure-reporting template for visual diagnostics

Return a compact, beginner-oriented template that explains where each
visual family normally belongs in a report, which helper to call, what
to say, and what not to claim. Use this static table together with the
dynamic `reporting_checklist(fit, diagnostics)$visual_scope` table: the
template answers "how should I use this figure?", while the checklist
answers "is this figure ready for the current run?".

## Usage

``` r
visual_reporting_template(
  scope = c("all", "manuscript", "appendix", "diagnostic", "surface")
)
```

## Arguments

- scope:

  Which part of the template to return: `"all"` (default),
  `"manuscript"`, `"appendix"`, `"diagnostic"`, or `"surface"`.

## Value

A data.frame with columns:

- `FigureFamily`: short visual family label.

- `Scope`: broad reporting role used for filtering.

- `PrimaryHelper`: public helper or plot route.

- `DefaultPlacement`: recommended location in a report.

- `WhatToReport`: wording focus for results sections or captions.

- `CaptionSkeleton`: caption starter that must be tailored to the study.

- `ResultsWording`: results-sentence starter that must be checked
  against the fitted object and diagnostics.

- `WhatNotToClaim`: common overclaim to avoid.

- `BeginnerCheck`: first thing a new user should inspect.

- `ThreeDPolicy`: whether 3D is recommended, discouraged, or data-only.

## Details

This helper is intentionally conservative. It does not inspect a fitted
object and does not certify that a plot is available. Run
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
for run-specific readiness, then use this table to decide how to
describe the resulting figure.

## Examples

``` r
visual_reporting_template()
#>                        FigureFamily      Scope
#> 1                        Wright map manuscript
#> 2                       Pathway map manuscript
#> 3    Category characteristic curves manuscript
#> 4      Category probability surface    surface
#> 5                Information curves manuscript
#> 6                      QC dashboard diagnostic
#> 7         Unexpected / displacement   appendix
#> 8           Strict marginal visuals   appendix
#> 9                Bias / DFF visuals diagnostic
#> 10                     Residual PCA   appendix
#> 11                Guttman scalogram diagnostic
#> 12                     Residual Q-Q   appendix
#> 13  Rater trajectory (linked waves) diagnostic
#> 14          Rater agreement heatmap diagnostic
#> 15             Response-time review diagnostic
#> 16 Empirical-Bayes shrinkage funnel   appendix
#>                                                                PrimaryHelper
#> 1                         plot(fit, type = "wright", preset = "publication")
#> 2                        plot(fit, type = "pathway", preset = "publication")
#> 3                            plot(fit, type = "ccc", preset = "publication")
#> 4                              plot(fit, type = "ccc_surface", draw = FALSE)
#> 5  compute_information(fit) -> plot_information(..., preset = "publication")
#> 6  plot_qc_dashboard(fit, diagnostics = diagnostics, preset = "publication")
#> 7                                     plot_unexpected(); plot_displacement()
#> 8                              plot_marginal_fit(); plot_marginal_pairwise()
#> 9            plot_bias_interaction(); plot_dif_heatmap(); plot_dif_summary()
#> 10                             analyze_residual_pca() -> plot_residual_pca()
#> 11                    plot_guttman_scalogram(fit, diagnostics = diagnostics)
#> 12                          plot_residual_qq(fit, diagnostics = diagnostics)
#> 13                       plot_rater_trajectory(list(T1 = fit_a, T2 = fit_b))
#> 14              plot_rater_agreement_heatmap(fit, diagnostics = diagnostics)
#> 15                 response_time_review(...); plot_response_time_review(...)
#> 16     plot_shrinkage_funnel(fit_eb, show_ci = TRUE, preset = "publication")
#>                                                                                    DefaultPlacement
#> 1                      Main text when targeting, spread, or shared-logit interpretation is central.
#> 2                 Main text or category-functioning subsection for ordered-category interpretation.
#> 3                       Main text or appendix; pair with pathway when category behavior is central.
#> 4                             Appendix, teaching, review, or downstream interactive rendering only.
#> 5                        Main text when precision or targeting across theta is a substantive claim.
#> 6  Screening dashboard; usually methods appendix or local triage rather than the final main figure.
#> 7                                               Case-review appendix or quality-control supplement.
#> 8                                               Diagnostic appendix after diagnostic_mode = "both".
#> 9             Main text only if interaction/DFF is a study question; otherwise diagnostic appendix.
#> 10                                                   Diagnostic appendix or sensitivity discussion.
#> 11                            Teaching material or diagnostic appendix; not a standalone fit claim.
#> 12                                            Diagnostic appendix or supplement after a fit screen.
#> 13               Diagnostic appendix for rater-training/drift review; requires anchor-linked waves.
#> 14                          Diagnostic appendix when rater count makes the bar-chart form too busy.
#> 15        Diagnostic appendix or data-quality supplement when response-time metadata are available.
#> 16             Appendix or methods supplement when small-N facet estimates were empirically shrunk.
#>                                                                                                           WhatToReport
#> 1                              Describe whether persons, facet levels, and thresholds overlap on the same logit scale.
#> 2                                 Describe expected-score progression and the theta regions where categories dominate.
#> 3                         Describe whether categories peak in the intended order and whether adjacent curves separate.
#> 4                         Describe it as exploratory category-probability support, not as a default manuscript figure.
#> 5                                           Describe where measurement information is highest or weakest across theta.
#> 6                           Describe which components triggered follow-up, not a single pass/fail publication verdict.
#> 7                                                                Describe which responses or levels need local review.
#> 8                                           Describe which facet/category cells or pairwise structures need follow-up.
#> 9                   Describe screened interaction or group-by-facet DFF patterns with low-count and threshold caveats.
#> 10                                     Describe residual structure as exploratory follow-up after the main fit screen.
#> 11 Describe the Guttman-style ordering as a teaching screen and call out where the overlay marks unexpected responses.
#> 12          Describe tail behavior of person-level residuals as exploratory follow-up, not as a formal normality test.
#> 13   Describe rater-level movement across waves under the stated linking assumption; name the anchor route explicitly.
#> 14          Describe pairwise agreement or correlation structure as a compact alternative to the interrater bar chart.
#> 15           Describe rapid/slow response-time patterns by person, facet, or score category as descriptive QC context.
#> 16       Describe how far raw facet estimates moved toward the facet mean and whether confidence whiskers remain wide.
#>                                                                                                                  CaptionSkeleton
#> 1            Figure X. Wright map showing person measures, facet-level locations, and step thresholds on the shared logit scale.
#> 2                     Figure X. Expected score pathway across theta, with dominant-category regions for the fitted rating scale.
#> 3                                   Figure X. Category characteristic curves showing fitted category probabilities across theta.
#> 4    Appendix Figure X. Exploratory category-probability surface showing theta, retained category index, and fitted probability.
#> 5  Figure X. Test information curve showing where the fitted model provides relatively stronger or weaker measurement precision.
#> 6                         Appendix Figure X. Quality-control dashboard summarizing diagnostic components that require follow-up.
#> 7               Appendix Figure X. Local response or level-review display for unexpected responses and displacement diagnostics.
#> 8              Appendix Figure X. Strict marginal diagnostic display for retained facet/category or pairwise follow-up evidence.
#> 9   Figure/Appendix Figure X. Bias or differential-functioning screening display for the specified facet pair or group contrast.
#> 10                      Appendix Figure X. Residual PCA scree or loading display used for exploratory residual-structure review.
#> 11                       Appendix Figure X. Guttman-style person x facet-level response matrix with unexpected-response overlay.
#> 12                                          Appendix Figure X. Normal Q-Q plot of person-level standardized residual aggregates.
#> 13                           Appendix Figure X. Rater severity trajectory across waves under the specified anchor-linking route.
#> 14                                         Appendix Figure X. Pairwise rater x rater agreement heatmap for the specified metric.
#> 15     Appendix Figure X. Descriptive response-time review showing rapid and slow response-time thresholds across rating events.
#> 16  Appendix Figure X. Empirical-Bayes shrinkage funnel showing raw and shrunken facet-level estimates with confidence whiskers.
#>                                                                                                                             ResultsWording
#> 1                 The Wright map was inspected to evaluate targeting and shared-scale overlap among persons, facet levels, and thresholds.
#> 2       The pathway plot was inspected to evaluate whether expected scores and dominant-category regions progressed in the intended order.
#> 3                 The category characteristic curves were inspected to evaluate the ordering and separation of fitted response categories.
#> 4            The category-probability surface was used as exploratory support for understanding the fitted category-probability structure.
#> 5                  The information curve was inspected to identify theta regions with relatively stronger or weaker measurement precision.
#> 6                        The QC dashboard was used as a triage screen to identify components requiring more specific diagnostic follow-up.
#> 7                              Unexpected-response and displacement displays were used to identify local cases or levels requiring review.
#> 8                      Strict marginal displays were used as follow-up evidence for facet/category and pairwise local-dependence patterns.
#> 9                Bias/DFF displays were used to screen interaction or group-functioning patterns under the documented screening threshold.
#> 10                         Residual PCA displays were used as exploratory follow-up for residual structure after the main model dimension.
#> 11 The Guttman scalogram was inspected as an exploratory teaching view of person x facet-level response ordering and unexpected responses.
#> 12                The residual Q-Q plot was inspected as exploratory follow-up on the distribution of person-level standardized residuals.
#> 13                  The rater trajectory plot was inspected, under the stated anchor-linking assumption, to screen for drift across waves.
#> 14                   The pairwise agreement heatmap was inspected as a compact alternative to the bar-chart form of the interrater review.
#> 15                       Response-time summaries were inspected as descriptive quality-control context outside the fitted MFRM likelihood.
#> 16                         The shrinkage funnel was inspected to show which small-N facet levels moved most after empirical-Bayes pooling.
#>                                                                                                        WhatNotToClaim
#> 1                                                              Do not present targeting as proof of global model fit.
#> 2                                   Do not treat smooth category progression as proof that the rating scale is valid.
#> 3             Do not overstate overlapping curves as definitive category failure without category counts and context.
#> 4  Use the surface as exploratory mfrmr output or downstream renderer input; prefer 2D CCC/pathway plots for reports.
#> 5                                Do not ignore the precision tier or approximation caveats used to compute the curve.
#> 6                                                            Do not cite the dashboard alone as inferential evidence.
#> 7                                                 Do not interpret a single flagged case as final evidence by itself.
#> 8                                                Do not treat strict marginal visuals as standalone hypothesis tests.
#> 9                               Do not claim formal DIF unless the design and inferential route support that wording.
#> 10                                                     Do not treat residual PCA as a standalone dimensionality test.
#> 11                         Do not treat the scalogram as a global fit claim; it is a teaching-oriented ordering view.
#> 12                                                              Do not treat the Q-Q plot as a formal normality test.
#> 13                       Do not claim rater drift without an explicit anchor-linking route across the supplied waves.
#> 14                            Do not treat agreement or correlation heatmap cells as formal reliability coefficients.
#> 15       Do not treat response-time flags as speed-accuracy parameters, cheating proof, or automatic exclusion rules.
#> 16                              Do not treat shrinkage movement as automatic evidence of rater quality or facet bias.
#>                                                                                                      BeginnerCheck
#> 1                                                   Check gaps between person density and thresholds/facet levels.
#> 2                                        Check whether the dominant-category bands progress in the expected order.
#> 3                                          Check whether every retained category has a visible peak or clear role.
#> 4                       Read surface$data$category_support and surface$data$interpretation_guide before rendering.
#> 5                                          Check whether the information peak covers the theta region of interest.
#> 6                                                   Open the component rows or plots behind any dashboard warning.
#> 7                                     Sort by magnitude and inspect repeated patterns, not isolated extremes only.
#> 8                                   Confirm diagnostic_mode = "both" and inspect low-count or sparse-cell caveats.
#> 9              Confirm the tested facet pair or group-by-facet contrast, low-count cells, and screening threshold.
#> 10                                   Start with the scree plot, then inspect loadings only for targeted follow-up.
#> 11            Check whether the overlay concentrates in a few persons/facet cells rather than spreading uniformly.
#> 12           Check whether the tails depart sharply from the identity line before claiming non-Gaussian residuals.
#> 13                    Confirm that the waves share an anchor or were post-hoc linked before interpreting movement.
#> 14         Switch between metric = "exact" and metric = "correlation" and check that both tell a consistent story.
#> 15 Start with the distribution plot, then inspect whether rapid/slow rates concentrate in persons or facet levels.
#> 16            Start with the longest raw-to-shrunken segments and compare their CI width before and after pooling.
#>                                                           ThreeDPolicy
#> 1                      2D recommended; 3D Wright maps are discouraged.
#> 2                                                   2D report default.
#> 3                                                   2D report default.
#> 4  advanced surface data only; no package-native interactive renderer.
#> 5           2D curve route active; 3D information surface is deferred.
#> 6                               2D dashboard only; 3D not recommended.
#> 7                                    2D point/profile views preferred.
#> 8                                      2D heatmap/bar views preferred.
#> 9                                  2D heatmap/profile views preferred.
#> 10                                        2D scree/loadings preferred.
#> 11                              2D matrix display; 3D not recommended.
#> 12                                  2D Q-Q display; 3D not applicable.
#> 13                          2D trajectory display; 3D not recommended.
#> 14                             2D heatmap display; 3D not recommended.
#> 15       2D distribution and grouped dot displays; 3D not recommended.
#> 16                  2D caterpillar/funnel display; 3D not recommended.
visual_reporting_template("manuscript")
#>                     FigureFamily      Scope
#> 1                     Wright map manuscript
#> 2                    Pathway map manuscript
#> 3 Category characteristic curves manuscript
#> 5             Information curves manuscript
#>                                                               PrimaryHelper
#> 1                        plot(fit, type = "wright", preset = "publication")
#> 2                       plot(fit, type = "pathway", preset = "publication")
#> 3                           plot(fit, type = "ccc", preset = "publication")
#> 5 compute_information(fit) -> plot_information(..., preset = "publication")
#>                                                                    DefaultPlacement
#> 1      Main text when targeting, spread, or shared-logit interpretation is central.
#> 2 Main text or category-functioning subsection for ordered-category interpretation.
#> 3       Main text or appendix; pair with pathway when category behavior is central.
#> 5        Main text when precision or targeting across theta is a substantive claim.
#>                                                                                   WhatToReport
#> 1      Describe whether persons, facet levels, and thresholds overlap on the same logit scale.
#> 2         Describe expected-score progression and the theta regions where categories dominate.
#> 3 Describe whether categories peak in the intended order and whether adjacent curves separate.
#> 5                   Describe where measurement information is highest or weakest across theta.
#>                                                                                                                 CaptionSkeleton
#> 1           Figure X. Wright map showing person measures, facet-level locations, and step thresholds on the shared logit scale.
#> 2                    Figure X. Expected score pathway across theta, with dominant-category regions for the fitted rating scale.
#> 3                                  Figure X. Category characteristic curves showing fitted category probabilities across theta.
#> 5 Figure X. Test information curve showing where the fitted model provides relatively stronger or weaker measurement precision.
#>                                                                                                                       ResultsWording
#> 1           The Wright map was inspected to evaluate targeting and shared-scale overlap among persons, facet levels, and thresholds.
#> 2 The pathway plot was inspected to evaluate whether expected scores and dominant-category regions progressed in the intended order.
#> 3           The category characteristic curves were inspected to evaluate the ordering and separation of fitted response categories.
#> 5            The information curve was inspected to identify theta regions with relatively stronger or weaker measurement precision.
#>                                                                                            WhatNotToClaim
#> 1                                                  Do not present targeting as proof of global model fit.
#> 2                       Do not treat smooth category progression as proof that the rating scale is valid.
#> 3 Do not overstate overlapping curves as definitive category failure without category counts and context.
#> 5                    Do not ignore the precision tier or approximation caveats used to compute the curve.
#>                                                               BeginnerCheck
#> 1            Check gaps between person density and thresholds/facet levels.
#> 2 Check whether the dominant-category bands progress in the expected order.
#> 3   Check whether every retained category has a visible peak or clear role.
#> 5   Check whether the information peak covers the theta region of interest.
#>                                                 ThreeDPolicy
#> 1            2D recommended; 3D Wright maps are discouraged.
#> 2                                         2D report default.
#> 3                                         2D report default.
#> 5 2D curve route active; 3D information surface is deferred.
visual_reporting_template("surface")
#>                   FigureFamily   Scope
#> 4 Category probability surface surface
#>                                   PrimaryHelper
#> 4 plot(fit, type = "ccc_surface", draw = FALSE)
#>                                                        DefaultPlacement
#> 4 Appendix, teaching, review, or downstream interactive rendering only.
#>                                                                                   WhatToReport
#> 4 Describe it as exploratory category-probability support, not as a default manuscript figure.
#>                                                                                                               CaptionSkeleton
#> 4 Appendix Figure X. Exploratory category-probability surface showing theta, retained category index, and fitted probability.
#>                                                                                                                  ResultsWording
#> 4 The category-probability surface was used as exploratory support for understanding the fitted category-probability structure.
#>                                                                                                       WhatNotToClaim
#> 4 Use the surface as exploratory mfrmr output or downstream renderer input; prefer 2D CCC/pathway plots for reports.
#>                                                                                BeginnerCheck
#> 4 Read surface$data$category_support and surface$data$interpretation_guide before rendering.
#>                                                          ThreeDPolicy
#> 4 advanced surface data only; no package-native interactive renderer.
mfrmr_interval_guide("visual")[, c("Route", "PrimaryHelper", "DefaultLevel")]
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
#>                                                                                                                  PrimaryHelper
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
#>    DefaultLevel
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
```
