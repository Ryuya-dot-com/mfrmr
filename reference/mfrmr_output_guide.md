# Choose an mfrmr output helper by user goal

Find a function for the next question in your analysis. Start with
`mfrmr_output_guide("beginner")` and read its `Question` and
`MainFunction` columns. With no argument the function returns the full
specialist catalogue, which includes tables, reports, reviews and
exports. It does not analyze data.

## Usage

``` r
mfrmr_output_guide(
  scope = c("all", "public", "beginner", "psychometric", "entry", "viewer", "binary",
    "tables", "reports", "reviews", "bundles", "exports", "compatibility", "gpcm",
    "calibration", "simulation", "linking", "network", "response_time", "facets",
    "conquest", "r", "models", "features", "imputation", "gtheory", "feedback", "plots")
)
```

## Arguments

- scope:

  Which rows to return. `"all"` returns the full route catalogue.
  `"plots"` returns a separate purpose-based plot capability table (see
  below). `"public"` returns the canonical six-step route for most
  users; `"beginner"` returns the same compact route rather than
  combining every beginner-labelled specialist row. `"entry"` returns
  the recommended first-screen routes. `"viewer"` returns local-viewer
  routes built around `mfrm_results(include = ...)`. `"binary"` returns
  the two-category person-item Rasch route and checks. Other values
  filter to one output family or to `GPCM`-relevant routes. `"linking"`
  returns anchor, drift, equating and DIF sensitivity routes.
  `"calibration"` returns the portable fixed-calibration lifecycle and
  artifact-only scoring route, conditional decisions and fixed-plan
  classification accuracy/consistency. `"simulation"` and `"network"`
  return advanced design-review rows. `"response_time"` returns
  descriptive response-time QC rows. `"models"` compares fixed-facet,
  shared-rater and Person-specific testlet workflows, including their
  distinct prediction and reporting boundaries. `"feedback"`
  distinguishes fixed-rater uncertainty, unexpected rating patterns,
  shared-rater uncertainty, observed agreement, centrality,
  criterion-referenced accuracy and screening accuracy with known truth.
  `"features"`, `"imputation"` and `"gtheory"` show exploratory
  attributes, assigned-score multiple imputation and observed-score
  G/D-study workflows, including their own table, plot and saving
  routes. `"facets"`, `"conquest"`, and `"r"` return user-pathway rows
  for people arriving from those workflows.

## Value

For `scope = "plots"`, a data.frame with `Question`, `InputClass`,
`PlotCall`, `PlotName` (the name in the saved plot data),
`DataComponent`, `GGPlot`, `GGPlotCall` (`NA` when unavailable),
`Notes`, `ResultFunction` and `NextStep`. All other scopes return a
data.frame with one row per route and columns:

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

Naming convention used by the guide:

- `*_table`: focused table or table-like result for one evidence source

- `*_report`: multi-table evidence bundle for a reporting question

- `*_review`: status, interpretation, or decision-support object

- `*_bundle`: reusable collection of tables/metadata for handoff

- `export_*`: writes files or appendix artifacts

## First-screen route

Use `mfrmr_output_guide("public")` or `mfrmr_output_guide("beginner")`
for the shortest top-level API map: an explicit
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
check and
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
MML fit, the lightweight fit summary, `res <- mfrm_results(fit)` and its
triage, optional figures, and report/export or RDS saving. Plotting is
not required before saving. Earlier scripts may obtain the same result
bundle from `summary(fit, profile = "facets")$results`; no FACETS
software is required. Use `mfrmr_output_guide("entry")` when you
specifically need alternative first-screen creation routes, including
existing result objects, the optional viewer, or interactive console
work. After creating `res`, use `summary(res)$next_actions` to choose a
purpose-specific specialist helper. Use `mfrmr_output_guide("viewer")`
when the next step is the optional local Shiny reader; it shows which
`include` preset to use before calling
[`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md).
Use `mfrmr_output_guide("feedback")` when preparing rater feedback.
Start with the question and the fitted model: severity, response misfit
and the accuracy of a warning rule are different quantities. A severe
rater need not misfit, and an observed flag does not establish poor
rater quality. For observed agreement, choose
[`pairwise_kappa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/pairwise_kappa_table.md),
[`krippendorff_alpha_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/krippendorff_alpha_table.md),
[`gwet_ac2_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/gwet_ac2_table.md)
or
[`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/pairwise_icc_table.md)
according to the score scale, rater target and missingness assumptions.
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md)
compares a score source with reference ratings;
[`rater_centrality_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_centrality_table.md)
describes residual and threshold-spread indices;
[`fit_rater_accuracy()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_accuracy.md)
models exact matches to fixed reference ratings. High rater separation
reliability indicates distinguishable severities, not high agreement.
These quantities do not replace one another. For a fixed future plan,
use
[`classification_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/classification_table.md)
under `scope = "calibration"`; its model-based accuracy/consistency
differs from observed reference agreement and posterior ability-band
probabilities. For DIF sensitivity, `scope = "linking"` points to
[`mantel_haenszel_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/mantel_haenszel_table.md),
[`ordinal_logistic_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/ordinal_logistic_table.md)
and the shared-roster example in
[`vignette("mfrmr-linking-and-dff")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.md).
For an individual native additive RSM/PCM or experimental two-family
GPCM sheet, use
`mfrm_report(res, style = "rater", facet = "Rater", rater = "R01")`. The
selected sheet omits source identifiers; the comprehensive result and
export bundle retain the original analysis. Use
`mfrmr_output_guide("psychometric")` for the technical table, review,
and reporting routes whose interpretation boundaries should be checked
before manuscript use.

## How to use this guide

For route scopes, read `Question` first, then open the help for a
function in `MainFunction`. For `"plots"`, use the figure instructions
below. `UseWhen` describes its inputs and purpose; `NextStep` explains
what to inspect. Cells containing `...` are outlines, not complete
scripts to paste and run. Use
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md)
for a runnable introduction and an explanation of function names.
Inspect `DecisionBoundary` before interpreting a result. For
construct-focused research, the *Use results as evidence about a
construct* section of
[mfrmr_methods_reference](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md)
connects a claim to observable patterns, competing explanations and the
limits of a conclusion. For `GPCM`, use `scope = "gpcm"` to find both
the support matrix and the table that explains how out-of-scope routes
are handled. Use `scope = "exports"` to distinguish saved-analysis
archives from
[`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md),
which generates a Stan/brms model for a separate Bayesian analysis with
explicit priors. That route returns to mfrmr through
[`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md):
inspect `summary(x)` before using `plot(x)`, `confint(x)` or
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md).
Other interval levels, contrasts and predictions require the backend's
joint draws.

## Check the model before following a route

The six-step beginner route starts with ordinary RSM/PCM. The result
class `mfrm_fit` alone does not establish which diagnostics or figures
are valid: one-family GPCM, two-family GPCM and corrected JML share that
class. Read the fitted model and estimation method in `summary(fit)`
first. For GPCM, consult
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
and
[`vignette("mfrmr-gpcm-scope", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.md).
Two-family GPCM and corrected JML have separate result/report and
descriptive response-diagnostic routes; ordinary fit tests and
Wright/Pathway maps do not apply. Corrected JML supplies point plots for
slopes, locations and steps, without structural confidence intervals.

Use `scope = "models"` for fixed-facet, shared-rater and testlet roles,
`scope = "feedback"` for the distinct rater-review targets, and
`scope = "calibration"` for scoring or fixed-plan decisions. For
exploratory bias review across eligible facet pairs, use
[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md),
followed by `summary(screens)` and `plot(screens)`. Use
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
for a prespecified pair. Retain failed pairs and unavailable cells; the
collection does not supply multiplicity-controlled inference or evidence
that no bias exists. Save the complete collection.

Use `scope = "gtheory"` for observed-score assessment planning. Start
with the G-study component or covariance view, then compare D-study
curves while keeping other facet counts fixed or in separate panels. Use
`plot(d, type = "error_components")` to inspect each plan's error
sources, including signed covariance contributions, or `type = "sem"`
for error in score units. Error-source contributions are point
estimates; SEM uncertainty requires the separately supported interval
calculation. These projections and paired plan-difference intervals
answer different questions. Component SEs/intervals are available for
the designs and methods documented in
[`confint.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md)
and
[`vcov.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/vcov.mfrm_multivariate_gstudy.md).
For coefficient sampling SEs, use
[`confint.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md)
with `method = "delta"` and `assumption = "normal"`. These differ from
measurement SEM. Its normal-reference intervals and plots retain bounds
outside `[0,1]` with approximation qualifications; defaults are
unchanged. General distribution-robust comparison intervals are not
supplied. Save each complete result with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) and reopen it
with [`base::readRDS()`](https://rdrr.io/r/base/readRDS.html); a CSV
alone does not retain its design or qualifications. Fixed-facet output
also depends on the estimator: native CML uses dedicated summaries and
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
plots/tables, without ordinary Person scoring or consolidated reports.
[`mfrmr_interval_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_interval_guide.md)
separates that route from MML interaction contrasts and their
population-SD standardization.

## Choosing a figure

Use `mfrmr_output_guide("plots")` to find selected plots by purpose,
input class and explicit plot call. This is a curated map, not an
exhaustive list of every plot method, view or component. Unlisted routes
are not necessarily unsupported. Existing scopes, including `"all"`,
keep their route-table format.

For linked figure previews and runnable examples, open
[`vignette("mfrmr-visual-diagnostics")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).
`ResultFunction` names a help page for creating the required result. In
`PlotCall`, replace `x` with the indicated result object and save the
returned object as `p`. Calls use `draw = FALSE`; change it to `TRUE` to
display the original figure. Then follow `GGPlotCall`, if available.
`DataComponent` is for
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
extraction; it is not automatically a valid or equivalent `component`
argument to
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md).

`GGPlot` distinguishes `"dedicated"` (a converter for this plot),
`"native"` (the plot method already returns ggplot), `"generic"` (a
table-based view that need not reproduce the original figure), and
`"unavailable"` (use the original plot or build a custom graphic from
its data). ggplot routes need the optional ggplot2 package. Display
support does not broaden the fitted model's statistical scope or
establish interval coverage. Read `Notes` and the source function's help
before interpretation.

## Examples

``` r
beginner <- mfrmr_output_guide("beginner")
beginner[, c("Question", "MainFunction", "NextStep")]
#>                                                 Question
#> 1            1. Check your rating data and fit the model
#> 2  2. Read the fit summary and its recommended next step
#> 3                 3. Review estimates, fit and precision
#> 4 4. Plot abilities and facet estimates with uncertainty
#> 5       5. Add other maps when they answer your question
#> 6       6. Read the report and save the reviewed results
#>                                                                                                                                                                                                                                                                                           MainFunction
#> 1 describe_mfrm_data(data, person = ..., facets = ..., score = ..., rating_min = ..., rating_max = ..., category_policy = "preserve"); fit <- fit_mfrm(data, person = ..., facets = ..., score = ..., rating_min = ..., rating_max = ..., category_policy = "preserve", method = "MML", model = "RSM")
#> 2                                                                                                                                                                                                                                                      summary(fit, profile = "fit", detail = "brief")
#> 3                                                                                                                                                                                                                                                               res <- mfrm_results(fit); summary(res)
#> 4                                                                                                                                                                                                 plot(res, type = "wright", renderer = "native", show_ci = TRUE, top_n = Inf, preset = "publication")
#> 5                                                                            fit$prep$score_map; plot(res, type = "wright", renderer = "facets", category_labels = rubric_labels, show_ci = FALSE); plot(res, type = "fit_pathway", fit_stat = "Infit", include_person = TRUE, person_labels = "none")
#> 6                                                                                                                                                                                           report <- mfrm_report(res); summary(report, view = "reader"); export_mfrm_results(res, preset = "starter")
#>                                                                                                                    NextStep
#> 1       Review retained/missing categories and the score map, then run the lightweight fit profile and confirm convergence.
#> 2               If the fit is usable, collect res <- mfrm_results(fit); otherwise resolve convergence or data issues first.
#> 3               Read summary(res)$triage and $next_actions; use $plot_map to choose optional figures, or save res directly.
#> 4                 Inspect targeting, facet uncertainty, and every retained step; keep this figure with the analysis record.
#> 5     Use rubric labels from the actual instrument and treat person points as case-review prompts, not exclusion decisions.
#> 6 Read the report summary before export and keep replay plus data-handling metadata with every controlled analysis archive.

# Ask for a specialist map only when that question arises.
linking <- mfrmr_output_guide("linking")
linking[, c("Question", "MainFunction", "UseWhen")]
#>                                                               Question
#> 41 Open first-screen anchor and linking readiness from an existing fit
#> 42       Review intended anchor and group-anchor tables before fitting
#> 43                 Check drift across separately fitted waves or forms
#> 44         Build a screened equating chain across ordered calibrations
#> 95     How sensitive is a group contrast to the DIF comparison method?
#>                                                                                                       MainFunction
#> 41                                             mfrm_results(fit, include = "linking"); plot(res, type = "anchors")
#> 42                        make_anchor_table(); review_mfrm_anchors(); fit_mfrm(anchors = ..., group_anchors = ...)
#> 43               detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2)); build_linking_review(drift = ...); plot(x)
#> 44 build_equating_chain(list(Form1 = fit1, Form2 = fit2)); build_linking_review(chain = ...); plot(type = "chain")
#> 95                                                               mantel_haenszel_table(); ordinal_logistic_table()
#>                                                                                                                                                  UseWhen
#> 41                                         You already have an mfrm_fit and want the stored anchor-review evidence in the comprehensive results surface.
#> 42 You are preparing fixed anchors or group anchors and need to catch overlap, duplicate, missing, sparse, or unsupported anchor rows before estimation.
#> 43                                           You have two or more independently fitted waves and need common-element drift and thin-link support checks.
#> 44          You have an ordered sequence of forms or administrations and need screened adjacent-link offsets before operational score-scale maintenance.
#> 95                             Compare binary MH or ordinal-logistic group contrasts with residual analyze_dff() output on an explicitly matched roster.

feedback <- mfrmr_output_guide("feedback")
feedback[, c("Question", "MainFunction", "DecisionBoundary")]
#>                                                                                Question
#> 84                How uncertain are fixed-rater severities or prespecified differences?
#> 85 Which ordinary-model rating patterns need review, and do flags depend on the cutoff?
#> 86     Which response residuals need review under supported RSMs or corrected GPCM JML?
#> 87               How uncertain is an observed rater's severity in a shared-rater model?
#> 88             How often does a warning rule flag unaffected or detect affected raters?
#> 89                                             How can I prepare a sheet for one rater?
#> 90                                 How closely do observed ratings agree across raters?
#> 91                            How does one score source compare with reference ratings?
#> 92                       Do rater residuals and category thresholds suggest centrality?
#> 93                 How accurately does each rater match fixed expert reference ratings?
#>                                                                                  MainFunction
#> 84                                                                     mfrm_facet_intervals()
#> 85                                                                       fit_measures_table()
#> 86                                                                mfrm_response_diagnostics()
#> 87                                                   confint(); mfrm_random_rater_intervals()
#> 88                                 mfrm_screening_performance(); mfrm_screening_sensitivity()
#> 89                                                                              mfrm_report()
#> 90 pairwise_kappa_table(); krippendorff_alpha_table(); gwet_ac2_table(); pairwise_icc_table()
#> 91                                                                   score_comparison_table()
#> 92                                                                   rater_centrality_table()
#> 93                                                                       fit_rater_accuracy()
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                DecisionBoundary
#> 84 Pointwise fixed-facet intervals, not simultaneous classifications or random-rater population inference. CML uses conditional information and estimates no population SD; its intervals are asymptotic. Native scale is the default. Explicit MML standardized contrasts divide by the same fit's population SD and include its uncertainty and cross-covariance; estimated SD requires an intercept-only normal population, not a regression residual SD. Inspect IdentificationBasis, numerical eligibility and unavailable rows separately; these do not prove global MML identification or finite-sample coverage. Sandwich SEs do not correct a biased estimate or MNAR. GPCM location differences do not imply uniform rating differences when slopes/steps vary. One-family MML Wald intervals assume a correctly specified, identified regular model.
#> 85                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Flags are descriptive review prompts, not probabilities of poor rater quality. Severity is not misfit. Threshold sensitivity on observed data does not estimate false-flag or detection rates; GPCM retains its separate capability and inference limits.
#> 86                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Posterior predictive and corrected-JML conditional Infit/Outfit have different probability definitions. Zero-variance corrected-JML rows can leave Infit defined but Outfit unavailable; no rows are silently dropped. No classic cutoffs, ZSTD tests, automatic exclusion or calibrated diagnostic accuracy is supplied.
#> 87                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         Individual-rater intervals are not automatic. Normal and bootstrap approximations remain unqualified for general coverage; average prediction coverage does not establish coverage at each fixed severity. Do not substitute conditional Person intervals or population-SD profiles.
#> 88                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Known truth is required: real-data flags alone cannot estimate these rates. Monte Carlo intervals describe simulation uncertainty, not severity uncertainty. Unavailable screens are retained, and raters within one replication are not independent trials.
#> 89                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              No refitting, interval calculation, automatic warning cutoff or rater-quality classification. The sheet omits source identifiers; patterns may still be recognizable. Do not distribute the comprehensive source bundle as an individual sheet.
#> 90                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Observed-score agreement is not MFRM separation reliability or criterion accuracy. Coefficients have different chance models and missingness denominators; ICC pairs may use different units and must not be averaged into a panel ICC. No universal quality cutoff or confidence interval is supplied.
#> 91                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            The reference is not necessarily error-free. Williamson thresholds are application-specific examples, not general validity criteria. Severity/fit are separate from criterion accuracy; automated_scoring_table() is the compatibility interface.
#> 92                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        Descriptive indices, not a validated centrality diagnosis or Bayesian omega estimate. Low Infit has other explanations; MML expectations use saved EAP plug-in scores. Binary rubrics cannot supply threshold spread.
#> 93                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Accuracy logits concern exact reference matches, not severity or proficiency. Binary coding discards error direction/size; reference uncertainty is excluded. JML is exploratory with infinite extreme estimates; MML EAP/SD condition on fitted difficulty and population parameters.

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
#> 13                                        Compare fixed-rater estimates and interval methods
#> 14                                                 Review conditional interaction departures
#> 15                                                       Explore bias across all facet pairs
#> 16                                       Read latent-regression coefficients and uncertainty
#> 17                                        Read prespecified conditional population contrasts
#> 18                                     Compare same-rater and other-rater score associations
#> 19                                                               Show GPCM slope uncertainty
#> 20                                          Show GPCM probability or information uncertainty
#> 21                                           Compare observed raters in a shared-rater model
#> 22                                                     Inspect testlet-model facet estimates
#> 23                                Review conditional Person scores from a shared-rater model
#> 24                                     Review conditional Person scores from a testlet model
#> 25 Review response residuals under supported RSMs, two-family GPCM MML or corrected GPCM JML
#> 26                                               Compare ordinary and extended model results
#> 27                                     Compare screening rules across known-truth conditions
#> 28                                               Show screening performance with uncertainty
#> 29                               Show pooled fixed-facet intervals after multiple imputation
#> 30                                                 Report saved external posterior intervals
#> 31                                       Inspect all residual associations and missing pairs
#> 32                                            Locate residual co-movement after model review
#> 33                                           Inspect exploratory groups of residual profiles
#> 34                                             Inspect separation of external-feature groups
#> 35                                                Describe an external feature within groups
#> 36                                            Inspect a hierarchy of external-feature groups
#> 37                                        Inspect group stability across feature imputations
#> 38                                    Choose how many external-feature components to inspect
#> 39                                            Locate entities on external-feature components
#> 40                                             Identify features contributing to a component
#> 41                                          Plan facet counts with an observed-score D-study
#> 42                                               Inspect sources of observed-score variation
#> 43                                    Plan reliability for a multivariate score or composite
#> 44                                            Plan absolute or relative error in score units
#> 45                                           Explain which error sources change across plans
#> 46                                             Compare D-study plans including the reference
#> 47                                           Inspect observed coverage across rating subsets
#> 48                                                 Customize the underlying precision values
#>                 ResultFunction      GGPlot
#> 1       rater_network_analysis unavailable
#> 2       rater_network_analysis unavailable
#> 3            fit_rater_network unavailable
#> 4            fit_rater_network unavailable
#> 5                     fit_mfrm   dedicated
#> 6                     fit_mfrm   dedicated
#> 7                     fit_mfrm   dedicated
#> 8                     fit_mfrm   dedicated
#> 9                     fit_mfrm   dedicated
#> 10          rating_scale_table   dedicated
#> 11          rating_scale_table   dedicated
#> 12      category_curves_report unavailable
#> 13        mfrm_facet_intervals   dedicated
#> 14     bias_interaction_report   dedicated
#> 15           estimate_all_bias   dedicated
#> 16   mfrm_population_intervals   dedicated
#> 17   mfrm_population_intervals   dedicated
#> 18 rater_halo_network_analysis   dedicated
#> 19            confint.mfrm_fit      native
#> 20        mfrm_curve_intervals      native
#> 21       fit_mfrm_random_rater   dedicated
#> 22            fit_mfrm_testlet   dedicated
#> 23     score_mfrm_random_rater   dedicated
#> 24        predict.mfrm_testlet   dedicated
#> 25   mfrm_response_diagnostics   dedicated
#> 26                compare_mfrm   dedicated
#> 27  mfrm_screening_sensitivity   dedicated
#> 28  mfrm_screening_performance unavailable
#> 29           pool_mfrm_imputed   dedicated
#> 30         read_mfrm_posterior   dedicated
#> 31       mfrm_residual_network   dedicated
#> 32       mfrm_residual_network unavailable
#> 33       mfrm_residual_network unavailable
#> 34                mfrm_cluster   dedicated
#> 35                mfrm_cluster   dedicated
#> 36   mfrm_cluster_hierarchical   dedicated
#> 37        mfrm_cluster_imputed   dedicated
#> 38                    mfrm_pca   dedicated
#> 39                    mfrm_pca   dedicated
#> 40                    mfrm_pca   dedicated
#> 41                mfrm_d_study unavailable
#> 42                mfrm_g_study   dedicated
#> 43                mfrm_d_study   dedicated
#> 44                mfrm_d_study   dedicated
#> 45                mfrm_d_study   dedicated
#> 46 mfrm_multivariate_d_compare unavailable
#> 47  subset_connectivity_report     generic
#> 48         compute_information     generic
```
