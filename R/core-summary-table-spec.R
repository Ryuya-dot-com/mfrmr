# Table order, reporting roles and descriptions shared by the standard summary bundles.
# Each row is c(table name, reporting role, description).
# Sources and converters only list fields that differ from the default data-frame route.
.mfrmr_summary_table_specs <- list(
  "summary.mfrm_fit" = list(
    title = "Model Summary Tables",
    fields = rbind(
      c("overview", "run_overview", "One-row model fit, convergence, and information-criteria overview."),
      c("population_overview", "population_basis", "Population-model basis, posterior basis, and omission review."),
      c("population_design", "population_design", "Population-model design-matrix columns and numeric check statistics."),
      c("population_coefficients", "population_coefficients", "Latent-regression coefficients when the population model is active."),
      c("population_coding", "population_coding", "Latent-regression categorical covariate levels, contrasts, and encoded model-matrix columns."),
      c("facet_overview", "facet_distribution", "Per-facet spread, range, and level-count summary."),
      c("person_overview", "person_distribution", "Distribution of person measures and posterior SD summaries."),
      c("step_overview", "category_structure", "Threshold range and monotonicity summary."),
      c("slope_overview", "gpcm_discrimination", "GPCM discrimination summary under the current identification."),
      c("settings_overview", "estimation_settings", "Estimation settings that affect identification and interpretation."),
      c("reporting_map", "reporting_map", "Companion outputs to cite for manuscript-oriented reporting."),
      c("caveats", "analysis_caveats", "Structured fit-level caveats such as retained zero-count categories, score-category recoding, and latent-regression population-model warnings."),
      c("facet_extremes", "extreme_facet_levels", "Facet levels with the largest absolute estimates."),
      c("person_high", "extreme_person_high", "Highest person measures from the current fit."),
      c("person_low", "extreme_person_low", "Lowest person measures from the current fit.")
    )
  ),
  "summary.mfrm_diagnostics" = list(
    title = "Diagnostics Summary Tables",
    fields = rbind(
      c("overview", "run_overview", "Run-level diagnostic coverage and precision tier."),
      c("fit_screening", "flag_counts", "Classified, unclassified and flagged elements for each mean-square/ZSTD screen; rates require complete classification."),
      c("marginal_coverage", "flag_counts", "Classified, unclassified and flagged marginal cells, groups and level pairs; unavailable results are not zero flags."),
      c("overall_fit", "overall_fit", "Global fit statistics from the current diagnostic run."),
      c("precision_profile", "precision_basis", "Precision basis and recommended interpretation tier."),
      c("precision_review", "precision_review", "Precision checks marked review/warn for manuscript caution."),
      c("reliability", "facet_precision", "Facet-level separation, strata, and reliability summary."),
      c("top_fit", "extreme_fit_rows", "Rows with the largest absolute fit Z statistics."),
      c("reporting_map", "reporting_map", "Companion outputs for manuscript reporting beyond summary(diag)."),
      c("flags", "flag_counts", "Counts of unexpected responses, displacement, interactions, and inter-rater pairs.")
    ),
    description_order = c("overview", "marginal_coverage", "fit_screening", "overall_fit", "precision_profile", "precision_review", 
    "reliability", "top_fit", "reporting_map", "flags")
  ),
  "summary.mfrm_precision_review" = list(
    title = "Precision Review Tables",
    fields = rbind(
      c("overview", "run_overview", "Run-level precision-review bundle metadata."),
      c("summary", "precision_basis", "One-row precision tier, formal-inference support, and fit/separation row counts."),
      c("profile", "precision_basis", "Precision basis, method tier, and formal-inference support for the current run."),
      c("checks", "precision_review", "Precision checks that should be reviewed before reporting SE, CI, or reliability claims."),
      c("fit_separation_basis", "precision_review", "Source-grounded boundary table for fit MnSq, ZSTD, separation/reliability/strata, and QC-threshold interpretation."),
      c("approximation_notes", "interpretation_notes", "Approximation notes carried from diagnostics for uncertainty-reporting caveats."),
      c("settings", "review_settings", "Precision-review settings used for the current run."),
      c("caveats", "analysis_caveats", "Structured fit-level caveats carried with the precision review."),
      c("notes", "interpretation_notes", "Compact interpretation notes for precision, fit, and separation reporting.")
    ),
    converters = list(notes = "text")
  ),
  "summary.mfrm_fit_measures" = list(
    title = "Fit-Measure Review Tables",
    fields = rbind(
      c("overview", "run_overview", "Run-level fit-measure bundle metadata."),
      c("summary", "overall_fit", "Overall fit-status counts, df-sensitivity counts, and displayed-row coverage."),
      c("table", "extreme_fit_rows", "Selected fit-measure rows with MnSq, ZSTD, confidence intervals, status labels, and df-sensitivity columns."),
      c("facets_table", "extreme_fit_rows", "FACETS-style fit table columns for manuscript or external-output review."),
      c("status_summary", "review_status", "Counts by facet and fit-review status."),
      c("threshold_profiles", "review_settings", "Fit-threshold profiles used for status and sensitivity summaries."),
      c("profile_summary", "overall_fit", "Fit-flag rates under the requested threshold profiles."),
      c("profile_summary_by_facet", "facet_distribution", "Facet-level fit-flag rates under the requested threshold profiles."),
      c("profile_summary_overall", "overall_fit", "Overall fit-flag rates under the requested threshold profiles."),
      c("df_sensitivity", "precision_review", "Engine-vs-FACETS-style df/ZSTD comparison rows."),
      c("df_sensitive", "precision_review", "Subset of df-sensitivity rows where df convention changes flag status or materially shifts ZSTD."),
      c("df_sensitivity_summary", "review_status", "Counts by df-sensitivity status for the selected fit-measure surface."),
      c("underfit", "extreme_fit_rows", "Rows labelled underfit under the selected fit bands."),
      c("overfit", "extreme_fit_rows", "Rows labelled overfit under the selected fit bands."),
      c("mixed", "extreme_fit_rows", "Rows with mixed underfit and overfit evidence across fit columns."),
      c("settings", "review_settings", "Fit-measure review settings and thresholds."),
      c("caveats", "analysis_caveats", "Structured fit-level caveats carried with the fit-measure review."),
      c("notes", "interpretation_notes", "Compact interpretation notes for fit-measure reporting.")
    ),
    converters = list(notes = "text")
  ),
  "summary.mfrm_facets_fit_review" = list(
    title = "FACETS Fit-Review Tables",
    fields = rbind(
      c("overview", "run_overview", "Run-level FACETS fit-review bundle metadata."),
      c("summary", "overall_fit", "Overview of within-mfrmr df/ZSTD sensitivity and optional external FACETS comparison coverage."),
      c("standardization", "review_settings", "Primary fit-df method, companion columns, and ZSTD transform metadata from diagnostics."),
      c("df_sensitivity", "precision_review", "Engine-vs-FACETS-style df/ZSTD comparison rows."),
      c("df_sensitive", "precision_review", "Subset of df-sensitivity rows where df convention changes flag status or materially shifts ZSTD."),
      c("df_sensitivity_summary", "review_status", "Counts by df-sensitivity status."),
      c("external_table_quality", "review_status", "Completeness and duplicate-key review for supplied external FACETS fit rows."),
      c("external_comparison", "precision_review", "Matched external FACETS-vs-mfrmr fit comparison rows when supplied."),
      c("guidance", "interpretation_notes", "Interpretation notes separating MnSq, ZSTD, df convention, external matching, and GPCM scope."),
      c("settings", "review_settings", "FACETS fit-review tolerances and metadata."),
      c("caveats", "analysis_caveats", "Structured fit-level caveats carried with the FACETS fit review."),
      c("notes", "interpretation_notes", "Compact interpretation notes for FACETS fit-review reporting.")
    ),
    converters = list(notes = "text")
  ),
  "summary.mfrm_person_fit_indices" = list(
    title = "Person-Fit Summary Tables",
    fields = rbind(
      c("overview", "overall_fit", "Run-level person-fit counts, reportable rows, Snijders-corrected rows, and flag rates."),
      c("status_summary", "review_status", "Counts by report-level person-fit review status."),
      c("report_index_summary", "review_status", "Counts showing whether the report index used lz_star, lz, or no finite statistic."),
      c("lz_star_status_summary", "review_status", "Counts by Snijders-correction availability/status."),
      c("top_review", "extreme_fit_rows", "Highest-priority person rows for response-level follow-up."),
      c("caveats", "analysis_caveats", "Visible caveats explaining whether lz_star or uncorrected lz underlies each reporting route."),
      c("thresholds", "review_settings", "Practical two-sided z thresholds used for person-fit flags."),
      c("reporting_map", "reporting_map", "Companion outputs for response-level follow-up and draw-free plot-data handoff."),
      c("notes", "interpretation_notes", "Compact interpretation notes for person-fit reporting.")
    ),
    converters = list(notes = "text")
  ),
  "summary.mfrm_data_description" = list(
    title = "Data Description Tables",
    fields = rbind(
      c("overview", "run_overview", "One-row sample, design, and rating-span overview."),
      c("missing", "missingness", "Missing-value counts by selected input column."),
      c("score_distribution", "score_usage", "Observed score distribution for category-usage reporting."),
      c("facet_overview", "facet_coverage", "Facet-level coverage and weighted counts."),
      c("agreement", "agreement", "Observed inter-rater agreement summary when available."),
      c("reporting_map", "reporting_map", "Companion outputs for fit, reliability, and residual follow-up."),
      c("caveats", "score_category_caveats", "Structured pre-fit score-support caveats such as retained zero-count categories.")
    )
  ),
  "summary.mfrm_reporting_checklist" = list(
    title = "Reporting Checklist Tables",
    fields = rbind(
      c("overview", "checklist_overview", "Overall checklist coverage across sections and draft-readiness flags."),
      c("section_summary", "section_coverage", "Coverage summary by reporting section."),
      c("facets_positioning", "facets_relationship_wording", "Report-ready wording that separates mfrmr estimation from FACETS-style handoff or external-table review."),
      c("priority_summary", "priority_distribution", "High/medium/low/ready counts by severity."),
      c("action_items", "draft_actions", "Top unresolved manuscript-drafting actions."),
      c("settings", "checklist_settings", "Checklist settings used to build the reporting contract.")
    )
  ),
  "summary.mfrm_apa_outputs" = list(
    title = "APA Output Tables",
    fields = rbind(
      c("overview", "draft_overview", "Overall coverage for manuscript draft text products."),
      c("components", "component_stats", "Per-component line, character, and mention counts."),
      c("sections", "section_coverage", "Availability of the package-native section map."),
      c("content_checks", "draft_checks", "Checks of draft completeness and agreement with the supplied results."),
      c("preview", "text_preview", "Compact preview of the first non-empty lines in each draft component.")
    )
  ),
  "summary.mfrm_diagnostic_screening" = list(
    title = "Diagnostic Screening Tables",
    fields = rbind(
      c("overview", "diagnostic_screening_overview", "Run-level overview for the current diagnostic-screening simulation study."),
      c("reading_order", "diagnostic_screening_reading_order", "Recommended reading order for diagnostic-screening summaries and appendix tables."),
      c("next_actions", "diagnostic_screening_next_actions", "Action-oriented triage for replication count, run completion, contrasts, report signals, and export."),
      c("reporting_notes", "diagnostic_screening_reporting_notes", "Report-facing boundaries and recommended wording safeguards for diagnostic-screening output."),
      c("figure_recipes", "diagnostic_screening_figure_recipes", "Figure/display recipes linking plot calls, plot_data extraction, caption focus, and interpretation boundaries."),
      c("scenario_summary", "diagnostic_screening_scenario_summary", "Aggregated scenario-by-design legacy and strict marginal/pairwise screening summaries."),
      c("performance_summary", "diagnostic_screening_performance", "Scenario-by-design any-flag rates, agreement rates, elapsed time, and Type I/sensitivity proxies."),
      c("report_signal_summary", "diagnostic_screening_report_signals", "Optional report-index availability/readiness and review-signal summaries when include_report = TRUE."),
      c("scenario_contrast", "diagnostic_screening_contrast", "Misspecification-minus-well-specified contrasts for legacy and strict screening signals."),
      c("plot_overview_rate", "diagnostic_screening_plot_data", "Long-form overview-rate plot data for legacy, strict, and optional report-review signals."),
      c("plot_overview_count", "diagnostic_screening_plot_data", "Long-form overview-count plot data for flagged counts and report-signal counts."),
      c("plot_report_rate", "diagnostic_screening_plot_data", "Long-form report-rate plot data from report_signal_summary."),
      c("plot_contrast_count", "diagnostic_screening_plot_data", "Long-form scenario-contrast count plot data."),
      c("plot_runtime", "diagnostic_screening_runtime", "Long-form runtime plot data."),
      c("ademp", "diagnostic_screening_design_basis", "ADEMP-style description of the diagnostic-screening simulation aim, data-generating mechanism, estimands, methods, and performance measures."),
      c("settings", "diagnostic_screening_settings", "Diagnostic-screening simulation settings used to generate, fit, diagnose, and optionally report repeated datasets."),
      c("notes", "interpretation_notes", "Compact interpretation notes for diagnostic-screening reporting.")
    ),
    converters = list(ademp = "recovery_ademp", settings = "settings", notes = "text")
  ),
  "summary.mfrm_recovery_simulation" = list(
    title = "Recovery Simulation Tables",
    fields = rbind(
      c("overview", "recovery_overview", "Run-level overview for the current parameter-recovery simulation."),
      c("recovery_summary", "recovery_performance", "Parameter-group recovery metrics, including bias, RMSE, coverage, and Monte Carlo SE."),
      c("rep_overview", "recovery_replications", "Replication-level fit status, convergence status, recovery-row counts, and elapsed time."),
      c("sparse_review", "recovery_sparse_design_diagnostics", "Compact replication-level sparse linked design-review counts kept separate from recovery metrics."),
      c("sparse_design", "recovery_sparse_design_diagnostics", "Replication-level sparse linked planned-missingness and rater-link diagnostics retained separately from recovery metrics."),
      c("diagnostic_oc", "recovery_diagnostic_operating_characteristics", "Optional replication-by-facet fit/separation operating characteristics retained when include_diagnostics = TRUE."),
      c("diagnostic_oc_summary", "recovery_diagnostic_oc_summary", "Optional facet-level fit/separation operating-characteristic summary for diagnostic context."),
      c("ademp", "recovery_design_basis", "ADEMP-style description of the recovery simulation aim, data-generating mechanism, estimands, methods, and performance measures."),
      c("settings", "recovery_settings", "Recovery simulation settings used to generate and refit repeated datasets."),
      c("notes", "interpretation_notes", "Compact interpretation notes for recovery simulation reporting.")
    ),
    sources = list(sparse_design = "rep_overview"),
    converters = list(sparse_design = "sparse_design", ademp = "recovery_ademp", settings = "settings", notes = "text")
  ),
  "summary.mfrm_recovery_assessment" = list(
    title = "Recovery Assessment Tables",
    fields = rbind(
      c("overview", "recovery_assessment_overview", "Run-level recovery adequacy status for the current assessment."),
      c("reading_order", "recovery_assessment_reading_order", "Recommended first-read order for recovery assessment summary, condition, plot, and row-level outputs."),
      c("checklist", "recovery_assessment_checklist", "Reviewer-facing adequacy checklist for replication count, convergence, uncertainty, Monte Carlo precision, and practical thresholds."),
      c("condition_reporting_notes", "recovery_condition_reporting_notes", "Reporter-facing generator-condition notes for GPCM slope stress and generated score-category support."),
      c("condition_review", "recovery_condition_review", "Generator-condition metadata for interpreting recovery evidence, including GPCM slope-regime labels and generated score-category support when available."),
      c("diagnostic_reporting_notes", "recovery_diagnostic_reporting_notes", "Reporter-facing fit/separation diagnostic notes that flag caveats without treating them as recovery criteria."),
      c("diagnostic_review", "recovery_diagnostic_review", "Fit/separation operating-characteristic review retained as diagnostic context rather than a recovery criterion."),
      c("metric_review", "recovery_metric_review", "Parameter-group recovery review with threshold status and next-action guidance."),
      c("uncertainty_review", "recovery_uncertainty_review", "Parameter-group coverage and standard-error availability interpretation."),
      c("next_actions", "repair_recommendations", "Prioritized follow-up actions for strengthening or documenting the recovery evidence."),
      c("thresholds", "review_settings", "Assessment thresholds used to classify recovery adequacy."),
      c("notes", "interpretation_notes", "Compact interpretation notes for recovery assessment reporting.")
    ),
    converters = list(next_actions = "text", thresholds = "settings", notes = "text"),
    text_columns = list(next_actions = "Action")
  ),
  "summary.mfrmr_recovery_validation" = list(
    title = "Recovery Evidence Tables",
    fields = rbind(
      c("evidence_overview", "recovery_evidence_overview", "Top-line recovery-evidence assessment across the summarized cases."),
      c("reading_order", "recovery_validation_reading_order", "Recommended first-read order for recovery-evidence summary outputs."),
      c("case_evidence_assessment", "recovery_evidence_case_assessment", "Case-level recovery-evidence table with recovery, uncertainty, and Monte Carlo status."),
      c("case_summary", "recovery_validation_case_summary", "Case-level validation summary including recovery status and generator-condition fields."),
      c("condition_reporting_notes", "recovery_validation_condition_reporting_notes", "Reporter-facing generator-condition notes for slope-regime and score-support caveats."),
      c("condition_summary", "recovery_validation_condition_summary", "Generator-condition summary for slope-regime and score-support evidence across validation cases."),
      c("diagnostic_reporting_notes", "recovery_validation_diagnostic_reporting_notes", "Reporter-facing fit/separation notes that retain caveats without treating diagnostics as standalone validation criteria."),
      c("diagnostic_oc_summary", "recovery_validation_diagnostic_oc_summary", "Fit/separation operating-characteristic summary across validation cases, retained as diagnostic-only context."),
      c("domain_decision_table", "recovery_validation_domain_decisions", "Long-form validation-domain status table for recovery metrics, uncertainty, Monte Carlo precision, score support, and overall status.")
    ),
    sources = list(evidence_overview = "topline_release_decision", case_evidence_assessment = "release_decision_table")
  ),
  "summary.mfrm_facets_run" = list(
    title = "Workflow Summary Tables",
    fields = rbind(
      c("overview", "workflow_overview", "Legacy-compatible workflow overview with fit metadata."),
      c("mapping", "column_mapping", "Resolved column mapping for the one-shot workflow run."),
      c("run_info", "workflow_settings", "Workflow settings and pipeline metadata recorded by run_mfrm_facets()."),
      c("fit_overview", "run_overview", "Nested model-fit overview routed from summary(out$fit)."),
      c("fit_reporting_map", "reporting_map", "Nested reporting-map follow-up routed from summary(out$fit)."),
      c("diagnostic_overview", "run_overview", "Nested diagnostic overview routed from summary(out$diagnostics)."),
      c("diagnostic_flags", "flag_counts", "Nested diagnostic flag counts routed from summary(out$diagnostics)."),
      c("diagnostic_reporting_map", "reporting_map", "Nested reporting-map follow-up routed from summary(out$diagnostics).")
    ),
    sources = list(fit_overview = c("fit", "overview"), fit_reporting_map = c("fit", "reporting_map"), diagnostic_overview = c("diagnostics", 
    "overview"), diagnostic_flags = c("diagnostics", "flags"), diagnostic_reporting_map = c("diagnostics", 
    "reporting_map"))
  ),
  "summary.mfrm_results" = list(
    title = "Comprehensive Results Tables",
    fields = rbind(
      c("overview", "workflow_overview", "High-level mfrm_results run overview with component, table, and plot-route counts."),
      c("triage", "review_status", "First-screen reading order for unavailable, review, information, and OK signals."),
      c("status", "review_status", "Section-level availability table for automatically assembled result components."),
      c("component_index", "reporting_map", "Classes of the fitted, diagnostic, report, review, and table components retained in the object."),
      c("table_index", "reporting_map", "Available table registry with size and numeric plotting readiness."),
      c("plot_map", "plot_routing", "User-facing plot routes exposed by plot.mfrm_results()."),
      c("next_actions", "draft_actions", "Prioritized next-action routes after the comprehensive first screen."),
      c("mapping", "column_mapping", "Column mapping used when mfrm_results() started from a data.frame or run_mfrm_facets() object."),
      c("reproducible_code", "workflow_settings", "Line-by-line replay script for the mfrm_results() route."),
      c("notes", "interpretation_notes", "Compact interpretation notes carried by mfrm_results().")
    ),
    converters = list(notes = "text")
  ),
  "summary.mfrm_report" = list(
    title = "Report Summary Tables",
    fields = rbind(
      c("study_context", "study_design", "User-declared study and score meaning; not validated by the model."),
      c("overview", "report_overview", "Reader-facing report status row derived from mfrm_report() first_screen."),
      c("first_screen", "first_screen", "Compact FACETS-like first screen with status, main issue, next action, and route."),
      c("status_counts", "review_status", "Counts of evidence areas by first-screen status."),
      c("immediate_actions", "draft_actions", "Unavailable, review, and caveated areas to inspect before drafting."),
      c("optional_sections", "requested_followup", "Not-requested evidence areas to request only when the claim is needed."),
      c("claim_readiness", "claim_readiness", "Claim-readiness counts summarized from the report object."),
      c("report_gaps", "draft_actions", "Highest-priority report gaps and recommended actions."),
      c("boundary_index", "claim_boundary", "Template-boundary rows to review before using report wording."),
      c("routes", "reporting_map", "Standard report-reading and export routes.")
    )
  ),
  "summary.mfrm_bias" = list(
    title = "Bias Summary Tables",
    fields = rbind(
      c("overview", "bias_overview", "Interaction-order overview and screening counts for the current bias run."),
      c("chi_sq", "bias_chi_square", "Fixed-effect chi-square block from the current bias run."),
      c("final_iteration", "bias_iteration_status", "Final bias-iteration status row for stabilization checks."),
      c("top_rows", "bias_screening_rows", "Highest-|t| interaction rows for immediate follow-up."),
      c("notes", "interpretation_notes", "Compact interpretation notes for screening-oriented bias reporting.")
    ),
    converters = list(notes = "text")
  )
)

assemble_summary_table_spec <- function(summary_obj, definition) {
  fields <- definition$fields[, 1L]
  tables <- stats::setNames(lapply(fields, function(field) {
    value <- summary_obj
    for (part in definition$sources[[field]] %||% field) {
      value <- do.call("$", list(value, part))
    }
    switch(definition$converters[[field]] %||% "df",
      df = summary_table_bundle_df(value),
      text = summary_table_bundle_text_df(value,
        column = definition$text_columns[[field]] %||% "Note"),
      settings = summary_table_bundle_settings_df(value),
      sparse_design = summary_table_bundle_sparse_design_df(value),
      recovery_ademp = summary_table_bundle_recovery_ademp_df(value)
    )
  }), fields)
  descriptions <- stats::setNames(definition$fields[, 3L], fields)
  if (!is.null(definition$description_order)) {
    descriptions <- descriptions[definition$description_order]
  }
  list(title = definition$title, tables = tables,
    roles = stats::setNames(definition$fields[, 2L], fields),
    descriptions = descriptions)
}

