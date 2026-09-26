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
  returns anchor, drift, and equating route rows. `"calibration"`
  returns the portable fixed-calibration lifecycle and artifact-only
  scoring route. `"simulation"` and `"network"` return advanced
  design-review rows. `"response_time"` returns descriptive
  response-time QC rows. `"models"` compares fixed-facet, shared-rater
  and Person-specific testlet workflows, including their distinct
  prediction and reporting boundaries. `"feedback"` distinguishes
  fixed-rater uncertainty, unexpected rating patterns, shared-rater
  uncertainty and screening accuracy with known truth. `"features"`,
  `"imputation"` and `"gtheory"` show exploratory attributes,
  assigned-score multiple imputation and observed-score G/D-study
  workflows, including their own table, plot and saving routes.
  `"facets"`, `"conquest"`, and `"r"` return user-pathway rows for
  people arriving from those workflows.

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
MML fit, the lightweight fit summary, the fuller fit and precision
review (whose profile name is `"facets"`; no FACETS software knowledge
or installation is required), the native Wright map with uncertainty,
optional FACETS-style Wright and person-inclusive Infit views, and
finally report/export. Use `mfrmr_output_guide("entry")` when you
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
rater quality. For an individual native additive RSM/PCM sheet, use
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
Inspect `DecisionBoundary` before interpreting a result. For `GPCM`, use
`scope = "gpcm"` to find both the support matrix and the table that
explains how out-of-scope routes are handled.

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
#>                                                                                                                                                                                                                MainFunction
#> 1 describe_mfrm_data(data, person = ..., facets = ..., score = ..., rating_min = ..., rating_max = ...); fit <- fit_mfrm(data, person = ..., facets = ..., score = ..., rating_min = ..., rating_max = ..., method = "MML")
#> 2                                                                                                                                                                           summary(fit, profile = "fit", detail = "brief")
#> 3                                                                                                                                       review <- summary(fit, profile = "facets", detail = "brief"); res <- review$results
#> 4                                                                                                                      plot(res, type = "wright", renderer = "native", show_ci = TRUE, top_n = Inf, preset = "publication")
#> 5 fit$prep$score_map; plot(res, type = "wright", renderer = "facets", category_labels = rubric_labels, show_ci = FALSE); plot(res, type = "fit_pathway", fit_stat = "Infit", include_person = TRUE, person_labels = "none")
#> 6                                                                                                                report <- mfrm_report(res); summary(report, view = "reader"); export_mfrm_results(res, preset = "starter")
#>                                                                                                                    NextStep
#> 1       Review retained/missing categories and the score map, then run the lightweight fit profile and confirm convergence.
#> 2                     If the fit is usable, request profile = "facets"; otherwise resolve convergence or data issues first.
#> 3                                   Save review$results as res, then create the native Wright map before optional displays.
#> 4                 Inspect targeting, facet uncertainty, and every retained step; keep this figure with the analysis record.
#> 5     Use rubric labels from the actual instrument and treat person points as case-review prompts, not exclusion decisions.
#> 6 Read the report summary before export and keep replay plus data-handling metadata with every controlled analysis archive.

# Ask for a specialist map only when that question arises.
linking <- mfrmr_output_guide("linking")
linking[, c("Question", "MainFunction", "UseWhen")]
#>                                                               Question
#> 40 Open first-screen anchor and linking readiness from an existing fit
#> 41       Review intended anchor and group-anchor tables before fitting
#> 42                 Check drift across separately fitted waves or forms
#> 43         Build a screened equating chain across ordered calibrations
#>                                                                                                                    MainFunction
#> 40                                                          mfrm_results(fit, include = "linking"); plot(res, type = "anchors")
#> 41                                     make_anchor_table(); review_mfrm_anchors(); fit_mfrm(anchors = ..., group_anchors = ...)
#> 42                detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2)); build_linking_review(drift = ...); plot_anchor_drift()
#> 43 build_equating_chain(list(Form1 = fit1, Form2 = fit2)); build_linking_review(chain = ...); plot_anchor_drift(type = "chain")
#>                                                                                                                                                  UseWhen
#> 40                                         You already have an mfrm_fit and want the stored anchor-review evidence in the comprehensive results surface.
#> 41 You are preparing fixed anchors or group anchors and need to catch overlap, duplicate, missing, sparse, or unsupported anchor rows before estimation.
#> 42                                           You have two or more independently fitted waves and need common-element drift and thin-link support checks.
#> 43          You have an ordered sequence of forms or administrations and need screened adjacent-link offsets before operational score-scale maintenance.

feedback <- mfrmr_output_guide("feedback")
feedback[, c("Question", "MainFunction", "DecisionBoundary")]
#>                                                                                Question
#> 82                How uncertain are fixed-rater severities or prespecified differences?
#> 83 Which ordinary-model rating patterns need review, and do flags depend on the cutoff?
#> 84             Which rating patterns need review under a shared-rater or testlet model?
#> 85               How uncertain is an observed rater's severity in a shared-rater model?
#> 86             How often does a warning rule flag unaffected or detect affected raters?
#> 87                                             How can I prepare a sheet for one rater?
#>                                                  MainFunction
#> 82                                     mfrm_facet_intervals()
#> 83                                       fit_measures_table()
#> 84                                mfrm_response_diagnostics()
#> 85                   confint(); mfrm_random_rater_intervals()
#> 86 mfrm_screening_performance(); mfrm_screening_sensitivity()
#> 87                                              mfrm_report()
#>                                                                                                                                                                                                                                                                        DecisionBoundary
#> 82                                              Pointwise fixed-facet intervals, not simultaneous rater classifications or random-rater population inference. Sandwich SEs do not correct a biased estimate, informative assignment or MNAR missingness. No general coverage guarantee.
#> 83                            Flags are descriptive review prompts, not probabilities of poor rater quality. Severity is not misfit. Threshold sensitivity on observed data does not estimate false-flag or detection rates; GPCM retains its separate capability and inference limits.
#> 84                                                                                       Posterior predictive Infit/Outfit are descriptive and differ from ordinary plug-in indices. No classic cutoffs, ZSTD tests, automatic exclusion or calibrated diagnostic accuracy is supplied.
#> 85 Individual-rater intervals are not automatic. Normal and bootstrap approximations remain unqualified for general coverage; average prediction coverage does not establish coverage at each fixed severity. Do not substitute conditional Person intervals or population-SD profiles.
#> 86                         Known truth is required: real-data flags alone cannot estimate these rates. Monte Carlo intervals describe simulation uncertainty, not severity uncertainty. Unavailable screens are retained, and raters within one replication are not independent trials.
#> 87                                      No refitting, interval calculation, automatic warning cutoff or rater-quality classification. The sheet omits source identifiers; patterns may still be recognizable. Do not distribute the comprehensive source bundle as an individual sheet.

figures <- mfrmr_output_guide("plots")
figures[, c("Question", "ResultFunction", "GGPlot")]
#>                                                       Question
#> 1             Compare persons, facet levels and category steps
#> 2                          Show expected scores across ability
#> 3                   Review severity together with response fit
#> 4                                 Inspect category functioning
#> 5           Compare fixed-rater estimates and interval methods
#> 6                                  Show GPCM slope uncertainty
#> 7             Show GPCM probability or information uncertainty
#> 8              Compare observed raters in a shared-rater model
#> 9                        Inspect testlet-model facet estimates
#> 10  Review conditional Person scores from a shared-rater model
#> 11       Review conditional Person scores from a testlet model
#> 12                 Review response fit under an extended model
#> 13                 Compare ordinary and extended model results
#> 14       Compare screening rules across known-truth conditions
#> 15                 Show screening performance with uncertainty
#> 16 Show pooled fixed-facet intervals after multiple imputation
#> 17               Inspect separation of external-feature groups
#> 18                  Describe an external feature within groups
#> 19              Inspect a hierarchy of external-feature groups
#> 20          Inspect group stability across feature imputations
#> 21      Choose how many external-feature components to inspect
#> 22              Locate entities on external-feature components
#> 23               Identify features contributing to a component
#> 24            Plan facet counts with an observed-score D-study
#> 25      Plan reliability for a multivariate score or composite
#> 26              Plan absolute or relative error in score units
#> 27         Compare D-study scenarios with difference intervals
#> 28             Inspect observed coverage across rating subsets
#> 29                   Customize the underlying precision values
#>                 ResultFunction      GGPlot
#> 1                     fit_mfrm   dedicated
#> 2                     fit_mfrm   dedicated
#> 3                     fit_mfrm   dedicated
#> 4                     fit_mfrm   dedicated
#> 5         mfrm_facet_intervals   dedicated
#> 6             confint.mfrm_fit      native
#> 7         mfrm_curve_intervals      native
#> 8        fit_mfrm_random_rater   dedicated
#> 9             fit_mfrm_testlet   dedicated
#> 10     score_mfrm_random_rater   dedicated
#> 11        predict.mfrm_testlet   dedicated
#> 12   mfrm_response_diagnostics   dedicated
#> 13                compare_mfrm   dedicated
#> 14  mfrm_screening_sensitivity   dedicated
#> 15  mfrm_screening_performance unavailable
#> 16           pool_mfrm_imputed   dedicated
#> 17                mfrm_cluster   dedicated
#> 18                mfrm_cluster   dedicated
#> 19   mfrm_cluster_hierarchical   dedicated
#> 20        mfrm_cluster_imputed   dedicated
#> 21                    mfrm_pca   dedicated
#> 22                    mfrm_pca   dedicated
#> 23                    mfrm_pca   dedicated
#> 24                mfrm_d_study unavailable
#> 25   mfrm_multivariate_d_study   dedicated
#> 26   mfrm_multivariate_d_study   dedicated
#> 27 mfrm_multivariate_d_compare unavailable
#> 28  subset_connectivity_report     generic
#> 29         compute_information     generic
```
