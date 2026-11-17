# Choose an mfrmr output helper by user goal

With no argument, return five central routes: data review, measurement,
diagnostics, assessment planning and reporting. Read `Question`,
`MainFunction` and `NextStep`. Use `scope = "all"` for the full
specialist catalogue. This guide selects a route; it does not analyze
data.

## Usage

``` r
mfrmr_output_guide(scope = "core_workflow", ...)
```

## Arguments

- scope:

  Which rows or companion matrix to return. The default,
  `"core_workflow"`, returns the five central routes. `"all"` returns
  the full route catalogue. `"plots"` returns a purpose-based plot
  capability table (see below). `"intervals"` returns the
  confidence-interval and uncertainty route guide; `"visual_templates"`
  returns the figure-reporting template; `"gpcm_capabilities"` returns
  the GPCM workflow/score/unavailable capability matrix (see
  [mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gpcm_scope.md));
  and `"calibration_capabilities"` returns the portable
  fixed-calibration model and estimator capability matrix. `"public"`
  and `"beginner"` return the same six-row ordinary RSM/PCM measurement
  route. The default map includes observed-score G/D planning, which
  uses ratings directly and does not require an MFRM fit. `"entry"`
  returns the recommended first-screen routes. `"viewer"` returns
  local-viewer routes built around `mfrm_results(include = ...)`.
  `"binary"` returns the two-category person-item Rasch route and
  checks. Other values filter to one output family or to `GPCM`-relevant
  routes. `"linking"` returns anchor, drift, equating and DIF
  sensitivity routes. `"calibration"` returns the portable
  fixed-calibration lifecycle and artifact-only scoring route,
  conditional decisions and fixed-plan classification
  accuracy/consistency. `"simulation"` and `"network"` return advanced
  design-review rows. `"response_time"` returns descriptive
  response-time QC rows. `"models"` compares fixed-facet, shared-rater
  and Person-specific testlet workflows, including their distinct
  prediction and reporting boundaries. `"feedback"` distinguishes
  fixed-rater uncertainty, unexpected rating patterns, shared-rater
  uncertainty, observed agreement, centrality, criterion-referenced
  accuracy and screening accuracy with known truth. `"features"`,
  `"imputation"` and `"gtheory"` show exploratory attributes,
  assigned-score multiple imputation and observed-score G/D-study
  workflows, including their own table, plot and saving routes.
  `"facets"`, `"conquest"`, and `"r"` return user-pathway rows for
  people arriving from those workflows.

- ...:

  Optional sub-scope or filter arguments for specialist matrices:

  - `scope = "intervals"`: optional `category` (`"all"`, `"visual"`,
    `"table"`, `"reporting"`, `"fit"`, `"bias"`, `"linking"`, `"gpcm"`,
    `"equivalence"`, `"hierarchical"`, or `"shrinkage"`).

  - `scope = "visual_templates"`: optional `category` (`"all"`,
    `"manuscript"`, `"appendix"`, `"diagnostic"`, or `"surface"`).

  - `scope = "gpcm_capabilities"`: optional `status` and `view`
    (`"workflows"`, `"scores"`, or `"unavailable"`). Other scopes take
    no additional arguments.

## Value

- For `scope = "plots"`, a data.frame with `Question`, `InputClass`,
  `PlotCall`, `PlotName` (the name in the saved plot data),
  `DataComponent`, `GGPlot`, `GGPlotCall` (`NA` when unavailable),
  `Notes`, `ResultFunction` and `NextStep`.

- For `scope = "intervals"`, a data.frame mapping confidence-interval
  and uncertainty routes (`Route`, `Scope`, `PrimaryHelper`,
  `DisplayRoute`, `DefaultLevel`, `IntervalColumns`, `Basis`, `UseFor`,
  `InterpretationBoundary`, `GPCMStatus`, `Notes`).

- For `scope = "visual_templates"`, a data.frame of figure-reporting
  guidance (`FigureFamily`, `Scope`, `PrimaryHelper`,
  `DefaultPlacement`, `WhatToReport`, `CaptionSkeleton`,
  `ResultsWording`, `WhatNotToClaim`, `BeginnerCheck`, `ThreeDPolicy`).

- For `scope = "gpcm_capabilities"`, an `mfrmr_gpcm_capabilities`
  data.frame for `view = "workflows"`, or an ordinary data.frame for
  `view = "scores"` and `view = "unavailable"`; see
  [mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gpcm_scope.md).

- For `scope = "calibration_capabilities"`, a data.frame with one row
  per model, estimator, and scoring-basis combination (`Model`,
  `Estimator`, `ScoringBasis`, `PortableCalibration`, `AnchorSupport`,
  `InteractionSupport`, `ExistingAlternative`, `Limitation`).

- All other scopes return a data.frame with one row per route and
  columns:

- `Scope`

- `Question`

- `OutputFamily`

- `Lifecycle`

- `UserLevel`

- `APILayer`

- `ObjectRole`

- `DecisionBoundary`

- `RecommendedEntry`

- `MainFunction`

- `UseWhen`

- `TypicalInput`

- `NextStep`

- `GPCMStatus`

- `Notes`

## Details

Read `Question` and `UseWhen`, then open the help for `MainFunction`.
`TypicalInput` identifies the required object and `NextStep` its
continuation. `DecisionBoundary` and `Notes` describe the limit of the
route; a listed function does not imply that every model can use it.

The five default routes are choices, not required stages. G/D planning
uses observed ratings without an MFRM fit. Explicit `"public"` and
`"beginner"` retain the six-row ordinary RSM/PCM route. Other scopes
select a topic or output family. Names ending in `_table`, `_report`,
`_review` or `_bundle` describe the role of the result, not
interchangeable input classes.

## Reporting, tables, and saving routes

|  |  |
|----|----|
| Need | Primary route |
| Triage an ordinary RSM/PCM analysis | [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md), then `summary(res)$triage` and `$next_actions` |
| Build an analyst report or single-rater feedback sheet | [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md) (`style = "rater"` requires `facet` and `rater`) |
| Draft manuscript prose and formatted tables | [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md), [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md), [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md) |
| Check reporting gaps or uncertainty readiness | `mfrm_report(fit, type = "checklist")` and `type = "precision"` |
| Preserve complete R objects, CSVs, or replay archives | [`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html), [`export_mfrm_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_tables.md), [`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md), [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md) |

Reporting helpers organize stored evidence (informed by JARS-Quant;
Appelbaum et al., 2018,
[doi:10.1037/amp0000191](https://doi.org/10.1037/amp0000191) );
`DraftReady`, `ReadyForAPA`, and `ClaimStrength` do not certify
substantive validity or replace study-design, recruitment, missingness,
and multiplicity disclosures. Retain `NA`/status/reason columns rather
than replacing unavailable outputs with zero. See
[`vignette("mfrmr-reporting-and-apa", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-reporting-and-apa.md)
for a complete fit-to-manuscript walkthrough.

## Choosing a figure

For `scope = "plots"`, read `Question`, `InputClass`, `PlotCall` and
`DataComponent`. Compute the required result first and call its
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method. The
table is a curated map, not an inventory of every plot type. See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for interpretation and editing; plot-method help specifies the supported
arguments and return contract.

## Model-specific support

The basic fit/results/report route covers supported ordinary RSM/PCM
fits. GPCM, CML, corrected JML and extended models have different
downstream support. Check `mfrmr_output_guide("gpcm_capabilities")` and
the result class's help before reusing a route.
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)
connects the main objects; numerical and uncertainty conditions belong
to the function that computes the result.

## Examples

``` r
core <- mfrmr_output_guide()
core[, c("Question", "MainFunction", "NextStep")]
#>                                                              Question
#> 1          Inspect rating design, connectedness, and score categories
#> 2     Fit the measurement model with shared spec and optional control
#> 3 Diagnose model fit, precision, local dependence, and rater patterns
#> 4   Partition observed-score variance and project future rating plans
#> 5                        Assemble reports and unified ggplot2 figures
#>                                                                                                                                                                              MainFunction
#> 1 spec <- list(person = "Person", facets = c("Rater", "Criterion"), score = "Score", rating_min = 1, rating_max = 4, category_policy = "preserve"); describe_mfrm_data(data, spec = spec)
#> 2                                                                       fit <- fit_mfrm(data, spec = spec, model = "RSM", method = "MML", control = list(quad_points = 15)); summary(fit)
#> 3                                                                                                                     diag <- diagnose_mfrm(fit, diagnostic_mode = "both"); summary(diag)
#> 4           g <- mfrm_g_study(data, person = "Person", facets = c("Rater", "Criterion"), score = "Score"); d <- mfrm_d_study(g, plans = data.frame(Rater = c(2, 3), Criterion = c(4, 4)))
#> 5                                                        res <- mfrm_results(fit, diagnostics = diag); report <- mfrm_report(res); plot(fit); plot_data(plot(fit, draw = FALSE), "notes")
#>                                                                                                                                                      NextStep
#> 1                                 Check zero-count categories and disconnected subsets; add review_mfrm_anchors(data, spec = spec) when linking across waves.
#> 2                Read summary(fit)$decision before interpreting estimates; see ?fit_mfrm_technical_details for specialist identification and control options.
#> 3 Inspect Infit/Outfit, marginal-fit screens, and mfrm_report(type = 'precision', fit, diagnostics = diag); add analyze_dff() or estimate_bias() when needed.
#> 4                                  Inspect IdentificationStatus, GStatus, and PhiStatus alongside plot(d, type = "error_components") before selecting a plan.
#> 5                                          Read summary(report, view = "reader") and retain figure notes from plot_data(p, "notes"); save res with saveRDS().

# Request the full catalogue explicitly.
catalogue <- mfrmr_output_guide("all")
head(catalogue[, c("Question", "MainFunction")])
#>                                                              Question
#> 1          Inspect rating design, connectedness, and score categories
#> 2     Fit the measurement model with shared spec and optional control
#> 3 Diagnose model fit, precision, local dependence, and rater patterns
#> 4   Partition observed-score variance and project future rating plans
#> 5                        Assemble reports and unified ggplot2 figures
#> 6                         1. Check your rating data and fit the model
#>                                                                                                                                                                                                                        MainFunction
#> 1                                           spec <- list(person = "Person", facets = c("Rater", "Criterion"), score = "Score", rating_min = 1, rating_max = 4, category_policy = "preserve"); describe_mfrm_data(data, spec = spec)
#> 2                                                                                                                 fit <- fit_mfrm(data, spec = spec, model = "RSM", method = "MML", control = list(quad_points = 15)); summary(fit)
#> 3                                                                                                                                                               diag <- diagnose_mfrm(fit, diagnostic_mode = "both"); summary(diag)
#> 4                                                     g <- mfrm_g_study(data, person = "Person", facets = c("Rater", "Criterion"), score = "Score"); d <- mfrm_d_study(g, plans = data.frame(Rater = c(2, 3), Criterion = c(4, 4)))
#> 5                                                                                                  res <- mfrm_results(fit, diagnostics = diag); report <- mfrm_report(res); plot(fit); plot_data(plot(fit, draw = FALSE), "notes")
#> 6 spec <- list(person = ..., facets = ..., score = ..., rating_min = ..., rating_max = ..., category_policy = "preserve"); describe_mfrm_data(data, spec = spec); fit <- fit_mfrm(data, spec = spec, method = "MML", model = "RSM")

# Ask for a specialist map only when that question arises.
linking <- mfrmr_output_guide("linking")
linking[, c("Question", "MainFunction", "UseWhen")]
#>                                                                Question
#> 46  Open first-screen anchor and linking readiness from an existing fit
#> 47        Review intended anchor and group-anchor tables before fitting
#> 48                  Check drift across separately fitted waves or forms
#> 49          Build a screened equating chain across ordered calibrations
#> 100     How sensitive is a group contrast to the DIF comparison method?
#>                                                                                                        MainFunction
#> 46                                              mfrm_results(fit, include = "linking"); plot(res, type = "anchors")
#> 47                         make_anchor_table(); review_mfrm_anchors(); fit_mfrm(anchors = ..., group_anchors = ...)
#> 48                detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2)); build_linking_review(drift = ...); plot(x)
#> 49  build_equating_chain(list(Form1 = fit1, Form2 = fit2)); build_linking_review(chain = ...); plot(type = "chain")
#> 100                                                               mantel_haenszel_table(); ordinal_logistic_table()
#>                                                                                                                                                   UseWhen
#> 46                                          You already have an mfrm_fit and want the stored anchor-review evidence in the comprehensive results surface.
#> 47  You are preparing fixed anchors or group anchors and need to catch overlap, duplicate, missing, sparse, or unsupported anchor rows before estimation.
#> 48                                            You have two or more independently fitted waves and need common-element drift and thin-link support checks.
#> 49           You have an ordered sequence of forms or administrations and need screened adjacent-link offsets before operational score-scale maintenance.
#> 100     Compare binary MH, multi-category/multi-group GMH or ordinal-logistic results with residual analyze_dff() output on an explicitly matched roster.

feedback <- mfrmr_output_guide("feedback")
feedback[, c("Question", "MainFunction", "DecisionBoundary")]
#>                                                                                Question
#> 89                How uncertain are fixed-rater severities or prespecified differences?
#> 90 Which ordinary-model rating patterns need review, and do flags depend on the cutoff?
#> 91     Which response residuals need review under supported RSMs or corrected GPCM JML?
#> 92               How uncertain is an observed rater's severity in a shared-rater model?
#> 93             How often does a warning rule flag unaffected or detect affected raters?
#> 94                                             How can I prepare a sheet for one rater?
#> 95                                 How closely do observed ratings agree across raters?
#> 96                            How does one score source compare with reference ratings?
#> 97                       Do rater residuals and category thresholds suggest centrality?
#> 98                 How accurately does each rater match fixed expert reference ratings?
#>                                                                                  MainFunction
#> 89                                                                     mfrm_facet_intervals()
#> 90                                                                       fit_measures_table()
#> 91                                                                mfrm_response_diagnostics()
#> 92                                                   confint(); mfrm_random_rater_intervals()
#> 93                                 mfrm_screening_performance(); mfrm_screening_sensitivity()
#> 94                                                                              mfrm_report()
#> 95 pairwise_kappa_table(); krippendorff_alpha_table(); gwet_ac2_table(); pairwise_icc_table()
#> 96                                                                   score_comparison_table()
#> 97                                                                   rater_centrality_table()
#> 98                                                                       fit_rater_accuracy()
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                DecisionBoundary
#> 89 Pointwise fixed-facet intervals, not simultaneous classifications or random-rater population inference. CML uses conditional information and estimates no population SD; its intervals are asymptotic. Native scale is the default. Explicit MML standardized contrasts divide by the same fit's population SD and include its uncertainty and cross-covariance; estimated SD requires an intercept-only normal population, not a regression residual SD. Inspect IdentificationBasis, numerical eligibility and unavailable rows separately; these do not prove global MML identification or finite-sample coverage. Sandwich SEs do not correct a biased estimate or MNAR. GPCM location differences do not imply uniform rating differences when slopes/steps vary. One-family MML Wald intervals assume a correctly specified, identified regular model.
#> 90                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Flags are descriptive review prompts, not probabilities of poor rater quality. Severity is not misfit. Threshold sensitivity on observed data does not estimate false-flag or detection rates; GPCM retains its separate capability and inference limits.
#> 91                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Posterior predictive and corrected-JML conditional Infit/Outfit have different probability definitions. Zero-variance corrected-JML rows can leave Infit defined but Outfit unavailable; no rows are silently dropped. No classic cutoffs, ZSTD tests, automatic exclusion or calibrated diagnostic accuracy is supplied.
#> 92                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         Individual-rater intervals are not automatic. Normal and bootstrap approximations remain unqualified for general coverage; average prediction coverage does not establish coverage at each fixed severity. Do not substitute conditional Person intervals or population-SD profiles.
#> 93                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Known truth is required: real-data flags alone cannot estimate these rates. Monte Carlo intervals describe simulation uncertainty, not severity uncertainty. Unavailable screens are retained, and raters within one replication are not independent trials.
#> 94                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              No refitting, interval calculation, automatic warning cutoff or rater-quality classification. The sheet omits source identifiers; patterns may still be recognizable. Do not distribute the comprehensive source bundle as an individual sheet.
#> 95                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Observed-score agreement is not MFRM separation reliability or criterion accuracy. Coefficients have different chance models and missingness denominators; ICC pairs may use different units and must not be averaged into a panel ICC. No universal quality cutoff or confidence interval is supplied.
#> 96                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        The reference is not necessarily error-free. Williamson thresholds are application-specific examples, not general validity criteria. Severity/fit are separate from criterion accuracy; request screen = 'williamson2012' explicitly when applicable.
#> 97                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        Descriptive indices, not a validated centrality diagnosis or Bayesian omega estimate. Low Infit has other explanations; MML expectations use saved EAP plug-in scores. Binary rubrics cannot supply threshold spread.
#> 98                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Accuracy logits concern exact reference matches, not rater severity or examinee ability. Binary coding discards error direction/size; reference uncertainty is excluded. JML is exploratory with infinite extreme estimates; MML EAP/SD condition on fitted difficulty and population parameters.

figures <- mfrmr_output_guide("plots")
figures[, c("Question", "ResultFunction", "GGPlot")]
#>                                                                                     Question
#> 1                                                    Inspect signed pairwise rater agreement
#> 2                                             Compare weighted network inconsistency indices
#> 3                                            Inspect conditional binary-network coefficients
#> 4                                            Compare a binary network with model simulations
#> 5                                           Compare persons, facet levels and category steps
#> 6                                                        Show expected scores across ability
#> 7                                                 Review severity together with response fit
#> 8                                              Compare facet locations and their uncertainty
#> 9                                                               Inspect category functioning
#> 10                                                             Review pooled category counts
#> 11                                                 Review steps within their threshold owner
#> 12                                                           Compare category curve families
#> 13                                   Compare group-pair DFF / DIF values on a 2D scatterplot
#> 14                                        Compare fixed-rater estimates and interval methods
#> 15                                                 Review conditional interaction departures
#> 16                                                       Explore bias across all facet pairs
#> 17                                       Read latent-regression coefficients and uncertainty
#> 18                                        Read prespecified conditional population contrasts
#> 19                                     Compare same-rater and other-rater score associations
#> 20                                                               Show GPCM slope uncertainty
#> 21                                          Show GPCM probability or information uncertainty
#> 22                                           Compare observed raters in a shared-rater model
#> 23                                                     Inspect testlet-model facet estimates
#> 24                                Review conditional Person scores from a shared-rater model
#> 25                                     Review conditional Person scores from a testlet model
#> 26 Review response residuals under supported RSMs, two-family GPCM MML or corrected GPCM JML
#> 27                                               Compare ordinary and extended model results
#> 28                                     Compare screening rules across known-truth conditions
#> 29                                               Show screening performance with uncertainty
#> 30                               Show pooled fixed-facet intervals after multiple imputation
#> 31                                                 Report saved external posterior intervals
#> 32                          Review new-Person Bayesian posterior scores and variance sources
#> 33                                       Inspect all residual associations and missing pairs
#> 34                                            Locate residual co-movement after model review
#> 35                                           Inspect exploratory groups of residual profiles
#> 36                                             Inspect separation of external-feature groups
#> 37                                                Describe an external feature within groups
#> 38                                            Inspect a hierarchy of external-feature groups
#> 39                                        Inspect group stability across feature imputations
#> 40                                    Choose how many external-feature components to inspect
#> 41                                            Locate entities on external-feature components
#> 42                                             Identify features contributing to a component
#> 43                                          Plan facet counts with an observed-score D-study
#> 44                                               Inspect sources of observed-score variation
#> 45                                    Plan reliability for a multivariate score or composite
#> 46                                            Plan absolute or relative error in score units
#> 47                                           Explain which error sources change across plans
#> 48                                             Compare D-study plans including the reference
#> 49                                           Inspect observed coverage across rating subsets
#> 50                                                 Customize the underlying precision values
#>                    ResultFunction    GGPlot
#> 1          rater_network_analysis dedicated
#> 2          rater_network_analysis dedicated
#> 3               fit_rater_network dedicated
#> 4               fit_rater_network dedicated
#> 5                        fit_mfrm dedicated
#> 6                        fit_mfrm dedicated
#> 7                        fit_mfrm dedicated
#> 8                        fit_mfrm dedicated
#> 9                        fit_mfrm dedicated
#> 10             rating_scale_table dedicated
#> 11             rating_scale_table dedicated
#> 12                    mfrm_report dedicated
#> 13                    analyze_dff dedicated
#> 14           mfrm_facet_intervals dedicated
#> 15                    mfrm_report dedicated
#> 16              estimate_all_bias dedicated
#> 17      mfrm_population_intervals dedicated
#> 18      mfrm_population_intervals dedicated
#> 19    rater_halo_network_analysis dedicated
#> 20               confint.mfrm_fit    native
#> 21           mfrm_curve_intervals    native
#> 22          fit_mfrm_random_rater dedicated
#> 23               fit_mfrm_testlet dedicated
#> 24        score_mfrm_random_rater dedicated
#> 25           predict.mfrm_testlet dedicated
#> 26      mfrm_response_diagnostics dedicated
#> 27                   compare_mfrm dedicated
#> 28     mfrm_screening_sensitivity dedicated
#> 29     mfrm_screening_performance dedicated
#> 30              pool_mfrm_imputed dedicated
#> 31            read_mfrm_posterior dedicated
#> 32 predict.mfrm_posterior_summary dedicated
#> 33          mfrm_residual_network dedicated
#> 34          mfrm_residual_network dedicated
#> 35          mfrm_residual_network dedicated
#> 36                   mfrm_cluster dedicated
#> 37                   mfrm_cluster dedicated
#> 38                   mfrm_cluster dedicated
#> 39           mfrm_cluster_imputed dedicated
#> 40                       mfrm_pca dedicated
#> 41                       mfrm_pca dedicated
#> 42                       mfrm_pca dedicated
#> 43                   mfrm_d_study dedicated
#> 44                   mfrm_g_study dedicated
#> 45                   mfrm_d_study dedicated
#> 46                   mfrm_d_study dedicated
#> 47                   mfrm_d_study dedicated
#> 48                   compare_mfrm dedicated
#> 49     subset_connectivity_report   generic
#> 50            compute_information   generic

mfrmr_output_guide("intervals", "visual")[, c("Route", "DisplayRoute", "Basis")]
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
#> 32                         GMFRM step-offset intervals
#> 33                              GPCM curve uncertainty
#> 34                      GPCM bootstrap slope intervals
#> 35          Binary rater-network coefficient intervals
#>                                                                                                                                                                                                                                DisplayRoute
#> 2                                                                                                                                                         Use plot(fit_measures, type = "measure_ci", draw = FALSE) for reusable plot data.
#> 3                                                                                                                                                                Use plot_data(..., component = "locations") or draw the ggplot Wright map.
#> 4                                                                                                                             Use plot_data(..., type = "wright", view = "unified", component = "locations") or draw the ggplot Wright map.
#> 5                                                                                                                                                                      Use draw = FALSE to reuse the ranked severity table and band labels.
#> 6                                                                                                                                                                Use draw = FALSE to reuse wright, severity, threshold, and summary panels.
#> 7                                                                                                                                                   Use plot_data(..., type = "fair_average", show_ci = TRUE); inspect plot_data and notes.
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
#> 32                                                                                                                       summary(result), plot(result), apa_table(result); attach with mfrm_results(fit, intervals = list(steps = result)).
#> 33                                                                                            plot(result), as_ggplot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(uncertainty = result)).
#> 34                                                                                            plot(result), as_ggplot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(uncertainty = result)).
#> 35                                                                                                                                                                   summary(model); plot(model, type = 'coefficients'); mfrm_report(model)
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
#> 32                                                                                                             Experimental pointwise normal intervals using constrained steps and full joint marginal information.
#> 33                                                                                                       Full calibration covariance at fixed native-scale ability and rating context; logit or log transformation.
#> 34                                                                                                                    Fitted-model basic bootstrap errors; unresolved refits enclose all possible empirical limits.
#> 35                                                                                                                     Approximate pointwise normal ERGM coefficient intervals in conditional log-odds coordinates.
mfrmr_output_guide("visual_templates", "manuscript")[, c("FigureFamily", "DefaultPlacement")]
#>                     FigureFamily
#> 1                     Wright map
#> 2                    Pathway map
#> 3 Category characteristic curves
#> 5             Information curves
#>                                                                    DefaultPlacement
#> 1      Main text when targeting, spread, or shared-logit interpretation is central.
#> 2 Main text or category-functioning subsection for ordered-category interpretation.
#> 3       Main text or appendix; pair with pathway when category behavior is central.
#> 5        Main text when precision or targeting across theta is a substantive claim.
mfrmr_output_guide("gpcm_capabilities", "supported")[, c("Area", "Status")]
#> mfrmr GPCM workflow availability
#> Most rows describe one slope family; two-family MML has a separate provisional scope.
#> MML IC comparison and PCM/GPCM tests have separate checks; relative-slope intervals use separate MML checks.
#> 
#>     Status Routes
#>  supported      2
#> 
#> Route preview
#>                                             Area    Status
#>  Fitted-object posterior scoring and information supported
#>                    Core curve and category views supported
#> 
#> Filter by status, for example mfrmr_output_guide("gpcm_capabilities", "supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
mfrmr_output_guide("calibration_capabilities")[, c("Model", "Estimator", "PortableCalibration")]
#>                 Model     Estimator PortableCalibration
#> 1                 RSM           MML           available
#> 2                 PCM           MML           available
#> 3             RSM/PCM           MML         unavailable
#> 4                GPCM           MML           available
#> 5             RSM/PCM           JML           available
#> 6                GPCM           JML           available
#> 7                GPCM Corrected JML           available
#> 8 GPCM (two families)           MML           available
```
