# Standard summary tables: field, heading, conversion, rounding and original availability guard.
# Keep these definitions separate from warnings, interpretation and privacy decisions.
.mfrmr_summary_print_sections <- list(
  "print.summary.mfrm_anchor_drift_01" = rbind(
    c(field = "common_elements", heading = "\nCommon elements:\n", cast = "frame", rounded = "no", guard = "required"),
    c("common_by_facet", "\nRetained common elements by facet:\n", "frame", "no", "required")
  ),
  "print.summary.mfrm_linking_review_01" = rbind(
    c(field = "plot_routes", heading = "\nPlot Follow-up\n", cast = "frame", rounded = "no", guard = "required")
  ),
  "print.summary.mfrm_misfit_casebook_01" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "yes", guard = "required"),
    c("status", "\nStatus\n", "frame", "no", "required")
  ),
  "print.summary.mfrm_misfit_casebook_02" = rbind(
    c(field = "case_rollup", heading = "\nCase Rollup\n", cast = "frame", rounded = "yes", guard = "required"),
    c("group_view_index", "\nGrouping Views\n", "frame", "no", "required"),
    c("plot_routes", "\nPlot Follow-up\n", "frame", "no", "required"),
    c("source_summary", "\nSource Summary\n", "frame", "yes", "required"),
    c("source_support", "\nSource Support\n", "frame", "no", "required"),
    c("top_cases", "\nTop Cases\n", "frame", "yes", "required"),
    c("support_status", "\nSupport Status\n", "frame", "no", "required")
  ),
  "print.summary.mfrm_weighting_review_01" = rbind(
    c(field = "top_measure_shifts", heading = "\nTop Measure Shifts\n", cast = "frame", rounded = "yes", guard = "required"),
    c("top_reweighted_levels", "\nTop Reweighted Levels\n", "frame", "yes", "required")
  ),
  "print.summary.mfrm_model_choice_review_01" = rbind(
    c(field = "weighting_review_status", heading = "\nWeighting Review Status\n", cast = "frame", rounded = "no", guard = "required")
  ),
  "print.summary.mfrm_facet_dashboard_01" = rbind(
    c(field = "settings", heading = "\nSettings\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.mfrm_data_description_01" = rbind(
    c(field = "design_connectivity", heading = "\nPerson-facet connectivity\n", cast = "frame", rounded = "no", guard = "present"),
    c("score_distribution", "\nScore distribution\n", "raw", "no", "present")
  ),
  "print.summary.mfrm_data_description_01" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "yes", guard = "present"),
    c("missing", "\nMissing by column\n", "frame", "yes", "present"),
    c("structural_missingness", "\nPlanned assignment coverage\n", "frame", "yes", "present"),
    c("design_connectivity", "\nPerson-facet connectivity\n", "frame", "yes", "present"),
    c("linkage_summary", "\nFacet linkage support\n", "frame", "yes", "present"),
    c("score_distribution", "\nScore distribution\n", "frame", "yes", "present"),
    c("facet_overview", "\nFacet coverage\n", "frame", "yes", "present")
  ),
  "print.summary.mfrm_data_description_02" = rbind(
    c(field = "reporting_map", heading = "\nPaper reporting map\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.mfrm_anchor_review_01" = rbind(
    c(field = "facet_summary", heading = "\nFacet summary\n", cast = "raw", rounded = "no", guard = "present")
  ),
  "print.summary.mfrm_anchor_review_01" = rbind(
    c(field = "issue_counts", heading = "\nIssue counts\n", cast = "frame", rounded = "yes", guard = "present"),
    c("facet_summary", "\nFacet summary\n", "frame", "yes", "present"),
    c("level_observation_summary", "\nLevel observation summary\n", "frame", "yes", "present"),
    c("category_counts", "\nCategory counts\n", "frame", "yes", "present")
  ),
  "print.summary.mfrm_bundle_01" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "yes", guard = "present"),
    c("count_distribution", "\nCount distribution\n", "frame", "yes", "present"),
    c("low_count_cells", "\nLow-count cells (preview)\n", "frame", "yes", "present"),
    c("thresholds", "\nThresholds\n", "frame", "no", "present")
  ),
  "print.summary.mfrm_bundle_02" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "yes", guard = "present"),
    c("summary", "\nWarning counts\n", "frame", "yes", "present"),
    c("summary_counts", "\nSummary counts\n", "frame", "yes", "present"),
    c("settings", "\nFACETS crosswalk\n", "frame", "no", "present"),
    c("plot_routes", "\nPublic plot routes\n", "frame", "no", "present")
  ),
  "print.summary.mfrm_bundle_03" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "yes", guard = "present"),
    c("preview", "\nPairwise preview\n", "frame", "yes", "present")
  ),
  "print.summary.mfrm_diagnostics_01" = rbind(
    c(field = "flags", heading = "\nFlag counts\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.summary.mfrm_diagnostics_02" = rbind(
    c(field = "fit_standardization", heading = "\nFit ZSTD standardization\n", cast = "frame", rounded = "yes", guard = "present")
  ),
  "print.summary.mfrm_diagnostics_03" = rbind(
    c(field = "precision_profile", heading = "\nPrecision basis\n", cast = "frame", rounded = "yes", guard = "present")
  ),
  "print.summary.mfrm_diagnostics_04" = rbind(
    c(field = "facets_chisq", heading = "\nFacet variability (fixed-effect chi-square; null = all elements equal)\n", cast = "frame", rounded = "yes", guard = "present"),
    c("interrater", "\nInter-rater agreement summary\n", "frame", "yes", "present")
  ),
  "print.summary.mfrm_diagnostics_05" = rbind(
    c(field = "category_usage", heading = "\nCategory usage (Count + AvgMeasure within each observed score)\n", cast = "frame", rounded = "yes", guard = "present")
  ),
  "print.summary.mfrm_diagnostics_06" = rbind(
    c(field = "top_marginal_cells", heading = "\nLargest marginal residual cells\n", cast = "frame", rounded = "yes", guard = "present")
  ),
  "print.summary.mfrm_diagnostics_07" = rbind(
    c(field = "top_marginal_pairs", heading = "\nLargest marginal pairwise residuals\n", cast = "frame", rounded = "yes", guard = "present")
  ),
  "print.summary.mfrm_diagnostics_08" = rbind(
    c(field = "reporting_map", heading = "\nPaper reporting map\n", cast = "frame", rounded = "no", guard = "present"),
    c("flags", "\nFlag counts\n", "frame", "no", "present")
  ),
  "print.summary.mfrm_bias_01" = rbind(
    c(field = "chi_sq", heading = "\nFixed-effect chi-square\n", cast = "frame", rounded = "yes", guard = "present"),
    c("final_iteration", "\nFinal iteration status\n", "frame", "yes", "present"),
    c("top_rows", "\nTop |t| bias rows\n", "frame", "yes", "present")
  ),
  "print.summary.mfrm_fit_01" = rbind(
    c(field = "facet_overview", heading = "\nFacet measure overview\n", cast = "frame", rounded = "yes", guard = "fallback")
  ),
  "print.summary.mfrm_fit_02" = rbind(
    c(field = "step_overview", heading = "\nStep parameter summary\n", cast = "frame", rounded = "yes", guard = "fallback")
  ),
  "print.summary.mfrm_fit_03" = rbind(
    c(field = "population_design", heading = "\nPopulation design matrix\n", cast = "frame", rounded = "yes", guard = "fallback"),
    c("population_coding", "\nPopulation covariate coding\n", "frame", "no", "fallback"),
    c("population_coefficients", "\nPopulation coefficients\n", "frame", "yes", "required"),
    c("facet_overview", "\nFacet overview\n", "frame", "yes", "required")
  ),
  "print.summary.mfrm_fit_04" = rbind(
    c(field = "targeting", heading = "\nTargeting (Person vs facet means; sum-to-zero ID makes Targeting = Person mean)\n", cast = "frame", rounded = "yes", guard = "fallback"),
    c("step_overview", "\nStep parameter summary\n", "frame", "yes", "required")
  ),
  "print.summary.mfrm_fit_05" = rbind(
    c(field = "interaction_overview", heading = "\nFacet interaction summary\n", cast = "frame", rounded = "yes", guard = "fallback")
  ),
  "print.summary.mfrm_fit_06" = rbind(
    c(field = "facet_extremes", heading = "\nMost extreme facet levels (|estimate|)\n", cast = "frame", rounded = "yes", guard = "required")
  ),
  "print.summary.mfrm_fit_07" = rbind(
    c(field = "reporting_map", heading = "\nPaper reporting map\n", cast = "frame", rounded = "no", guard = "fallback")
  ),
  "print.summary.mfrm_reporting_checklist_01" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "no", guard = "present"),
    c("section_summary", "\nSection summary\n", "frame", "no", "present"),
    c("priority_summary", "\nPriority summary\n", "frame", "no", "present"),
    c("action_items", "\nAction items (preview)\n", "frame", "no", "present")
  ),
  "print.summary.mfrm_reporting_checklist_02" = rbind(
    c(field = "settings", heading = "\nSettings\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.summary.mfrm_apa_outputs_01" = rbind(
    c(field = "sections", heading = "\nSections\n", cast = "frame", rounded = "no", guard = "present"),
    c("content_checks", "\nContent checks\n", "frame", "no", "present")
  ),
  "print.summary.mfrm_apa_outputs_02" = rbind(
    c(field = "preview", heading = "\nPreview\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.mfrm_summary_table_bundle_01" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "no", guard = "present"),
    c("table_index", "\nTable index\n", "frame", "no", "present"),
    c("plot_index", "\nPlot index\n", "frame", "no", "present")
  ),
  "print.summary.mfrm_summary_table_bundle_01" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "yes", guard = "present"),
    c("role_summary", "\nRole summary\n", "frame", "yes", "present"),
    c("table_catalog", "\nTable catalog\n", "frame", "yes", "present"),
    c("table_profile", "\nTable profile\n", "frame", "yes", "present"),
    c("plot_index", "\nPlot index\n", "frame", "yes", "present"),
    c("appendix_presets", "\nAppendix presets\n", "frame", "yes", "present"),
    c("appendix_role_summary", "\nAppendix role summary\n", "frame", "yes", "present"),
    c("appendix_section_summary", "\nAppendix section summary\n", "frame", "yes", "present"),
    c("selection_summary", "\nSelection summary\n", "frame", "yes", "present"),
    c("selection_table_summary", "\nSelection table summary\n", "frame", "yes", "present"),
    c("selection_table_preset_summary", "\nSelection table preset summary\n", "frame", "yes", "present"),
    c("selection_handoff_table_summary", "\nSelection handoff table summary\n", "frame", "yes", "present"),
    c("selection_handoff_preset_summary", "\nSelection handoff preset summary\n", "frame", "yes", "present"),
    c("selection_handoff_summary", "\nSelection handoff summary\n", "frame", "yes", "present"),
    c("selection_handoff_bundle_summary", "\nSelection handoff bundle summary\n", "frame", "yes", "present"),
    c("selection_handoff_role_summary", "\nSelection handoff role summary\n", "frame", "yes", "present"),
    c("selection_handoff_role_section_summary", "\nSelection handoff role-section summary\n", "frame", "yes", "present"),
    c("selection_role_summary", "\nSelection role summary\n", "frame", "yes", "present"),
    c("selection_section_summary", "\nSelection section summary\n", "frame", "yes", "present"),
    c("selection_catalog", "\nSelection catalog\n", "frame", "yes", "present"),
    c("reporting_map", "\nReporting map\n", "frame", "no", "present")
  ),
  "print.summary.apa_table_01" = rbind(
    c(field = "numeric_profile", heading = "\nNumeric profile\n", cast = "frame", rounded = "yes", guard = "present")
  ),
  "print.summary.mfrm_threshold_profiles_01" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "no", guard = "present"),
    c("thresholds", "\nProfile thresholds\n", "frame", "yes", "present"),
    c("threshold_ranges", "\nThreshold ranges across profiles\n", "frame", "yes", "present")
  ),
  "print.summary.mfrm_resampling_spec_01" = rbind(
    c(field = "stratum_overview", heading = "\nStrata\n", cast = "raw", rounded = "no", guard = "required"),
    c("preserve_overview", "\nPreserve-facet coverage basis\n", "raw", "no", "required")
  ),
  "print.summary.mfrm_resamples_01" = rbind(
    c(field = "stratum_summary", heading = "\nStratum summary\n", cast = "raw", rounded = "no", guard = "required"),
    c("preserve_summary", "\nPreserve-facet summary\n", "raw", "no", "required")
  ),
  "print.summary.mfrm_results_01" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.summary.mfrm_report_01" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.summary.mfrm_report_02" = rbind(
    c(field = "first_screen", heading = "\nFirst screen\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.summary.mfrm_report_03" = rbind(
    c(field = "immediate_actions", heading = "\nImmediate actions\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.summary.mfrm_report_04" = rbind(
    c(field = "report_gaps", heading = "\nReport gaps\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.summary.mfrm_structural_design_review_01" = rbind(
    c(field = "overview", heading = "\nOverview\n", cast = "frame", rounded = "yes", guard = "present")
  ),
  "print.summary.mfrm_structural_design_review_02" = rbind(
    c(field = "readiness_summary", heading = "\nReadiness summary\n", cast = "frame", rounded = "yes", guard = "present"),
    c("recommendation_table", "\nRecommendation table\n", "frame", "yes", "present")
  ),
  "print.summary.mfrm_structural_design_review_03" = rbind(
    c(field = "table_index", heading = "\nTable index\n", cast = "frame", rounded = "no", guard = "present"),
    c("plot_index", "\nPlot index\n", "frame", "no", "present"),
    c("table_catalog", "\nTable catalog\n", "frame", "yes", "present"),
    c("role_summary", "\nRole summary\n", "frame", "yes", "present"),
    c("table_profile", "\nTable profile\n", "frame", "yes", "present"),
    c("profile_summary", "\nProfile summary\n", "frame", "yes", "present"),
    c("load_balance_summary", "\nLoad/balance summary\n", "frame", "yes", "present"),
    c("coverage_summary", "\nCoverage summary\n", "frame", "yes", "present"),
    c("guardrail_summary", "\nGuardrail summary\n", "frame", "yes", "present"),
    c("readiness_summary", "\nReadiness summary\n", "frame", "yes", "present"),
    c("recommendation_table", "\nRecommendation table\n", "frame", "yes", "present"),
    c("appendix_presets", "\nAppendix presets\n", "frame", "yes", "present"),
    c("appendix_role_summary", "\nAppendix role summary\n", "frame", "yes", "present"),
    c("appendix_section_summary", "\nAppendix section summary\n", "frame", "yes", "present"),
    c("selection_summary", "\nSelection summary\n", "frame", "yes", "present"),
    c("selection_table_summary", "\nSelection table summary\n", "frame", "yes", "present"),
    c("selection_table_preset_summary", "\nSelection table preset summary\n", "frame", "yes", "present"),
    c("selection_handoff_table_summary", "\nSelection handoff table summary\n", "frame", "yes", "present"),
    c("selection_handoff_preset_summary", "\nSelection handoff preset summary\n", "frame", "yes", "present"),
    c("selection_handoff_summary", "\nSelection handoff summary\n", "frame", "yes", "present"),
    c("selection_handoff_bundle_summary", "\nSelection handoff bundle summary\n", "frame", "yes", "present"),
    c("selection_handoff_role_summary", "\nSelection handoff role summary\n", "frame", "yes", "present"),
    c("selection_handoff_role_section_summary", "\nSelection handoff role-section summary\n", "frame", "yes", "present"),
    c("selection_role_summary", "\nSelection role summary\n", "frame", "yes", "present"),
    c("selection_section_summary", "\nSelection section summary\n", "frame", "yes", "present"),
    c("reporting_map", "\nReporting map\n", "frame", "no", "present")
  ),
  "print.summary.mfrm_recovery_simulation_01" = rbind(
    c(field = "recovery_summary", heading = "\nRecovery summary\n", cast = "frame", rounded = "yes", guard = "present"),
    c("diagnostic_oc_summary", "\nDiagnostic operating-characteristic summary\n", "frame", "yes", "present"),
    c("sparse_review", "\nSparse linked design review\n", "frame", "yes", "present")
  ),
  "print.summary.mfrm_recovery_assessment_01" = rbind(
    c(field = "checklist", heading = "\nChecklist\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.summary.mfrm_diagnostic_screening_01" = rbind(
    c(field = "reading_order", heading = "\nReading order\n", cast = "frame", rounded = "no", guard = "present")
  ),
  "print.summary.mfrm_facets_run_01" = rbind(
    c(field = "mapping", heading = "\nColumn mapping\n", cast = "frame", rounded = "no", guard = "present")
  )
)

print_summary_sections <- function(x, sections, digits = 3L) {
  # Read each field where the original guard/print read it, retaining partial-match warnings.
  value <- function() do.call("$", list(x, field))
  for (i in seq_len(nrow(sections))) {
    field <- sections[i, "field"]
    guard <- sections[i, "guard"]
    available <- switch(guard,
      present = !is.null(value()) && nrow(value()) > 0L,
      fallback = nrow(value() %||% data.frame()) > 0L,
      required = nrow(value()) > 0L
    )
    if (available) {
      cat(sections[i, "heading"])
      table <- value()
      table <- switch(sections[i, "cast"],
        raw = table,
        frame = as.data.frame(table),
        frame_false = as.data.frame(table, stringsAsFactors = FALSE)
      )
      if (sections[i, "rounded"] == "yes") table <- round_numeric_df(table, digits = digits)
      print(table, row.names = FALSE)
    }
  }
  invisible(NULL)
}

