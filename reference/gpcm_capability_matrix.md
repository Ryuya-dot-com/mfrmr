# Bounded GPCM Support Matrix

Public capability map for the current `GPCM` scope in `mfrmr`.

Use this helper when you need to answer a practical question quickly:
which `GPCM` workflows are supported in this release, which are
available only with explicit caveats, and which helpers remain blocked
or deferred, plus the route to use instead when the requested helper is
outside the current boundary.

The matrix is intentionally conservative. It is a release-scope
statement, not a promise that every lower-level helper can be combined
with `GPCM`. If a helper is not yet covered by the current validation
boundary, it is listed as `blocked` or `deferred` even when related
components already exist.

## Usage

``` r
gpcm_capability_matrix(
  status = c("all", "supported", "supported_with_caveat", "blocked", "deferred")
)
```

## Arguments

- status:

  Which rows to return: `"all"` (default), `"supported"`,
  `"supported_with_caveat"`, `"blocked"`, or `"deferred"`.

## Value

A data.frame with one row per public helper family and columns:

- `Area`

- `Helpers`

- `Status`

- `PrimaryUse`

- `Boundary`

- `Evidence`

- `RecommendedRoute`

- `NextValidationStep`

## Details

The current release treats `GPCM` as a bounded supported scope inside
the core R package:

- fitting and core summaries are supported,

- posterior-scoring and information helpers are supported,

- residual-based diagnostics and strict marginal follow-up are supported
  as exploratory screens,

- direct slope-aware simulation-spec generation and parameter-recovery
  simulation are supported with caveats,

- [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  is supported with an explicit slope-aware element-conditional caveat,

- [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  is supported as conditional screening evidence with slope-aware
  information and profile-likelihood follow-up columns,

- summary-table appendix export is available for supported direct
  outputs,

- APA writer, visual summaries, QC pipelines, manifests, replay scripts,
  and fit-based export bundles are available only as caveated
  sensitivity-reporting surfaces with an explicit `gpcm_boundary`,

- package-native scorefile export is available with score-side caveats,

- role-based design evaluation and population forecasting are available
  as caveated bounded-`GPCM` sensitivity evidence,

- role-based diagnostic and signal-detection design screening helpers
  are available as caveated bounded-`GPCM` sensitivity evidence,

- full FACETS output-contract score-side review remains outside the
  validated `GPCM` boundary.

Why some helpers remain blocked:

- full FACETS output-contract score-side review depends on Rasch-family
  measure-to-score semantics plus delta-method SE machinery that are not
  yet generalized to the free-discrimination `GPCM` branch;

- APA writer, fit-based report/export bundles, visual summaries, and QC
  pipelines stay caveated because they must not turn unsupported
  score-side semantics into narrative or pass/fail outputs;

- diagnostic, signal-detection, design-forecast, and linking helpers
  stay caveated because their simulation/refit summaries must not become
  operational screening, scoring, or arbitrary-facet planning claims.

This boundary is aligned with the package's current validation evidence,
including the targeted `GPCM` recovery snapshot and the public workflow
checks.

## Typical workflow

1.  Call `gpcm_capability_matrix()` before using `GPCM` in a new
    workflow.

2.  Stay on rows marked `supported` or `supported_with_caveat` for the
    current release.

3.  For `blocked` and `deferred` rows, read `RecommendedRoute` before
    choosing a substitute workflow.

4.  Treat `blocked` rows as explicit non-support, not as temporary
    omissions.

5.  Treat `deferred` rows as future-extension targets rather than part
    of the current user-facing support.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
[`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[mfrmr-package](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)

## Examples

``` r
gpcm_capability_matrix()
#>                                                                   Area
#> 1                                           Core fitting and summaries
#> 2                       Exploratory diagnostics and residual follow-up
#> 3                            Fixed-calibration scoring and information
#> 4                                        Core curve and category views
#> 5                           Checklist and summary-table appendix route
#> 6                                          Operational misfit casebook
#> 7                             Weighting review and model-choice review
#> 8                                        Operational linking synthesis
#> 9                       Direct simulation-spec generation and recovery
#> 10                             APA writer and fit-based export bundles
#> 11             Fair-average semantics under bounded GPCM (slope-aware)
#> 12     Design evaluation and population forecasting under bounded GPCM
#> 13 Diagnostic and signal-detection design screening under bounded GPCM
#> 14         Differential facet functioning screening under bounded GPCM
#> 15                                   MCMC and heavy-backend extensions
#> 16                          Residual-bias screening under bounded GPCM
#> 17                      Score-side scorefile export under bounded GPCM
#> 18                            FACETS output-contract score-side review
#>                                                                                                                                                                                                                                                                      Helpers
#> 1                                                                                                                                                                                                                               fit_mfrm(model = "GPCM"); summary(); print()
#> 2  diagnose_mfrm(); analyze_residual_pca(); unexpected_response_table(); displacement_table(); measurable_summary_table(); rating_scale_table(); interrater_agreement_table(); facet_quality_dashboard(); plot_qc_dashboard(); plot_marginal_fit(); plot_marginal_pairwise()
#> 3                                                                                                                                                                            predict_mfrm_units(); sample_mfrm_plausible_values(); compute_information(); plot_information()
#> 4                                                                                                        plot(fit, type = c("wright", "pathway", "ccc", "ccc_surface")); category_structure_report(); category_curves_report(); facets_output_file_bundle(include = "graph")
#> 5                                                                                                                                                                  reporting_checklist(); precision_review_report(); build_summary_table_bundle(); export_summary_appendix()
#> 6                                                                                                                                                                                                                                                    build_misfit_casebook()
#> 7                                                                                                  compare_mfrm(); build_model_choice_review(); build_weighting_review(); compute_information(); plot_information(); build_summary_table_bundle(); export_summary_appendix()
#> 8                                                                                                                                                                                                                                                     build_linking_review()
#> 9                                                                                                                                                     build_mfrm_sim_spec(); extract_mfrm_sim_spec(); simulate_mfrm_data(); evaluate_mfrm_recovery(); assess_mfrm_recovery()
#> 10                                                                                                                                 build_apa_outputs(); build_visual_summaries(); run_qc_pipeline(); build_mfrm_manifest(); build_mfrm_replay_script(); export_mfrm_bundle()
#> 11                                                                                                                                                                                                                                                      fair_average_table()
#> 12                                                                                                                                                                                                                         evaluate_mfrm_design(); predict_mfrm_population()
#> 13                                                                                                                                                                                                    evaluate_mfrm_diagnostic_screening(); evaluate_mfrm_signal_detection()
#> 14                                                                                                                                                               analyze_dff(); analyze_dif(); dif_interaction_table(); dif_report(); plot_dif_heatmap(); plot_dif_summary()
#> 15                                                                                                                                                                     cpp11 backend promotion; posterior predictive computation; MCMC engine; Docker-based advanced runtime
#> 16                                                                                                                                                                                                                                                           estimate_bias()
#> 17                                                                                                                                                                                                                              facets_output_file_bundle(include = "score")
#> 18                                                                                                                                                                                                                                           facets_output_contract_review()
#>                   Status
#> 1              supported
#> 2  supported_with_caveat
#> 3              supported
#> 4              supported
#> 5  supported_with_caveat
#> 6  supported_with_caveat
#> 7  supported_with_caveat
#> 8  supported_with_caveat
#> 9  supported_with_caveat
#> 10 supported_with_caveat
#> 11 supported_with_caveat
#> 12 supported_with_caveat
#> 13 supported_with_caveat
#> 14 supported_with_caveat
#> 15              deferred
#> 16 supported_with_caveat
#> 17 supported_with_caveat
#> 18               blocked
#>                                                                                                                    PrimaryUse
#> 1                                           Estimate bounded GPCM models and inspect convergence, steps, and slope summaries.
#> 2                                              Screen local misfit, residual structure, and agreement patterns after fitting.
#> 3                                      Score new units or review design-weighted precision under the fitted GPCM calibration.
#> 4                    Inspect targeting, category progression, and category-probability behavior under the generalized kernel.
#> 5                                        Check which direct tables and plots are draft-ready and export their summary tables.
#> 6                     Combine residual, strict marginal, unexpected-response, and displacement screens into one review queue.
#> 7                       Review whether bounded GPCM is introducing substantively acceptable discrimination-based reweighting.
#> 8                                           Synthesize anchor, drift, and chain evidence into one exploratory review surface.
#> 9      Generate or extract slope-aware simulation specifications, sample responses, and run direct parameter-recovery checks.
#> 10      Produce caveated manuscript-draft prose, fit-based report bundles, manifests, replay scripts, or full export bundles.
#> 11                               Compute slope-aware element-conditional fair-average score adjustments for reporting tables.
#> 12 Evaluate role-based future designs or forecast one future administration with repeated bounded-GPCM simulation/refit runs.
#> 13                                             Run diagnostic-screening or signal-detection operating-characteristic studies.
#> 14                                 Review group-by-facet differential-functioning patterns as slope-aware screening evidence.
#> 15                                                                     Move beyond the current core-package release boundary.
#> 16                                   Screen residual two-way interaction-bias cells under bounded GPCM at the screening tier.
#> 17             Export observation-level slope-aware expected score, residual, probability, and slope fields for bounded GPCM.
#> 18   Run the full FACETS-style output-contract score-side review that depends on validated free-discrimination score metrics.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Boundary
#> 1                                                                                                                                                                                                                                                                                                                                                                                               Requires an explicit step facet and currently keeps `slope_facet == step_facet`; MML direct is the validated default, and EM/hybrid fall back to direct.
#> 2                                                                                                                                                                                                                                                                                                                Residual-based mean-square and strict-marginal outputs remain exploratory screening tools because discrimination is free. The dashboard's fair-average panel reports an explicit unavailability status when the underlying fit is GPCM.
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                          Covers fixed-calibration posterior scoring and information only; population forecasting is a separate layer outside this row.
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                         Limited to the slope-aware probability kernel that is already generalized for the current bounded GPCM branch.
#> 5                                                                                                                                                                                                                                                                                                                                                                 Routes users to supported direct tables and plots. Caveated manuscript-draft APA and fit-based export bundles are governed by their separate capability row and carry `gpcm_boundary`.
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                      Supported with caveat for bounded GPCM because the casebook inherits exploratory screening semantics from its underlying sources.
#> 7                                                                                                                                                                                                                                                                                                                                                                              Supported with caveat because the helper is an operational review of Rasch-family equal weighting versus bounded GPCM reweighting, not an automatic model-selection rule.
#> 8                                                                                                                                                                                                                                                                                                      Supported with caveat as an exploratory synthesis over already-built anchor review, drift, and chain objects. It does not establish an operational GPCM linking decision, anchor-drift absence claim, or equating-chain adequacy claim by itself.
#> 9                                                                                                                                                                                                                Requires explicit slope-aware specifications and keeps the current bounded branch's facet-role restrictions. Recovery checks are direct simulation/refit summaries, not design-planning or forecasting claims. `assess_mfrm_recovery()` requires user-supplied practical thresholds before RMSE or bias can be interpreted as adequate.
#> 10                                                                                                                                                                                                                                                        Supported with caveat as a partial reporting/export bundle over already-supported GPCM diagnostics, direct tables, plots, manifests, and replay scripts. Full FACETS-style score-side contract review, design forecasting, and automatic operational scoring claims remain outside this route.
#> 11                                                                                          Slope-aware element-conditional construction: slope-facet element rows use that level's own slope; non-slope-facet rows (Person, Rater, ...) use the geometric-mean-one slope by identification convention. The historical SE columns in the output are scaled facet-measure SEs, not fair-average SEs. Use `fair_se = TRUE` to request structural delta-method fair-average SEs for non-person rows when the MML observed-information Hessian is available.
#> 12                                                                                                    Supported with caveat as a role-based person x rater-like x criterion-like Monte Carlo simulation/refit route. It uses the bounded-GPCM generator and refits bounded GPCM with the supplied or fit-derived step/slope facet contract, but it reports design-level operating characteristics only. Slope-recovery adequacy, diagnostic screening operating characteristics, signal detection, and arbitrary- facet planning remain separate routes.
#> 13                                                                                                                                                                               Supported with caveat as slope-aware repeated simulation/refit screening evidence for the current role-based person x rater-like x criterion-like design layer. The summaries are Type I proxy, sensitivity proxy, DIF target-flag, and bias-screening readouts, not calibrated inferential tests, operational screening gates, or arbitrary-facet planning validation.
#> 14                                                                                                                                                                                                                                Supported with caveat as direct DFF/DIF screening over the fitted bounded-GPCM expected-score and residual scale. Residual-method contrasts and interaction cells remain screening evidence; refit contrasts must retain explicit linking and precision gates before any stronger subgroup-comparison wording is used.
#> 15                                                                                                                                                                                                                                                                                                                                                                                                                                                         Future extensions, listed for transparency. Out of scope for the current bounded GPCM branch.
#> 16 Bias point estimates use the slope-aware GPCM kernel: the bias parameter is the additive shift on the linear predictor that maximises the per-cell GPCM log-likelihood. `LR ChiSq`, `LR Prob.`, and profile-CI columns compare that fitted shift with zero by conditional profile likelihood. SE / t / Prob columns use conditional plug-in information at the bias point estimate. All quantities hold theta, steps, slopes, and other facet estimates fixed, so they support screening and follow-up review rather than standalone fairness claims.
#> 17                                                                                                Supported with caveat for package-native scorefile export only. Rows carry fitted expected score, residual, standardized residual, observed-category probability, score slope, native structural expected-score uncertainty, selectable score-side delta SEs, and explicit caveat fields when the required MML diagnostics are available. The route does not export FACETS-equivalent score-side SEs or establish operational score-scale equivalence.
#> 18                                                                                                                                                                                                                                                                                                          Not yet generalized to the full FACETS-style output-contract review. Direct scorefile export is available with caveats, but contract-wide coverage and metric claims still require a broader free-discrimination score-side review contract.
#>                                                                     Evidence
#> 1                          covered by estimation and output-stability checks
#> 2                             covered by diagnostic and marginal-plot checks
#> 3                                  covered by scoring and information checks
#> 4                             covered by curve, plot, and information checks
#> 5              covered by reporting-route and summary-appendix export checks
#> 6                           covered by misfit-casebook and diagnostic checks
#> 7                         covered by weighting-review and information checks
#> 8                      covered by exploratory linking-review guardrail tests
#> 9                      covered by slope-aware simulation and recovery checks
#> 10                 covered by partial-reporting and export-bundle GPCM tests
#> 11  covered by reduction-to-PCM and worked-example numerical-agreement tests
#> 12             covered by caveated GPCM design-evaluation and forecast tests
#> 13  covered by caveated GPCM diagnostic and signal-detection screening tests
#> 14      covered by caveated GPCM DFF summary, report, and plot-payload tests
#> 15                                                          future extension
#> 16                    covered by an end-to-end test on a fitted GPCM example
#> 17 covered by GPCM scorefile export, native uncertainty, and guardrail tests
#> 18                 not yet validated for free-discrimination score semantics
#>                                                                                                                                                                                                                                                                                            RecommendedRoute
#> 1                                                                                                                                                                                               Use `fit_mfrm(..., model = "GPCM", step_facet = ..., slope_facet = step_facet)` and inspect `summary(fit)`.
#> 2                                                                                                                                                        Use diagnostics as screening evidence and return to direct residual, unexpected-response, displacement, and category tables before writing claims.
#> 3                                                                                                                                                                        Use fixed-calibration scoring and `compute_information()` / `plot_information()`; keep population forecasting on a separate route.
#> 4                                                                                                                                                                                                         Use draw-free plot objects and category reports for GPCM sensitivity figures and appendix tables.
#> 5                                                                                                                                                                              Export direct supported tables; use the separate APA/QC/export bundle row for caveated GPCM sensitivity prose and manifests.
#> 6                                                                                                                                                                                                          Use the casebook as a review queue, then confirm flagged rows with the underlying direct tables.
#> 7                                                                                                                                                                                                Compare against an equal-weighting `RSM` / `PCM` reference and report reweighting as sensitivity evidence.
#> 8                                                                                                                                    Use `build_linking_review()` as a reader-facing index over direct anchor, drift, or chain outputs; write any GPCM linking language as exploratory and source-specific.
#> 9                                                                                                                                                                                                    Use ADEMP-style direct recovery checks with explicit practical RMSE, bias, and uncertainty thresholds.
#> 10                                                                                   Use the APA/QC/export bundle for caveated GPCM sensitivity reporting; use package-native scorefile export, design forecasting, and full FACETS score-side review only through their separate caveated or blocked rows.
#> 11                                                                                                                                                            Use `fair_average_table(fair_se = TRUE)` when structural fair-average SEs are required, and label outputs as slope-aware element-conditional.
#> 12                            Use `evaluate_mfrm_design(..., model = "GPCM", step_facet = ..., slope_facet = step_facet)` or `predict_mfrm_population()` for caveated design-level operating-characteristic review; inspect `gpcm_boundary` and keep slope-recovery adequacy on `evaluate_mfrm_recovery()`.
#> 13 Use `evaluate_mfrm_diagnostic_screening(..., model = "GPCM", step_facet = ..., slope_facet = step_facet)` or `evaluate_mfrm_signal_detection()` for caveated slope-aware screening operating-characteristic review; inspect `gpcm_boundary` and keep operational screening decisions outside this route.
#> 14                                                                         Use `analyze_dff()` / `analyze_dif()` and `dif_interaction_table()` as screening surfaces, then carry `gpcm_boundary` through `summary()`, `dif_report()`, `plot_dif_heatmap()`, and `plot_dif_summary()` before writing claims.
#> 15                                                                                                                                                                                                                  Keep this outside the current public GPCM route and track it as future-extension scope.
#> 16                                                                                                                                                               Use `estimate_bias()` as screening evidence and follow up with explicit facet-pair review or external validation before fairness language.
#> 17                                                                                 Use `facets_output_file_bundle(include = "score")` for a package-native bounded-GPCM scorefile with explicit caveat columns; inspect `gpcm_score_side_contract()`, and do not treat it as FACETS score-side equivalence.
#> 18                                                                                          Use direct fair-average tables and graph-only compatibility outputs; use `gpcm_score_side_contract()` to inspect the unblock criteria, and keep full FACETS output-contract reviews on the `RSM` / `PCM` route.
#>                                                                                                                                                                                                            NextValidationStep
#> 1                                                                                                                                 Add identification and recovery tests before broadening beyond `slope_facet == step_facet`.
#> 2                                                                                                       Collect free-discrimination diagnostic comparison fixtures before promoting residual screens to confirmatory wording.
#> 3                                                                                                                     Validate latent-regression and population-forecast semantics separately from fixed-calibration scoring.
#> 4                                                                                                                                                  Keep kernel-reduction, curve-shape, and draw-free plot-data tests current.
#> 5                                                                                                                     Keep direct-output and report-bundle caveats synchronized before broadening toward operational wording.
#> 6                                                                                                                                     Add larger operational case-review examples if external GPCM fixtures become available.
#> 7                                                                                                                       Define a model-choice decision policy before turning reweighting review into recommendation language.
#> 8                                                                                Validate larger multi-wave GPCM anchor/drift and equating-chain fixtures before upgrading exploratory wording to operational linking claims.
#> 9                                                                                                                                 Expand multi-seed recovery coverage across slope regimes and sparse score-category support.
#> 10                                                                                                                        Keep partial-section availability tests synchronized with score-side and design-forecasting guards.
#> 11                                                                                                                                                  Add external or simulation-backed checks for structural fair-average SEs.
#> 12                                             Expand multi-seed fixtures across slope regimes, sparse score support, and fit-derived specifications before using this route for stronger operational design recommendations.
#> 13 Expand multi-seed fixtures across slope regimes, local-dependence, step/slope-facet misspecification, sparse score support, and fit-derived specifications before using this route for stronger screening recommendations.
#> 14                                                                                 Add larger subgroup fixtures and simulation operating-characteristic checks before using DFF rows as fairness, invariance, or bias claims.
#> 15                                                                                                                         Decide posterior-predictive, MCMC, and backend scope only after the score-side contract is stable.
#> 16                                                                                                       Add simulation operating-characteristic or external fixture evidence before using screening rows as fairness claims.
#> 17                                                   Add unit-slope PCM reduction checks and slope-variation fixtures before broadening the scorefile route from package-native delta SEs toward FACETS-style score-side SEs.
#> 18                               Complete the `gpcm_score_side_contract()` requirements, including a FACETS-compatible free-discrimination score metric and output contract, before enabling full score-side contract review.
gpcm_capability_matrix("supported")
#>                                        Area
#> 1                Core fitting and summaries
#> 2 Fixed-calibration scoring and information
#> 3             Core curve and category views
#>                                                                                                                                                               Helpers
#> 1                                                                                                                        fit_mfrm(model = "GPCM"); summary(); print()
#> 2                                                                     predict_mfrm_units(); sample_mfrm_plausible_values(); compute_information(); plot_information()
#> 3 plot(fit, type = c("wright", "pathway", "ccc", "ccc_surface")); category_structure_report(); category_curves_report(); facets_output_file_bundle(include = "graph")
#>      Status
#> 1 supported
#> 2 supported
#> 3 supported
#>                                                                                                 PrimaryUse
#> 1                        Estimate bounded GPCM models and inspect convergence, steps, and slope summaries.
#> 2                   Score new units or review design-weighted precision under the fitted GPCM calibration.
#> 3 Inspect targeting, category progression, and category-probability behavior under the generalized kernel.
#>                                                                                                                                                   Boundary
#> 1 Requires an explicit step facet and currently keeps `slope_facet == step_facet`; MML direct is the validated default, and EM/hybrid fall back to direct.
#> 2                            Covers fixed-calibration posterior scoring and information only; population forecasting is a separate layer outside this row.
#> 3                                           Limited to the slope-aware probability kernel that is already generalized for the current bounded GPCM branch.
#>                                            Evidence
#> 1 covered by estimation and output-stability checks
#> 2         covered by scoring and information checks
#> 3    covered by curve, plot, and information checks
#>                                                                                                                     RecommendedRoute
#> 1                        Use `fit_mfrm(..., model = "GPCM", step_facet = ..., slope_facet = step_facet)` and inspect `summary(fit)`.
#> 2 Use fixed-calibration scoring and `compute_information()` / `plot_information()`; keep population forecasting on a separate route.
#> 3                                  Use draw-free plot objects and category reports for GPCM sensitivity figures and appendix tables.
#>                                                                                        NextValidationStep
#> 1             Add identification and recovery tests before broadening beyond `slope_facet == step_facet`.
#> 2 Validate latent-regression and population-forecast semantics separately from fixed-calibration scoring.
#> 3                              Keep kernel-reduction, curve-shape, and draw-free plot-data tests current.
gpcm_capability_matrix("blocked")
#>                                       Area                         Helpers
#> 1 FACETS output-contract score-side review facets_output_contract_review()
#>    Status
#> 1 blocked
#>                                                                                                                 PrimaryUse
#> 1 Run the full FACETS-style output-contract score-side review that depends on validated free-discrimination score metrics.
#>                                                                                                                                                                                                                                       Boundary
#> 1 Not yet generalized to the full FACETS-style output-contract review. Direct scorefile export is available with caveats, but contract-wide coverage and metric claims still require a broader free-discrimination score-side review contract.
#>                                                    Evidence
#> 1 not yet validated for free-discrimination score semantics
#>                                                                                                                                                                                                  RecommendedRoute
#> 1 Use direct fair-average tables and graph-only compatibility outputs; use `gpcm_score_side_contract()` to inspect the unblock criteria, and keep full FACETS output-contract reviews on the `RSM` / `PCM` route.
#>                                                                                                                                                                             NextValidationStep
#> 1 Complete the `gpcm_score_side_contract()` requirements, including a FACETS-compatible free-discrimination score metric and output contract, before enabling full score-side contract review.
```
