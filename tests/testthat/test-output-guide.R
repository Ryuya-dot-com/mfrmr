test_that("mfrmr_output_guide returns a stable purpose-to-helper map", {
  guide <- mfrmr_output_guide()

  expect_s3_class(guide, "data.frame")
  expect_true(all(c(
    "Scope",
    "Question",
    "OutputFamily",
    "Lifecycle",
    "UserLevel",
    "APILayer",
    "ObjectRole",
    "DecisionBoundary",
    "RecommendedEntry",
    "MainFunction",
    "UseWhen",
    "TypicalInput",
    "NextStep",
    "GPCMStatus",
    "Notes"
  ) %in% names(guide)))
  expect_true(nrow(guide) >= 10L)
  expect_true(any(grepl("mfrm_results", guide$MainFunction, fixed = TRUE)))
  expect_true(any(guide$RecommendedEntry))
  expect_true(any(guide$APILayer == "top_level_public_surface"))
  expect_true(any(guide$APILayer == "specialist_followup"))
  expect_true(any(guide$ObjectRole == "comprehensive result object"))
  expect_true(any(grepl("not a new estimator", guide$DecisionBoundary, fixed = TRUE)))
  expect_true(any(guide$Lifecycle == "advanced"))
  expect_true(any(guide$Lifecycle == "compatibility"))
  expect_true(any(grepl("precision_review_report", guide$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("build_summary_table_bundle", guide$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("facets_output_file_bundle", guide$MainFunction, fixed = TRUE)))
})

test_that("mfrmr_output_guide supports focused scopes", {
  public <- mfrmr_output_guide("public")
  expect_true(nrow(public) > 0L)
  expect_true(all(public$Scope == "public"))
  expect_true(all(public$RecommendedEntry))
  expect_true(all(public$UserLevel == "beginner"))
  expect_true(all(public$APILayer == "top_level_public_surface"))
  expect_true(any(public$ObjectRole == "model estimation and result-object entry"))
  expect_true(any(public$ObjectRole == "report-readiness surface"))
  expect_true(any(grepl("does not recompute diagnostics", public$DecisionBoundary, fixed = TRUE)))
  expect_true(any(grepl("mfrm_report", public$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("view = \"brief\"", public$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("view = \"reader\"", public$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("export_mfrm_results", public$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("preset = \"starter\"", public$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("launch_mfrmr_viewer", public$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("mfrmr_minimum_report_checklist", public$MainFunction, fixed = TRUE)))

  beginner <- mfrmr_output_guide("beginner")
  expect_true(nrow(beginner) > 0L)
  expect_true(all(beginner$Scope == "beginner"))
  expect_true(all(beginner$RecommendedEntry))
  expect_true(all(beginner$UserLevel == "beginner"))
  expect_true(all(beginner$APILayer == "recommended_entry_route"))
  expect_true(any(grepl("mfrmr_minimum_report_checklist", beginner$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("RSM/PCM route first", beginner$NextStep, fixed = TRUE)))
  expect_true(any(grepl("deliberately narrow", beginner$Notes, fixed = TRUE)))

  entry <- mfrmr_output_guide("entry")
  expect_true(nrow(entry) > 0L)
  expect_true(all(entry$Scope == "entry"))
  expect_true(any(grepl("mfrm_results", entry$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("fit_mfrm", entry$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("mfrm_results_interactive", entry$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("launch_mfrmr_viewer", entry$MainFunction, fixed = TRUE)))
  expect_true(all(entry$RecommendedEntry))
  expect_true(all(entry$UserLevel == "beginner"))

  binary <- mfrmr_output_guide("binary")
  expect_true(nrow(binary) > 0L)
  expect_true(all(binary$Scope == "binary"))
  expect_true(all(binary$RecommendedEntry))
  expect_true(all(binary$UserLevel == "beginner"))
  expect_true(any(grepl("fit_mfrm", binary$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("Categories is 2", binary$NextStep, fixed = TRUE)))
  expect_true(any(grepl("Rasch", binary$Notes, fixed = TRUE)))

  viewer <- mfrmr_output_guide("viewer")
  expect_true(nrow(viewer) > 0L)
  expect_true(all(viewer$Scope == "viewer"))
  expect_true(all(viewer$OutputFamily == "viewer"))
  expect_true(all(viewer$RecommendedEntry))
  expect_true(all(viewer$UserLevel == "beginner"))
  expect_true(any(grepl("launch_mfrmr_viewer", viewer$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("include = \"publication\"", viewer$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("include = \"bias\"", viewer$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("include = \"misfit_review\"", viewer$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("include = \"linking\"", viewer$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("bias_interaction_report", viewer$NextStep, fixed = TRUE)))
  expect_true(any(grepl("does not estimate", viewer$Notes, fixed = TRUE)))

  simulation <- mfrmr_output_guide("simulation")
  expect_true(nrow(simulation) > 0L)
  expect_true(all(simulation$Scope == "simulation"))
  expect_true(all(simulation$Lifecycle == "advanced"))
  expect_true(any(grepl("simulate_mfrm_data", simulation$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("evaluate_mfrm_diagnostic_screening", simulation$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("evaluate_mfrm_signal_detection", simulation$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("predict_mfrm_population", simulation$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("summary(sim_eval)$reading_order", simulation$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("summary(pred)$reading_order", simulation$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("export_summary_appendix", simulation$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("plot_overview_rate", simulation$NextStep, fixed = TRUE)))
  expect_true(any(grepl("BiasScreenRate", simulation$NextStep, fixed = TRUE)))
  expect_true(any(grepl("scenario-level aggregate forecast", simulation$Notes, fixed = TRUE)))
  expect_true(any(grepl("operating-characteristic", simulation$Notes, fixed = TRUE)))

  linking <- mfrmr_output_guide("linking")
  expect_true(nrow(linking) > 0L)
  expect_true(all(linking$Scope == "linking"))
  expect_true(any(grepl("mfrm_results(fit, include = \"linking\")", linking$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("anchor_linking_contract", linking$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("review_mfrm_anchors", linking$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("detect_anchor_drift", linking$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("build_equating_chain", linking$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("one fit", linking$Notes, fixed = TRUE)))

  network <- mfrmr_output_guide("network")
  expect_true(nrow(network) > 0L)
  expect_true(all(network$Scope == "network"))
  expect_true(all(network$Lifecycle == "advanced"))
  expect_true(any(grepl("build_mfrm_network_review", network$MainFunction, fixed = TRUE)))

  reviews <- mfrmr_output_guide("reviews")
  expect_true(nrow(reviews) > 0L)
  expect_true(all(reviews$Scope == "reviews"))
  expect_true(all(reviews$OutputFamily == "review"))
  expect_true(any(grepl("response_time_review", reviews$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("analyze_dif_mh", reviews$MainFunction,
                        fixed = TRUE)))
  expect_true(any(grepl("descriptive QC context",
                        reviews$DecisionBoundary,
                        fixed = TRUE)))
  expect_true(any(grepl("Bias, DFF, and DIF rows are screening prompts",
                        reviews$DecisionBoundary,
                        fixed = TRUE)))

  response_time <- mfrmr_output_guide("response_time")
  expect_true(nrow(response_time) >= 2L)
  expect_true(any(response_time$Scope == "reviews"))
  expect_true(any(response_time$Scope == "r"))
  expect_true(any(grepl("plot_response_time_review",
                        response_time$MainFunction,
                        fixed = TRUE)))
  expect_true(any(grepl("speed-accuracy",
                        response_time$DecisionBoundary,
                        fixed = TRUE)))
  expect_true(any(grepl("summary(res)$next_actions",
                        response_time$NextStep,
                        fixed = TRUE)))
  expect_true(any(grepl("do not alter MFRM estimates",
                        response_time$Notes,
                        fixed = TRUE)))
  expect_true(any(grepl("automatic exclusion rules",
                        response_time$DecisionBoundary,
                        fixed = TRUE)))

  reports <- mfrmr_output_guide("reports")
  expect_true(nrow(reports) > 0L)
  expect_true(all(reports$Scope == "reports"))
  expect_true(any(grepl("mfrm_report", reports$MainFunction, fixed = TRUE)))

  exports <- mfrmr_output_guide("exports")
  expect_true(nrow(exports) > 0L)
  expect_true(all(exports$Scope == "exports"))
  expect_true(any(grepl("export_mfrm_results", exports$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("preset = \"starter\"", exports$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("preset = \"archive\"", exports$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("export_summary_appendix", exports$MainFunction, fixed = TRUE)))

  gpcm <- mfrmr_output_guide("gpcm")
  expect_true(nrow(gpcm) > 0L)
  expect_false(any(gpcm$GPCMStatus == "supported"))
  expect_false(any(grepl("fit_bundle_blocked", gpcm$GPCMStatus, fixed = TRUE)))
  expect_false(any(grepl("rsm_pcm_only_for_strict_screening_currently", gpcm$GPCMStatus, fixed = TRUE)))
  expect_false(any(grepl("rsm_pcm_linking_route", gpcm$GPCMStatus, fixed = TRUE)))
  expect_true(any(
    grepl("evaluate_mfrm_diagnostic_screening", gpcm$MainFunction, fixed = TRUE) &
      gpcm$GPCMStatus == "supported_with_caveat"
  ))
  expect_true(any(
    grepl("detect_anchor_drift", gpcm$MainFunction, fixed = TRUE) &
      grepl("supported_with_caveat", gpcm$GPCMStatus, fixed = TRUE)
  ))
  expect_true(any(grepl("GPCM", gpcm$NextStep, ignore.case = TRUE)))
  expect_true(any(gpcm$Scope == "gpcm" &
                    grepl("gpcm_capability_matrix", gpcm$MainFunction, fixed = TRUE)))
  expect_true(any(gpcm$Scope == "gpcm" &
                    grepl("gpcm_runtime_guard_coverage", gpcm$MainFunction, fixed = TRUE)))
  expect_true(any(gpcm$ObjectRole == "out-of-scope route-status table"))
  expect_true(any(grepl("does not broaden any route beyond its current capability row",
                        gpcm$DecisionBoundary,
                        fixed = TRUE)))

  psychometric <- mfrmr_output_guide("psychometric")
  expect_true(nrow(psychometric) > 0L)
  expect_true(all(psychometric$Scope == "psychometric"))
  expect_true(all(psychometric$UserLevel == "advanced"))
  expect_true(all(psychometric$APILayer == "specialist_followup"))
  expect_false(any(psychometric$RecommendedEntry))
  expect_true(any(grepl("mfrmr_minimum_report_checklist", psychometric$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("mfrm_analysis_audit", psychometric$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("mfrm_generalizability", psychometric$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("mfrm_d_study", psychometric$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("facets_term_crosswalk", psychometric$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("do not certify validity", psychometric$DecisionBoundary, fixed = TRUE)))
})

test_that("mfrmr_minimum_report_checklist exposes reviewer-facing report gaps", {
  checklist <- mfrmr_minimum_report_checklist()

  expect_s3_class(checklist, "data.frame")
  expect_true(all(c(
    "Scope",
    "Section",
    "ReportItem",
    "Required",
    "PrimaryQuestion",
    "mfrmrRoute",
    "ReportUse",
    "ReviewerRisk",
    "Boundary"
  ) %in% names(checklist)))
  expect_true(nrow(checklist) >= 15L)
  expect_true(any(checklist$Scope == "validity" &
                    grepl("content", checklist$Boundary, fixed = TRUE)))
  expect_true(any(checklist$Scope == "generalizability" &
                    grepl("mfrm_generalizability", checklist$mfrmrRoute, fixed = TRUE)))
  expect_true(any(checklist$Scope == "generalizability" &
                    grepl("fitted-logit", checklist$ReviewerRisk, fixed = TRUE)))
  expect_true(any(checklist$Scope == "fairness" &
                    grepl("DFF/DIF", checklist$ReportItem, fixed = TRUE)))
  expect_true(any(checklist$Scope == "external" &
                    grepl("facets_term_crosswalk", checklist$mfrmrRoute, fixed = TRUE)))
  expect_true(any(checklist$Scope == "visuals" &
                    grepl("visual_reporting_template", checklist$mfrmrRoute, fixed = TRUE)))

  fairness <- mfrmr_minimum_report_checklist("fairness")
  expect_true(nrow(fairness) > 0L)
  expect_true(all(fairness$Scope == "fairness"))

  generalizability <- mfrmr_minimum_report_checklist("generalizability")
  expect_true(nrow(generalizability) > 0L)
  expect_true(all(generalizability$Scope == "generalizability"))

  validity <- mfrmr_minimum_report_checklist("validity")
  expect_true(nrow(validity) > 0L)
  expect_true(all(validity$Scope == "validity"))
})

test_that("facets_feature_coverage separates implemented and unsupported FACETS surfaces", {
  coverage <- facets_feature_coverage()

  expect_s3_class(coverage, "data.frame")
  expect_true(all(c(
    "FACETSArea",
    "FACETSFeature",
    "FACETSReference",
    "mfrmrRoute",
    "Status",
    "Scope",
    "GapOrBoundary",
    "Priority"
  ) %in% names(coverage)))
  expect_true(nrow(coverage) >= 60L)
  expect_true(any(grepl("Table 14", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "implemented"))
  expect_true(any(grepl("Wright map", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "implemented"))
  expect_true(any(grepl("Generalizability Theory", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "implemented" &
                    grepl("mfrm_d_study", coverage$mfrmrRoute, fixed = TRUE)))
  expect_true(any(grepl("Connectivity network graph", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "implemented" &
                    grepl("mfrm_network_analysis", coverage$mfrmrRoute, fixed = TRUE) &
                    grepl("type = \"network\"", coverage$mfrmrRoute, fixed = TRUE)))
  expect_true(any(grepl("Residuals output file", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "implemented" &
                    grepl("write_mfrm_residual_file", coverage$mfrmrRoute, fixed = TRUE)))
  expect_true(any(grepl("Category information function", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "implemented" &
                    grepl("category_information", coverage$mfrmrRoute, fixed = TRUE)))
  expect_true(any(grepl("Cumulative probability curves", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "implemented" &
                    grepl("type = \"cumulative\"", coverage$mfrmrRoute, fixed = TRUE)))
  expect_true(any(grepl("Winsteps", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "not_implemented"))
  expect_true(any(grepl("command-file parser", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "not_targeted"))
  expect_true(any(grepl("Multiple simultaneous Model=", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "not_implemented"))
  expect_true(any(grepl("Binomial/Bernoulli and Poisson", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "not_implemented"))
  expect_true(any(grepl("Model-statement weights", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "partial" &
                    grepl("weight_col", coverage$mfrmrRoute, fixed = TRUE)))
  expect_true(any(grepl("Named rating-scale blocks", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "partial" &
                    grepl("step_facet = \"Rater\"", coverage$mfrmrRoute, fixed = TRUE)))
  expect_true(any(grepl("category recoding", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "partial" &
                    grepl("score_map", coverage$mfrmrRoute, fixed = TRUE)))
  expect_true(any(grepl("Anchorfile=", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "partial" &
                    grepl("complete FACETS specification", coverage$GapOrBoundary, fixed = TRUE)))
  expect_true(any(grepl("output-dialog", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "not_targeted"))
  expect_true(any(grepl("Table 5", coverage$FACETSFeature, fixed = TRUE) &
                    coverage$Status == "partial" &
                    grepl("package-native approximations", coverage$GapOrBoundary, fixed = TRUE)))

  partial <- facets_feature_coverage("partial")
  expect_true(nrow(partial) > 0L)
  expect_true(all(partial$Status == "partial"))

  missing <- facets_feature_coverage("not_implemented")
  expect_true(nrow(missing) > 0L)
  expect_true(all(missing$Status == "not_implemented"))
})

test_that("facets_visual_contract maps FACETS graph surfaces to mfrmr routes", {
  visual <- facets_visual_contract()

  expect_s3_class(visual, "data.frame")
  expect_true(all(c(
    "Scope",
    "FACETSVisualSurface",
    "FACETSReference",
    "mfrmrRoute",
    "Status",
    "ReaderUse",
    "PlotDataRoute",
    "Boundary",
    "FACETSExpectation",
    "FirstMfrmrRoute",
    "EditableDataRoute",
    "GgplotRoute",
    "ReportUse",
    "MigrationNote",
    "ClaimBoundary"
  ) %in% names(visual)))
  expect_true(nrow(visual) >= 14L)
  expect_true(all(c("output_table", "graph_menu", "output_file", "rweb") %in%
                    unique(visual$Scope)))
  expect_true(any(visual$Scope == "output_table" &
                    grepl("line-printer", visual$FACETSExpectation, fixed = TRUE)))
  expect_true(any(visual$Status == "implemented" &
                    grepl("FirstMfrmrRoute", visual$MigrationNote, fixed = TRUE)))
  expect_true(any(grepl("as_ggplot", visual$GgplotRoute, fixed = TRUE)))
  expect_true(any(grepl("Table 6.0", visual$FACETSVisualSurface, fixed = TRUE) &
                    visual$Status == "implemented" &
                    grepl("plot_wright_unified", visual$mfrmrRoute, fixed = TRUE) &
                    visual$FirstMfrmrRoute == "plot(fit, type = \"wright\")"))
  expect_true(any(grepl("Table 8 scale-structure probability curves",
                        visual$FACETSVisualSurface, fixed = TRUE) &
                    visual$Status == "implemented" &
                    grepl("category_curves_report", visual$mfrmrRoute, fixed = TRUE) &
                    grepl("plot_data", visual$EditableDataRoute, fixed = TRUE)))
  expect_true(any(grepl("Category probability curves",
                        visual$FACETSVisualSurface, fixed = TRUE) &
                    visual$Status == "implemented" &
                    grepl("type = \"ccc\"", visual$mfrmrRoute, fixed = TRUE)))
  expect_true(any(grepl("Graph plotting file", visual$FACETSVisualSurface, fixed = TRUE) &
                    visual$Status == "implemented" &
                    grepl("facets_output_file_bundle", visual$mfrmrRoute, fixed = TRUE)))
  expect_true(any(grepl("DIF/bias Excel plot", visual$FACETSVisualSurface, fixed = TRUE) &
                    visual$Status == "partial" &
                    grepl("Excel workbook", visual$ClaimBoundary, fixed = TRUE) &
                    grepl("caption", visual$MigrationNote, fixed = TRUE)))
  expect_true(any(grepl("Conditional probability curves",
                        visual$FACETSVisualSurface, fixed = TRUE) &
                    visual$Status == "partial" &
                    grepl("conditional", visual$PlotDataRoute, fixed = TRUE)))
  expect_true(any(grepl("clickable Webpage", visual$FACETSVisualSurface, fixed = TRUE) &
                    visual$Status == "not_targeted" &
                    visual$GgplotRoute == "not_available"))

  graphs <- facets_visual_contract("graph_menu")
  expect_true(nrow(graphs) > 0L)
  expect_true(all(graphs$Scope == "graph_menu"))

  partial <- facets_visual_contract("partial")
  expect_true(nrow(partial) > 0L)
  expect_true(all(partial$Status == "partial"))
})

test_that("facets_positioning_guide prevents FACETS numerical-clone wording", {
  guide <- facets_positioning_guide()

  expect_s3_class(guide, "data.frame")
  expect_true(all(c(
    "Topic",
    "Position",
    "RecommendedWording",
    "PrimaryRoute"
  ) %in% names(guide)))
  expect_true(any(guide$Topic == "Estimation authority"))
  expect_true(any(guide$Topic == "External FACETS comparison"))
  expect_true(any(grepl("package-native", guide$Position, fixed = TRUE)))
  expect_true(any(grepl("not evidence of FACETS numerical equivalence",
                        guide$RecommendedWording,
                        fixed = TRUE)))
  expect_true(any(grepl("read_facets_fit_table", guide$PrimaryRoute, fixed = TRUE)))
  expect_false(any(grepl("\\baudit\\b", unlist(guide), ignore.case = TRUE)))
})

test_that("facets_term_crosswalk maps FACETS vocabulary without equivalence claims", {
  crosswalk <- facets_term_crosswalk()

  expect_s3_class(crosswalk, "data.frame")
  expect_true(all(c(
    "Scope",
    "FACETSTerm",
    "FACETSSurface",
    "mfrmrTerm",
    "mfrmrRoute",
    "Relationship",
    "ReviewerNote",
    "Boundary"
  ) %in% names(crosswalk)))
  expect_true(nrow(crosswalk) >= 20L)
  expect_true(any(crosswalk$FACETSTerm == "Measure" &
                    crosswalk$Relationship == "same_concept"))
  expect_true(any(crosswalk$FACETSTerm == "ZStd / ZSTD" &
                    grepl("facets_fit_df_guide", crosswalk$mfrmrRoute, fixed = TRUE)))
  expect_true(any(grepl("Rating Scale= Specific", crosswalk$FACETSTerm, fixed = TRUE) &
                    grepl("step_facet = \"Rater\"", crosswalk$mfrmrRoute, fixed = TRUE)))
  expect_true(any(crosswalk$FACETSTerm == "Graphfile" &
                    grepl("not the FACETS graph window", crosswalk$Boundary, fixed = TRUE)))
  expect_true(any(crosswalk$FACETSTerm == "Full FACETS command file" &
                    crosswalk$Relationship == "scope_boundary"))
  expect_false(any(grepl("numerical equivalence", crosswalk$Boundary, fixed = TRUE)))

  fit_terms <- facets_term_crosswalk("fit")
  expect_true(nrow(fit_terms) > 0L)
  expect_true(all(fit_terms$Scope == "fit"))

  visuals <- facets_term_crosswalk("visuals")
  expect_true(nrow(visuals) > 0L)
  expect_true(all(visuals$Scope == "visuals"))
})

test_that("mfrmr_output_guide gives FACETS, ConQuest, and R user pathways", {
  facets <- mfrmr_output_guide("facets")
  expect_true(nrow(facets) >= 10L)
  expect_true(all(facets$Scope == "facets"))
  expect_true(any(grepl("facets_positioning_guide", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("not a FACETS numerical clone", facets$Notes, fixed = TRUE)))
  expect_true(any(grepl("facets_term_crosswalk", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("terminology guide", facets$Notes, fixed = TRUE)))
  expect_true(any(grepl("facets_feature_coverage", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("facets_visual_contract", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("review_mfrm_anchors", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("make_anchor_table", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("anchor_linking_contract", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("group_anchors", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("detect_anchor_drift", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("plot_anchor_drift", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("fit_measures_table", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("facets_fit_df_guide", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("df_sensitivity", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("df_sensitive", facets$NextStep, fixed = TRUE)))
  expect_true(any(grepl("rating_scale_table", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("fair_average_table", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("estimate_bias", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("bias_interaction_report", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("bias_pairwise_report", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("plot_bias_interaction", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("plot_wright_unified", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("type = \"wright\"", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("data_quality_report", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("write_mfrm_residual_file", facets$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("write_mfrm_subset_file", facets$MainFunction, fixed = TRUE)))

  conquest <- mfrmr_output_guide("conquest")
  expect_true(nrow(conquest) >= 3L)
  expect_true(all(conquest$Scope == "conquest"))
  expect_true(any(grepl("build_conquest_overlap_bundle", conquest$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("review_conquest_overlap", conquest$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("less free than ConQuest", conquest$Question, fixed = TRUE)))

  r_path <- mfrmr_output_guide("r")
  expect_true(nrow(r_path) >= 3L)
  expect_true(all(r_path$Scope == "r"))
  expect_true(any(grepl("plot_data", r_path$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("plot_data_components", r_path$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("mfrmr_interval_guide", r_path$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("plot_long", r_path$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("type = \"pathway\"", r_path$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("plot_bias_interaction", r_path$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("plot_information", r_path$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("plot_response_time_review", r_path$MainFunction, fixed = TRUE)))
  expect_true(any(grepl("plot_data_components", r_path$NextStep, fixed = TRUE)))
  expect_true(any(grepl("mfrmr_interval_guide", r_path$NextStep, fixed = TRUE)))
  expect_true(any(grepl("pathway_long", r_path$NextStep, fixed = TRUE)))
  expect_true(any(grepl("annotations/settings", r_path$NextStep, fixed = TRUE)))
  expect_true(any(grepl("table, thresholds, overview, and notes",
                        r_path$NextStep,
                        fixed = TRUE)))
  expect_true(any(grepl("ggplot2", r_path$UseWhen, fixed = TRUE)))
})

test_that("plot_data extracts reusable payloads and selected components", {
  fit <- make_toy_fit(maxit = 8)
  dq <- data_quality_report(fit)

  dashboard_payload <- plot_data(dq, type = "dashboard")
  expect_true(is.list(dashboard_payload))
  expect_true(all(c(
    "quality_flags",
    "score_support",
    "facet_response_patterns"
  ) %in% names(dashboard_payload)))

  flags <- plot_data(dq, type = "dashboard", component = "quality_flags")
  expect_s3_class(flags, "data.frame")
  dashboard_components <- plot_data_components(dq, type = "dashboard")
  expect_s3_class(dashboard_components, "data.frame")
  expect_true(all(c(
    "PlotName", "Component", "Role", "ObjectType", "Rows",
    "Columns", "Accessor", "Notes"
  ) %in% names(dashboard_components)))
  expect_true(any(dashboard_components$Component == "quality_flags"))

  plotted <- plot(dq, type = "dashboard", draw = FALSE)
  expect_s3_class(plotted, "mfrm_plot_data")
  score_support <- plot_data(plotted, component = "score_support")
  expect_s3_class(score_support, "data.frame")
  plotted_components <- plot_data_components(plotted)
  expect_true(any(plotted_components$Component == "score_support"))
  expect_error(plot_data(plotted, component = "not_a_component"), "component")

  curves <- category_curves_report(fit, theta_points = 21)
  cumulative_payload <- plot_data(curves, type = "cumulative")
  expect_true(all(c(
    "cumulative_probabilities",
    "cumulative_boundaries",
    "cumulative_direction"
  ) %in% names(cumulative_payload)))
  cumulative_table <- plot_data(curves, type = "cumulative", component = "cumulative_probabilities")
  expect_s3_class(cumulative_table, "data.frame")
  category_probability_payload <- plot_data(curves, type = "category_probability")
  expect_identical(category_probability_payload$plot, "ccc")
  expect_identical(category_probability_payload$plot_settings$RequestedType[1], "category_probability")
  expect_true(any(category_probability_payload$plot_long$PlotType == "ccc" &
                    category_probability_payload$plot_long$DisplayedByDefault))
  expect_true(all(c("plot_annotations", "curve_summary") %in%
                    names(category_probability_payload)))
  category_probability_components <- plot_data_components(curves, type = "category_probability")
  expect_true(any(category_probability_components$Component == "plot_long" &
                    category_probability_components$Role == "primary_data"))
  expect_true(any(category_probability_components$Component == "plot_annotations" &
                    category_probability_components$Role == "annotation"))
  category_information <- plot_data(
    curves,
    type = "category_information",
    component = "category_information"
  )
  expect_s3_class(category_information, "data.frame")
  expect_true(all(c("CategoryInformation", "CategoryInformationShare") %in% names(category_information)))

  curve_long <- plot_data(curves, component = "plot_long")
  expect_s3_class(curve_long, "data.frame")
  expect_true(all(c(
    "PlotType", "Panel", "CurveGroup", "Theta", "Series",
    "ValueName", "Value", "DisplayedByDefault"
  ) %in% names(curve_long)))
  expect_true(all(c(
    "ogive", "ccc", "cumulative", "information", "category_information"
  ) %in% unique(curve_long$PlotType)))
  expect_true(any(curve_long$PlotType == "cumulative" &
                    curve_long$Direction == "at_or_below" &
                    curve_long$DisplayedByDefault))
  curve_style <- plot_data(curves, preset = "monochrome", component = "curve_style")
  expect_s3_class(curve_style, "data.frame")
  expect_true(all(c("Series", "Colour", "LineType", "Preset") %in% names(curve_style)))
  expect_true(all(curve_style$Preset == "monochrome"))
  expect_gt(length(unique(curve_style$LineType)), 1L)

  diag <- diagnose_mfrm(fit, residual_pca = "none")
  pathway_long <- plot_data(
    fit,
    type = "pathway",
    diagnostics = diag,
    component = "pathway_long"
  )
  expect_s3_class(pathway_long, "data.frame")
  expect_true(all(c("Layer", "CurveGroup", "Theta", "Value") %in% names(pathway_long)))
  expect_true(any(pathway_long$Layer == "expected_score"))

  pathway_fit <- plot_data(
    fit,
    type = "pathway",
    diagnostics = diag,
    component = "fit_measures"
  )
  expect_s3_class(pathway_fit, "data.frame")
  expect_true(all(c("Facet", "Level", "Infit", "Outfit", "FitStatus") %in% names(pathway_fit)))
  pathway_components <- plot_data_components(fit, type = "pathway", diagnostics = diag)
  expect_true(any(pathway_components$Component == "pathway_long" &
                    pathway_components$Role == "primary_data"))
  expect_true(any(pathway_components$Component == "fit_measures" &
                    pathway_components$Role == "fit_review"))

  pathway_without_fit <- plot_data(
    fit,
    type = "pathway",
    include_fit_measures = FALSE,
    component = "fit_measure_status"
  )
  expect_s3_class(pathway_without_fit, "data.frame")
  expect_false(isTRUE(pathway_without_fit$Available[1]))
  expect_identical(pathway_without_fit$Status[1], "not_requested")

  info <- compute_information(fit, theta_points = 21)
  sem_long <- plot_data(
    plot_information(info, type = "sem", draw = FALSE),
    component = "plot_long"
  )
  expect_s3_class(sem_long, "data.frame")
  expect_true(any(sem_long$ValueName == "ConditionalSEM"))
  sem_components <- plot_data_components(plot_information(info, type = "sem", draw = FALSE))
  expect_true(any(sem_components$Component == "conditional_sem"))

  bias <- suppressWarnings(suppressMessages(
    estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 1)
  ))
  bias_long <- plot_data(
    plot_bias_interaction(bias, plot = "heatmap", draw = FALSE),
    component = "plot_long"
  )
  expect_s3_class(bias_long, "data.frame")
  expect_true(any(bias_long$Layer == "heatmap_cell"))
  bias_components <- plot_data_components(
    plot_bias_interaction(bias, plot = "heatmap", draw = FALSE)
  )
  expect_true(any(bias_components$Component == "flag_summary" &
                    bias_components$Role == "summary_or_guidance"))
})
