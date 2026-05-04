#' Bounded GPCM Support Matrix
#'
#' @description
#' Public capability map for the current `GPCM` scope in `mfrmr`.
#'
#' Use this helper when you need to answer a practical question quickly:
#' which `GPCM` workflows are formally supported in the current core package,
#' which are available only with explicit caveats, and which helpers remain
#' blocked or deferred.
#'
#' The matrix is intentionally conservative. It is a release-scope statement,
#' not a list of every internal code path that happens to run. If a helper is
#' not yet covered by the current validation boundary, it is listed as
#' `blocked` or `deferred` even when some lower-level components already exist.
#'
#' @param status Which rows to return: `"all"` (default), `"supported"`,
#'   `"supported_with_caveat"`, `"blocked"`, or `"deferred"`.
#'
#' @details
#' The current release treats `GPCM` as a bounded supported scope inside the
#' core R package:
#'
#' - fitting and core summaries are supported,
#' - posterior-scoring and information helpers are supported,
#' - residual-based diagnostics and strict marginal follow-up are supported as
#'   exploratory screens,
#' - direct slope-aware simulation-spec generation is supported,
#' - fair-average, visual-summary, and QC routes are available with explicit
#'   GPCM caveats,
#' - APA writer, package-native export/replay bundles, and simulation/refit
#'   planning / forecasting helpers are available with explicit caveats,
#' - FACETS score-side compatibility remains outside the validated `GPCM`
#'   boundary.
#'
#' Why some helpers remain blocked:
#'
#' - FACETS compatibility-contract score exports depend on Rasch-family
#'   measure-to-score semantics that are not yet generalized to the
#'   free-discrimination `GPCM` branch;
#' - fair-average, visual-summary, QC, APA, and export helpers are therefore
#'   exposed as caveated GPCM routes, not as FACETS/Rasch fair-M invariance or
#'   full joint-uncertainty evidence;
#' - planning and forecasting are simulation/refit screening routes under the
#'   current role-based person x rater-like x criterion-like contract, not a
#'   fully arbitrary-facet planner.
#'
#' This boundary is aligned with the package's current validation evidence,
#' including the targeted `GPCM` recovery snapshot and the public-workflow
#' regression tests.
#'
#' @return A data.frame with one row per public helper family and columns:
#' - `Area`
#' - `Helpers`
#' - `Status`
#' - `PrimaryUse`
#' - `Boundary`
#' - `Evidence`
#'
#' @section Typical workflow:
#' 1. Call `gpcm_capability_matrix()` before using `GPCM` in a new workflow.
#' 2. Stay on rows marked `supported` or `supported_with_caveat` for the
#'    current release.
#' 3. Treat `blocked` rows as explicit non-support, not as temporary omissions.
#' 4. Treat `deferred` rows as future-extension targets rather than part of the
#'    current package promise.
#'
#' @seealso [fit_mfrm()], [diagnose_mfrm()], [compute_information()],
#'   [predict_mfrm_units()], [sample_mfrm_plausible_values()],
#'   [reporting_checklist()], [mfrmr_workflow_methods], [mfrmr-package]
#' @examples
#' gpcm_capability_matrix()
#' gpcm_capability_matrix("supported")
#' gpcm_capability_matrix("blocked")
#' @export
gpcm_capability_matrix <- function(status = c("all", "supported", "supported_with_caveat", "blocked", "deferred")) {
  status <- match.arg(status)

  out <- data.frame(
    Area = c(
      "Core fitting and summaries",
      "Exploratory diagnostics and residual follow-up",
      "Fixed-calibration scoring and information",
      "Core curve and category views",
      "Checklist, visual summary, and QC route",
      "Operational misfit casebook",
      "Weighting audit and model-choice review",
      "Operational linking synthesis",
      "Direct simulation-spec generation",
      "APA writer and package-native export/replay bundles",
      "Fair-average semantics under bounded GPCM (slope-aware)",
      "Design planning and forecasting",
      "MCMC and heavy-backend extensions",
      "Residual-bias screening under bounded GPCM",
      "FACETS compatibility-contract score-side outputs"
    ),
    Helpers = c(
      "fit_mfrm(model = \"GPCM\"); summary(); print()",
      paste(
        "diagnose_mfrm(); analyze_residual_pca(); unexpected_response_table();",
        "displacement_table(); measurable_summary_table();",
        "rating_scale_table(); interrater_agreement_table();",
        "facet_quality_dashboard(); plot_qc_dashboard();",
        "plot_marginal_fit(); plot_marginal_pairwise()"
      ),
      "predict_mfrm_units(); sample_mfrm_plausible_values(); compute_information(); plot_information()",
      paste(
        "plot(fit, type = c(\"wright\", \"pathway\", \"ccc\", \"ccc_surface\"));",
        "category_structure_report(); category_curves_report();",
        "facets_output_file_bundle(include = \"graph\")"
      ),
      "reporting_checklist(); precision_audit_report(); build_visual_summaries(); run_qc_pipeline()",
      "build_misfit_casebook()",
      "compare_mfrm(); build_weighting_audit(); compute_information(); plot_information(); build_summary_table_bundle(); export_summary_appendix()",
      "build_linking_review()",
      "build_mfrm_sim_spec(); extract_mfrm_sim_spec(); simulate_mfrm_data()",
      "build_apa_outputs(); build_mfrm_manifest(); build_mfrm_replay_script(); export_mfrm_bundle()",
      "fair_average_table()",
      "evaluate_mfrm_design(); evaluate_mfrm_diagnostic_screening(); evaluate_mfrm_signal_detection(); predict_mfrm_population()",
      "cpp11 backend promotion; posterior predictive computation; MCMC engine; Docker-based advanced runtime",
      "estimate_bias()",
      "facets_parity_report(); facets_output_file_bundle(include = \"score\")"
    ),
    Status = c(
      "supported",
      "supported_with_caveat",
      "supported",
      "supported",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "deferred",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "deferred",
      "supported_with_caveat",
      "blocked"
    ),
    PrimaryUse = c(
      "Estimate bounded GPCM models and inspect convergence, steps, and slope summaries.",
      "Screen local misfit, residual structure, and agreement patterns after fitting.",
      "Score new units or review design-weighted precision under the fitted GPCM calibration.",
      "Inspect targeting, category progression, and category-probability behavior under the generalized kernel.",
      "Check which direct tables and plots are draft-ready and bundle visual/QC screening outputs without claiming FACETS score-side parity.",
      "Combine residual, strict marginal, unexpected-response, and displacement screens into one review queue.",
      "Review whether bounded GPCM is introducing substantively acceptable discrimination-based reweighting.",
      "Synthesize anchor, drift, and chain evidence into one operational review surface.",
      "Generate or extract slope-aware simulation specifications and sample responses directly from them.",
      "Produce caveated manuscript-draft prose, replay scripts, manifests, or package-native export bundles.",
      "Compute slope-aware element-conditional fair-average score adjustments for reporting tables.",
      "Evaluate role-based designs, forecast future administrations, or run screening-design studies by simulation/refit.",
      "Move beyond the current core-package release boundary.",
      "Screen residual two-way interaction-bias cells under bounded GPCM at the screening tier.",
      "Use FACETS-style compatibility-contract score-side outputs that depend on a validated free-discrimination score metric."
    ),
    Boundary = c(
      paste(
        "Requires an explicit step facet and currently keeps",
        "`slope_facet == step_facet`; MML direct is the validated default,",
        "and EM/hybrid fall back to direct."
      ),
      paste(
        "Residual-based mean-square and strict-marginal outputs remain",
        "exploratory screening tools because discrimination is free.",
        "The dashboard's fair-average panel uses the same caveated",
        "slope-aware element-conditional table carried by diagnose_mfrm()."
      ),
      paste(
        "Covers fixed-calibration posterior scoring and information only;",
        "population forecasting is handled by the design-planning row below."
      ),
      paste(
        "Limited to the slope-aware probability kernel that is already",
        "generalized for the current bounded GPCM branch."
      ),
      paste(
        "Routes users to supported direct tables, plots, visual summaries,",
        "QC screens, and caveated APA/export outputs. APA prose must retain",
        "the GPCM screening-tier caveats."
      ),
      paste(
        "Supported with caveat for bounded GPCM because the casebook inherits",
        "exploratory screening semantics from its underlying sources."
      ),
      paste(
        "Supported with caveat because the helper is an operational review of",
        "Rasch-family equal weighting versus bounded GPCM reweighting, not an automatic model-selection rule."
      ),
      paste(
        "Not yet validated for bounded GPCM. Use the underlying anchor-audit,",
        "drift, or chain helpers directly and keep the result outside the",
        "current formal GPCM route."
      ),
      paste(
        "Requires explicit slope-aware specifications and keeps the current",
        "bounded branch's facet-role restrictions."
      ),
      paste(
        "Supported as a package-native reproducibility route with explicit",
        "GPCM caveats. APA text uses GPCM model wording; fair-average and",
        "bias sections remain screening-tier. FACETS score-side exports are",
        "still blocked on the separate compatibility row."
      ),
      paste(
        "Slope-aware element-conditional construction: slope-facet element rows",
        "use that level's own slope; non-slope-facet rows (Person, Rater, ...)",
        "use the geometric-mean-one slope by identification convention.",
        "SE / Model S.E. / Real S.E. columns in the output are scaled",
        "facet-measure SEs. AdjustedAverageConditionalSE and",
        "StandardizedAdjustedAverageConditionalSE are measure-only",
        "conditional delta-method SEs for the fair-average value; they do",
        "not propagate joint threshold, slope, or person-measure uncertainty."
      ),
      paste(
        "Supported for the current role-based person x rater-like x",
        "criterion-like simulation/refit planner under the bounded",
        "`slope_facet == step_facet` contract. Treat outputs as",
        "design-screening summaries, not as FACETS/Rasch score-side",
        "invariance evidence or arbitrary-facet planning."
      ),
      paste(
        "Future extensions, listed for transparency. Out of scope for",
        "the current bounded GPCM branch."
      ),
      paste(
        "Bias point estimates use the slope-aware GPCM kernel: the bias",
        "parameter is the additive shift on the linear predictor that",
        "maximises the per-cell GPCM log-likelihood. SE / t / Prob columns",
        "retain the screening-tier semantics documented in `?estimate_bias`",
        "(conditional plug-in information at the bias point estimate,",
        "holding theta and structural parameters fixed); they are NOT",
        "delta-method standard errors that propagate joint parameter",
        "uncertainty. A delta-method SE for the bias estimate is not",
        "currently provided; it would require the joint-covariance",
        "machinery noted on the FACETS-compatibility row below."
      ),
      paste(
        "Not yet generalized to free-discrimination score semantics.",
        "The underlying joint covariance machinery (a joint Hessian on",
        "theta x slope x step) is the prerequisite for delta-method",
        "score-side standard errors and has not yet been exposed."
      )
    ),
    Evidence = c(
      "covered by estimation and output-stability checks",
      "covered by diagnostic and marginal-plot checks",
      "covered by scoring and information checks",
      "covered by curve, plot, and information checks",
      "covered by reporting-route, visual-summary, and QC-pipeline checks",
      "covered by misfit-casebook and diagnostic checks",
      "covered by weighting-review and information checks",
      "covered by APA/export/replay GPCM smoke checks",
      "covered by slope-aware simulation checks",
      "covered by GPCM planning and forecast smoke checks",
      "covered by reduction-to-PCM and worked-example numerical-agreement tests",
      "not yet validated for the bounded GPCM route",
      "future extension",
      "covered by an end-to-end test on a fitted GPCM example",
      "not yet validated for free-discrimination score semantics"
    ),
    stringsAsFactors = FALSE
  )

  if (!identical(status, "all")) {
    out <- out[out$Status == status, , drop = FALSE]
  }

  rownames(out) <- NULL
  out
}
