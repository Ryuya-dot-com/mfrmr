#' Updating saved analyses and compatibility workflows
#'
#' @description
#' Use this reference when updating saved analyses, earlier scripts or
#' compatibility-oriented exports. The saved-analysis section identifies
#' which calculations to repeat; later sections describe specific corrections
#' and legacy wrappers. For a new analysis, use [mfrmr_workflow_methods].
#'
#' The legacy wrappers and FACETS-style exports apply mainly to diagnostics-based
#' `RSM` / `PCM` workflows. Supported `GPCM` fits also provide graph and
#' package-native scorefile exports through [facets_output_file_bundle()],
#' with explicit score-side limitations. Check each helper's model scope.
#' Treat this layer as a presentation/contract surface, not as a claim of
#' FACETS or ConQuest numerical equivalence.
#'
#' SPSS is treated differently from FACETS and ConQuest: `mfrmr` currently
#' supports table/data-frame/CSV handoff for SPSS-oriented reporting workflows,
#' but it does not generate SPSS syntax, write native SPSS system files, execute
#' SPSS estimators, or claim SPSS numerical equivalence.
#'
#' @section Updating saved analyses for 0.2.4:
#' Keep the original objects, data and analysis settings. Installing an update
#' does not recalculate saved tables, figures or reports. For analyses based
#' on a native MFRM fit, start by printing `summary(fit)` under the updated
#' package and reading its interpretation
#' decision. If the saved native fit lacks the current estimation checks,
#' refit from the original data with the same intended model, category coding,
#' anchors, weights and numerical settings. Running [diagnose_mfrm()] alone
#' cannot establish checks missing from that fit. If the original data or
#' settings are unavailable, retain the old result as historical output;
#' its previous approval is not evidence for current inferential use.
#' Observed-score G/D studies and external-feature groups instead use their
#' own source objects; they do not require an MFRM fit.
#'
#' Update the affected result at the earliest step below, then rebuild its
#' dependent summaries, plots and exports. For an MFRM-based analysis, this
#' assumes a fit with current estimation checks. A request to recompute
#' diagnostics or scoring does not itself
#' require a new calibration fit.
#'
#' - **Display wording only:** reprint a saved fit summary. This updates labels
#'   and removes the duplicate inference decision; it does not recalculate
#'   stored diagnostics or establish missing precision evidence.
#' - **Wright-map groups:** regenerate `plot(fit, type = "wright", ...)` from
#'   the saved fit and original group specification, including `group_data`
#'   if supplied. This corrects group membership and exclusions without refitting.
#'   Reloading an old plot alone retains its previously calculated densities.
#' - **Diagnostics and QC:** recreate [diagnose_mfrm()] results with the original
#'   diagnostic settings before rebuilding reliability, precision, category,
#'   marginal-fit, person-fit, unexpected-response, fair-score and reporting
#'   results. Rerun separately requested [q3_statistic()],
#'   [analyze_residual_pca()] and [compute_person_fit_indices()] calculations
#'   with their original options. In [run_qc_pipeline()], request
#'   `separation_facets` only for facets whose levels need to be distinguished;
#'   it is no longer a default rater-quality requirement. Missing results remain
#'   unavailable and cannot be treated as passes.
#' - **Model comparisons:** rerun [compare_mfrm()] on the existing eligible fits,
#'   retaining the original comparison settings, then rebuild dependent
#'   [build_model_choice_review()] and [build_weighting_review()] results.
#'   The corrected RSM/PCM nesting review requires every RSM interaction to be
#'   retained in the PCM. More category-step parameters do not establish
#'   nesting. An affected pair can retain an eligible information-criterion
#'   comparison while losing its invalid chi-square test. This correction
#'   does not require refitting; printing an old comparison leaves its stored
#'   decision unchanged.
#' - **Group comparisons and equivalence:** recreate residual [analyze_dff()]
#'   / [analyze_dif()] and [dif_interaction_table()] results from the existing
#'   fit and original group data. They now describe residual differences without
#'   tests or confidence intervals. Recompute [analyze_facet_equivalence()]
#'   from an eligible MML fit with matching current diagnostics and the original
#'   practical bound; old equivalence bundles cannot supply the required joint
#'   covariance.
#' - **ICC and design effects:** rerun [compute_facet_icc()] or
#'   [analyze_hierarchical_structure()] from the original data and settings.
#'   Numeric score labels now retain their values. Missing scores or grouping
#'   values require an explicit `missing = "omit"` choice; malformed scores
#'   must be corrected. Inspect `attr(icc, "data_usage")`, then recreate
#'   [compute_facet_design_effect()] using the new ICC result. Older ICC
#'   tables lack the row accounting needed to calculate matching sample sizes.
#'   Recalculation also removes the fixed variance cutoff tied to score units
#'   and preserves small positive variances without decimal rounding. Constant
#'   retained scores have unavailable variance components and ICCs. Design
#'   effects remain per-facet approximations; their equivalent row counts do
#'   not estimate the precision of a complete crossed or unbalanced design.
#'   The former `ci_method = "profile"` transformed separate component bounds
#'   and did not calculate a profile-likelihood interval for the ICC ratio.
#'   Choose `"boot"` explicitly for parametric percentile intervals, then read
#'   `ICC_CI_Status` and `attr(icc, "icc_ci")`. Failed or nonconverged refits
#'   and fit warnings withhold intervals. Saved bootstrap results also require
#'   rerunning to obtain complete failure accounting and identify
#'   constant-response refits, which withhold intervals; reprinting is insufficient.
#' - **Observed-score design coefficients and shrinkage:** rerun
#'   [mfrm_generalizability()] with its original data and settings, then
#'   [mfrm_d_study()] with the planned counts and residual-scaling choice.
#'   This re-estimates the separate observed-score mixed model, not the MFRM.
#'   Reapply [apply_empirical_bayes_shrinkage()] with the original prior settings
#'   and explicit Person choice to refresh shrinkage reports, descriptive bands,
#'   and replay settings. Reapplication replaces the previous adjustment;
#'   switching Person shrinkage off removes its old adjustment columns.
#'   Regenerate replay scripts to retain the post-fit adjustment step.
#' - **Multivariate G/D studies:** to apply metric-specific G/Phi/SEM
#'   availability rules, rerun [mfrm_d_study()] from the saved
#'   G-study with the original planned counts and score weights. Changing only
#'   future counts or weights also reuses that G-study. Recreate dependent
#'   plan comparisons, plots and exports after recalculation; replotting alone
#'   preserves stored numbers. Refit [mfrm_g_study()] when changing
#'   the source data or G-study model, replacing an object with missing or
#'   incompatible design metadata, or correcting an earlier G-study affected
#'   by the single-score MINQUE(0) or period-containing interaction-ID bugs. In
#'   particular, a crossed result cannot be converted to a nested model by
#'   editing its labels; refit with an explicit `nesting` specification.
#'   Retain the G-study object and its data to calculate new prespecified
#'   plan comparisons with [mfrm_multivariate_d_compare()]. A coefficient
#'   table alone does not contain the information needed for those intervals.
#' - **External-feature groups:** saved clustering results retain their
#'   memberships and fitted hierarchy. Replot them to update labels; use
#'   [plot_data()] for their stored values. [as_ggplot()] supports silhouette,
#'   profile, dendrogram and co-membership views. A change to features, weights, group
#'   counts or method requires a new clustering call, followed by
#'   [mfrm_cluster_compare()] on the updated results. For imputation
#'   comparisons, reuse the original `mice` object to preserve pairing across
#'   completed datasets; do not generate unrelated completions for each setting.
#' - **Fitted-object Person scores:** re-summarize the original prediction object
#'   to recover stored interval settings and updated explanations. To replace
#'   older grid-endpoint intervals with continuous posterior intervals, rerun
#'   [predict_mfrm_units()] using the existing fit, scoring data and settings.
#'   Reprinting cannot change an already calculated interval. Rerun scoring
#'   when older estimated-population results lack numerical prior information
#'   or are refused because they claimed unrestricted scoring; these fits
#'   require explicit `readiness_policy = "review"`.
#' - **Plausible values:** use `summary(original_plausible_values)` on the saved
#'   draw object to obtain empirical quantiles at its requested interval level.
#'   No new draws are needed for this correction. A saved derived summary alone
#'   cannot recover the original draws. If estimated-population restrictions
#'   require regeneration, repeat the original scoring/draw call with the same
#'   data, settings and seed, and `readiness_policy = "review"`.
#' - **Portable calibration:** [load_mfrm_calibration()] preserves a valid
#'   artifact's recorded scoring algorithm; older grid-based intervals remain
#'   grid-based. To adopt continuous intervals, create a new calibration using
#'   the reviewed source fits and [mfrm_calibration_workflow], then score again.
#'   Retain the old artifact for reproducibility. Re-summarizing older score
#'   results recovers recorded algorithm/level labels without changing values.
#' - **External fits:** rerun [import_erm_fit()], [import_tam_fit()] or
#'   [import_mirt_fit()] on the saved source-package fit and rebuild displays;
#'   source-model re-estimation is unnecessary. Use `compute_fit = TRUE` when
#'   imported measurement diagnostics are needed. Unsupported source models
#'   remain unsupported, and imports do not become native fits.
#' - **Agreement, networks and timing:** rebuild [interrater_agreement_table()],
#'   [rater_network_analysis()] and [rater_halo_network_analysis()] from the
#'   existing native fit, matching diagnostics and original settings. Refresh
#'   design reviews with [build_mfrm_network_review()] to record whether the
#'   graph covers all observed subsets. Recreate [response_time_review()] from
#'   the original timed-event data and settings. No MFRM refit is required.
#'   Unavailable comparisons remain unassessed; a missing or excluded graph
#'   edge does not establish absence of a rater effect. Halo Welch-test columns
#'   are retained as missing values. Timing rates use valid times and describe
#'   cutoff rules, not calibrated rapid-guessing or low-effort classifications.
#' - **Simulation and design summaries:** re-summarize saved evaluation objects
#'   to retain attempted-run denominators and unavailable residual-DIF rates.
#'   Rebuilding design summaries also restores unrounded metrics for threshold
#'   decisions; rounded saved summaries alone cannot recover that precision.
#'   Missing workload or connectivity records cannot be reconstructed by
#'   summary formatting. If those records are required for a recommendation,
#'   repeat the original evaluation with its recorded design, settings and seeds.
#'
#' After any required recalculation, regenerate dependent [mfrm_results()],
#' reports and exports with matching source objects. A newly created PDF, HTML
#' file or CSV can still contain outdated calculations if built from an old
#' derived object. Consult the affected function's help for its interpretation
#' limits; updating an object does not broaden those limits.
#'
#' @section Compatibility outputs:
#' Use this layer when a downstream consumer requires a legacy layout.
#' [run_mfrm_facets()] provides a one-shot fit/diagnostic wrapper;
#' [build_fixed_reports()] writes fixed-width blocks; [facets_output_file_bundle()]
#' provides graphfile/scorefile-style outputs. Dedicated residual and subset
#' handoffs use [write_mfrm_residual_file()] and [write_mfrm_subset_file()].
#' [facets_output_contract_review()] checks the stated output contract, not
#' numerical equivalence to external FACETS.
#'
#' For new analyses, start with [fit_mfrm()] and the applicable diagnostics,
#' then [mfrmr_reports_and_tables] for report/export selection. Use
#' [compatibility_alias_table()] to check former names and replacements, and
#' `reporting_checklist(fit)$software_scope` for FACETS/ConQuest/SPSS wording.
#' @section Multiple-imputation review and intervals in 0.2.4:
#' Re-run [pool_mfrm_imputed()] on saved, valid [fit_mfrm_imputed()] analyses
#' to obtain `IntervalReason` and saved inference notes, then recreate plots
#' and exports. No new imputations or fitted analyses are needed for the
#' interval arithmetic update. Numerically unresolved intervals keep their
#' estimates and variances with missing bounds. Older saved tables lack this
#' audit.
#'
#' [review_mfrm_imputations()] now rejects numeric IDs that collapse to the
#' same text and detects changes to observed numeric predictors without text
#' rounding. Numeric predictors must stay numeric in completed data; integer
#' and double storage are interchangeable. Pooling rechecks the original
#' roster and saved assignment/support review. Correct changed inputs from
#' their original evidence and recreate affected reviews/analyses; do not
#' overwrite original values to make an invalid completion pass.
#'
#' @section Expected agreement and accuracy identifiers in 0.2.4:
#' Regenerate [diagnose_mfrm()] from the saved fit, then recreate
#' [interrater_agreement_table()] and derived reports or exports. Calibration
#' refitting is unnecessary. Observed agreement remains available when primary
#' fitted estimates are unavailable; model-expected agreement is withheld
#' instead of using finite optimizer proxies. New `ExpectedReason` fields
#' distinguish these cases from repeated ratings and unavailable probabilities.
#' Older diagnostics do not contain this audit; reports identify its absence
#' and request regeneration before interpreting model expectations.
#' The MML baseline remains a
#' conditional EAP plug-in quantity, not posterior-integrated agreement.
#'
#' [fit_rater_accuracy()] rejects numeric identifiers whose conversion to text
#' would merge distinct values. Replace them with unambiguous character IDs
#' from the original data before fitting; already rounded text cannot recover
#' the original identities. Previously affected accuracy fits need to be
#' regenerated from corrected input.
#'
#' @section Halo-network inference in 0.2.4:
#' Recreate [rater_halo_network_analysis()] results from the original fit and
#' matching saved diagnostics before summary, plotting or export. No model
#' refit is needed. Older results lack the Person-level availability audit and
#' are rejected by summary and plot methods. Correlations remain available
#' when Persons repeat across shared contexts, but ordinary independent-pair
#' p-values are withheld with counts and reasons. Context definitions omitting
#' `"Person"` also provide descriptive correlations only. Use `alpha = 1`
#' for an explicitly descriptive graph without a p-value filter; this does
#' not supply missing inference. Regenerate derived plots and CSV files.
#'
#' @section Simulation, assignment review and GPCM guidance in 0.2.4:
#' These old public function names have been replaced, rather than retained
#' as callable aliases. Their help aliases lead to the new topics.
#'
#' | Former call | Current call | What it does |
#' | --- | --- | --- |
#' | `evaluate_mfrm_recovery(...)` | `simulate_mfrm_recovery(...)` | Generate data repeatedly, refit, and summarize parameter recovery. |
#' | `build_peer_review_design_review(x)` | `review_peer_design(x)` | Read existing peer-assessment assignment metadata; no assignment generation or model fitting. |
#' | `gpcm_score_side_contract(status)` | `gpcm_capability_matrix(status, view = "scores")` | Read score availability, limitations and alternatives. |
#' | `gpcm_runtime_guard_coverage()` | `gpcm_capability_matrix(view = "unavailable")` | Read blocked/deferred workflows and alternatives. |
#'
#' `assess_mfrm_recovery(x, ...)` keeps its name: it applies review thresholds
#' to an existing simulation result without generating data or refitting.
#' Unused arguments are now rejected, so misspelled options cannot silently
#' leave a requested threshold unapplied. Review thresholds are aids to
#' interpretation, not universal validity criteria.
#'
#' The simulation and peer-design replacements retain their argument lists,
#' defaults, numerical calculations and result classes. Existing RDS objects
#' still work with `summary()`, supported `plot()` methods and reporting helpers;
#' no re-estimation or class relabelling is needed for these naming changes.
#' Each GPCM view retains its previous columns and status meanings. The default
#' workflow view is unchanged apart from updated route names. Existing scorefile
#' bundles keep the component `gpcm_score_side_contract` and its CSV filename
#' for saved-output compatibility; this field name is not a callable function.
#'
#' @section CSV export name in 0.2.4:
#' Replace `export_mfrm(fit, ...)` with [export_mfrm_tables()] using the same
#' arguments. The old function is no longer exported; its help alias opens
#' the replacement's help. CSV filenames, numeric values and the returned file
#' table are unchanged by the rename. Enriched facet CSVs additionally retain
#' diagnostic availability, SE/inference qualifications and reasons, and follow
#' the source facet-table order. Existing fits do not need re-estimation;
#' regenerate older CSVs from the fit and matching diagnostics to include these
#' fields. Do not infer approval from their absence in an older CSV.
#'
#' [export_mfrm_results()] and [export_mfrm_bundle()] retain their names because
#' they serve different tasks: the former archives an existing results object
#' and reloads its RDS, while the latter prepares fit-level artifacts with an
#' optional refitting recipe. Neither is an alias for the CSV-only exporter.
#' ZIP replacement now includes only files written by the current call; older
#' members are not carried forward. If ZIP creation fails, the prior archive is
#' retained but is not reported as a successful current export. See
#' [mfrmr_reports_and_tables] for the saving routes.
#'
#' @section Practical migration rules:
#' Recompute older [mantel_haenszel_table()] results from their original input
#' data if large strata produced integer-overflow warnings or unavailable
#' odds ratios/tests/intervals. Merely reopening the saved list does not repair
#' it. The corrected calculation preserves the statistical method, matching
#' and multiplicity settings; no MFRM fitting is involved. Regenerate CSV
#' exports from the new result.
#'
#' - Start FACETS-facing reports with [facets_positioning_guide()] when readers
#'   might otherwise assume FACETS numerical reproduction.
#' - Keep compatibility wrappers only where a downstream consumer truly needs
#'   the old layout or fixed-width format.
#' - For new scripts, start from package-native bundles and add compatibility
#'   outputs only at the export boundary.
#' - Treat compatibility outputs as presentation contracts, not as the primary
#'   analysis objects.
#' - Use [compatibility_alias_table()] when you need to check which aliases are
#'   still retained and which package-native names should be used in new code.
#' - Use `reporting_checklist(fit)$software_scope` to review the current
#'   FACETS, ConQuest, and SPSS relationship wording for a fitted analysis.
#'
#' @section G/D-study entry points in 0.2.4:
#' Use [mfrm_g_study()] for one or several observed score columns and
#' [mfrm_d_study()] for the resulting assessment plans. The former public
#' names are replaced as follows:
#'
#' | Former call | Current call |
#' | --- | --- |
#' | `mfrm_multivariate_gstudy(data, scores, ...)` | `mfrm_g_study(data, scores, ...)` |
#' | `mfrm_multivariate_d_study(g, plans, weights)` | `mfrm_d_study(g, plans, weights = weights)` |
#' | `mfrm_d_study(main_effects, plans, residual_scaling = ...)` | Same call; the main-effects approximation is retained. |
#'
#' The two former long names are no longer exported functions; their help
#' aliases lead to the replacement pages. Constructor arguments, ANOVA/MINQUE
#' defaults, result classes and stored estimates are preserved. Existing G/D
#' RDS files can be reloaded and passed to `mfrm_d_study()`, `summary()`,
#' `plot()` and the same supported interval methods without re-estimation.
#' This naming change alone does not require recreating a saved analysis.
#'
#' Both D-study routes accept facet labels or `n_<facet>` count columns, for
#' example `n_Rater` and `n_Task`. Existing task/rater `Raters`/`Tasks` names
#' remain accepted for results that use them. Supply one count per facet;
#' duplicate aliases, extra columns and ambiguous matches are errors. Returned
#' count columns retain the source result's convention so plot selections and
#' saved interval identities stay unchanged. A nested child count still means
#' children per parent, not the total number of children.
#'
#' `summary(d)` returns the coefficient data frame for either route. For a
#' main-effects D-study this replaces generic per-column descriptive summaries;
#' use `summary(as.data.frame(d))` if those summaries were intended. Unsupported
#' arguments to an already estimated G-study are now rejected instead of ignored.
#' Composite weights require the score-component route; `residual_scaling`
#' belongs only to the main-effects approximation. Supplying a fitted MFRM
#' still estimates a separate observed-score main-effects G-study first.
#' Dispatch does not change an estimator or add interval support to that approximation.
#'
#' @section Standard R extraction in 0.2.4:
#' [mfrm_fit_extractors] documents the native `coef()`, `vcov()`, `logLik()` and
#' `nobs()` methods. `coef(fit)` gives free coordinates matched to covariance;
#' `type = "locations"` gives labelled facet locations, which need their constraint
#' map before combination with that covariance. `confint(fit)` now defaults to
#' pointwise intervals for those free coefficients in supported MML/CML fits.
#' JML structural-truth intervals remain unsupported.
#'
#' **GPCM scripts requesting slope inference must now specify
#' `confint(fit, parm = "slopes", ...)`.** This includes slope contrasts,
#' standardization, sandwich/profile options and slope-plot attachments. The
#' default free log-slope coefficient matrix is a different target. Existing
#' slope-interval objects need no recalculation solely for this syntax change.
#' See [confint.mfrm_fit()] for diagnostics and target-specific availability.
#'
#' `nobs(fit)` counts Persons for MML/CML and ratings for JML; request
#' `type = "ratings"` for rating rows throughout. Multiple-model AIC/BIC calls
#' now direct users to [compare_mfrm()]. Unsupported/legacy likelihood metadata
#' require the documented summaries rather than inference from absent fields.
#'
#' [mfrm_fit_responses] documents `fitted()`, `residuals()` and source-rating
#' `predict()`, which previously could fall through to `NULL`. Supplied-response
#' ability scoring still uses [predict_mfrm_units()] or [score_mfrm_calibration()];
#' `predict(fit, newdata = ...)` is unsupported. Returned rows align with
#' `fit$prep$data`, not the unfiltered input. Old fits without omission identities
#' cannot recover original `InputRow` positions merely by being reopened.
#'
#' Regenerate older diagnostics and exports from the saved fit to obtain the
#' corrected missing-residual coverage and identifier matching; no calibration
#' refit is needed for these corrections. Inspect `FitAvailableRows`,
#' `FitUnavailableRows`, `FitReason` and response-table status fields. Native
#' response methods and legacy diagnostics can differ at extreme/low-variance
#' limits; [mfrm_fit_responses] specifies their respective estimate bases.
#' CML does not supply this Person plug-in response target.
#' @section Input normalization corrections in 0.2.4:
#' The shared preparation used by [fit_mfrm()], [describe_mfrm_data()] and
#' anchor review now rounds scores within `1e-6` of an integer to that integer.
#' Earlier preparation accepted that tolerance but then truncated toward zero:
#' for example, `1.9999999` could become category 1 rather than category 2.
#' The new `score_roundoff_normalized` preparation note records affected retained
#' rows. Genuine fractional responses still require explicit recoding.
#' Corrected JML and two-family GPCM retain their stricter exact-integer input
#' checks; explicitly normalize roundoff before using those specialized fits.
#' Numeric observation weights no longer pass through character formatting;
#' their supplied precision is retained. Out-of-range integer category codes,
#' nonrepresentable category spans and overflowing retained-weight totals are
#' refused before likelihood construction.
#'
#' Grouped and rowwise tibbles now behave like their ungrouped versions. Only
#' selected model columns enter preparation; grouping on an unused column does
#' not add that column to the design or remove rows for its missing values.
#' This is one combined analysis, not a separate model for each dplyr group.
#'
#' Facets named `Person`, `Score`, `Weight`, `score_k`, `theta`, `steps`,
#' `interactions`, `log_slopes`, `beta` or `log_sigma2` are now refused before
#' they can collide with internal data or parameter blocks. Rename the facet and update the
#' `facets` argument and any step/slope-owner or anchor references to it. This
#' restriction does not prevent using those names for their intended person,
#' score or observation-weight roles.
#' For example, rename a facet column `steps` to `Stage` and replace
#' `facets = c("Rater", "steps")` with `facets = c("Rater", "Stage")`, also
#' updating any `step_facet`, `slope_facet`, interaction and anchor references.
#' Similar names such as `log_sigma2_group` remain supported. Internal
#' parameter lookup now matches names exactly, preventing those columns from
#' being mistaken for population or slope parameters when those blocks are
#' absent. Older fits using such prefixes should be refitted with the same
#' settings if their calculation entered an affected path, including adaptive
#' MML, where the former partial matching could alter the gradient.
#'
#' If an older fit was affected by category truncation or a column collision,
#' refit from the original corrected data and regenerate its derived results.
#' Editing `prep$data`, `score_map`, parameter names or identity metadata in a saved fit cannot
#' repair estimates computed from a different response coding. Exact integer
#' inputs with ordinary facet names keep their existing preparation behavior.
#'
#' @section Likelihood and convergence corrections in 0.2.4:
#' JML/MML category and posterior normalization now preserve probabilities and
#' log likelihoods when finite log weights share a large offset. Earlier paths
#' could lose the normalizing term through cancellation, even though no
#' exponential overflow occurred. Fits whose estimates or numerical checks
#' entered this regime need refitting with the same data/model and a new
#' numerical review. Saved estimates and derived outputs do not update when
#' the package is updated; do not edit their stored likelihood or readiness flags.
#'
#' Optimizer code zero no longer gives a numerical pass when the terminal
#' gradient is absent, incomplete or contains NA/NaN/Inf. In that case the
#' result reports `code_zero_unavailable_gradient` and remains review-only.
#' Older saved fits with missing or nonfinite gradient diagnostics must not be
#' treated as qualified merely because their stored convergence code is zero.
#' Refitting under the current checks is required before relying on their
#' numerical-readiness claim. A finite recorded norm alone cannot establish
#' that an older full gradient was valid, because earlier code discarded
#' nonfinite entries when calculating that norm. These corrections do not
#' change the response model, estimator, quadrature order or tolerance.
#'
#' Optimizer polishing now rejects candidates with a worse likelihood beyond
#' floating-point rounding error, even if their terminal gradient is smaller.
#' Earlier acceptance used a relative allowance that grew with the objective
#' magnitude. If a saved fit selected such a worse polishing stage, refit with
#' the original data/model/settings and regenerate dependent inference; editing
#' its saved optimizer history does not repair the retained estimates.
#' MML solution checks now return an ineligible result with a reason when
#' likelihood, gradient-norm or information summaries are missing or invalid.
#'
#' Two-family GPCM/GMFRM EM also uses the stable Person-posterior normalization:
#' large common log likelihoods no longer erase quadrature weights or inflate
#' expected response counts. Its log-slope derivatives and the ordinary GPCM
#' JML/MML derivatives avoid cancellation at large, nearly tied category logits.
#' Refit calibrations affected by these numerical
#' defects with their original data and model settings before reusing inference.
#'
#' GPCM profile intervals now require positive nuisance curvature at both
#' integration orders, in addition to their existing optimizer, gradient and
#' start-agreement checks. A shared stationary point need not maximize the
#' constrained likelihood. Recompute saved profile intervals with
#' `confint(fit, parm = "slopes", method = "profile", slope = ...)` to apply this additional
#' check; stored intervals do not update automatically. The source calibration
#' can be reused if it remains eligible and was unaffected by the fitting
#' corrections above. An unresolved curvature check leaves missing bounds and
#' a reason; it does not prove that an interval does not exist. Passing these
#' local checks does not establish a global optimum or sampling coverage.
#'
#' @section Updating saved ability scores in 0.2.4:
#' New-Person and portable-calibration scoring now remove common log-likelihood
#' offsets before applying quadrature weights. This prevents distorted EAPs and
#' posterior SDs when finite likelihood terms are very large in magnitude.
#' Continuous posterior intervals and cut-score probabilities likewise center
#' the likelihood before adding the prior density; otherwise even an
#' ability-independent likelihood could change a normal-prior interval.
#'
#' Recompute affected scores with [predict_mfrm_units()] or
#' [score_mfrm_calibration()], preserving the input rows, calibration, scoring
#' prior, weights, interval level and any cut scores. Regenerate plausible
#' values with the original seed and settings using
#' [sample_mfrm_plausible_values()]. Saved summaries and draws do not update
#' automatically. A scoring-only correction can reuse an eligible unchanged
#' calibration; if its fitted likelihood or convergence checks were affected
#' by the corrections above, refit and review that calibration first. Intervals
#' remain conditional on the point calibration and supplied prior; this
#' correction does not establish frequentist coverage or include calibration
#' uncertainty.
#'
#' The same likelihood-centering correction applies to ordinary source-Person,
#' testlet and shared-rater continuous scoring. Recompute source scores with
#' [score_mfrm_persons()]. For a supplied roster, use [predict.mfrm_testlet()]
#' or [score_mfrm_random_rater()] with the original complete roster and settings.
#' Recompute affected response diagnostics with [mfrm_response_diagnostics()].
#' Testlet nested integration and the shared-rater likelihood also correct
#' cancellation at large finite category ties; calibrations affected during
#' estimation require refitting and renewed numerical checks before reuse.
#' Testlet derivatives now handle a single latent point without dropping a
#' matrix dimension. None of these corrections certify the separate shared-rater
#' Laplace approximation or calibration-adjusted interval coverage.
#'
#' @section Updating saved diagnostics in 0.2.4:
#' Recreate [diagnose_mfrm()] and [estimate_bias()] from the original saved fit
#' with the original diagnostic options, then rebuild reports. Corrected bundles
#' record `calculation_version = 2`; corrections concern PTMEA, ZSTD, displacement,
#' chi-square df, PCM fair scores, bias tests and unexpected-response screening.
#' The main calibration does not need refitting for these changes.
#'
#' To reproduce older conventions, use the explicit controls:
#' - `fit_df_method = "engine"` instead of the current `"facets"` default;
#' - `whexact = "legacy_linear"` for the former calculation; current `TRUE`
#'   means FACETS WHEXACT=NO and historical engine reproduction also needs
#'   `fit_df_method = "engine"`;
#' - `abs_z_min = 2, rule = "either"` for the former unexpected-response rule;
#' - pairwise `df_method = "classical"` for continuous Rasch-Welch df. The current
#'   modified, rounded-down calculation produces `CalculationVersion = 3`.
#'
#' Consumers combining a fit and diagnostics, bias/screening results or predictions
#' require matching calculation/identity metadata. Labels or location estimates
#' alone do not establish a match: retained observations, thresholds, population
#' and integration settings matter. Recreate older results lacking that metadata;
#' do not insert version/identity fields by hand. Imported diagnostics must be
#' those stored in the matching imported fit. Standalone methods keep their own
#' input requirements and do not establish a match to a separate fit. This check
#' does not expand supported model families; CML has its separate interval route.
#' @section Updating saved shrinkage results in 0.2.4:
#' Reapply [apply_empirical_bayes_shrinkage()] to the saved fit using the
#' original prior settings, then regenerate plots and exports. No MFRM refit
#' is needed. Updated reports record `CalculationVersion = 2`; calculations
#' avoid artificial zero SEs and retained weights caused by subtracting a
#' shrinkage factor rounded to one.
#'
#' `shrink_person = TRUE` now requires ordinary JML. For MML or other
#' estimators, use `shrink_person = FALSE`: this removes any previous extra
#' Person adjustment and retains the original Person estimates. MML EAP and
#' posterior SD already describe a posterior distribution; treating them as
#' an observation and sampling SE for another normal update is unsupported.
#' Non-Person facet adjustment remains available within its existing scope.
#'
#' @section Updating saved screening results in 0.2.4:
#' - Recompute [detect_anchor_drift()] and [build_equating_chain()] from saved
#'   fitted waves, then regenerate plots/exports. This corrects offset/SE
#'   arithmetic, singleton spread and unavailable counts without model refitting.
#'   Rebuild chains before offset sensitivity if old offsets no longer match;
#'   the plot now uses the selected measure rather than the first numeric column.
#' - Rerun [analyze_dff()] with `method = "refit"` using the original baseline
#'   and data. This **does rerun subgroup estimation**. Earlier results could
#'   borrow baseline estimates for failed/skipped groups and omit absent targets.
#'   Current methods reject those old objects. Recreate them to obtain retained
#'   cell counts, shared-Person checks and parameter-difference direction labels.
#' - Recompute [estimate_bias()] / [estimate_all_bias()] with the original
#'   facets, limits, filtering and thresholds from the saved fit and matching
#'   diagnostics. This corrects boundary/information checks, incomplete-cell
#'   Infit/Outfit, `||` labels and unavailable screening/multiplicity counts.
#'   Boundary points remain estimates with unavailable SEs/tail areas. Re-screening
#'   does not refit the calibration; printing an old table does not recalculate it.
#' - Bias collections, unexpected-response and displacement results require a
#'   matching `fit_identity` when attached to fit-level reports, QC, exports or
#'   casebooks. Every retained collection member must match. Recreate old or
#'   manually assembled results rather than adding metadata. Identity checks
#'   prevent mixing analyses; they do not qualify formal inference.
#' @section Updating saved predictions in 0.2.4:
#' Older [predict_mfrm_units()] and [sample_mfrm_plausible_values()] outputs need
#' recreation before fit-level manifests, replay scripts or archives can check
#' their `fit_identity`. Reuse the saved calibration and original responses,
#' column mappings, `person_data`, prior, integration, omission policy and seed.
#' This repeats scoring/draws, not calibration estimation.
#'
#' For [predict_mfrm_population()], a forecast created with `fit = fit` must match
#' the archived fit. Recreating it repeats simulations and replication fits,
#' while retaining the original calibration. An explicit `sim_spec = spec`
#' scenario may accompany another fit; `population_prediction_source` and notes
#' identify that distinction. Do not relabel an old result to bypass the check.
#' Replay scripts use the saved simulation specification rather than re-derive
#' it from the replayed calibration, so recreated forecasts are labelled as
#' supplied-specification scenarios. These checks do not alter the uncertainty
#' definitions or eligibility of scoring, plausible values or forecasts.
#' @section Updating saved structural reviews in 0.2.4:
#' [analyze_hierarchical_structure()] now saves `data_identity` metadata.
#' [reporting_checklist()] checks the reviewed column roles and retained rows,
#' including scores when ICC was computed. Raw-data reviews and reviews of a
#' subset of fitted facets remain supported when those data match; the checklist
#' names their scope. Row order, factor level order, unused columns and fitted
#' estimates are irrelevant to this descriptive-data match. Different rating
#' counts, assignments or ICC scores are not interchangeable.
#'
#' Recreate an older review from its saved fit or matching retained rows using
#' the original facets, person/score columns, ICC and connectivity options,
#' missing-value policy and interval settings (including bootstrap seed).
#' This repeats the requested structural/ICC review, not MFRM estimation.
#' Do not add identity metadata to old tables manually. Standalone summary and
#' plot methods retain their existing requirements. Reviews of additional raw
#' rows or grouping columns absent from the fit must be reported separately;
#' they cannot mark this fit's structural-review checklist item as available.
#' Recalculate nesting reviews involving fractional/zero weights or missing
#' facet values: [detect_facet_nesting()] now uses weighted frequencies directly
#' and one common set of observed rows per pair. Earlier results rounded
#' weights and mixed marginal and conditional samples. Weight columns must
#' now be numeric, finite and nonnegative, with some positive weight; missing
#' columns and invalid values are refused instead of ignored or replaced.
#' New `UsedRows`/`ExcludedRows` columns record the pair-specific scope.
#'
#' @section Rating-count review corrections in 0.2.4:
#' In [facet_small_sample_review()], `facet_summary$WorstCategory` now selects
#' the lowest count band, correcting the previous highest-band aggregation.
#' Recreate the review from the saved fit to update older review objects.
#' Count thresholds must now be finite, positive and strictly increasing.
#' The table columns and default thresholds remain the same; the returned
#' `notes` field explains that counts are retained rating rows and cannot
#' establish precision or coverage.
#'
#' In [reporting_checklist()], the item formerly named
#' `"Facet sample-size adequacy"` is now `"Facet rating-count screening"`.
#' Scripts selecting that item by its text must use the new label.
#' Its availability indicates that a count screen is present, including sparse
#' counts, rather than treating a high count band as proof of sample adequacy.
#'
#' @section Retained table-field names:
#' - `row_review` is the data-quality table field used to document row
#'   filtering. FACETS-style column and metric contract results are exposed as
#'   `column_review` and `metric_checks`.
#' - Prediction outputs expose row-preparation and person-omission
#'   traceability as `row_review` and `population_review`.
#' - `hierarchical_review`, `shrinkage_review`, and `nesting_review` are
#'   manifest or model-comparison traceability fields. They are not callable
#'   helper names; user-facing helper names use review/check terminology.
#'
#' @section Companion guides:
#' - For FACETS coverage and boundary wording, see
#'   [facets_positioning_guide()] and [facets_feature_coverage()].
#' - For standard reports/tables, see [mfrmr_reports_and_tables].
#' - For manuscript-draft reporting, see [mfrmr_reporting_and_apa].
#' - For visual diagnostics, see [mfrmr_visual_diagnostics].
#' - For linking and DFF workflows, see [mfrmr_linking_and_dff].
#' - For end-to-end routes, see [mfrmr_workflow_methods].
#'
#' @examples
#' # Long-running workflow; run explicitly when needed.
#' # example("mfrmr_compatibility_layer", run.dontrun = TRUE)
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' toy_small <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
#'
#' run <- run_mfrm_facets(
#'   data = toy_small,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   maxit = 30
#' )
#' summary(run)
#' compatibility_alias_table("functions")
#'
#' fixed <- build_fixed_reports(
#'   estimate_bias(
#'     run$fit,
#'     run$diagnostics,
#'     facet_a = "Rater",
#'     facet_b = "Criterion",
#'     max_iter = 1
#'   ),
#'   branch = "original"
#' )
#' names(fixed)
#'
#' }
#' @name mfrmr_compatibility_layer
NULL

#' List retained compatibility aliases and preferred names
#'
#' @param scope Which alias surface to return: `"all"`, `"functions"`,
#'   `"arguments"`, `"fields"`, `"columns"`, or `"plot_metrics"`.
#'
#' @details
#' This helper is a compact public registry of the compatibility aliases that
#' `mfrmr` intentionally keeps visible for older scripts and downstream
#' handoffs. It is meant to answer two questions quickly:
#' 1. Which old names are still accepted?
#' 2. Which package-native names should new code use instead?
#'
#' Non-exported soft-deprecated helpers are deliberately excluded here. This table
#' is only for retained user-facing aliases that remain part of the public
#' surface.
#'
#' @return A data.frame with one row per retained alias and columns:
#' - `Alias`
#' - `PreferredName`
#' - `Surface`
#' - `Lifecycle`
#' - `RetainedFor`
#' - `RemovalPlan`
#' - `Notes`
#'
#' @section Typical workflow:
#' 1. Call `compatibility_alias_table()` when reading older scripts or reports.
#' 2. Use `PreferredName` when updating older analysis code.
#' 3. Prefer the package-native name in all new outputs and scripts.
#'
#' @seealso [mfrmr_compatibility_layer], [run_mfrm_facets()], [analyze_dff()],
#'   [reporting_checklist()], [fair_average_table()], [plot(x, type = "fair_average")][plot.mfrm_fit]
#' @examples
#' compatibility_alias_table()
#' compatibility_alias_table("functions")
#' compatibility_alias_table("fields")
#' compatibility_alias_table("columns")
#' @export
compatibility_alias_table <- function(scope = c("all", "functions", "arguments", "fields", "columns", "plot_metrics")) {
  scope <- match.arg(scope)

  out <- .mfrmr_table_compatibility_alias_table_out

  if (identical(scope, "all")) {
    return(out)
  }

  scope_map <- c(
    functions = "function",
    arguments = "argument",
    fields = "field",
    columns = "column",
    plot_metrics = "plot_metric"
  )
  out[out$Surface %in% scope_map[[scope]], , drop = FALSE]
}

#' Extract canonical review components
#'
#' @param x A fitted `mfrm_fit`, diagnostics object, summary object, or
#'   compatible list containing the requested review component.
#' @param required Logical. If `TRUE`, error when no compatible review component
#'   is found. If `FALSE`, return `NULL` instead.
#'
#' @details
#' `anchor_review()` returns the fitted object's `config$anchor_review`
#' component. `precision_review()` returns the diagnostics
#' `precision_review` table. These helpers intentionally do not search older
#' field names.
#'
#' @return
#' `anchor_review()` returns an `mfrm_anchor_review`-like object when available.
#' `precision_review()` returns the precision-review table when available.
#' If `required = FALSE` and no component is available, both helpers return
#' `NULL`.
#'
#' @examples
#' fit_like <- list(config = list(
#'   anchor_review = structure(list(issue_counts = data.frame()),
#'                             class = "mfrm_anchor_review")
#' ))
#' anchor_review(fit_like)
#' diag_like <- list(
#'   precision_review = data.frame(Check = "SE", Status = "ok", Detail = "Model-based")
#' )
#' precision_review(diag_like)
#' @name review_accessors
#' @export
anchor_review <- function(x, required = TRUE) {
  required <- isTRUE(required)

  if (inherits(x, "mfrm_anchor_review")) {
    return(x)
  }
  if (!is.list(x)) {
    stop("`x` must be an `mfrm_fit`, anchor-review object, or compatible list.", call. = FALSE)
  }

  config <- x$config %||% x
  out <- config$anchor_review
  if (is.null(out)) {
    if (!required) return(NULL)
    stop(
      "No anchor-review component was found. Use `fit$config$anchor_review`, ",
      "or run `review_mfrm_anchors()`.",
      call. = FALSE
    )
  }
  out
}

#' @rdname review_accessors
#' @export
precision_review <- function(x, required = TRUE) {
  required <- isTRUE(required)

  if (inherits(x, "mfrm_precision_review")) {
    validate_precision_review_profile(x$profile)
    return(x)
  }
  if (!is.list(x)) {
    stop("`x` must be an `mfrm_diagnostics`, precision-review object, or compatible list.", call. = FALSE)
  }
  validate_diagnostics_precision(x)

  out <- x$precision_review
  if (is.null(out)) {
    if (!required) return(NULL)
    stop(
      "No precision-review component was found. Run `diagnose_mfrm()` and use ",
      "`diagnostics$precision_review`.",
      call. = FALSE
    )
  }
  out
}
