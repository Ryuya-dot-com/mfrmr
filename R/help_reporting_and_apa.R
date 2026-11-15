#' mfrmr Reporting and APA Guide
#'
#' @description
#' Prepare a report from reviewed analysis objects. For the complete RSM lesson,
#' Methods/Results example and study-context checklist, use
#' `vignette("mfrmr-reporting-and-apa", package = "mfrmr")`.
#'
#' @section Choose the reporting task:
#' | Task | Route |
#' | --- | --- |
#' | Inspect an analysis and its missing evidence | [mfrm_results()], then `summary(res)$triage` and `$next_actions` |
#' | Produce an analyst report or one rater's feedback | [mfrm_report()]; the rater style requires the recipient's facet and identifier |
#' | Draft manuscript text and tables | [build_apa_outputs()], [build_summary_table_bundle()] and [apa_table()] |
#' | Check reporting gaps and uncertainty | [reporting_checklist()] and [precision_review_report()] |
#' | Save results or make a file bundle | [mfrmr_reports_and_tables] distinguishes RDS, results archives and fit-level exports |
#'
#' These are optional branches from the analysis. Save complete source objects
#' and attach only the diagnostics and intervals needed for the question.
#' For example, `mfrm_results(fit, diagnostics = diagnostics,
#' intervals = list(raters = ci), compute = "never")` retains existing results
#' without filling missing diagnostics. `plot(res, type = "facet_raters")`
#' uses the attached rater intervals; a Wright map does not acquire their method.
#' See [mfrm_results()] and [mfrm_report()] for the full save/reopen workflow.
#'
#' @section Supported analyses:
#' The consolidated route covers supported ordinary MML/JML RSM/PCM fits,
#' with estimator-specific inference limits. For native CML or comparison-only
#' fits, use `summary(fit)` and the supported [mfrm_facet_intervals()] route,
#' followed by `summary(ci)`, `plot(ci)`, [apa_table()] and `saveRDS()`.
#' Ordinary one-family GPCM has caveated APA/QC/export routes: retain
#' `gpcm_boundary` and consult [gpcm_capability_matrix()] for each helper's scope.
#' A report or scorefile does not itself qualify operational scoring.
#'
#' Use diagnostics from the same fitted analysis. Changing data, model or
#' estimation settings requires new matching diagnostics; identical labels
#' alone are insufficient. For old saved calculations, follow
#' [mfrmr_compatibility_layer] before rebuilding dependent reports.
#'
#' @section Model comparison and population reporting:
#' Use [compare_mfrm()] and read `ICComparable`, `ComparisonBasis` and nesting
#' warnings before reporting a ranking. [build_model_choice_review()] connects
#' eligible comparisons to model roles and optional weighting reviews. Integration,
#' likelihood and nesting requirements are specified in [compare_mfrm()];
#' an information criterion alone does not decide operational scoring.
#'
#' For latent regression, report `population_formula`, coding/contrasts,
#' `population_policy` and omissions alongside the summary's population tables.
#' These are conditional-normal population-model parameters, not a regression
#' on estimated Person scores. [fit_mfrm_technical_details] and
#' [mfrm_population_intervals()] define the supported model and inference;
#' [predict_mfrm_units()] and [sample_mfrm_plausible_values()] cover subsequent
#' scoring and draws.
#'
#' @section Editable GPCM report:
#' Copy `system.file("templates", "gpcm-report.Rmd", package = "mfrmr")`
#' and render the copy with [rmarkdown::render()]. Set `ratings_csv`,
#' `rating_min`, `rating_max` and `output_dir`. Input columns are Person, Rater,
#' Criterion and Score, with one rating per cell; repeated occasions require
#' explicit measurement units and agreement keys. The template fits one-family
#' GPCM MML with criterion-owned steps/slopes. Its observed ordinal alpha is
#' calculated separately; [mfrm_report()] does not add that statistic automatically.
#' Complete the context and interpretation prompts before using the draft.
#'
#' @section Review the manuscript, not just the output:
#' The helpers are APA-oriented drafting aids, informed by the APA Publication
#' Manual (7th ed.), JARS-Quant and the method-specific sources returned by
#' `reporting_checklist(..., include_references = TRUE)`. `DraftReady`,
#' `ReadyForAPA` and `ClaimStrength` organize drafting and caveats; they do not
#' certify validity, journal acceptance or research-level reporting completeness.
#' For an APA-style report, inspect `$first_screen`, `$claim_readiness`,
#' `$report_gaps` and `$template_index` before copying text.
#'
#' The author must supply and verify the research question, design, recruitment,
#' ethics, sample-size rationale, missingness/exclusions, multiplicity, departures
#' from plan and data/code availability. Choose effect sizes, uncertainty and
#' rounding for the claims. The reporting vignette distinguishes those obligations
#' from what the package can extract. Analyst archives retain source identifiers
#' and data; inspect exported files before sharing them as feedback or supplements.
#'
#' Appelbaum, M., et al. (2018). Journal article reporting standards for
#' quantitative research in psychology. *American Psychologist, 73*(1), 3-25.
#' \doi{10.1037/amp0000191}
#' @examples
#' # Long-running workflow; run explicitly when needed.
#' # example("mfrmr_reporting_and_apa", run.dontrun = TRUE)
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
#' # Check which report sections have supporting evidence
#' diagnostics <- diagnose_mfrm(fit)
#' checklist <- reporting_checklist(fit, diagnostics = diagnostics)
#' checklist$section_summary
#' subset(checklist$checklist, !DraftReady,
#'        c("Section", "Item", "NextAction"))
#'
#' # Format the per-facet distribution summary as a table
#' results <- summary(fit, diagnostics = diagnostics)
#' tbl <- apa_table(results, which = "facet_overview")
#' tbl # Prints the table, caption, and note; review them before using in a paper
#'
#' # For individual estimates, see as.data.frame(fit)
#' }
#' @name mfrmr_reporting_and_apa
NULL
