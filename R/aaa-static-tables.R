








.mfrmr_table_.gpcm_capability_registry_out <- data.frame(CapabilityID = c("core_fit_summary", "exploratory_diagnostics", 
    "fixed_calibration_scoring", "curve_category_views", "summary_appendix", "misfit_casebook", "weighting_model_choice", 
    "linking_synthesis", "simulation_recovery", "apa_export_bundles", "fair_average", "design_forecasting", 
    "diagnostic_signal_screening", "dff_screening", "mcmc_backends", "residual_bias_screening", "scorefile_export", 
    "facets_score_review", "optimization_replay", "portable_calibration", "multiple_slope_families", 
    "corrected_jml_inference", "gpcm_em_fitting"), Area = c("Core fitting and summaries", "Exploratory diagnostics and residual follow-up", 
    "Fitted-object posterior scoring and information", "Core curve and category views", "Checklist and summary-table appendix route", 
    "Operational misfit casebook", "Weighting review and model-choice review", "Operational linking synthesis", 
    "Direct simulation-spec generation and recovery", "APA writer and fit-based export bundles", "Fair-average semantics under GPCM (slope-aware)", 
    "Design evaluation and population forecasting under GPCM", "Diagnostic and signal-detection design screening under GPCM", 
    "Differential facet functioning screening under GPCM", "Native MCMC and posterior-predictive sampling", 
    "Residual-bias screening under GPCM", "Score-side scorefile export under GPCM", "FACETS output-contract score-side review", 
    "Replayed optimization diagnostics under GPCM", "Portable calibration and later-person scoring", 
    "Simultaneous estimation of multiple slope families", "Formal structural confidence intervals for corrected JML", 
    "GPCM fitting with EM or hybrid optimization"), Helpers = c("fit_mfrm(model = \"GPCM\"); summary(); print(); confint(parm = \"slopes\")", 
    paste("diagnose_mfrm(); analyze_residual_pca(); unexpected_response_table();", "displacement_table(); measurable_summary_table();", 
        "rating_scale_table(); interrater_agreement_table();", "facet_quality_dashboard(); plot(x, type = \"qc\");", 
        "plot(x, type = \"marginal_fit\"); plot(x, type = \"marginal_pairwise\")"), "predict_mfrm_units(); sample_mfrm_plausible_values(); compute_information(); plot(x)", 
    paste("plot(fit, type = c(\"wright\", \"pathway\", \"ccc\", \"ccc_surface\"));", "mfrm_report(fit, type = 'category_structure'); mfrm_report(fit, type = 'category_curves');", 
        "facets_output_file_bundle(include = \"graph\")"), "mfrm_report(fit, type = 'checklist'); mfrm_report(fit, type = 'precision'); build_summary_table_bundle(); export_summary_appendix()", 
    "build_misfit_casebook()", "compare_mfrm(); build_model_choice_review(); build_weighting_review(); compute_information(); plot(x); build_summary_table_bundle(); export_summary_appendix()", 
    "build_linking_review()", "build_mfrm_sim_spec(); extract_mfrm_sim_spec(); simulate_mfrm_data(); simulate_mfrm_recovery(); assess_mfrm_recovery()", 
    paste("mfrm_results(include = \"gpcm_review\"); mfrm_report();", "export_mfrm_results(); build_apa_outputs(); build_visual_summaries();", 
        "run_qc_pipeline(); build_mfrm_manifest(); build_mfrm_replay_script();", "export_mfrm_bundle()"), 
    "fair_average_table()", "evaluate_mfrm_design(); predict_mfrm_population()", "evaluate_mfrm_diagnostic_screening(); evaluate_mfrm_signal_detection()", 
    "analyze_dff(); dif_interaction_table(); mfrm_report(dif, type = 'dff'); plot(x, type = \"heatmap\"); plot(x, type = \"summary\")", 
    NA_character_, "estimate_all_bias(); estimate_bias(); summary(); plot(); unexpected_after_bias_table()", 
    "facets_output_file_bundle(include = \"score\")", "facets_output_contract_review()", "mfrm_report(fit, type = 'iterations')", 
    paste("mfrmr_output_guide(\"calibration_capabilities\"); extract_mfrm_calibration();", "save_mfrm_calibration(); load_mfrm_calibration(); score_mfrm_calibration()"), 
    "fit_mfrm(); summary(); mfrm_curve_intervals(); mfrm_response_diagnostics(); predict_mfrm_units(); sample_mfrm_plausible_values(); extract_mfrm_calibration(); score_mfrm_calibration(); mfrm_results(); mfrm_report(); export_mfrm_results()", 
    NA_character_, "fit_mfrm(mml_engine = 'em', slope_facet = c(first_owner, second_owner))"), Status = c("supported_with_caveat", 
    "supported_with_caveat", "supported", "supported", "supported_with_caveat", "supported_with_caveat", 
    "supported_with_caveat", "supported_with_caveat", "supported_with_caveat", "supported_with_caveat", 
    "supported_with_caveat", "supported_with_caveat", "supported_with_caveat", "supported_with_caveat", 
    "deferred", "supported_with_caveat", "supported_with_caveat", "blocked", "supported_with_caveat", 
    "supported_with_caveat", "supported_with_caveat", "deferred", "supported_with_caveat"), Boundary = c(paste("One slope family: requires an explicit step facet; MML allows a separate slope owner,", 
    "whereas JML requires `slope_facet == step_facet`. MML direct is the default,", "and EM/hybrid fall back to direct. Free-slope fits retain numerical", 
    "estimates for review. confint(fit, parm = \"slopes\") separately checks approximate MML intervals.", 
    "Explicit options add standardized slopes, comparisons, sandwich covariance and Bonferroni adjustment;", 
    "method = 'profile' supplies an experimental one-relative-slope nuisance profile within its separate scope;", 
    "bootstrap_mfrm_gpcm() and mfrm_curve_intervals() supply bootstrap inference and curve uncertainty.", 
    "These inference routes require MML; JML formal slope intervals are not implemented.", "mfrm_facet_intervals() separately supplies one-family MML location/contrast Wald intervals from full joint information under its identified regular-model assumptions; finite-sample coverage is not guaranteed.", 
    "MML information-criterion ranking requires the separate likelihood", "and local-solution checks in compare_mfrm()."), 
    paste("Residual-based mean-square and strict-marginal outputs remain", "exploratory screening tools because discrimination is free.", 
        "The dashboard's fair-average panel reports an explicit", "unavailability status when the underlying fit is GPCM."), 
    paste("`predict_mfrm_units()` and `sample_mfrm_plausible_values()` consume", "the fitted model and hold its non-Person parameters fixed. For JML this is post-hoc EAP", 
        "with a default N(0,1) reference prior or explicit scoring_prior, not ML/WLE scoring.", "The prior is not a population distribution estimated by JML. This is", 
        "not scoring from a saved, versioned calibration artifact; population", "forecasting is a separate layer outside this row."), 
    paste("Limited to the slope-aware probability kernel that is already", "generalized for the current GPCM branch."), 
    paste("Routes users to supported direct tables and plots. Caveated", "manuscript-draft APA and fit-based export bundles are governed by", 
        "their separate capability row and carry `gpcm_boundary`."), paste("Supported with caveat for GPCM because the casebook inherits", 
        "exploratory screening semantics from its underlying sources."), paste("Supported with caveat because the helper is an operational review of", 
        "Rasch-family equal weighting versus GPCM reweighting, not an automatic model-selection rule.", 
        "This weighting helper requires the same slope/step owner; use compare_mfrm() for separate owners.", 
        "MML ranking requires ICComparable; nested = TRUE requests the separately checked PCM/GPCM equal-slope test."), 
    paste("Supported with caveat as an exploratory synthesis over already-built", "anchor review, drift, and chain objects. It does not establish an", 
        "operational GPCM linking decision, anchor-drift absence claim, or", "equating-chain adequacy claim by itself."), 
    paste("Requires explicit slope-aware specifications and keeps the current", "same slope/step owner. Recovery checks are direct", 
        "simulation/refit summaries, not design-planning or forecasting claims.", "`assess_mfrm_recovery()` requires user-supplied practical thresholds", 
        "before RMSE or bias can be interpreted as adequate."), paste("Supported with caveat as a connected public reporting/export route over", 
        "already-supported GPCM diagnostics, direct tables, plots, manifests,", "and replay scripts. The mfrm_results -> mfrm_report -> export/replay", 
        "route preserves the model, step/slope owners, and MML identification.", "Full FACETS-style score-side contract review,", 
        "design forecasting, and automatic operational scoring claims remain", "outside this route."), 
    paste("Slope-aware element-conditional construction: slope-facet element rows", "use that level's own slope; non-slope-facet rows (Person, Rater, ...)", 
        "use the geometric-mean-one slope by identification convention.", "The historical SE columns in the output are scaled facet-measure SEs,", 
        "not fair-average SEs. Use `fair_se = TRUE` to request structural", "delta-method fair-average SEs for non-person rows when the MML", 
        "observed-information Hessian is available. These remain diagnostic-only:", "FairCIEligible is FALSE, including with computable or regularized", 
        "covariance, and full-refit coverage remains unverified."), paste("Supported with caveat as a role-based person x rater-like x", 
        "criterion-like Monte Carlo simulation/refit route. It uses the", "GPCM generator and refits GPCM with the supplied or", 
        "fit-derived step/slope facet contract, but it reports design-level", "operating characteristics only. Slope-recovery adequacy, diagnostic", 
        "screening operating characteristics, signal detection, and arbitrary-", "facet planning remain separate routes."), 
    paste("Supported with caveat as slope-aware repeated simulation/refit", "screening evidence for the current role-based person x rater-like x", 
        "criterion-like design layer. The summaries are Type I proxy,", "sensitivity proxy, DIF target-flag, and bias-screening readouts,", 
        "not calibrated inferential tests, operational screening criteria, or", "arbitrary-facet planning validation."), 
    paste("Supported with caveat as direct DFF/DIF screening over the fitted", "GPCM expected-score and residual scale. Residual-method", 
        "contrasts and interaction cells remain screening evidence; refit", "contrasts must retain explicit linking and precision requirements before", 
        "any stronger subgroup-comparison wording is used."), paste("mfrmr does not run native GPCM MCMC or posterior-predictive sampling.", 
        "export_mfrm_model() writes Stan/brms code for eligible one-family MML sources and Stan code for two-family sources, adding explicit structural priors and retaining supported fixed constraints.", 
        "Conditional posterior response diagnostics are a different, non-MCMC calculation."), paste("Bias point estimates use the slope-aware GPCM kernel: the bias", 
        "parameter is the additive shift on the linear predictor that", "maximises the per-cell GPCM log-likelihood. `LR ChiSq`,", 
        "`LR Prob.`, and profile-CI columns compare that fitted shift", "with zero by conditional profile likelihood. SE / t / Prob", 
        "columns use conditional plug-in information at the bias point", "estimate. All quantities hold theta, steps, slopes, and other", 
        "facet estimates fixed, so they support screening and follow-up", "review rather than standalone fairness claims. The post-bias", 
        "unexpected-response comparison uses the same conditional fitted", "quantities and is an in-sample descriptive screen; it does not show", 
        "that bias has been removed. estimate_all_bias() collects eligible facet pairs and retains failed/unavailable results; it does not supply collection-wide multiplicity control."), 
    paste("Supported with caveat for package-native scorefile export only.", "Rows carry fitted expected score, residual, standardized residual,", 
        "observed-category probability, score slope, native structural", "expected-score uncertainty, selectable score-side delta SEs, and", 
        "explicit caveat fields when the required MML diagnostics are", "available. The route does not export FACETS-equivalent score-side", 
        "SEs or establish operational score-scale equivalence."), paste("Limited to direct scorefile export rather than the full FACETS-style output-contract review.", 
        "Direct scorefile export is available with caveats, but contract-wide", "coverage and metric claims still require a broader free-discrimination", 
        "score-side review contract."), paste("This is a slope-aware diagnostic replay from a reconstructed starting", 
        "state, not the exact optimizer history stored during fitting and not", "an additional convergence test."), 
    paste("One slope family only. MML permits shared or separate slope/step owners with", "an estimated intercept-only normal population; JML requires shared owners", 
        "and uses a declared post-hoc normal reference prior. Both require their", "source checks, unit weights, known levels and no anchors or interactions.", 
        "Later-person EAP scores and posterior intervals condition on the saved", "calibration; they exclude its estimation uncertainty and bias and are not ML/WLE.", 
        "Experimental corrected shared-owner JML uses distinct adjusted-equation checks and preserves the explicit correction order (file format 5)."), 
    paste("Provisional fixed-grid EM or adaptive direct MML for exactly two fixed slope facets, with fixed N(0,1),", 
        "unit weights, no anchors or population covariates and observed zero-based scores.", "The first family's slopes have geometric mean one; the second owns steps and has free slopes.", 
        "Summary and fitted curves connect to saved results/reports; curve intervals are unavailable.", 
        "Both routes support separately checked experimental component log-Wald intervals using their fitted integration method. Global identification and coverage remain unestablished.", 
        "mfrm_facet_intervals() separately supplies experimental model-based location and within-facet contrast intervals from the inverse full marginal information. Failed numerical checks retain points and missing bounds; confint(fit, parm = 'steps') separately supplies experimental centered step intervals. No sandwich or curve intervals are supplied.", 
        "method = 'profile' and a named slope value profile one owner/level with the fitted fixed or adaptive integration, nuisance reoptimization and saved Wald comparison; coverage improvement is not established.", 
        "mml_quadrature_sensitivity() preserves the fitting engine/integration method; optional adaptive_quad_points adds fixed-calibration integration diagnostics, not Person scoring or a change of estimator.", 
        "For both engines, mfrm_response_diagnostics() integrates ability with both slope families fixed, retaining the fitted integration method and complete Person record; descriptive residuals connect to plots/reports/exports without fit cutoffs or formal tests.", 
        "predict_mfrm_units() separately supplies experimental new-Person EAP, posterior SD and continuous posterior intervals under the retained N(0,1) prior with known levels and unit weights. Source/batch numerical checks are distinct; intervals exclude calibration uncertainty and do not establish coverage or population transport.", 
        "Portable format 6 retains both slope components, category coding and fixed N(0,1) prior after passing source checks; every new batch is checked independently. Prior overrides and repeated-event extensions are unsupported.", 
        "mfrm_results(fit, scores = scores) collects matching saved native or format-6 Person scores for tables, reports and exports without rescoring; source/batch checks and review-only labels remain attached.", 
        "mfrm_report(..., style = 'rater', facet = ..., rater = ...) provides experimental individual feedback from saved two-family results, separating location, component slope, category use, exposure and descriptive posterior residuals. Saved component-slope intervals remain experimental; no competence or training-effect decision is supplied.", 
        "Ordinary fit diagnostics and model ranking are not supported."), paste("Formal corrected-JML structural intervals are unavailable.", 
        "The explicit corrected estimator reports local adjusted-equation RootSE, not established structural coverage.", 
        "Uncorrected JML location SEs and post-hoc Person intervals answer different questions.", "None is a bias-corrected structural confidence interval."), 
    paste("Two-family GPCM uses fixed-grid EM or adaptive direct MML with fixed-standard-normal identification.", 
        "EM uses ascent-checked M steps and per-Person marginal-score stopping; adaptive direct MML uses reltol and optimizer gradient checks;", 
        "numerical convergence does not establish inferential reliability.", "mml_integration = 'auto' preserves the selected engine and checks increasing rules within mml_accuracy_control = list(max_points = ...), including reference rules. Fixed integration remains the default; two-family direct fitting requires adaptive or auto.", 
        "One-family EM/hybrid requests still use direct optimization and record that fallback.", "Adaptive EM and two-family hybrid fitting are not supported.")), 
    RecommendedRoute = c(paste("Use `fit_mfrm(..., model = \"GPCM\", step_facet = ...,", "slope_facet = ...)` and inspect `summary(fit)`; separate owners require MML."), 
        paste("Use diagnostics as screening evidence and return to direct residual,", "unexpected-response, displacement, and category tables before writing claims."), 
        paste("Use fitted-object posterior scoring and `compute_information()` /", "`plot(x)`; keep portable calibration and population", 
            "forecasting on their separately documented routes."), paste("Use draw-free plot objects and category reports for GPCM sensitivity", 
            "figures and appendix tables."), paste("Export direct supported tables; use the separate APA/QC/export", 
            "bundle row for caveated GPCM sensitivity prose and manifests."), paste("Use the casebook as a review queue, then confirm flagged rows with", 
            "the underlying direct tables."), paste("Compare against an equal-weighting `RSM` / `PCM` reference and report", 
            "reweighting as sensitivity evidence."), paste("Use `build_linking_review()` as a reader-facing index over direct", 
            "anchor, drift, or chain outputs; write any GPCM linking language as", "exploratory and source-specific."), 
        paste("Use ADEMP-style direct recovery checks with explicit practical RMSE,", "bias, and uncertainty thresholds."), 
        paste("Use `mfrm_results(fit, include = \"gpcm_review\")`, `mfrm_report()`,", "and `export_mfrm_results()` for caveated GPCM sensitivity reporting;", 
            "use package-native scorefile export, design forecasting, and full", "FACETS score-side review only through their separate caveated or", 
            "blocked rows."), paste("Use `fair_average_table(fair_se = TRUE)` when structural fair-average", 
            "SEs are required, and label outputs as slope-aware element-conditional."), paste("Use `evaluate_mfrm_design(..., model = \"GPCM\", step_facet = ...,", 
            "slope_facet = step_facet)` or `predict_mfrm_population()` for", "caveated design-level operating-characteristic review; inspect", 
            "`gpcm_boundary` and keep slope-recovery adequacy on", "`simulate_mfrm_recovery()`."), paste("Use `evaluate_mfrm_diagnostic_screening(..., model = \"GPCM\",", 
            "step_facet = ..., slope_facet = step_facet)` or", "`evaluate_mfrm_signal_detection()` for caveated slope-aware screening", 
            "operating-characteristic review; inspect `gpcm_boundary` and keep", "operational screening decisions outside this route."), 
        paste("Use `analyze_dff()` and `dif_interaction_table()`", "as screening surfaces, then carry `gpcm_boundary` through", 
            "`summary()`, `mfrm_report(dif, type = 'dff')`, `plot(x, type = \"heatmap\")`, and", "`plot(x, type = \"summary\")` before writing claims."), 
        paste("Use MML and conditional posterior scoring for their stated targets.", "Use export_mfrm_model(format = 'stan' or 'brms') for eligible one-family sources, or format = 'stan' for two-family sources. Then review priors, sampler diagnostics and posterior fit; code export is not native Bayesian estimation."), 
        paste("Use `estimate_all_bias()` for exploratory pairs or `estimate_bias()` for one specified pair; use `unexpected_after_bias_table()` only", 
            "for a descriptive before/after flag comparison, then confirm important", "patterns with substantive facet-pair review or external validation."), 
        paste("Use `facets_output_file_bundle(include = \"score\")` for a", "package-native GPCM scorefile with explicit caveat columns;", 
            "inspect `mfrmr_output_guide(\"gpcm_capabilities\", view = \"scores\")`, and do not treat it as", 
            "FACETS score-side equivalence."), paste("Use direct fair-average tables and graph-only compatibility outputs;", 
            "use package-native scorefile export with its stated caveats, and keep", "full FACETS output-contract reviews on the `RSM` / `PCM` route."), 
        paste("Use `summary(fit, profile = \"fit\", detail = \"brief\")` for the", "recorded convergence result. Use `mfrm_report(fit, type = 'iterations')` only", 
            "to inspect a reconstructed trajectory and label it as replayed."), paste("Check mfrmr_output_guide(\"calibration_capabilities\"), then extract, save, load and score", 
            "with the existing calibration workflow; review the scoring prior and each batch's numerical checks."), 
        paste("See the Two slope families section of fit_mfrm() for explicit owners and fitting settings;", 
            "use summary(fit), mfrm_curve_intervals(fit, newdata) and saved fit/plot results with compute = 'never'."), 
        paste("Use current JML outputs within their descriptive scope, or explicitly choose", "MML inference if its population assumptions suit the analysis; do not transfer MML intervals to JML."), 
        paste("Use direct MML for one-family GPCM; two families permit fixed-grid EM or adaptive direct MML;", 
            "inspect the actual engine and ConvergenceBasis in summary(fit).")), stringsAsFactors = FALSE)

.mfrmr_table_.gpcm_capability_registry_data <- data.frame(CapabilityID = "corrected_jml_estimation", 
    Area = "Experimental corrected JML estimates and saved output", Helpers = "fit_mfrm(jml_correction_order = ...); summary(); mfrm_response_diagnostics(); predict_mfrm_units(); extract_mfrm_calibration(); score_mfrm_calibration(); plot(); mfrm_results(); mfrm_report(); export_mfrm_results()", 
    Status = "supported_with_caveat", Boundary = paste("Shared-owner GPCM JML with an explicit positive order, declared categories, unit-weight observed ratings and centered fixed facets.", 
        "No anchors, interactions or automatic order selection. RootSE describes local adjusted-equation variation; residual bias may remain.", 
        "Point estimates survive covariance failure. Conditional observed-row probabilities and descriptive residual summaries hold corrected calibration and Person profiles fixed; no fit cutoffs or rater-quality classifications.", 
        "Conditional new-Person/portable EAP uses distinct adjusted-equation checks and a separate normal prior; calibration uncertainty and residual bias are not propagated.", 
        "Ordinary fit tests, structural intervals, likelihood ranking and corrected Person ML/WLE remain unavailable."), 
    RecommendedRoute = "Read the Corrected JML section of fit_mfrm(); inspect summary(fit)$tables, then collect mfrm_results(fit).", 
    stringsAsFactors = FALSE)


.mfrmr_const_gpcm_fair_average_rationale <- "The diagnostics/QC dashboard keeps the embedded fair-average panel disabled for `GPCM` fits so it does not present score-side adjustments as a FACETS-equivalent reporting surface. Use `fair_average_table()` directly for the supported slope-aware element-conditional GPCM fair averages, and keep its documented SE caveat in force."

.mfrmr_const_mfrm_checkpoint_schema_id <- "mfrmr_mml_em_checkpoint"

.mfrmr_const_mfrm_checkpoint_schema_version <- 2L

.mfrmr_const_mfrm_ic_contract_required_fields <- c("ICContractVersion", "N", "ResponseRows", "WeightedResponseTotal", 
    "Persons", "Npar", "LogLik", "Deviance", "WeightPolicy", "ICEligible", "ICSelectable", "ICStatus", 
    "ICSampleSize", "ICSampleSizeBasis", "AIC", "BIC", "SABIC", "SABICSelectable", "AICFormula", "BICFormula", 
    "SABICFormula", "IntegrationEvaluationId", "ICQuadraturePoints", "ICIntegrationTier", "ICIntegrationStatus", 
    "ICIntegrationSelectable")

.mfrmr_const_mfrm_ic_contract_version <- "mfrmr_ic_person_v2"

.mfrmr_const_mfrm_ic_formula_identifiers <- c(AIC = "aic_deviance_plus_2k", BIC = "bic_person_count", 
    SABIC = "sclove_n_plus_2_over_24")

.mfrmr_const_mfrm_jml_note <- "Experimental profile-score-adjusted JML. RootSE describes local variation around the adjusted-equation solution; residual bias may remain. Method qualification is incomplete; numerical availability does not establish statistical accuracy. It is not a standard error with established coverage for the true structural parameter. Person profiles condition on the adjusted calibration. No confidence intervals for structural parameters, ordinary fit tests, likelihood ranking or rater-quality classifications are supplied."

.mfrmr_const_mfrm_separation_interpretation <- "Separation reliability describes differences among facet locations relative to their estimation errors. High Person values indicate distinguishable abilities; high rater values indicate distinguishable severities, not inter-rater agreement. Low rater values can also reflect imprecision and do not establish agreement. The index does not test every rater pair or quantify the practical size of severity differences. Reliability, separation and Strata are approximate compatibility indices: unshrunk facet estimates use marginal-SE variance subtraction without propagating covariance among estimates, whereas MML Person EAP estimates use the posterior-variance decomposition Var(EAP) / (Var(EAP) + mean(SE^2)), conditional on the assumed population prior and fixed calibration. Model and fit-adjusted values are companion indices, not confidence limits. Strata describes hypothetical distinguishable strata, not discovered groups. Facet heterogeneity chi-square summaries use diagonal SE weights, not full-covariance joint tests."






.mfrmr_const_mfrmr_jml_gpcm_asymptotically_affine_contract_version <- "mfrmr-jml-gpcm-asymptotically-affine-transport-0.2.3-v1"

.mfrmr_const_mfrmr_jml_gpcm_boundary_classification_contract_version <- "mfrmr-jml-gpcm-fixed-objective-boundary-0.2.3-v2"

.mfrmr_const_mfrmr_jml_gpcm_boundary_compactification_contract_version <- "mfrmr-jml-gpcm-boundary-compactification-0.2.3-v1"

.mfrmr_const_mfrmr_jml_gpcm_terminal_gradient_contract_version <- "mfrmr-jml-gpcm-fixed-objective-terminal-gradient-0.2.3-v1"

.mfrmr_const_mfrmr_jml_recession_fit_policy <- list(contract_version = "mfrmr-jml-recession-fit-policy-v1", 
    scope = "additive_structural_and_joint_recession", native_timeout_seconds = 10L, attempts_per_stage = 1L, 
    retry_after_unaccepted = FALSE, maximum_native_seconds_per_positive_target = 20L)

.mfrmr_const_mfrmr_nonlinear_local_estimability_contract_version <- "mfrmr-nonlinear-local-estimability-0.2.3-v1"

.mfrmr_const_mfrmr_readiness_contract_states <- list(ReadinessScope = c("fit", "parameter", "comparison"), 
    InputState = c("pass", "review", "blocked", "legacy_unknown"), EstimabilityState = c("identified", 
        "population_assumption_linked", "weak_information", "structurally_unidentified", "not_evaluated", 
        "legacy_unknown"), CategoryState = c("adequate", "weak_information", "unsupported_coordinate", 
        "not_applicable", "not_evaluated", "legacy_unknown"), BoundaryState = c("finite", "has_exclusions", 
        "not_applicable", "not_evaluated", "legacy_unknown", "nonfinite_maximum"), NumericalState = c("ready", 
        "review", "failed", "not_run", "legacy_unknown"), FitReadiness = c("ready", "ready_with_exclusions", 
        "review", "blocked", "legacy_unknown"), ParameterStatus = c("estimable", "fixed", "weak_information", 
        "unbounded_low", "unbounded_high", "unbounded_both", "aliased", "unsupported", "not_estimated", 
        "not_evaluated", "legacy_unknown", "finite_numerical_solution", "finite_local_solution", "numerical_unresolved", 
        "finite_maximum_absent", "finite_likelihood_limit", "unidentified_likelihood_limit", "limit_not_evaluated"), 
    ComparisonEligibility = c("eligible", "ineligible", "missing", "failed", "not_applicable"), ExpectedAction = c("return_ready_fit", 
        "return_review_fit", "return_partial_fit", "return_blocked_diagnostic", "stop_before_fit", "retain_parameter", 
        "label_legacy", "include_metric", "exclude_metric", "report_missing", "report_failed"), EvidenceRole = c("unit_positive", 
        "unit_negative", "migration", "comparison_positive", "comparison_negative"))

.mfrmr_const_person_fit_threshold_table <- structure(list(Threshold = c("5pct", "1pct"), TwoSidedAlpha = c(0.05, 
    0.01), AbsZ = c(1.95996398454005, 2.5758293035489), Rule = c("|z| > 1.96", "|z| > 2.58")), class = "data.frame", 
    row.names = c(NA, -2L))

