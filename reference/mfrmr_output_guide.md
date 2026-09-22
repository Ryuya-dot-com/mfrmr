# Choose an mfrmr output helper by user goal

`mfrmr_output_guide()` returns a compact table for choosing among the
main table, report, review, bundle, export, and compatibility helpers.
It is a user-facing map, not an analysis result.

## Usage

``` r
mfrmr_output_guide(
  scope = c("all", "public", "beginner", "psychometric", "entry", "viewer", "binary",
    "tables", "reports", "reviews", "bundles", "exports", "compatibility", "gpcm",
    "calibration", "simulation", "linking", "network", "response_time", "facets",
    "conquest", "r")
)
```

## Arguments

- scope:

  Which rows to return. `"all"` returns the full guide. `"public"`
  returns the canonical six-step route for most users; `"beginner"`
  returns the same compact route rather than combining every
  beginner-labelled specialist row. `"entry"` returns the recommended
  first-screen routes. `"viewer"` returns local-viewer routes built
  around `mfrm_results(include = ...)`. `"binary"` returns the
  two-category person-item Rasch route and checks. Other values filter
  to one output family or to bounded-`GPCM`-relevant routes. `"linking"`
  returns anchor, drift, and equating route rows. `"calibration"`
  returns the portable fixed-calibration lifecycle and artifact-only
  scoring route. `"simulation"` and `"network"` return advanced
  design-review rows. `"response_time"` returns descriptive
  response-time QC rows. `"facets"`, `"conquest"`, and `"r"` return
  user-pathway rows for people arriving from those workflows.

## Value

A data.frame with one row per recommended route and columns:

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
MML fit, the lightweight fit summary, the comprehensive measurement
review (whose historical profile name is `"facets"`; no FACETS software
knowledge or installation is required), the native Wright map with
SE/CI, optional FACETS-style Wright and person-inclusive Infit views,
and finally report/export. Use `mfrmr_output_guide("entry")` when you
specifically need alternative first-screen creation routes, including
existing result objects, the optional viewer, or interactive console
work. After creating `res`, use `summary(res)$next_actions` to choose a
purpose-specific specialist helper. Use `mfrmr_output_guide("viewer")`
when the next step is the optional local Shiny reader; it shows which
`include` preset to use before calling
[`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md).
Use `mfrmr_output_guide("psychometric")` for the technical table,
review, and reporting routes whose interpretation boundaries should be
checked before manuscript use.

## How to use this guide

Treat `MainFunction` as the route to try next and `UseWhen` as the
guardrail. The guide is not a replacement for the help pages of the
listed functions; it is a namespace map for deciding which page to open.
For bounded `GPCM`, use `scope = "gpcm"` to find both the support matrix
and the table that explains how out-of-scope routes are handled.

## Examples

``` r
beginner <- mfrmr_output_guide("beginner")
beginner[, c("Question", "MainFunction", "NextStep")]
#>                                                  Question
#> 1 1. Check score support and fit with explicit data roles
#> 2          2. Check convergence and fitted-model settings
#> 3           3. Build the comprehensive measurement review
#> 4  4. Create the required native Wright map with SE or CI
#> 5    5. Add optional FACETS-style and Infit pathway views
#> 6     6. Review, report, and export the completed results
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
```
