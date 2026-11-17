#' @aliases mfrmr_reports_and_tables
#' @rdname mfrmr_output_guide
#' @name mfrmr_reports_and_tables
NULL

#' Choose an mfrmr output helper by user goal
#'
#' @description
#' With no argument, return five central routes: data review, measurement,
#' diagnostics, assessment planning and reporting. Read `Question`,
#' `MainFunction` and `NextStep`. Use `scope = "all"` for the full specialist
#' catalogue. This guide selects a route; it does not analyze data.
#'
#' @param scope Which rows or companion matrix to return. The default,
#'   `"core_workflow"`, returns the five central routes. `"all"` returns the
#'   full route catalogue. `"plots"` returns a purpose-based plot capability
#'   table (see below). `"intervals"` returns the confidence-interval and
#'   uncertainty route guide; `"visual_templates"` returns the figure-reporting
#'   template; `"gpcm_capabilities"` returns the GPCM workflow/score/unavailable
#'   capability matrix (see [mfrmr_gpcm_scope]); and
#'   `"calibration_capabilities"` returns the portable fixed-calibration model
#'   and estimator capability matrix.
#'   `"public"` and `"beginner"` return the same six-row ordinary RSM/PCM
#'   measurement route. The default map includes observed-score G/D planning,
#'   which uses ratings directly and does not require an MFRM fit.
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
#' @param ... Optional sub-scope or filter arguments for specialist matrices:
#'   - `scope = "intervals"`: optional `category` (`"all"`, `"visual"`,
#'     `"table"`, `"reporting"`, `"fit"`, `"bias"`, `"linking"`, `"gpcm"`,
#'     `"equivalence"`, `"hierarchical"`, or `"shrinkage"`).
#'   - `scope = "visual_templates"`: optional `category` (`"all"`,
#'     `"manuscript"`, `"appendix"`, `"diagnostic"`, or `"surface"`).
#'   - `scope = "gpcm_capabilities"`: optional `status` and `view`
#'     (`"workflows"`, `"scores"`, or `"unavailable"`).
#'   Other scopes take no additional arguments.
#'
#' @details
#' Read `Question` and `UseWhen`, then open the help for `MainFunction`.
#' `TypicalInput` identifies the required object and `NextStep` its continuation.
#' `DecisionBoundary` and `Notes` describe the limit of the route; a listed
#' function does not imply that every model can use it.
#'
#' The five default routes are choices, not required stages. G/D planning uses
#' observed ratings without an MFRM fit. Explicit `"public"` and `"beginner"`
#' retain the six-row ordinary RSM/PCM route. Other scopes select a topic or
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
#' support. Check `mfrmr_output_guide("gpcm_capabilities")` and the result class's help before reusing a
#' route. [mfrmr_workflow_methods] connects the main objects; numerical and
#' uncertainty conditions belong to the function that computes the result.
#' @return
#' - For `scope = "plots"`, a data.frame with `Question`, `InputClass`,
#'   `PlotCall`, `PlotName` (the name in the saved plot data), `DataComponent`,
#'   `GGPlot`, `GGPlotCall` (`NA` when unavailable), `Notes`, `ResultFunction`
#'   and `NextStep`.
#' - For `scope = "intervals"`, a data.frame mapping confidence-interval and
#'   uncertainty routes (`Route`, `Scope`, `PrimaryHelper`, `DisplayRoute`,
#'   `DefaultLevel`, `IntervalColumns`, `Basis`, `UseFor`,
#'   `InterpretationBoundary`, `GPCMStatus`, `Notes`).
#' - For `scope = "visual_templates"`, a data.frame of figure-reporting guidance
#'   (`FigureFamily`, `Scope`, `PrimaryHelper`, `DefaultPlacement`,
#'   `WhatToReport`, `CaptionSkeleton`, `ResultsWording`, `WhatNotToClaim`,
#'   `BeginnerCheck`, `ThreeDPolicy`).
#' - For `scope = "gpcm_capabilities"`, an `mfrmr_gpcm_capabilities` data.frame
#'   for `view = "workflows"`, or an ordinary data.frame for `view = "scores"`
#'   and `view = "unavailable"`; see [mfrmr_gpcm_scope].
#' - For `scope = "calibration_capabilities"`, a data.frame with one row per
#'   model, estimator, and scoring-basis combination (`Model`, `Estimator`,
#'   `ScoringBasis`, `PortableCalibration`, `AnchorSupport`,
#'   `InteractionSupport`, `ExistingAlternative`, `Limitation`).
#' - All other scopes return a data.frame with one row per route and columns:
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
#' core <- mfrmr_output_guide()
#' core[, c("Question", "MainFunction", "NextStep")]
#'
#' # Request the full catalogue explicitly.
#' catalogue <- mfrmr_output_guide("all")
#' head(catalogue[, c("Question", "MainFunction")])
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
#'
#' mfrmr_output_guide("intervals", "visual")[, c("Route", "DisplayRoute", "Basis")]
#' mfrmr_output_guide("visual_templates", "manuscript")[, c("FigureFamily", "DefaultPlacement")]
#' mfrmr_output_guide("gpcm_capabilities", "supported")[, c("Area", "Status")]
#' mfrmr_output_guide("calibration_capabilities")[, c("Model", "Estimator", "PortableCalibration")]
#' @aliases gpcm_score_side_contract gpcm_runtime_guard_coverage
#' @concept reporting workflow
#' @concept route selection
#' @concept GPCM boundaries
#' @export
mfrmr_output_guide <- function(scope = "core_workflow", ...) {
  scope <- match.arg(scope, c("core_workflow", "all", "public", "beginner", "psychometric",
                                         "entry", "viewer", "binary", "tables", "reports", "reviews",
                                         "bundles", "exports", "compatibility",
                                         "gpcm", "calibration", "simulation", "linking", "network",
                                         "response_time", "facets", "conquest", "r", "models",
                                         "features", "imputation", "gtheory", "feedback", "plots",
                                         "intervals", "visual_templates",
                                         "gpcm_capabilities", "calibration_capabilities"))
  dots <- list(...)
  if (identical(scope, "intervals")) {
    if (length(dots) == 0L) {
      return(mfrmr_interval_guide())
    }
    nms <- names(dots)
    if (length(dots) == 1L && (is.null(nms) || nms[1L] %in% c("", "category", "scope"))) {
      return(mfrmr_interval_guide(scope = dots[[1L]]))
    }
    stop(
      "`scope = \"intervals\"` accepts at most one optional sub-scope argument (`category`, ",
      "such as `\"visual\"`, `\"gpcm\"`, or `\"shrinkage\"`).",
      call. = FALSE
    )
  }
  if (identical(scope, "visual_templates")) {
    if (length(dots) == 0L) {
      return(visual_reporting_template())
    }
    nms <- names(dots)
    if (length(dots) == 1L && (is.null(nms) || nms[1L] %in% c("", "category", "scope"))) {
      return(visual_reporting_template(scope = dots[[1L]]))
    }
    stop(
      "`scope = \"visual_templates\"` accepts at most one optional sub-scope argument (`category`, ",
      "such as `\"manuscript\"`, `\"appendix\"`, `\"diagnostic\"`, or `\"surface\"`).",
      call. = FALSE
    )
  }
  if (identical(scope, "gpcm_capabilities")) {
    nms <- names(dots)
    if (!is.null(nms) && any(!nms %in% c("", "status", "view"))) {
      bad <- nms[!nms %in% c("", "status", "view")]
      stop(
        sprintf(
          "Unsupported argument(s) for `scope = \"gpcm_capabilities\"`: %s. Use `status` and/or `view`.",
          paste(sprintf("`%s`", unique(bad)), collapse = ", ")
        ),
        call. = FALSE
      )
    }
    return(do.call(gpcm_capability_matrix, dots))
  }
  if (identical(scope, "calibration_capabilities")) {
    if (length(dots) > 0L) {
      stop("`scope = \"calibration_capabilities\"` takes no additional arguments.", call. = FALSE)
    }
    return(mfrm_calibration_capabilities())
  }
  if (length(dots) > 0L) {
    stop(sprintf("`scope = \"%s\"` takes no additional arguments.", scope), call. = FALSE)
  }
  if (identical(scope, "plots")) return(.mfrmr_const_.mfrmr_plot_guide)

  out <- .mfrmr_table_mfrmr_output_guide_out

  core_workflow_rows <- .mfrmr_table_mfrmr_output_guide_core_workflow_rows

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
    core_workflow_rows, public_rows, calibration_rows, entry_rows, viewer_rows, binary_rows, out, linking_rows,
    advanced_rows, gpcm_rows, migration_entry_rows, user_pathway_rows, model_rows, workflow_rows,
    feedback_rows, rating_evaluation_rows, model_export_row, network_rows
  )
  out$Lifecycle <- "stable"
  out$Lifecycle[out$OutputFamily %in% "compatibility" | out$Scope %in% c("compatibility", "facets", "conquest")] <- "compatibility"
  out$Lifecycle[out$Scope %in% c("simulation", "network")] <- "advanced"
  out$UserLevel <- "intermediate"
  out$UserLevel[out$Scope %in% c("public", "core_workflow", "calibration", "entry", "viewer", "binary")] <- "beginner"
  out$UserLevel[out$Scope %in% c("simulation", "network", "reviews")] <- "advanced"
  out$UserLevel[out$Scope %in% c("compatibility", "facets", "conquest")] <- "migration"
  out$APILayer <- "specialist_component"
  out$APILayer[out$Scope %in% "public"] <- "top_level_public_surface"
  out$APILayer[out$Scope %in% c("core_workflow", "calibration", "entry", "viewer", "binary")] <- "recommended_entry_route"
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
  out$ObjectRole[grepl("^mfrmr_output_guide", out$MainFunction)] <- "route-selection guide"
  out$ObjectRole[grepl("view = 'unavailable'", out$MainFunction, fixed = TRUE) |
                   grepl('view = "unavailable"', out$MainFunction, fixed = TRUE)] <- "unavailable-route alternatives"
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

  out$RecommendedEntry <- out$Scope %in% c("public", "core_workflow", "calibration", "entry", "viewer", "binary")
  dedicated <- out$Scope %in% c("features", "imputation", "gtheory")
  rating_evaluation <- out$MainFunction %in% rating_evaluation_rows$MainFunction
  targeted <- dedicated | rating_evaluation | out$Scope %in% c("core_workflow", "models", "feedback")
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
