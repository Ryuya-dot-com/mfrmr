#' mfrmr Workflow and Method Map
#'
#' @description
#' Connect the analysis question to the result object and its next use.
#' For a step-by-step lesson, including CSV import and the meaning of the R
#' commands, use `vignette("mfrmr-workflow", package = "mfrmr")`.
#'
#' @section Choose the analysis question:
#' | Question | Start with | Read next |
#' | --- | --- | --- |
#' | What do ratings imply about Person abilities and facet effects? | [describe_mfrm_data()], [fit_mfrm()] | `summary(fit)$decision`, then the estimate tables |
#' | How would rater/task counts or score weights change precision? | [mfrm_g_study()], [mfrm_d_study()] | The declared design, G/Phi and uncertainty availability |
#' | Which ratings or rater patterns need review? | [diagnose_mfrm()], [estimate_bias()], [analyze_dff()] | The selected diagnostic's target, counts and reasons |
#' | Do raters give the same scores to the same responses? | [interrater_agreement_table()] or a raw-score agreement helper | Matching units, the agreement definition and denominator |
#' | How can new Persons be scored against an existing calibration? | [predict_mfrm_units()] or [mfrm_calibration_workflow] | Conditional scores, uncertainty and calibration scope |
#'
#' These are alternative or complementary analyses. Observed agreement and G/D
#' planning do not establish MFRM fit; severity separation is not agreement.
#' [mfrmr_methods_reference] explains which calculation answers each question.
#'
#' @section Start here:
#' The example below loads synthetic ratings, fits an RSM, saves its summary
#' and draws a Wright map. Each input row is one rating; `person`, `facets`
#' and `score` identify columns. The summary's overview tables describe
#' distributions; `as.data.frame(fit)` gives individual estimates.
#'
#' Before adapting the example, declare the rubric and review category use,
#' retained rows and assignments with [describe_mfrm_data()]. Unassigned cells
#' are not zero scores. `category_policy = "preserve"` retains the declared
#' ladder; the default can collapse gaps. Ordinary RSM/PCM MML defaults to a
#' fixed N(0,1) Person distribution. Estimating its mean/SD requires an explicit
#' population model. These choices change the model, not just its labels.
#' See [fit_mfrm_technical_details] for model, estimator and constraint choices.
#'
#' @section From the first summary to diagnostics:
#' For supported ordinary RSM/PCM MML/JML fits, continue to
#' [mfrm_results()] and inspect `summary(res)$triage`; [mfrm_report()] and
#' [export_mfrm_results()] use that result bundle. `summary(fit)` alone does
#' not compute diagnostics. Read `Why` and `NextAction` when inference is
#' unavailable: it may require a precision review, rather than indicate a
#' failed point estimate. Keep diagnostics with the fit that produced them.
#'
#' Other estimators have distinct result classes and downstream support:
#' - **CML:** use its structural locations/steps and [mfrm_facet_intervals()].
#'   Person abilities, population SD and ordinary fit diagnostics are not returned.
#'   Comparison-only fitting reports the requested identifiable contrasts.
#' - **GPCM:** consult [gpcm_capability_matrix()] before requesting ordinary-model reports.
#'   One-family and two-family routes have different restrictions.
#' - **Corrected JML, random-rater and testlet models:** use the methods
#'   documented for their result classes, including [mfrm_response_diagnostics()]
#'   where supported. A shared class name alone is not a capability guarantee.
#'
#' @section Continuing an analysis:
#' - **Plan an assessment:** the G-theory tutorial and [mfrm_g_study()] /
#'   [mfrm_d_study()] specify score components, crossed/nested designs and future
#'   replications. Design identification and interval availability are separate.
#' - **Link calibrations or review DFF:** [mfrmr_linking_and_dff] distinguishes
#'   joint calibration, fixed anchors, drift and conditional bias screens.
#' - **Review missing scores:** [review_mfrm_imputations()] checks supplied
#'   completions; [fit_mfrm_imputed()] retains each fit/failure and
#'   [pool_mfrm_imputed()] documents pooling eligibility. Missing scores on
#'   assigned ratings are different from unassigned cells.
#' - **Explore external attributes:** [mfrm_features()] reviews the selected
#'   variables; PCA and clustering describe those attributes, not latent abilities.
#' - **Report or visualize results:** [mfrmr_reports_and_tables] covers saved
#'   output; [mfrmr_visual_diagnostics] helps select a figure. The reporting
#'   tutorial provides the complete manuscript workflow.
#'
#' Use [mfrmr_output_guide()] for specialist routes such as population
#' prediction, screening evaluation, operational review or model comparison.
#' Each route's help gives its inputs and limits; running all routes is not a
#' requirement. [mfrmr_compatibility_layer] covers old names and saved analyses.
#'
#' @section Installed help and online articles:
#' Five core tutorials are included with the package. Specialist articles are
#' online; they cannot all be opened with `vignette()`. Match the website's
#' version to `packageVersion("mfrmr")`; installed help describes this version.
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
#'   model = "RSM",
#'   population_formula = NULL # Fixed N(0,1) ability distribution
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
#' @name mfrmr_workflow_methods
NULL
