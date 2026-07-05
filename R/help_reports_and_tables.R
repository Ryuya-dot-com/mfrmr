#' mfrmr Reports and Tables Map
#'
#' @description
#' Quick guide to choosing the right report or table helper in `mfrmr`.
#' Use this page when you know the reporting question but have not yet decided
#' which bundle, table, or reporting helper to call.
#'
#' @section Start with the question:
#' - "How should I document the model setup and run settings?"
#'   Use [specifications_report()].
#' - "Was data filtered, dropped, or mapped in unexpected ways?"
#'   Use [data_quality_report()] and [describe_mfrm_data()].
#' - "Did estimation converge cleanly and how formal is the precision layer?"
#'   Use [estimation_iteration_report()] and [precision_review_report()].
#' - "Which facets are measurable, variable, or weakly separated?"
#'   Use [facet_statistics_report()], [measurable_summary_table()], and
#'   [facets_chisq_table()].
#' - "Are score categories functioning in a usable sequence?"
#'   Use [rating_scale_table()], [category_structure_report()], and
#'   [category_curves_report()].
#' - "Is the design linked well enough across subsets, forms, or waves?"
#'   Use [subset_connectivity_report()] and [plot_anchor_drift()].
#' - "What should go into the manuscript text and tables?"
#'   For `RSM` / `PCM`, use [reporting_checklist()], [build_apa_outputs()],
#'   and [build_summary_table_bundle()] or [export_summary_appendix()]. For
#'   bounded `GPCM`, use the same route only where
#'   [gpcm_capability_matrix()] marks it as `supported_with_caveat`: direct
#'   table/plot helpers, summary-table appendix export, caveated
#'   [build_apa_outputs()], and caveated [export_mfrm_bundle()] are available
#'   with a `gpcm_boundary`; score-side exports and design-forecasting evidence
#'   use their own caveated or blocked `GPCM` routes.
#' - "Did a simulation recover the known generating parameters well enough?"
#'   Use [evaluate_mfrm_recovery()] for the recovery study,
#'   [assess_mfrm_recovery()] for the adequacy checklist, and then
#'   [build_summary_table_bundle()] or [export_summary_appendix()] for the
#'   appendix handoff.
#'
#' @section Recommended report route:
#' 1. Start with [specifications_report()] and [data_quality_report()] to
#'    document the run and confirm usable data.
#' 2. Continue with [estimation_iteration_report()] and
#'    [precision_review_report()] to judge convergence and inferential strength.
#' 3. Use [facet_statistics_report()] and [subset_connectivity_report()] to
#'    describe spread, linkage, and measurability.
#' 4. Add [rating_scale_table()], [category_structure_report()], and
#'    [category_curves_report()] to document scale functioning.
#' 5. For `RSM` / `PCM`, finish with [reporting_checklist()] and
#'    [build_apa_outputs()] for manuscript-oriented output, then
#'    [build_summary_table_bundle()] for reusable handoff tables or
#'    [export_summary_appendix()] for direct appendix export. For bounded
#'    `GPCM`, the same report/export route is available only as a caveated
#'    sensitivity-reporting layer with `gpcm_boundary`; keep FACETS-style
#'    score-side review and design forecasting on their separate capability
#'    rows.
#'
#' If you are unsure which helper to call, start with
#' [mfrmr_output_guide()]. It returns a compact purpose-to-helper table that
#' separates `*_table`, `*_report`, `*_review`, `*_bundle`, `export_*`, and
#' compatibility routes.
#'
#' @section Which output answers which question:
#' \describe{
#'   \item{[specifications_report()]}{Documents model type, estimation method,
#'   anchors, and core run settings. Best for method sections and
#'   reproducibility records.}
#'   \item{[data_quality_report()]}{Summarizes retained and dropped rows,
#'   missingness, and unknown elements. Best for data cleaning narratives.}
#'   \item{[estimation_iteration_report()]}{Shows replayed convergence
#'   trajectories. Best for diagnosing slow or unstable estimation.}
#'   \item{[precision_review_report()]}{Summarizes whether `SE`, `CI`, and
#'   reliability indices are model-based, hybrid, or exploratory. Best for
#'   deciding how strongly to phrase inferential claims.}
#'   \item{[facet_statistics_report()]}{Bundles facet summaries, precision
#'   summaries, and variability tests. Best for facet-level reporting.}
#'   \item{[subset_connectivity_report()]}{Summarizes disconnected subsets and
#'   coverage bottlenecks. Best for linking and anchor strategy review.}
#'   \item{[rating_scale_table()]}{Gives category counts, average measures, and
#'   threshold diagnostics. Best for first-pass category evaluation.}
#'   \item{[category_structure_report()]}{Adds transition points and compact
#'   category warnings. Best for category-order interpretation.}
#'   \item{[category_curves_report()]}{Returns category-probability,
#'   cumulative-probability, expected-ogive, total-information, and
#'   category-specific information coordinates. Best for downstream graphics
#'   and report drafts.}
#'   \item{[write_mfrm_residual_file()]}{Writes an observation-level residual
#'   file, optionally with modeled category probabilities. Best for external
#'   case review or reproducible handoff.}
#'   \item{[write_mfrm_subset_file()]}{Writes connected-subset summary and
#'   node-membership files. Best for scale-linking review outside R.}
#'   \item{[reporting_checklist()]}{Turns analysis status into an action list
#'   with priorities and next steps. Best for closing reporting gaps.}
#'   \item{[build_apa_outputs()]}{Creates manuscript-draft text, notes,
#'   captions, and section maps from a shared reporting contract.}
#'   \item{[build_summary_table_bundle()]}{Converts supported `summary()`
#'   outputs into named `data.frame` tables with a compact index for appendix
#'   or manuscript handoff, including recovery simulation and recovery
#'   assessment outputs. It also supports bundle-level `summary()` / `plot()`
#'   for QC before export.}
#'   \item{[export_summary_appendix()]}{Exports those validated summary-table
#'   bundles as CSV and optional HTML appendix artifacts without requiring the
#'   broader fit-based export bundle. This is the preferred export route for
#'   recovery simulation evidence.}
#'   \item{[apa_table()]}{Can now take those summary-table bundles directly,
#'   so a selected component can move from `summary()` to a formatted handoff
#'   table without rebuilding the analysis object path.}
#' }
#'
#' @section Practical interpretation rules:
#' - Use bundle summaries first, then drill down into component tables.
#' - Treat [precision_review_report()] as the gatekeeper for formal inference.
#' - Treat category and bias outputs as complementary layers rather than
#'   substitutes for overall fit review.
#' - Treat zero-count score categories as scale-functioning caveats. Boundary
#'   zero-count categories can be retained with explicit `rating_min` /
#'   `rating_max`; intermediate zero-count categories require
#'   `keep_original = TRUE` and make adjacent thresholds weakly identified.
#'   `summary(describe_mfrm_data(...))` exposes these in `Notes`, printed
#'   `Caveats`, and `$caveats`; `summary(fit)` carries full structured caveats
#'   into printed `Caveats` and `$caveats`, with `Key warnings` as a short
#'   triage subset. Summary-table exports use `score_category_caveats` and
#'   `analysis_caveats`.
#' - Use [reporting_checklist()] before [build_apa_outputs()] when a report
#'   still needs missing diagnostics or clearer caveats.
#'
#' @section Typical workflow:
#' - Run documentation:
#'   [fit_mfrm()] -> [specifications_report()] -> [data_quality_report()].
#' - Precision and facet review:
#'   [diagnose_mfrm()] -> [precision_review_report()] ->
#'   [facet_statistics_report()].
#' - Scale review:
#'   [rating_scale_table()] -> [category_structure_report()] ->
#'   [category_curves_report()].
#' - Manuscript handoff (`RSM` / `PCM`):
#'   [reporting_checklist()] -> [build_apa_outputs()] ->
#'   [build_summary_table_bundle()] -> `summary()` / `plot()` -> [apa_table()]
#'   or [export_summary_appendix()] /
#'   [export_mfrm_bundle()](include = "summary_tables").
#' - Bounded `GPCM` handoff:
#'   [reporting_checklist()] -> direct summaries/plots ->
#'   [build_apa_outputs()] or [build_summary_table_bundle()] ->
#'   [export_summary_appendix()] or caveated [export_mfrm_bundle()], with
#'   `gpcm_boundary` retained in report/export objects.
#' - Recovery simulation handoff:
#'   [evaluate_mfrm_recovery()] -> [plot()] / [assess_mfrm_recovery()] ->
#'   [build_summary_table_bundle()] -> [export_summary_appendix()].
#'
#' @section Companion guides:
#' - For visual follow-up, see [mfrmr_visual_diagnostics].
#' - For one-shot analysis routes, see [mfrmr_workflow_methods].
#' - For manuscript assembly, see [mfrmr_reporting_and_apa].
#' - For linking and DFF review, see [mfrmr_linking_and_dff].
#' - For legacy-compatible wrappers and exports, see [mfrmr_compatibility_layer].
#'
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' toy_small <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
#' fit <- fit_mfrm(
#'   toy_small,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   method = "MML",
#'   quad_points = 7,
#'   maxit = 30
#' )
#' diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
#'
#' spec <- specifications_report(fit)
#' summary(spec)$overview
#'
#' prec <- precision_review_report(fit, diagnostics = diag)
#' summary(prec)$checks
#'
#' checklist <- reporting_checklist(fit, diagnostics = diag)
#' subset(checklist$checklist, Section == "Visual Displays", c("Item", "NextAction"))
#'
#' apa <- build_apa_outputs(fit, diagnostics = diag)
#' apa$section_map[, c("Heading", "Available")]
#' bundle <- build_summary_table_bundle(checklist)
#' bundle$table_index
#' }
#'
#' @name mfrmr_reports_and_tables
NULL

#' Choose an mfrmr output helper by user goal
#'
#' @description
#' `mfrmr_output_guide()` returns a compact table for choosing among the main
#' table, report, review, bundle, export, and compatibility helpers. It is a
#' user-facing map, not an analysis result.
#'
#' @param scope Which rows to return. `"all"` returns the full guide.
#'   `"public"` returns the small top-level public surface for most users.
#'   `"entry"` returns the recommended first-screen routes. `"viewer"` returns
#'   `"beginner"` returns a short first-analysis path for users who should not
#'   start with FACETS, GPCM, or advanced simulation vocabulary. `"entry"`
#'   returns the recommended first-screen routes. `"viewer"` returns
#'   local-viewer routes built around `mfrm_results(include = ...)`. `"binary"`
#'   returns the two-category person-item Rasch route and checks.
#'   `"psychometric"` returns reviewer-facing report and validity-boundary
#'   routes, including [mfrmr_minimum_report_checklist()],
#'   [mfrm_analysis_audit()], and the observed-score G-theory route through
#'   [mfrm_generalizability()] / [mfrm_d_study()]. Other values
#'   filter to one output family or to bounded-`GPCM`-relevant routes.
#'   `"linking"` returns anchor, drift, and equating route rows.
#'   `"simulation"` and `"network"` return advanced design-review rows.
#'   `"response_time"` returns descriptive response-time QC rows.
#'   `"facets"`, `"conquest"`, and `"r"` return user-pathway rows for people
#'   arriving from those workflows.
#'
#' @details
#' Naming convention used by the guide:
#' - `*_table`: focused table or table-like result for one evidence source
#' - `*_report`: multi-table evidence bundle for a reporting question
#' - `*_review`: status, interpretation, or decision-support object
#' - `*_bundle`: reusable collection of tables/metadata for handoff
#' - `export_*`: writes files or appendix artifacts
#'
#' @section First-screen route:
#' Use `mfrmr_output_guide("public")` when you want the shortest top-level API
#' map. Use `mfrmr_output_guide("entry")` when you specifically want
#' first-screen creation routes. The entry guide points new scripts to
#' [fit_mfrm()] -> [diagnose_mfrm()] -> [mfrm_results()], existing fits to
#' [mfrm_results()], and exploratory console
#' work to [mfrm_results_interactive()]. After creating `res`, use
#' `summary(res, view = "brief")` for the short first screen and
#' `summary(res)$next_actions` to choose the next purpose-specific helper.
#' Use `mfrmr_output_guide("viewer")` when the next step is the optional local
#' Shiny reader; it shows which `include` preset to use before calling
#' [launch_mfrmr_viewer()].
#' For file handoff, the public and export guides route first to
#' `export_mfrm_results(res, preset = "starter")` so users get a reader-first
#' `index.html`, compact summaries, primary evidence tables, and replay code
#' before opening full archive exports.
#'
#' @section How to use this guide:
#' Treat `MainFunction` as the route to try next and `UseWhen` as the guardrail.
#' The guide is not a replacement for the help pages of the listed functions;
#' it is a namespace map for deciding which page to open.
#' For bounded `GPCM`, use `scope = "gpcm"` to find both the support matrix
#' and the table that explains how out-of-scope routes are handled.
#'
#' @return A data.frame with one row per recommended route and columns:
#' - `Scope`
#' - `Question`
#' - `OutputFamily`
#' - `Lifecycle`
#' - `UserLevel`
#' - `APILayer`
#' - `ObjectRole`
#' - `DecisionBoundary`
#' - `RecommendedEntry`
#' - `MainFunction`
#' - `UseWhen`
#' - `TypicalInput`
#' - `NextStep`
#' - `GPCMStatus`
#' - `Notes`
#'
#' @examples
#' public <- mfrmr_output_guide("public")
#' public[, c("Question", "APILayer", "ObjectRole", "MainFunction")]
#'
#' entry <- mfrmr_output_guide("entry")
#' entry[, c("Question", "Lifecycle", "UserLevel", "MainFunction")]
#'
#' reviews <- mfrmr_output_guide("reviews")
#' reviews[, c("Question", "MainFunction", "UseWhen")]
#'
#' mfrmr_output_guide("gpcm")[, c("Question", "MainFunction", "GPCMStatus")]
#' mfrmr_output_guide("beginner")[, c("Question", "MainFunction", "NextStep")]
#' mfrmr_output_guide("psychometric")[, c("Question", "MainFunction")]
#' mfrmr_output_guide("simulation")[, c("Question", "MainFunction", "NextStep")]
#' mfrmr_output_guide("linking")[, c("Question", "MainFunction")]
#' mfrmr_output_guide("network")[, c("Question", "MainFunction", "NextStep")]
#' mfrmr_output_guide("facets")[, c("Question", "MainFunction")]
#' mfrmr_output_guide("binary")[, c("Question", "MainFunction")]
#' mfrmr_output_guide("viewer")[, c("Question", "MainFunction")]
#' mfrmr_output_guide("response_time")[, c("Question", "MainFunction")]
#' @concept reporting workflow
#' @concept route selection
#' @concept GPCM boundaries
#' @export
mfrmr_output_guide <- function(scope = c("all", "public", "beginner", "entry", "viewer", "binary", "tables", "reports", "reviews",
                                         "bundles", "exports", "compatibility",
                                         "gpcm", "simulation", "linking", "network",
                                         "response_time", "psychometric",
                                         "facets", "conquest", "r")) {
  scope <- match.arg(scope)

  out <- data.frame(
    Scope = c(
      "reports", "reports", "reviews", "reviews", "reports", "tables", "reviews",
      "reviews", "reviews", "bundles", "reports", "exports", "compatibility"
    ),
    Question = c(
      "Document the model setup and run settings",
      "Check whether data were filtered, dropped, or remapped",
      "Review response-time metadata as descriptive QC context",
      "Decide how strongly precision claims can be phrased",
      "Summarize facet variability, separation, and measurability",
      "Review category functioning and expected-score curves",
      "Screen bias, DFF, or interaction evidence",
      "Review anchors, drift, and linking readiness",
      "Compare equal-weighting and bounded-GPCM routes",
      "Turn summaries into reusable appendix tables",
      "Assemble manuscript-oriented narrative output",
      "Write files for appendix, replay, or handoff",
      "Serve a legacy-compatible downstream layout"
    ),
    OutputFamily = c(
      "report", "report", "review", "review", "report", "table", "review",
      "review", "review", "bundle", "bundle", "export", "compatibility"
    ),
    MainFunction = c(
      "specifications_report()",
      "data_quality_report()",
      "response_time_review(); mfrm_results(include = \"response_time\", response_time = ...); plot_response_time_review(); plot_data_components()",
      "precision_review_report()",
      "facet_statistics_report()",
      "rating_scale_table(); category_structure_report(); category_curves_report()",
      "mfrm_results(fit, include = \"bias\"); estimate_bias(); analyze_dff(); analyze_dff_moderation(); analyze_dif_mh(); bias_interaction_report()",
      "review_mfrm_anchors(); detect_anchor_drift(); build_linking_review()",
      "build_model_choice_review(); build_weighting_review(); compare_mfrm()",
      "build_summary_table_bundle()",
      "mfrm_report(); reporting_checklist(); build_apa_outputs()",
      "export_mfrm_results(preset = \"starter\"); export_mfrm_results(preset = \"archive\"); export_summary_appendix(); export_mfrm_bundle(); build_mfrm_manifest()",
      "run_mfrm_facets(); facets_output_file_bundle(); facets_output_contract_review()"
    ),
    UseWhen = c(
      "You need methods-section settings or reproducibility context.",
      "You need to explain retained rows, missing values, or unknown elements.",
      "You have event-level timing metadata and need rapid/slow-response screening outside the fitted MFRM likelihood.",
      "You need to separate model-based, hybrid, and exploratory precision evidence.",
      "You need facet-level reporting before writing interpretation.",
      "You need category diagnostics or curve data for figures.",
      "You need screening evidence for follow-up fairness or interaction review.",
      "You need operational scale-maintenance checks for RSM/PCM workflows.",
      "You need to review whether discrimination-based reweighting changes conclusions.",
      "You need named data.frame outputs for appendix or handoff.",
      "You need manuscript text, captions, notes, and section maps.",
      "You need files on disk rather than R objects; start with the reader-first starter export unless a full archive is required.",
      "You need a fixed-width, graphfile, scorefile, or contract-check layout."
    ),
    TypicalInput = c(
      "mfrm_fit",
      "mfrm_fit plus optional raw data",
      "long-format rating-event data with person, time, and optional facet/score columns",
      "mfrm_fit plus mfrm_diagnostics",
      "mfrm_fit plus mfrm_diagnostics",
      "mfrm_fit",
      "mfrm_fit plus optional diagnostics/grouping; one-response person-by-item data for MH",
      "anchor tables, drift results, or equating chain objects",
      "two or more fitted candidate models",
      "summary(), review, recovery, prediction, or checklist objects",
      "mfrm_results, or mfrm_fit plus diagnostics/checklist evidence",
      "summary-table bundle, manifest, or fitted analysis bundle",
      "mfrm_fit or run_mfrm_facets() output"
    ),
    NextStep = c(
      "Read summary rows before adding interpretation.",
      "Inspect row-level reasons before reporting exclusions.",
      "Inspect thresholds, grouped summaries, summary(res)$next_actions, and draw-free plot data before deciding whether a separate QC note is needed.",
      "Use the status mix to decide wording strength.",
      "Use plots or summary-table bundles for presentation.",
      "Use plot helpers or export curve tables.",
      "Treat positive screens as follow-up prompts, not final decisions; for MH, first verify the person-by-item response-table contract.",
      "Use operational linking synthesis for RSM/PCM; keep bounded GPCM linking review caveated and exploratory.",
      "Report GPCM fit gains as sensitivity evidence, not automatic scoring policy.",
      "Use apa_table() or export_summary_appendix().",
      "Start from res <- mfrm_results(fit); use mfrm_report(res, style = \"qc\") before manuscript-specific prose.",
      "Check written_files and available_outputs before sharing.",
      "Prefer package-native routes unless a downstream tool requires this layout."
    ),
    GPCMStatus = c(
      "supported",
      "supported",
      "supported",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat; exploratory_gpcm_linking_review",
      "supported_with_caveat",
      "supported_for_direct_outputs",
      "supported_with_caveat",
      "summary_appendix_supported; fit_bundle_supported_with_caveat",
      "graph_only_or_blocked_by_score_side_semantics"
    ),
    Notes = c(
      "Best first report object when methods documentation is the goal.",
      "Pairs naturally with describe_mfrm_data().",
      "Timing summaries are descriptive QC only; they do not alter MFRM estimates, fit speed-accuracy models, estimate speed parameters, or define exclusion rules.",
      "Use before formal confidence or reliability language.",
      "Good bridge from diagnostics to report text.",
      "Category curves carry reusable plot data.",
      "Bias and DFF outputs are screening layers; MH DIF is an observed-score screen outside fitted-model fairness decisions.",
      "Operational linking conclusions remain RSM/PCM-scoped; bounded GPCM review is caveated exploratory synthesis.",
      "Use with gpcm_capability_matrix().",
      "Works for several object classes; inspect table_index.",
      "mfrm_report() is the report entry point over mfrm_results(); bounded GPCM APA text is caveated and carries gpcm_boundary.",
      "Use export_mfrm_results(preset = \"starter\") for reader-first handoff; use preset = \"archive\" or export_mfrm_bundle() for complete machine-readable archives.",
      "Compatibility is a presentation contract, not numerical equivalence."
    ),
    stringsAsFactors = FALSE
  )

  public_rows <- data.frame(
    Scope = rep("public", 7L),
    Question = c(
      "Start a new reproducible analysis",
      "Open the comprehensive first-screen result object",
      "Read report readiness before writing",
      "Open a local point-and-click reader",
      "Download results, report tables, HTML, and replay code",
      "Find the next specialized helper",
      "Use exploratory prompts only when explicitly requested"
    ),
    OutputFamily = c("entry", "entry", "report", "viewer", "export", "guide", "entry"),
    MainFunction = c(
      "fit_mfrm(); diagnose_mfrm(); res <- mfrm_results(fit)",
      "res <- mfrm_results(fit, include = ...); summary(res, view = \"brief\"); summary(res)",
      "mfrmr_minimum_report_checklist(); report <- mfrm_report(res); summary(report, view = \"reader\"); mfrm_report(res, output = \"html\")",
      "launch_mfrmr_viewer(res)",
      "export_mfrm_results(res, preset = \"starter\")",
      "mfrmr_output_guide(scope); summary(res)$next_actions",
      "mfrm_results_interactive(df)"
    ),
    UseWhen = c(
      "You can name the person, facet, and score columns and want a scriptable analysis.",
      "You already have a fit and want fit, diagnostics, tables, report status, plot routes, and next actions in one object.",
      "You need the minimum reporting outline, a FACETS-like report first screen, cautious wording routes, or HTML/Markdown report output.",
      "You want a local viewer over an existing mfrm_results object.",
      "You need files on disk for sharing, review, appendix work, or reproducibility.",
      "You know the purpose but not the exact helper name.",
      "You are at an interactive console with an unfamiliar data frame and accept opt-in prompts."
    ),
    TypicalInput = c(
      "long-format data.frame",
      "mfrm_fit, mfrm_facets_run, or conservative standard data.frame",
      "mfrm_results",
      "mfrm_results",
      "mfrm_results",
      "scope label or mfrm_results summary",
      "interactive long-format data.frame"
    ),
    NextStep = c(
      "Read summary(res, view = \"brief\"), plot(res, type = \"qc\"), and summary(res)$next_actions.",
      "Use mfrm_report(res), export_mfrm_results(res, preset = \"starter\"), or a scope-specific helper only after reading the first screen.",
      "Read mfrmr_minimum_report_checklist() before drafting; then start from summary(report, view = \"reader\") and report$first_screen before opening detailed templates.",
      "Use viewer output for inspection; keep the replayed mfrm_results() call in the analysis script.",
      "Open index.html first; inspect manifest.csv and keep the generated replay code with the analysis record.",
      "Filter by \"reports\", \"reviews\", \"exports\", \"linking\", \"simulation\", \"facets\", or \"r\".",
      "Move the printed replay code into an explicit script before reporting."
    ),
    GPCMStatus = c(
      "supported_with_caveat",
      "supported_with_caveat",
      "direct_outputs_supported; APA route scoped",
      "viewer_only_uses_existing_results",
      "summary_appendix_supported; fit_bundle_supported_with_caveat",
      "supported",
      "supported_with_caveat"
    ),
    Notes = c(
      "Primary entry for new work.",
      "Main object-level results surface; detailed helpers remain available as components.",
      "Minimum checklist plus report surface over mfrm_results(), not a new estimator or validity rule.",
      "Optional Shiny dependency; no external web application is loaded.",
      "Use preset = \"starter\" for reader-first handoff; use preset = \"archive\" or export_mfrm_bundle() for complete machine-readable archives.",
      "Use this instead of scanning every exported function name.",
      "Opt-in only; not used in batch scripts or tests."
    ),
    stringsAsFactors = FALSE
  )

  beginner_rows <- data.frame(
    Scope = rep("beginner", 5L),
    Question = c(
      "Run one ordinary first analysis",
      "Read the first screen before opening specialist helpers",
      "Check what the report must cover",
      "Choose one diagnostic follow-up",
      "Export a reader-first result packet"
    ),
    OutputFamily = c("entry", "entry", "guide", "review", "export"),
    MainFunction = c(
      "fit_mfrm(); diagnose_mfrm(); res <- mfrm_results(fit)",
      "summary(res, view = \"brief\"); plot(res, type = \"qc\"); summary(res)$next_actions",
      "mfrmr_minimum_report_checklist(); reporting_checklist(fit, diagnostics = diag)",
      "precision_review_report(); rating_scale_table(); fit_measures_table()",
      "export_mfrm_results(res, preset = \"starter\")"
    ),
    UseWhen = c(
      "You are new to MFRM and can identify the person, rater/item/facet, and score columns.",
      "You already fitted the model and need to know whether the run is readable before exploring advanced routes.",
      "You are preparing a class project, thesis chapter, or manuscript outline and need a concrete reporting checklist.",
      "The first screen points to fit, precision, or category evidence that needs one targeted follow-up.",
      "You need shareable HTML/CSV/replay files without learning every export helper."
    ),
    TypicalInput = c(
      "long-format data.frame",
      "mfrm_results",
      "none for minimum checklist; mfrm_fit plus diagnostics for reporting_checklist()",
      "mfrm_fit plus diagnostics",
      "mfrm_results"
    ),
    NextStep = c(
      "Use a simple RSM/PCM route first; leave FACETS migration, GPCM, simulation, and linking pages until a specific need appears.",
      "Read status and next_actions; do not treat unavailable sections as negative evidence until the listed helper has been run.",
      "Use the minimum checklist for the outline, then use reporting_checklist() after diagnostics to identify actual missing evidence.",
      "Open only the helper named by next_actions; avoid scanning the whole namespace.",
      "Open index.html first and keep the replay code with the analysis record."
    ),
    GPCMStatus = c(
      "rsm_pcm_recommended_for_first_analysis",
      "supported_with_caveat",
      "supported",
      "supported_with_caveat",
      "summary_appendix_supported; fit_bundle_supported_with_caveat"
    ),
    Notes = c(
      "This scope is deliberately narrow so beginners start with one scriptable model.",
      "The comprehensive result object collects evidence but does not make validity decisions.",
      "The minimum checklist is fit-independent; reporting_checklist() is fit-specific.",
      "Use one diagnostic follow-up at a time.",
      "The starter export is easier to review than a full machine-readable archive."
    ),
    stringsAsFactors = FALSE
  )

  entry_rows <- data.frame(
    Scope = c("entry", "entry", "entry", "entry", "entry"),
    Question = c(
      "Start with explicit model roles and a comprehensive first screen",
      "Open a FACETS-style result surface from an existing fit",
      "Browse the comprehensive result in a local Shiny viewer",
      "Choose the next purpose-specific helper without scanning the namespace",
      "Use column-selection prompts for exploratory data-frame input"
    ),
    OutputFamily = c("entry", "entry", "viewer", "guide", "entry"),
    MainFunction = c(
      "fit_mfrm(); diagnose_mfrm(); mfrm_results()",
      "mfrm_results()",
      "res <- mfrm_results(fit); launch_mfrmr_viewer(res)",
      "mfrmr_output_guide(); summary(res)$next_actions",
      "mfrm_results_interactive()"
    ),
    UseWhen = c(
      "You are writing a script, Quarto document, or reproducible analysis and can name person, facet, and score columns.",
      "You already have an mfrm_fit or run_mfrm_facets() object and want fit, diagnostics, table coverage, plot routes, and next actions together.",
      "You want a local point-and-click reader for triage, QC, report text, bias screens, pathway/misfit review, tables, plots, and replay code after creating mfrm_results().",
      "You need to move from the first screen into reporting, review, export, compatibility, network, or simulation routes.",
      "You are exploring an unfamiliar data frame at the console and explicitly want prompts."
    ),
    TypicalInput = c(
      "long-format data.frame",
      "mfrm_fit, mfrm_facets_run, or conservative standard data.frame",
      "mfrm_results",
      "scope label or mfrm_results summary",
      "interactive long-format data.frame"
    ),
    NextStep = c(
      "Read summary(res, view = \"brief\"), then use plot(res, type = \"qc\") and summary(res)$next_actions.",
      "Inspect summary(res)$status before treating unavailable sections as evidence.",
      "Install optional shiny support if needed; use the Replay tab output in scripts and reports, and make explicit follow-up choices for bias interaction review.",
      "Filter this guide by scope such as \"reviews\", \"reports\", \"exports\", \"facets\", or \"r\".",
      "Copy the printed replay code into a script before using the result in a report."
    ),
    GPCMStatus = c(
      "supported_with_caveat",
      "supported_with_caveat",
      "viewer_only_uses_existing_results",
      "supported",
      "supported_with_caveat"
    ),
    Notes = c(
      "Preferred route for new work: explicit fit first, then comprehensive results.",
      "mfrm_results() is a results surface over existing estimators, diagnostics, and table/report helpers.",
      "The viewer does not fit models or change diagnostics; it reads the supplied mfrm_results object and shows follow-up routes when a section is absent.",
      "Use this table as the public API map rather than memorizing every helper name.",
      "Interactive selection is deliberately opt-in and stops in non-interactive sessions."
    ),
    stringsAsFactors = FALSE
  )

  viewer_rows <- data.frame(
    Scope = rep("viewer", 7L),
    Question = c(
      "Open the standard first-screen viewer",
      "Prepare publication-oriented viewer sections",
      "Check validation, fit, and separation surfaces before reporting",
      "Inspect bias-screen prompts without choosing contrasts automatically",
      "Inspect pathway-map and row-level misfit prompts",
      "Inspect anchor and linking readiness",
      "Prepare a broad reviewer-facing viewer object"
    ),
    OutputFamily = rep("viewer", 7L),
    MainFunction = c(
      "res <- mfrm_results(fit, include = \"standard\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = \"publication\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = \"validation\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = \"bias\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = \"misfit_review\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = \"linking\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = c(\"publication\", \"bias\", \"misfit_review\", \"linking\")); launch_mfrmr_viewer(res)"
    ),
    UseWhen = c(
      "You want a local reader for overview, triage, status, QC, tables, plot routes, and replay code.",
      "You want APA-style draft text, table notes, figure notes, and reporting tables visible in the viewer.",
      "You want fit, precision, reliability, and FACETS-style review surfaces visible before making manuscript claims.",
      "You want facet-level bias-screen guidance while keeping interaction-bias facet-pair selection explicit in code.",
      "You want pathway-map annotations, unexpected-response rows, and displacement prompts in one inspection surface.",
      "You want anchor-readiness status and anchor plots visible before moving to explicit drift or equating checks.",
      "You are preparing a QC or review meeting and want the main publication, bias-screen, misfit-review, and linking-readiness surfaces together."
    ),
    TypicalInput = rep("mfrm_fit or mfrm_results", 7L),
    NextStep = c(
      "Read the Overview and Status tabs first; then use Tables, Plots, and Replay for drill-down.",
      "Treat report text as a draft scaffold and reconcile it with the fitted model, diagnostics, and study design.",
      "Use precision and separation evidence as reporting context, not as automatic pass/fail gates.",
      "Choose the substantive facet pair explicitly before running bias_interaction_report() or bias_pairwise_report().",
      "Treat unexpected rows as case-review prompts; document any exclusion or adjudication rule outside the viewer.",
      "Use detect_anchor_drift() or build_equating_chain() only after assembling an explicit list of fitted waves or forms.",
      "Use the Replay tab to move final choices back into an explicit script or Quarto document."
    ),
    GPCMStatus = c(
      "viewer_only_uses_existing_results",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "anchor_readiness_supported; exploratory_linking_review_supported_with_caveat",
      "viewer_only_uses_existing_results"
    ),
    Notes = c(
      "The viewer reads a completed mfrm_results object; it does not estimate or change diagnostics.",
      "For bounded GPCM, publication viewer sections can show direct outputs, caveated APA text, and gpcm_boundary.",
      "This route is a display layer over existing validation and fit/separation helpers.",
      "Bias screens are follow-up prompts, not fairness conclusions.",
      "Pathway and unexpected-response displays help locate cases; they do not decide whether observations are invalid.",
      "The first-screen viewer does not infer drift from a single fitted model.",
      "Do not use the viewer as the only analysis record; keep the replayed mfrm_results() call in source control or the report source."
    ),
    stringsAsFactors = FALSE
  )

  binary_rows <- data.frame(
    Scope = c("binary", "binary", "binary"),
    Question = c(
      "Fit ordinary person-item binary responses",
      "Confirm the two-category score support",
      "Open the first-screen results for a binary Rasch run"
    ),
    OutputFamily = c("entry", "guide", "entry"),
    MainFunction = c(
      "fit_mfrm(data, person = ..., facets = \"Item\", score = ..., model = \"RSM\"); mfrm_results()",
      "describe_mfrm_data(); fit$prep$score_map; summary(fit)$settings_overview",
      "mfrm_results(fit); plot(res, type = \"wright\"); plot(res, type = \"qc\")"
    ),
    UseWhen = c(
      "The data have one person column, one item column, and ordered binary scores such as 0/1 or 1/2.",
      "Score codes may not start at zero, boundary categories may be unobserved, or you need to document the internal score map.",
      "You want the same comprehensive first screen used for rating-scale MFRM fits."
    ),
    TypicalInput = c(
      "long-format binary response data",
      "raw data or mfrm_fit",
      "mfrm_fit"
    ),
    NextStep = c(
      "Do not include the person column again in facets; pass the item column as the non-person facet.",
      "Check that fit$summary$Categories is 2. Set rating_min/rating_max only when the intended response scale includes unobserved boundary categories.",
      "Read summary(res)$triage and summary(res)$next_actions before moving to fit, category, bias, or reporting helpers."
    ),
    GPCMStatus = c(
      "rsm_recommended_for_ordinary_binary",
      "supported",
      "supported_with_caveat"
    ),
    Notes = c(
      "With two ordered categories, the RSM branch reduces to the usual binary Rasch logit up to package centering and threshold identification.",
      "Binary 1/2 input is still binary; the observed range and score mapping are recorded in prep metadata.",
      "Binary runs use the same diagnostics and plotting routes, but category-threshold interpretation has only one boundary."
    ),
    stringsAsFactors = FALSE
  )

  linking_rows <- data.frame(
    Scope = c("linking", "linking", "linking", "linking"),
    Question = c(
      "Open first-screen anchor and linking readiness from an existing fit",
      "Review intended anchor and group-anchor tables before fitting",
      "Check drift across separately fitted waves or forms",
      "Build a screened equating chain across ordered calibrations"
    ),
    OutputFamily = c("review", "review", "review", "review"),
    MainFunction = c(
      "mfrm_results(fit, include = \"linking\"); plot(res, type = \"anchors\")",
      "make_anchor_table(); anchor_linking_contract(); review_mfrm_anchors(); fit_mfrm(anchors = ..., group_anchors = ...)",
      "detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2)); build_linking_review(drift = ...); plot_anchor_drift()",
      "build_equating_chain(list(Form1 = fit1, Form2 = fit2)); build_linking_review(chain = ...); plot_anchor_drift(type = \"chain\")"
    ),
    UseWhen = c(
      "You already have an mfrm_fit and want the stored anchor-review evidence in the comprehensive results surface.",
      "You are preparing fixed anchors or group anchors and need to catch overlap, duplicate, missing, sparse, or unsupported anchor rows before estimation.",
      "You have two or more independently fitted waves and need common-element drift and thin-link support checks.",
      "You have an ordered sequence of forms or administrations and need screened adjacent-link offsets before operational score-scale maintenance."
    ),
    TypicalInput = c(
      "mfrm_fit",
      "raw long-format data plus anchor/group-anchor tables",
      "named list of mfrm_fit objects",
      "ordered named list of mfrm_fit objects"
    ),
    NextStep = c(
      "Use summary(res$components$linking_review), plot(res, type = \"anchors\"), and build_summary_table_bundle(res$components$linking_review).",
      "Read the anchor contract for R-native replay/FACETS Anchorfile boundaries, then resolve issue_counts and recommendations before fitting the anchored model.",
      "Inspect common_by_facet and flagged drift rows before treating fitted waves as comparable.",
      "Inspect link support and residual spread before using cumulative offsets operationally."
    ),
    GPCMStatus = c(
      "anchor_readiness_supported; exploratory_linking_review_supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat; exploratory_gpcm_linking_review",
      "supported_with_caveat; exploratory_gpcm_linking_review"
    ),
    Notes = c(
      "The first-screen route does not infer drift from one fit; it makes the anchor-readiness evidence visible and routes users to multi-fit checks.",
      "Pre-fit anchor review is a data/design check, not a proof that anchored estimates are valid.",
      "Drift review removes common-element link offsets before flagging residual drift.",
      "The equating chain is a screened practical aid, not a full general-purpose equating framework."
    ),
    stringsAsFactors = FALSE
  )

  advanced_rows <- data.frame(
    Scope = c(
      rep("simulation", 8L),
      "network", "network"
    ),
    Question = c(
      "Define one reusable data-generating mechanism",
      "Generate one synthetic response dataset",
      "Check whether known parameters are recovered",
      "Compare candidate design operating characteristics",
      "Forecast one future administration scenario",
      "Screen diagnostic behavior under misspecification scenarios",
      "Screen DIF and bias signal-detection behavior",
      "Export simulation operating-characteristic tables for appendices",
      "Review co-observation connectivity as design evidence",
      "Review peer-review assignment topology"
    ),
    OutputFamily = c(
      "simulation", "simulation", "review", "review",
      "simulation", "simulation", "simulation", "export",
      "review", "review"
    ),
    MainFunction = c(
      "build_mfrm_sim_spec(); extract_mfrm_sim_spec()",
      "simulate_mfrm_data()",
      "evaluate_mfrm_recovery(); summary(rec)$reading_order; assess_mfrm_recovery()",
      "evaluate_mfrm_design(); summary(sim_eval)$reading_order; recommend_mfrm_design(); plot(sim_eval, draw = FALSE)",
      "predict_mfrm_population(); summary(pred)$reading_order",
      "evaluate_mfrm_diagnostic_screening(); summary(diag_eval)$reading_order; plot(..., draw = FALSE); plot_data()",
      "evaluate_mfrm_signal_detection(); summary(sig_eval)$reading_order; plot(signal = \"bias\", metric = \"screen_rate\", draw = FALSE)",
      "build_summary_table_bundle(); export_summary_appendix()",
      "mfrm_network_analysis(); build_mfrm_network_review(); plot(review, ...); build_summary_table_bundle(review)",
      "build_peer_review_sim_spec(); build_peer_review_design_review(); build_mfrm_network_review(peer_review_design = ...)"
    ),
    UseWhen = c(
      "You need a documented, reusable DGM before generating data, checking recovery, evaluating designs, or forecasting one scenario.",
      "You need a single synthetic long-format response table for a smoke example, fixture, or downstream refit check.",
      "You need direct Monte Carlo evidence that the fitted model recovers known generating parameters under one DGM.",
      "You need to compare design cells across facet counts, assignment density, separation, reliability, recovery RMSE, or fit-screen rates.",
      "You need scenario-level aggregate operating characteristics for one future design, not a grid of design alternatives.",
      "You need to compare legacy residual ZSTD screens, strict marginal/pairwise screens, scenario contrasts, runtime, and optional report-review signals.",
      "You need DIF target/non-target rates and bias-screen hit-rate behavior under injected signal scenarios.",
      "You need simulation summary tables, reading-order tables, reporting notes, and plot-data handoff tables for Quarto, reviewers, or supplementary files.",
      "You need graph connectedness, shared-observation, or subset diagnostics before treating measures as comparable.",
      "You need to document reviewer load, reciprocal pairs, low-common reviewer links, or assignment topology before interpreting peer-review scores."
    ),
    TypicalInput = c(
      "explicit generator arguments or an mfrm_fit for extract_mfrm_sim_spec()",
      "mfrm_sim_spec or explicit generator arguments",
      "mfrm_sim_spec or explicit generator arguments",
      "mfrm_sim_spec plus design grid or explicit generator/design arguments",
      "mfrm_sim_spec or mfrm_fit plus one design override",
      "mfrm_diagnostic_screening object or its summary",
      "mfrm_signal_detection object or its summary",
      "simulation object or summary object",
      "mfrm_fit, data frame, or diagnostics with co-observation structure",
      "peer-review simulation output or peer-review design metadata"
    ),
    NextStep = c(
      "Inspect spec$model, spec$assignment, threshold/slope tables, sparse controls, and ADEMP metadata carried into downstream summaries.",
      "Inspect attributes(data, \"mfrm_sim_spec\") and any sparse-design metadata before fitting; do not treat one draw as design evidence.",
      "Start with summary(rec)$reading_order and summary(rec)$next_actions; use assess_mfrm_recovery() with practical thresholds before reporting adequacy.",
      "Start with summary(sim_eval)$reading_order and summary(sim_eval)$next_actions; use recommend_mfrm_design() only after setting practical thresholds.",
      "Start with summary(pred)$reading_order and summary(pred)$reporting_notes; use evaluate_mfrm_design() when comparing candidate designs.",
      "Read scenario_summary and performance_summary first; use plot_overview_rate or plot_report_rate for reusable figure data.",
      "Read summary(sig_eval)$reporting_notes before prose; use BiasScreenRate/screen_rate wording for bias-side outputs.",
      "Use appendix_preset = \"recommended\" for a compact handoff, or include_empty = TRUE when documenting unavailable report-signal tables.",
      "Read assumption_checks first, then use visualization_map, report_templates, and appendix tables for reporting.",
      "Use the design review before any peer-quality, fairness, fit, separation, or recovery interpretation."
    ),
    GPCMStatus = c(
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "design_diagnostic_not_measurement_gate",
      "design_diagnostic_not_measurement_gate"
    ),
    Notes = c(
      "Generator labels and slope-regime metadata document conditions; they are not fit or adequacy thresholds.",
      "One synthetic dataset is an example or fixture, not a Monte Carlo validation result.",
      "Use ADEMP-style condition and metric separation when reporting recovery simulation evidence.",
      "Design evaluation is simulated operating-characteristic evidence, not an observed-data D-study or validity decision.",
      "Population forecasting is a scenario-level aggregate forecast, not deterministic future person/rater prediction.",
      "Diagnostic-screening simulations are operating-characteristic readouts, not calibrated inferential tests or release gates.",
      "Bias-side rates are screening summaries from estimate_bias(), not formal power or alpha-calibrated false-positive rates.",
      "The appendix route reuses the package-wide summary-table contract instead of creating a separate simulation-only export API.",
      "Network review is a design/connectivity layer; assumption checks, APA templates, and plot routes do not replace MFRM estimates.",
      "Peer-review topology is an assignment-design diagnostic, not a reviewer-quality decision."
    ),
    stringsAsFactors = FALSE
  )

  gpcm_rows <- data.frame(
    Scope = rep("gpcm", 2L),
    Question = c(
      "Check the bounded GPCM support matrix",
      "Review out-of-scope bounded GPCM route guidance"
    ),
    OutputFamily = c("guide", "review"),
    MainFunction = c(
      "gpcm_capability_matrix()",
      "gpcm_runtime_guard_coverage()"
    ),
    UseWhen = c(
      "You need to confirm which GPCM helper families are supported, caveated, blocked, or deferred before choosing a route.",
      "You need to confirm which GPCM routes are supported, caveated, blocked, or deferred before choosing a route."
    ),
    TypicalInput = c(
      "none",
      "none"
    ),
    NextStep = c(
      "Use supported and supported_with_caveat rows directly; for blocked or deferred rows, inspect RecommendedRoute and NextValidationStep.",
      "Read RecommendedRoute and NextValidationStep before choosing a substitute route or changing out-of-scope GPCM behavior."
    ),
    GPCMStatus = c(
      "bounded_support_matrix",
      "out_of_scope_route_guidance"
    ),
    Notes = c(
      "The capability matrix is the user-facing bounded-GPCM support matrix.",
      "This table explains out-of-scope route handling; it does not expand the supported GPCM surface."
    ),
    stringsAsFactors = FALSE
  )

  psychometric_rows <- data.frame(
    Scope = rep("psychometric", 7L),
    Question = c(
      "Plan the minimum report expected by a critical reviewer",
      "Check fit-specific draft readiness and missing evidence",
      "Place diagnostics inside a broader validity argument",
      "Separate G-theory generalizability from fitted MFRM reliability",
      "Keep FACETS terminology precise for FACETS-experienced readers",
      "Select figures without overclaiming visual evidence",
      "Document model-choice and sensitivity boundaries"
    ),
    OutputFamily = c("guide", "report", "review", "review", "compatibility", "guide", "review"),
    MainFunction = c(
      "mfrmr_minimum_report_checklist()",
      "reporting_checklist(); summary(reporting_checklist(...))",
      "mfrm_analysis_audit(); mfrmr_reporting_and_apa",
      "mfrm_generalizability(); mfrm_d_study(); check_mfrm_generalizability_design(); compare_mfrm_generalizability(); bootstrap_mfrm_generalizability()",
      "facets_positioning_guide(); facets_term_crosswalk(); facets_feature_coverage(); facets_visual_contract()",
      "visual_reporting_template(); reporting_checklist()$visual_scope; build_visual_summaries()",
      "build_model_choice_review(); build_weighting_review(); compare_mfrm(); gpcm_capability_matrix()"
    ),
    UseWhen = c(
      "You are planning, reviewing, or revising a report before treating output as manuscript-ready.",
      "You already have fit and diagnostics and need a prioritized action list.",
      "You need to show that fit, precision, fairness, and design evidence are not being treated as standalone validity proof.",
      "You need G/Phi, D-study projections, or interaction-sensitive design evidence without calling it MFRM separation reliability.",
      "A reviewer or collaborator is fluent in FACETS terms and may expect Table 6/7/8/13/14, Graphfile, Anchorfile, or ZSTD wording.",
      "You need captions, figure placement, and plot-data routes with explicit interpretation boundaries.",
      "You are deciding whether RSM/PCM or bounded GPCM should be operational, sensitivity-only, or deferred."
    ),
    TypicalInput = c(
      "none",
      "mfrm_fit plus diagnostics and optional bias/linking objects",
      "mfrm_fit plus optional diagnostics, G/D-study, bias, resampling, or hierarchy objects",
      "mfrm_fit, or a previously computed mfrm_generalizability object",
      "none or mfrm_fit depending on the follow-up helper",
      "none for template; fit/checklist for run-specific availability",
      "one or more mfrm_fit objects"
    ),
    NextStep = c(
      "Mark which required rows are answered by the study protocol versus package output.",
      "Resolve high-priority DraftReady = FALSE rows before writing results.",
      "Report the audit as workflow coverage and caution evidence, not as a pass/fail validity decision.",
      "Run the design check before interpreting interactions; report G/Phi as observed-score G-theory complements.",
      "Use the crosswalk first, then feature/visual coverage for actual implementation boundaries.",
      "Choose a figure only when the helper is available for the current run and the caption states its diagnostic role.",
      "Tie model-choice language to score interpretation and report bounded-GPCM gains as sensitivity evidence unless operationally justified."
    ),
    GPCMStatus = c(
      "supported",
      "supported_with_caveat",
      "supported_with_caveat",
      "observed_score_complement_supported_with_caveat",
      "graph_only_or_blocked_by_score_side_semantics",
      "supported_with_caveat",
      "supported_with_caveat"
    ),
    Notes = c(
      "This is the best starting point for a critical psychometric review.",
      "Fit-specific checklist rows show availability, caveats, and next actions.",
      "The audit helps avoid turning diagnostics into standalone validity decisions.",
      "G-study and D-study evidence answers design-generalizability questions, not fitted-logit reliability or validity questions.",
      "FACETS-style wording remains a migration contract, not numerical equivalence.",
      "Visual evidence should be selected from the reporting question, not from plot availability alone.",
      "Fit improvement alone is not enough when equal contribution is part of the score interpretation."
    ),
    stringsAsFactors = FALSE
  )

  user_pathway_rows <- data.frame(
    Scope = c(
      "facets", "facets", "facets", "facets", "facets", "facets", "facets",
      "facets", "facets", "facets", "facets", "facets",
      "conquest", "conquest", "conquest",
      "r", "r", "r", "r"
    ),
    Question = c(
      "State the FACETS relationship before using FACETS-style routes",
      "Translate FACETS table, file, graph, and command terms",
      "Translate FACETS direct and group anchor blocks",
      "Review anchor drift across forms, raters, or waves",
      "List fit measures and misfit flags by facet",
      "Explain FACETS df and ZSTD conversion",
      "Bring an external FACETS fit table into the review",
      "Review rating-scale categories, fair averages, and expected curves",
      "Review FACETS Table 14-style bias and interaction signals",
      "Draw a Wright map / variable map on the common logit scale",
      "Check score support and rater response patterns before fitting claims",
      "Write residual and subset files for external review",
      "Prepare a scoped ConQuest overlap case",
      "Compare extracted ConQuest tables after the external run",
      "State where mfrmr is less free than ConQuest",
      "Reuse plotting data for custom graphics",
      "Start from data-quality plot data for QC dashboards",
      "Reuse response-time plot data for custom QC graphics",
      "Combine tables and plot data for reports"
    ),
    OutputFamily = c(
      "compatibility", "compatibility", "review", "review", "table", "review", "review",
      "table", "review", "plot-data", "report",
      "export",
      "compatibility", "review", "compatibility",
      "plot-data", "plot-data", "plot-data", "bundle"
    ),
    MainFunction = c(
      "facets_positioning_guide(); facets_feature_coverage(); facets_visual_contract(); run_mfrm_facets(); mfrmRFacets(); facets_output_file_bundle()",
      "facets_term_crosswalk(); facets_feature_coverage(); facets_visual_contract()",
      "review_mfrm_anchors(); make_anchor_table(); anchor_linking_contract(); fit_mfrm(anchors = ..., group_anchors = ...)",
      "anchor_to_baseline(); detect_anchor_drift(); build_equating_chain(); plot_anchor_drift()",
      "fit_measures_table(); facets_chisq_table(); displacement_table()",
      "facets_fit_df_guide(); diagnose_mfrm(fit_df_method = \"both\")",
      "read_facets_fit_table(); facets_fit_review(); plot(..., type = \"df_sensitivity\")",
      "rating_scale_table(); category_structure_report(); category_curves_report(); fair_average_table(); plot_fair_average()",
      "mfrm_results(fit, include = \"bias\"); estimate_bias(); bias_interaction_report(); bias_pairwise_report(); plot_bias_interaction()",
      "facets_visual_contract(); plot(fit, type = \"wright\"); plot_wright_unified(); plot_data(type = \"wright\")",
      "data_quality_report(); plot(..., type = \"dashboard\")",
      "write_mfrm_residual_file(); write_mfrm_subset_file(); facets_output_file_bundle()",
      "build_conquest_overlap_bundle()",
      "normalize_conquest_overlap_files(); review_conquest_overlap()",
      "reporting_checklist(); reference_case_benchmark()",
      "facets_visual_contract(); mfrm_results(fit, include = \"misfit_review\"); mfrmr_interval_guide(); plot_data_components(); plot_data(); plot(..., draw = FALSE); plot(fit, type = \"pathway\", draw = FALSE); plot_data(category_curves_report(...), component = \"plot_long\"); plot_bias_interaction(..., draw = FALSE); plot_information(..., draw = FALSE)",
      "plot_data(data_quality_report(...), type = \"dashboard\")",
      "response_time_review(); plot_response_time_review(..., draw = FALSE); plot_data_components(); plot_data()",
      "build_summary_table_bundle(); build_visual_summaries()"
    ),
    UseWhen = c(
      "You want to prevent FACETS-complete-reproduction wording while still using familiar names, coverage maps, fixed files, or graphfile-style handoff.",
      "You or a reviewer is searching with FACETS words such as Measure, S.E., ZSTD, Table 8, Graphfile, Anchorfile, or Rating Scale=.",
      "You are translating FACETS D/A or D/G anchor blocks before fitting.",
      "You need to screen common-element drift across administrations, forms, raters, or waves.",
      "You want a Table 7-like view of measures, standard errors, and fit status.",
      "You need to show whether a ZSTD difference is caused by df convention rather than MnSq.",
      "You have already extracted a FACETS fit table and want a df/ZSTD-sensitive side-by-side review.",
      "You want FACETS Table 8/category and Table 12 fair-average style evidence.",
      "You want a FACETS Table 14-like route for local interaction-bias screening.",
      "You want a variable-map view of persons, facet levels, and step thresholds.",
      "You want a pre-interpretation QC screen for zero categories, dominant raters, or dropped rows.",
      "You need standalone residual rows or connected-subset membership files for a reviewer, spreadsheet, or external QC workflow.",
      "You need the narrow documented MML latent-regression overlap bundle.",
      "You have external ConQuest output tables already extracted to rectangular files.",
      "You need to explain why a ConQuest command-file workflow is not interchangeable with this package.",
      "You want to draw your own ggplot2/base/plotly figure from package plot data.",
      "You want the dashboard tables without accepting the package's default base-R drawing.",
      "You have response-time metadata and want reusable timing tables for ggplot2, plotly, Quarto, or dashboard QC views.",
      "You need stable data frames and reusable plot-data objects for an R Markdown or Quarto report."
    ),
    TypicalInput = c(
      "mfrm_fit or run_mfrm_facets() output",
      "none",
      "raw data plus anchor and/or group-anchor tables",
      "baseline anchors, baseline fit, new data, or a list of fitted waves",
      "mfrm_fit plus optional diagnostics",
      "mfrm_fit, mfrm_diagnostics, or a fit-measures/review table",
      "mfrm_fit plus extracted FACETS table",
      "mfrm_fit plus optional diagnostics",
      "mfrm_fit plus diagnostics",
      "mfrm_fit",
      "mfrm_fit plus optional raw data",
      "mfrm_fit plus optional diagnostics",
      "eligible MML RSM/PCM fit",
      "ConQuest population, item, and case tables plus the overlap bundle",
      "mfrm_fit plus optional diagnostics or benchmark request",
      "mfrm_plot_data or any mfrmr object with a plot method",
      "mfrm_data_quality bundle",
      "mfrm_response_time_review or long-format rating-event data",
      "summary/checklist/report/review objects"
    ),
    NextStep = c(
      "Start with facets_positioning_guide(), then use native mfrmr objects for inference and FACETS-style files for handoff layout.",
      "Use the term crosswalk for vocabulary first; use feature and visual coverage only after the term has been located.",
      "Review issue_counts and recommendations before choosing anchor_policy for fit_mfrm().",
      "Check drift flags and link residuals before treating linked measures as comparable.",
      "Use threshold profiles to show how underfit/overfit rates depend on the chosen band.",
      "Compare MnSq first, then df, then ZSTD; label convention-sensitive flags explicitly.",
      "Normalize the external table first, then inspect df_sensitivity, df_sensitive, and external_comparison.",
      "Check zero/sparse categories and threshold ordering before reporting fair averages.",
      "Use estimate_bias() for screening, bias_interaction_report() for ranked cells, and bias_pairwise_report() for pairwise contrasts.",
      "Use facets_visual_contract() to map FACETS Table 6/8/Graph-menu expectations first; use draw = FALSE or plot_data(type = \"wright\") when you need reusable coordinates for custom graphics.",
      "Resolve severe QC flags before interpreting fit or fairness outputs.",
      "Keep residual, subset, and graph/score files distinct; use the native writers unless a legacy graph/score contract is required.",
      "Run ConQuest externally and keep the generated command text as a conservative template.",
      "Review missing/non-numeric/status rows before treating differences as numerical evidence.",
      "Document that mfrmr currently exposes selected overlap checks, not the full ConQuest modeling language.",
      "Start with facets_visual_contract() and plot_data_components(); for interval-aware figures use mfrmr_interval_guide(); for pathway maps use pathway_long/pathway_annotations/fit_measures; for category, bias, and information plots use plot_long plus annotations/settings.",
      "Use component names such as quality_flags, category_usage_by_facet, and facet_response_patterns.",
      "Use the table, thresholds, overview, and notes components; keep timing interpretation descriptive unless a separate speed-accuracy model is fitted.",
      "Keep table objects and plot-data objects separate so custom reporting remains reproducible."
    ),
    GPCMStatus = c(
      "graph_only_or_blocked_by_score_side_semantics",
      "graph_only_or_blocked_by_score_side_semantics",
      "supported_with_caveat",
      "supported_with_caveat; exploratory_gpcm_linking_review",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported",
      "supported",
      "blocked_for_gpcm; rsm_pcm_overlap_only",
      "blocked_for_gpcm; rsm_pcm_overlap_only",
      "blocked_for_gpcm; rsm_pcm_overlap_only",
      "supported",
      "supported",
      "supported",
      "supported_for_direct_outputs"
    ),
    Notes = c(
      "mfrmr is not a FACETS numerical clone; familiar names help transition, but estimates remain package-native unless external output is supplied.",
      "The crosswalk is a terminology guide, not an equivalence claim.",
      "Direct anchors fix element logits; group anchors constrain a group mean, with direct anchors taking precedence.",
      "Operational linking conclusions remain RSM/PCM-scoped; bounded GPCM linking review is caveated exploratory synthesis.",
      "Closest current route for FACETS users who expect fit measures in one table.",
      "The guide explains engine df, FACETS-style df, Wilson-Hilferty ZSTD, and WHEXACT caveats.",
      "This is a review of supplied rectangular output, not raw FACETS text parsing; use df_sensitive for convention-sensitive rows.",
      "GPCM fair averages are slope-aware direct outputs, not FACETS score-side equivalence.",
      "Bias outputs are conditional screening layers; use substantive review before fairness conclusions.",
      "Wright maps visualize fitted scale locations; under bounded GPCM, interpret step/threshold locations with slope-aware caveats.",
      "Designed to catch user-visible data problems before fit interpretation.",
      "Residual and subset writers are package-native CSV/TSV handoff routes, not exact FACETS fixed-field command-file clones.",
      "ConQuest support is intentionally scoped to a documented comparison case.",
      "The helper reads extracted tables, not raw ConQuest report text.",
      "Use this row when reporting scope differences to ConQuest users.",
      "Best R-first route for users who want full control over graphics, interval-aware displays, fit-annotated pathway maps, bias-screening views, and TIF/conditional-SEM plots.",
      "The accessor avoids depending on the underlying object structure in user scripts.",
      "Response-time plot data are a QC display contract, not a measurement-model extension.",
      "Use this path for Quarto/R Markdown pipelines and downstream custom tables."
    ),
    stringsAsFactors = FALSE
  )

  out <- rbind(public_rows, beginner_rows, entry_rows, viewer_rows, binary_rows, out,
               linking_rows, advanced_rows, gpcm_rows, psychometric_rows,
               user_pathway_rows)
  out$Lifecycle <- "stable"
  out$Lifecycle[out$OutputFamily %in% "compatibility" | out$Scope %in% c("compatibility", "facets", "conquest")] <- "compatibility"
  out$Lifecycle[out$Scope %in% c("simulation", "network")] <- "advanced"
  out$UserLevel <- "intermediate"
  out$UserLevel[out$Scope %in% c("public", "beginner", "entry", "viewer", "binary")] <- "beginner"
  out$UserLevel[out$Scope %in% c("simulation", "network", "reviews", "psychometric")] <- "advanced"
  out$UserLevel[out$Scope %in% c("compatibility", "facets", "conquest")] <- "migration"
  out$APILayer <- "specialist_component"
  out$APILayer[out$Scope %in% "public"] <- "top_level_public_surface"
  out$APILayer[out$Scope %in% c("beginner", "entry", "viewer", "binary")] <- "recommended_entry_route"
  out$APILayer[out$Scope %in% c("reports", "reviews", "tables", "bundles", "exports", "linking", "gpcm", "psychometric")] <- "specialist_followup"
  out$APILayer[out$Scope %in% c("simulation", "network")] <- "advanced_design_review"
  out$APILayer[out$Scope %in% c("compatibility", "facets", "conquest", "r")] <- "migration_or_integration"
  out$ObjectRole <- "specialist evidence component"
  out$ObjectRole[out$OutputFamily %in% "table"] <- "focused evidence table"
  out$ObjectRole[out$OutputFamily %in% "report"] <- "reporting evidence bundle"
  out$ObjectRole[out$OutputFamily %in% "review"] <- "review and follow-up surface"
  out$ObjectRole[out$OutputFamily %in% "bundle"] <- "handoff table bundle"
  out$ObjectRole[out$OutputFamily %in% "export"] <- "file export surface"
  out$ObjectRole[out$OutputFamily %in% "viewer"] <- "local reader over existing results"
  out$ObjectRole[out$OutputFamily %in% "guide"] <- "route-selection guide"
  out$ObjectRole[out$OutputFamily %in% "compatibility"] <- "compatibility presentation contract"
  out$ObjectRole[grepl("mfrm_results(", out$MainFunction, fixed = TRUE)] <- "comprehensive result object"
  out$ObjectRole[grepl("fit_mfrm", out$MainFunction, fixed = TRUE)] <- "model estimation and result-object entry"
  out$ObjectRole[grepl("mfrm_report", out$MainFunction, fixed = TRUE)] <- "report-readiness surface"
  out$ObjectRole[grepl("launch_mfrmr_viewer", out$MainFunction, fixed = TRUE)] <- "local reader over existing results"
  out$ObjectRole[grepl("export_", out$MainFunction, fixed = TRUE)] <- "file export surface"
  out$ObjectRole[grepl("mfrmr_output_guide", out$MainFunction, fixed = TRUE)] <- "route-selection guide"
  out$ObjectRole[grepl("gpcm_runtime_guard_coverage", out$MainFunction, fixed = TRUE)] <- "out-of-scope route-status table"
  out$ObjectRole[grepl("mfrm_results_interactive", out$MainFunction, fixed = TRUE)] <- "explicit opt-in interactive entry"

  out$DecisionBoundary <- "Specialist follow-up: inspect the source object and help page before treating output as report evidence."
  out$DecisionBoundary[out$ObjectRole %in% "model estimation and result-object entry"] <-
    "Fits model parameters first; diagnostics, reporting, and validity claims are separate follow-up steps."
  out$DecisionBoundary[out$ObjectRole %in% "comprehensive result object"] <-
    "Collects existing fit, diagnostic, table, reporting, and plot surfaces; it is not a new estimator or pass/fail decision."
  out$DecisionBoundary[out$ObjectRole %in% "report-readiness surface"] <-
    "Summarizes report readiness and wording routes; it does not recompute diagnostics or create an acceptance rule."
  out$DecisionBoundary[out$ObjectRole %in% "local reader over existing results"] <-
    "Displays an existing mfrm_results object; it does not estimate models, load external web apps, or alter diagnostics."
  out$DecisionBoundary[out$ObjectRole %in% "file export surface"] <-
    "Writes already-created evidence to disk; it does not recompute or strengthen evidence."
  out$DecisionBoundary[out$ObjectRole %in% "route-selection guide"] <-
    "Chooses the next help route; it is not analysis evidence."
  out$DecisionBoundary[out$ObjectRole %in% "out-of-scope route-status table"] <-
    "Explains supported-with-caveat, blocked, and deferred bounded-GPCM route handling; it does not broaden any route beyond its current capability row."
  out$DecisionBoundary[out$ObjectRole %in% "explicit opt-in interactive entry"] <-
    "Collects column choices interactively; move replay code into an explicit script before reporting."
  out$DecisionBoundary[grepl("precision", out$MainFunction, ignore.case = TRUE)] <-
    "Precision and separation evidence are not inter-rater agreement or standalone validity proof."
  out$DecisionBoundary[grepl("response_time", out$MainFunction, fixed = TRUE)] <-
    "Response-time outputs are descriptive QC context; they do not alter MFRM estimates, fit a joint speed-accuracy model, or create automatic exclusion rules."
  out$DecisionBoundary[grepl("bias|DFF|dff|DIF|dif", out$MainFunction, ignore.case = TRUE)] <-
    "Bias, DFF, and DIF rows are screening prompts; they are not final fairness conclusions without follow-up design and substantive review."
  out$DecisionBoundary[grepl("anchor|drift|linking|equating", out$MainFunction, ignore.case = TRUE)] <-
    "Anchor and linking evidence support scale-maintenance review; drift and equating claims require explicit multi-fit wave or form designs."
  out$DecisionBoundary[out$Scope %in% c("simulation", "network")] <-
    "Design, network, or operating-characteristic evidence informs planning and review; it is not an observed-data validity decision by itself."
  out$DecisionBoundary[out$Scope %in% "psychometric"] <-
    "Reviewer-facing routes organize required evidence and caveats; they do not certify validity, fairness, or operational use by themselves."
  out$DecisionBoundary[out$Scope %in% c("compatibility", "facets", "conquest")] <-
    "Compatibility rows are presentation or migration contracts, not numerical equivalence claims unless external outputs are explicitly compared."

  out$RecommendedEntry <- out$Scope %in% c("public", "beginner", "entry", "viewer", "binary")
  out <- out[, c(
    "Scope", "Question", "OutputFamily", "Lifecycle", "UserLevel",
    "APILayer", "ObjectRole", "DecisionBoundary", "RecommendedEntry",
    "MainFunction", "UseWhen", "TypicalInput", "NextStep", "GPCMStatus",
    "Notes"
  ), drop = FALSE]

  if (identical(scope, "all")) {
    return(out)
  }
  if (identical(scope, "gpcm")) {
    keep <- out$GPCMStatus != "supported" |
      grepl("GPCM|gpcm", out$Question, ignore.case = TRUE) |
      grepl("GPCM|gpcm", out$Notes, ignore.case = TRUE)
    return(out[keep, , drop = FALSE])
  }
  if (identical(scope, "response_time")) {
    haystack <- paste(out$Question, out$MainFunction, out$UseWhen,
                      out$NextStep, out$Notes)
    keep <- grepl("response[-_ ]time|timing", haystack, ignore.case = TRUE)
    return(out[keep, , drop = FALSE])
  }
  out[out$Scope == scope, , drop = FALSE]
}
