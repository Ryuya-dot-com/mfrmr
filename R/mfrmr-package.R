#' mfrmr: Many-Facet Ordered-Response Modeling in R
#'
#' @description
#' Analyze ordered ratings involving raters, tasks and criteria. The package
#' provides measurement models, observed-score assessment planning and rater
#' feedback. Choose a route from the question; these are not compulsory stages
#' of a single analysis.
#'
#' @useDynLib mfrmr, .registration = TRUE
#'
#' @section Choose an analysis route:
#' - **Measurement:** [describe_mfrm_data()] reviews rating rows and the design;
#'   [fit_mfrm()] estimates Person abilities, facet effects and category steps
#'   within the selected model's scope. Read `summary(fit)$decision` before
#'   interpreting the estimates. The example below starts with bundled ratings.
#' - **Assessment planning:** [mfrm_g_study()] estimates observed-score variance
#'   components; [mfrm_d_study()] compares specified rater/task plans. Neither
#'   requires an MFRM fit. G/Phi refer to the declared score and replication plan.
#' - **Rater feedback:** [interrater_agreement_table()] describes agreement,
#'   [diagnose_mfrm()] reviews supported response-fit diagnostics, and
#'   [estimate_bias()] / [analyze_dff()] address specified interaction/group
#'   questions. Severity, agreement and fit are different targets.
#'
#' @section Learning and reference:
#' Use `vignette("mfrmr-workflow", package = "mfrmr")` for a first analysis
#' and importing your own ratings. The model-choice, G-theory, visual-diagnostics
#' and reporting tutorials address the corresponding decisions; list installed
#' tutorials with `vignette(package = "mfrmr")`.
#'
#' [mfrmr_workflow_methods] connects the main result objects. Use
#' [mfrmr_methods_reference] to locate definitions and methodological sources,
#' or [mfrmr_output_guide()] for the five central routes. Use
#' `mfrmr_output_guide("all")` to find specialist tables, figures or exports.
#' Function help gives the installed version's arguments, calculations and
#' limitations. Additional packages are required only by the features that name
#' them in their help. Cite `citation("mfrmr")` and the methods actually used.
#'
#' @section Saved analyses:
#' Keep complete result objects with [base::saveRDS()] and record the package
#' version and analysis settings. Reopening with [base::readRDS()] does not
#' update calculations. [mfrmr_compatibility_layer] distinguishes redisplaying,
#' recomputing derived results and refitting when updating older analyses.
#' For scoring against a portable fixed calibration, use
#' [mfrm_calibration_workflow]; this is a different artifact from a saved fit.
#'
#' @section Interpretation:
#' Model, estimator, score coding, assignment and uncertainty assumptions must
#' match the intended use. A returned estimate, numerical convergence and an
#' available interval are separate results. The specialist help and returned
#' status/reason fields state the applicable restrictions; a review flag is
#' not an automatic judgment of rater quality or fairness.
#' @examples
#' # Load the package
#' library(mfrmr)
#'
#' # Load example ratings and look at the first six rows
#' ratings <- load_mfrmr_data("example_operational")
#' head(ratings)
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
#' # Read the interpretation status before examining or plotting estimates
#' results <- summary(fit)
#' results$decision
#' results$person_overview # One row summarizing person ability estimates
#' results$facet_overview  # One row per facet: number of levels, mean, SD, range
#'
#' # Plot the results (Wright map) within the reported interpretation limits
#' plot(fit)
#' @importFrom dplyr across all_of any_of arrange bind_cols bind_rows
#' @importFrom dplyr case_when coalesce count desc distinct everything filter group_by
#' @importFrom dplyr if_all inner_join lag last left_join mutate n n_distinct pull rename
#' @importFrom dplyr row_number rowwise select slice slice_head slice_tail summarise
#' @importFrom dplyr starts_with summarize transmute ungroup
#' @importFrom tidyr drop_na expand_grid pivot_wider replace_na unite
#' @importFrom tibble as_tibble column_to_rownames tibble
#' @importFrom utils combn data globalVariables head modifyList packageVersion
#' @importFrom utils read.csv tail write.csv
#' @importFrom graphics abline arrows axis barplot dotchart hist image legend lines mtext plot plot.new points rect segments text title
#' @importFrom stats cutree hclust kmeans nlminb optim optimHess optimize qt
#' @importFrom utils zip
#' @importFrom cli cli_progress_bar cli_progress_done cli_progress_update
#' @importFrom gtable gtable_add_cols gtable_add_grob gtable_add_rows gtable_matrix
#' @importFrom rlang .data
#' @importFrom stats ave confint na.omit optim p.adjust pchisq predict pt qnorm rnorm sd setNames uniroot
#'
#' @name mfrmr-package
"_PACKAGE"
