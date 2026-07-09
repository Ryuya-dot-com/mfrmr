# mfrmr

[![GitHub](https://img.shields.io/badge/GitHub-mfrmr-181717?logo=github)](https://github.com/Ryuya-dot-com/mfrmr)
[![R-CMD-check](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/pkgdown.yaml)
[![test-coverage](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/test-coverage.yaml)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Native R package for many-facet ordered-response measurement models: the
Rasch-family `RSM` / `PCM` route, plus the package’s bounded `GPCM`
extension where explicitly documented.

Package website: <https://ryuya-dot-com.github.io/mfrmr/>

## Start here

Use `mfrmr` when ordered ratings or scores are shaped by more than one
source, such as people, raters, items, tasks, criteria, forms, or
occasions. The package fits the model, then helps you read the result
without treating every diagnostic as a final decision.

The shortest route is:

``` r

fit <- fit_mfrm(my_data, person = "Person", facets = c("Rater", "Criterion"),
                score = "Score", model = "RSM")
res <- mfrm_results(fit)
summary(res, view = "brief")
report <- mfrm_report(res)
summary(report, view = "reader")
```

After that first screen, use `mfrmr_output_guide("public")` to choose
the next route. Use `mfrmr_output_guide("beginner")` for a gentler map,
`mfrmr_output_guide("psychometric")` for technical reporting boundaries,
and `?mfrmr-package` when you need the fuller package-level reference.
For GPCM limits, start with
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
and
[`vignette("mfrmr-gpcm-scope", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.md).

## Core terms

| Term | Plain-language meaning in this package |
|----|----|
| Many-facet model | A model that estimates the target measure while also accounting for other score-shaping roles, such as rater severity or item difficulty. |
| Facet | A role in the data design, for example rater, item, task, criterion, form, or occasion. |
| Logit | The model’s measurement unit. Larger logits mean more of the latent trait or stronger facet effects on the model scale. |
| `RSM` | Rating scale model: ordered categories share one step pattern across the selected design. |
| `PCM` | Partial credit model: ordered categories may have item/facet-specific step patterns. |
| Bounded `GPCM` | The documented 0.2.2 GPCM extension. It is useful where marked as supported, but it is not unrestricted free-slope GPCM. |
| Infit / Outfit | Fit summaries that flag unexpectedly patterned or unexpectedly large residual behavior. They are review prompts, not automatic exclusion rules. |
| Separation / reliability / strata | Descriptive summaries of how clearly units are spread apart on the fitted scale. They are not the same as validity evidence. |
| EAP | A posterior scoring summary for a person or unit under the fitted calibration and prior. |
| Wright map | A plot that puts persons and facet parameters on a shared logit scale for inspection. |
| Anchor | A parameter or design element held stable so results can be compared across waves, forms, or calibrations. |
| DIF / DFF | Screening routes for possible subgroup or facet-related differences. They identify follow-up questions, not final fairness conclusions. |

## 0.2.2 release scope

Read 0.2.2 in two layers. The short version is that this is still the
unidimensional
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
package, with stronger report, review, visual, G-theory, bounded-`GPCM`,
DIF, linking, and release-evidence support around that engine. The
comprehensive scope map below is the release boundary to keep in view
before treating a helper as a new model engine.

| Area | Included in 0.2.2 | Boundary to report explicitly |
|----|----|----|
| Core model engine | [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md) estimates the existing unidimensional ordered-response MFRM route for `RSM`, `PCM`, and the documented bounded-`GPCM` branch. | No multidimensional latent trait engine, Q-matrix design, arbitrary covariance structure, `formulaA`-style model matrix, mixture, or response-process model is implemented in [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md). |
| First-screen workflow | [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md), `summary(..., view = "brief")`, [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md), `summary(..., view = "reader")`, and `export_mfrm_results(preset = "starter")` make the first result/report/export route easier to read. | These helpers organize existing evidence; they do not refit the model, change diagnostics, or create an acceptance rule. |
| FACETS transition | [`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_positioning_guide.md), `facets_term_crosswalk()`, [`facets_feature_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_feature_coverage.md), `facets_visual_contract()`, and related file contracts explain FACETS-facing terminology and handoff surfaces. | FACETS-style names are migration/presentation contracts, not numerical equivalence claims unless external FACETS output is explicitly supplied and compared. |
| Reporting and reviewer completeness | `mfrmr_minimum_report_checklist()`, [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md), `mfrmr_output_guide("beginner")`, and `mfrmr_output_guide("psychometric")` separate beginner routes from technical review routes. | Package output supports the validity argument; it does not establish content evidence, response-process evidence, consequences, fairness, or operational use by itself. |
| Generalizability theory | [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md), [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md), `check_mfrm_generalizability_design()`, `compare_mfrm_generalizability()`, and `bootstrap_mfrm_generalizability()` provide observed-score G-study/D-study complements, interaction sensitivity review, design checks, and person-cluster bootstrap intervals. | `G` and `Phi` are observed-score G-theory coefficients, not fitted-logit MFRM separation reliability, rater agreement, or validity evidence. Sparse or singular interaction models are sensitivity evidence. |
| Bounded `GPCM` | [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md), [`gpcm_score_side_contract()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_score_side_contract.md), fixed score-side simulation evidence, and fixed external probability-kernel comparisons document supported and caveated routes. | This is not complete unrestricted GPCM, not full FACETS score-side equivalence, not posterior predictive checking, and not a heavy-backend Bayesian implementation. |
| Model-family and estimator scope | `mfrmr_model_family_scope()`, `mfrmr_estimation_scope()`, `estimate_population_sd = TRUE`, and `analyze_eap_power_sensitivity()` document current and deferred model/estimation choices. | Scope helpers do not implement the deferred models they describe. Free-SD and EAP sensitivity routes do not imply latent-regression, mixture, MCMC, or structural-SE unification. |
| DIF/DFF and fairness screening | [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md), [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md), `analyze_dif_mh()`, `analyze_dff_moderation()`, and `dif_report(style = "apa")` support conservative bias/DIF screening and APA-style reporting boundaries. | Screens are prompts for follow-up design and substantive review, not final fairness, invariance, or subgroup-decision conclusions. |
| Anchoring and linking | [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md), [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md), `anchor_linking_contract()`, [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md), [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md), and [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md) make anchor/linking support auditable. | Drift, equating, or scale-maintenance claims require explicit multi-fit wave/form designs and anchor support, not a single fitted summary. |
| Visualization | `plot(..., draw = FALSE)`, [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md), `as_ggplot()`, [`visual_reporting_template()`](https://ryuya-dot-com.github.io/mfrmr/reference/visual_reporting_template.md), and `facets_visual_contract()` expose editable visual payloads and caption guidance. | Visuals are diagnostic/reporting evidence; they are not standalone validity, fairness, or FACETS-equivalent graphics claims. |
| Simulation and design planning | [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md), [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md), [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md), and [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md) separate data generation, recovery, design-grid review, and screening operating characteristics. | Simulation results inform planning and sensitivity, not observed-study validity or automatic operational decisions. |
| Response-time QC | [`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md) and response-time plot/export routes carry timing metadata as descriptive QC context. | No speed parameter, joint speed-accuracy model, modified logit, or automatic exclusion rule is fitted. |
| Release evidence | Versioned validation artifacts under `inst/validation/` and `release_readiness()` record fixed smoke evidence, evidence maps, and release-scope checks for 0.2.2. | Fixed artifacts document the release claim; they do not rerun every long simulation during ordinary CRAN checks. |

## Public surface

`mfrmr` has many specialist helpers, but most users should start from a
small public surface and drill down only when a report or review
question requires it.

| Layer | Use first | Purpose |
|----|----|----|
| Fit | [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md) -\> [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md) | Explicit, scriptable model roles and diagnostics |
| Results | `res <- mfrm_results(fit)` -\> `summary(res, view = "brief")` | Reader-first overview, highest-priority triage, next actions, plot routes, replay code |
| Report | `report <- mfrm_report(res)` -\> `summary(report, view = "reader")` | Report readiness, claim-use guidance, cautious wording routes, HTML/Markdown report output |
| Viewer | `launch_mfrmr_viewer(res)` | Optional local reader over an existing `mfrm_results` object |
| Export | `export_mfrm_results(res, preset = "starter")` | Reader-first folder with `index.html`, report tables, evidence summaries, replay code, manifest |
| Guide | `mfrmr_output_guide("public")` | Compact map from user purpose to the next route |
| Interactive | `mfrm_results_interactive(df)` | Explicit opt-in column prompts for exploratory console work |

The rest of the namespace is best read as specialist follow-up:
`*_table()` functions expose focused evidence tables, `*_report()` and
`*_review()` functions bundle evidence for a particular question,
`*_bundle()` functions prepare reusable handoff objects, and
`export_*()` functions write files. Use `mfrmr_output_guide("public")`
for the top-level map and `mfrmr_output_guide("reports")`, `"reviews"`,
`"exports"`, `"linking"`, `"simulation"`, `"response_time"`, `"facets"`,
or `"r"` only after the first screen points there. The guide’s
`ObjectRole` and `DecisionBoundary` columns are the most direct way to
check whether a route estimates the model, summarizes existing evidence,
displays a result, writes files, or merely points to the next helper.

## Recommended workflow

For an initial analysis, run this route before branching into
specialized tables, reviews, simulations, or compatibility outputs. Help
pages use the compact `example_core` fixture to keep examples light; the
workflow below uses the packaged Study 1 data so the first-screen route
is closer to an ordinary analysis.

``` r

library(mfrmr)
study1 <- load_mfrmr_data("study1")

fit <- fit_mfrm(
  study1,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM",
  quad_points = 15
  # Use the default quad_points = 31 for final publication-tier reruns.
)

summary(fit)

# Comprehensive first screen: diagnostics, tables, report status, plot routes.
res <- mfrm_results(fit)
summary(res, view = "brief")
plot(res, type = "qc", preset = "publication")
summary(res)$next_actions

# Report-readiness first screen and shareable output.
report <- mfrm_report(res)
summary(report, view = "reader")
export_mfrm_results(
  res,
  output_dir = "mfrmr-results",
  prefix = "analysis01",
  preset = "starter",
  zip_bundle = TRUE,
  overwrite = TRUE
)

# Compact public-API map for any branch that remains unclear.
mfrmr_output_guide("public")
```

When the first screen points to a specific need, use a scoped guide
rather than scanning the namespace:

``` r

mfrmr_output_guide("reports")
mfrmr_output_guide("reviews")
mfrmr_output_guide("exports")
mfrmr_output_guide("linking")
mfrmr_output_guide("response_time")
```

## First API routes

Use this table after the public surface when a specific situation
applies.

| Situation | First call | Then |
|----|----|----|
| New reproducible analysis | [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md) -\> [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md) | `summary(res, view = "brief")`, `plot(res, type = "qc")`, `summary(res)$next_actions` |
| Binary person-item response data | `fit_mfrm(..., facets = "Item", model = "RSM")` -\> [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md) | Check `fit$summary$Categories == 2`; use `mfrmr_output_guide("binary")` for the route |
| Existing `mfrm_fit` object | `mfrm_results(fit)` | Drill into `res$components` or `build_summary_table_bundle(res)` |
| Local point-and-click review | `mfrm_results(fit, include = ...)` -\> `launch_mfrmr_viewer(res)` | Use `mfrmr_output_guide("viewer")` to choose `include = "publication"`, `"bias"`, `"misfit_review"`, `"linking"`, or a combined route |
| Report-ready QC or validation text | `res <- mfrm_results(fit)` -\> `mfrm_report(res, style = "qc")` | Start with `summary(report, view = "reader")`; use `style = "apa"`, `"validation"`, `"reviewer"`, or `"technical"` only for that reporting question |
| Reader-first file handoff | `export_mfrm_results(res, preset = "starter")` | Writes `index.html`, compact summaries, report-readiness CSVs, evidence summaries, replay code, and a manifest |
| Anchor and linking readiness | `mfrm_results(fit, include = "linking")` | Inspect `summary(res$components$linking_review)` and `plot(res, type = "anchors")`; use `mfrmr_output_guide("linking")` for drift/equating follow-up |
| Response-time metadata | `response_time_review(data, person = ..., time = ...)` | Use `plot_response_time_review(..., draw = FALSE)` and `mfrmr_output_guide("response_time")`; keep timing as descriptive QC, not a fitted speed parameter |
| Unfamiliar data frame at the console | `mfrm_results_interactive(df)` | Move the printed replay code into an explicit script |
| Purpose-specific reporting or review | `mfrmr_output_guide("reviews")` / `"reports"` / `"exports"` | Use the listed helper only when that reporting question is needed |
| FACETS-facing handoff | `mfrmr_output_guide("facets")` | Keep compatibility outputs as presentation contracts, not equivalence claims |

For the shortest programmatic version of this map, use
`mfrmr_output_guide("public")`; for fit/result creation routes only, use
`mfrmr_output_guide("entry")`. For viewer-specific `include` choices,
use `mfrmr_output_guide("viewer")`. The guide also carries `APILayer`,
`ObjectRole`, `DecisionBoundary`, `Lifecycle`, `UserLevel`, and
`RecommendedEntry` columns so top-level public surfaces, specialist
follow-ups, advanced design review, compatibility routes, and migration
routes are not mixed together by accident.

Before branching into specialist helpers, keep the 0.2.2 release scope
above in view. The shortest operational boundary summary is:

| Area | Current conclusion | Do not claim from this route alone |
|----|----|----|
| [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md) | First-screen result object over existing fit, diagnostics, reports, tables, plot routes, and next actions. | A new estimator, new diagnostic rule, or automatic acceptance decision. |
| G-theory helpers | Observed-score G-study/D-study complements for design generalizability, interaction sensitivity, and uncertainty review. | Fitted-logit MFRM separation reliability, rater agreement, validity, or definitive variance partitions from sparse/singular interaction models. |
| Response-time QC | Descriptive timing review that can be carried through [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md), plots, viewer, and exports when timing metadata are supplied. | Speed parameters, a joint speed-accuracy model, modified logits, or automatic exclusion rules. |
| Bounded `GPCM` | Supported only inside the documented capability matrix; direct outputs and caveated helpers are usable where marked. | Full FACETS score-side support, posterior predictive checks, or heavy backends unless [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md) marks that row as supported. |

For dichotomous person-item data, use the same explicit route rather
than a separate function. Pass the person column to `person`, pass the
item column as the single non-person facet, and keep the score column as
ordered binary integer categories:

``` r

fit_bin <- fit_mfrm(
  data = binary_df,
  person = "Person",
  facets = "Item",
  score = "Score",
  model = "RSM"
)

fit_bin$summary[, c("Model", "Facets", "Categories", "Converged")]
mfrmr_output_guide("binary")
res_bin <- mfrm_results(fit_bin)
summary(res_bin)$triage
```

With exactly two ordered categories, the `RSM` branch is the ordinary
binary Rasch logit up to the package’s centering and
threshold-identification conventions. `Score` may be coded as `0/1` or
`1/2`; inspect `fit_bin$prep$score_map` when documenting the coding. Do
not include the person column again inside `facets`.

If you want a local point-and-click reader after creating the
comprehensive result object, use the optional Shiny viewer. The viewer
does not fit a model or contact an external web application; it reads an
existing `mfrm_results` object and displays its overview, triage,
status, tables, plots, and replay code. When the result object contains
the relevant sections, the viewer also exposes QC evidence, APA-style
draft text and table/figure notes, bias-screen tables, the pathway map,
and an unexpected-response selector for row-level misfit inspection. The
QC, Report, Bias, and Pathway/Misfit tabs show section-status tables, so
omitted or unavailable sections are explained in the tab where the user
expects them. Bias-interaction review still requires an explicit
facet-pair choice in code; the viewer does not choose that contrast
automatically.

``` r

res <- mfrm_results(fit, include = c("publication", "bias", "misfit_review"))
mfrmr_output_guide("viewer")[, c("Question", "MainFunction")]

if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  launch_mfrmr_viewer(res)
}
```

This keeps the reproducible analysis route explicit: first create `fit`,
then create `res <- mfrm_results(fit)`, then use the viewer only for
inspection. To download the same comprehensive result without opening
Shiny, export it:

``` r

download <- export_mfrm_results(
  res,
  output_dir = "mfrmr-results",
  prefix = "analysis01",
  preset = "starter",
  zip_bundle = TRUE,
  overwrite = TRUE
)
download$written_files
```

Open `index.html` first. The starter export keeps the reader-facing
files at the root, groups compact summaries in `00_summary/`,
report-readiness tables in `01_report/`, primary evidence summaries in
`02_evidence/`, and replay/manifest artifacts in `03_reproducibility/`.
When `zip_bundle = TRUE`, that folder layout is preserved inside the zip
archive.

For report drafting, keep the same object-first route and turn the
already assembled evidence into a section plan:

``` r

report <- mfrm_report(res, style = "qc")
summary(report, view = "reader")
report$first_screen
report$report_index
report$template_index
names(report$tables)
mfrm_report(res, style = "validation", output = "html")
```

[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
is a reporting surface over
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md):
it does not add a new estimator, recompute diagnostics, or turn fit,
separation, bias screens, misfit rows, or anchor evidence into automatic
pass/fail decisions. Its `first_screen`, `report_index`,
`template_index`, `claim_readiness`, and `report_gaps` tables are
intended to make report wording more conservative. `first_screen` is the
FACETS-like entry surface: it gives an `Overall` row and one row per
major evidence area with `Status`, `Readiness`, `MainIssue`,
`NextAction`, and `PrimaryRoute`, so users can see where to start before
opening the detailed tables. `summary(report, view = "reader")` is the
short reader-facing version of that surface: it starts from the first
screen and then shows what can be reported, what needs caveats, and what
needs more evidence before listing immediate actions and report gaps.
HTML output uses the same order, placing reader guidance, first-screen
tables, reader claims, and report gaps before the full Markdown text.
`report_index` then shows the major evidence areas, status, readiness
label, review-signal count, and primary/template tables to inspect next;
`claim_readiness` and `report_gaps` show which claims are ready, which
need caveats, and which require a more specific `include` preset or
helper. `report_index` also carries `EvidenceRoute`, `TemplateRoute`,
`PlotRoute`, `ExportRoute`, and `IncludePreset` columns so the report
route points to the next table, figure, export, or
`mfrm_results(include = ...)` call without turning those routes into new
evidence. `template_index` stacks all reporting-template rows across
fit, precision, bias, misfit/pathway, and linking/anchor areas so
unsupported or caveated wording can be reviewed before opening the full
template text. Detailed tables remain available through `report$tables`;
use `report$report_index$PrimaryTable`,
`report$report_index$TemplateTable`, and `report$report_index$PlotRoute`
to choose the next table or figure rather than opening every report
table by default. For fit claims, also inspect `fit_criteria`,
`zstd_conventions`, and `fit_decision_policy`, plus the result-specific
`fit_evidence_summary`, `fit_threshold_sensitivity`,
`fit_reporting_templates`, and `fit_df_sensitivity_summary` tables. Also
inspect `precision_evidence_summary`, `precision_basis`, and
`precision_reporting_templates` before writing separation, reliability,
or strata claims. These tables keep the selected MnSq band, observed
fit-status counts, alternative published threshold profiles,
engine-vs-FACETS-style ZSTD standardization, and Rasch/FACETS-style
precision indices visible. The reporting templates turn those counts
into cautious APA/QC/validation/reviewer wording scaffolds without
turning the result into a single pass/fail sentence. Each
reporting-template table also carries `EvidenceTable`, `EvidenceRoute`,
`BoundaryType`, `ClaimStrength`, and `RecommendedUse`, so wording can be
traced back to its evidence source and claim boundary before it is
pasted into a manuscript, QC memo, reviewer response, or appendix.
FACETS-style ZSTD review uses the fourth-moment df convention and can
retain positive df below 1 with capped ZSTD values; report this as a
standardization convention rather than as a different MnSq fit signal.
If a ZSTD flag changes only because the df convention changes, treat
that row as a review prompt and return to the MnSq size, facet role, and
response context before writing a substantive fit claim. If separation
or reliability is high, still report it as precision evidence rather
than inter-rater agreement or standalone validity evidence. When `res`
was built with `include = "bias"`, `bias_evidence_summary` and
`bias_reporting_templates` add the same guardrails for bias, DFF, and
fairness language: facet-level bias rows are screening prompts,
interaction-bias contrasts must be chosen explicitly, and DFF claims
require a documented group, method, linking/anchor support, and
threshold policy. When `res` was built with `include = "misfit_review"`,
`misfit_evidence_summary` and `misfit_reporting_templates` extend the
same boundary to unexpected responses, displacement, and pathway maps:
local misfit rows are case-review prompts, not automatic exclusion,
fairness, or validity decisions. When `res` was built with
`include = "linking"`, `linking_evidence_summary` and
`linking_reporting_templates` extend the boundary to anchor readiness,
drift review, and equating-chain wording: anchor evidence supports
scale-maintenance review, but drift and equating claims still require
explicit multi-fit wave/form comparisons.

Start with `summary(res, view = "brief")` before reading every table. It
keeps the overview, highest-priority triage rows, first next actions,
and available plot routes visible without printing the full
section-status and table-index payload. Use `summary(res)$triage` and
`summary(res)$status` only when the brief screen points to detailed
routing.

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
accepts purpose presets in `include`, so common workflows can stay
readable:

``` r

mfrm_results(fit, include = "standard")     # first screen
mfrm_results(fit, include = "publication")  # add APA assembly
mfrm_results(fit, include = "validation")   # add FACETS-fit review
mfrm_results(fit, include = "bias")         # add bias-screen guidance
mfrm_results(fit, include = "misfit_review")# add unexpected/displacement/pathway review
mfrm_results(fit, include = "linking")      # add anchor-readiness/linking review
mfrm_results(fit, include = "network")      # add connectivity review
mfrm_results(                              # add descriptive timing QC
  fit,
  include = "response_time",
  response_time = "ResponseTime",
  response_time_data = original_data
)
mfrm_results(fit, include = "gpcm_review")  # standard route with GPCM caveats
```

If you want the shortest possible recommendation:

- Final estimation: prefer `method = "MML"`
- Fast exploratory pass only: use `method = "JML"`
- Preferred `RSM` / `PCM` fit screen:
  `diagnose_mfrm(..., diagnostic_mode = "both")`
- First visual screen: `plot_qc_dashboard(..., preset = "publication")`
- First reporting screen: `report <- mfrm_report(res)` and
  `summary(report, view = "reader")`
- Manuscript checklist follow-up:
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
- First case-review screen:
  [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
  and then inspect `casebook$group_view_index`
- First weighting-policy screen:
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
- First operational linking screen:
  `mfrm_results(fit, include = "linking")` for anchor readiness from one
  fit, then
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  /
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  with explicit lists of fitted waves or forms;
  [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
  is the synthesis layer. For bounded `GPCM`, use it as a caveated
  exploratory index over direct anchor, drift, and chain support and do
  not treat it as an operational linking decision.

## Minimum input contract

`mfrmr` expects long-format rating data: one row per observed rating.

- Required columns:
  - one person column
  - one ordered score column
  - one or more non-person facet columns supplied in `facets = c(...)`
- Score-column rules:
  - scores should be ordered integer category codes such as `0/1`,
    `1/2`, or `1:5`
  - binary two-category scores are supported under the same
    ordered-response interface
  - fractional scores are rejected; recode them explicitly before
    fitting
  - non-numeric score labels are dropped with a warning if coercion
    fails
  - when `keep_original = FALSE`, unused intermediate categories are
    collapsed to a contiguous internal scale and recorded in
    `fit$prep$score_map`
  - if the intended scale has unused boundary categories, such as a 1-5
    scale with only 2-5 observed, set `rating_min = 1, rating_max = 5`
    so the zero-count boundary category remains in the fitted support
  - if the intended scale has unused intermediate categories, such as 1,
    3, 5 observed on a 1-5 scale, also set `keep_original = TRUE`
  - `summary(describe_mfrm_data(...))` reports retained zero-count
    categories in `Notes`, the printed `Caveats` block, and `$caveats`;
    `summary(fit)` carries the full structured rows into printed
    `Caveats` and appendix/export role `analysis_caveats`, with
    `Key warnings` as a short triage subset
- Typical optional columns:
  - `Subset` for disconnected-form or linking work
  - `Weight` for weighted analyses
  - `Group` when downstream fairness or DFF workflows need grouping
    metadata
  - `ResponseTime` (or similar) for descriptive timing review with
    [`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md);
    timing metadata are not part of the fitted MFRM likelihood

Response-time metadata can be screened as a separate quality-control
layer:

``` r

rt <- response_time_review(
  dat,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  time = "ResponseTime"
)

summary(rt)
plot_response_time_review(rt, type = "distribution")
plot_response_time_review(rt, type = "person")

res_rt <- mfrm_results(
  fit,
  include = c("standard", "response_time"),
  response_time = "ResponseTime",
  response_time_data = dat
)
summary(res_rt)$next_actions
plot(res_rt, type = "response_time", draw = FALSE)
```

Use these outputs to locate rapid/slow response-time patterns by person,
facet, or score category. Do not describe them as joint speed-accuracy
model parameters or automatic exclusion rules.

Minimal pattern:

``` r

names(df)
# [1] "Person" "Rater" "Criterion" "Score"

fit <- fit_mfrm(
  data = df,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)
```

For exploratory use, `mfrm_results(df)` can start from a standard
long-format data frame when `Person` and `Score` are unambiguous column
names; all remaining columns are treated as facets. For ambiguous files,
keep the reproducible route explicit with `fit_mfrm(...)`. If you want
column-selection prompts in an interactive R session, use the opt-in
wizard:

``` r

if (interactive()) {
  res <- mfrm_results_interactive(df)
}
```

## Main capabilities

Core analysis:

- comprehensive first-screen results via
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
  with automatic diagnostics, table collection, plot routing, and
  optional temporary HTML
- estimation with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  under `MML` or `JML`
- fit diagnostics with
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
  and residual PCA follow-up
- strict marginal follow-up for `RSM` / `PCM` via
  `diagnostic_mode = "both"`,
  [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md),
  and
  [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md)
- package-native tables and summaries via
  [`summary()`](https://rdrr.io/r/base/summary.html),
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
  and
  [`facet_statistics_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_statistics_report.md)

Reporting and QA:

- APA/report drafting with
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
  and
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
- visual/report routing with
  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
  and
  [`mfrmr_interval_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_interval_guide.md)
- QC workflows with
  [`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md)
  and
  [`plot_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_pipeline.md)
- descriptive response-time QC with
  [`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md)
  and
  [`plot_response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_response_time_review.md)
  when timing metadata are available
- reproducible export helpers such as
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
  [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md),
  and
  [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md)

Linking, fairness, and advanced review:

- bias and DFF/DIF workflows through
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
  [`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md),
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  `analyze_dff_moderation()`, `analyze_dif_mh()`, and
  [`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md)
- anchoring and linking via
  [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md),
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
  and
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
- precision/targeting views via
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
  [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md),
  and
  [`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md)
- equivalence and review helpers such as
  [`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md),
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
  and
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)

Design-adequacy review and partial pooling:

- hierarchical-structure and sample-adequacy review with
  [`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md),
  [`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md),
  [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
  [`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md),
  and the combined
  [`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md)
- empirical-Bayes / James-Stein shrinkage for small-N facets via
  `fit_mfrm(..., facet_shrinkage = "empirical_bayes")` or post-hoc
  [`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md),
  with
  [`shrinkage_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/shrinkage_report.md)
  as the accessor
- missing-code pre-processing through
  `fit_mfrm(..., missing_codes = TRUE)` (FACETS / SPSS / SAS sentinels
  such as `99`, `999`, `-1`, `"N/A"`, `""` converted to `NA`) or the
  standalone
  [`recode_missing_codes()`](https://ryuya-dot-com.github.io/mfrmr/reference/recode_missing_codes.md)
  helper
- APA output adapters
  [`as_kable.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_kable.apa_table.md)
  and
  [`as_flextable.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_flextable.apa_table.md)
  for RMarkdown / Quarto / Word / PowerPoint handoffs

Advanced or compatibility scope:

- legacy-compatible one-shot wrapper:
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  /
  [`mfrmRFacets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
- simulation and planning helpers:
  [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
  [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md),
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md),
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
- future-unit posterior scoring:
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  and
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)

## Latent regression status

`mfrmr` now includes a first-version latent-regression branch inside
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
Activate it with `method = "MML"`, `population_formula = ~ ...`, and
one-row-per-person `person_data`.

Current supported boundary:

- ordered-response `RSM` / `PCM`
- one latent dimension
- conditional-normal person population model
- estimated conditional residual variance `sigma2`; this is separate
  from the ordinary fixed-SD MML route
- person covariates supplied through an explicit person table and
  expanded through
  [`stats::model.matrix()`](https://rdrr.io/r/stats/model.matrix.html),
  including numeric/logical predictors and factor/character categorical
  predictors
- posterior scoring and plausible-value draws that condition on the
  fitted population model

What to inspect after fitting:

- `summary(fit)$population_overview` shows the posterior basis, residual
  variance, and any omitted-person counts.
- `summary(fit)$population_coefficients` shows the latent-regression
  coefficients.
- `summary(fit)$population_coding` shows how categorical covariates were
  coded.
- `summary(fit)$key_warnings` and `summary(fit)$caveats` flag issues
  that should be reviewed before reporting or exporting results.

Introductory workflow:

``` r

# response data: one row per rating event
# person data: one row per person, with the same Person IDs
person_tbl <- unique(dat[c("Person", "Grade", "Group")])

fit_pop <- fit_mfrm(
  data = dat,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM",
  population_formula = ~ Grade + Group,
  person_data = person_tbl,
  population_policy = "error"
)

s_pop <- summary(fit_pop)
s_pop$population_overview      # posterior basis, residual variance, omissions
s_pop$population_coefficients  # latent-regression coefficients
s_pop$population_coding        # categorical levels / contrasts / encoded columns
s_pop$caveats                  # complete-case and category-support warnings
```

Use `population_policy = "omit"` only when complete-case removal is
intended, then report the omitted-person and omitted-row counts.
Coefficients in `population_coefficients` are conditional-normal
population-model parameters, not a post hoc regression on EAP/MLE
scores.

Reference checks for this branch:

``` r

bench_pop <- reference_case_benchmark(
  cases = c("synthetic_latent_regression_omit", "synthetic_conquest_overlap_dry_run"),
  method = "MML",
  model = "RSM",
  quad_points = 5,
  maxit = 30
)

summary(bench_pop)
bench_pop$population_policy_checks  # complete-case omission check
bench_pop$conquest_overlap_checks   # package-side ConQuest preparation check
```

The ConQuest preparation case checks only package-side preparation. It
does not run ConQuest. When actual ConQuest output tables are available
for the documented overlap case, use the external-table comparison
helpers:

``` r

bundle <- build_conquest_overlap_bundle(fit_overlap, output_dir = "conquest_overlap")
normalized <- normalize_conquest_overlap_files(
  population_file = "conquest_population.csv",
  item_file = "conquest_items.csv",
  case_file = "conquest_cases.csv"
)
review <- review_conquest_overlap(bundle, normalized)
summary(review)$summary
review$attention_items
```

Treat this as a scoped comparison, not as full ConQuest numerical
equivalence. ConQuest must be run separately and the extracted tables
must be reviewed.

Current non-goals for this branch:

- `JML` latent regression
- bounded `GPCM` latent regression
- multidimensional population models
- arbitrary imported design specifications
- the full ConQuest plausible-values workflow

This should be described as first-version overlap with the ConQuest
latent-regression framework, not as ConQuest numerical equivalence.

[`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
remains a simulation-based scenario-forecasting helper. It should not be
described as the latent-regression estimator itself.

## Bounded GPCM support

`GPCM` is now part of the supported package scope, but only within a
bounded route. Use
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
to see the current boundary in one place. The matrix includes
`RecommendedRoute` and `NextValidationStep` columns, so out-of-scope
helper families point to the supported substitute workflow and the
evidence needed before that boundary can move.
`mfrmr_output_guide("gpcm")` routes users to the same support matrix and
to the table that lists how out-of-scope `GPCM` routes are handled.

Here “bounded” is literal. It means a constrained package-native branch,
not a complete unrestricted GPCM implementation. The current branch is a
many-facet GPCM route that preserves the role-based design contract,
requires explicit step-facet structure, keeps
`slope_facet == step_facet`, identifies positive slopes with geometric
mean one, and validates downstream helpers one capability row at a time.
Arbitrary slope structures, multidimensional or random-effect GPCM
extensions, MCMC or posterior-predictive engines, and full FACETS-style
score-side equivalence are outside the current boundary.

A complete unrestricted package-native GPCM route would have to remove
that structural restriction: slopes would need to be specifiable and
estimable independently of the step facet, with identification,
covariance, reduction tests, simulation, score-side uncertainty, and
every downstream helper defined for the general slope design. Even then,
free-discrimination GPCM would still need its own slope-aware score-side
contract rather than FACETS-style raw-score-to-measure equivalence,
because raw-score sufficiency does not carry over from the Rasch-family
route.

When a blocked or deferred helper is called on a bounded-`GPCM` path,
the error message includes the capability row, recommended substitute
route, and next validation step rather than silently returning a partial
reporting object. These errors carry class `mfrmr_gpcm_scope_error` with
`helper`, `area`, `status`, `recommended_route`, and
`next_validation_step` fields for programmatic handling. Advanced users
can call
[`gpcm_runtime_guard_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_runtime_guard_coverage.md)
to see which out-of-scope rows stop with that structured guidance and
which rows are documented as future-extension scope.

The model basis is Muraki’s generalized partial credit model and its
information-function extension. The package-level `slope_regime` labels
used in simulation specifications are narrower: they are operational
recovery stress labels for reading generated conditions, not
psychometric fit or adequacy cut points from Muraki or later literature.
The recovery workflow is organized in the ADEMP spirit: aims,
data-generating mechanism, estimands, methods, and performance measures
are kept explicit before interpreting Monte Carlo summaries.

For the 0.2.2 release evidence map:

``` r

file.show(system.file(
  "validation", "release-evidence-map-0.2.2.md",
  package = "mfrmr"
))
```

- Supported core: fitting,
  [`summary()`](https://rdrr.io/r/base/summary.html) /
  [`print()`](https://rdrr.io/r/base/print.html), posterior scoring,
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
  Wright/pathway/CCC plots, and category reports.
- Supported with caveat:
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  and direct slope-aware simulation are exploratory;
  [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
  checks direct parameter recovery rather than design operating
  characteristics;
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
  and
  [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
  route only the direct table/plot path.
  [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  and
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  use the slope-aware element-conditional GPCM kernel. For fair
  averages, the historical SE columns remain scaled facet-measure SEs;
  use `fair_average_table(fair_se = TRUE)` to request structural
  delta-method fair-average SEs for non-person rows when the MML Hessian
  is available. For bias screening, the SE / `t` / `Prob.` columns are
  conditional plug-in screening quantities, and bounded-GPCM rows also
  carry conditional profile-likelihood columns for follow-up review.
- Supported with caveat for design evidence:
  [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  and
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  can run bounded-GPCM role-based design / forecast scenarios when the
  requested design preserves the simulation specification’s slope
  structure. They are design-level sensitivity summaries, not
  operational scoring or arbitrary-facet planning claims.
- Supported with caveat for screening evidence:
  [`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md)
  and
  [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md)
  can run bounded-GPCM role-based repeated simulation/refit studies.
  They report slope-aware Type I proxy, sensitivity proxy, DIF
  target-flag, and bias-screening readouts, not calibrated inferential
  tests or operational screening gates.
- Supported with caveat for DFF/DIF evidence:
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  `analyze_dff_moderation()`, `analyze_dif_moderation()`,
  [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
  [`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md),
  [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
  and
  [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md)
  carry `gpcm_boundary` and should be read as slope-aware
  screening/reporting support rather than standalone fairness,
  invariance, or subgroup-decision evidence.
- Not supported in this release: full FACETS-style score-side contract
  review or score-side equivalence, posterior predictive computation,
  and `MCMC`. Package-native scorefile export includes fitted expected
  scores, residuals, slope fields, observed-category probabilities,
  native structural delta-method expected-score uncertainty, and
  selectable score-side delta-method SEs when the required MML
  diagnostics are available. `ScoreSideLogitSE` stays on the logit-side
  component scale, while `ScoreSideSE` is on the expected-score scale
  (`ScoreSlope * Var * eta_se`); the route remains caveated because
  those fields are not FACETS-equivalent score-side standard errors or
  operational score-scale decisions. APA/QC/export bundles and linking
  review are also available only as caveated GPCM reporting /
  exploratory review surfaces with explicit boundary output.

The unsupported helpers depend on FACETS-style score-side or
posterior-predictive assumptions that are validated for the Rasch-family
route but not yet for bounded `GPCM`. Use
[`gpcm_score_side_contract()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_score_side_contract.md)
to inspect the specific score-side estimand, native uncertainty,
score-side delta SE, reduction-test, schema, and FACETS-compatible
uncertainty requirements that separate the current caveated scorefile
route from full FACETS-style score-side review. The 0.2.2 validation
evidence also includes an external probability-kernel comparison: mapped
[`mirt::probtrace()`](https://philchalmers.github.io/mirt/reference/probtrace.html)
and TAM `rprobs` agree with the local bounded-`GPCM` adjacent-category
kernel, while [`eRm::PCM()`](https://rdrr.io/pkg/eRm/man/PCM.html) is
retained only as unit-slope/CML boundary evidence. This strengthens the
package-native score-side contract without treating those packages as
MFRM comparators or making a FACETS-equivalent score-side claim.

The installed bounded-`GPCM` scope notes keep those unsupported areas
explicit:

``` r

file.show(system.file(
  "validation", "gpcm-post-0.2.2-roadmap.md",
  package = "mfrmr"
))
```

For release review, the optional script
`system.file("validation", "recovery-validation.R", package = "mfrmr")`
defines core `RSM` / `PCM` / bounded-`GPCM` recovery cases, an extended
latent-regression case, an extended high-dispersion/sparse-category
bounded-`GPCM` case, structured release-review steps, and
CSV/RDS/Markdown summaries. It is intentionally separate from routine
tests because the useful settings are long-running Monte Carlo checks.
The summary separates recovery metric status from uncertainty status,
generator-condition status, and diagnostic-only fit/separation status,
so unavailable coverage columns, sparse generated categories, or
fit/separation flags do not look like failed parameter recovery by
themselves. Printing the validation object or calling
`summary(validation)` shows the release-level status first.

For direct recovery checks, `plot(evaluate_mfrm_recovery(...), ...)`
shows recovery summaries, row-level errors, truth-estimate scatter, and
replication status. After
[`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md),
use `recovery_review$condition_reporting_notes` before
`recovery_review$condition_review` to confirm the bounded-`GPCM`
slope-regime generator condition and generated score-category support,
then `recovery_review$diagnostic_reporting_notes` before
`recovery_review$diagnostic_review` if the recovery run retained
diagnostic fit/separation operating characteristics, then
`plot(recovery_review, type = "status")` for checklist status counts and
`plot(recovery_review, type = "metrics", metric = "rmse")` for the
parameter-group metric review. The recommended reading order is:
`summary(recovery_review)`, then condition notes/review, then diagnostic
notes/review when available, then the status plot, then the metric plot,
and only then the row-level recovery table for the parameter groups that
need follow-up. `summary(recovery_review)$reading_order` records this
order directly; the `draw = FALSE` plot data also include
`reading_order` and `guidance` fields for plotting handoff.

A compact bounded-`GPCM` recovery smoke check looks like this. The one
replication setting is for checking the workflow and reading the handoff
tables; increase `reps` before using the result as release evidence.

``` r

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

gpcm_rec <- evaluate_mfrm_recovery(
  sim_spec = gpcm_spec,
  reps = 1,
  fit_method = "MML",
  quad_points = 5,
  maxit = 12,
  include_person = FALSE,
  include_diagnostics = TRUE,
  diagnostic_fit_df_method = "both",
  seed = 456
)

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
gpcm_review$condition_review[, c(
  "Model", "GPCMSlopeRegime", "StressLevel", "ScoreSupportStatus"
)]
gpcm_review$diagnostic_reporting_notes[, c(
  "Facet", "ReportingAttention", "DiagnosticFinding"
)]
gpcm_review$diagnostic_review[, c(
  "Facet", "MeanSeparation", "MeanReliability", "ValidationUse"
)]
summary(gpcm_review)$reading_order
plot(gpcm_review, type = "status")
plot(gpcm_review, type = "metrics", metric = "rmse")
```

For model-scope planning, call `mfrmr_model_family_scope()` before
treating a requested model as part of the GPCM track. The helper
separates the current ordered-response scope from complete unrestricted
GPCM, GRM/NRM/sequential polytomous IRT models, hierarchical or
latent-class rater models, rater bundle models, unfolding models such as
HCM/GGUM, Rasch design-matrix extensions such as MRCMLM/LLTM/LPCM, and
mixture Rasch models. These are not all GPCM subfeatures; each needs its
own likelihood, identification, reporting, and validation contract
before it can be advertised.

For estimator and backend planning, call `mfrmr_estimation_scope()`.
This keeps `JMLE`/`MMLE`, `CMLE` for Rasch-family `RSM`/`PCM`, pairwise
or composite likelihood, WLE/MAP/EAP scoring refinements, free normal
population SD for ordinary MML, optional `Stan` / `cmdstanr` Bayesian
heavy-backend work, nonparametric latent-distribution estimation,
empirical nonparametric response-function diagnostics, and mixture Rasch
estimation in separate lanes. In particular, Stan belongs to the future
backend scope: it can support Bayesian sensitivity, hierarchical rater
extensions, posterior uncertainty, and posterior-predictive checks, but
it is not current support and should not be treated as a drop-in
replacement for the package-native maximum-likelihood routes until its
data contract, priors, identification, diagnostics, and validation
comparisons are specified.

The free normal population-SD row is now an opt-in metric-calibration
route for additive `RSM`/`PCM` and bounded-`GPCM` MML under EM. It is
separate from configurable EAP/reference priors: the former estimates
the MML fitting scale itself, whereas the latter changes scoring-stage
posterior summaries under a fixed calibration. The current fixed-SD
default is preserved; latent-regression, model-estimated
facet-interaction, and direct/hybrid free-SD paths still need separate
estimator contracts.

Two adjacent scoring/uncertainty extensions are intentionally separated
in that table. A configurable EAP/reference prior is attractive for
sensitivity analysis, sparse-person scoring, and policy-relevant
reference populations, but it can make EAP scores, posterior SDs,
intervals, and plausible-value draws prior-sensitive. The first
implemented step is `analyze_eap_power_sensitivity()`, which
power-scales the existing quadrature-grid prior and likelihood under a
fixed calibration and reports EAP deltas from the unscaled reference. A
broader arbitrary-prior API should remain a design candidate, not a
silent change to `fit_mfrm(method = "MML")`. Likewise, MML structural
SEs, MML person posterior SDs, and JML observation-information SEs
should not be collapsed into one unlabeled SE claim. A future
uncertainty contract should name the estimand, conditioning basis,
whether calibration uncertainty is included, and the appropriate
reporting use.

Read the validation outputs in this order:

- `topline_release_decision`: the release-level recovery conclusion. Its
  `ReleaseRecoveryStatus` uses core validation cases as the release
  basis and reports extended sensitivity cases separately via
  `ExtendedSensitivityStatus`. Recovery metrics, convergence, and Monte
  Carlo precision remain the primary evidence for the release status.
- `release_decision_table`: the same decision by validation case, with a
  short interpretation and any uncertainty limitation.
- `condition_reporting_notes`: reporter-facing generator-condition
  caveats, such as high-dispersion slope stress or sparse generated
  score support.
- `condition_summary`: the generator-condition table that separates
  bounded-`GPCM` slope-regime stress from generated score-category
  support.
- `diagnostic_reporting_notes`: reporter-facing fit/separation caveats,
  such as zero separation/reliability or df-sensitive ZSTD flags, kept
  out of the release gate.
- `domain_decision_table`: the diagnostic split among recovery metrics,
  uncertainty, Monte Carlo precision, score support, and the broader
  overall status.

For appendix handoff, pass the validation summary to
`build_summary_table_bundle(summary(validation))`. The bundle includes
the top-line decision, case decisions, case summary, condition summary,
and domain decision tables, plus condition reporting notes, diagnostic
reporting notes, and raw diagnostic summaries under recovery-validation
appendix roles.

A local smoke-read of the packaged validation protocol is:

``` r

source(system.file("validation", "recovery-validation.R", package = "mfrmr"))

validation <- mfrmr_run_recovery_validation(
  case_ids = c("gpcm_slope_profile", "gpcm_high_dispersion_sparse"),
  quick = TRUE,
  seed = 20260525,
  verbose = FALSE
)

s_validation <- summary(validation)
s_validation$reading_order
s_validation$topline_release_decision
s_validation$condition_reporting_notes[, c(
  "CaseID", "ConditionArea", "ReportingAttention", "ConditionFinding"
)]
s_validation$condition_summary[, c(
  "CaseID", "GPCMSlopeRegime", "ScoreSupportStatus"
)]
s_validation$diagnostic_reporting_notes[, c(
  "CaseID", "Facet", "ReportingAttention", "DiagnosticFinding"
)]
s_validation$diagnostic_oc_summary[, c(
  "CaseID", "Facet", "MeanSeparation", "MeanReliability",
  "DiagnosticAvailability", "ValidationUse"
)]

validation_bundle <- build_summary_table_bundle(s_validation)
validation_bundle$tables$reading_order
validation_bundle$tables$condition_reporting_notes
validation_bundle$tables$diagnostic_reporting_notes
validation_bundle$tables$domain_decision_table

validation_out_dir <- tempfile("mfrmr-validation-appendix-")
validation_appendix <- export_summary_appendix(
  list(validation = s_validation),
  output_dir = validation_out_dir,
  prefix = "mfrmr_validation_appendix",
  preset = "recommended",
  include_html = FALSE,
  overwrite = TRUE
)
validation_appendix$selection_catalog

# The same validation summary can be supplied to
# export_mfrm_bundle(..., summary_tables = list(validation = s_validation))
# when you want release-review tables co-located with a fit-based bundle.
```

In particular, do not treat `OverallStatus = "review"` as a
release-level recovery failure by itself. In the validation bundle,
`UncertaintyStatus = "review"` can mean that SE/coverage evidence is
intentionally reported as a separate limitation while recovery metrics
remain acceptable.

For a source-grounded release review plan, read the packaged evidence
map and its structured checklist. The 0.2.2 files cover the current
public workflow, reader-first reporting/export refinements,
observed-score generalizability sensitivity, bounded-`GPCM` scope
control, DIF/DFF reporting boundaries, and release-engineering gates;
the external common-data recovery summary remains the 0.2.0 artifact
until that separate workflow is refreshed.

``` r

file.show(system.file(
  "validation", "release-evidence-map-0.2.2.md",
  package = "mfrmr"
))

read.csv(system.file(
  "validation", "release-evidence-checklist-0.2.2.csv",
  package = "mfrmr"
))

file.show(system.file(
  "validation", "external-parameter-recovery-simulation-0.2.0.md",
  package = "mfrmr"
))
```

It links the release checks to the ordered-response model literature,
FACETS/Winsteps fit conventions, ADEMP-style simulation-study reporting,
and the package’s current implementation boundaries. The checklist
classifies each item as required release evidence, caveat-managed
evidence, or future-scope evidence.

The external parameter-recovery summary records a separate common-data
simulation workflow. It supports the distinction between recovery
checks, cross-engine agreement, and design endorsement: sparse stress
designs can converge and agree across engines while still showing
recovery, coverage, precision, or role-bias risk. The large generated
datasets and engine outputs are not bundled with the package; the
validation bundle includes a sourceable review helper for re-reading a
local `Parameter_Recovery_Simulation` output directory, checking
expected CSV schemas, and recording file fingerprints when that external
workflow is refreshed.

## Equal weighting and when to prefer the Rasch-family route

`mfrmr` treats `RSM` / `PCM` as the package’s equal-weighting reference
models. In that Rasch-family route, category discrimination is fixed, so
the operational scoring contract does not let the psychometric model
reweight some item-facet combinations more heavily than others.

Bounded `GPCM` serves a different purpose. It allows estimated slopes,
so some observed design cells become more influential than others
through discrimination-based reweighting. This often improves fit, but a
better-fitting `GPCM` does not automatically make it the preferred
operational model.

The package therefore recommends:

- prefer `RSM` / `PCM` when equal contributions of items and raters are
  part of the substantive scoring argument
- use bounded `GPCM` when you explicitly want to inspect or allow
  discrimination-based reweighting and can defend that choice on
  validity grounds
- read `RSM` / `PCM` versus `GPCM` as a model-choice or sensitivity
  question, not as a contest in which fit alone decides the winner

One more distinction matters. The `weight =` argument in
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
is for an observation-weight column. That is different from the
equal-weighting question discussed above. Observation weights adjust how
rating events enter estimation and summaries; they do not turn a
Rasch-family fit into a discrimination-based model.

## Model selection guide and report wording

Use the model argument to match the score interpretation first, then use
fit statistics and diagnostics as checks on that interpretation.

| Choose | When it is the right starting point | Report wording |
|----|----|----|
| `RSM` | The rubric is intended to share the same category thresholds across items, criteria, or other step-facet levels. | “We fit a many-facet rating-scale Rasch model, treating category thresholds as common across the step facet.” |
| `PCM` | Category thresholds may differ by rater, item, criterion, or another declared step facet, but equal contribution of rating events remains part of the scoring argument. | “We fit a many-facet partial-credit Rasch model, allowing step thresholds to vary by the designated step facet.” |
| bounded `GPCM` | You explicitly want a slope-aware sensitivity model and can defend discrimination-based reweighting. | “We fit a bounded generalized partial-credit many-facet model as a slope-aware sensitivity analysis.” |

Do not set `step_facet` for `RSM`: the model has one common threshold
vector. If supplied,
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
warns and records the fitted design as common thresholds in
`summary(fit)$design_spec`.

For FACETS-facing rater work, `model = "PCM", step_facet = "Rater"` is
the clearest package-native example of a partial-credit / `Specific`
rating-scale structure: each rater receives their own category-use
thresholds. Use `step_facet = "Item"` for item-specific partial-credit
scales and `step_facet = "Criterion"` for criterion-specific rubric
thresholds. Design-matrix packages may describe these blocks as
`rater:step`, `item:step`, or `criterion:step`; mfrmr keeps the
user-facing API in `step_facet` terms and records those external
analogues only in `fit$config$design_spec`.

Avoid these shortcuts:

- do not describe the whole package surface as “a Rasch-only MFRM” now
  that bounded `GPCM` is implemented
- do not write that bounded `GPCM` is better for operational scoring
  solely because `AIC`, `BIC`, or log-likelihood improves
- do not use FACETS-style score-side, operational scoring, calibrated
  design-forecasting, or operational linking-synthesis language for
  bounded `GPCM`; use APA/QC/export, design/screening, scorefile, and
  linking helpers only where
  [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
  marks the row as `supported_with_caveat`

In a manuscript, a defensible model-choice sentence is:

> We treated `RSM`/`PCM` as the equal-weighting operational reference
> and used bounded `GPCM` to inspect whether allowing
> discrimination-based reweighting changed the substantive conclusions.

After fitting candidate models, use
[`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md)
to keep the same guidance attached to the actual fit objects:

``` r

review <- build_model_choice_review(RSM = fit_rsm, GPCM = fit_gpcm)
summary(review)

# Add the detailed reweighting review when an RSM/PCM reference and bounded
# GPCM sensitivity fit were estimated on the same response data.
review <- build_model_choice_review(RSM = fit_rsm, GPCM = fit_gpcm,
                                    run_weighting_review = TRUE)
```

## Documentation map

The README is only the shortest map. The package now has guide-style
help pages for the main workflows.

- Workflow map:
  [`help("mfrmr_workflow_methods", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md)
- Visual diagnostics map:
  [`help("mfrmr_visual_diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
- Reports and tables map:
  [`help("mfrmr_reports_and_tables", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md)
- Output helper guide:
  [`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)
- Beginner first-analysis route: `mfrmr_output_guide("beginner")`
- Psychometric minimum report checklist:
  `mfrmr_minimum_report_checklist()`
- Reviewer-facing reporting route: `mfrmr_output_guide("psychometric")`
- Reporting and APA map:
  [`help("mfrmr_reporting_and_apa", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)
- FACETS terminology crosswalk: `facets_term_crosswalk()`
- Linking and DFF map:
  [`help("mfrmr_linking_and_dff", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)
- Compatibility layer map:
  [`help("mfrmr_compatibility_layer", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
- Bounded `GPCM` scope:
  [`help("gpcm_capability_matrix", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)

Companion vignettes:

- [`vignette("mfrmr-workflow", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-workflow.md)
- [`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md)
- [`vignette("mfrmr-reporting-and-apa", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-reporting-and-apa.md)
- [`vignette("mfrmr-linking-and-dff", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.md)
- [`vignette("mfrmr-mml-and-marginal-fit", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-mml-and-marginal-fit.md)
- [`vignette("mfrmr-gpcm-scope", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.md)
- [`vignette("mfrmr-facets-migration", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-facets-migration.md)

A two-page landscape cheatsheet of the public API ships at
`system.file("cheatsheet", "mfrmr-cheatsheet.pdf", package = "mfrmr")`
(pre-rendered) and
`system.file("cheatsheet", "mfrmr-cheatsheet.Rmd", package = "mfrmr")`
(source). Open the PDF directly for a quick printable reference, or knit
the `.Rmd` with
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
when you want a customised version.

## Installation

``` r

# GitHub
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("Ryuya-dot-com/mfrmr", build_vignettes = TRUE)

# CRAN (when available)
# install.packages("mfrmr")
```

If you install from GitHub without `build_vignettes = TRUE`, use the
guide-style help pages included in the package, for example:

- [`help("mfrmr_workflow_methods", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md)
- [`help("mfrmr_reporting_and_apa", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)
- [`help("mfrmr_linking_and_dff", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

Installed vignettes:

``` r

browseVignettes("mfrmr")
```

## Core workflow

    fit_mfrm() --> diagnose_mfrm() --> reporting / advanced analysis
                        |
                        +--> analyze_residual_pca()
                       +--> estimate_bias()
                        +--> interaction_effect_table()
                        +--> analyze_dff()
                        +--> compare_mfrm()
                        +--> run_qc_pipeline()
                        +--> anchor_to_baseline() / detect_anchor_drift()

1.  Fit model:
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
2.  Diagnostics:
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
3.  Optional residual-structure screen:
    [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md)
4.  Optional interaction bias:
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
5.  Optional model-estimated facet interactions:
    [`interaction_effect_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interaction_effect_table.md)
6.  Differential-functioning analysis:
    [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
    `analyze_dff_moderation()`, `analyze_dif_mh()`,
    [`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md)
7.  Model comparison:
    [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
8.  Reporting:
    [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
    [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
    [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
9.  Quality control:
    [`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md)
10. Anchoring & linking:
    [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md),
    [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
    [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
11. FACETS output-contract review when needed:
    [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md);
    this checks package output contracts, not external FACETS numerical
    equivalence
12. Reproducible inspection:
    [`summary()`](https://rdrr.io/r/base/summary.html) and
    `plot(..., draw = FALSE)`

Dimensionality wording is deliberately conservative. Residual PCA and
Q3-style local-dependence screens are exploratory follow-up evidence,
not standalone proofs that unidimensionality has been established and
not implementations of DIMTEST/UNIDIM. For MFRM manuscripts, combine
global residual fit, element fit, residual PCA, and local-dependence
checks, and use limited wording such as “evidence consistent with
essential unidimensionality under the specified facet structure.”

## Choose a route

Use the route that matches the question you are trying to answer.

| Question | Recommended route |
|----|----|
| Can I fit the model and get a first-pass diagnosis quickly? | [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md) -\> [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md) -\> [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md) |
| Which reporting elements are draft-complete, and with what caveats? | [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md) -\> [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md) -\> [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md) |
| Which tables and prose should I adapt into a manuscript draft? | [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md) -\> [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md) -\> [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md) |
| Is the design connected well enough for a common scale? | [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md) -\> `plot(..., type = "design_matrix")` |
| Do I need to place a new administration onto a baseline scale? | [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md) -\> [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md) |
| Are common elements stable across separately fitted forms or waves? | fit each wave -\> [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md) -\> [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md) |
| Are some facet levels functioning differently across groups? | [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md) -\> [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md) -\> [`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md); for one-response-per-person-item observed screens outside the fitted-MFRM route use `analyze_dif_mh()` -\> [`summary()`](https://rdrr.io/r/base/summary.html) |
| Do I need old fixed-width or wrapper-style outputs? | [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md) or [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md) only at the compatibility boundary |

## Additional routes

After the canonical `MML + both` route above, these are the next
shortest specialized routes.

Shared setup used by the snippets below:

``` r

library(mfrmr)
toy <- load_mfrmr_data("example_core")
```

### 1. Quick first pass

``` r

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", model = "RSM", quad_points = 7)
diag <- diagnose_mfrm(fit, diagnostic_mode = "both", residual_pca = "none")
summary(diag)
plot_qc_dashboard(fit, diagnostics = diag, preset = "publication")
```

### 1b. Preferred MML + marginal-fit route

``` r

fit_final <- fit_mfrm(
  toy,
  "Person",
  c("Rater", "Criterion"),
  "Score",
  method = "MML",
  model = "RSM",
  quad_points = 15
)

diag_final <- diagnose_mfrm(
  fit_final,
  diagnostic_mode = "both",
  residual_pca = "none"
)

summary(fit_final)
summary(diag_final)
```

For `RSM` / `PCM`, this is the recommended final-analysis route when you
want legacy continuity plus the newer strict marginal screening path.

### 2. Design and linking check

``` r

diag <- diagnose_mfrm(fit, residual_pca = "none")
sc <- subset_connectivity_report(fit, diagnostics = diag)
summary(sc)
plot(sc, type = "design_matrix", preset = "publication")
plot_wright_unified(fit, preset = "publication", show_thresholds = TRUE)
```

### 3. Manuscript and reporting check

``` r

# Use this fit-independent checklist before treating software output as a
# complete manuscript/reporting plan.
mfrmr_minimum_report_checklist()[, c("Section", "ReportItem", "Required")]

# Add `bias_results = ...` if you want the bias/reporting layer included.
chk <- reporting_checklist(fit, diagnostics = diag)
apa <- build_apa_outputs(fit, diag)

chk$checklist[, c("Section", "Item", "DraftReady", "NextAction")]
cat(apa$report_text)
```

### 4. Hierarchical structure and sample-adequacy review

Use this when rater counts are small, raters may be nested in schools or
regions, or a reviewer asks for ICC / design-effect evidence that the
additive fixed-effects many-facet model cannot partition out on its own.

``` r

review <- facet_small_sample_review(fit)
review$facet_summary         # worst level per facet + SampleCategory
summary(review)              # counts of sparse / marginal / standard / strong

nest <- detect_facet_nesting(toy, c("Rater", "Criterion"))
plot(nest)                   # nesting index heatmap

# Combined bundle (ICC uses lme4, connectivity uses igraph, both Suggests):
h <- analyze_hierarchical_structure(toy, c("Rater", "Criterion"), score = "Score",
                                    person = "Person")
summary(h)
```

`reporting_checklist(fit, hierarchical_structure = h)` then marks the
“Hierarchical structure review” item ready.

### 5. Empirical-Bayes shrinkage for small-N facets

When a facet has 3-10 levels, the fixed-effects many-facet model retains
wide per-level SEs. Empirical-Bayes partial pooling (Efron & Morris,
1973) dominates the MLE under squared-error loss whenever `K >= 3`.

``` r

# Integrated path: shrinkage applied as part of the fit.
fit_eb <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                   method = "MML", quad_points = 15,
                   facet_shrinkage = "empirical_bayes")
shrinkage_report(fit_eb)
plot(fit_eb, type = "shrinkage", show_ci = TRUE)

# Post-hoc path: apply to an existing fit.
fit_post <- apply_empirical_bayes_shrinkage(fit)
head(fit_post$facets$others[, c("Facet", "Level", "Estimate",
                                 "ShrunkEstimate", "ShrinkageFactor")])
```

### 6. Missing-code pre-processing

`fit_mfrm(..., missing_codes = TRUE)` converts the default FACETS / SPSS
/ SAS sentinels (`"99"`, `"999"`, `"-1"`, `"N"`, `"NA"`, `"n/a"`, `"."`,
`""`) to `NA` on the `person`, `facets`, and `score` columns before
estimation. Replacement counts are kept in `fit$prep$missing_recoding`
and surfaced by `build_mfrm_manifest()$missing_recoding`. The default
(`missing_codes = NULL`) is strictly backward-compatible.

``` r

fit <- fit_mfrm(
  dirty_data, "Person", c("Rater", "Criterion"), "Score",
  missing_codes = TRUE           # or supply a custom character vector
)
fit$prep$missing_recoding
```

A standalone
[`recode_missing_codes()`](https://ryuya-dot-com.github.io/mfrmr/reference/recode_missing_codes.md)
helper is exported for users who prefer to recode before calling
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## Estimation choices

The package treats `MML` and `JML` differently on purpose.

- `MML` is the default and the preferred route for final estimation.
- In ordinary `MML` fits (`population_formula = NULL`), the latent prior
  is fixed to normal scale by default (`population_prior_sd = 1`).
- Set `estimate_population_sd = TRUE` to estimate the additive
  `RSM`/`PCM` or bounded-`GPCM` MML latent population SD under the EM
  engine. This is not yet available for latent-regression MML or
  model-estimated facet interactions. `summary(fit)` and
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  report the SD mode; free-SD runs add the estimated SD, profile SE/CI,
  and profile-uncertainty caveat to the APA draft prose/table notes.
- `JML` is supported as a fast exploratory route.
- Downstream precision summaries distinguish `model_based`, `hybrid`,
  and `exploratory` tiers.
- Use
  [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
  when you need to decide how strongly to phrase SE, CI, or reliability
  claims.

Typical pattern:

``` r

toy <- load_mfrmr_data("example_core")

fit_final <- fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", model = "RSM", quad_points = 15
)

diag_final <- diagnose_mfrm(
  fit_final,
  diagnostic_mode = "both",
  residual_pca = "none"
)

precision_review_report(fit_final, diagnostics = diag_final)
```

Metric-scale check:

``` r

fit_free_sd <- fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", model = "RSM", quad_points = 15,
  estimate_population_sd = TRUE
)

summary(fit_free_sd)$population_overview[
  , c("PopulationSDMode", "EstimatedPopulationSD", "PopulationSDSEStatus")
]

compare_mfrm(fit_final, fit_free_sd,
             labels = c("fixed_SD", "free_SD"))$table[
  , c("Label", "npar", "AIC", "PopulationSDMode", "EstimatedPopulationSD")
]
```

### Fit and separation reporting boundary

Fit and separation are useful, but they should not be treated as
automatic validation success criteria.
[`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md)
keeps mean-square fit (`Infit`, `Outfit`) as the primary size diagnostic
and uses `fit_df_method = "both"` plus
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)
when ZSTD differences need to be read as FACETS-style df or
standardization differences. Mean-square bands are sourced to Wright and
Linacre (1994) and Linacre (2002), while separation, reliability, and
strata follow the Wright and Masters G/R/H convention.

[`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
now returns `fit_separation_basis`, a compact source-grounding table
that separates:

- fit MnSq diagnostics;
- ZSTD standardization and df-convention review;
- Rasch/FACETS-style separation, reliability, and strata;
- package QC thresholds used by
  [`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md)
  and design simulations.

Use that table as a reporting and validation boundary: fit and
separation summaries can support diagnostic interpretation and
external-output review, but they do not replace recovery checks,
convergence review, design checks, or substantive validity evidence. For
appendix handoff, pass the precision review directly to
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
or
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md);
the `fit_separation_basis` table stays in the precision-review role
instead of being folded into a top-line validation decision. The same
appendix route now accepts
[`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md)
and
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)
outputs, so df/ZSTD sensitivity and optional external FACETS matching
can be exported beside, but not collapsed into, MnSq fit status.
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
also surfaces this as a Global Fit item before users move into draft
text.

The same boundary is used in recovery validation. When
`include_diagnostics = TRUE`,
[`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md),
[`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md),
and the release validation protocol retain fit/separation operating
characteristics for diagnostic context, while the assessment and
top-line release decisions remain based on recovery metrics,
convergence, uncertainty, and Monte Carlo precision. `DiagnosticStatus`
is an availability/status-routing field, not a judgement that fit or
separation values are adequate. Read `diagnostic_reporting_notes` before
the raw `diagnostic_review` or `diagnostic_oc_summary` when deciding how
strongly to phrase fit, separation, or reliability caveats in reports.
For diagnostic-screening simulations,
[`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md)
can also retain the
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
`report_index` surface with `include_report = TRUE`. The resulting
`report_signal_summary` shows how often the report layer was available
and how many fit, precision, or misfit review signals were routed to
`review`, but it remains an operating-characteristic summary, not a
validation pass/fail gate. Use
`plot(diag_eval, type = "overview", draw = FALSE)` or
`plot_data(diag_eval, type = "overview", component = "plot_long")` to
collect legacy ZSTD, strict marginal, strict pairwise, strict combined,
and optional report-review rates in one long-form visualization table.
`type = "report"` focuses on report readiness/review signals,
`type = "contrast"` shows misspecification-minus-well-specified deltas,
and `type = "runtime"` summarizes elapsed-time operating
characteristics. The same draw-free plot object also retains `overview`,
`reading_order`, `next_actions`, `reporting_notes`, and
`figure_recipes`, so custom ggplot2, plotly, Quarto, or Shiny displays
can carry the interpretation boundaries and caption/display guidance
beside the plotted values. For common plot-data shapes, `as_ggplot()`
provides a direct optional `ggplot2` route:

``` r

as_ggplot(plot(fit, type = "wright", draw = FALSE))
as_ggplot(plot(fit, type = "pathway", draw = FALSE))
as_ggplot(plot(fit, type = "fit_pathway", fit_stat = "Outfit", draw = FALSE))
as_ggplot(plot(fit, type = "ccc", draw = FALSE), slope_aes = "linewidth")
as_ggplot(plot_dif_summary(dff_refit, draw = FALSE))
as_ggplot(plot_dif_heatmap(dff_refit, metric = "contrast", draw = FALSE))
```

The package still keeps base R as the default renderer; use
`as_ggplot()` when the figure needs journal-specific themes, scales,
facets, or downstream composition in Quarto. The Wright-map converter
carries over the person distribution and facet/step rails; the pathway
converter carries over dominant-category strips, thresholds, endpoint
labels, and available fit annotations; the fit-pathway converter keeps
the selected Infit/Outfit axis separate from the vertical measure/logit
axis. The CCC converter keeps category curves editable and can map a
`GPCM` slope/discrimination column to line width, alpha, or colour; for
RSM/PCM payloads this remains a constant-slope display. For appendix
handoff, `summary(diag_eval)`, `build_summary_table_bundle(diag_eval)`,
and `export_summary_appendix(diag_eval, preset = "recommended")` return
the same scenario, performance, report-signal, contrast, and draw-free
plot-data surfaces as tables, keeping simulation screening signals
separate from validation pass/fail decisions. Start with
`summary(diag_eval)$reading_order`, then read
`summary(diag_eval)$next_actions` and
`summary(diag_eval)$reporting_notes` before using the raw scenario or
plot-data tables in a manuscript or reviewer appendix. Use
`mfrmr_output_guide("simulation")` when deciding whether the next step
is one reusable DGM, one generated dataset, recovery assessment,
design-grid evaluation, one-scenario forecasting, diagnostic/DIF/bias
screening, appendix export, or network/peer-review design review.

For bounded-`GPCM` recovery runs, read `condition_reporting_notes`
before `condition_review` or `condition_summary`. Those notes separate
declared generator stress, such as high-dispersion slopes or sparse
generated score support, from parameter-recovery performance.

## Mathematical note for expert users

Full marginal-likelihood and strict-marginal derivations, along with the
literature positioning (Bock & Aitkin, 1981; Linacre, 1989; Eckes, 2005;
Orlando & Thissen, 2000; Haberman & Sinharay, 2013; Sinharay & Monroe,
2025), are collected in the dedicated vignette:

``` r

vignette("mfrmr-mml-and-marginal-fit", package = "mfrmr")
```

## Documentation datasets

- `load_mfrmr_data("example_core")`: compact, approximately
  unidimensional example for fitting, diagnostics, plots, and reports.
  It is package-generated and not paper-derived.
- `load_mfrmr_data("example_bias")`: compact package-generated example
  with known `Group x Criterion` differential-functioning and
  `Rater x Criterion` interaction signals for bias-focused help pages.
- `load_mfrmr_data("study1")` / `load_mfrmr_data("study2")`: larger
  Eckes/Jin-inspired synthetic studies for more realistic end-to-end
  analyses.
- Direct dataset access also works with
  `data("mfrmr_example_core", package = "mfrmr")` and
  `data("mfrmr_example_bias", package = "mfrmr")`.

Source boundary:

- The `example_*` fixtures are not based on a published empirical
  dataset; they are small package-authored smoke-test datasets.
- The `study*` datasets are synthetic. Eckes and Jin (2021) informs the
  design dimensions and rating-scale context, but the package does not
  redistribute TestDaF operational response rows, reproduce their
  Bayesian FM-SC estimates, or claim that the generated scores are
  empirical TestDaF data.
- The model and reporting conventions elsewhere in the package are
  grounded in the cited Rasch/MFRM literature, but every generated
  result should still be read as an `mfrmr` estimate or summary over the
  supplied data.

## Basic workflow

``` r

library(mfrmr)

data("mfrmr_example_core", package = "mfrmr")
df <- mfrmr_example_core

# Fit
fit <- fit_mfrm(
  data = df,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM",
  quad_points = 7
)
summary(fit)

# Fast diagnostics first
diag <- diagnose_mfrm(fit, residual_pca = "none")
summary(diag)

# APA outputs
apa <- build_apa_outputs(fit, diag)
cat(apa$report_text)

# QC pipeline reuses the same diagnostics object
qc <- run_qc_pipeline(fit, diagnostics = diag)
summary(qc)
```

## Main objects you will reuse

Most package workflows reuse a small set of objects rather than
recomputing everything from scratch. The canonical list is kept up to
date in `summary(fit)` under “Next actions”; the items below are a short
orientation pointer.

- `fit`: the fitted model object returned by
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
- `diag`: diagnostic summaries returned by
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
- `chk`: reporting and manuscript-draft checks returned by
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
- `apa`: structured APA/report draft outputs returned by
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
- `sc`: connectivity and linking summaries returned by
  [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
- `bias` / `dff`: interaction screening and differential-functioning
  results returned by
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  and
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)

Typical reuse pattern:

``` r

toy <- load_mfrmr_data("example_core")

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", model = "RSM", quad_points = 7)
diag <- diagnose_mfrm(fit, residual_pca = "none")
chk <- reporting_checklist(fit, diagnostics = diag)
apa <- build_apa_outputs(fit, diag)
sc <- subset_connectivity_report(fit, diagnostics = diag)
```

## Reporting and APA route

If your endpoint is a manuscript or technical report, use the
package-native reporting contract rather than composing text by hand.

``` r

diag <- diagnose_mfrm(fit, residual_pca = "none")

# Add `bias_results = ...` to either helper when bias screening should
# appear in the checklist or draft text.
chk <- reporting_checklist(fit, diagnostics = diag)
chk$checklist[, c("Section", "Item", "DraftReady", "Priority", "NextAction")]

apa <- build_apa_outputs(
  fit,
  diag,
  context = list(
    assessment = "Writing assessment",
    setting = "Local scoring study",
    scale_desc = "0-4 rubric scale",
    rater_facet = "Rater"
  )
)

cat(apa$report_text)
apa$section_map[, c("SectionId", "Available", "Heading")]

tbl_fit <- apa_table(fit, which = "summary")
tbl_reliability <- apa_table(fit, which = "reliability", diagnostics = diag)
```

For a question-based map of the reporting API, see
[`help("mfrmr_reporting_and_apa", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md).

## Visualization recipes

A task-oriented index of the plotting surface lives at
[`help("mfrmr_visual_diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
and worked publication examples are collected in
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).
The common starter patterns are:

``` r

plot(fit, type = "wright", preset = "publication", show_ci = TRUE)
plot(fit, type = "pathway", preset = "publication")
plot(fit, type = "fit_pathway", fit_stat = "Infit", preset = "publication")
plot(fit, type = "ccc", preset = "publication")
plot_qc_dashboard(fit, diagnostics = diag, preset = "publication")
```

For interval-aware figures and tables, start with:

``` r

mfrmr_interval_guide("visual")[, c("Route", "PrimaryHelper", "Basis")]
plot_fair_average(fit, show_ci = TRUE, ci_level = 0.95)
plot_bias_interaction(bias, plot = "ranked", show_ci = TRUE, ci_level = 0.95)
plot_rater_severity_profile(fit, ci_level = 0.95)
plot_apa_figure_one(fit, ci_level = 0.95, draw = FALSE)
fm <- fit_measures_table(fit, ci_level = 0.95)
plot(fm, type = "measure_ci")
```

The interval guide separates Wald, delta-method, profile-like, and
plotting overlay routes so 95% CI displays are read as precision or
screening evidence, not as automatic fit, fairness, or validity
decisions.

A second-wave teaching / drift / agreement layer ships for follow-up
inspection; it is not a default reporting figure set:

``` r

plot_guttman_scalogram(fit, diagnostics = diag)       # teaching ordering view
plot_residual_qq(fit, diagnostics = diag)             # residual tail follow-up
plot_rater_agreement_heatmap(fit, diagnostics = diag) # compact pairwise agreement
plot_rater_trajectory(list(T1 = fit_a, T2 = fit_b))   # requires anchor-linked waves
```

## Linking, anchors, and DFF route

Use this route when your design spans forms, waves, or subgroup
comparisons.

``` r

data("mfrmr_example_bias", package = "mfrmr")
df_bias <- mfrmr_example_bias
fit_bias <- fit_mfrm(df_bias, "Person", c("Rater", "Criterion"), "Score",
                     method = "MML", model = "RSM", quad_points = 7)
diag_bias <- diagnose_mfrm(fit_bias, residual_pca = "none")

# Connectivity and design coverage
sc <- subset_connectivity_report(fit_bias, diagnostics = diag_bias)
summary(sc)
plot(sc, type = "design_matrix", preset = "publication")

# Anchor export from a baseline fit
anchors <- make_anchor_table(fit_bias, facets = "Criterion")
head(anchors)

# Anchor/linking contract for handoff boundaries
anchor_contract <- anchor_linking_contract(fit_bias, diagnostics = diag_bias)
anchor_contract$contract[, c("Surface", "Status", "Boundary")]

# Differential facet functioning
dff <- analyze_dff(
  fit_bias,
  diag_bias,
  facet = "Criterion",
  group = "Group",
  data = df_bias,
  method = "residual"
)
dff$summary
plot_dif_heatmap(dff)
plot_dif_summary(dff)
```

For linking-specific guidance, see
[`help("mfrmr_linking_and_dff", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md).
`anchor_linking_contract()` is the compact handoff check: it documents
that
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md)
produces R-native `Facet` / `Level` / `Anchor` rows for later
`fit_mfrm(anchors = ...)` calls, not a complete FACETS `Anchorfile=`
specification file.

For FACETS-facing migration, use the term crosswalk before feature or
visual coverage. This keeps FACETS words such as `Measure`, `S.E.`,
`ZSTD`, `Rating Scale=`, `Graphfile`, and `Anchorfile=` separate from
equivalence claims:

``` r

facets_term_crosswalk()[, c("FACETSTerm", "mfrmrRoute", "Relationship")]
```

For FACETS-facing visual migration, then use the visual contract:

``` r

facets_visual_contract()[, c(
  "FACETSVisualSurface",
  "Status",
  "FirstMfrmrRoute",
  "EditableDataRoute",
  "ClaimBoundary"
)]
```

This maps FACETS Table 6/8 displays, Graphs-menu curves, DIF/bias Excel
plots, Graphfile output, and R/Web plot menus to `mfrmr` plot,
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
and `as_ggplot()` routes. It is a review-purpose migration guide, not a
claim that `mfrmr` reproduces FACETS graph-window behavior, Excel
workbook plots, clickable Webpage output, or line-printer artwork.

## DFF / DIF analysis

The primary many-facet route is
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
/
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md):
it uses the fitted
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
model and supports `RSM`, `PCM`, and bounded `GPCM` according to the
capability matrix. Bounded `GPCM` results remain slope-aware
screening/reporting evidence with `gpcm_boundary` caveats.
`analyze_dif_mh()` is different: it is a model-independent
observed-score Mantel-Haenszel screen and does not use an MFRM, `RSM`,
`PCM`, or `GPCM` likelihood. `analyze_dif_classical()` remains as a
compatibility wrapper.

``` r

data("mfrmr_example_bias", package = "mfrmr")
df_bias <- mfrmr_example_bias
fit_bias <- fit_mfrm(df_bias, "Person", c("Rater", "Criterion"), "Score",
                     method = "MML", model = "RSM", quad_points = 7)
diag_bias <- diagnose_mfrm(fit_bias, residual_pca = "none")

dff <- analyze_dff(fit_bias, diag_bias, facet = "Criterion",
                   group = "Group", data = df_bias, method = "residual")
dff$dif_table
dff$summary

# `group` is categorical. For 3+ groups, use all pairwise comparisons
# or set `focal = ...`; do not pass a raw continuous covariate.
age_map <- setNames(seq_along(unique(df_bias$Person)), unique(df_bias$Person))
df_bias$AgeLike <- age_map[df_bias$Person]
mod_cont <- analyze_dff_moderation(fit_bias, facet = "Criterion",
                                   covariate = "AgeLike", data = df_bias)
mod_cont$moderation_table

# Mantel-Haenszel DIF is a separate observed-score screen, not a
# fitted-MFRM RSM/PCM/GPCM route. It expects one response per person x
# item/facet level; aggregate or redesign rater-mediated repeated rows before
# using it. See
# inst/references/mh-dif-r-package-alignment.md for the current
# alignment boundary against difR, lordif, and mirt help-page surfaces.
# inst/validation/mh-dif-package-comparison-0.2.2.R provides the optional
# difR::difMH() numerical comparison harness.
# inst/validation/mh-dif-simulation-0.2.2.R provides the optional seeded
# simulation review for direction, false positives, matching, sparse cells,
# dichotomization, and wrapper behavior.
classic_df <- subset(df_bias, Rater == unique(df_bias$Rater)[1])
classic_df$PassLike <- as.integer(classic_df$Score >= max(classic_df$Score))
mh <- analyze_dif_mh(classic_df, person = "Person", item = "Criterion",
                     score = "PassLike", group = "Group")
mh$mh_table

# Cell-level interaction table
dit <- dif_interaction_table(fit_bias, diag_bias, facet = "Criterion",
                             group = "Group", data = df_bias)

# Visual, narrative, and bias reports
plot_dif_heatmap(dff)
plot_dif_summary(dff)
plot(fit_bias, type = "dif_icc", group = "Group", group_data = df_bias)

# Optional display controls for review meetings or appendices
plot_dif_heatmap(dff, metric = "t", flag_threshold = 2,
                 show_values = FALSE, scale_limit = 3)
plot_dif_summary(dff, ci_level = 0.90,
                 effect_thresholds = c(screen = 0.5))
dr <- dif_report(dff)
cat(dr$narrative)

# APA-style DFF/DIF reporting flow: one source object supplies the paragraph,
# table, note, and caption. The language stays in screening terms unless the
# study supplies stronger substantive and design evidence.
dr_apa <- dif_report(dff, style = "apa")
cat(dr_apa$apa_text)
apa_table(dff)
apa_with_dff <- build_apa_outputs(fit_bias, diag_bias, dif_results = dff)
apa_with_dff$section_map[apa_with_dff$section_map$SectionId ==
                           "results_differential_functioning", ]

# The observed-score MH route has the same reporting adapter but remains
# separate from fitted-MFRM RSM/PCM/GPCM DFF/DIF.
mh_apa <- dif_report(mh, style = "apa")
cat(mh_apa$apa_text)
apa_table(mh)

# Optional release-review validation: verifies the APA adapter across
# two-level, three-level, continuous-covariate, MH, interaction, refit, and
# bounded-GPCM reporting cases.
source(system.file("validation", "dif-apa-reporting-0.2.2.R",
                   package = "mfrmr"))
apa_dif_review <- mfrmr_review_dif_apa_reporting()
apa_dif_review$status

# Refit-based contrasts can support ETS labels only when subgroup linking is adequate
dff_refit <- analyze_dff(fit_bias, diag_bias, facet = "Criterion",
                         group = "Group", data = df_bias, method = "refit")
dff_refit$summary

bias <- estimate_bias(fit_bias, diag_bias, facet_a = "Rater", facet_b = "Criterion")
summary(bias)

# App-style batch bias estimation across all modeled facet pairs
bias_all <- estimate_all_bias(fit_bias, diag_bias)
bias_all$summary
```

Interpretation rules:

- `residual` DFF is a screening route.
- `refit` DFF can support logit-scale contrasts only when subgroup
  linking is adequate.
- Residual-method classifications are screening labels, not ETS A/B/C
  severity categories.
- DIF/DFF visualizations follow the same rule:
  [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md)
  uses ETS A/B/C colors only for rows with
  `ClassificationSystem == "ETS"`, and draw-free payloads expose
  `ETSDisplayEligible` / `ets_display_eligible` so reports can avoid
  relabeling screening plots as ETS classifications.
- `as_ggplot()` can re-render the draw-free DIF/DFF payloads as editable
  `ggplot2` objects; it does not change the underlying classification or
  reporting boundary.
- Use `dif_report(..., style = "apa")` and
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
  for manuscript handoff, and pass `dif_results = ...` to
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  when the differential-functioning paragraph should appear in the main
  APA draft.
- The 0.2.2 validation matrix in
  `inst/validation/dif-dff-simulation-matrix-0.2.2.R` runs seeded `RSM`,
  `PCM`, and bounded-`GPCM` smoke cases for categorical signal, null,
  three-level categorical, and continuous-covariate DFF scenarios. Treat
  that evidence as route-boundary and target-direction validation, not
  as calibrated power, false-positive, fairness, invariance, or
  subgroup-decision evidence.
- MH reporting from `analyze_dif_mh()` is an observed-score
  Mantel-Haenszel screen; do not describe it as an MFRM `RSM`, `PCM`, or
  bounded-`GPCM` parameter test.
- Check `ScaleLinkStatus`, `ContrastComparable`, and the reported
  classification system before treating a contrast as a strong
  interpretive claim.

## Model-estimated facet interactions

For confirmatory interaction hypotheses,
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
can estimate explicit two-way non-person facet interactions in the model
likelihood.

``` r

fit_add <- fit_mfrm(df, "Person", c("Rater", "Criterion"), "Score",
                    method = "MML", model = "RSM")

fit_rxcrit <- fit_mfrm(df, "Person", c("Rater", "Criterion"), "Score",
                       method = "MML", model = "RSM",
                       facet_interactions = "Rater:Criterion")

interaction_effect_table(fit_rxcrit)
compare_mfrm(Additive = fit_add, RaterCriterion = fit_rxcrit, nested = TRUE)
```

Rules for interpretation:

- Name the facet pair explicitly. The package does not add all possible
  interactions automatically.
- The current scope is two-way interactions between non-person facets
  for `RSM` and `PCM`; GPCM, person-involving, higher-order, and
  random-effect interaction terms are deferred.
- The interaction matrix uses zero marginal sums, so each estimate is a
  deviation from the additive main-effects MFRM. Positive values
  indicate higher-than-expected scores for that facet-level combination;
  negative values indicate lower-than-expected scores.
- [`interaction_effect_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interaction_effect_table.md)
  reports model-estimated fixed effects.
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  and
  [`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md)
  remain residual screening tools for exploratory bias review.
- Sparse cells matter. Use `min_obs_per_interaction` and inspect the
  `Sparse` column before reporting substantive interaction claims.

## Model comparison

``` r

fit_rsm <- fit_mfrm(df, "Person", c("Rater", "Criterion"), "Score",
                     method = "MML", model = "RSM")
fit_pcm <- fit_mfrm(df, "Person", c("Rater", "Criterion"), "Score",
                     method = "MML", model = "PCM", step_facet = "Criterion")
cmp <- compare_mfrm(RSM = fit_rsm, PCM = fit_pcm)
cmp$table

# Request nested tests only when models are truly nested and fit on the same basis
cmp_nested <- compare_mfrm(RSM = fit_rsm, PCM = fit_pcm, nested = TRUE)
cmp_nested$comparison_basis

# RSM design-weighted precision curves
info <- compute_information(fit_rsm)
plot_information(info)
```

## Design simulation

``` r

spec <- build_mfrm_sim_spec(
  n_person = 50,
  n_rater = 4,
  n_criterion = 4,
  raters_per_person = 2,
  assignment = "rotating",
  model = "RSM"
)

sim_eval <- evaluate_mfrm_design(
  n_person = c(30, 50, 80),
  n_rater = 4,
  n_criterion = 4,
  raters_per_person = 2,
  reps = 2,
  maxit = 30,
  sim_spec = spec,
  seed = 123
)

s_sim <- summary(sim_eval)
s_sim$reading_order
s_sim$next_actions
s_sim$design_summary
s_sim$reporting_notes
s_sim$ademp

rec <- recommend_mfrm_design(sim_eval)
rec$recommended

plot(sim_eval, facet = "Rater", metric = "separation", x_var = "n_person")
plot(sim_eval, facet = "Criterion", metric = "severityrmse", x_var = "n_person")
```

Notes:

- Use
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  when you want one explicit, reusable data-generating mechanism.
- Use `extract_mfrm_sim_spec(fit)` when you want a fit-derived starting
  point for a later design study.
- Use
  `extract_mfrm_sim_spec(fit, latent_distribution = "empirical", assignment = "resampled")`
  when you want a more semi-parametric design study that reuses
  empirical fitted spreads and observed rater-assignment profiles.
- Use
  `extract_mfrm_sim_spec(fit, latent_distribution = "empirical", assignment = "skeleton")`
  when you want a more plasmode-style study that preserves the observed
  person-by-facet design skeleton and resimulates only the responses.
- Start with `summary(sim_eval)$reading_order` and
  `summary(sim_eval)$next_actions` before comparing candidate design
  rows.
- `summary(sim_eval)$ademp` records the simulation-study contract: aims,
  DGM, estimands, methods, and performance measures.
- [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  is a Monte Carlo design-evaluation helper. It can show how separation,
  reliability, strata, RMSE, and fit-screen rates change as facet counts
  vary; use
  [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  plus
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  for observed G-study components and analytic D-study projections.

### Sparse linked simulation

Use `assignment = "sparse_linked"` when the design itself should contain
planned missingness: most persons receive a small rater subset, while a
linking set receives a larger rater set to preserve common-person links
among raters.

``` r

sparse_spec <- build_mfrm_sim_spec(
  n_person = 80,
  n_rater = 6,
  n_criterion = 4,
  raters_per_person = 2,
  assignment = "sparse_linked",
  sparse_controls = list(
    link_fraction = 0.10,
    link_raters_per_person = 6,
    min_common_persons_per_rater_pair = 4
  )
)

sparse_sim <- simulate_mfrm_data(sim_spec = sparse_spec, seed = 20260526)
sparse_design <- attr(sparse_sim, "mfrm_sparse_design")
sparse_design$overview
sparse_design$rater_pair_links

sparse_eval <- evaluate_mfrm_design(
  n_person = c(40, 80),
  n_rater = 6,
  n_criterion = 4,
  raters_per_person = 2,
  assignment = "sparse_linked",
  sparse_controls = list(
    link_fraction = 0.10,
    link_raters_per_person = 6,
    min_common_persons_per_rater_pair = 4
  ),
  reps = 2,
  maxit = 30,
  seed = 20260526,
  progress = FALSE
)
summary(sparse_eval)$design_summary[
  ,
  c("Facet", "n_person", "MeanDesignDensity",
    "MeanPlannedMissingRate", "MeanMinCommonPersonsPerRaterPair")
]
summary(sparse_eval)$sparse_review

plot(
  sparse_eval,
  facet = "Rater",
  metric = "plannedmissingrate",
  x_var = "n_person",
  draw = FALSE
)

sparse_bundle <- build_summary_table_bundle(summary(sparse_eval))
sparse_bundle$tables$sparse_review
sparse_bundle$tables$sparse_design
```

This is a true data-generating simulation route, unlike observed-data
resampling below. The sparse-design metadata reports design density,
planned missing rate, rater coverage, and rater-pair common-person
counts so users can inspect whether the generated rating network has
enough linking for the study they intend to run. The table bundle keeps
the same sparse diagnostics in a separate appendix-ready table, rather
than mixing them into performance metrics. Its `LinkReviewStatus` column
flags zero common-person rater pairs or requested-link target shortfalls
as design-review items; it is not a parameter-recovery or model-fit
decision.

### Peer-review simulation

Use
[`build_peer_review_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_peer_review_sim_spec.md)
when submissions and reviewers are drawn from the same participant pool,
as in peer-assessment or peer-review scoring studies. The helper builds
a fixed skeleton so self-review can be excluded by design, ordinary
submissions can receive a small peer set, and a smaller anchor set can
be reviewed by many or all eligible peers for common-link support.

``` r

peer_spec <- build_peer_review_sim_spec(
  n_submission = 30,
  n_criterion = 4,
  reviewers_per_submission = 3,
  anchor_fraction = 0.10,
  avoid_self_review = TRUE
)

peer_sim <- simulate_mfrm_data(sim_spec = peer_spec, seed = 20260526)
peer_review <- build_peer_review_design_review(peer_sim)
summary(peer_review)$overview[
  ,
  c("Submissions", "Reviewers", "ReviewPairs", "SelfReviews",
    "MinCommonSubmissionsPerReviewerPair", "ZeroCommonReviewerPairs")
]

peer_bundle <- build_summary_table_bundle(peer_review)
peer_bundle$tables$low_common_pairs
```

The peer-review metadata reports assignment density, self-review counts,
reviewer load, reciprocal review pairs, and common submissions per
reviewer pair. These are design diagnostics. They do not by themselves
establish peer fairness, reviewer quality, fit, separation, or parameter
recovery.

The same metadata can be carried into
[`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md)
after a model is fit, so peer-review assignment checks appear alongside
graph connectedness and bridge/articulation diagnostics.

``` r

if (requireNamespace("igraph", quietly = TRUE)) {
  peer_fit <- fit_mfrm(
    peer_sim,
    person = "Person",
    facets = c("Reviewer", "Criterion"),
    score = "Score",
    method = "JML",
    maxit = 30
  )

  peer_net <- build_mfrm_network_review(
    peer_fit,
    peer_review_design = peer_sim,
    top_n = 8
  )
  summary(peer_net)$peer_review
}
```

### MFRM design-network review

Use
[`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md)
when the question is whether the observed person-by-facet design is well
linked enough to support common-scale interpretation. The helper wraps
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md)
and keeps graph diagnostics separate from MFRM fit, separation,
recovery, and rater-quality claims.

``` r

toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "JML",
  maxit = 30
)

if (requireNamespace("igraph", quietly = TRUE)) {
  net_review <- build_mfrm_network_review(fit, top_n = 8)
  summary(net_review)$overview
  summary(net_review)$top_cut_nodes
  summary(net_review)$top_bridge_edges

  net_bundle <- build_summary_table_bundle(net_review)
  net_bundle$tables$overview
  net_bundle$tables$facet_summary
}
```

For sparse simulations, pass the generated sparse-design metadata so the
same review can show both observed network vulnerability and
planned-missingness link diagnostics.

``` r

if (requireNamespace("igraph", quietly = TRUE)) {
  net_review <- build_mfrm_network_review(
    fit,
    sparse_design = sparse_design,
    top_n = 8
  )
  summary(net_review)$sparse_review
}
```

This route follows the linking-set and sparse-design literature by
treating connected components, articulation points, bridge edges, and
common-person rater links as design evidence. It does not turn network
centrality into a person measure, rater severity estimate, fit
statistic, or recovery gate.

## Observed-data resampling validation

Use the resampling helpers when the study target is stability or
reproducibility against a full-data reference estimate rather than
recovery of known generated truth. The draw layer is person-clustered,
so all observations for a selected person stay together. Stratification
can preserve small substantive groups such as `Region`, while
`preserve_facets` asks the draw to review and, when possible, top up
rater or other facet-level coverage.

``` r

toy_region <- simulate_mfrm_data(
  n_person = 30,
  n_rater = 4,
  n_criterion = 3,
  raters_per_person = 2,
  seed = 20260525
)
region_map <- setNames(
  rep(c("A", "B", "C"), length.out = length(unique(toy_region$Person))),
  unique(toy_region$Person)
)
toy_region$Region <- unname(region_map[toy_region$Person])

rs_spec <- build_mfrm_resampling_spec(
  toy_region,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  strata = "Region",
  preserve_facets = "Rater",
  reps = 5,
  sample_fraction = 0.5,
  seed = 20260525
)

rs_draws <- draw_mfrm_resamples(rs_spec)
summary(rs_draws)$overview
summary(rs_draws)$stratum_summary
summary(rs_draws)$preserve_summary
rs_draws$manifest
```

The returned `mfrm_resamples` object includes `samples`, a
replicate-level `manifest`, `stratum_manifest`, and `preserve_manifest`.
These objects are a validation input layer: the full-data estimates
remain reference estimates, not known true parameters, so reports should
describe later comparisons as estimation stability, reproducibility, or
agreement with the full-data reference.

## Population forecast

``` r

spec_pop <- build_mfrm_sim_spec(
  n_person = 50,
  n_rater = 4,
  n_criterion = 4,
  raters_per_person = 2,
  assignment = "rotating",
  model = "RSM"
)

pred_pop <- predict_mfrm_population(
  sim_spec = spec_pop,
  n_person = 60,
  reps = 2,
  maxit = 30,
  seed = 123
)

s_pred <- summary(pred_pop)
s_pred$reading_order
s_pred$next_actions
s_pred$forecast[, c("Facet", "MeanSeparation", "McseSeparation")]
s_pred$reporting_notes
```

Notes:

- [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  forecasts aggregate operating characteristics for one future design.
- It does not return deterministic future person or rater true values.
- Use
  [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  rather than
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  when you need to compare a grid of candidate designs.

## Future-unit posterior scoring

``` r

toy_pred <- load_mfrmr_data("example_core")
toy_fit <- fit_mfrm(
  toy_pred,
  "Person", c("Rater", "Criterion"), "Score",
  method = "MML",
  quad_points = 7
)

raters <- unique(toy_pred$Rater)[1:2]
criteria <- unique(toy_pred$Criterion)[1:2]

new_units <- data.frame(
  Person = c("NEW01", "NEW01", "NEW02", "NEW02"),
  Rater = c(raters[1], raters[2], raters[1], raters[2]),
  Criterion = c(criteria[1], criteria[2], criteria[1], criteria[2]),
  Score = c(2, 3, 2, 4)
)

pred_units <- predict_mfrm_units(toy_fit, new_units, n_draws = 0)
summary(pred_units)$estimates[, c("Person", "Estimate", "Lower", "Upper")]

pv_units <- sample_mfrm_plausible_values(
  toy_fit,
  new_units,
  n_draws = 3,
  seed = 123
)
summary(pv_units)$draw_summary[, c("Person", "Draws", "MeanValue")]

sens_units <- analyze_eap_power_sensitivity(
  toy_fit,
  new_units,
  prior_power = c(0.8, 1, 1.25),
  likelihood_power = c(0.9, 1, 1.1)
)
summary(sens_units)$summary
summary(sens_units)$facet_overview

plot(sens_units, type = "facet_stability")
plot(sens_units, type = "facet_heatmap", facet = "Rater")

if (requireNamespace("ggplot2", quietly = TRUE)) {
  as_ggplot(plot(sens_units, type = "facet_heatmap", facet = "Rater", draw = FALSE))
}
```

Notes:

- [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  scores future or partially observed persons under the fitted scoring
  basis.
- For ordinary `MML` fits, that basis is the fitted marginal
  calibration.
- For latent-regression `MML` fits with covariates, supply
  one-row-per-person background data for the scored units and the
  posterior summaries will condition on the fitted population model.
- Intercept-only latent-regression fits (`population_formula = ~ 1`) can
  reconstruct that minimal scored-person table from the person IDs in
  `new_units`.
- For `JML` fits, the scoring layer remains a post hoc reference-prior
  approximation rather than a latent-regression fit.
- It returns posterior summaries, not deterministic future true values.
- [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  exposes posterior draws under the same fitted scoring basis; the
  ordinary `MML` route is fixed-calibration, while active
  latent-regression fits use the fitted population model.
- `analyze_eap_power_sensitivity()` recomputes EAP summaries after
  power-scaling the quadrature-grid prior and/or likelihood. Use it as a
  scoring-stage sensitivity diagnostic; it does not refit the model,
  estimate a new latent distribution, or make the MML fitting prior
  configurable.
- The sensitivity object also includes exposure-weighted facet summaries
  and base-R/`ggplot2` plot routes. These identify where unstable scored
  persons appear in the observed scoring design; they are not a causal
  decomposition of facet parameter instability.
- Non-person facet levels in `new_units` must already exist in the
  fitted calibration.

## Prediction-aware bundle export

``` r

prediction_out_dir <- tempfile("mfrmr-prediction-bundle-")
bundle_pred <- export_mfrm_bundle(
  fit = toy_fit,
  population_prediction = pred_pop,
  unit_prediction = pred_units,
  plausible_values = pv_units,
  output_dir = prediction_out_dir,
  prefix = "mfrmr_prediction_bundle",
  include = c("manifest", "predictions", "html"),
  overwrite = TRUE
)

bundle_pred$summary
```

Notes:

- `include = "predictions"` only writes prediction artifacts that you
  actually supply.
- Use
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  and
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  only with an existing fitted calibration. For latent-regression fits,
  keep the scoring `person_data` contract explicit when the fitted
  population model includes covariates rather than treating the scored
  outputs as ordinary fixed-calibration summaries.
- When a latent-regression fit is exported with
  `include = c("script", "html")`, the bundle writes a fit-level replay
  person-data sidecar for the replay script, while the HTML bundle
  exposes only an artifact index for that sidecar rather than embedding
  raw person-level rows.

## DIF / Bias screening simulation

``` r

spec_sig <- build_mfrm_sim_spec(
  n_person = 50,
  n_rater = 4,
  n_criterion = 4,
  raters_per_person = 2,
  assignment = "rotating",
  group_levels = c("A", "B")
)

sig_eval <- evaluate_mfrm_signal_detection(
  n_person = c(30, 50, 80),
  n_rater = 4,
  n_criterion = 4,
  raters_per_person = 2,
  reps = 2,
  dif_effect = 0.8,
  bias_effect = -0.8,
  maxit = 30,
  sim_spec = spec_sig,
  seed = 123
)

s_sig <- summary(sig_eval)
s_sig$reading_order
s_sig$next_actions
s_sig$detection_summary
s_sig$reporting_notes
s_sig$ademp

plot(sig_eval, signal = "dif", metric = "power", x_var = "n_person")
plot(sig_eval, signal = "bias", metric = "false_positive", x_var = "n_person")
```

Notes:

- `DIFPower` is a conventional detection-power summary for the injected
  DIF target.
- `BiasScreenRate` and `BiasScreenFalsePositiveRate` summarize screening
  behavior from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).
- Bias-side `t`/`Prob.` values are screening metrics, not formal
  inferential p-values.
- For bias-side figures and prose, prefer `metric = "screen_rate"` /
  `BiasScreenRate` language over formal power wording.

## Bundle export

``` r

bundle_out_dir <- tempfile("mfrmr-bundle-")
bundle <- export_mfrm_bundle(
  fit_bias,
  diagnostics = diag_bias,
  bias_results = bias_all,
  output_dir = bundle_out_dir,
  prefix = "mfrmr_bundle",
  include = c("core_tables", "checklist", "manifest", "visual_summaries", "script", "html"),
  overwrite = TRUE
)

bundle$written_files

prediction_bundle_out_dir <- tempfile("mfrmr-prediction-bundle-")
bundle_pred <- export_mfrm_bundle(
  toy_fit,
  output_dir = prediction_bundle_out_dir,
  prefix = "mfrmr_prediction_bundle",
  include = c("manifest", "predictions", "html"),
  population_prediction = pred_pop,
  unit_prediction = pred_units,
  plausible_values = pv_units,
  overwrite = TRUE
)

bundle_pred$written_files

replay <- build_mfrm_replay_script(
  fit_bias,
  diagnostics = diag_bias,
  bias_results = bias_all,
  data_file = "your_data.csv"
)

replay$summary
```

## Anchoring and linking

``` r

d1 <- load_mfrmr_data("study1")
d2 <- load_mfrmr_data("study2")
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)

# Anchored calibration
res <- anchor_to_baseline(d2, fit1, "Person", c("Rater", "Criterion"), "Score")
summary(res)
res$drift

# Drift detection
drift <- detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2))
summary(drift)
plot_anchor_drift(drift, type = "drift")

# Screened linking chain
chain <- build_equating_chain(list(Form1 = fit1, Form2 = fit2))
summary(chain)
plot_anchor_drift(chain, type = "chain")
```

Notes:

- [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  and
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  remove the common-element link offset first, then report residual
  drift/link residuals.
- Treat `LinkSupportAdequate = FALSE` as a weak-link warning: at least
  one linking facet retained fewer than 5 common elements after
  screening.
- [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  is a practical screened linking aid, not a full general-purpose
  equating framework.

## QC pipeline

``` r

qc <- run_qc_pipeline(fit, threshold_profile = "standard")
qc$overall      # "Pass", "Warn", or "Fail"
qc$verdicts     # per-check verdicts
qc$recommendations

plot_qc_pipeline(qc, type = "traffic_light")
plot_qc_pipeline(qc, type = "detail")

# Threshold profiles: "strict", "standard", "lenient"
qc_strict <- run_qc_pipeline(fit, threshold_profile = "strict")
```

## Compatibility layer

Compatibility helpers are still available, but they are no longer the
primary route for new scripts.

- Use
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  or
  [`mfrmRFacets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  only when you need the one-shot wrapper.
- Use
  [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md)
  and
  [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md)
  only when a fixed-width or legacy export contract is required.
- For routine work, prefer package-native routes built from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
  and
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

For the full map, see
[`help("mfrmr_compatibility_layer", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md).

External-software wording should stay conservative:

``` r

chk <- reporting_checklist(fit, diagnostics = diag)
chk$facets_positioning
chk$software_scope
summary(chk)$software_scope
```

- `mfrmr native`: primary analysis surface.
- `FACETS`: FACETS-style reporting and handoff surfaces; results remain
  `mfrmr` estimates unless external FACETS output is supplied for
  explicit comparison.
- `ConQuest`: narrow external-table review path for the documented
  latent- regression overlap; use scoped comparison wording.
- `SPSS`: CSV/data-frame/reporting handoff only; no native SPSS
  integration.

## Legacy-compatible one-shot wrapper

``` r

run <- run_mfrm_facets(
  data = df,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "JML",
  model = "RSM"
)
summary(run)
plot(run, type = "fit", draw = FALSE)
```

## Public API map

For day-to-day use, start with the compact map:

``` r

mfrmr_output_guide("public")[, c("Question", "APILayer", "ObjectRole", "MainFunction")]
```

Rows with `APILayer == "top_level_public_surface"` are the preferred
user surface. `ObjectRole` tells whether the row estimates, summarizes,
displays, exports, or routes; `DecisionBoundary` states what the row
must not be used to claim. Rows marked `specialist_followup`,
`advanced_design_review`, or `migration_or_integration` should normally
be reached from `summary(res, view = "brief")`,
`summary(report, view = "reader")`, or a scoped guide rather than chosen
from the namespace by name.

The full exported function index (with categories such as *Model and
diagnostics*, *Bias and DFF*, *Anchoring and linking*, *Reporting and
APA*, *Plots and dashboards*, *Simulation and design*, and *Export
utilities*) is generated from roxygen. Within R the same grouping is
available through the topic help pages
[`?mfrmr_workflow_methods`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[`?mfrmr_visual_diagnostics`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
[`?mfrmr_reports_and_tables`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md),
[`?mfrmr_reporting_and_apa`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md),
[`?mfrmr_linking_and_dff`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md),
and
[`?mfrmr_compatibility_layer`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md).

Output-terminology note: `ModelSE` is the model-based standard error
used for primary summaries; `RealSE` is the fit-adjusted companion.
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
keeps the historical display labels (`Fair(M) Average`,
`Fair(Z) Average`) alongside package-native aliases `AdjustedAverage`,
`StandardizedAdjustedAverage`, `ModelBasedSE`, and `FitAdjustedSE`.

Reliability terminology note: `diagnostics$reliability` reports
Rasch/FACETS-style separation, strata, and separation reliability. These
indices answer whether persons, raters, criteria, or other facet
elements are distinguishable on the fitted logit scale. They are not
intra-class correlations. Use
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
only when you want a complementary random-effects variance-share summary
on the observed-score scale; for non-person facets such as raters, a
large ICC is systematic facet variance, not better reliability.

Generalizability-theory terminology note:
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
and
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
are observed-score G-study / D-study complements to the MFRM fit. Their
`G` and `Phi` coefficients answer design-generalizability questions
about observed score variance, not fitted-logit MFRM separation
reliability. Use `random_interactions` and
`compare_mfrm_generalizability()` as sensitivity checks when
person-by-rater, person-by-task, or condition-by-condition interactions
are substantively important. Singular or boundary expanded models should
be reported as sensitivity evidence rather than definitive variance
partitions. Use `check_mfrm_generalizability_design()` before fitting
expanded models when you need to review observed cell density,
exact-cell replication, and whether highest-order interaction remains
difficult to separate from residual error. Use
`plot(design_check, draw = FALSE)` or `as_ggplot()` to turn that review
into editable interaction-cell, highest-order, facet-coverage, or
signal-count figures; the same route is available from a fitted G-study
with `plot(gt, type = "design_check", draw = FALSE)`. For reporting, use
`plot(compare, type = "variance_delta", draw = FALSE)` to show variance
movement and `plot(compare, type = "d_study_overlay", draw = FALSE)` to
check whether design recommendations change. Start that comparison with
`plot(compare, type = "design_check", draw = FALSE)` when named
interactions are central to the claim, and inspect
`compare$comparison_review` before writing a model-comparison
conclusion. The returned `mfrm_plot_data` can be passed to `as_ggplot()`
or inspected with
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md)
for custom figures. When G/Phi or variance-component differences will be
interpreted strongly, use `bootstrap_mfrm_generalizability()` to add
observed-data person-cluster bootstrap intervals. Use
`build_summary_table_bundle(compare)` or
`export_summary_appendix(compare, preset = "recommended")` to hand off
the G-study comparison tables, including `comparison_review`, design
checks, variance movement, D-study rows, and warnings. Use
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
and `mfrmr_output_guide("psychometric")` near the end of an analysis to
check which evidence layers are present, missing, or review-bound before
drafting claims.

Scope note: `mfrmr` does not estimate latent-class mixture models or
response-time / careless-rating adjustments. Use person fit, residual
matrices, Q3-style local-dependence screens, rater drift, and DFF
diagnostics as screening evidence, not as substitutes for an explicit
mixture or response-time model. Use `mfrmr_model_family_scope()` for the
broader post-GPCM model boundary covering GRM, NRM, sequential models,
HRM, rater-bundle, HCM/GGUM, MRCMLM, LLTM/LPCM, and mixture Rasch
families. Use `mfrmr_estimation_scope()` for the separate
estimator/backend boundary covering CMLE, PMLE/composite likelihood,
free normal population SD for ordinary MML, optional Stan integration,
nonparametric latent distributions, empirical nonparametric response
curves, and mixture estimation.

## FACETS reference mapping

A reference table mapping FACETS-program output tables (Table 1, Table
5, Table 7, …) to the `mfrmr` helper functions that produce
substantively corresponding or adjacent package-native reports ships
with the installed package. The same reference also records
command/model-surface boundaries such as multiple FACETS `Model=`
statements, named `Rating Scale=` blocks, binomial/Poisson scale codes,
`Anchorfile=` specification rewrites, and output-dialog external file
routes. Open it with:

``` r

file.show(system.file("references", "FACETS_manual_mapping.md", package = "mfrmr"))
```

The mapping is a package-output contract reference, not evidence that
FACETS was executed or that numerical FACETS equivalence has been
established for any given fit. The intended workflow is to estimate and
report from `mfrmr` objects, then use FACETS-style routes only for
transition, handoff, or explicit external-table review.

## Packaged synthetic datasets

Lazy-loaded under `data/` and accessed either by name or via the
canonical loader:

``` r

data("ej2021_study1", package = "mfrmr")
# or
df <- load_mfrmr_data("study1")
```

Current packaged dataset sizes:

- `study1`: 1842 rows, 307 persons, 18 raters, 3 criteria
- `study2`: 3287 rows, 206 persons, 12 raters, 9 criteria
- `combined`: 5129 rows, 307 persons, 18 raters, 12 criteria
- `study1_itercal`: 1842 rows, 307 persons, 18 raters, 3 criteria
- `study2_itercal`: 3341 rows, 206 persons, 12 raters, 9 criteria
- `combined_itercal`: 5183 rows, 307 persons, 18 raters, 12 criteria

These datasets are paper-inspired, not paper-reproducing. The design
targets come from Eckes and Jin (2021): Study 1 used 307 examinees, 18
raters, 3 criteria, and a four-category writing rating scale; Study 2
used 206 examinees, 12 raters, 9 criteria, and the same four-category
scale. The package rows and scores are simulated artifacts for examples,
validation, and workflow rehearsal.

## Citation

``` r

citation("mfrmr")
```

## Acknowledgements

`mfrmr` has benefited from discussion and methodological input from
[Dr. Atsushi Mizumoto](https://mizumot.com/) and [Dr. Taichi
Yamashita](https://kugakujo.kansai-u.ac.jp/html/100000882_en.html).
