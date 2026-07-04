#' Bounded GPCM Support Matrix
#'
#' @description
#' Public capability map for the current `GPCM` scope in `mfrmr`.
#'
#' Use this helper when you need to answer a practical question quickly:
#' which `GPCM` workflows are supported in this release, which are available
#' only with explicit caveats, and which helpers remain blocked or deferred,
#' plus the route to use instead when the requested helper is outside the
#' current boundary.
#'
#' The matrix is intentionally conservative. It is a release-scope statement,
#' not a promise that every lower-level helper can be combined with `GPCM`.
#' If a helper is not yet covered by the current validation boundary, it is
#' listed as `blocked` or `deferred` even when related components already
#' exist.
#'
#' @param status Which rows to return: `"all"` (default), `"supported"`,
#'   `"supported_with_caveat"`, `"blocked"`, or `"deferred"`.
#'
#' @details
#' The current release treats `GPCM` as a bounded supported scope inside the
#' core R package. "Bounded" means a constrained package-native branch, not a
#' complete unrestricted GPCM implementation; the current `GPCM` route is
#' therefore not a complete unrestricted GPCM implementation. The current
#' branch keeps the role-based many-facet design contract, requires an
#' explicit step-facet
#' structure, keeps `slope_facet == step_facet`, uses positive
#' geometric-mean-one slopes, and validates helper families one row at a time
#' through this matrix.
#'
#' Within that boundary:
#'
#' - fitting and core summaries are supported,
#' - posterior-scoring and information helpers are supported,
#' - residual-based diagnostics and strict marginal follow-up are supported as
#'   exploratory screens,
#' - direct slope-aware simulation-spec generation and parameter-recovery
#'   simulation are supported with caveats,
#' - `fair_average_table()` is supported with an explicit slope-aware
#'   element-conditional caveat,
#' - `estimate_bias()` is supported as conditional screening evidence with
#'   slope-aware information and profile-likelihood follow-up columns,
#' - summary-table appendix export is available for supported direct outputs,
#' - APA writer, visual summaries, QC pipelines, manifests, replay scripts,
#'   and fit-based export bundles are available only as caveated
#'   sensitivity-reporting surfaces with an explicit `gpcm_boundary`,
#' - package-native scorefile export is available with score-side caveats,
#' - role-based design evaluation and population forecasting are available as
#'   caveated bounded-`GPCM` sensitivity evidence,
#' - role-based diagnostic and signal-detection design screening helpers are
#'   available as caveated bounded-`GPCM` sensitivity evidence,
#' - full FACETS output-contract score-side review remains outside the
#'   validated `GPCM` boundary.
#'
#' Why some helpers remain blocked:
#'
#' - full FACETS output-contract score-side review depends on Rasch-family
#'   measure-to-score semantics plus delta-method SE machinery that are not
#'   yet generalized to the free-discrimination `GPCM` branch;
#' - APA writer, fit-based report/export bundles, visual summaries, and QC
#'   pipelines stay caveated because they must not turn unsupported score-side
#'   semantics into narrative or pass/fail outputs;
#' - diagnostic, signal-detection, design-forecast, and linking helpers stay
#'   caveated because their simulation/refit summaries must not become
#'   operational screening, scoring, or arbitrary-facet planning claims.
#'
#' This boundary is aligned with the package's current validation evidence,
#' including the targeted `GPCM` recovery snapshot and the public workflow
#' checks.
#'
#' @return A data.frame with one row per public helper family and columns:
#' - `Area`
#' - `Helpers`
#' - `Status`
#' - `PrimaryUse`
#' - `Boundary`
#' - `Evidence`
#' - `RecommendedRoute`
#' - `NextValidationStep`
#'
#' @section Typical workflow:
#' 1. Call `gpcm_capability_matrix()` before using `GPCM` in a new workflow.
#' 2. Stay on rows marked `supported` or `supported_with_caveat` for the
#'    current release.
#' 3. For `blocked` and `deferred` rows, read `RecommendedRoute` before choosing
#'    a substitute workflow.
#' 4. Treat `blocked` rows as explicit non-support, not as temporary omissions.
#' 5. Treat `deferred` rows as future-extension targets rather than part of the
#'    current user-facing support.
#'
#' @seealso [fit_mfrm()], [diagnose_mfrm()], [compute_information()],
#'   [predict_mfrm_units()], [sample_mfrm_plausible_values()],
#'   [reporting_checklist()], [mfrmr_model_family_scope()],
#'   [mfrmr_workflow_methods], [mfrmr-package]
#' @examples
#' gpcm_capability_matrix()
#' gpcm_capability_matrix("supported")
#' gpcm_capability_matrix("blocked")
#' @concept GPCM boundaries
#' @concept route selection
#' @export
gpcm_capability_matrix <- function(status = c("all", "supported", "supported_with_caveat", "blocked", "deferred")) {
  status <- match.arg(status)

  out <- data.frame(
    Area = c(
      "Core fitting and summaries",
      "Exploratory diagnostics and residual follow-up",
      "Fixed-calibration scoring and information",
      "Core curve and category views",
      "Checklist and summary-table appendix route",
      "Operational misfit casebook",
      "Weighting review and model-choice review",
      "Operational linking synthesis",
      "Direct simulation-spec generation and recovery",
      "APA writer and fit-based export bundles",
      "Fair-average semantics under bounded GPCM (slope-aware)",
      "Design evaluation and population forecasting under bounded GPCM",
      "Diagnostic and signal-detection design screening under bounded GPCM",
      "Differential facet functioning screening under bounded GPCM",
      "MCMC and heavy-backend extensions",
      "Residual-bias screening under bounded GPCM",
      "Score-side scorefile export under bounded GPCM",
      "FACETS output-contract score-side review"
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
      "reporting_checklist(); precision_review_report(); build_summary_table_bundle(); export_summary_appendix()",
      "build_misfit_casebook()",
      "compare_mfrm(); build_model_choice_review(); build_weighting_review(); compute_information(); plot_information(); build_summary_table_bundle(); export_summary_appendix()",
      "build_linking_review()",
      "build_mfrm_sim_spec(); extract_mfrm_sim_spec(); simulate_mfrm_data(); evaluate_mfrm_recovery(); assess_mfrm_recovery()",
      "build_apa_outputs(); build_visual_summaries(); run_qc_pipeline(); build_mfrm_manifest(); build_mfrm_replay_script(); export_mfrm_bundle()",
      "fair_average_table()",
      "evaluate_mfrm_design(); predict_mfrm_population()",
      "evaluate_mfrm_diagnostic_screening(); evaluate_mfrm_signal_detection()",
      "analyze_dff(); analyze_dif(); analyze_dff_moderation(); analyze_dif_moderation(); dif_interaction_table(); dif_report(); plot_dif_heatmap(); plot_dif_summary()",
      "cpp11 backend promotion; posterior predictive computation; MCMC engine; Docker-based advanced runtime",
      "estimate_bias()",
      "facets_output_file_bundle(include = \"score\")",
      "facets_output_contract_review()"
    ),
    Status = c(
      "supported",
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
      "blocked"
    ),
    PrimaryUse = c(
      "Estimate bounded GPCM models and inspect convergence, steps, and slope summaries.",
      "Screen local misfit, residual structure, and agreement patterns after fitting.",
      "Score new units or review design-weighted precision under the fitted GPCM calibration.",
      "Inspect targeting, category progression, and category-probability behavior under the generalized kernel.",
      "Check which direct tables and plots are draft-ready and export their summary tables.",
      "Combine residual, strict marginal, unexpected-response, and displacement screens into one review queue.",
      "Review whether bounded GPCM is introducing substantively acceptable discrimination-based reweighting.",
      "Synthesize anchor, drift, and chain evidence into one exploratory review surface.",
      "Generate or extract slope-aware simulation specifications, sample responses, and run direct parameter-recovery checks.",
      "Produce caveated manuscript-draft prose, fit-based report bundles, manifests, replay scripts, or full export bundles.",
      "Compute slope-aware element-conditional fair-average score adjustments for reporting tables.",
      "Evaluate role-based future designs or forecast one future administration with repeated bounded-GPCM simulation/refit runs.",
      "Run diagnostic-screening or signal-detection operating-characteristic studies.",
      "Review group-by-facet differential-functioning patterns as slope-aware screening evidence.",
      "Move beyond the current core-package release boundary.",
      "Screen residual two-way interaction-bias cells under bounded GPCM at the screening tier.",
      "Export observation-level slope-aware expected score, residual, probability, and slope fields for bounded GPCM.",
      "Run the full FACETS-style output-contract score-side review that depends on validated free-discrimination score metrics."
    ),
    Boundary = c(
      paste(
        "Requires an explicit step facet and currently keeps",
        "`slope_facet == step_facet`; fixed-SD direct MML remains the",
        "stable default, EM/hybrid are available for additive bounded GPCM,",
        "and opt-in free population-SD estimation forces the EM variance",
        "M-step. This is a constrained package-native branch, not a",
        "complete unrestricted GPCM implementation."
      ),
      paste(
        "Residual-based mean-square and strict-marginal outputs remain",
        "exploratory screening tools because discrimination is free.",
        "The dashboard's fair-average panel reports an explicit",
        "unavailability status when the underlying fit is GPCM."
      ),
      paste(
        "Covers fixed-calibration posterior scoring and information only;",
        "population forecasting is a separate layer outside this row."
      ),
      paste(
        "Limited to the slope-aware probability kernel that is already",
        "generalized for the current bounded GPCM branch."
      ),
      paste(
        "Routes users to supported direct tables and plots. Caveated",
        "manuscript-draft APA and fit-based export bundles are governed by",
        "their separate capability row and carry `gpcm_boundary`."
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
        "Supported with caveat as an exploratory synthesis over already-built",
        "anchor review, drift, and chain objects. It does not establish an",
        "operational GPCM linking decision, anchor-drift absence claim, or",
        "equating-chain adequacy claim by itself."
      ),
      paste(
        "Requires explicit slope-aware specifications and keeps the current",
        "bounded branch's facet-role restrictions. Recovery checks are direct",
        "simulation/refit summaries, not design-planning or forecasting claims.",
        "`assess_mfrm_recovery()` requires user-supplied practical thresholds",
        "before RMSE or bias can be interpreted as adequate."
      ),
      paste(
        "Supported with caveat as a partial reporting/export bundle over",
        "already-supported GPCM diagnostics, direct tables, plots, manifests,",
        "and replay scripts. Full FACETS-style score-side contract review,",
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
        "observed-information Hessian is available."
      ),
      paste(
        "Supported with caveat as a role-based person x rater-like x",
        "criterion-like Monte Carlo simulation/refit route. It uses the",
        "bounded-GPCM generator and refits bounded GPCM with the supplied or",
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
        "not calibrated inferential tests, operational screening gates, or",
        "arbitrary-facet planning validation."
      ),
      paste(
        "Supported with caveat as direct DFF/DIF screening over the fitted",
        "bounded-GPCM expected-score and residual scale. Residual-method",
        "contrasts and interaction cells remain screening evidence; refit",
        "contrasts must retain explicit linking and precision gates before",
        "any stronger subgroup-comparison wording is used."
      ),
      paste(
        "Future extensions, listed for transparency. Out of scope for",
        "the current bounded GPCM branch."
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
        "review rather than standalone fairness claims."
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
        "Not yet generalized to the full FACETS-style output-contract review.",
        "Direct scorefile export is available with caveats, but contract-wide",
        "coverage and metric claims still require a broader free-discrimination",
        "score-side review contract."
      )
    ),
    Evidence = c(
      "covered by estimation and output-stability checks",
      "covered by diagnostic and marginal-plot checks",
      "covered by scoring and information checks",
      "covered by curve, plot, and information checks",
      "covered by reporting-route and summary-appendix export checks",
      "covered by misfit-casebook and diagnostic checks",
      "covered by weighting-review and information checks",
      "covered by exploratory linking-review guardrail tests",
      "covered by slope-aware simulation and recovery checks",
      "covered by partial-reporting and export-bundle GPCM tests",
      "covered by reduction-to-PCM and worked-example numerical-agreement tests",
      "covered by caveated GPCM design-evaluation and forecast tests",
      "covered by caveated GPCM diagnostic and signal-detection screening tests",
      "covered by caveated GPCM DFF summary, report, and plot-payload tests",
      "future extension",
      "covered by an end-to-end test on a fitted GPCM example",
      "covered by GPCM scorefile export, native uncertainty, score-side simulation, mirt/TAM external-kernel comparison, and guardrail tests",
      "not yet validated for free-discrimination score semantics"
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
        "Use fixed-calibration scoring and `compute_information()` /",
        "`plot_information()`; keep population forecasting on a separate route."
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
        "Use the APA/QC/export bundle for caveated GPCM sensitivity reporting;",
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
        "Use `analyze_dff()` / `analyze_dif()`,",
        "`analyze_dff_moderation()` / `analyze_dif_moderation()`, and",
        "`dif_interaction_table()` as screening surfaces, then carry",
        "`gpcm_boundary` through `summary()`, `dif_report()`,",
        "`plot_dif_heatmap()`, and `plot_dif_summary()` before writing claims."
      ),
      paste(
        "Keep this outside the current public GPCM route and track it as",
        "future-extension scope."
      ),
      paste(
        "Use `estimate_bias()` as screening evidence and follow up with explicit",
        "facet-pair review or external validation before fairness language."
      ),
      paste(
        "Use `facets_output_file_bundle(include = \"score\")` for a",
        "package-native bounded-GPCM scorefile with explicit caveat columns;",
        "inspect `gpcm_score_side_contract()`, and do not treat it as",
        "FACETS score-side equivalence."
      ),
      paste(
        "Use direct fair-average tables and graph-only compatibility outputs;",
        "use `gpcm_score_side_contract()` to inspect the unblock criteria,",
        "and keep full FACETS output-contract reviews on the `RSM` / `PCM` route."
      )
    ),
    NextValidationStep = c(
      paste(
        "Add identification and recovery tests before broadening beyond",
        "`slope_facet == step_facet`."
      ),
      paste(
        "Collect free-discrimination diagnostic comparison fixtures before",
        "promoting residual screens to confirmatory wording."
      ),
      paste(
        "Validate latent-regression and population-forecast semantics separately",
        "from fixed-calibration scoring."
      ),
      "Keep kernel-reduction, curve-shape, and draw-free plot-data tests current.",
      paste(
        "Keep direct-output and report-bundle caveats synchronized before",
        "broadening toward operational wording."
      ),
      "Add larger operational case-review examples if external GPCM fixtures become available.",
      paste(
        "Define a model-choice decision policy before turning reweighting review",
        "into recommendation language."
      ),
      paste(
        "Validate larger multi-wave GPCM anchor/drift and equating-chain",
        "fixtures before upgrading exploratory wording to operational linking",
        "claims."
      ),
      paste(
        "Expand multi-seed recovery coverage across slope regimes and sparse",
        "score-category support."
      ),
      paste(
        "Keep partial-section availability tests synchronized with score-side",
        "and design-forecasting guards."
      ),
      "Add external or simulation-backed checks for structural fair-average SEs.",
      paste(
        "Expand multi-seed fixtures across slope regimes, sparse score support,",
        "and fit-derived specifications before using this route for stronger",
        "operational design recommendations."
      ),
      paste(
        "Expand multi-seed fixtures across slope regimes, local-dependence,",
        "step/slope-facet misspecification, sparse score support, and",
        "fit-derived specifications before using this route for stronger",
        "screening recommendations."
      ),
      paste(
        "Add larger subgroup fixtures and simulation operating-characteristic",
        "checks before using DFF rows as fairness, invariance, or bias claims."
      ),
      paste(
        "Decide posterior-predictive, MCMC, and backend scope only after the",
        "score-side contract is stable."
      ),
      paste(
        "Add simulation operating-characteristic or external fixture evidence",
        "before using screening rows as fairness claims."
      ),
      paste(
        "Keep unit-slope PCM reduction checks, slope-variation fixtures,",
        "mirt/TAM external-kernel comparison, and score-scale delta-SE tests",
        "current before broadening the scorefile route beyond package-native",
        "sensitivity output."
      ),
      paste(
        "Complete the `gpcm_score_side_contract()` requirements, including",
        "a FACETS-compatible free-discrimination score metric and output",
        "contract, before enabling full score-side contract review."
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

#' Bounded GPCM Score-Side Export Contract
#'
#' @description
#' Minimal contract table for the caveated bounded-`GPCM` scorefile route and
#' the still-blocked full FACETS-style score-side review route.
#'
#' @details
#' This helper does not enable full FACETS-style score-side review. It records
#' the requirements that separate the current caveated
#' `facets_output_file_bundle(include = "score")` route from a future
#' `facets_output_contract_review()` route for bounded `GPCM`.
#'
#' Use it as a release-maintenance checklist. Rows marked
#' `implemented_with_caveat` support the current package-native bounded-`GPCM`
#' scorefile route. Rows marked `required_for_full_facets_review` are still
#' blockers for full FACETS-style output-contract review. Rows marked
#' `validated_dependency` are already available in the package but are not
#' sufficient by themselves to justify full FACETS score-side equivalence.
#'
#' @param status Which rows to return: `"all"` (default),
#'   `"implemented_with_caveat"`, `"required_for_full_facets_review"`, or
#'   `"validated_dependency"`.
#'
#' @return A data.frame with columns:
#' - `ContractArea`
#' - `Requirement`
#' - `CurrentStatus`
#' - `ReleaseBoundary`
#' - `ValidationTarget`
#' - `ExitCriterion`
#'
#' @seealso [gpcm_capability_matrix()], [gpcm_runtime_guard_coverage()],
#'   [facets_output_contract_review()], [facets_output_file_bundle()]
#' @examples
#' gpcm_score_side_contract()
#' gpcm_score_side_contract("implemented_with_caveat")
#' @concept GPCM boundaries
#' @concept FACETS compatibility
#' @export
gpcm_score_side_contract <- function(status = c("all", "implemented_with_caveat", "required_for_full_facets_review", "validated_dependency")) {
  status <- match.arg(status)

  out <- data.frame(
    ContractArea = c(
      "score_estimand",
      "measure_to_score_metric",
      "score_uncertainty",
      "external_probability_kernel",
      "facets_score_uncertainty_contract",
      "structural_fair_average_se",
      "pcm_reduction",
      "export_schema",
      "runtime_guard",
      "release_wording"
    ),
    Requirement = c(
      "Define the bounded-GPCM score-side estimand separately from Rasch-family measure-to-score semantics.",
      "Specify how free-discrimination slopes enter expected-score summaries, residual score-side fields, and caveat columns.",
      "Maintain native observation-level expected-score uncertainty and corrected score-scale delta SEs under free discrimination for caveated bounded-GPCM score files.",
      "Compare the adjacent-category bounded-GPCM probability kernel against external GPCM probability traces under explicit parameter mappings.",
      "Define the FACETS-compatible score-side uncertainty contract before enabling full output-contract review.",
      "Use structural fair-average SEs where available and document when Hessian-based SEs are unavailable.",
      "Preserve unit-slope bounded-GPCM reduction tests against the PCM route while score-side export remains caveated.",
      "Map each scorefile column to a bounded-GPCM source, caveat, or explicit unavailable status.",
      "Keep full FACETS output-contract review blocked until all required_for_full_facets_review rows are satisfied.",
      "Keep sensitivity-model output separate from operational scoring and FACETS equivalence claims."
    ),
    CurrentStatus = c(
      rep("implemented_with_caveat", 4L),
      "required_for_full_facets_review",
      "validated_dependency",
      "validated_dependency",
      "implemented_with_caveat",
      "validated_dependency",
      "implemented_with_caveat"
    ),
    ReleaseBoundary = c(
      "scorefile_supported_with_caveat",
      "scorefile_supported_with_caveat",
      "scorefile_supported_with_caveat",
      "scorefile_supported_with_caveat",
      "full_facets_review_blocked",
      "available as fair_average_table(fair_se = TRUE), not as scorefile support",
      "available as reduction evidence, not as scorefile support",
      "scorefile_supported_with_caveat",
      "active guard for full FACETS review",
      "scorefile_supported_with_caveat"
    ),
    ValidationTarget = c(
      "A named estimand and interpretation note for every exported bounded-GPCM scorefile quantity.",
      "A deterministic scorefile contract with slope handling and identification conventions.",
      "Native delta-method expected-score SEs and corrected score-scale delta SEs where MML diagnostics are available, with explicit not_requested/unavailable status otherwise.",
      "A fixed external comparison artifact covering `mirt::probtrace()` with `tau_k = b_k`, TAM `tam.mml.2pl(..., irtmodel = \"GPCM\")` `rprobs` with `tau_k = beta + tau.Cat_k`, and `eRm` as PCM/CML boundary evidence only; these packages are not treated as many-facet MFRM comparators.",
      "A FACETS-compatible free-discrimination score metric plus uncertainty policy for contract-wide review fields.",
      "Agreement checks that structural fair-average SE columns are present only when supported by the fitted object.",
      "Numerical agreement checks showing bounded-GPCM unit-slope score-side quantities reduce to the PCM route.",
      "A column contract that separates available, caveated, and unavailable bounded-GPCM scorefile fields.",
      "Structured mfrmr_gpcm_scope_error before full FACETS output-contract review work begins.",
      "NEWS, README, help pages, and validation artifacts that prevent operational scoring overclaims."
    ),
    ExitCriterion = c(
      "Scorefile help pages can name the bounded-GPCM estimand without borrowing Rasch-family wording.",
      "Tests cover slope variation, slope_facet identification, expected-score conversion, and boundary categories.",
      "Tests cover finite native expected-score SEs, ScoreSlope * Var * eta_se score-side SEs, and explicit not_requested/unavailable status where not available.",
      "gpcm-score-side-external-comparison-0.2.2.md records status ok, mirt/TAM mapped-kernel rows, eRm PCM/CML boundary status, and zero failed checks without claiming many-facet MFRM or FACETS score-side equivalence.",
      "facets_output_contract_review() can report bounded-GPCM score-side uncertainty without borrowing Rasch-family SE semantics.",
      "The fair-average SE route remains traceable and does not imply FACETS score-side equivalence.",
      "Unit-slope bounded-GPCM fixtures match PCM score-side outputs within stated tolerance.",
      "facets_output_contract_review() can report bounded-GPCM score rows without silently emitting unsupported fields.",
      "gpcm_runtime_guard_coverage() and score-side helper errors remain synchronized with gpcm_capability_matrix().",
      "Release wording states whether the route is supported, supported_with_caveat, or still blocked."
    ),
    stringsAsFactors = FALSE
  )

  if (!identical(status, "all")) {
    out <- out[out$CurrentStatus == status, , drop = FALSE]
  }

  rownames(out) <- NULL
  out
}

#' Model-family scope and boundary table
#'
#' @description
#' Scope table separating the current `mfrmr` ordered-response model scope
#' from future model-family extensions. Use this helper when deciding whether
#' a requested model is part of bounded `GPCM`, a candidate Rasch-family
#' design-matrix extension, a rater-dependence model, an unfolding/ideal-point
#' model, or a mixture/latent-class model.
#'
#' @details
#' The table is deliberately conservative. It prevents a common scope error:
#' treating every polytomous, rater, or mixture model as if it were simply
#' "more GPCM." Complete package-native `GPCM` support remains the first
#' extension target inside the current likelihood family, but models such as
#' Samejima's graded response model, Bock's nominal response model,
#' continuation-ratio models, hierarchical rater models, rater bundle models,
#' GGUM / hyperbolic-cosine unfolding models, MRCMLM, LLTM/LPCM, and mixture
#' Rasch models require separate likelihood, identification, estimation,
#' reporting, and validation contracts.
#'
#' @param lane Which scope lane to return: `"all"` (default),
#'   `"current"`, `"gpcm"`, `"rasch_design"`, `"polytomous_irt"`,
#'   `"rater_dependence"`, `"unfolding"`, or `"mixture"`.
#'
#' @return A data.frame with one row per model family and columns:
#' - `Lane`
#' - `ModelFamily`
#' - `CurrentStatus`
#' - `RelationshipToGPCM`
#' - `CurrentSurface`
#' - `ReleaseTier`
#' - `RequiredWork`
#' - `SourceBasis`
#' - `RecommendedPositioning`
#'
#' @examples
#' mfrmr_model_family_scope()
#' mfrmr_model_family_scope("gpcm")
#' mfrmr_model_family_scope("rater_dependence")
#' @seealso [gpcm_capability_matrix()], [gpcm_score_side_contract()],
#'   [mfrmr_estimation_scope()], [fit_mfrm()]
#' @concept GPCM boundaries
#' @concept route selection
#' @export
mfrmr_model_family_scope <- function(lane = c(
  "all", "current", "gpcm", "rasch_design", "polytomous_irt",
  "rater_dependence", "unfolding", "mixture"
)) {
  lane <- match.arg(lane)

  out <- data.frame(
    LaneKey = c(
      "current",
      "gpcm",
      "polytomous_irt",
      "polytomous_irt",
      "polytomous_irt",
      "rater_dependence",
      "rater_dependence",
      "rater_dependence",
      "rater_dependence",
      "unfolding",
      "unfolding",
      "rasch_design",
      "rasch_design",
      "rasch_design",
      "mixture"
    ),
    Lane = c(
      "Current ordered-response scope",
      "GPCM completion",
      "Alternative polytomous IRT",
      "Alternative polytomous IRT",
      "Alternative polytomous IRT",
      "Rater-dependence and latent-process models",
      "Rater-dependence and latent-process models",
      "Rater-dependence and latent-process models",
      "Rater-dependence and latent-process models",
      "Unfolding and ideal-point models",
      "Unfolding and ideal-point models",
      "Rasch-family design-matrix extensions",
      "Rasch-family design-matrix extensions",
      "Rasch-family design-matrix extensions",
      "Mixture and latent-class models"
    ),
    ModelFamily = c(
      "RSM / PCM / bounded GPCM",
      "Complete unrestricted GPCM",
      "Graded Response Model",
      "Nominal Response Model",
      "Sequential / continuation-ratio model",
      "Hierarchical Rater Model",
      "Rater latent-class / signal-detection model",
      "Rater Bundle Model",
      "Facet interaction / bias models",
      "Hyperbolic Cosine Model",
      "Generalized Graded Unfolding Model",
      "MRCMLM",
      "LLTM",
      "LPCM",
      "Mixture / Mixed Rasch model"
    ),
    CurrentStatus = c(
      "implemented_with_gpcm_caveats",
      "deferred",
      "not_implemented",
      "not_implemented",
      "not_implemented",
      "not_implemented",
      "not_implemented",
      "not_implemented",
      "partially_implemented_for_RSM_PCM",
      "not_implemented",
      "not_implemented",
      "not_implemented",
      "not_implemented",
      "not_implemented",
      "not_implemented"
    ),
    RelationshipToGPCM = c(
      paste(
        "Current public model surface; GPCM is bounded by",
        "`slope_facet == step_facet` and geometric-mean-one slopes."
      ),
      paste(
        "Same adjacent-category family as bounded GPCM, but requires general",
        "slope designs, covariance propagation, score-side contracts, and",
        "downstream helper closure."
      ),
      paste(
        "Different cumulative-category likelihood; not a GPCM completion task."
      ),
      paste(
        "Unordered nominal/multinomial likelihood; explicitly outside the",
        "current ordered-response scope."
      ),
      paste(
        "Different process model for ordered steps or attempts; not the same",
        "as `step_facet` in PCM/GPCM."
      ),
      paste(
        "Hierarchical rater-stage model; not reducible to a single bounded",
        "GPCM slope table."
      ),
      paste(
        "Latent-class perceptual or signal-detection rater model; current",
        "signal-detection helpers are simulation screens, not this estimator."
      ),
      paste(
        "Repeated-rating dependence model; current local-dependence screens",
        "are diagnostics, not a bundle-model likelihood."
      ),
      paste(
        "Bias/interactions can be adjacent to GPCM diagnostics, but current",
        "model-estimated interactions are RSM/PCM-only."
      ),
      paste(
        "Ideal-point/unfolding response family; not an adjacent-category",
        "dominance model."
      ),
      paste(
        "General graded unfolding likelihood; separate from GPCM despite",
        "graded categories and item discrimination."
      ),
      paste(
        "Potential unifying Rasch-family design-matrix framework; broader",
        "than the current `fit_mfrm()` model switch."
      ),
      paste(
        "Linear constraints on Rasch item/facet parameters; compatible with",
        "a future design-matrix lane, not a GPCM slope extension."
      ),
      paste(
        "Linear constraints on PCM step parameters; a plausible medium-term",
        "Rasch-family extension after design-matrix infrastructure exists."
      ),
      paste(
        "Latent-class heterogeneity model; explicitly outside current",
        "mixture-free `mfrmr` scope."
      )
    ),
    CurrentSurface = c(
      "fit_mfrm(model = c(\"RSM\", \"PCM\", \"GPCM\")); gpcm_capability_matrix()",
      "gpcm_capability_matrix(); gpcm_score_side_contract(); scope artifact",
      "none",
      "none",
      "none",
      "none",
      "evaluate_mfrm_signal_detection() only as design-screening simulation",
      "Q3/local-dependence diagnostics only as screens",
      "facet_interactions for RSM/PCM; estimate_bias() and DFF screens",
      "none",
      "none",
      "none",
      "none",
      "none",
      "person-fit, residual, drift, and DFF screens only; no mixture estimator"
    ),
    ReleaseTier = c(
      "current",
      "post_0.2.2_core_candidate",
      "post_gpcm_candidate",
      "post_gpcm_candidate",
      "post_gpcm_candidate",
      "long_term_heavy_backend",
      "long_term_heavy_backend",
      "long_term_heavy_backend",
      "current_partial_then_gpcm_extension",
      "research_only",
      "research_only",
      "medium_term_architecture_candidate",
      "medium_term_architecture_candidate",
      "medium_term_architecture_candidate",
      "long_term_heavy_backend"
    ),
    RequiredWork = c(
      paste(
        "Keep current capability matrix, runtime guards, caveats, and",
        "draw-free output contracts synchronized."
      ),
      paste(
        "General slope design, identification/covariance basis, estimation",
        "coverage, many-facet integration, downstream helper closure, and",
        "external/simulation evidence."
      ),
      paste(
        "Cumulative-threshold likelihood, discrimination/threshold",
        "identification, information/residual definitions, fit and reporting",
        "contracts, external comparisons."
      ),
      paste(
        "Nominal-category likelihood, alternative-specific parameters,",
        "unordered-score data contract, scoring and visualization semantics."
      ),
      paste(
        "Continuation-ratio likelihood, process interpretation, attempt/step",
        "data contract, residual and category-curve definitions."
      ),
      paste(
        "Two-stage or hierarchical likelihood, rater consistency/severity",
        "parameters, uncertainty propagation, and MCMC or equivalent backend."
      ),
      paste(
        "Latent-class SDT likelihood, class identification, rater precision",
        "parameters, posterior classification, and separate reporting language."
      ),
      paste(
        "Local-dependence bundle likelihood for repeated ratings, dependence",
        "variance, reliability correction, and model-checking evidence."
      ),
      paste(
        "Current model-estimated interactions are RSM/PCM-only; extend",
        "fixed-effect interactions beyond RSM/PCM only after GPCM",
        "identification, covariance, and downstream helper semantics are stable."
      ),
      paste(
        "Define ideal-point likelihood, scale orientation, person/item",
        "location interpretation, and non-monotone curve diagnostics."
      ),
      paste(
        "GGUM likelihood, threshold/discrimination identification, EAP/MML or",
        "Bayesian estimation, unfolding-specific fit and visualization."
      ),
      paste(
        "Design-matrix parameterization, multidimensional random coefficients,",
        "constraint parser, engine support, and reduction tests."
      ),
      paste(
        "Linear constraint matrix for item/facet difficulty components,",
        "hypothesis tests, and import/export/reporting contracts."
      ),
      paste(
        "Linear step-parameter constraints for PCM, design-matrix API,",
        "identification checks, and reduction tests."
      ),
      paste(
        "Mixture likelihood, class-count selection, label-switching controls,",
        "class-specific parameters, and model-checking evidence."
      )
    ),
    SourceBasis = c(
      "Andrich 1978; Masters 1982; Muraki 1992/1993; Linacre MFRM",
      "Muraki 1992/1993",
      "Samejima 1969",
      "Bock 1972",
      "Tutz 1990",
      "Patz, Junker, Johnson, and Mariano 2002",
      "DeCarlo signal-detection rater-model literature",
      "Wilson and Hoskens 2001",
      "Linacre FACETS bias/interactions; MFRM bias literature",
      "Hyperbolic-cosine unfolding literature",
      "Roberts, Donoghue, and Laughlin 2000",
      "Adams, Wilson, and Wang 1997",
      "Fischer 1973",
      "Linear partial-credit extensions of PCM",
      "Rost 1990"
    ),
    RecommendedPositioning = c(
      "Document as the current supported ordered-response scope.",
      "Treat as the next in-family GPCM completion target, not as 0.2.2 done.",
      "Track as an alternative ordered polytomous IRT family after GPCM scope stabilizes.",
      "Track as a separate unordered-response family; do not imply binary support is nominal support.",
      "Track as a separate sequential process model.",
      "Track as a rater-process model requiring a new estimation layer.",
      "Keep separate from current signal-detection simulation screens.",
      "Use current diagnostics only as evidence of need, not as model substitutes.",
      "Keep current RSM/PCM interaction support explicit; defer GPCM interactions.",
      "Keep as research-only unless the package adds ideal-point modeling.",
      "Keep as research-only unless the package adds unfolding estimation.",
      "Evaluate as an architectural umbrella, not a small feature.",
      "Candidate after a general design-matrix parameterization exists.",
      "Candidate after a general design-matrix parameterization exists.",
      "Do not advertise as supported; current screens are not mixture substitutes."
    ),
    stringsAsFactors = FALSE
  )

  if (!identical(lane, "all")) {
    out <- out[out$LaneKey == lane, , drop = FALSE]
  }
  out$LaneKey <- NULL
  rownames(out) <- NULL
  out
}

#' Estimation and backend scope table
#'
#' @description
#' Scope table separating currently implemented likelihood estimators from
#' future conditional, pairwise/composite, Bayesian/Stan, nonparametric,
#' and latent-class estimation extensions.
#'
#' @details
#' This helper is intentionally about estimation method and backend scope, not
#' about response-model family scope. `Stan` integration belongs here: it would
#' provide a Bayesian heavy-backend route for models whose posterior uncertainty,
#' hierarchical structure, or posterior-predictive checks are not well served by
#' the current `JMLE`/`MMLE` surface. It should not be advertised as a drop-in
#' replacement for the package-native maximum-likelihood estimators until the
#' data contract, priors, identification, convergence diagnostics, posterior
#' summaries, and external validation are all specified.
#'
#' The current `MMLE` row also separates ordinary fixed-prior MML from active
#' latent-regression MML. With `population_formula = NULL`, `mfrmr` uses a
#' fixed normal latent prior by default (`population_prior_sd = 1`) or an
#' opt-in estimated normal population SD for additive RSM/PCM and bounded-GPCM
#' EM fits.
#' Supplying `population_formula` activates the latent-regression branch,
#' where the conditional residual variance `sigma2` is estimated.
#'
#' A separate latent-distribution row records the opt-in free normal
#' population-SD route for additive MML. This is not a configurable EAP
#' scoring prior: it changes the fitting metric itself. The implemented target
#' is RSM/PCM and bounded GPCM under EM with the fixed-SD default preserved for
#' backward compatibility; latent-regression, model-estimated facet
#' interactions, and direct/hybrid free-SD extensions require separate work.
#'
#' The nonparametric rows deliberately separate two different ideas. A
#' parametric item/facet response function with a nonparametric latent
#' distribution is a discrete or flexible mixing-distribution extension to MML.
#' A nonparametric response function changes the item/category curve itself and
#' is better treated first as an exploratory diagnostic before becoming an
#' estimator. Latent-class and mixture Rasch models add class-specific
#' parameters and therefore require a separate likelihood and reporting
#' contract.
#'
#' @param lane Which estimation lane to return: `"all"` (default),
#'   `"current"`, `"conditional"`, `"pairwise"`, `"bayesian"`,
#'   `"latent_distribution"`, `"nonparametric"`, `"mixture"`,
#'   `"scoring"`, or `"uncertainty"`.
#'
#' @return A data.frame with one row per estimation route and columns:
#' - `Lane`
#' - `Method`
#' - `CurrentStatus`
#' - `ModelScope`
#' - `RelationshipToCurrent`
#' - `ReleaseTier`
#' - `Benefit`
#' - `Risk`
#' - `RequiredWork`
#' - `SourceBasis`
#' - `RecommendedPositioning`
#'
#' @examples
#' mfrmr_estimation_scope()
#' mfrmr_estimation_scope("conditional")
#' mfrmr_estimation_scope("bayesian")
#' @seealso [mfrmr_model_family_scope()], [gpcm_capability_matrix()],
#'   [fit_mfrm()]
#' @concept estimation
#' @concept route selection
#' @export
mfrmr_estimation_scope <- function(lane = c(
  "all", "current", "conditional", "pairwise", "bayesian",
  "latent_distribution", "nonparametric", "mixture", "scoring",
  "uncertainty"
)) {
  lane <- match.arg(lane)

  out <- data.frame(
    LaneKey = c(
      "current",
      "current",
      "latent_distribution",
      "conditional",
      "pairwise",
      "scoring",
      "scoring",
      "scoring",
      "uncertainty",
      "bayesian",
      "nonparametric",
      "nonparametric",
      "mixture"
    ),
    Lane = c(
      "Current package-native maximum likelihood",
      "Current package-native maximum likelihood",
      "Parametric latent-distribution calibration",
      "Conditional likelihood for Rasch-family models",
      "Pairwise or composite conditional likelihood",
      "Person scoring and shrinkage",
      "Person scoring and shrinkage",
      "Person scoring and shrinkage",
      "Uncertainty and standard-error contracts",
      "Bayesian heavy-backend integration",
      "Nonparametric latent distribution",
      "Nonparametric response-function diagnostics",
      "Mixture and latent-class estimation"
    ),
    Method = c(
      "JMLE",
      "MMLE",
      "Free normal population SD for additive MML",
      "CMLE",
      "PMLE / pairwise composite likelihood",
      "WLE / MAP / EAP scoring",
      "Configurable EAP / reference prior",
      "EAP prior/likelihood power sensitivity",
      "Unified structural and integrated person SE contract",
      "Stan / cmdstanr backend",
      "NPML or discrete latent distribution under parametric IRFs",
      "Kernel-smoothed empirical IRFs",
      "Mixture / mixed Rasch estimation"
    ),
    CurrentStatus = c(
      "implemented",
      "implemented",
      "implemented_for_RSM_PCM_GPCM_EM",
      "not_implemented",
      "not_implemented",
      "partially_implemented",
      "not_implemented",
      "implemented_scoring_diagnostic",
      "partially_implemented_for_MML",
      "not_implemented",
      "not_implemented",
      "diagnostic_candidate",
      "not_implemented"
    ),
    ModelScope = c(
      "RSM / PCM / bounded GPCM as currently exposed by fit_mfrm()",
      "RSM / PCM / bounded GPCM as currently exposed by fit_mfrm()",
      paste(
        "Additive MML with `population_formula = NULL`; RSM/PCM and",
        "bounded GPCM under EM."
      ),
      "Start with RSM and PCM; not a natural target for free-slope GPCM",
      "RSM/PCM sparse designs first, then design-matrix Rasch-family extensions",
      "Person/facet score summaries and plausible values, not a new response model",
      paste(
        "Prediction and plausible-value scoring first; core MML calibration",
        "prior only after sensitivity evidence and output-contract review"
      ),
      paste(
        "Fixed-calibration EAP sensitivity for RSM / PCM / bounded GPCM",
        "scoring paths, not a new model or refit estimator"
      ),
      paste(
        "MML non-person structural SEs and EAP posterior SDs exist; JML",
        "person/facet SEs remain exploratory and not yet integrated under one",
        "formal contract"
      ),
      paste(
        "Bayesian MFRM, complete GPCM, hierarchical rater, mixture, and",
        "posterior-predictive validation routes after native contracts are stable"
      ),
      paste(
        "Parametric RSM/PCM/GPCM item-category functions with a flexible",
        "latent distribution"
      ),
      paste(
        "Empirical item/category curves for diagnostics and visualization,",
        "not immediate operational scoring"
      ),
      "Latent-class Rasch/MFRM variants with class-specific parameters"
    ),
    RelationshipToCurrent = c(
      "Baseline package-native joint likelihood route.",
      paste(
        "Baseline package-native marginal likelihood route using quadrature.",
        "With `population_formula = NULL`, the unconditional latent prior is",
        "fixed to standard normal scale (SD = 1). Supplying",
        "`population_formula` activates the latent-regression branch, where",
        "conditional residual variance `sigma2` is estimated."
      ),
      paste(
        "Current ordinary MMLE fixes the latent scale by default through",
        "`population_prior_sd = 1`, or estimates sigma under a normal latent",
        "distribution when explicitly requested. Active",
        "latent-regression MML already estimates conditional residual",
        "variance `sigma2` in the direct branch."
      ),
      paste(
        "Conditions on sufficient raw scores and avoids a latent-distribution",
        "assumption for Rasch-family RSM/PCM."
      ),
      paste(
        "Composite-likelihood route that can be useful for sparse or",
        "large-scale Rasch-family designs, with different SE semantics."
      ),
      paste(
        "Adds or clarifies person-estimation estimators after item/facet",
        "parameters are fixed or estimated."
      ),
      paste(
        "Current posterior scoring uses either the fitted latent-regression",
        "population model or a fixed standard normal reference prior. A",
        "configurable prior would change EAP, posterior SDs, intervals, and",
        "plausible-value draws even when the calibration is held fixed."
      ),
      paste(
        "`analyze_eap_power_sensitivity()` renormalizes the existing",
        "quadrature-grid posterior under prior and likelihood powers and",
        "reports deltas from the unscaled EAP reference. It does not refit",
        "the calibration or expose arbitrary prior families."
      ),
      paste(
        "Current SE columns mix different conditioning targets: MML non-person",
        "structural SEs use marginal observed information, MML person SEs are",
        "posterior SDs conditional on calibration, and JML SEs use",
        "observation-table approximations. A unified display needs separate",
        "estimand labels, not a single interchangeable SE."
      ),
      paste(
        "Separate backend for posterior inference, priors, hierarchical",
        "variance components, posterior predictive checks, and sensitivity",
        "analyses; not a silent replacement for JMLE/MMLE."
      ),
      paste(
        "Keeps the parametric response model but replaces the normal or fixed",
        "latent distribution with estimated mass points or flexible mixing."
      ),
      paste(
        "Changes the empirical curve-estimation layer rather than the core",
        "parametric likelihood; best introduced as visual/model-check evidence."
      ),
      paste(
        "Adds class membership and class-specific parameters, so it is broader",
        "than a nonparametric latent distribution for one common parameter set."
      )
    ),
    ReleaseTier = c(
      "current",
      "current",
      "0.4_metric_calibration",
      "post_0.2.2_medium_priority",
      "post_cmle_candidate",
      "post_0.2.2_incremental",
      "post_0.2.2_design_candidate",
      "post_0.2.2_scoring_diagnostic",
      "post_0.2.2_contract_candidate",
      "post_0.4_heavy_backend_candidate",
      "post_cmle_or_mml_extension_candidate",
      "post_visual_diagnostics_candidate",
      "long_term_heavy_backend"
    ),
    Benefit = c(
      "Fast exploratory fixed-effect calibration and direct person estimates.",
      "Consistent structural calibration route for the current package scope.",
      "Makes the latent metric data-determined for cross-engine comparisons while preserving fixed-SD backward compatibility by default.",
      "Distribution-free Rasch-family item/facet estimation under sufficient-score conditioning.",
      "Scales to sparse or large Rasch-family designs when full likelihood is expensive.",
      "Gives users explicit control over point-estimation bias and shrinkage after calibration.",
      "Supports sensitivity analysis for sparse persons, policy-relevant reference populations, and plausible-value summaries.",
      "Provides a low-cost robustness check for prior-sensitive EAP scores without changing fitted calibrations.",
      "Prevents users from comparing MML person posterior SDs, MML structural SEs, and JML exploratory SEs as if they were one quantity.",
      "Opens Bayesian posterior uncertainty, hierarchical structures, and posterior-predictive checks.",
      "Reduces misspecification from a fixed normal latent distribution while keeping parametric IRFs.",
      "Shows empirical item/category shape without committing to a new estimator.",
      "Models unobserved heterogeneity when one common parameter set is implausible."
    ),
    Risk = c(
      "Incidental-parameter bias and unstable extremes make formal reporting fragile.",
      "The current default fixes the unconditional latent SD, so population-spread claims are limited unless latent regression is active.",
      "Changes the scale of person EAPs, posterior SDs, fit summaries, reliability displays, plausible values, and information criteria; outputs must record the SD mode and estimated SD.",
      "Does not generalize cleanly to free-slope GPCM and can be harder to extend to incomplete many-facet designs.",
      "Composite SEs are not ordinary likelihood SEs; misuse can overstate precision.",
      "Different estimators answer different questions; mixing WLE/MAP/EAP labels can confuse reporting.",
      "Can make scores prior-sensitive and break comparability across analyses unless the prior is recorded in every output.",
      "Grid-based power scaling is a scoring diagnostic, not a full Bayesian sensitivity workflow or evidence for a refit model.",
      "A single unified SE column would be misleading unless it records conditioning, structural uncertainty, and posterior uncertainty separately.",
      "Adds toolchain, prior, convergence, and reproducibility burden.",
      "Can absorb item/facet misfit into the latent distribution and hide model problems.",
      "Sparse bins and smoothing choices can create visually persuasive artifacts.",
      "Label switching, class-count choice, and class-specific interpretation can dominate the substantive result."
    ),
    RequiredWork = c(
      "Keep reduction tests, convergence diagnostics, and output contracts synchronized.",
      paste(
        "Keep quadrature, covariance, fair-average SE, and bounded-GPCM",
        "caveats synchronized; keep default fixed-SD MML wording separate",
        "from active latent-regression MML where `sigma2` is estimated."
      ),
      paste(
        "Keep fixed-SD numeric regression tests, EM-only RSM/PCM and",
        "bounded-GPCM recovery tests, conditional/profile sigma SE/CI",
        "tests, GPCM log-slope identification checks, AIC/BIC and",
        "compare_mfrm() parameter-count checks, and reporting wording",
        "synchronized. Future work: latent-regression, facet-interaction,",
        "and direct/hybrid free-SD contracts."
      ),
      paste(
        "Conditional sufficient-score likelihood for RSM/PCM, connectivity",
        "checks, identification constraints, conditional SEs, and comparisons",
        "with established CML implementations."
      ),
      paste(
        "Define pairwise conditioning set, composite score equations, sandwich",
        "or Godambe SEs, sparse-design failure modes, and comparison targets."
      ),
      paste(
        "Define estimator labels, bias/variance behavior, fixed-parameter",
        "versus refit semantics, and reporting language."
      ),
      paste(
        "Define prior API, allowed distribution families, prior provenance",
        "columns, sensitivity defaults, interval wording, and guardrails",
        "against changing the scoring prior while implying recalibration."
      ),
      paste(
        "Maintain the fixed-calibration contract, reference-condition deltas,",
        "input validation, documentation that separates quadrature",
        "renormalization from priorsense-style PSIS diagnostics, and tests",
        "for MML, JML, and latent-regression scoring paths."
      ),
      paste(
        "Define an uncertainty contract separating structural calibration SE,",
        "posterior person SD, integrated person uncertainty, JML fixed-effect",
        "information, and bootstrap/sandwich alternatives; add tests that",
        "prevent incompatible SEs from sharing an unlabeled column."
      ),
      paste(
        "Stan data writer, generated Stan programs, cmdstanr optional",
        "dependency handling, priors, constraints, posterior summaries,",
        "diagnostics, posterior-predictive checks, and equivalence tests",
        "against package-native routes where models overlap."
      ),
      paste(
        "Mass-point or flexible distribution parameterization, EM or MML",
        "updates, identifiability controls, information criteria, and",
        "simulation evidence separating distribution misspecification from",
        "item/facet misfit."
      ),
      paste(
        "Smoothing choices, bandwidth rules, uncertainty bands, sparse-score",
        "guardrails, and explicit wording that empirical curves are diagnostics."
      ),
      paste(
        "Class-count selection, label-switching controls, class-specific",
        "parameter contracts, posterior classification uncertainty, and",
        "model-checking evidence."
      )
    ),
    SourceBasis = c(
      "Linacre MFRM; package validation artifacts",
      "Bock and Aitkin 1981; package validation artifacts",
      "Bock and Aitkin 1981; TAM variance.fixed/est.variance documentation; ACER ConQuest population-model documentation; mirt Rasch/factor-variance documentation",
      "Andersen 1970/1972; eRm conditional maximum-likelihood implementation",
      "Pairwise/composite likelihood literature for Rasch-family estimation",
      "Warm 1989; Bayesian/MML person scoring practice",
      "Bock and Mislevy 1982; Mislevy 1991 plausible-values literature",
      "Kallioinen et al. 2023 power-scaling sensitivity; priorsense package; Bock and Mislevy 1982 EAP scoring",
      "Bock and Mislevy 1982; Warm 1989; MML observed-information practice; Snijders-style person-fit caveats",
      "Stan Reference Manual/User's Guide; cmdstanr interface documentation; Stan IRT examples",
      "Lindsay NPML tradition; latent-distribution MML extensions",
      "Ramsay 1991 kernel-smoothed item-response functions",
      "Rost 1990 mixed Rasch model"
    ),
    RecommendedPositioning = c(
      "Advertise as supported within the existing caveats.",
      "Advertise as supported within the existing caveats.",
      paste(
        "Advertise as opt-in additive MML metric calibration under EM for",
        "RSM/PCM and the current bounded-GPCM branch. Do not advertise as",
        "complete-GPCM support, latent-regression free-SD support, or an",
        "arbitrary prior-family API."
      ),
      paste(
        "Treat as an important 0.4.0+ RSM/PCM estimator candidate, not as",
        "part of complete free-slope GPCM."
      ),
      "Treat as a later sparse-design/composite-likelihood route after CMLE is scoped.",
      "Treat as scoring-estimator refinement, not as a new model family.",
      paste(
        "Introduce first as an explicit scoring-only sensitivity option for",
        "`predict_mfrm_units()` / `sample_mfrm_plausible_values()`. Do not",
        "make the fitting prior configurable until calibration equivalence,",
        "identification, and report wording are validated."
      ),
      paste(
        "Advertise as `analyze_eap_power_sensitivity()` for scoring-stage",
        "robustness checks. Keep wording explicit that it is quadrature-grid",
        "power scaling and not a new MML prior, MAP estimator, or refit."
      ),
      paste(
        "Do not collapse MML and JML uncertainty into one SE claim. Add a",
        "contracted uncertainty table with estimand, conditioning basis,",
        "calibration-included flag, and reporting-use guidance."
      ),
      paste(
        "Include in scope as an optional heavy-backend bridge, initially for",
        "validation, Bayesian sensitivity, and models that need hierarchical",
        "or posterior-predictive machinery."
      ),
      paste(
        "Treat as an MML latent-distribution extension before claiming",
        "mixture-model support."
      ),
      paste(
        "Introduce through ggplot2 diagnostics and simulation checks before",
        "operational estimation."
      ),
      "Keep separate from NPML latent-distribution support and do not advertise as current."
    ),
    stringsAsFactors = FALSE
  )

  if (!identical(lane, "all")) {
    out <- out[out$LaneKey == lane, , drop = FALSE]
  }
  out$LaneKey <- NULL
  rownames(out) <- NULL
  out
}

#' Bounded GPCM Route-Boundary Coverage
#'
#' @description
#' Public table showing how blocked or deferred bounded-`GPCM` capability rows
#' are handled by the current release.
#'
#' @details
#' `gpcm_capability_matrix()` is the user-facing support matrix. This helper
#' records which public helpers stop with `mfrmr_gpcm_scope_error` when called
#' on a bounded `GPCM` path and which capability rows have no public route yet
#' and are therefore documented as future-extension scope.
#'
#' Package checks use this table to keep out-of-scope `GPCM` behavior aligned
#' with the capability matrix. A row with `GuardMode = "runtime_error"` should
#' have `ExpectedConditionClass = "mfrmr_gpcm_scope_error"`. A row with
#' `GuardMode = "roadmap_only"` records a documented future-extension target
#' with no public helper to call in the current release.
#'
#' @return A data.frame with columns:
#' - `Area`
#' - `Helper`
#' - `Status`
#' - `GuardMode`
#' - `ExpectedConditionClass`
#' - `RecommendedRoute`
#' - `NextValidationStep`
#' - `TestRoute`
#' - `Notes`
#'
#' @seealso [gpcm_capability_matrix()], [mfrmr_workflow_methods],
#'   [mfrmr-package]
#' @examples
#' gpcm_runtime_guard_coverage()
#' @export
gpcm_runtime_guard_coverage <- function() {
  matrix <- gpcm_capability_matrix()
  guard <- data.frame(
    Area = c(
      "FACETS output-contract score-side review",
      "MCMC and heavy-backend extensions"
    ),
    Helper = c(
      "facets_output_contract_review()",
      NA_character_
    ),
    GuardMode = c(
      "runtime_error",
      "roadmap_only"
    ),
    ExpectedConditionClass = c(
      "mfrmr_gpcm_scope_error",
      NA_character_
    ),
    TestRoute = c(
      "minimal mfrm_fit",
      "no public runtime helper in 0.2.2"
    ),
    Notes = c(
      "Full FACETS score-side contract review is intentionally unavailable for bounded GPCM; see gpcm_score_side_contract().",
      "Documented as future-extension scope until a public backend/MCMC helper is exposed."
    ),
    stringsAsFactors = FALSE
  )

  idx <- match(guard$Area, matrix$Area)
  guard$Status <- matrix$Status[idx]
  guard$RecommendedRoute <- matrix$RecommendedRoute[idx]
  guard$NextValidationStep <- matrix$NextValidationStep[idx]
  guard <- guard[, c(
    "Area", "Helper", "Status", "GuardMode", "ExpectedConditionClass",
    "RecommendedRoute", "NextValidationStep", "TestRoute", "Notes"
  )]
  rownames(guard) <- NULL
  guard
}
