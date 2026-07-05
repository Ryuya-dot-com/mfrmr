#' mfrmr Reporting and APA Guide
#'
#' @description
#' Package-native guide to moving from fitted model objects to
#' manuscript-draft text, tables, notes, and revision checklists in `mfrmr`.
#'
#' This guide currently applies fully to diagnostics-based `RSM` / `PCM`
#' workflows. First-release `GPCM` fits now support [reporting_checklist()],
#' [precision_review_report()], direct curve/graph and residual table helpers,
#' and caveated APA/QC/export bundles. Use [gpcm_capability_matrix()] when you
#' need the formal boundary for the current `GPCM` reporting path.
#'
#' In particular, bounded `GPCM` [build_apa_outputs()],
#' [build_visual_summaries()], [run_qc_pipeline()],
#' [build_mfrm_manifest()], [build_mfrm_replay_script()], and
#' [export_mfrm_bundle()] outputs include explicit `gpcm_boundary` caveats.
#' Full FACETS-style score-side contract review remains blocked. Scorefile
#' export, design forecasting, diagnostic/signal-detection screening, and
#' linking synthesis use their own caveated `GPCM` routes and should not be
#' treated as automatic operational-scoring evidence.
#'
#' @section Start with the reporting question:
#' - "What would a critical psychometric reviewer expect before seeing any
#'   fitted object?"
#'   Use [mfrmr_minimum_report_checklist()]. It lists the minimum report
#'   topics that should be planned before treating software output as a
#'   manuscript-ready validity argument.
#' - "Which parts of this run are draft-complete, and with what caveats?"
#'   Use [reporting_checklist()].
#' - "How should I phrase the model, fit, and precision sections?"
#'   For `RSM` / `PCM`, use [build_apa_outputs()].
#' - "Which tables should I hand off to a manuscript or appendix?"
#'   Use [build_summary_table_bundle()], [export_summary_appendix()],
#'   [apa_table()], and
#'   [facet_statistics_report()].
#' - "How do I explain model-based vs exploratory precision?"
#'   Use [precision_review_report()] and `summary(diagnose_mfrm(...))`.
#' - "Which caveats need to appear in the write-up?"
#'   Use [reporting_checklist()] first, then [build_apa_outputs()].
#' - "How should I report DFF/DIF results in the manuscript?"
#'   Use [dif_report()] with `style = "apa"` for the conservative paragraph,
#'   [apa_table()] for the aligned table/note/caption, and
#'   `build_apa_outputs(..., dif_results = ...)` when the DFF/DIF paragraph
#'   should be appended to the main APA draft.
#' - "How should I report design-network connectedness or rater-linkage
#'   diagnostics?"
#'   Use [build_mfrm_network_review()] with an explicit graph scope. For
#'   rater-linkage, self-assessment, or peer/teacher bridging questions, compare
#'   the full graph with `facets = "Rater"`; then use
#'   `assumption_checks`, `visualization_map`, and `report_templates` rather
#'   than writing network interpretations from raw graph metrics alone. When
#'   the claim concerns pairwise rater agreement, disagreement, or relative
#'   severity direction, use [rater_network_analysis()] separately and export
#'   its `assumption_checks` through [build_summary_table_bundle()].
#' - "How should I report the MML population metric?"
#'   Inspect `summary(fit)$population_overview`, run [build_apa_outputs()],
#'   and check `summary(apa)$content_checks` for the
#'   `"MML population SD wording alignment"` row. Free-SD runs should keep the
#'   estimated SD and profile SE/CI caveat visible.
#' - "How should I start figure captions or visual-results wording?"
#'   Use [visual_reporting_template()] for conservative caption and results
#'   sentence starters, then verify availability with
#'   `reporting_checklist()$visual_scope`.
#'
#' @section Recommended reporting route:
#' 1. Before fitting or drafting, run [mfrmr_minimum_report_checklist()] and
#'    decide which rows are required for the intended use of the scores.
#' 2. Fit with [fit_mfrm()].
#' 3. Build diagnostics with [diagnose_mfrm()].
#' 4. Review precision strength with [precision_review_report()] when
#'    inferential language matters.
#' 5. Run [reporting_checklist()] to identify missing sections, caveats, and
#'    next actions. Use the `"Visual Displays"` rows as the figure-routing
#'    layer for the current run.
#' 6. When strict marginal rows are available, follow up with
#'    [plot_marginal_fit()] and [plot_marginal_pairwise()] before finalizing
#'    the narrative around local misfit.
#' 7. Create manuscript-draft prose and metadata with [build_apa_outputs()].
#'    For bounded `GPCM`, treat the APA/QC/export stack as caveated
#'    sensitivity-reporting output and keep its `gpcm_boundary` visible.
#'    For ordinary MML, keep fixed-prior versus estimated population-SD mode
#'    visible in Method wording and table notes.
#' 8. Convert summary outputs to reusable table bundles with
#'    [build_summary_table_bundle()], review the bundle with `summary()` /
#'    `plot()`, then convert specific components to handoff tables with
#'    [apa_table()] or export them directly with [export_summary_appendix()].
#'
#' @section Which helper answers which task:
#' \describe{
#'   \item{[mfrmr_minimum_report_checklist()]}{Lists the fit-independent
#'   method, design, estimation, fit, precision, category, rater/facet,
#'   fairness, linking, visual, FACETS/external-software, validity-boundary,
#'   and limitation topics that should be planned before writing. It is the
#'   best first page for a critical reviewer or a graduate student building a
#'   reporting outline.}
#'   \item{[reporting_checklist()]}{Turns current analysis objects into a
#'   prioritized revision guide with `DraftReady`, `Priority`, and
#'   `NextAction`. `DraftReady` means "ready to draft with the documented
#'   caveats"; `ReadyForAPA` is retained as a backward-compatible alias, and
#'   neither field means "formal inference is automatically justified". The
#'   `"Visual Displays"` rows also mirror the public plot family, so the
#'   checklist doubles as a figure-routing surface.}
#'   \item{[build_apa_outputs()]}{Builds shared-contract prose, table notes,
#'   captions, and a section map from the current fit and diagnostics.}
#'   \item{[build_summary_table_bundle()]}{Turns supported `summary()` outputs
#'   into named `data.frame` tables plus an index for manuscript or appendix
#'   handoff, and now also supports bundle-level `summary()` / `plot()` for
#'   role coverage and numeric QC.}
#'   \item{[export_summary_appendix()]}{Writes those validated summary-table
#'   bundles to CSV and optional HTML appendix artifacts without requiring a
#'   full fit-based export bundle.}
#'   \item{[apa_table()]}{Produces reproducible base-R tables with APA-oriented
#'   labels, notes, and captions.}
#'   \item{[precision_review_report()]}{Summarizes whether precision claims are
#'   model-based, hybrid, or exploratory.}
#'   \item{[facet_statistics_report()]}{Provides facet-level summaries that
#'   often feed result tables and appendix material.}
#'   \item{[build_visual_summaries()]}{Prepares publication-oriented figure
#'   data that can be cited from the report text.}
#'   \item{[visual_reporting_template()]}{Provides conservative figure
#'   placement, caption-starter, results-wording, and overclaim-avoidance
#'   guidance for public visual helpers.}
#'   \item{[build_mfrm_network_review()]}{Provides design-network review
#'   tables for connectedness, rater-linkage, self-assessment isolation, and
#'   peer/teacher bridging questions. Report its assumption checks before its
#'   graph metrics, use its APA templates for draft wording, and use its
#'   `Avoid` column to keep network diagnostics separate from fit, precision,
#'   fairness, and validity claims.}
#' }
#'
#' @section Practical reporting rules:
#' - Use [mfrmr_minimum_report_checklist()] before the analysis when the
#'   question is "what must the report cover?"
#' - Treat [reporting_checklist()] as the gap finder and
#'   [build_apa_outputs()] as the writing engine.
#' - Use the checklist's `"Visual Displays"` rows to decide whether the next
#'   follow-up should be [plot_qc_dashboard()], [plot_marginal_fit()],
#'   [plot_residual_pca()], [plot_bias_interaction()], or another public plot.
#' - Use [visual_reporting_template()] to draft visual captions and
#'   results-sentence starters, but do not paste the skeletons without checking
#'   the actual fit, diagnostics, and study context.
#' - Phrase formal inferential claims only when the precision tier is
#'   model-based.
#' - Keep bias and differential-functioning outputs in screening language
#'   unless the current precision layer and linking evidence justify stronger
#'   claims.
#' - Keep observed-score Mantel-Haenszel DIF from [analyze_dif_mh()] separate
#'   from fitted-MFRM `RSM`, `PCM`, and bounded-`GPCM` DFF/DIF. It can be
#'   reported through [dif_report()] with `style = "apa"` and [apa_table()], but
#'   its note states that no fitted MFRM likelihood was used.
#' - Keep design-network evidence from [build_mfrm_network_review()] separate
#'   from fitted MFRM evidence. Components, articulation points, bridges,
#'   centrality, and graph density describe observed co-observation topology;
#'   they are not model fit, rater quality, fairness, reliability, or validity
#'   indices.
#' - Keep MML population-SD mode separate from model fit and GPCM slope
#'   interpretation. The fixed-prior and free-SD routes put person measures on
#'   different latent metrics, so mixed comparisons need sensitivity wording.
#' - Treat `DraftReady` (and the legacy alias `ReadyForAPA`) as a
#'   drafting-readiness flag, not as a substitute for methodological review.
#' - Rebuild APA outputs after major model changes instead of editing old text
#'   by hand.
#' - For bounded `GPCM`, use APA/QC/export helpers only as caveated
#'   sensitivity-reporting surfaces and keep full FACETS-style score-side
#'   review outside this route.
#'
#' @section Typical workflow:
#' - Manuscript-first route:
#'   [mfrmr_minimum_report_checklist()] -> [fit_mfrm()] ->
#'   [diagnose_mfrm()] -> [reporting_checklist()] ->
#'   [build_apa_outputs()] -> [build_summary_table_bundle()] -> `summary()` /
#'   `plot()` -> [apa_table()], [export_summary_appendix()], or
#'   [export_mfrm_bundle()](include = c("summary_tables", "html")).
#'   For `RSM` / `PCM` final reports, prefer `method = "MML"` and
#'   `diagnostic_mode = "both"` in the diagnostics step.
#'   If `estimate_population_sd = TRUE`, add
#'   `summary(fit)$population_overview` and the
#'   `"MML population SD wording alignment"` content check to the read order.
#'   For bounded `GPCM`, use the same fit-based reporting/export family only
#'   as caveated sensitivity-reporting output and inspect its `gpcm_boundary`
#'   rows before writing claims.
#' - DFF/DIF route:
#'   [analyze_dff()] / [analyze_dif()] / [analyze_dif_mh()] /
#'   [analyze_dff_moderation()] / [dif_interaction_table()] ->
#'   [dif_report()] with `style = "apa"` -> [apa_table()] and, when desired,
#'   [build_apa_outputs()] with `dif_results = ...`.
#' - Appendix-first route:
#'   [facet_statistics_report()] -> [apa_table()] ->
#'   [build_visual_summaries()] -> [build_apa_outputs()].
#' - Precision-sensitive route:
#'   [diagnose_mfrm()] -> [precision_review_report()] ->
#'   [reporting_checklist()] -> [build_apa_outputs()].
#' - Network-reporting route:
#'   [build_mfrm_network_review()] -> inspect `assumption_checks` ->
#'   compare full and projected reviews when the target is rater linkage ->
#'   use `visualization_map` for figure selection ->
#'   use `report_templates[, c("APASection", "Text", "Avoid")]` for wording ->
#'   [build_summary_table_bundle()] / [export_summary_appendix()] for appendix
#'   handoff.
#' - bounded `GPCM` route:
#'   [diagnose_mfrm()] -> [precision_review_report()] ->
#'   [reporting_checklist()] -> direct residual/category/information helpers ->
#'   caveated [build_apa_outputs()], [build_visual_summaries()],
#'   [run_qc_pipeline()], or [export_mfrm_bundle()] as needed.
#'
#' @section Companion guides:
#' - For report/table selection, see [mfrmr_reports_and_tables].
#' - For end-to-end analysis routes, see [mfrmr_workflow_methods].
#' - For visual follow-up, see [mfrmr_visual_diagnostics].
#' - For the bounded `GPCM` support statement, see [gpcm_capability_matrix].
#' - For a longer walkthrough, see
#'   `vignette("mfrmr-reporting-and-apa", package = "mfrmr")`.
#'
#' @examples
#' \dontrun{
#' mfrmr_minimum_report_checklist()[, c("Section", "ReportItem", "Required")]
#' mfrmr_minimum_report_checklist("fairness")[, c("ReportItem", "mfrmrRoute")]
#'
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(
#'   toy,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   method = "MML",
#'   quad_points = 7,
#'   maxit = 30
#' )
#' diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
#'
#' checklist <- reporting_checklist(fit, diagnostics = diag)
#' visual_reporting_template("manuscript")[, c("FigureFamily", "CaptionSkeleton")]
#' head(checklist$checklist[, c("Section", "Item", "DraftReady", "NextAction")])
#' subset(
#'   checklist$checklist,
#'   Section == "Visual Displays",
#'   c("Item", "Available", "NextAction")
#' )
#'
#' apa <- build_apa_outputs(fit, diagnostics = diag)
#' apa$section_map[, c("SectionId", "Available")]
#'
#' tbl <- apa_table(fit, which = "summary")
#' tbl$caption
#' bundle <- build_summary_table_bundle(checklist)
#' bundle$table_index
#' apa_from_bundle <- apa_table(bundle, which = "section_summary")
#' apa_from_bundle$caption
#'
#' if (requireNamespace("igraph", quietly = TRUE)) {
#'   net_review <- build_mfrm_network_review(fit, diagnostics = diag,
#'                                           facets = "Rater")
#'   net_review$assumption_checks[, c("Check", "Status", "NextStep")]
#'   net_review$report_templates[, c("APASection", "Text", "Avoid")]
#' }
#' }
#'
#' @name mfrmr_reporting_and_apa
NULL
