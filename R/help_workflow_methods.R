#' @section Five-question workflow map:
#' | Question | Start with | Inspect next |
#' | --- | --- | --- |
#' | Person abilities and facet effects | [describe_mfrm_data()], [fit_mfrm()] | `summary(fit)$decision`, estimate tables |
#' | Rater/task counts and score weights | [mfrm_g_study()], [mfrm_d_study()] | Declared design, `G`/`Phi`, interval status |
#' | Ratings or rater patterns needing review | [diagnose_mfrm()], [estimate_bias()], [analyze_dff()] | Diagnostic target, counts, availability reasons |
#' | Observed rater score agreement | [interrater_agreement_table()] or pairwise agreement helpers | Matched units, agreement definition, denominator |
#' | Scoring new Persons on a fixed calibration | [predict_mfrm_units()] or [mfrm_calibration_workflow] | Conditional EAP/SD, prior, source checks |
#'
#' Observed agreement and G-Study/D-Study planning use raw ratings directly and
#' do not establish MFRM fit; rater severity separation is distinct from
#' inter-rater agreement. See `vignette("mfrmr-workflow", package = "mfrmr")`
#' and [mfrmr_output_guide()] for step-by-step routes.
#'
#' @aliases mfrmr_workflow_methods
#' @rdname mfrmr-package
#' @name mfrmr_workflow_methods
NULL
