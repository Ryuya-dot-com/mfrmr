#' mfrmr Reports, Tables and Exports
#'
#' @description
#' Choose a reusable result bundle and the files needed for reporting. The
#' reporting tutorial provides the complete fit-to-manuscript workflow;
#' [mfrmr_reporting_and_apa] identifies the writing and table-formatting tools.
#'
#' @section Recommended report route:
#' For supported ordinary RSM/PCM MML/JML fits, create [mfrm_results()] and
#' read `summary(res)$triage`. Supply matching diagnostics when reusing an
#' existing analysis. [mfrm_report()] renders stored evidence; it does not turn
#' unavailable diagnostics into valid results. Other estimators use their own
#' supported result/report methods; consult [gpcm_capability_matrix()] for GPCM.
#'
#' @section Choose what to save:
#' | Need | Function or format |
#' | --- | --- |
#' | Preserve the complete result and settings | [base::saveRDS()] / [base::readRDS()] |
#' | Core fitted-model CSV tables | [export_mfrm_tables()]; supplied matching diagnostics enrich them without automatic computation |
#' | Selected tables from a consolidated result | [export_mfrm_results()] |
#' | Reusable analysis handoff | [export_mfrm_bundle()] |
#' | Reader-facing HTML | [mfrm_report()] |
#' | Editable tables and draft manuscript text | [mfrmr_reporting_and_apa] |
#'
#' Keep the model/estimator, score coding, weights, denominator and uncertainty
#' method with exported values. NA/status/reason fields explain unavailable
#' results and must not be replaced with zero. A CSV or figure alone does not
#' preserve the full analysis. [mfrmr_compatibility_layer] explains when old
#' derived results need recomputation rather than redisplay or refitting.
#'
#' @section Assessment plans and specialist results:
#' G/D-study summaries and plots use the saved design and interval assumptions;
#' they are not ordinary fit diagnostics. Use [summary.mfrm_multivariate_d_study()]
#' and its documented interval arguments when reporting plan uncertainty.
#' For other result types, select a route with [mfrmr_output_guide()] and open
#' the source function's help. [mfrmr_visual_diagnostics] covers figure choice.
#' @examples
#' # Long-running workflow; run explicitly when needed.
#' # example("mfrmr_reports_and_tables", run.dontrun = TRUE)
#' \dontrun{
#' # Load the package and example ratings
#' library(mfrmr)
#' ratings <- load_mfrmr_data("example_operational")
#'
#' # Fit the model
#' fit <- fit_mfrm(
#'   data = ratings,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   rating_min = 1, rating_max = 4, category_policy = "preserve",
#'   method = "MML",
#'   model = "RSM"
#' )
#'
#' summary(fit)$decision # Review the fit before interpreting it
#'
#' # Build the comprehensive results and report
#' res <- mfrm_results(fit)
#' report <- mfrm_report(res)
#' summary(report, view = "reader")
#'
#' # Find report sections that need attention
#' report$first_screen[, c("Area", "Status", "MainIssue", "NextAction")]
#'
#' # Extract individual person, rater, and criterion estimates
#' estimates <- as.data.frame(fit)
#' head(subset(estimates, Facet == "Person")) # First six persons
#' subset(estimates, Facet == "Rater")       # All raters
#' subset(estimates, Facet == "Criterion")   # All criteria
#'
#' # Keep the full result, including methods and unavailable-output reasons
#' file <- tempfile(fileext = ".rds") # Choose a lasting path for your analysis
#' saveRDS(res, file)
#' saved <- readRDS(file)
#' summary(saved)$triage # No refitting or repeated diagnostic calculation
#' }
#' @name mfrmr_reports_and_tables
NULL

#' Choose an mfrmr output helper by user goal
#'
#' @description
#' Find a function for the next question in your analysis. Start with
#' `mfrmr_output_guide("beginner")` and read its `Question` and `MainFunction`
#' columns. With no argument the function returns the full specialist catalogue,
#' which includes tables, reports, reviews and exports. It does not analyze data.
#'
#' @param scope Which rows to return. `"all"` returns the full route catalogue.
#'   `"plots"` returns a separate purpose-based plot capability table (see below).
#'   `"public"` returns the canonical six-step route for most users;
#'   `"beginner"` returns the same compact route rather than combining every
#'   beginner-labelled specialist row.
#'   `"entry"` returns the recommended first-screen routes. `"viewer"` returns
#'   local-viewer routes built around `mfrm_results(include = ...)`. `"binary"`
#'   returns the two-category person-item Rasch route and checks. Other values
#'   filter to one output family or to `GPCM`-relevant routes.
#'   `"linking"` returns anchor, drift, equating and DIF sensitivity routes.
#'   `"calibration"` returns the portable fixed-calibration lifecycle and
#'   artifact-only scoring route, conditional decisions and fixed-plan
#'   classification accuracy/consistency.
#'   `"simulation"` and `"network"` return advanced design-review rows.
#'   `"response_time"` returns descriptive response-time QC rows.
#'   `"models"` compares fixed-facet, shared-rater and Person-specific testlet
#'   workflows, including their distinct prediction and reporting boundaries.
#'   `"feedback"` distinguishes fixed-rater uncertainty, unexpected rating
#'   patterns, shared-rater uncertainty, observed agreement, centrality,
#'   criterion-referenced accuracy and screening accuracy with known truth.
#'   `"features"`, `"imputation"` and `"gtheory"` show exploratory attributes,
#'   assigned-score multiple imputation and observed-score G/D-study workflows,
#'   including their own table, plot and saving routes.
#'   `"facets"`, `"conquest"`, and `"r"` return user-pathway rows for people
#'   arriving from those workflows.
#'
#' @details
#' Read `Question` and `UseWhen`, then open the help for `MainFunction`.
#' `TypicalInput` identifies the required object and `NextStep` its continuation.
#' `DecisionBoundary` and `Notes` describe the limit of the route; a listed
#' function does not imply that every model can use it.
#'
#' `scope = "beginner"` selects starting routes; other scopes select a topic or
#' output family. Names ending in `_table`, `_report`, `_review` or `_bundle`
#' describe the role of the result, not interchangeable input classes.
#'
#' @section Choosing a figure:
#' For `scope = "plots"`, read `Question`, `InputClass`, `PlotCall` and
#' `DataComponent`. Compute the required result first and call its `plot()`
#' method. The table is a curated map, not an inventory of every plot type.
#' See [mfrmr_visual_diagnostics] for interpretation and editing; plot-method
#' help specifies the supported arguments and return contract.
#'
#' @section Model-specific support:
#' The basic fit/results/report route covers supported ordinary RSM/PCM fits.
#' GPCM, CML, corrected JML and extended models have different downstream
#' support. Check [gpcm_capability_matrix()] and the result class's help before reusing a
#' route. [mfrmr_workflow_methods] connects the main objects; numerical and
#' uncertainty conditions belong to the function that computes the result.
#' @return For `scope = "plots"`, a data.frame with `Question`, `InputClass`,
#'   `PlotCall`, `PlotName` (the name in the saved plot data), `DataComponent`,
#'   `GGPlot`, `GGPlotCall` (`NA` when unavailable), `Notes`, `ResultFunction`
#'   and `NextStep`.
#'   All other scopes return a data.frame with one row per route and columns:
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
#' beginner <- mfrmr_output_guide("beginner")
#' beginner[, c("Question", "MainFunction", "NextStep")]
#'
#' # Ask for a specialist map only when that question arises.
#' linking <- mfrmr_output_guide("linking")
#' linking[, c("Question", "MainFunction", "UseWhen")]
#'
#' feedback <- mfrmr_output_guide("feedback")
#' feedback[, c("Question", "MainFunction", "DecisionBoundary")]
#'
#' figures <- mfrmr_output_guide("plots")
#' figures[, c("Question", "ResultFunction", "GGPlot")]
#' @concept reporting workflow
#' @concept route selection
#' @concept GPCM boundaries
#' @export
mfrmr_output_guide <- function(scope = c("all", "public", "beginner", "psychometric",
                                         "entry", "viewer", "binary", "tables", "reports", "reviews",
                                         "bundles", "exports", "compatibility",
                                         "gpcm", "calibration", "simulation", "linking", "network",
                                         "response_time", "facets", "conquest", "r", "models",
                                         "features", "imputation", "gtheory", "feedback", "plots")) {
  scope <- match.arg(scope)
  if (identical(scope, "plots")) return(.mfrmr_plot_guide())

  out <- .mfrmr_table_mfrmr_output_guide_out

  public_rows <- .mfrmr_table_mfrmr_output_guide_public_rows

  calibration_rows <- .mfrmr_table_mfrmr_output_guide_calibration_rows

  entry_rows <- .mfrmr_table_mfrmr_output_guide_entry_rows

  viewer_rows <- .mfrmr_table_mfrmr_output_guide_viewer_rows

  binary_rows <- .mfrmr_table_mfrmr_output_guide_binary_rows

  linking_rows <- .mfrmr_table_mfrmr_output_guide_linking_rows

  advanced_rows <- .mfrmr_table_mfrmr_output_guide_advanced_rows

  gpcm_rows <- .mfrmr_table_mfrmr_output_guide_gpcm_rows

  migration_entry_rows <- .mfrmr_table_mfrmr_output_guide_migration_entry_rows

  user_pathway_rows <- .mfrmr_table_mfrmr_output_guide_user_pathway_rows

  model_rows <- .mfrmr_table_mfrmr_output_guide_model_rows

  workflow_rows <- .mfrmr_table_mfrmr_output_guide_workflow_rows

  feedback_rows <- .mfrmr_table_mfrmr_output_guide_feedback_rows

  feedback_rows <- rbind(feedback_rows, .mfrmr_table_mfrmr_output_guide_data)

  calibration_rows <- rbind(calibration_rows, .mfrmr_table_mfrmr_output_guide_data_1)

  rating_evaluation_rows <- .mfrmr_table_mfrmr_output_guide_rating_evaluation_rows

  model_export_row <- .mfrmr_table_mfrmr_output_guide_model_export_row

  workflow_rows <- rbind(workflow_rows, .mfrmr_table_mfrmr_output_guide_data_2)

  network_rows <- .mfrmr_table_mfrmr_output_guide_network_rows

  out <- rbind(
    public_rows, calibration_rows, entry_rows, viewer_rows, binary_rows, out, linking_rows,
    advanced_rows, gpcm_rows, migration_entry_rows, user_pathway_rows, model_rows, workflow_rows,
    feedback_rows, rating_evaluation_rows, model_export_row, network_rows
  )
  out$Lifecycle <- "stable"
  out$Lifecycle[out$OutputFamily %in% "compatibility" | out$Scope %in% c("compatibility", "facets", "conquest")] <- "compatibility"
  out$Lifecycle[out$Scope %in% c("simulation", "network")] <- "advanced"
  out$UserLevel <- "intermediate"
  out$UserLevel[out$Scope %in% c("public", "calibration", "entry", "viewer", "binary")] <- "beginner"
  out$UserLevel[out$Scope %in% c("simulation", "network", "reviews")] <- "advanced"
  out$UserLevel[out$Scope %in% c("compatibility", "facets", "conquest")] <- "migration"
  out$APILayer <- "specialist_component"
  out$APILayer[out$Scope %in% "public"] <- "top_level_public_surface"
  out$APILayer[out$Scope %in% c("calibration", "entry", "viewer", "binary")] <- "recommended_entry_route"
  out$APILayer[out$Scope %in% c("reports", "reviews", "tables", "bundles", "exports", "linking", "gpcm")] <- "specialist_followup"
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
  out$ObjectRole[grepl("view = 'unavailable'", out$MainFunction, fixed = TRUE)] <- "unavailable-route alternatives"
  out$ObjectRole[grepl("mfrm_calibration_capabilities", out$MainFunction, fixed = TRUE)] <- "route-selection guide"
  out$ObjectRole[grepl("extract_mfrm_calibration", out$MainFunction, fixed = TRUE)] <- "portable calibration lifecycle"
  out$ObjectRole[grepl("save_mfrm_calibration", out$MainFunction, fixed = TRUE)] <- "calibration persistence"
  out$ObjectRole[grepl("score_mfrm_calibration", out$MainFunction, fixed = TRUE)] <- "artifact-only posterior scoring"
  out$ObjectRole[grepl("summary(scores)", out$MainFunction, fixed = TRUE)] <- "portable score-batch review"
  out$ObjectRole[grepl("with cut_scores", out$MainFunction, fixed = TRUE)] <- "conditional ability decisions"
  out$ObjectRole[grepl("mfrm_results_interactive", out$MainFunction, fixed = TRUE)] <- "explicit opt-in interactive entry"
  out$ObjectRole[grepl('summary(fit, profile = "fit"', out$MainFunction, fixed = TRUE)] <- "fit summary surface"
  out$ObjectRole[grepl('summary(fit, profile = "facets"', out$MainFunction, fixed = TRUE)] <- "comprehensive result object"

  out$DecisionBoundary <- "Specialist follow-up: inspect the source object and help page before treating output as report evidence."
  out$DecisionBoundary[out$ObjectRole == "conditional ability decisions"] <-
    "Posterior event probabilities conditional on point calibration, scoring prior and supplied cuts; no automatic decision rule or calibration uncertainty."
  out$DecisionBoundary[out$ObjectRole %in% "model estimation and result-object entry"] <-
    "Fits model parameters first; diagnostics, reporting, and validity claims are separate follow-up steps."
  out$DecisionBoundary[out$ObjectRole %in% "fit summary surface"] <-
    "Summarizes fit status and settings without computing comprehensive diagnostics or making a reporting decision."
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
    "Explains supported-with-caveat, blocked, and deferred GPCM route handling; it does not broaden any route beyond its current capability row."
  out$DecisionBoundary[out$ObjectRole %in% "explicit opt-in interactive entry"] <-
    "Collects column choices interactively; move replay code into an explicit script before reporting."
  out$DecisionBoundary[out$ObjectRole %in% "portable calibration lifecycle"] <-
    "Creates fixed-standard-normal RSM/PCM MML, conditional estimated-normal one-family or experimental fixed-standard-normal two-family GPCM MML, or reference-prior RSM/PCM and shared-owner GPCM JML artifacts within their documented scope; incomplete GPCM global audits remain recorded. Every refusal must be resolved before freezing."
  out$DecisionBoundary[out$ObjectRole %in% "calibration persistence"] <-
    "Preserves and validates a calibration lifecycle object; loading is not authentication of an untrusted file."
  out$DecisionBoundary[out$ObjectRole %in% "artifact-only posterior scoring"] <-
    paste(
      "Returns posterior EAP uncertainty conditional on the frozen point",
      "calibration and recorded prior, excludes calibration-parameter",
      "uncertainty, and performs no refit."
    )
  out$DecisionBoundary[out$ObjectRole %in% "portable score-batch review"] <-
    paste(
      "Reviews score dispositions and conditional uncertainty; it does not",
      "establish source-fit quality, reliability, transport, or validity."
    )
  out$DecisionBoundary[grepl("precision", out$MainFunction, ignore.case = TRUE)] <-
    "Precision and separation evidence are not inter-rater agreement or standalone validity proof."
  out$DecisionBoundary[grepl("response_time", out$MainFunction, fixed = TRUE)] <-
    "Response-time outputs are descriptive QC context; they do not alter MFRM estimates, fit a joint speed-accuracy model, or create automatic exclusion rules."
  out$DecisionBoundary[grepl("bias|DFF|dff", out$MainFunction, ignore.case = TRUE)] <-
    "Bias and DFF rows are screening prompts; they are not final fairness conclusions without follow-up design and substantive review."
  out$DecisionBoundary[grepl("anchor|drift|linking|equating", out$MainFunction, ignore.case = TRUE)] <-
    "Anchor and linking evidence support scale-maintenance review; drift and equating claims require explicit multi-fit wave or form designs."
  out$DecisionBoundary[out$Scope %in% c("simulation", "network")] <-
    "Design, network, or operating-characteristic evidence informs planning and review; it is not an observed-data validity decision by itself."
  out$DecisionBoundary[out$Scope %in% c("compatibility", "facets", "conquest")] <-
    "Compatibility rows are presentation or migration contracts, not numerical equivalence claims unless external outputs are explicitly compared."

  out$RecommendedEntry <- out$Scope %in% c("public", "calibration", "entry", "viewer", "binary")
  dedicated <- out$Scope %in% c("features", "imputation", "gtheory")
  rating_evaluation <- out$MainFunction %in% rating_evaluation_rows$MainFunction
  targeted <- dedicated | rating_evaluation | out$Scope %in% c("models", "feedback")
  out$DecisionBoundary[targeted] <- out$Notes[targeted]
  batch_bias <- grepl("estimate_all_bias()", out$MainFunction, fixed = TRUE)
  out$DecisionBoundary[batch_bias] <- out$Notes[batch_bias]
  model_export <- out$MainFunction == model_export_row$MainFunction
  out$ObjectRole[model_export] <- "external model and saved posterior summary workflow"
  out$DecisionBoundary[model_export] <- out$Notes[model_export]
  out$ObjectRole[dedicated] <- "dedicated analysis and saved-output workflow"
  out$ObjectRole[out$Scope == "feedback"] <- "rater-feedback route selection"
  out$APILayer[out$Scope == "feedback"] <- "specialist_followup"
  out$Lifecycle[dedicated] <- "advanced"
  out$Lifecycle[out$Scope == "models" & out$MainFunction != "fit_mfrm()"] <- "advanced"
  out <- out[, c(
    "Scope", "Question", "OutputFamily", "Lifecycle", "UserLevel",
    "APILayer", "ObjectRole", "DecisionBoundary", "RecommendedEntry",
    "MainFunction", "UseWhen", "TypicalInput", "NextStep", "GPCMStatus",
    "Notes"
  ), drop = FALSE]

  if (identical(scope, "all")) {
    return(out)
  }
  if (identical(scope, "beginner")) {
    return(out[out$Scope %in% "public", , drop = FALSE])
  }
  if (identical(scope, "psychometric")) {
    keep <- out$Scope %in% c("tables", "reports", "reviews", "linking") &
      out$ObjectRole %in% c(
        "focused evidence table", "reporting evidence bundle",
        "review and follow-up surface", "specialist evidence component"
      )
    return(out[keep | rating_evaluation, , drop = FALSE])
  }
  if (identical(scope, "gpcm")) {
    keep <- !out$GPCMStatus %in% c("supported", "not_applicable")
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
