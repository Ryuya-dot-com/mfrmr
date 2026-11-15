#' mfrmr Visual Diagnostics Map
#'
#' @description
#' Choose a figure by its question, then use the corresponding result's
#' `plot()` method. Start with the source summary and availability reasons;
#' a plot does not qualify estimates or inference. The installed
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")` gives worked
#' examples and interpretation.
#'
#' Ordinary RSM/PCM and supported one-family GPCM fits use [diagnose_mfrm()]
#' and [plot.mfrm_fit()]. Check [gpcm_capability_matrix()] for GPCM: its MnSq screens
#' need their slope-aware interpretation, and its QC fair-average panel is
#' unavailable. Two-family GPCM and corrected JML instead use the supported
#' [mfrm_response_diagnostics()] route, not ordinary Wright/Pathway plots.
#' Portable fixed-calibration scores have their own summary/plot methods in
#' [mfrm_calibration_score_methods]; these do not assess calibration fit.
#' @section Choose a figure:
#' | Question | Start with |
#' | --- | --- |
#' | Do Persons and facet levels cover a similar scale range? | `plot(fit, type = "wright")` |
#' | How do expected scores and category probabilities change? | `plot(fit, type = "pathway")` or `type = "ccc"` |
#' | Which responses or facet levels warrant fit review? | `plot(fit, type = "qc")`, then the relevant `unexpected`, `displacement` or `marginal_fit` view |
#' | Do observed raters agree? | [interrater_agreement_table()] and the fit's `agreement` view |
#' | Is there residual structure or a conditional interaction? | The fit's `residual_pca`, `local_dependence` or `bias` view |
#' | Are assignments connected, or common elements drifting? | [subset_connectivity_report()], [mfrm_network_analysis()] or [detect_anchor_drift()], then `plot(result)` |
#' | Do groups differ on the selected facet? | [analyze_dff()], then `plot(result)`; see [mfrm_dff_methods] for inferential alternatives |
#' | Which fixed-calibration scores need review? | `summary(scores)`, then `plot(scores, type = "interval")`; see [mfrm_calibration_score_methods] |
#'
#' Use `mfrmr_output_guide("plots")` for the complete plot map and
#' `reporting_checklist()$visual_scope` for availability in a fitted analysis.
#' [plot.mfrm_fit()] documents fit-specific `type`/`view` choices; other results
#' have their own `plot()` methods. The installed visual-diagnostics vignette
#' walks through figures, their reading and follow-up questions.
#' @section Session plot defaults:
#' Set `options(mfrmr.plot_preset = "publication")` to choose a session default
#' for plotting functions that expose the common `preset` argument. The
#' supported values are `"standard"`, `"publication"`, `"compact"` and
#' `"monochrome"`. Precedence is an explicit call argument, then the session
#' option, then `"standard"`. For example, `preset = "standard"` overrides
#' a session set to `"monochrome"`. Explicit `preset = NULL` retains the
#' earlier package-default behavior; it does not read the session option.
#' Invalid session values cause an error only when that option is needed.
#'
#' The category-curve, data-quality, fit-review, connectivity and network
#' routes of `plot()` for report bundles use the same option through `...`.
#' Plots without a common `preset` argument, including extended-model plots
#' with their own `palette` controls, keep their own settings. This option
#' selects a preset, not a universal theme or a guarantee that all renderers
#' implement every appearance control identically.
#'
#' New plot payloads retain the resolved preset for supported saved-data
#' rendering. Converting an existing payload with [as_ggplot()] uses its saved
#' appearance, even after the session option changes. A call that creates a
#' new plot from a fit or statistical result uses the current default.
#' For a reproducible script, supply `preset` explicitly or set the option in
#' that script. Saving only the fitted model does not save a session option.
#' No global ggplot theme is changed.
#'
#' Restore previous settings with `old <- options(mfrmr.plot_preset =
#' "monochrome")` followed by `options(old)`. Use
#' `options(mfrmr.plot_preset = NULL)` to remove the option. The preset changes
#' appearance, not estimates, confidence levels or diagnostic thresholds.
#'
#' @section Titles and compatibility:
#' Use `title` with [plot(x, type = "marginal_fit")][plot.mfrm_fit],
#' [plot(x, type = "marginal_pairwise")][plot.mfrm_fit], [plot(x, type = "unexpected")][plot.mfrm_fit],
#' [plot(x, type = "agreement")][plot.mfrm_fit], [plot(x, type = "facets_chisq")][plot.mfrm_fit], [plot(x, type = "bubble")][plot.mfrm_fit],
#' [plot(x, type = "bias")][plot.mfrm_fit] and [plot(x, type = "facet_dashboard")][plot.mfrm_fit]. Omission
#' retains default title metadata; `title = "Scoring patterns"` replaces it;
#' `title = NULL` or `title = ""` suppresses that metadata. Titles and explanatory
#' notes are returned outside the figure by default; display controls below
#' govern explicit drawing. The dashboard's S3 `plot()`
#' method forwards these controls. Use exact argument names.
#'
#' Legacy `main` remains supported without warnings, and `main = NULL` keeps
#' its original meaning: use the default heading. Supplying both `main` and
#' `title` is an error, even when they are equal or both `NULL`. Existing
#' positional calls retain their argument order. This is a compatible new
#' spelling, not removal or deprecation of `main`.
#'
#' A title change does not alter the data, interval level, screening settings,
#' reference lines, subtitles or interpretation notes. In stored plot payloads,
#' an omitted heading is represented by an empty string. When hiding the
#' heading of a review-only dashboard, retain its limitations in the figure
#' caption or accompanying report. Use the plot guide to check ggplot support;
#' accepting `title` does not add a converter for an unsupported plot.
#'
#' @section Fitted plots and saved intervals:
#' For ordinary fitted-model plots, `plot(fit, level = 0.90)` is an alternative
#' to `ci_level = 0.90`; use only one spelling. The same control is forwarded
#' by ordinary fit-based routes of `plot(res, ...)` and `as_ggplot(fit, ...)`.
#' It changes the normal intervals where `show_ci = TRUE`, without refitting
#' the model. The default remains 0.95. Specialist helpers that document
#' only `ci_level` retain that argument; this is not a package-wide rename.
#'
#' A saved inferential result has already chosen its method and level. For
#' example, create `ci <- mfrm_facet_intervals(fit, "Rater", level = 0.90)`
#' before `plot(ci)`; passing `level` to that plotting method is an error.
#' The attached route `plot(res, type = "facet_raters")` uses those saved
#' endpoints and does not inherit the Wright map's interval settings.
#'
#' A saved plot payload also retains its rendering choices. With
#' `p <- plot(fit, level = 0.90, show_title = FALSE, draw = FALSE)`,
#' `as_ggplot(p)` keeps that selection. To change it, make a new plot from
#' `fit`; extra settings such as `as_ggplot(p, level = 0.80)` are rejected.
#' To change labels on the converted ggplot, use
#' `as_ggplot(p) + ggplot2::labs(title = NULL)`.
#'
#' Figures omit titles, subtitles and explanatory footnotes by default.
#' Keep the returned object: `p <- plot(fit)`, then use
#' `plot_data(p, "title")` and `plot_data(p, "notes")` to prepare the title
#' and notes separately in a manuscript. Printing a returned `mfrm_plot_data`
#' object also displays notes in the console. The same notes accessor works
#' for mfrmr ggplots and after saving and reloading the returned object.
#' Axis labels, legends, panel identifiers and data/status symbols remain.
#' `title`, `main`, `subtitle` and `caption` now supply metadata by default.
#' Entry points with `show_title` and `show_notes` allow explicit opt-in
#' display; both switches default to `FALSE`. For ggplot customization, use
#' `ggplot2::labs(title = "...")`. Numerical warnings and saved diagnostics
#' remain available regardless of these presentation choices.
#'
#' @section Read the scale and diagnostic reference:
#' Higher Person locations predict higher **coded scores** in the ordinary
#' positive-discrimination models. Higher default Rater locations predict lower
#' coded scores; `positive_facets` reverses that facet's orientation, not the
#' outcome coding. Record both ends of the rubric. Changing labels or an axis
#' does not recode a model or its anchors; imported fits need their source
#' orientation. The visual-diagnostics vignette gives contrasting rubric examples.
#'
#' Infit/Outfit MnSq have reference 1: lower values indicate less residual
#' variation (overfit), higher values more (underfit). ZSTD has reference 0.
#' Agreement, similar severities or training alone do not imply overfit, and
#' displayed review bands are not universal acceptance rules. Read
#' [diagnose_mfrm()] for the selected calculation and reference conditions.
#'
#' Positive `Bias Size` increases expected coded scores while positive default
#' Rater severity decreases them. [estimate_bias()] holds the baseline calibration
#' fixed: the shift is a conditional interaction screen, not evidence of prejudice.
#' Absolute-bias profiles hide direction; inspect signed cells and their exposure
#' and uncertainty. A Step describes an adjacent-category transition, not a
#' learning stage or pass/fail cut. Its two category probabilities need not be
#' 0.5 at their crossing. See [rating_scale_table()] and [plot.mfrm_fit()] for
#' step offsets, reference profiles and RSM/PCM/GPCM ownership.
#' @section Keep the network questions separate:
#' [mfrm_network_analysis()] describes the assignment/co-observation graph and
#' is the relevant network route for disconnected measurement subsets.
#' [rater_network_analysis()] describes pairwise score agreement,
#' disagreement, or severity direction, while [rater_halo_network_analysis()]
#' describes rater-by-criterion score-profile correlations. The latter two do
#' not establish assignment connectedness or a common scale. In all three,
#' degree, strength, betweenness, and closeness are graph-theoretic quantities;
#' they are not rating-scale central tendency, MFRM severity logits, or causal
#' halo evidence.
#'
#' @section Customizing figures:
#' The package's plotting defaults are intended to be safe starting points,
#' not a closed graphics system. Use `preset = "publication"` for clean
#' manuscript defaults, or `preset = "monochrome"` for grayscale output that
#' relies more on line type, point shape, and reference lines than on color.
#' Use `plot(..., draw = FALSE)` when you want the reusable `mfrm_plot_data`
#' object instead of immediate base graphics. Then call
#' [plot_data_components()] to see available components and [plot_data()] to
#' extract the long tables used by the plot.
#'
#' Custom renderers should keep the returned metadata close to the figure:
#' `reference_lines`, `legend`, `guidance`, `category_support`,
#' `interpretation_guide`, and any reporting-template rows are part of the
#' interpretation contract. They let users change colors, labels, panels,
#' or rendering technology without losing the measurement scale, caveats, and
#' caption boundary attached to the package-native plot.
#'
#' @section Plot availability:
#' Use the question-to-function map above and the help of the corresponding
#' `plot()` method. Availability depends on the result class and fitted model;
#' a figure does not override missing estimates, intervals or diagnostic checks.
#'
#' @section 3D and surface data:
#' The package currently treats 3D as an exploratory data handoff, not as a
#' default plotting layer. The supported route is
#' `plot(fit, type = "ccc_surface", draw = FALSE)`, which returns
#' `surface`, `categories`, `category_support`, `groups`, `axis_contract`,
#' `renderer_contract`, `interpretation_guide`, and `reporting_policy` tables
#' inside an `mfrm_plot_data` object. These columns can be passed to an
#' external renderer if needed, while `category_support` and
#' `interpretation_guide` should be checked before interpreting retained
#' zero-frequency categories or adjacent threshold ridges.
#'
#' Do not replace the standard 2D Wright map, pathway map, CCC plot,
#' heatmap/profile diagnostics, or information curves with 3D figures in
#' routine reports. In particular, 3D Wright maps are discouraged because
#' perspective and occlusion obscure the shared-scale comparison that the
#' Wright map is meant to support.
#'
#' @section Preserve the interpretation when drawing:
#' Choose the view after reviewing its source summary and availability reasons.
#' Wright maps describe targeting; residual and interaction views screen model
#' departures. A figure cannot supply missing estimates or qualify inference.
#' Strict marginal/pairwise views require the documented diagnostic mode and
#' remain exploratory. Agreement and separation address different questions.
#'
#' For portable score batches, retain unavailable and prior-only states and
#' inspect the calibration separately; conditional intervals omit calibration
#' uncertainty. DFF refit contrasts also condition on baseline anchors and omit
#' cross-refit covariance, so their plots are screening displays without ETS
#' A/B/C labels. [mfrmr_interval_guide()] distinguishes inferential and descriptive bounds.
#'
#' Keep `plot_data(p, "notes")`, reference lines, category support and status
#' information when customizing or exporting. Titles and explanatory notes are
#' outside the figure by default; hiding them does not remove their qualifications.
#' For monochrome CCC/pathway curves and fair-score points, encodings repeat
#' beyond six series: use panels or select a facet when they become ambiguous.
#' @section Non-Latin and long labels:
#' Select an installed font that contains the characters in your labels before
#' drawing. For example, on macOS, open a PNG device and set
#' `par(family = "Hiragino Sans")` before `plot(fit)`. Use an appropriate
#' installed font on other systems. A successful plot call alone does not
#' confirm that the device rendered every character; inspect the saved figure.
#' Long labels also require enough space. Use a wider device for rater-severity
#' profiles. For crowded FACETS-style maps, use a taller or wider device,
#' increase `rows_per_logit`, or switch to `renderer = "native"`.
#' Full labels remain in the tables returned with `draw = FALSE`.
#'
#' @section Companion vignette:
#' For a longer, plot-first walkthrough, run
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @seealso [mfrmr_workflow_methods], [mfrmr_reports_and_tables],
#'   [mfrmr_reporting_and_apa], [mfrmr_linking_and_dff],
#'   [gpcm_capability_matrix], [visual_reporting_template()],
#'   [mfrmr_interval_guide()],
#'   [plot(x, type = "guttman")][plot.mfrm_fit], [plot(x, type = "qc")][plot.mfrm_fit],
#'   [plot(x, type = "unexpected")][plot.mfrm_fit], [plot(x, type = "displacement")][plot.mfrm_fit], [plot(x, type = "marginal_fit")][plot.mfrm_fit],
#'   [plot(x, type = "marginal_pairwise")][plot.mfrm_fit], [plot(x, type = "agreement")][plot.mfrm_fit],
#'   [plot(x, type = "facets_chisq")][plot.mfrm_fit], [plot(x, type = "residual_pca")][plot.mfrm_fit], [plot(x, type = "bias")][plot.mfrm_fit],
#'   [plot(x, type = "heatmap")][plot.mfrm_dif], [plot(x, type = "summary")][plot.mfrm_dif], [plot(x)][plot.mfrm_anchor_drift],
#'   [plot.mfrm_fit()],
#'   [plot(x, type = "residual_qq")][plot.mfrm_fit], `plot(fits[[1L]], type = "trajectory", comparison = fits[-1L], labels = names(fits))` (see [plot.mfrm_fit()]),
#'   [plot(x, type = "agreement", view = "heatmap")][plot.mfrm_fit], [response_time_review()],
#'   [plot(x)][plot.mfrm_response_time_review]
#'
#' @concept visual diagnostics
#' @concept reporting workflow
#' @concept confidence intervals
#' @concept GPCM boundaries
#'
#' @examples
#' # Long-running workflow; run explicitly when needed.
#' # example("mfrmr_visual_diagnostics", run.dontrun = TRUE)
#' \dontrun{
#' # Load the package and example ratings
#' library(mfrmr)
#' toy <- load_mfrmr_data("example_operational")
#'
#' # Fit the model
#' fit <- fit_mfrm(
#'   data = toy,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   method = "MML",
#'   model = "RSM"
#' )
#'
#' # Start with the shared-scale view; run plot commands one at a time
#' plot(fit)
#'
#' # Compute diagnostics once and check their interpretation status
#' diagnostics <- diagnose_mfrm(fit)
#' review <- summary(diagnostics)
#' review$decision
#'
#' # Inspect an overview of model-fit issues
#' plot(fit, type = "qc", diagnostics = diagnostics)
#'
#' # Follow up on observed versus model-expected category frequencies
#' plot(diagnostics, type = "marginal_fit")
#' }
#' @seealso [mfrmr_plot_migration]
#' @name mfrmr_visual_diagnostics
NULL

#' Figure-reporting template for visual diagnostics
#'
#' @description
#' Return a compact, beginner-oriented template that explains where each
#' visual family normally belongs in a report, which helper to call, what to
#' say, and what not to claim. Use this static table together with the dynamic
#' `reporting_checklist(fit, diagnostics)$visual_scope` table: the template
#' answers "how should I use this figure?", while the checklist answers "is
#' this figure ready for the current run?".
#'
#' @param scope Which part of the template to return: `"all"` (default),
#'   `"manuscript"`, `"appendix"`, `"diagnostic"`, or `"surface"`.
#'
#' @return A data.frame with columns:
#' - `FigureFamily`: short visual family label.
#' - `Scope`: broad reporting role used for filtering.
#' - `PrimaryHelper`: public helper or plot route.
#' - `DefaultPlacement`: recommended location in a report.
#' - `WhatToReport`: wording focus for results sections or captions.
#' - `CaptionSkeleton`: caption starter that must be tailored to the study.
#' - `ResultsWording`: results-sentence starter that must be checked against
#'   the fitted object and diagnostics.
#' - `WhatNotToClaim`: common overclaim to avoid.
#' - `BeginnerCheck`: first thing a new user should inspect.
#' - `ThreeDPolicy`: whether 3D is recommended, discouraged, or data-only.
#'
#' @details
#' This helper is intentionally conservative. It does not inspect a fitted
#' object and does not certify that a plot is available. Run
#' [reporting_checklist()] for run-specific readiness, then use this table to
#' decide how to describe the resulting figure.
#'
#' @concept visual diagnostics
#' @concept reporting workflow
#' @concept figure captions
#'
#' @examples
#' visual_reporting_template()
#' visual_reporting_template("manuscript")
#' visual_reporting_template("surface")
#' mfrmr_interval_guide("visual")[, c("Route", "PrimaryHelper", "DefaultLevel")]
#' @export
visual_reporting_template <- function(scope = c("all", "manuscript", "appendix", "diagnostic", "surface")) {
  scope <- match.arg(scope)

  out <- .mfrmr_table_visual_reporting_template_out

  if (identical(scope, "all")) {
    return(out)
  }
  out[out$Scope == scope, , drop = FALSE]
}

#' Confidence-interval and uncertainty route guide
#'
#' @description
#' Return a compact map of the public `mfrmr` routes that can expose
#' confidence intervals or interval-like uncertainty displays. Use this when
#' you need to know which helper accepts `show_ci` or `ci_level`, which columns
#' to look for in `draw = FALSE` output, and how strongly the resulting
#' interval should be interpreted.
#'
#' @param scope Which rows to return: `"all"` (default), `"visual"`,
#'   `"table"`, `"reporting"`, `"fit"`, `"bias"`, `"linking"`, `"gpcm"`,
#'   `"equivalence"`, `"hierarchical"`, or `"shrinkage"`.
#'
#' @details
#' The guide is deliberately conservative. It is a namespace and interpretation
#' map, not a fitted result and not proof that a given interval is available
#' for a particular run. For run-specific availability, call the listed helper
#' with `draw = FALSE` or inspect the relevant result table.
#'
#' Most rows use `ci_level = 0.95` by default. Some intervals are model-based
#' Wald intervals, some are delta-method intervals, some are profile or
#' profile-like intervals when available, and some are plotting overlays around
#' already-estimated quantities. The `Basis` and `InterpretationBoundary`
#' columns are the important guardrails.
#'
#' @section Why an estimate or interval is missing:
#' Point and interval availability are separate. When only uncertainty is
#' unavailable, retain the point together with its status and reason; do not
#' drop it merely because its bounds are missing. A refused interval call
#' leaves the source fit unchanged. An unidentified or nonexistent primary
#' estimate must not be replaced by a finite optimizer value. Constraint-fixed
#' values and prior-only scores also have different meanings. An `NA` bound
#' is not an infinite limit, zero uncertainty, or evidence of no effect.
#'
#' - **Fit and parameter readiness:** start with `summary(fit)$decision`,
#'   `$readiness` and `$key_warnings` for ordinary fits. For CML inspect
#'   `summary(fit)$checks` and `$notes`; comparison-only CML retains
#'   `EstimateStatus` and `EstimateReason` in `fit$comparisons`. Identification
#'   failure or absence of a finite MLE cannot be repaired merely by increasing
#'   optimizer iterations. A refused calculation explains the restriction in
#'   its error instead of returning an inferential result.
#' - **Facet and population intervals:** inspect `ci$table$Status`,
#'   `$CIEligible` and `$InferenceReview`, together with the result's checks
#'   and cautions. Missing SEs or bounds may coexist with a retained point;
#'   that does not certify the point as reliable. `fixed` refers to a target
#'   fixed by constraints, not an estimate with perfect measured precision.
#' - **GPCM slope/profile intervals:** use `attr(ci, "diagnostics")` and
#'   the saved endpoint checks. They distinguish an unavailable interval from
#'   a partially resolved profile; [confint.mfrm_fit()] describes each method.
#' - **Testlet and shared-rater normal intervals:** use
#'   `attr(ci, "diagnostics")` and `attr(ci, "checks")`; default summary tables
#'   also retain `IntervalStatus` and `InferenceReview`. These distinguish intervals
#'   not requested, unsupported targets, failed numerical/information checks,
#'   and estimated zero-variance boundaries. The boundary restriction applies
#'   even when optimization has converged. See [confint.mfrm_testlet()] and
#'   [confint.mfrm_random_rater()].
#' - **Person scores:** [score_mfrm_persons()] and the extension scoring
#'   functions retain row-level `Status` and `Reason`. `prior_only` means no
#'   observed responses: the reported mean and interval describe the assumed
#'   population. `unavailable` withholds individual estimates and intervals.
#'   Review the stated cause; more quadrature nodes cannot supply observations
#'   or remedy a zero ability-variance restriction.
#' - **G/D-study intervals:** read the metric-specific `Status`, diagnostics
#'   and notes. A width below numerical resolution is a calculation limitation,
#'   not perfect reliability; raw log-ratio or pivot diagnostics may still be
#'   retained. An explicitly reported zero endpoint, a constraint boundary and
#'   an unresolved numerical interval have different meanings.
#'
#' Increase integration precision or revise optimizer controls only when the
#' saved diagnostics identify those numerical issues. Model assumptions,
#' insufficient design information and unsupported boundary inference need
#' substantive review. Numerical success alone does not resolve them.
#' Keep explanations with saved results: use [saveRDS()] for the whole object,
#' and export the status/reason table with CSV. Older saved tables do not gain
#' fields merely by being read; recreate summaries or interval displays from
#' their source fit where supported. Do not rewrite historical fit checks.
#'
#' @section Availability is not coverage:
#' Read the target, interval method and assumptions before interpreting bounds.
#' Numerical availability, sampling coverage and public API support are separate
#' questions. Where returned, `CIEligible` records the source and method's
#' eligibility checks, which can include model, design and numerical restrictions;
#' `CoverageQualified = FALSE` means nominal sampling coverage is not established
#' for that procedure. It is not a measured coverage rate and does not erase
#' computed bounds. Absence of that field is not evidence of coverage either.
#'
#' A partial profile retains computed endpoints and the unresolved side's
#' reason. An unresolved search is not an infinite limit or a calibrated
#' one-sided interval. Inspect `apa_table(result, which = "profile_endpoints")`
#' and retain the method's notes when reporting or exporting it.
#'
#' Corrected-JML `RootSE` describes variation around an adjusted-equation root;
#' residual bias can separate that root from the true structural parameter.
#' It must not be turned into a structural confidence interval by multiplying
#' it by 1.96. This guide includes that uncertainty-only route with no default
#' confidence level. Unavailable public structural intervals do not establish
#' that every interval method is mathematically impossible.
#'
#' Conditional Person posterior intervals hold calibration fixed. A full
#' external Bayesian analysis, for example through [export_mfrm_model()], has
#' different assumptions and returns credible intervals; export alone neither
#' runs the sampler nor validates its intervals. Inspect sampler precision,
#' convergence and prior sensitivity. Neither type of posterior interval is
#' automatically a frequentist confidence interval with nominal coverage.
#' See [gpcm_capability_matrix()] for estimator-specific routes and restrictions.
#' For coefficients, conditional population means and residual variance in an
#' estimated RSM/PCM population, use [mfrm_population_intervals()]. Its
#' [plot() method][plot.mfrm_population_intervals] displays coefficients or
#' saved contrasts, retaining unavailable intervals and experimental status.
#' Residual variance stays in the table because its units differ. This route
#' is separate from Person scoring and facet-location intervals.
#'
#' Native RSM/PCM CML intervals use conditional information, with no estimated
#' Person abilities or population SD. The guide gives a dedicated route for
#' saved comparison-only targets and explains the facet argument for full CML
#' results. A separate full-MML interaction route accepts `comparison_review`
#' and optional `scale = "standardized"`; estimated-SD standardization includes
#' the same fit's population-SD uncertainty and its covariance with the contrast.
#' It requires an intercept-only normal population rather than substituting a
#' regression residual SD. Neither numerical eligibility nor a positive
#' conditional identification check establishes global MML identification or
#' finite-sample interval coverage.
#'
#' @return A data.frame with columns:
#' - `Route`
#' - `Scope`
#' - `PrimaryHelper`
#' - `DisplayRoute`
#' - `DefaultLevel` (missing for an uncertainty-only route without intervals)
#' - `IntervalColumns`
#' - `Basis`
#' - `UseFor`
#' - `InterpretationBoundary`
#' - `GPCMStatus`
#' - `Notes`
#'
#' @examples
#' mfrmr_interval_guide()
#' mfrmr_interval_guide("visual")[, c("Route", "DisplayRoute", "Basis")]
#' mfrmr_interval_guide("gpcm")[, c("Route", "GPCMStatus", "InterpretationBoundary")]
#' @seealso [mfrmr_visual_diagnostics], [visual_reporting_template()],
#'   [plot(x, type = "fair_average")][plot.mfrm_fit], [plot(x, type = "bias")][plot.mfrm_fit],
#'   [plot(x, type = "displacement")][plot.mfrm_fit], [plot(x, type = "wright", view = "unified")][plot.mfrm_fit],
#'   [plot(x, type = "rater_severity")][plot.mfrm_fit], [plot(x, type = "apa_summary")][plot.mfrm_fit],
#'   [fit_measures_table()], [mfrm_facet_intervals()], [mfrm_population_intervals()],
#'   [pool_mfrm_imputed()],
#'   [mfrm_random_rater_intervals()], [confint.mfrm_random_rater()],
#'   [fit_mfrm_testlet()], [predict.mfrm_testlet()]
#' @concept confidence intervals
#' @concept uncertainty displays
#' @concept visual diagnostics
#' @concept reporting workflow
#' @export
mfrmr_interval_guide <- function(scope = c(
  "all", "visual", "table", "reporting", "fit", "bias", "linking",
  "gpcm", "equivalence", "hierarchical", "shrinkage"
)) {
  scope <- match.arg(scope)

  out <- .mfrmr_table_mfrmr_interval_guide_out

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_1)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_2)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_3)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_4)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_5)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_6)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_7)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_8)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_9)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_10)

  if (identical(scope, "all")) {
    return(out)
  }
  out[grepl(paste0("(^|,)", scope, "(,|$)"), out$Scope), , drop = FALSE]
}
