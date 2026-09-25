#' GPCM Workflow Availability
#'
#' @description
#' Check which `GPCM` workflows can be used in `mfrmr`, the limits that
#' apply to each workflow, and the recommended alternative when a route is not
#' available.
#'
#' The table is intended for route selection before or after fitting and is
#' limited to workflow availability, interpretive constraints, and the route
#' to use next.
#' The fitted model uses one facet for both relative discriminations and
#' category steps (`slope_facet == step_facet`). It has one substantive ability
#' dimension. These structural choices are stated separately from the
#' availability of each output. An available probability or descriptive comparison does
#' not establish eligibility for a confidence interval or model-selection rule.
#'
#' @param status Which rows to return: `"all"` (default), `"supported"`,
#'   `"supported_with_caveat"`, `"blocked"`, or `"deferred"`.
#'
#' @details
#' `Status` has the following user-facing meanings:
#'
#' - `supported`: the helper is available within the stated boundary;
#' - `supported_with_caveat`: the helper runs, but its interpretation is
#'   restricted as described in `Boundary`;
#' - `blocked`: the helper intentionally stops for a `GPCM` fit;
#' - `deferred`: no public `mfrmr` route is currently available.
#'
#' Read `Boundary` before interpreting a caveated result. For a blocked or
#' deferred row, use `RecommendedRoute` to choose a supported analysis or a
#' Rasch-family alternative.
#'
#' @section Estimates, intervals and comparisons:
#' For free slopes, these are different questions:
#' - **What did the numerical fit return?** `fit$slopes$OptimizerEstimate`
#'   retains the fitted relative slopes for descriptive sensitivity analysis.
#'   The compatibility column `Estimate` contains the same numerical values;
#'   it does not override `ParameterStatus` or `PrimaryEstimate`.
#' - **How uncertain is a slope?** `confint(fit, parm = "slopes")` returns
#'   approximate pointwise intervals for eligible GPCM MML fits.
#'   `diagnose_mfrm(fit)$parameter_uncertainty$slopes` supplies the same 95%
#'   calculation with `CIEligible` and `InferenceReview`. Ineligible solutions
#'   retain missing ordinary bounds and explicitly labelled `Optimizer*`
#'   diagnostic quantities. Old eligibility flags do not authorize an interval.
#' - **Which model should be selected?** MML information criteria may be
#'   retained numerically. `compare_mfrm()` ranks GPCM MML candidates when its
#'   separate solution and comparison checks pass. `ICSelectable` describes
#'   likelihood and integration requirements; `ICFitEligible` describes the
#'   fit's solution check; `ICComparable` is the final comparison decision.
#'   The weighting review preserves this decision without making an
#'   operational-scoring recommendation. With `nested = TRUE`, it can also
#'   request the separately checked PCM/GPCM equal-slope test.
#'
#' The inference restrictions above concern the current package implementation;
#' they are not a claim that GPCM inference is impossible in general. A local
#'   rank or curvature check does not by itself assess competing solutions,
#'   numerical integration error or the performance of an interval procedure.
#' Relative-slope intervals have their own checks. A PCM/GPCM LRT requires the matched
#' comparison described below; more iterations or quadrature points alone do
#' not establish its structural assumptions.
#'
#' @section Different requirements for intervals and model comparison:
#' These decisions are separate, and do not follow from unidimensionality:
#' - **Slope intervals:** [confint.mfrm_fit()] uses the inverse joint observed
#'   information, including estimated population parameters, and the sum-zero
#'   log-slope transformation. It checks likelihood consistency, convergence,
#'   positive unregularized information, unit weights and a grid of at least
#'   31 points. The exponentiated log-Wald limits are pointwise model-based
#'   approximations for geometric-mean-one relative slopes by default.
#'   Explicit options add population-SD-standardized slopes, named ratios or
#'   differences, Bonferroni adjustment and independent-cluster sandwich
#'   covariance. Small samples and misspecification can still affect coverage.
#'   Failed checks retain missing limits and a reason. [bootstrap_mfrm_gpcm()]
#'   provides fitted-model bootstrap intervals or a matched PCM/GPCM test;
#'   [mfrm_curve_intervals()] propagates calibration uncertainty to curves.
#'   Probability-curve intervals showed undercoverage in a saved-fit study of
#'   small incomplete designs, including finite-grid Bonferroni families.
#'   Numerical availability and multiplicity adjustment do not certify nominal
#'   coverage; bootstrap coverage requires separate evidence too.
#'   Saved results support [apa_table()], [plot_data()] and [as_ggplot()];
#'   attach selected intervals to [mfrm_results()] for reports and exports.
#'   Their targets remain separate from Wright/Pathway location and fit displays.
#' - **Information criteria:** AIC/BIC compare maximized likelihoods on the same
#'   response data, with appropriate free-parameter counts and numerical
#'   accuracy. They do not require a slope confidence interval or nested
#'   models. The GPCM MML solution check reevaluates the retained likelihood,
#'   terminal gradient and positive unregularized local information without
#'   refitting. It uses the existing numerical-gradient tolerance (at most
#'   \eqn{10^{-4}}) and information-inversion eigenvalue tolerance. The existing
#'   joint information calculation is shared with slope intervals and governed
#'   by `options(mfrmr.max_information_bytes = 256 * 1024^2)` rather than an
#'   80-coordinate cutoff. The budget estimates dense matrix workspace, not
#'   total process memory. An unavailable check gives a reason, not permission
#'   to rank. Local checks do
#'   not prove global optimality or integration accuracy; inspect different
#'   starts and [mml_quadrature_sensitivity()] when the decision is close.
#' - **PCM/GPCM likelihood-ratio test:** with the same population model, step
#'   structure and other constraints, setting all relative slopes to one gives
#'   PCM. One is an interior positive slope value, not a variance-zero boundary.
#'   With \eqn{G} slope levels and no other differing free parameters, the null
#'   imposes \eqn{G-1} independent log-slope restrictions. A chi-square reference
#'   additionally requires identified, regular solutions and adequate sample
#'   information. [compare_mfrm()] with `nested = TRUE` checks the matched
#'   model settings, G-1 free dimensions and regular local MML solutions before
#'   reporting an asymptotic chi-square p-value. Default PCM and GPCM calls can
#'   use different population models: supply `population_formula = ~1` and the
#'   same person data to both fits to compare estimated-normal models.
#'   Small or sparse samples can give inaccurate asymptotic p-values; examine
#'   starting-value and quadrature sensitivity and report the test's assumptions.
#'
#' The official \href{https://stat.ethz.ch/R-manual/R-devel/library/stats/html/AIC.html}{R AIC documentation}
#' describes likelihood comparability. The \href{https://philchalmers.github.io/mirt/reference/mirt.html}{mirt model documentation}
#' documents GPCM and information-matrix SEs, and its
#' \href{https://philchalmers.github.io/mirt/reference/anova-method.html}{model-comparison documentation}
#' describes likelihood-ratio and information-criterion comparisons. These are
#' examples of supported statistical methods, not validation of mfrmr's
#' many-facet implementation.
#'
#' @section Comparing models with ConQuest and TAM:
#' Match the response formula before comparing estimates. In mfrmr, the
#' selected positive slope multiplies ability, facet locations and the category
#' step together. A slope multiplying ability alone, with separately additive
#' rater severity, generally specifies a different many-facet model.
#'
#' TAM's `tam.mml.mfr()` does not estimate slopes itself, but its documented
#' Example 14, Model 14c combines a facet intercept design with grouped slopes
#' in `tam.mml.2pl(irtmodel = "GPCM.design")`. ConQuest estimates GPCM scores
#' with `scoresfree`; its default slopes belong to combinations of facets
#' (generalized items), with further grouping available through a scoring
#' design. Neither construction automatically reproduces mfrmr's single
#' slope/step facet and complete-predictor multiplication. See the
#' \href{https://alexanderrobitzsch.github.io/TAM/reference/tam.mml.html}{TAM fitting documentation}
#' and \href{https://www.acer.org/files/Note_8--The_ConQuest_4_Model.pdf}{ConQuest Note 8}.
#'
#' A matched item-only, positive-slope GPCM with an estimated normal population
#' can be expressed on either scale. mfrmr fixes the geometric mean of relative
#' slopes \eqn{\alpha_i} to one and estimates the population SD \eqn{\sigma}
#' conditional on any population covariates. On the unit-variance scale the
#' slopes become \eqn{a_i=\sigma\alpha_i}.
#' Locations, steps and any population regression also need transformation.
#' This equivalence does not include imposing both unit variance and
#' geometric-mean-one slopes: together they impose an additional restriction.
#'
#' Transformed intervals require the joint parameter covariance. Multiplying
#' relative-slope interval endpoints by an estimated population SD omits its
#' uncertainty and covariance with the slopes. Use [confint.mfrm_fit()] with
#' `scale = "standardized"` for the full transformation; with covariates the SD
#' is the residual population SD. TAM's documented `tam.se()` omits
#' parameter covariances; ConQuest distinguishes the covariance of parameter
#' estimates from the latent-population covariance. Neither marginal SEs nor
#' a latent-population covariance matrix replace the required joint matrix.
#' Numerical replication requires matching data, model and identification.
#' IC selection can compare different, nonnested models on compatible
#' likelihoods; verify each model's free-parameter count and integration
#' accuracy. A likelihood-ratio test additionally requires a nested null.
#' Consult `vignette("mfrmr-gpcm-scope")` for examples, sources and the scope
#' of existing numerical comparisons. These do not supply a general GPCM
#' import or comparison API.
#'
#' @section Conditional Person uncertainty:
#' Person posterior SDs and intervals, where returned, condition on the fitted
#' calibration; they are not slope intervals or calibration-aware confidence
#' intervals. An unstable calibration also limits their interpretation.
#'
#' @return A data.frame of class `mfrmr_gpcm_capabilities` with one row per
#' workflow family and columns:
#' - `Area`
#' - `Helpers`
#' - `Status`
#' - `Boundary`
#' - `RecommendedRoute`
#'
#' @section Typical workflow:
#' 1. Call `gpcm_capability_matrix()` before using `GPCM` in a new workflow.
#' 2. For `supported_with_caveat`, read `Boundary` before interpreting output.
#' 3. For `blocked` or `deferred`, follow `RecommendedRoute` instead.
#'
#' @seealso [fit_mfrm()], [diagnose_mfrm()], [compute_information()],
#'   [predict_mfrm_units()], [sample_mfrm_plausible_values()],
#'   [reporting_checklist()], [mfrmr_workflow_methods], [mfrmr-package]
#' @examples
#' gpcm_capability_matrix()
#' gpcm_capability_matrix("supported")
#' gpcm_capability_matrix("blocked")
#' @concept GPCM boundaries
#' @concept route selection
#' @export
gpcm_capability_matrix <- function(status = c("all", "supported", "supported_with_caveat", "blocked", "deferred")) {
  status <- match.arg(status)
  out <- .gpcm_capability_registry(status)
  out <- out[, c(
    "Area", "Helpers", "Status", "Boundary", "RecommendedRoute"
  ), drop = FALSE]
  out$Helpers[out$Status == "deferred"] <- NA_character_
  rownames(out) <- NULL
  class(out) <- c("mfrmr_gpcm_capabilities", "data.frame")
  out
}

#' @export
#' @method print mfrmr_gpcm_capabilities
#' @noRd
print.mfrmr_gpcm_capabilities <- function(x, ...) {
  status_levels <- c(
    "supported", "supported_with_caveat", "blocked", "deferred"
  )
  counts <- table(factor(x$Status, levels = status_levels))
  status_summary <- data.frame(
    Status = names(counts),
    Routes = as.integer(counts),
    stringsAsFactors = FALSE
  )
  status_summary <- status_summary[status_summary$Routes > 0L, , drop = FALSE]

  cat("mfrmr GPCM workflow availability\n")
  cat("One facet supplies both slopes and category steps.\n")
  cat("MML IC comparison and PCM/GPCM tests have separate checks; relative-slope intervals use separate MML checks.\n\n")
  print.data.frame(status_summary, row.names = FALSE)

  max_rows <- min(nrow(x), 8L)
  if (max_rows > 0L) {
    cat("\nRoute preview\n")
    preview <- x[seq_len(max_rows), c("Area", "Status"), drop = FALSE]
    print.data.frame(preview, row.names = FALSE)
  }
  if (nrow(x) > max_rows) {
    cat("\n... ", nrow(x) - max_rows, " more route(s).\n", sep = "")
  }
  cat(
    "\nFilter by status, for example ",
    "gpcm_capability_matrix(\"supported_with_caveat\").\n",
    "Read Boundary and RecommendedRoute before interpreting a caveated or ",
    "unavailable route.\n",
    sep = ""
  )
  invisible(x)
}

.gpcm_capability_registry <- function(status = c("all", "supported", "supported_with_caveat", "blocked", "deferred")) {
  status <- match.arg(status)

  out <- data.frame(
    CapabilityID = c(
      "core_fit_summary",
      "exploratory_diagnostics",
      "fixed_calibration_scoring",
      "curve_category_views",
      "summary_appendix",
      "misfit_casebook",
      "weighting_model_choice",
      "linking_synthesis",
      "simulation_recovery",
      "apa_export_bundles",
      "fair_average",
      "design_forecasting",
      "diagnostic_signal_screening",
      "dff_screening",
      "mcmc_backends",
      "residual_bias_screening",
      "scorefile_export",
      "facets_score_review",
      "optimization_replay"
    ),
    Area = c(
      "Core fitting and summaries",
      "Exploratory diagnostics and residual follow-up",
      "Fitted-object posterior scoring and information",
      "Core curve and category views",
      "Checklist and summary-table appendix route",
      "Operational misfit casebook",
      "Weighting review and model-choice review",
      "Operational linking synthesis",
      "Direct simulation-spec generation and recovery",
      "APA writer and fit-based export bundles",
      "Fair-average semantics under GPCM (slope-aware)",
      "Design evaluation and population forecasting under GPCM",
      "Diagnostic and signal-detection design screening under GPCM",
      "Differential facet functioning screening under GPCM",
      "Posterior-predictive and Bayesian workflows",
      "Residual-bias screening under GPCM",
      "Score-side scorefile export under GPCM",
      "FACETS output-contract score-side review",
      "Replayed optimization diagnostics under GPCM"
    ),
    Helpers = c(
      "fit_mfrm(model = \"GPCM\"); summary(); print(); confint(parm = \"slopes\")",
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
      "reporting_checklist(); precision_review_report(); build_summary_table_bundle(); export_summary_appendix()",
      "build_misfit_casebook()",
      "compare_mfrm(); build_model_choice_review(); build_weighting_review(); compute_information(); plot_information(); build_summary_table_bundle(); export_summary_appendix()",
      "build_linking_review()",
      "build_mfrm_sim_spec(); extract_mfrm_sim_spec(); simulate_mfrm_data(); evaluate_mfrm_recovery(); assess_mfrm_recovery()",
      paste(
        "mfrm_results(include = \"gpcm_review\"); mfrm_report();",
        "export_mfrm_results(); build_apa_outputs(); build_visual_summaries();",
        "run_qc_pipeline(); build_mfrm_manifest(); build_mfrm_replay_script();",
        "export_mfrm_bundle()"
      ),
      "fair_average_table()",
      "evaluate_mfrm_design(); predict_mfrm_population()",
      "evaluate_mfrm_diagnostic_screening(); evaluate_mfrm_signal_detection()",
      "analyze_dff(); analyze_dif(); dif_interaction_table(); dif_report(); plot_dif_heatmap(); plot_dif_summary()",
      NA_character_,
      "estimate_bias(); unexpected_after_bias_table()",
      "facets_output_file_bundle(include = \"score\")",
      "facets_output_contract_review()",
      "estimation_iteration_report()"
    ),
    Status = c(
      "supported_with_caveat",
      "supported_with_caveat",
      "supported",
      "supported",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "deferred",
      "supported_with_caveat",
      "supported_with_caveat",
      "blocked",
      "supported_with_caveat"
    ),
    Boundary = c(
      paste(
        "Requires an explicit step facet and currently keeps",
        "`slope_facet == step_facet`; MML direct is the documented and verified default,",
        "and EM/hybrid fall back to direct. Free-slope fits retain numerical",
        "estimates for review. confint(fit, parm = \"slopes\") separately checks approximate MML intervals.",
        "Explicit options add standardized slopes, comparisons, sandwich covariance and Bonferroni adjustment;",
        "bootstrap_mfrm_gpcm() and mfrm_curve_intervals() supply bootstrap inference and curve uncertainty.",
        "MML information-criterion ranking requires the separate likelihood",
        "and local-solution checks in compare_mfrm()."
      ),
      paste(
        "Residual-based mean-square and strict-marginal outputs remain",
        "exploratory screening tools because discrimination is free.",
        "The dashboard's fair-average panel reports an explicit",
        "unavailability status when the underlying fit is GPCM."
      ),
      paste(
        "`predict_mfrm_units()` and `sample_mfrm_plausible_values()` consume",
        "the fitted model and hold its non-Person parameters fixed. This is",
        "not scoring from a saved, versioned calibration artifact; population",
        "forecasting is a separate layer outside this row."
      ),
      paste(
        "Limited to the slope-aware probability kernel that is already",
        "generalized for the current GPCM branch."
      ),
      paste(
        "Routes users to supported direct tables and plots. Caveated",
        "manuscript-draft APA and fit-based export bundles are governed by",
        "their separate capability row and carry `gpcm_boundary`."
      ),
      paste(
        "Supported with caveat for GPCM because the casebook inherits",
        "exploratory screening semantics from its underlying sources."
      ),
      paste(
        "Supported with caveat because the helper is an operational review of",
        "Rasch-family equal weighting versus GPCM reweighting, not an automatic model-selection rule.",
        "MML ranking requires ICComparable; nested = TRUE requests the separately checked PCM/GPCM equal-slope test."
      ),
      paste(
        "Supported with caveat as an exploratory synthesis over already-built",
        "anchor review, drift, and chain objects. It does not establish an",
        "operational GPCM linking decision, anchor-drift absence claim, or",
        "equating-chain adequacy claim by itself."
      ),
      paste(
        "Requires explicit slope-aware specifications and keeps the current",
        "GPCM facet-role restrictions. Recovery checks are direct",
        "simulation/refit summaries, not design-planning or forecasting claims.",
        "`assess_mfrm_recovery()` requires user-supplied practical thresholds",
        "before RMSE or bias can be interpreted as adequate."
      ),
      paste(
        "Supported with caveat as a connected public reporting/export route over",
        "already-supported GPCM diagnostics, direct tables, plots, manifests,",
        "and replay scripts. The mfrm_results -> mfrm_report -> export/replay",
        "route preserves the model, step/slope owners, and MML identification.",
        "Full FACETS-style score-side contract review,",
        "design forecasting, and automatic operational scoring claims remain",
        "outside this route."
      ),
      paste(
        "Slope-aware element-conditional construction: slope-facet element rows",
        "use that level's own slope; non-slope-facet rows (Person, Rater, ...)",
        "use the geometric-mean-one slope by identification convention.",
        "The historical SE columns in the output are scaled facet-measure SEs,",
        "not fair-average SEs. Use `fair_se = TRUE` to request structural",
        "delta-method fair-average SEs for non-person rows when the MML",
        "observed-information Hessian is available. These remain diagnostic-only:",
        "FairCIEligible is FALSE, including with computable or regularized",
        "covariance, and full-refit coverage remains unverified."
      ),
      paste(
        "Supported with caveat as a role-based person x rater-like x",
        "criterion-like Monte Carlo simulation/refit route. It uses the",
        "GPCM generator and refits GPCM with the supplied or",
        "fit-derived step/slope facet contract, but it reports design-level",
        "operating characteristics only. Slope-recovery adequacy, diagnostic",
        "screening operating characteristics, signal detection, and arbitrary-",
        "facet planning remain separate routes."
      ),
      paste(
        "Supported with caveat as slope-aware repeated simulation/refit",
        "screening evidence for the current role-based person x rater-like x",
        "criterion-like design layer. The summaries are Type I proxy,",
        "sensitivity proxy, DIF target-flag, and bias-screening readouts,",
        "not calibrated inferential tests, operational screening criteria, or",
        "arbitrary-facet planning validation."
      ),
      paste(
        "Supported with caveat as direct DFF/DIF screening over the fitted",
        "GPCM expected-score and residual scale. Residual-method",
        "contrasts and interaction cells remain screening evidence; refit",
        "contrasts must retain explicit linking and precision requirements before",
        "any stronger subgroup-comparison wording is used."
      ),
      paste(
        "mfrmr does not currently provide posterior-predictive checks or MCMC",
        "estimation for GPCM."
      ),
      paste(
        "Bias point estimates use the slope-aware GPCM kernel: the bias",
        "parameter is the additive shift on the linear predictor that",
        "maximises the per-cell GPCM log-likelihood. `LR ChiSq`,",
        "`LR Prob.`, and profile-CI columns compare that fitted shift",
        "with zero by conditional profile likelihood. SE / t / Prob",
        "columns use conditional plug-in information at the bias point",
        "estimate. All quantities hold theta, steps, slopes, and other",
        "facet estimates fixed, so they support screening and follow-up",
        "review rather than standalone fairness claims. The post-bias",
        "unexpected-response comparison uses the same conditional fitted",
        "quantities and is an in-sample descriptive screen; it does not show",
        "that bias has been removed."
      ),
      paste(
        "Supported with caveat for package-native scorefile export only.",
        "Rows carry fitted expected score, residual, standardized residual,",
        "observed-category probability, score slope, native structural",
        "expected-score uncertainty, selectable score-side delta SEs, and",
        "explicit caveat fields when the required MML diagnostics are",
        "available. The route does not export FACETS-equivalent score-side",
        "SEs or establish operational score-scale equivalence."
      ),
      paste(
        "Limited to direct scorefile export rather than the full FACETS-style output-contract review.",
        "Direct scorefile export is available with caveats, but contract-wide",
        "coverage and metric claims still require a broader free-discrimination",
        "score-side review contract."
      ),
      paste(
        "This is a slope-aware diagnostic replay from a reconstructed starting",
        "state, not the exact optimizer history stored during fitting and not",
        "an additional convergence test."
      )
    ),
    RecommendedRoute = c(
      paste(
        "Use `fit_mfrm(..., model = \"GPCM\", step_facet = ...,",
        "slope_facet = step_facet)` and inspect `summary(fit)`."
      ),
      paste(
        "Use diagnostics as screening evidence and return to direct residual,",
        "unexpected-response, displacement, and category tables before writing claims."
      ),
      paste(
        "Use fitted-object posterior scoring and `compute_information()` /",
        "`plot_information()`; keep portable calibration and population",
        "forecasting on their separately documented routes."
      ),
      paste(
        "Use draw-free plot objects and category reports for GPCM sensitivity",
        "figures and appendix tables."
      ),
      paste(
        "Export direct supported tables; use the separate APA/QC/export",
        "bundle row for caveated GPCM sensitivity prose and manifests."
      ),
      paste(
        "Use the casebook as a review queue, then confirm flagged rows with",
        "the underlying direct tables."
      ),
      paste(
        "Compare against an equal-weighting `RSM` / `PCM` reference and report",
        "reweighting as sensitivity evidence."
      ),
      paste(
        "Use `build_linking_review()` as a reader-facing index over direct",
        "anchor, drift, or chain outputs; write any GPCM linking language as",
        "exploratory and source-specific."
      ),
      paste(
        "Use ADEMP-style direct recovery checks with explicit practical RMSE,",
        "bias, and uncertainty thresholds."
      ),
      paste(
        "Use `mfrm_results(fit, include = \"gpcm_review\")`, `mfrm_report()`,",
        "and `export_mfrm_results()` for caveated GPCM sensitivity reporting;",
        "use package-native scorefile export, design forecasting, and full",
        "FACETS score-side review only through their separate caveated or",
        "blocked rows."
      ),
      paste(
        "Use `fair_average_table(fair_se = TRUE)` when structural fair-average",
        "SEs are required, and label outputs as slope-aware element-conditional."
      ),
      paste(
        "Use `evaluate_mfrm_design(..., model = \"GPCM\", step_facet = ...,",
        "slope_facet = step_facet)` or `predict_mfrm_population()` for",
        "caveated design-level operating-characteristic review; inspect",
        "`gpcm_boundary` and keep slope-recovery adequacy on",
        "`evaluate_mfrm_recovery()`."
      ),
      paste(
        "Use `evaluate_mfrm_diagnostic_screening(..., model = \"GPCM\",",
        "step_facet = ..., slope_facet = step_facet)` or",
        "`evaluate_mfrm_signal_detection()` for caveated slope-aware screening",
        "operating-characteristic review; inspect `gpcm_boundary` and keep",
        "operational screening decisions outside this route."
      ),
      paste(
        "Use `analyze_dff()` / `analyze_dif()` and `dif_interaction_table()`",
        "as screening surfaces, then carry `gpcm_boundary` through",
        "`summary()`, `dif_report()`, `plot_dif_heatmap()`, and",
        "`plot_dif_summary()` before writing claims."
      ),
      paste(
        "Use the current MML fitting and fitted-object posterior scoring routes, or",
        "use external Bayesian software when posterior sampling is required."
      ),
      paste(
        "Run `estimate_bias()` first; use `unexpected_after_bias_table()` only",
        "for a descriptive before/after flag comparison, then confirm important",
        "patterns with substantive facet-pair review or external validation."
      ),
      paste(
        "Use `facets_output_file_bundle(include = \"score\")` for a",
        "package-native GPCM scorefile with explicit caveat columns;",
        "inspect `gpcm_score_side_contract()`, and do not treat it as",
        "FACETS score-side equivalence."
      ),
      paste(
        "Use direct fair-average tables and graph-only compatibility outputs;",
        "use package-native scorefile export with its stated caveats, and keep",
        "full FACETS output-contract reviews on the `RSM` / `PCM` route."
      ),
      paste(
        "Use `summary(fit, profile = \"fit\", detail = \"brief\")` for the",
        "recorded convergence result. Use `estimation_iteration_report()` only",
        "to inspect a reconstructed trajectory and label it as replayed."
      )
    ),
    stringsAsFactors = FALSE
  )

  if (!identical(status, "all")) {
    out <- out[out$Status == status, , drop = FALSE]
  }

  rownames(out) <- NULL
  out
}

#' GPCM Score-Side Availability
#'
#' @description
#' Show which `GPCM` score-side quantities are available, the limits on
#' their interpretation, and the alternative route when a quantity is not
#' available.
#'
#' @details
#' Package-native expected-score and uncertainty fields are not FACETS
#' score-side equivalents. A row marked `available_with_caveat` can be used
#' within its stated `Limitation`; `supporting_route` identifies a related
#' output that can inform interpretation; and `unavailable` identifies a route
#' that should be replaced by the listed `Alternative`.
#'
#' @param status Which rows to return: `"all"` (default),
#'   `"available_with_caveat"`, `"supporting_route"`, or `"unavailable"`.
#'
#' @return A data.frame with columns:
#' - `Capability`
#' - `Status`
#' - `Limitation`
#' - `Alternative`
#'
#' @seealso [gpcm_capability_matrix()], [gpcm_runtime_guard_coverage()],
#'   [facets_output_contract_review()], [facets_output_file_bundle()]
#' @examples
#' gpcm_score_side_contract()
#' gpcm_score_side_contract("unavailable")
#' @concept GPCM boundaries
#' @concept FACETS compatibility
#' @export
gpcm_score_side_contract <- function(status = "all") {
  status <- as.character(status[1])
  public_status <- c(
    "all", "available_with_caveat", "supporting_route", "unavailable"
  )
  legacy_status <- c(
    "implemented_with_caveat", "required_for_full_facets_review",
    "validated_dependency"
  )
  if (is.na(status) || !nzchar(status) ||
      !status %in% c(public_status, legacy_status)) {
    stop(
      "`status` must be one of: ",
      paste(sprintf('"%s"', public_status), collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  registry <- .gpcm_score_side_contract_registry()
  if (status %in% legacy_status) {
    registry <- registry[
      registry$CompatibilityStatus == status, , drop = FALSE
    ]
  } else if (!identical(status, "all")) {
    registry <- registry[registry$PublicStatus == status, , drop = FALSE]
  }
  out <- registry[, c(
    "Capability", "PublicStatus", "Limitation", "Alternative"
  ), drop = FALSE]
  names(out)[names(out) == "PublicStatus"] <- "Status"
  rownames(out) <- NULL
  out
}

.gpcm_score_side_contract_registry <- function() {
  data.frame(
    # These selectors preserve calls accepted before the public status names
    # were simplified. They are not returned by gpcm_score_side_contract().
    CompatibilityStatus = c(
      rep("implemented_with_caveat", 3L),
      "required_for_full_facets_review",
      "validated_dependency",
      "validated_dependency",
      "implemented_with_caveat",
      "validated_dependency",
      "implemented_with_caveat"
    ),
    Capability = c(
      "Package-native score estimand",
      "Slope-aware expected-score fields",
      "Native score uncertainty",
      "FACETS-compatible score uncertainty",
      "Structural fair-average uncertainty",
      "Equal-discrimination PCM reference",
      "Package-native scorefile export",
      "Full FACETS score-side review",
      "Reporting interpretation"
    ),
    PublicStatus = c(
      rep("available_with_caveat", 3L),
      "unavailable",
      "supporting_route",
      "supporting_route",
      "available_with_caveat",
      "unavailable",
      "available_with_caveat"
    ),
    Limitation = c(
      "Expected-score and residual quantities are package-native GPCM outputs, not Rasch measure-to-score or FACETS-equivalent quantities.",
      "Expected-score fields use the fitted slope structure and therefore depend on the declared step and slope facets.",
      "Uncertainty fields require the relevant MML diagnostics; otherwise the scorefile reports an explicit unavailable status.",
      "No FACETS-compatible free-discrimination score-side uncertainty definition is currently available.",
      "Structural fair-average SEs condition on Person EAP/reference means and remain diagnostic-only (FairCIEligible = FALSE); full-refit coverage and FACETS score-side equivalence are unverified.",
      "Unit-slope agreement with PCM is an interpretation reference, not evidence that every free-slope score quantity is Rasch-equivalent.",
      "The exported scorefile is package-native and must retain its GPCM caveat fields.",
      "The full FACETS-style score-side review is unavailable for free-discrimination GPCM.",
      "GPCM score-side output is sensitivity evidence, not an automatic operational scoring decision."
    ),
    Alternative = c(
      "Use `facets_output_file_bundle(include = \"score\")` and report the package-native estimand explicitly.",
      "Inspect the fitted step and slope summaries before interpreting exported expected scores or residuals.",
      "Use an MML fit when uncertainty is required, or report the explicit unavailable status without substituting another SE.",
      "Use the package-native scorefile with caveats; use an `RSM` or `PCM` fit when a full FACETS score-side review is required.",
      "Use `fair_average_table(fit, fair_se = TRUE)` directly and label the result as slope-aware element-conditional diagnostic uncertainty.",
      "Fit a `PCM` reference when equal-discrimination score semantics are required for comparison.",
      "Use `facets_output_file_bundle(include = \"score\")` and retain all status and caveat columns.",
      "Keep full `facets_output_contract_review()` work on the `RSM` or `PCM` route.",
      "Report GPCM as a slope-aware sensitivity analysis and keep operational claims separate."
    ),
    stringsAsFactors = FALSE
  )
}

#' Unavailable GPCM Routes and Alternatives
#'
#' @description
#' List `GPCM` routes that are not currently available and show the
#' supported alternative for each route.
#'
#' @details
#' A `blocked` row names a helper that intentionally stops instead of returning
#' an unsupported `GPCM` result. A `deferred` row has no public helper.
#' In either case, read `Boundary` for the reason and `RecommendedRoute` for a
#' currently available analysis route.
#'
#' @return A data.frame with columns:
#' - `Area`
#' - `Helper`
#' - `Status`
#' - `Boundary`
#' - `RecommendedRoute`
#'
#' @seealso [gpcm_capability_matrix()], [mfrmr_workflow_methods],
#'   [mfrmr-package]
#' @examples
#' gpcm_runtime_guard_coverage()
#' @export
gpcm_runtime_guard_coverage <- function() {
  matrix <- .gpcm_capability_registry()
  registry <- .gpcm_runtime_guard_registry()
  idx <- match(registry$CapabilityID, matrix$CapabilityID)
  out <- data.frame(
    Area = registry$Area,
    Helper = registry$Helper,
    Status = matrix$Status[idx],
    Boundary = matrix$Boundary[idx],
    RecommendedRoute = matrix$RecommendedRoute[idx],
    stringsAsFactors = FALSE
  )
  rownames(out) <- NULL
  out
}

.gpcm_runtime_guard_registry <- function() {
  matrix <- .gpcm_capability_registry()
  guard <- data.frame(
    CapabilityID = c(
      "facets_score_review",
      "mcmc_backends"
    ),
    Helper = c(
      "facets_output_contract_review()",
      NA_character_
    ),
    AvailabilityMode = c(
      "structured_error",
      "no_public_helper"
    ),
    ConditionClass = c(
      "mfrmr_gpcm_scope_error",
      NA_character_
    ),
    stringsAsFactors = FALSE
  )

  idx <- match(guard$CapabilityID, matrix$CapabilityID)
  guard$Area <- matrix$Area[idx]
  guard$Status <- matrix$Status[idx]
  guard$RecommendedRoute <- matrix$RecommendedRoute[idx]
  guard <- guard[, c(
    "CapabilityID", "Area", "Helper", "Status", "AvailabilityMode",
    "ConditionClass", "RecommendedRoute"
  )]
  rownames(guard) <- NULL
  guard
}
