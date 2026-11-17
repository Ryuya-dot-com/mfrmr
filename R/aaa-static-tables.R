# Literal report/guide tables are constructed once at package installation.
# Callers receive ordinary R values: modifying a returned table cannot change
# the namespace value (copy-on-modify). Keep these definitions data-only.
# Edit the definitions here when changing guide/report content.

# From api-calibration.R:21
.mfrmr_table_mfrm_calibration_capabilities_data <- data.frame(
    Model = c(
      "RSM", "PCM", "RSM/PCM", "GPCM", "RSM/PCM", "GPCM", "GPCM", "GPCM (two families)"
    ),
    Estimator = c("MML", "MML", "MML", "MML", "JML", "JML", "Corrected JML", "MML"),
    ScoringBasis = c(
      "fixed standard normal", "fixed standard normal",
      "estimated population or latent regression",
      "frozen estimated intercept-only normal", "post-hoc standard normal reference",
      "post-hoc standard normal reference", "post-hoc standard normal reference", "fixed standard normal"
    ),
    PortableCalibration = c(
      "available", "available", "unavailable", "available", "available", "available", "available", "available"
    ),
    AnchorSupport = c(
      "stored direct and group facet anchors",
      "stored direct and group facet anchors",
      "not available for portable calibration", "not supported",
      "not supported", "not supported", "not supported", "not supported"
    ),
    InteractionSupport = c(
      "stored two-way facet interactions",
      "stored two-way facet interactions",
      "not available for portable calibration", "not supported",
      "not supported", "not supported", "not supported", "not supported"
    ),
    ExistingAlternative = c(
      "portable artifact or fitted-object scoring",
      "portable artifact or fitted-object scoring",
      "use fitted-object scoring with the fitted population model",
      "conditional portable artifact or fitted-object GPCM scoring",
      "portable artifact or fitted-object post-hoc EAP; not ML/WLE",
      "conditional portable artifact or fitted-object post-hoc EAP; not ML/WLE",
      "experimental corrected calibration with post-hoc EAP; not corrected Person ML/WLE",
      "experimental two-family conditional artifact or fitted-object EAP"
    ),
    Limitation = c(
      paste(
        "one observed score scale, one latent dimension, known facet levels,",
        "and an explicit same-data quadrature review"
      ),
      paste(
        "one observed score scale, one latent dimension, known facet levels,",
        "and an explicit same-data quadrature review"
      ),
      "population coding and conditional parameters are not stored in the artifact",
      "passing conditional source checks; known levels, unit weights, no anchors, interactions or latent regression",
      "finite identified RSM/PCM JML source; unit weights, no anchors or interactions; reference prior is not estimated by JML",
      "shared owners, unit weights, no anchors/interactions; passing local JML checks; incomplete global audits remain recorded",
      "shared owners; explicit correction order; passing adjusted-equation/root checks; residual calibration bias may remain; no calibration uncertainty propagated",
      "two slope owners, declared step/location roles and GM1 reference (format 7 for extended roles), fixed N(0,1), known levels, unit weights and passing source/batch checks; no prior override or repeated-event extension; calibration uncertainty and population transport are not qualified"
    ),
    stringsAsFactors = FALSE
  )
# From api-export-bundles.R:5226
.mfrmr_table_export_mfrm_bundle_privacy_notice <- data.frame(
    PrivacyClass = "analysis_archive",
    Deidentified = FALSE,
    ShareableWithoutReview = FALSE,
    Notice = paste0(
      "This fit-level bundle is an analysis archive, not a deidentified or ",
      "automatically shareable package. It can contain direct person identifiers, ",
      "person-level estimates, original labels, replay data, and local paths. ",
      "Review and transform every file under the applicable data-handling policy ",
      "before sharing it."
    ),
    stringsAsFactors = FALSE
  )
# From api-plotting-anchor-qc.R:244
.mfrmr_table_.equating_graph_data_notes <- data.frame(Type = c("definition", "interpretation", "screening"), Text = c(
    "Edges show common elements in the recorded comparisons, not an all-pairs assessment or an inventory of fixed anchors. Element nodes are repeated per link; AnchorId identifies the same facet/level across links.",
    "Connectedness and retention do not establish anchor invariance, model identification, scale comparability, or precision. Review drift, link support and source-fit readiness separately.",
    "Retained is the screening set, not a guarantee of positive weight in the offset. Flag is a separate residual-drift check; counts and edge widths do not represent precision."
  ), stringsAsFactors = FALSE)
# From api-plotting-anchor-qc.R:447
.mfrmr_table_.equating_offset_sensitivity_data <- data.frame(Type = c("definition", "interpretation", "screening", "uncertainty"), Text = c(
      "Each scenario removes one common facet/level identity from all adjacent links, then recomputes preliminary offsets, screening, final offsets and cumulative offsets using the recorded threshold and fixed source estimates/SEs.",
      "Changes are conditional linking-offset changes, not refitted item, rater or person measures. Missing link offsets propagate to later cumulative offsets. The first wave is a fixed zero reference and is excluded from maximum cumulative changes.",
      "Screening can re-admit other elements. If it would exclude every finite difference, the existing method falls back to all finite differences; ScreeningFallback reports this. Retained elements with unusable SEs may not contribute when inverse-variance weighting is active. Support includes facets whose last element was removed.",
      "No source model is refitted and no new SE, covariance or confidence interval is estimated. Finite offsets, small changes and retained connections do not establish anchor invariance, adequate support, comparable scales or inferential readiness."
    ), stringsAsFactors = FALSE)
# From api-plotting-fit-family.R:2828
.mfrmr_table_build_ccc_surface_data_reporting_policy <- data.frame(
    UseCase = c(
      "Manuscript core figure",
      "Appendix or teaching figure",
      "Interactive downstream rendering",
      "FACETS/ConQuest/SPSS comparison"
    ),
    Recommendation = c(
      "Prefer plot(fit, type = \"pathway\") or plot(fit, type = \"ccc\").",
      "Acceptable when explicitly described as exploratory category-probability support.",
      "Use surface, categories, groups, axis_contract, renderer_contract, and category_support as the renderer input contract.",
      "Do not present the surface as a direct FACETS, ConQuest, or SPSS-equivalent display."
    ),
    stringsAsFactors = FALSE
  )
# From api-reporting-checklist.R:1036
.mfrmr_table_reporting_checklist_data <- data.frame(
      Citation = c(
        "American Psychological Association (2020)",
        "Appelbaum et al. (2018)",
        "Eckes (2005)",
        "Koizumi et al. (2019)",
        "Muraki (1992, 1993)",
        "Myford & Wolfe (2003, 2004)",
        "Linacre (1989, 2002)",
        "Wright & Masters (1982)"
      ),
      Topic = c(
        "APA 7 manuscript and statistical-reporting conventions",
        "APA JARS-Quant reporting framework",
        "Rater effects in MFRM",
        "Validity / MFRM task reporting",
        "Generalized partial-credit model and information functions",
        "Bias and interaction analysis",
        "MFRM and rating scale guidance",
        "Rating scale analysis"
      ),
      stringsAsFactors = FALSE
    )
# From api-reports.R:198
.mfrmr_table_facets_fit_df_guide_formula_guide <- data.frame(
    Quantity = c(
      "Engine infit df",
      "Engine outfit df",
      "FACETS-style df",
      "Wilson-Hilferty ZSTD",
      "FACETS WHEXACT=NO",
      "Legacy linear approximation"
    ),
    Formula = c(
      "sum(Var * Weight)",
      "sum(Weight)",
      "2 / q^2, implemented as 2 * numerator^2 / fourth-moment denominator",
      "(MnSq^(1/3) - (1 - 2 / (9 * df))) / sqrt(2 / (9 * df))",
      "3 * (MnSq^(1/3) - 1) / sqrt(2/df)",
      "(MnSq - 1) * sqrt(df / 2)"
    ),
    MfrmrColumns = c(
      "DF_Infit or DF_Infit_ENGINE",
      "DF_Outfit or DF_Outfit_ENGINE",
      "DF_Infit_FACETS / DF_Outfit_FACETS",
      "InfitZSTD / OutfitZSTD, or *_FACETS companion columns",
      "Used when whexact = TRUE",
      "Used when whexact = legacy_linear"
    ),
    Use = c(
      "Package-native standardization and ordinary diagnostics.",
      "Package-native standardization and ordinary diagnostics.",
      "FACETS comparison layer; affects ZSTD but not MnSq.",
      "Default ZSTD transformation used for fit-review output.",
      "Cube-root transform without the additive q/3 term.",
      "Explicit reproduction of the former logical TRUE calculation."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:234
.mfrmr_table_facets_fit_df_guide_column_guide <- data.frame(
    Route = c(
      "diagnose_mfrm(fit_df_method = \"engine\")",
      "diagnose_mfrm(fit_df_method = \"facets\")",
      "diagnose_mfrm(fit_df_method = \"both\")",
      "fit_measures_table(fit_df_method = \"both\")",
      "facets_fit_review()"
    ),
    PrimaryColumns = c(
      "DF_Infit, DF_Outfit, InfitZSTD, OutfitZSTD use engine df.",
      "DF_Infit, DF_Outfit, InfitZSTD, OutfitZSTD use FACETS-style df.",
      "DF_Infit, DF_Outfit, InfitZSTD, OutfitZSTD use engine df.",
      "FACETS-style table keeps primary df and companion FACETS df/ZSTD columns.",
      "Within-mfrmr comparison places engine and FACETS-style df/ZSTD side by side."
    ),
    CompanionColumns = c(
      "No FACETS companion columns are retained.",
      "Engine companion columns are retained where available.",
      "DF_*_ENGINE, DF_*_FACETS, *ZSTD_ENGINE, and *ZSTD_FACETS are retained.",
      "FACETS Infit df, FACETS Outfit df, FACETS Infit ZStd, FACETS Outfit ZStd.",
      "DFRatio, ZSTDDiff, and FlagChangedByDf columns."
    ),
    UseWhen = c(
      "Routine package-native diagnostics.",
      "You want the primary ZSTD columns to mimic the FACETS-style df convention.",
      "You need to explain why ZSTD flags change under a different df convention.",
      "You want a FACETS-readable table while preserving R-friendly columns.",
      "You are comparing imported FACETS output or preparing a methods note."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:266
.mfrmr_table_facets_fit_df_guide_decision_guide <- data.frame(
    Step = seq_len(5L),
    Question = c(
      "Are MnSq values close?",
      "Are df values close under the same convention?",
      "Do ZSTD values differ after MnSq and df agree?",
      "Does |ZSTD| > 2 status change only after changing df convention?",
      "Is an external FACETS table supplied?"
    ),
    RecommendedAction = c(
      "If MnSq differs materially, treat this as a fit-statistic or estimation difference before discussing ZSTD.",
      "If df differs, classify the ZSTD gap as a df-convention issue unless MnSq also differs.",
      "Check WHEXACT/normalization settings and rounding/truncation before making a substantive claim.",
      "Report the flag as convention-sensitive; inspect MnSq and substantive context before acting on it.",
      "Use read_facets_results(), then pass it to facets_fit_review()."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:285
.mfrmr_table_facets_fit_df_guide_interpretation_guide <- data.frame(
    Pattern = c(
      "MnSq same, df different, ZSTD different",
      "MnSq different",
      "MnSq different and the mfrmr fit used method = \"MML\"",
      "Small df with counterintuitive ZSTD sign",
      "mfrmr ZSTD is NA but the external table reports a value",
      "FACETS-style flag but engine flag absent",
      "Engine flag but FACETS-style flag absent"
    ),
    Interpretation = c(
      "Usually a standardization-convention difference, not a different residual fit signal.",
      "Potential estimation, weighting, missing-data, or table-matching difference.",
      "MML residuals are evaluated at shrunken EAP person measures, while FACETS uses JMLE estimates; the residual basis itself differs, most visibly for extreme-scoring persons.",
      "Known small-df behavior of Wilson-Hilferty-style standardization; prioritize MnSq and context.",
      "Both conventions withhold ZSTD when df < 1; the FACETS-style route caps available values at +/-9. Native scopes with infinite-primary JML proxies also withhold ZSTD. Check FitReason and unavailable inputs.",
      "The FACETS-style df makes the same MnSq more statistically extreme.",
      "The engine df makes the same MnSq more statistically extreme."
    ),
    ReportingAction = c(
      "State the df convention and compare MnSq separately from ZSTD.",
      "Do not explain the difference as only a df issue until MnSq matching is resolved.",
      "Refit with method = \"JML\" before attributing the gap to fit computation; report the residual basis in methods notes.",
      "Avoid strong claims from ZSTD alone; show MnSq and df together.",
      "Treat as a small-df availability difference, not a fit difference; compare MnSq for that row instead.",
      "Label as convention-sensitive and review the actual MnSq band.",
      "Label as convention-sensitive and review the actual MnSq band."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:317
.mfrmr_table_facets_fit_df_guide_data <- data.frame(
      Source = c(
        "Winsteps WHEXACT documentation",
        "FACETS Diagnosing Misfit documentation",
        "Facets Tutorial 2",
        "Wright & Masters (1982)"
      ),
      Supports = c(
        "Wilson-Hilferty/WHEXACT normalization and small-df caveats.",
        "Separating MnSq size from ZSTD significance-style interpretation.",
        "Mean-square as chi-square divided by df; ZStd as Wilson-Hilferty standardization.",
        "Rasch rating-scale fit-statistic interpretation used by FACETS-style reporting."
      ),
      URL = c(
        "https://www.winsteps.com/winman/whexact.htm",
        "https://winsteps.com/facetman/diagnosingmisfit.htm",
        "https://www.winsteps.com/a/ftutorial2.pdf",
        NA_character_
      ),
      stringsAsFactors = FALSE
    )
# From api-reports.R:370
.mfrmr_table_fit_measure_threshold_profile_table_literature <- data.frame(
    Profile = c(
      "linacre_productive",
      "wright_linacre_high_stakes_mcq",
      "wright_linacre_routine_mcq",
      "wright_linacre_rating_scale",
      "wright_linacre_clinical_observation",
      "wright_linacre_judged_performance"
    ),
    ProfileLabel = c(
      "Productive measurement",
      "High-stakes multiple-choice",
      "Routine multiple-choice",
      "Rating-scale surveys",
      "Clinical observation",
      "Judged performance"
    ),
    Lower = c(0.5, 0.8, 0.7, 0.6, 0.5, 0.4),
    Upper = c(1.5, 1.2, 1.3, 1.4, 1.7, 1.2),
    Source = c(
      "Linacre (2002); Bond & Fox (2015)",
      rep("Wright & Linacre (1994)", 5)
    ),
    SuggestedUse = c(
      "Broad screening band for productive measurement",
      "High-stakes selected-response tests",
      "Routine selected-response tests",
      "Rating-scale surveys and questionnaires",
      "Clinical observation ratings",
      "Judged performance ratings"
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:2142
.mfrmr_table_peer_review_reporting_map_data <- data.frame(
    Area = c(
      "Peer-review assignment",
      "Reviewer load",
      "Common-submission links",
      "Reciprocal review pairs",
      "MFRM measurement model"
    ),
    PrimaryTable = c(
      "overview",
      "load_summary; reviewer_load; submission_load",
      "reviewer_pair_common_submissions; low_common_pairs",
      "reciprocal_pairs",
      "fit_mfrm(); diagnose_mfrm()"
    ),
    Use = c(
      "Check self-review exclusion, design density, anchor counts, and front-door assignment status.",
      "Inspect whether submissions and reviewers received the intended assignment load.",
      "Inspect reviewer linkage through shared reviewed submissions.",
      "Flag participant pairs that reviewed each other's submissions for design transparency.",
      "Estimate and diagnose person/submission measures, reviewer severity, criterion difficulty, fit, and precision."
    ),
    Boundary = c(
      "Design diagnostic; not evidence of peer quality or rating fairness.",
      "Assignment diagnostic; not a reviewer-quality score.",
      "Design-link diagnostic; not a universal adequacy threshold.",
      "Design-transparency diagnostic; not automatically a bias finding.",
      "Measurement model; keep separate from assignment-design diagnostics."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:2487
.mfrmr_table_network_review_reporting_map_data <- data.frame(
    Area = c(
      "MFRM measurement model",
      "Design network",
      "Sparse linked design",
      "Peer-review design",
      "Rater-effect network"
    ),
    PrimaryHelper = c(
      "fit_mfrm(); diagnose_mfrm()",
      "mfrm_network_analysis(); build_mfrm_network_review()",
      "simulate_mfrm_data(..., assignment = \"sparse_linked\")",
      "build_peer_review_sim_spec(); simulate_mfrm_data()",
      "rater_network_analysis(); rater_halo_network_analysis()"
    ),
    Use = c(
      "Estimate and diagnose person/facet measures, fit, precision, and bias.",
      "Inspect observed co-observation connectedness, articulation points, bridge edges, and design-level linking vulnerability.",
      "Inspect planned missingness, rater coverage, and common-person links in sparse simulation designs.",
      "Simulate peer-review or peer-assessment assignments with shared submission/reviewer IDs, no-self-review checks, reviewer-load diagnostics, and common-submission reviewer links.",
      "Screen observed rater relationship or halo patterns as descriptive diagnostics."
    ),
    Boundary = c(
      "Primary measurement model.",
      "Design diagnostic; not person ability, rater quality, or formal fit.",
      "Design diagnostic; not a recovery, fit, or separation criterion.",
      "Design diagnostic; not peer quality, reviewer fairness, or a universal common-link adequacy threshold.",
      "Descriptive network diagnostic; not a Rasch logit estimate or causal halo conclusion."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:8667
.mfrmr_table_summary_table_bundle_appendix_role_registry_out <- data.frame(
    Role = c(
      "run_overview",
      "population_basis",
      "population_coefficients",
      "population_design",
      "population_coding",
      "facet_distribution",
      "person_distribution",
      "category_structure",
      "gpcm_discrimination",
      "estimation_settings",
      "overall_fit",
      "precision_basis",
      "precision_review",
      "facet_precision",
      "flag_counts",
      "missingness",
      "score_usage",
      "facet_coverage",
      "agreement",
      "checklist_overview",
      "section_coverage",
      "facets_relationship_wording",
      "priority_distribution",
      "draft_overview",
      "component_stats",
      "draft_checks",
      "text_preview",
      "reporting_map",
      "extreme_facet_levels",
      "extreme_person_high",
      "extreme_person_low",
      "extreme_fit_rows",
      "draft_actions",
      "checklist_settings",
      "structural_design_overview",
      "structural_design_profile",
      "structural_design_load_balance",
      "structural_design_coverage",
      "structural_design_guardrails",
      "structural_design_readiness",
      "structural_design_recommendation",
      "structural_design_appendix_presets",
      "structural_design_appendix_roles",
      "structural_design_appendix_sections",
      "structural_design_selection_table_presets",
      "structural_design_selection_handoff_tables",
      "structural_design_selection_handoff_presets",
      "structural_design_selection_handoff",
      "structural_design_selection_handoff_bundles",
      "structural_design_selection_handoff_roles",
      "structural_design_selection_handoff_role_sections",
      "structural_design_selection_tables",
      "structural_design_selection_summary",
      "structural_design_selection_roles",
      "structural_design_selection_sections",
      "structural_design_selection_catalog",
      "structural_design_reporting_map",
      "linking_review_overview",
      "linking_risk_screen",
      "linking_risk_group_index",
      "misfit_casebook_overview",
      "misfit_case_rows",
      "misfit_case_rollup",
      "misfit_case_sources",
      "weighting_review_overview",
      "review_status",
      "plot_routing",
      "capability_boundary",
      "repair_recommendations",
      "interpretation_notes",
      "reweighting_measure_shift",
      "score_category_caveats",
      "analysis_caveats",
      "prediction_overview",
      "unit_estimates",
      "prediction_row_review",
      "prediction_population_review",
      "scoring_settings",
      "plausible_value_overview",
      "plausible_value_draws",
      "design_performance",
      "signal_detection",
      "design_grid",
      "forecast_summary",
      "workflow_overview",
      "column_mapping",
      "workflow_settings",
      "bias_overview",
      "bias_chi_square",
      "bias_iteration_status",
      "bias_screening_rows",
      "anchor_review_overview",
      "anchor_issue_counts",
      "level_observation_review",
      "category_usage",
      "prefit_anchor_risks",
      "drift_risks",
      "chain_risks",
      "review_settings"
    ),
    AppendixSection = c(
      "methods",
      "methods",
      "methods",
      "methods",
      "methods",
      "results",
      "results",
      "results",
      "results",
      "methods",
      "results",
      "results",
      "diagnostics",
      "results",
      "diagnostics",
      "methods",
      "methods",
      "results",
      "reporting",
      "reporting",
      "reporting",
      "methods",
      "reporting",
      "reporting",
      "reporting",
      "workflow",
      "workflow",
      "workflow",
      "exploratory",
      "exploratory",
      "exploratory",
      "exploratory",
      "workflow",
      "workflow",
      "methods",
      "methods",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "methods",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "workflow",
      "diagnostics",
      "workflow",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "methods",
      "methods",
      "diagnostics",
      "workflow",
      "methods",
      "reporting",
      "reporting",
      "results",
      "diagnostics",
      "diagnostics",
      "results",
      "results",
      "diagnostics",
      "diagnostics",
      "methods",
      "results",
      "results",
      "results",
      "diagnostics",
      "methods",
      "results",
      "workflow",
      "workflow",
      "workflow",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "methods"
    ),
    RecommendedAppendix = c(
      TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
      TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
      TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
      FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE,
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE,
      TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE,
      TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE,
      TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
    ),
    CompactAppendix = c(
      TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, FALSE, FALSE,
      TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE,
      TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
      FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE,
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE,
      TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE,
      TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, TRUE,
      TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, TRUE, FALSE
    ),
    PreferredAppendixOrder = c(
      10L, 20L, 30L, 35L, 36L, 40L, 50L, 60L, 70L, 80L,
      90L, 100L, 110L, 120L, 130L, 140L, 150L, 160L, 170L,
      180L, 190L, 195L, 200L, 210L, 220L,
      990L, 991L, 900L,
      910L, 920L, 930L, 940L, 950L, 960L,
      225L, 226L, 227L, 228L, 229L, 230L, 231L,
      970L, 971L, 972L, 973L, 974L, 975L, 976L, 977L, 978L, 979L, 980L, 981L, 982L, 983L, 984L, 985L,
      232L, 233L, 234L, 235L, 236L, 237L, 238L, 239L, 240L, 986L, 987L, 988L, 989L, 125L, 131L, 132L,
      133L, 134L, 135L, 136L, 137L, 138L, 139L,
      241L, 242L, 243L, 244L, 245L, 246L, 247L, 248L, 249L, 250L, 251L,
      252L, 253L, 254L, 255L, 256L, 257L, 258L, 259L
    ),
    AppendixRationale = c(
      "Always include the main run-identification table.",
      "Include whenever population-model interpretation is part of the report.",
      "Include when latent-regression coefficients were estimated.",
      "Include to review latent-regression design-matrix columns and variance screening.",
      "Include when categorical population covariates were encoded through the model matrix.",
      "Core facet spread and scale-location appendix table.",
      "Useful for full appendices but omitted from compact presets.",
      "Core threshold/category appendix table.",
      "Useful when GPCM discrimination is active.",
      "Methods/settings appendix table; recommended but not compact.",
      "Core fit summary table for results appendices.",
      "Core precision-basis table for cautious interpretation.",
      "Recommended when precision caveats need explicit documentation.",
      "Core reliability/separation appendix table.",
      "Recommended diagnostic count surface for QC appendices.",
      "Core missing-data appendix table.",
      "Core score-usage appendix table.",
      "Core facet-coverage appendix table.",
      "Optional agreement appendix surface.",
      "Recommended checklist overview for reporting QA appendices.",
      "Core section-coverage appendix table.",
      "Core FACETS-positioning wording for methods or migration appendices.",
      "Core priority distribution for reporting follow-up.",
      "Core manuscript-draft coverage overview.",
      "Core APA component inventory.",
      "Draft QA surface; keep out of recommended presets.",
      "Preview-only draft text; keep out of recommended presets.",
      "Bridge metadata, useful for workflow but not manuscript appendix.",
      "Exploratory extreme table; available only in full exports.",
      "Exploratory extreme table; available only in full exports.",
      "Exploratory extreme table; available only in full exports.",
      "Exploratory extreme table; available only in full exports.",
      "Drafting action list; keep out of recommended presets.",
      "Checklist settings; keep out of recommended presets.",
      "Recommended methods appendix overview for the structural design review.",
      "Recommended exact-count profile for structural-design methods appendices.",
      "Detailed load-balance diagnostics; retain for full exports but omit from recommended presets.",
      "Detailed coverage/connectivity diagnostics; retain for full exports but omit from recommended presets.",
      "Detailed guardrail classifications; retain for full exports but omit from recommended presets.",
      "Core structural readiness table for the design review.",
      "Core conservative recommendation table for structural-design methods appendices.",
      "Workflow-only appendix preset counts for the structural design review.",
      "Workflow-only appendix role counts for the structural design review.",
      "Workflow-only appendix section counts for the structural design review.",
      "Workflow-only preset-specific appendix table selections for the structural design review.",
      "Workflow-only table-level appendix handoff crosswalk for the structural design review.",
      "Workflow-only preset-level appendix handoff overview for the structural design review.",
      "Workflow-only manuscript-section handoff summary for the structural design review.",
      "Workflow-only bundle-aware appendix handoff summary for the structural design review.",
      "Workflow-only role-aware appendix handoff summary for the structural design review.",
      "Workflow-only role-by-section appendix handoff summary for the structural design review.",
      "Workflow-only preset-aware appendix table selections for the structural design review.",
      "Workflow-only preset-filtered appendix bundle counts for the structural design review.",
      "Workflow-only preset-filtered appendix role counts for the structural design review.",
      "Workflow-only preset-filtered appendix section counts for the structural design review.",
      "Workflow-only preset-filtered appendix selection catalog for the structural design review.",
      "Workflow-only reporting-map metadata for the structural design review.",
      "Recommended overview table for linking-review appendix handoff.",
      "Recommended top-risk table for operational linking-review follow-up appendices.",
      "Recommended grouping-view index for operational linking-review triage.",
      "Recommended overview table for operational misfit-case review appendix handoff.",
      "Recommended top-case table for operational misfit follow-up appendices.",
      "Recommended rollup table showing where flagged cases concentrate across review groupings.",
      "Recommended source-family count table for operational misfit follow-up appendices.",
      "Recommended overview table for weighting-policy review appendix handoff.",
      "Recommended compact status table for review-oriented appendix handoff.",
      "Plot-routing metadata; keep out of recommended appendix presets.",
      "Capability-boundary statement for supported-with-caveat review helpers.",
      "Recommended action-oriented table for repair or follow-up planning.",
      "Interpretation notes; retain mainly in full reporting exports.",
      "Recommended reweighting-change table for GPCM comparison review.",
      "Recommended caveat table for retained zero-count score categories and related score-support warnings.",
      "Recommended fit-level caveat table for score-support, population-model, and other analysis warnings.",
      "Recommended overview table for posterior unit-scoring appendix handoff.",
      "Recommended posterior estimate table for scored-person appendix handoff.",
      "Row-level scoring review; retain for full exports but omit from compact presets.",
      "Recommended latent-regression scoring omission review when population-model scoring is active.",
      "Methods/settings appendix table for posterior scoring inputs; recommended but not compact.",
      "Recommended overview table for plausible-value appendix handoff.",
      "Recommended plausible-value draw summary table for posterior-scoring appendices.",
      "Recommended design-performance table for simulation design appendices.",
      "Recommended signal-detection table for simulation diagnostics appendices.",
      "Recommended design-grid table documenting requested forecast inputs.",
      "Recommended forecast-summary table for population prediction appendices.",
      "Workflow-only overview for one-shot run handoff; omit from manuscript presets.",
      "Workflow-only column mapping for replay and traceability handoff.",
      "Workflow-only run settings for one-shot workflow provenance.",
      "Recommended overview table for bias-screening appendix handoff.",
      "Recommended fixed-effect chi-square table for bias-screening appendices.",
      "Bias iteration status table; retain for full exports but omit from compact presets.",
      "Recommended ranked bias-screening row table for immediate follow-up.",
      "Recommended overview table for anchor-review appendix handoff.",
      "Recommended anchor issue-count table for pre-fit review appendices.",
      "Recommended level-observation review table; retain for full appendices but omit from compact presets.",
      "Recommended score-category usage table for anchor-review support review.",
      "Recommended pre-fit anchor-risk table for linking-review appendices.",
      "Recommended drift-risk table for linking-review appendices.",
      "Recommended chain-risk table for linking-review appendices.",
      "Methods/settings table for operational review helpers; recommended but not compact."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:9012
.mfrmr_table_summary_table_bundle_appendix_role_registry_recovery_roles <- data.frame(
    Role = c(
      "recovery_overview",
      "recovery_design_basis",
      "recovery_settings",
      "recovery_performance",
      "recovery_replications",
      "recovery_diagnostic_operating_characteristics",
      "recovery_diagnostic_oc_summary",
      "recovery_assessment_overview",
      "recovery_assessment_reading_order",
      "recovery_assessment_checklist",
      "recovery_condition_reporting_notes",
      "recovery_condition_review",
      "recovery_diagnostic_reporting_notes",
      "recovery_diagnostic_review",
      "recovery_metric_review",
      "recovery_uncertainty_review"
    ),
    AppendixSection = c(
      "methods",
      "methods",
      "methods",
      "results",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics"
    ),
    RecommendedAppendix = rep(TRUE, 16),
    CompactAppendix = c(TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),
    PreferredAppendixOrder = 260:275,
    AppendixRationale = c(
      "Recommended overview table for parameter-recovery simulation appendix handoff.",
      "Recommended ADEMP-style methods table documenting the recovery simulation basis.",
      "Methods/settings table for recovery simulation provenance; recommended but not compact.",
      "Recommended parameter-group recovery-performance table for simulation appendices.",
      "Recommended replication-status table for recovery simulation diagnostics.",
      "Replication-by-facet fit/separation operating characteristics; retain for diagnostics exports.",
      "Recommended facet-level fit/separation operating-characteristic summary for diagnostic context.",
      "Recommended overview table for recovery adequacy assessment appendix handoff.",
      "Recommended reading-order table for recovery assessment handoff.",
      "Recommended checklist table for reviewer-facing recovery adequacy decisions.",
      "Recommended reporter-facing table for generator-condition caveats kept separate from recovery metrics.",
      "Recommended generator-condition table for interpreting GPCM slope-regime recovery evidence.",
      "Recommended reporter-facing table for fit/separation diagnostic caveats kept separate from recovery criteria.",
      "Recommended diagnostic-only fit/separation review table for recovery assessment handoff.",
      "Recommended parameter-group review table for recovery adequacy follow-up.",
      "Recommended uncertainty-evidence table separating coverage availability, SE availability, and coverage decision status."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:9073
.mfrmr_table_summary_table_bundle_appendix_role_registry_recovery_validation_roles <- data.frame(
    Role = c(
      "recovery_evidence_overview",
      "recovery_validation_reading_order",
      "recovery_evidence_case_assessment",
      "recovery_validation_case_summary",
      "recovery_validation_condition_reporting_notes",
      "recovery_validation_condition_summary",
      "recovery_validation_diagnostic_reporting_notes",
      "recovery_validation_diagnostic_oc_summary",
      "recovery_validation_domain_decisions"
    ),
    AppendixSection = c(
      "results",
      "results",
      "results",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics"
    ),
    RecommendedAppendix = rep(TRUE, 9),
    CompactAppendix = rep(TRUE, 9),
    PreferredAppendixOrder = 276:284,
    AppendixRationale = c(
      "Recommended top-line recovery-evidence assessment for methodological appendices.",
      "Recommended reading-order table for recovery-evidence handoff.",
      "Recommended case-level recovery-evidence table for appendix handoff.",
      "Recommended validation-case summary for evidence traceability.",
      "Recommended reporting table that keeps generator-condition caveats separate from validation conclusions.",
      "Recommended generator-condition summary table separating GPCM slope-regime and score-support stress.",
      "Recommended reporting table that keeps fit/separation caveats separate from validation conclusions.",
      "Recommended fit/separation operating-characteristic summary kept separate from recovery criteria.",
      "Recommended long-form domain-decision table for validation diagnostics."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:9113
.mfrmr_table_summary_table_bundle_appendix_role_registry_model_choice_roles <- data.frame(
    Role = c(
      "model_choice_overview",
      "model_choice_comparison",
      "model_choice_comparison_warnings",
      "model_choice_roles",
      "model_choice_downstream_routes",
      "model_choice_report_templates",
      "model_choice_route_map",
      "model_choice_weighting_review"
    ),
    AppendixSection = c(
      "methods",
      "results",
      "diagnostics",
      "methods",
      "workflow",
      "reporting",
      "workflow",
      "diagnostics"
    ),
    RecommendedAppendix = c(TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE),
    CompactAppendix = c(TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE),
    PreferredAppendixOrder = 304:311,
    AppendixRationale = c(
      "Recommended overview table for model-choice appendix handoff.",
      "Recommended same-basis comparison table for candidate-model reporting.",
      "Recommended comparison-boundary warnings explaining why ranking or likelihood-ratio testing was withheld.",
      "Recommended model-role table separating operational references from sensitivity candidates.",
      "Workflow-only route-availability table for model-choice follow-up.",
      "Recommended cautious wording table for model-choice reporting.",
      "Workflow-only question-to-helper map for model-choice review.",
      "Recommended status table for optional GPCM weighting review."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:9150
.mfrmr_table_summary_table_bundle_appendix_role_registry_sparse_roles <- data.frame(
    Role = c(
      "sparse_design_diagnostics",
      "recovery_sparse_design_diagnostics",
      "peer_review_design_diagnostics",
      "peer_review_load_summary",
      "peer_review_submission_load",
      "peer_review_reviewer_load",
      "peer_review_common_links",
      "peer_review_low_common_links",
      "peer_review_reciprocal_pairs"
    ),
    AppendixSection = c(
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics",
      "diagnostics"
    ),
    RecommendedAppendix = c(TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE),
    CompactAppendix = c(TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE),
    PreferredAppendixOrder = c(259.5, 263.5, 264.5, 264.6, 264.7, 264.8, 264.9, 265.1, 265.2),
    AppendixRationale = c(
      "Recommended planned-missingness and rater-link diagnostics for sparse linked design appendices.",
      "Recommended replication-level sparse linked design diagnostics kept separate from recovery metrics.",
      "Recommended peer-review assignment and reviewer-link diagnostics kept separate from measurement estimates.",
      "Recommended compact load-balance summary for peer-review assignment appendices.",
      "Full submission-load table; retain for detailed diagnostics exports.",
      "Recommended reviewer-load table for assignment follow-up.",
      "Full reviewer-pair common-submission table; retain for detailed diagnostics exports.",
      "Recommended reviewer-pair low-common-link table for peer-review assignment follow-up.",
      "Recommended reciprocal review-pair table for peer-review assignment transparency."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:9190
.mfrmr_table_summary_table_bundle_appendix_role_registry_diagnostic_screening_roles <- data.frame(
    Role = c(
      "diagnostic_screening_design_basis",
      "diagnostic_screening_settings",
      "diagnostic_screening_overview",
      "diagnostic_screening_reading_order",
      "diagnostic_screening_next_actions",
      "diagnostic_screening_reporting_notes",
      "diagnostic_screening_figure_recipes",
      "diagnostic_screening_scenario_summary",
      "diagnostic_screening_performance",
      "diagnostic_screening_report_signals",
      "diagnostic_screening_contrast",
      "diagnostic_screening_plot_data",
      "diagnostic_screening_runtime"
    ),
    AppendixSection = c(
      "methods",
      "methods",
      "methods",
      "reporting",
      "workflow",
      "reporting",
      "workflow",
      "diagnostics",
      "diagnostics",
      "reporting",
      "diagnostics",
      "diagnostics",
      "methods"
    ),
    RecommendedAppendix = rep(TRUE, 13),
    CompactAppendix = c(TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE),
    PreferredAppendixOrder = 291:303,
    AppendixRationale = c(
      "Recommended ADEMP-style methods table documenting the diagnostic-screening simulation basis.",
      "Methods/settings table for diagnostic-screening provenance; recommended but not compact.",
      "Recommended overview table for diagnostic-screening appendix handoff.",
      "Recommended reading-order table for diagnostic-screening summaries and appendices.",
      "Recommended action table for diagnostic-screening follow-up and export routing.",
      "Recommended reporting-boundary table for cautious diagnostic-screening interpretation.",
      "Recommended figure/display recipe table so custom graphics keep plot calls, captions, and boundaries explicit.",
      "Recommended scenario-by-design screening summary for diagnostic appendices.",
      "Recommended operating-characteristic table for diagnostic-screening interpretation.",
      "Recommended report-signal table when mfrm_report() review signals were retained.",
      "Recommended misspecification-minus-baseline contrast table for diagnostic follow-up.",
      "Long-form draw-free plot data for interactive or custom visualization handoff; recommended but not compact.",
      "Runtime operating-characteristic table; recommended for methods appendices but not compact."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:9242
.mfrmr_table_summary_table_bundle_appendix_role_registry_network_review_roles <- data.frame(
    Role = c(
      "network_review_overview",
      "network_design_summary",
      "network_facet_vulnerability",
      "network_central_nodes",
      "network_articulation_nodes",
      "network_bridge_edges"
    ),
    AppendixSection = rep("diagnostics", 6),
    RecommendedAppendix = rep(TRUE, 6),
    CompactAppendix = c(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE),
    PreferredAppendixOrder = 285:290,
    AppendixRationale = c(
      "Recommended overview table for design-network connectedness and vulnerability review.",
      "Recommended graph-level design-network summary for connectivity diagnostics.",
      "Recommended facet-level design-network vulnerability table for follow-up appendices.",
      "High-betweenness node table; retain for full diagnostics exports but omit from compact presets.",
      "Recommended articulation-point table for fragile-link follow-up.",
      "Recommended bridge-edge table for one-link dependency follow-up."
    ),
    stringsAsFactors = FALSE
  )
# From api-reports.R:9266
.mfrmr_table_summary_table_bundle_appendix_role_registry_data <- data.frame(
    Role = c("conditional_decisions", "score_dispositions"),
    AppendixSection = c("results", "diagnostics"),
    RecommendedAppendix = TRUE, CompactAppendix = TRUE,
    PreferredAppendixOrder = c(134.5, 136.5),
    AppendixRationale = c(
      "Conditional ability event probabilities with supplied cuts, actual priors and availability; parameter-estimation uncertainty is excluded.",
      "Retain review and unavailable Person dispositions alongside the score batch, including Persons with no scored responses."
    ), stringsAsFactors = FALSE
  )
# From api-reports.R:9276
.mfrmr_table_summary_table_bundle_appendix_role_registry_data_1 <- data.frame(
    Role = c("study_design", "study_estimates", "study_diagnostics", "study_notes"),
    AppendixSection = c("methods", "results", "diagnostics", "reporting"),
    RecommendedAppendix = TRUE, CompactAppendix = TRUE,
    PreferredAppendixOrder = c(312, 313, 314, 315),
    AppendixRationale = c("Retain the source, future plan, weights and estimator.",
      "Retain full signed estimates, errors and supplied uncertainty.",
      "Retain unavailable results and component/overlap diagnostics.",
      "Retain interpretation boundaries with the reported evidence."), stringsAsFactors = FALSE)
# From api-reports.R:9568
.mfrmr_table_summary_table_bundle_reporting_map_data <- data.frame(
    Area = c(
      "Coverage overview",
      "Table catalog / manuscript selection",
      "Numeric QC and quick plotting",
      "APA / appendix bridge",
      "Source-level caveats"
    ),
    CoveredHere = c("yes", "yes", "yes", "yes", "partial"),
    CompanionOutput = c(
      "summary(bundle)$overview / role_summary",
      "summary(bundle)$table_catalog / bundle$table_index",
      "summary(bundle)$plot_index / plot(bundle, ...)",
      "apa_table(bundle, which = ...) / export_summary_appendix(bundle, preset = \"recommended\")",
      "bundle$notes and the originating summary()/diagnostics output"
    ),
    stringsAsFactors = FALSE
  )
# From api-results.R:2389
.mfrmr_table_mfrm_report_evidence_boundary_data <- data.frame(
    EvidenceSource = c(
      "Model setup and convergence",
      "Fit, separation, and precision",
      "Category functioning",
      "Bias and DFF screening",
      "Misfit and pathway maps",
      "Anchors, linking, and drift",
      "Network and connectivity",
      "Response-time QC",
      "GPCM helper coverage",
      "APA-style wording"
    ),
    Use = c(
      "Document estimation settings, data roles, and run stability.",
      "Separate fit-size, standardized fit, separation, reliability, and uncertainty evidence.",
      "Describe how score categories function and where thresholds or curves need review.",
      "Identify candidate contrasts for follow-up fairness or interaction review.",
      "Localize unexpected observations for case review and substantive interpretation.",
      "Assess anchor readiness and operational scale-maintenance workflow.",
      "Describe design overlap, sparseness, and connectedness.",
      "Describe rapid/slow-response timing patterns as separate QC context.",
      "State which GPCM summaries are supported and which are caveated.",
      "Draft report prose, captions, and section maps."
    ),
    DoNotUseAs = c(
      "Proof that the construct interpretation is valid.",
      "A single pass/fail psychometric rule.",
      "Standalone validity evidence.",
      "Final fairness, bias, or invariance conclusion.",
      "Automatic exclusion rule for persons, raters, items, or observations.",
      "Single-fit evidence of drift or completed equating.",
      "A replacement for fit, precision, or bias diagnostics.",
      "A fitted speed parameter, speed-accuracy model, or automatic exclusion rule.",
      "A claim that every RSM/PCM report pathway has an equivalent GPCM route.",
      "Final manuscript text without study-specific editing."
    ),
    RecommendedRoute = c(
      "summary(res)$overview; mfrm_report(type = 'specifications', fit)",
      "summary(res$components$precision_review); mfrm_report(fit, type = 'precision')",
      "rating_scale_table(); mfrm_report(fit, type = 'category_structure'); mfrm_report(fit, type = 'category_curves')",
      "mfrm_results(fit, include = \"bias\"); estimate_bias(); mfrm_report(fit, type = 'bias_interaction')",
      "mfrm_results(fit, include = \"misfit_review\"); unexpected_response_table(); plot(res, type = \"pathway\")",
      "mfrm_results(fit, include = \"linking\"); review_mfrm_anchors(); detect_anchor_drift(); build_equating_chain()",
      "mfrm_results(fit, include = \"network\"); build_mfrm_network_review()",
      "mfrm_results(fit, include = \"response_time\", response_time = ..., response_time_data = ...); response_time_review()",
      "mfrmr_output_guide(\"gpcm_capabilities\"); mfrmr_output_guide(\"gpcm\")",
      "mfrm_report(res, style = \"apa\"); build_apa_outputs()"
    ),
    stringsAsFactors = FALSE
  )
# From api-results.R:2481
.mfrmr_table_mfrm_report_zstd_conventions_data <- data.frame(
    Convention = c(
      "engine df",
      "FACETS-style df",
      "Wilson-Hilferty ZSTD",
      "FACETS WHEXACT=NO",
      "Report comparison route"
    ),
    FormulaOrRule = c(
      "Infit df = sum(Var * Weight); Outfit df = sum(Weight).",
      "Fourth-moment Wright-Masters-style df: 2 * numerator^2 / denominator; package columns DF_*_FACETS.",
      "(MnSq^(1/3) - (1 - 2 / (9 * df))) / sqrt(2 / (9 * df)).",
      "3 * (MnSq^(1/3) - 1) / sqrt(2/df) when whexact = TRUE; legacy_linear explicitly retains the old linear approximation.",
      "Keep engine and FACETS-style columns side by side with fit_df_method = \"both\"."
    ),
    PackageConstraint = c(
      "zstd_from_mnsq() returns NA when df < 1 to avoid unstable Wilson-Hilferty signs.",
      "zstd_from_mnsq_facets() returns NA when df < 1 and caps available ZSTD at +/-9.",
      "Requires finite positive MnSq and usable df; small df can dominate the transformation.",
      "Still requires usable df; use only when the analysis intentionally follows that convention.",
      "Compare MnSq first, then df, then ZSTD; classify flag changes as convention-sensitive."
    ),
    ReportingImplication = c(
      "Both conventions withhold df < 1; this is an availability rule, not a calibrated conservative test.",
      "This option applies the documented fourth-moment df/ZSTD convention; agreement with external FACETS output must be checked separately.",
      "ZSTD is a standardization of MnSq, not a separate residual-fit statistic.",
      "State the transformation setting before interpreting ZSTD.",
      "Do not explain fit decisions from ZSTD alone when MnSq, df, or threshold profile differs."
    ),
    SourceBasis = c(
      "Package-native numerical guard for Wilson-Hilferty stability.",
      "FACETS/Winsteps fit-standardization documentation and Wright-Masters fourth-moment df convention.",
      "Wilson-Hilferty cube-root approximation used in Rasch fit standardization.",
      "Winsteps/FACETS WHEXACT documentation.",
      "facets_guide('fit_df'); facets_fit_review(); fit_measures_table()."
    ),
    Route = c(
      "diagnose_mfrm(fit_df_method = \"engine\")",
      "diagnose_mfrm(fit_df_method = \"facets\")",
      "fit_measures_table(..., fit_df_method = \"engine\" or \"facets\")",
      "diagnose_mfrm(..., whexact = TRUE)",
      "fit_measures_table(..., fit_df_method = \"both\")"
    ),
    stringsAsFactors = FALSE
  )
# From api-results.R:2529
.mfrmr_table_mfrm_report_fit_decision_policy_data <- data.frame(
    Step = seq_len(6L),
    Rule = c(
      "Choose and state the MnSq band",
      "Read MnSq before ZSTD",
      "Keep ZSTD convention visible",
      "Separate fit from precision",
      "Treat profile disagreement as sensitivity evidence",
      "Use local review before action"
    ),
    Rationale = c(
      "Published bands differ by setting; the active band and sensitivity profiles should both be visible.",
      "MnSq is the size of the fit signal; ZSTD is a df-dependent standardization of that signal.",
      "FACETS-style df can change |ZSTD| flags even when MnSq is unchanged.",
      "Fit, separation, reliability, and strata answer different questions.",
      "A row can be flagged under one defensible band and not another; report this as a review sensitivity.",
      "Element fit flags are prompts for inspecting responses, raters, items, categories, or design links."
    ),
    RecommendedRoute = c(
      "fit_measures_table(threshold_profiles = \"all\")",
      "fit_measures_table()$table[, c(\"Infit\", \"Outfit\", \"FitStatus\")]",
      "fit_measures_table(fit_df_method = \"both\")$df_sensitivity",
      "mfrm_report(fit, type = 'precision')$fit_separation_basis",
      "fit_measures_table()$profile_summary_by_facet",
      "unexpected_response_table(); displacement_table(); plot(res, type = \"pathway\")"
    ),
    ReportBoundary = c(
      "Do not silently mix bands across reports.",
      "Do not treat ZSTD as independent evidence from MnSq.",
      "Do not call a df-sensitive ZSTD change a substantive fit change without MnSq/context evidence.",
      "Do not use high reliability to excuse misfit or good fit to imply high precision.",
      "Do not present one threshold profile as universal.",
      "Do not remove levels or observations from fit flags alone."
    ),
    stringsAsFactors = FALSE
  )
# From api-results.R:3201
.mfrmr_table_mfrm_report_precision_evidence_summary_data <- data.frame(
      Status = "not_available",
      PrecisionTier = NA_character_,
      SupportsFormalInference = NA,
      ReliabilityRows = NA_integer_,
      ReviewOrWarnChecks = NA_integer_,
      MinSeparation = NA_real_,
      MaxSeparation = NA_real_,
      MinReliability = NA_real_,
      MaxReliability = NA_real_,
      MinStrata = NA_real_,
      MaxStrata = NA_real_,
      ZeroSeparationRows = NA_integer_,
      ZeroReliabilityRows = NA_integer_,
      ReliabilityUse = NA_character_,
      Source = "not_available",
      Route = "mfrm_results(fit, include = \"precision\")",
      Boundary = paste0(
        "Precision/separation wording requires the stored precision review ",
        "or diagnostics$reliability. Rebuild the result with precision included."
      ),
      stringsAsFactors = FALSE
    )
# From api-results.R:3449
.mfrmr_table_mfrm_report_bias_evidence_summary_data <- data.frame(
      Status = "not_requested",
      Rows = NA_integer_,
      Facets = NA_integer_,
      NonPersonFacets = NA_integer_,
      MaxAbsBias = NA_real_,
      MaxAbsStdResidual = NA_real_,
      ResidualTScreenPositiveRows = NA_integer_,
      ChiSqScreenPositiveRows = NA_integer_,
      ExplicitInteractionSelected = FALSE,
      InteractionStatus = "not_requested",
      Source = "not_requested",
      Route = "mfrm_results(fit, include = \"bias\")",
      Boundary = paste0(
        "Bias/DFF wording requires the bias preset or an explicit bias/DFF ",
        "helper call. Do not infer fairness conclusions from omitted sections."
      ),
      stringsAsFactors = FALSE
    )
# From api-results.R:3669
.mfrmr_table_mfrm_report_misfit_evidence_summary_data <- data.frame(
      Status = "not_requested",
      UnexpectedRows = NA_integer_,
      DisplacementRows = NA_integer_,
      PathwayFitRows = NA_integer_,
      PathwayStatusRows = NA_integer_,
      CurveFitStatusRows = NA_integer_,
      UnexpectedScreenPositiveRows = NA_integer_,
      DisplacementFlaggedRows = NA_integer_,
      MaxAbsStdResidual = NA_real_,
      MaxAbsDisplacement = NA_real_,
      MaxAbsDisplacementT = NA_real_,
      PathwayAvailable = FALSE,
      Source = "not_requested",
      Route = "mfrm_results(fit, include = \"misfit_review\")",
      Boundary = paste0(
        "Misfit/pathway wording requires the misfit_review preset or explicit ",
        "unexpected-response, displacement, and pathway helper calls."
      ),
      stringsAsFactors = FALSE
    )
# From api-results.R:3904
.mfrmr_table_mfrm_report_linking_evidence_summary_data <- data.frame(
      Status = "not_requested",
      AnchorReviewAvailable = FALSE,
      DriftAvailable = FALSE,
      ChainAvailable = FALSE,
      ReviewStatus = "not_requested",
      TopRiskRows = NA_integer_,
      AnchorRiskRows = NA_integer_,
      DriftRiskRows = NA_integer_,
      ChainRiskRows = NA_integer_,
      GroupViews = NA_integer_,
      AnchorFacetRows = NA_integer_,
      AnchoredLevels = NA_integer_,
      GroupAnchoredLevels = NA_integer_,
      OverlapLevels = NA_integer_,
      AnchorIssueTypes = NA_integer_,
      AnchorIssueRows = NA_integer_,
      LowObservationLevels = NA_integer_,
      LowCategoryRows = NA_integer_,
      DriftReviewStatus = "not_requested",
      EquatingChainStatus = "not_requested",
      GPCMSupport = NA_character_,
      SourceModels = NA_character_,
      Source = "not_requested",
      Route = "mfrm_results(fit, include = \"linking\")",
      Boundary = paste0(
        "Linking/anchor wording requires the linking preset or explicit ",
        "anchor, drift, or equating-chain helper calls."
      ),
      stringsAsFactors = FALSE
    )
# From api-results.R:5310
.mfrmr_table_mfrm_report_route_table_data <- data.frame(
    Surface = c(
      "First screen",
      "Detailed evidence routes",
      "Template boundaries",
      "Markdown report",
      "Download folder"
    ),
    Route = c(
      "report$first_screen",
      "report$report_index",
      "report$template_index",
      "mfrm_report(res, output = \"markdown\")",
      "export_mfrm_results(res, include = \"report\")"
    ),
    Use = c(
      "Start here; read the overall row and next-action route.",
      "Open when the first screen points to a specific evidence area.",
      "Open before using APA/QC/validation wording.",
      "Use after the evidence status and caveats have been reviewed.",
      "Use when report tables, Markdown, and HTML need to be handed off."
    ),
    stringsAsFactors = FALSE
  )
# From api-results.R:6048
.mfrmr_table_mfrm_results_export_privacy_notice_data <- data.frame(
    PrivacyClass = "analysis_archive",
    Deidentified = FALSE,
    ShareableWithoutReview = FALSE,
    Notice = paste0(
      "This export is an analysis archive, not a deidentified or automatically ",
      "shareable package. It can contain direct person identifiers, person-level ",
      "estimates, original facet labels, local file paths, and a complete RDS ",
      "result object. Review and transform every file under the applicable data-",
      "handling policy before sharing it."
    ),
    stringsAsFactors = FALSE
  )
# From api-simulation.R:4596
.mfrmr_table_recovery_assessment_reading_order_data <- data.frame(
    Step = seq_len(6L),
    Route = c(
      "summary(recovery_review)",
      "recovery_review$condition_reporting_notes, then recovery_review$condition_review",
      "recovery_review$diagnostic_reporting_notes, then recovery_review$diagnostic_review",
      "plot(recovery_review, type = \"status\")",
      "plot(recovery_review, type = \"metrics\")",
      "recovery_review$source$recovery"
    ),
    WhatToRead = c(
      "Overall run status, next actions, and compact checklist.",
      "Generator-condition caveats, then GPCM slope-regime and generated score-support metadata.",
      "Reporter-facing fit/separation caveats, then optional operating characteristics retained by include_diagnostics = TRUE.",
      "Checklist domains ordered by attention status.",
      "Parameter groups behind RMSE, bias, coverage, SE, or Monte Carlo statuses.",
      "Row-level truth-estimate comparisons for the parameter groups that need follow-up."
    ),
    Purpose = c(
      "Decide whether the assessment is ready to inspect.",
      "Separate generator stress conditions and sparse score support from parameter-recovery performance before interpreting metrics.",
      "Check diagnostic behavior without treating fit or separation as parameter-recovery criteria.",
      "Find the part of the assessment that needs attention first.",
      "Identify the specific parameter group and metric driving the status.",
      "Diagnose the underlying recovery pattern before changing design or fit settings."
    ),
    stringsAsFactors = FALSE
  )
# From api-simulation.R:8138
.mfrmr_table_diagnostic_screening_reading_order_out <- data.frame(
    Step = 1:10,
    Table = c(
      "overview",
      "reading_order",
      "next_actions",
      "reporting_notes",
      "figure_recipes",
      "scenario_summary",
      "performance_summary",
      "scenario_contrast",
      "report_signal_summary",
      "plot_overview_rate"
    ),
    WhatToRead = c(
      "Design count, replication count, scenarios, model, convergence, and whether report signals were retained.",
      "Recommended reading sequence for diagnostic-screening summaries.",
      "Action-oriented triage for replication count, run completion, contrasts, report signals, and export.",
      "Reporting boundaries and recommended wording safeguards.",
      "Figure and display recipes linking plot() calls, plot_data() extraction, caption focus, and interpretation boundaries.",
      "Scenario-by-design legacy, strict marginal, and strict pairwise screening summaries.",
      "Operating-characteristic rates, Type I/sensitivity proxy labels, agreement rates, and runtime summaries.",
      "Misspecification-minus-well-specified deltas when a baseline scenario was evaluated.",
      "Optional mfrm_report() report-index availability/readiness and review-signal summaries.",
      "Long-form draw-free visualization table for the main overview-rate display."
    ),
    Purpose = c(
      "Confirm that the simulation ran as intended before interpreting screening behavior.",
      "Avoid treating every exported table as equal-priority evidence.",
      "Decide whether to increase replications, inspect run failures, read contrasts, request report signals, or export appendices.",
      "Keep simulation screening language distinct from inferential and parameter-recovery conclusions.",
      "Choose the smallest figure set that matches the reporting purpose before styling or rendering.",
      "Compare raw screening surfaces across scenarios and design conditions.",
      "Separate operating behavior from runtime and from inferential or validation conclusions.",
      "Inspect whether misspecification shifts strict screens beyond the well-specified baseline.",
      "Use only when include_report = TRUE; otherwise treat absence as not requested.",
      "Reuse for ggplot2, plotly, Quarto, or supplementary figure construction."
    ),
    InterpretationBoundary = c(
      "Run completion and convergence are prerequisites for interpretation, not proof that the diagnostic screen is calibrated.",
      "Reading order is guidance for human review, not a statistical decision rule.",
      "Next actions are workflow prompts, not statistical decisions.",
      "Use cautious wording unless replication count, design, and scenario coverage support stronger claims.",
      "Figure recipes are reporting workflow guidance; they do not add evidence beyond the underlying summary tables.",
      "Scenario means and flag rates are operating-characteristic readouts, not formal inferential p-values.",
      "Type I and sensitivity labels are simulation proxies tied to the evaluated scenarios.",
      "Contrasts are descriptive deltas and depend on the selected baseline, design, and replication count.",
      "Report signals summarize the package reporting layer; they do not validate the model or the simulation design.",
      "Plot data are a presentation handoff and should not be reinterpreted as a separate analysis."
    ),
    stringsAsFactors = FALSE
  )
# From api-tables.R:8231
.mfrmr_table_build_bias_heatmap_data_reference_notes <- data.frame(
    Reference = c(
      "Linacre (1989); FACETS Table 13 / Table 14 interaction logic",
      "FACETS Tutorial 3: bias / interaction report",
      "mfrmr estimate_bias() screening label"
    ),
    Role = c(
      "Local behavior is contrasted with general facet behavior before substantive interpretation.",
      "Table 13 highlights conspicuous interaction cells; plots are follow-up aids, not replacements for the table.",
      "Heatmap cells inherit the conditional screening interpretation of estimate_bias()."
    ),
    stringsAsFactors = FALSE
  )
# From api-tables.R:8244
.mfrmr_table_build_bias_heatmap_data_interpretation_guide <- data.frame(
    Topic = c("Definition", "Cell", "Sign", "Score coding", "Absolute profile",
      "Flag outline", "Higher-order interactions", "Use of results"),
    Guidance = c(
      "Bias here is a conditional interaction departure from the baseline model, not overall rater severity, estimator bias, or evidence of prejudice or unfairness.",
      "Each cell represents a Facet1 level by Facet2 level interaction row from the bias table.",
      "Positive Bias Size increases expected coded scores relative to the baseline; negative Bias Size decreases them. This additive-shift sign is distinct from a negatively oriented rater's severity sign.",
      "Whether a higher coded score favors the performance depends on the rubric; category labels alone do not reverse scoring.",
      "Mean absolute bias in the facet-profile view measures magnitude and discards direction; return to signed cell rows before interpreting favoring or penalizing.",
      "Flagged cells crossed at least one current screening rule for |t|, |bias|, or tail probability.",
      "When the source bias table contains more than two facets, the heatmap keeps the largest absolute bias row for each first-two-facet cell and reports the number of collapsed rows.",
      "Use the heatmap for pattern recognition and follow-up; it does not upgrade screening statistics to confirmatory inference."
    ),
    stringsAsFactors = FALSE
  )
# From api-viewer.R:133
.mfrmr_table_mfrm_results_viewer_response_time_boundary_data <- data.frame(
    Area = c("Source", "Use", "Do not use as", "Next route"),
    Detail = c(
      "Response-time metadata supplied outside the fitted MFRM likelihood.",
      "Descriptive QC for rapid/slow timing patterns by event, person, facet, or score.",
      "A fitted speed parameter, joint speed-accuracy model, modified logit estimate, or automatic exclusion rule.",
      "Use response_time_review(), plot(..., draw = FALSE), and plot_data_components() for reusable timing QC tables."
    ),
    stringsAsFactors = FALSE
  )
# From help_compatibility_layer.R:706
.mfrmr_table_compatibility_alias_table_out <- data.frame(
    Alias = c(
      "mfrmRFacets",
      "analyze_dif",
      "mfrm_cluster_pam",
      "mfrm_response_imputations",
      "mfrm_response_imputations(impute)",
      "import_mirt_fit",
      "import_tam_fit",
      "import_erm_fit",
      "read_facets_fit_table",
      "mfrmr_interval_guide",
      "visual_reporting_template",
      "gpcm_capability_matrix",
      "mfrm_calibration_capabilities",
      "anchor_review",
      "precision_review",
      "keep_original",
      "JMLE",
      "ReadyForAPA",
      "SE",
      "Fair(M) Average",
      "Fair(Z) Average",
      "FairM",
      "FairZ"
    ),
    PreferredName = c(
      "run_mfrm_facets",
      "analyze_dff",
      "mfrm_cluster",
      "review_mfrm_imputations",
      "review_mfrm_imputations(impute_ids)",
      "import_irt_fit",
      "import_irt_fit",
      "import_irt_fit",
      "read_facets_results",
      "mfrmr_output_guide",
      "mfrmr_output_guide",
      "mfrmr_output_guide",
      "mfrmr_output_guide",
      "review_mfrm_anchors",
      "mfrm_report",
      "category_policy",
      "JML",
      "DraftReady",
      "ModelSE",
      "AdjustedAverage",
      "StandardizedAdjustedAverage",
      "AdjustedAverage",
      "StandardizedAdjustedAverage"
    ),
    Surface = c(
      "function",
      "function",
      "function",
      "function",
      "argument",
      "function",
      "function",
      "function",
      "function",
      "function",
      "function",
      "function",
      "function",
      "function",
      "function",
      "argument",
      "argument",
      "column",
      "column",
      "column",
      "column",
      "plot_metric",
      "plot_metric"
    ),
    Lifecycle = c(
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "removed_export",
      "retained_alias",
      "retained_alias",
      "retained_alias",
      "retained_alias",
      "retained_alias",
      "retained_alias",
      "retained_alias",
      "retained_alias"
    ),
    RetainedFor = c(
      "older workflow scripts",
      "earlier DIF-oriented package code",
      "earlier feature-clustering scripts and saved results",
      "earlier assigned-score imputation scripts and saved results",
      "event-ID selection in earlier imputation-review calls",
      "external mirt fit import scripts",
      "external TAM fit import scripts",
      "external eRm fit import scripts",
      "external FACETS fit-table import scripts",
      "confidence-interval route lookup scripts",
      "figure-reporting template lookup scripts",
      "GPCM workflow/score capability lookup scripts",
      "portable calibration capability lookup scripts",
      "fitted anchor-review field extraction",
      "diagnostics precision-review field extraction",
      "existing score-category policy in fitting and input review",
      "historical method labels",
      "older reporting scripts",
      "older measure-table scripts",
      "FACETS-style table continuity",
      "FACETS-style table continuity",
      "legacy plot metric shortcuts",
      "legacy plot metric shortcuts"
    ),
    RemovalPlan = c(
      "Removed in the 0.3.0 development series; use run_mfrm_facets().",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.",
      "No scheduled removal.",
      "No scheduled removal.",
      "No scheduled removal.",
      "No scheduled removal.",
      "No scheduled removal.",
      "No scheduled removal.",
      "No scheduled removal.",
      "No scheduled removal."
    ),
    Notes = c(
      "Use run_mfrm_facets(); the former workflow alias has been removed.",
      "Use analyze_dff(); the former DIF alias is no longer exported.",
      "Use mfrm_cluster(method = 'pam'); the underlying Gower/PAM result is unchanged.",
      "Same supplied-completion checks and result class; this function does not generate imputations.",
      "Use event-ID values in impute_ids, not a logical switch; the old wrapper is no longer exported.",
      "Use import_irt_fit(fit, model, ..., source = 'mirt') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.",
      "Use import_irt_fit(fit, model, ..., source = 'tam') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.",
      "Use import_irt_fit(fit, model, ..., source = 'erm') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.",
      "Use read_facets_results(file, ...) and pass it directly to facets_fit_review(fit, facets_fit = ...).",
      "Use mfrmr_output_guide('intervals', category); returned interval-guide table is unchanged.",
      "Use mfrmr_output_guide('visual_templates', category); returned figure-template table is unchanged.",
      "Use mfrmr_output_guide('gpcm_capabilities', status = ..., view = ...); returned GPCM capability matrix is unchanged.",
      "Use mfrmr_output_guide('calibration_capabilities'); returned portable-calibration capability matrix is unchanged.",
      "Read fit$config$anchor_review directly, or call review_mfrm_anchors() before fitting.",
      "Read diagnostics$precision_review directly, or call mfrm_report(type = 'precision', fit, diagnostics = diagnostics).",
      "In fit_mfrm(), describe_mfrm_data() and review_mfrm_anchors(): TRUE maps to preserve and FALSE to collapse. Defaults are unchanged; conflicting explicit choices fail.",
      "Accepted by fit wrappers, but user-facing summaries and docs use JML.",
      "Backward-compatible reporting flag; values match DraftReady exactly.",
      "Backward-compatible standard-error column; ModelSE is the preferred label.",
      "Legacy adjusted-average column retained alongside the native label.",
      "Legacy standardized adjusted-average column retained alongside the native label.",
      "Accepted by plot(x, type = \"fair_average\") as a shortcut for AdjustedAverage.",
      "Accepted by plot(x, type = \"fair_average\") as a shortcut for StandardizedAdjustedAverage."
    ),
    stringsAsFactors = FALSE
  )
# From help_facets_coverage.R:41
.mfrmr_table_facets_positioning_guide_data <- data.frame(
    Topic = c(
      "Estimation authority",
      "Compatibility purpose",
      "External FACETS comparison",
      "Current model and calibration boundary",
      "Reporting source of truth",
      "Extension beyond FACETS"
    ),
    Position = c(
      "mfrmr estimates are package-native; FACETS-style names do not mean that FACETS estimated the model.",
      "FACETS-style wrappers, table labels, and files support transition, handoff, and report organization, not optimizer-level reproduction.",
      "Numerical comparison requires an explicit external FACETS output table supplied by the user.",
      "Each fit uses one ordered-categorical response-model family and one observed score scale; nominal and count-response families, mixed families, multiple independent scales, general threshold anchors, and importing FACETS or third-party frozen calibrations are not current public capabilities. Native portable calibration follows the model, estimator and source-check scope in mfrmr_output_guide(\"calibration_capabilities\"), and posterior scoring from an existing fitted object is separate. Positive observation weights act on row-level conditional ordered-rating contributions; they are not a general collapsed-person frequency-table interface and do not change the response family.",
      "Inference and reporting should be based on native fit, diagnostics, review, table, and plot-data objects.",
      "GPCM, D-study, network, and reusable visualization data are extension routes rather than FACETS menu clones."
    ),
    RecommendedWording = c(
      "The model was estimated with mfrmr; FACETS-style output names are used only to organize the report.",
      "FACETS-style outputs were generated for handoff or reader familiarity; they are not evidence of FACETS numerical equivalence.",
      "When external FACETS output is supplied, compare MnSq first and report df/ZSTD convention sensitivity separately.",
      "Describe mfrmr as a native R RSM/PCM analysis, diagnostic, and reporting environment, not as a general FACETS operational-calibration replacement.",
      "Report estimates, standard errors, fit summaries, and plots from documented mfrmr objects.",
      "Use package-native extensions as additional evidence and label them as mfrmr analyses."
    ),
    PrimaryRoute = c(
      "fit_mfrm(); diagnose_mfrm(); mfrm_report(fit, type = 'checklist')",
      "facets_guide('coverage'); run_mfrm_facets(); facets_output_file_bundle()",
      "read_facets_results(); facets_fit_review(); fit_measures_table(df_sensitivity = TRUE)",
      "fit_mfrm(); facets_guide('coverage'); mfrmr_output_guide(\"all\")",
      "build_summary_table_bundle(); build_visual_summaries(); plot_data()",
      "mfrmr_output_guide(\"gpcm_capabilities\"); mfrm_g_study(); mfrm_d_study(); mfrm_d_study(); mfrm_network_analysis(); plot_data_components()"
    ),
    stringsAsFactors = FALSE
  )
# From help_facets_coverage.R:94
.mfrmr_table_facets_term_crosswalk_data <- data.frame(
    FACETSTerm = c(
      "Measure", "S.E.", "Infit MnSq", "Outfit MnSq", "ZSTD",
      "Rating Scale=", "Table 6 Wright/variable map", "Graphfile=",
      "Anchorfile=", "Positive="
    ),
    mfrmrTerm = c(
      "Estimate (logits)", "SE", "Infit", "Outfit", "InfitZSTD / OutfitZSTD",
      "model = \"RSM\" or \"PCM\"", "Wright map", "graph output table",
      "anchor table", "facet orientation"
    ),
    mfrmrRoute = c(
      "fit_measures_table(); summary(fit)",
      "fit_measures_table(); plot(fit, type = \"wright\", show_ci = TRUE)",
      "diagnose_mfrm(); fit_measures_table()",
      "diagnose_mfrm(); fit_measures_table()",
      "facets_guide('fit_df'); fit_measures_table(df_sensitivity = TRUE)",
      "fit_mfrm(model = \"RSM\" or \"PCM\")",
      "plot(x, type = \"wright\", view = \"unified\"); plot(fit, type = \"wright\")",
      "facets_output_file_bundle(include = \"graph\")",
      "make_anchor_table(); fit_mfrm(anchors = ...)",
      "fit_mfrm(positive_facets = ...); plot(x, type = \"wright\", view = \"unified\")"
    ),
    Relationship = c(
      "substantive counterpart", "substantive counterpart", "substantive counterpart",
      "substantive counterpart", "convention-sensitive counterpart",
      "model-setting crosswalk", "visual counterpart", "handoff-file counterpart",
      "input-table counterpart", "orientation convention"
    ),
    Boundary = c(
      "Numerical equality requires aligned model, estimator, identification, and supplied external FACETS output.",
      "SE bases differ by estimator and element type; inspect method metadata.",
      "Compare MnSq before standardized fit and document residual basis.",
      "Compare MnSq before standardized fit and document residual basis.",
      "df and Wilson-Hilferty conventions can change ZSTD without changing MnSq.",
      "The package exposes documented RSM/PCM and GPCM routes, not a FACETS command parser.",
      "FACETS-style rendering reproduces the ruler grammar, not optimizer-level numerical identity.",
      "CSV/TSV handoff is package-native rather than fixed-field FACETS syntax.",
      "The table is an R-native anchor contract, not a complete FACETS specification file.",
      "Always report which facets use the positive orientation."
    ),
    stringsAsFactors = FALSE
  )
# From help_facets_coverage.R:155
.mfrmr_table_facets_visual_contract_data <- data.frame(
    FACETSVisualSurface = c(
      "Table 6 asterisk Wright ruler",
      "Native Wright map with uncertainty",
      "Table 8 rating-scale structure",
      "Graphs: expected-score ICC/IRF",
      "Bond-Fox fit pathway",
      "DIF/bias visual review",
      "Graphfile and R/Web handoff"
    ),
    Status = c(
      "implemented_visual", "mfrmr_extension", "implemented",
      "implemented", "implemented_extension", "partial", "partial"
    ),
    FirstMfrmrRoute = c(
      "plot(fit, type = \"wright\", view = \"unified\", renderer = \"facets\")",
      "plot(fit, type = \"wright\", view = \"unified\", renderer = \"native\", show_ci = TRUE)",
      "rating_scale_table(); mfrm_report(fit, type = 'category_structure')",
      "plot(fit, type = \"pathway\")",
      "plot(fit, type = \"fit_pathway\", fit_stat = \"Infit\", include_person = TRUE, top_n_person = 12)",
      "plot(x, type = \"bias\")",
      "facets_output_file_bundle(); plot_data(); as_ggplot()"
    ),
    EditableDataRoute = c(
      "plot_data(..., renderer = \"facets\", component = \"facets_style\")$ruler_rows",
      "plot(..., draw = FALSE); plot_data(component = \"locations\")",
      "rating_scale_table(); plot_data()",
      "plot_data(type = \"pathway\")",
      "plot_data(type = \"fit_pathway\")",
      "plot_data(); mfrm_report(fit, type = 'bias_interaction')",
      "facets_output_file_bundle(); plot_data_components()"
    ),
    ClaimBoundary = c(
      "FACETS-style visual grammar; numerical comparison requires output from a documented FACETS version under aligned settings.",
      "The SE/CI display is an mfrmr extension and should be retained for uncertainty interpretation.",
      "Structured R output replaces FACETS line-printer artwork.",
      "This is expected score over theta, not a measure-versus-fit pathway map.",
      "This is a Bond-Fox-style mfrmr extension; it is not a standard FACETS Table 6 output.",
      "Screening display only; it is not a final fairness conclusion.",
      "Editable handoff is supported, but FACETS UI, Excel, and webpage behavior is not cloned."
    ),
    stringsAsFactors = FALSE
  )
# From help_gpcm_scope.R:478
.mfrmr_table_.gpcm_capability_registry_out <- data.frame(
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
      "optimization_replay",
      "portable_calibration",
      "multiple_slope_families",
      "corrected_jml_inference",
      "gpcm_em_fitting"
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
      "Native MCMC and posterior-predictive sampling",
      "Residual-bias screening under GPCM",
      "Score-side scorefile export under GPCM",
      "FACETS output-contract score-side review",
      "Replayed optimization diagnostics under GPCM",
      "Portable calibration and later-person scoring",
      "Simultaneous estimation of multiple slope families",
      "Formal structural confidence intervals for corrected JML",
      "GPCM fitting with EM or hybrid optimization"
    ),
    Helpers = c(
      "fit_mfrm(model = \"GPCM\"); summary(); print(); confint(parm = \"slopes\")",
      paste(
        "diagnose_mfrm(); analyze_residual_pca(); unexpected_response_table();",
        "displacement_table(); measurable_summary_table();",
        "rating_scale_table(); interrater_agreement_table();",
        "facet_quality_dashboard(); plot(x, type = \"qc\");",
        "plot(x, type = \"marginal_fit\"); plot(x, type = \"marginal_pairwise\")"
      ),
      "predict_mfrm_units(); sample_mfrm_plausible_values(); compute_information(); plot(x)",
      paste(
        "plot(fit, type = c(\"wright\", \"pathway\", \"ccc\", \"ccc_surface\"));",
        "mfrm_report(fit, type = 'category_structure'); mfrm_report(fit, type = 'category_curves');",
        "facets_output_file_bundle(include = \"graph\")"
      ),
      "mfrm_report(fit, type = 'checklist'); mfrm_report(fit, type = 'precision'); build_summary_table_bundle(); export_summary_appendix()",
      "build_misfit_casebook()",
      "compare_mfrm(); build_model_choice_review(); build_weighting_review(); compute_information(); plot(x); build_summary_table_bundle(); export_summary_appendix()",
      "build_linking_review()",
      "build_mfrm_sim_spec(); extract_mfrm_sim_spec(); simulate_mfrm_data(); simulate_mfrm_recovery(); assess_mfrm_recovery()",
      paste(
        "mfrm_results(include = \"gpcm_review\"); mfrm_report();",
        "export_mfrm_results(); build_apa_outputs(); build_visual_summaries();",
        "run_qc_pipeline(); build_mfrm_manifest(); build_mfrm_replay_script();",
        "export_mfrm_bundle()"
      ),
      "fair_average_table()",
      "evaluate_mfrm_design(); predict_mfrm_population()",
      "evaluate_mfrm_diagnostic_screening(); evaluate_mfrm_signal_detection()",
      "analyze_dff(); dif_interaction_table(); mfrm_report(dif, type = 'dff'); plot(x, type = \"heatmap\"); plot(x, type = \"summary\")",
      NA_character_,
      "estimate_all_bias(); estimate_bias(); summary(); plot(); unexpected_after_bias_table()",
      "facets_output_file_bundle(include = \"score\")",
      "facets_output_contract_review()",
      "mfrm_report(fit, type = 'iterations')",
      paste("mfrmr_output_guide(\"calibration_capabilities\"); extract_mfrm_calibration();",
        "save_mfrm_calibration(); load_mfrm_calibration(); score_mfrm_calibration()"),
      "fit_mfrm(); summary(); mfrm_curve_intervals(); mfrm_response_diagnostics(); predict_mfrm_units(); sample_mfrm_plausible_values(); extract_mfrm_calibration(); score_mfrm_calibration(); mfrm_results(); mfrm_report(); export_mfrm_results()",
      NA_character_,
      "fit_mfrm(mml_engine = 'em', slope_facet = c(first_owner, second_owner))"
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
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "deferred",
      "supported_with_caveat"
    ),
    Boundary = c(
      paste(
        "One slope family: requires an explicit step facet; MML allows a separate slope owner,",
        "whereas JML requires `slope_facet == step_facet`. MML direct is the default,",
        "and EM/hybrid fall back to direct. Free-slope fits retain numerical",
        "estimates for review. confint(fit, parm = \"slopes\") separately checks approximate MML intervals.",
        "Explicit options add standardized slopes, comparisons, sandwich covariance and Bonferroni adjustment;",
        "method = 'profile' supplies an experimental one-relative-slope nuisance profile within its separate scope;",
        "bootstrap_mfrm_gpcm() and mfrm_curve_intervals() supply bootstrap inference and curve uncertainty.",
        "These inference routes require MML; JML formal slope intervals are not implemented.",
        "mfrm_facet_intervals() separately supplies one-family MML location/contrast Wald intervals from full joint information under its identified regular-model assumptions; finite-sample coverage is not guaranteed.",
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
        "the fitted model and hold its non-Person parameters fixed. For JML this is post-hoc EAP",
        "with a default N(0,1) reference prior or explicit scoring_prior, not ML/WLE scoring.",
        "The prior is not a population distribution estimated by JML. This is",
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
        "This weighting helper requires the same slope/step owner; use compare_mfrm() for separate owners.",
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
        "same slope/step owner. Recovery checks are direct",
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
        "mfrmr does not run native GPCM MCMC or posterior-predictive sampling.",
        "export_mfrm_model() writes Stan/brms code for eligible one-family MML sources and Stan code for two-family sources, adding explicit structural priors and retaining supported fixed constraints.",
        "Conditional posterior response diagnostics are a different, non-MCMC calculation."
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
        "that bias has been removed. estimate_all_bias() collects eligible facet pairs and retains failed/unavailable results; it does not supply collection-wide multiplicity control."
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
      ),
      paste(
        "One slope family only. MML permits shared or separate slope/step owners with",
        "an estimated intercept-only normal population; JML requires shared owners",
        "and uses a declared post-hoc normal reference prior. Both require their",
        "source checks, unit weights, known levels and no anchors or interactions.",
        "Later-person EAP scores and posterior intervals condition on the saved",
        "calibration; they exclude its estimation uncertainty and bias and are not ML/WLE.",
        "Experimental corrected shared-owner JML uses distinct adjusted-equation checks and preserves the explicit correction order (file format 5)."
      ),
      paste(
        "Provisional fixed-grid EM or adaptive direct MML for exactly two fixed slope facets, with fixed N(0,1),",
        "unit weights, no anchors or population covariates and observed zero-based scores.",
        "The first family's slopes have geometric mean one; the second owns steps and has free slopes.",
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
        "Ordinary fit diagnostics and model ranking are not supported."
      ),
      paste(
        "Formal corrected-JML structural intervals are unavailable.",
        "The explicit corrected estimator reports local adjusted-equation RootSE, not established structural coverage.",
        "Uncorrected JML location SEs and post-hoc Person intervals answer different questions.",
        "None is a bias-corrected structural confidence interval."
      ),
      paste(
        "Two-family GPCM uses fixed-grid EM or adaptive direct MML with fixed-standard-normal identification.",
        "EM uses ascent-checked M steps and per-Person marginal-score stopping; adaptive direct MML uses reltol and optimizer gradient checks;",
        "numerical convergence does not establish inferential reliability.",
        "mml_integration = 'auto' preserves the selected engine and checks increasing rules within mml_accuracy_control = list(max_points = ...), including reference rules. Fixed integration remains the default; two-family direct fitting requires adaptive or auto.",
        "One-family EM/hybrid requests still use direct optimization and record that fallback.",
        "Adaptive EM and two-family hybrid fitting are not supported."
      )
    ),
    RecommendedRoute = c(
      paste(
        "Use `fit_mfrm(..., model = \"GPCM\", step_facet = ...,",
        "slope_facet = ...)` and inspect `summary(fit)`; separate owners require MML."
      ),
      paste(
        "Use diagnostics as screening evidence and return to direct residual,",
        "unexpected-response, displacement, and category tables before writing claims."
      ),
      paste(
        "Use fitted-object posterior scoring and `compute_information()` /",
        "`plot(x)`; keep portable calibration and population",
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
        "`simulate_mfrm_recovery()`."
      ),
      paste(
        "Use `evaluate_mfrm_diagnostic_screening(..., model = \"GPCM\",",
        "step_facet = ..., slope_facet = step_facet)` or",
        "`evaluate_mfrm_signal_detection()` for caveated slope-aware screening",
        "operating-characteristic review; inspect `gpcm_boundary` and keep",
        "operational screening decisions outside this route."
      ),
      paste(
        "Use `analyze_dff()` and `dif_interaction_table()`",
        "as screening surfaces, then carry `gpcm_boundary` through",
        "`summary()`, `mfrm_report(dif, type = 'dff')`, `plot(x, type = \"heatmap\")`, and",
        "`plot(x, type = \"summary\")` before writing claims."
      ),
      paste(
        "Use MML and conditional posterior scoring for their stated targets.",
        "Use export_mfrm_model(format = 'stan' or 'brms') for eligible one-family sources, or format = 'stan' for two-family sources. Then review priors, sampler diagnostics and posterior fit; code export is not native Bayesian estimation."
      ),
      paste(
        "Use `estimate_all_bias()` for exploratory pairs or `estimate_bias()` for one specified pair; use `unexpected_after_bias_table()` only",
        "for a descriptive before/after flag comparison, then confirm important",
        "patterns with substantive facet-pair review or external validation."
      ),
      paste(
        "Use `facets_output_file_bundle(include = \"score\")` for a",
        "package-native GPCM scorefile with explicit caveat columns;",
        "inspect `mfrmr_output_guide(\"gpcm_capabilities\", view = \"scores\")`, and do not treat it as",
        "FACETS score-side equivalence."
      ),
      paste(
        "Use direct fair-average tables and graph-only compatibility outputs;",
        "use package-native scorefile export with its stated caveats, and keep",
        "full FACETS output-contract reviews on the `RSM` / `PCM` route."
      ),
      paste(
        "Use `summary(fit, profile = \"fit\", detail = \"brief\")` for the",
        "recorded convergence result. Use `mfrm_report(fit, type = 'iterations')` only",
        "to inspect a reconstructed trajectory and label it as replayed."
      ),
      paste(
        "Check mfrmr_output_guide(\"calibration_capabilities\"), then extract, save, load and score",
        "with the existing calibration workflow; review the scoring prior and each batch's numerical checks."
      ),
      paste(
        "See the Two slope families section of fit_mfrm() for explicit owners and fitting settings;",
        "use summary(fit), mfrm_curve_intervals(fit, newdata) and saved fit/plot results with compute = 'never'."
      ),
      paste(
        "Use current JML outputs within their descriptive scope, or explicitly choose",
        "MML inference if its population assumptions suit the analysis; do not transfer MML intervals to JML."
      ),
      paste(
        "Use direct MML for one-family GPCM; two families permit fixed-grid EM or adaptive direct MML;",
        "inspect the actual engine and ConvergenceBasis in summary(fit)."
      )
    ),
    stringsAsFactors = FALSE
  )
# From help_gpcm_scope.R:893
.mfrmr_table_.gpcm_capability_registry_data <- data.frame(
    CapabilityID="corrected_jml_estimation",
    Area="Experimental corrected JML estimates and saved output",
    Helpers="fit_mfrm(jml_correction_order = ...); summary(); mfrm_response_diagnostics(); predict_mfrm_units(); extract_mfrm_calibration(); score_mfrm_calibration(); plot(); mfrm_results(); mfrm_report(); export_mfrm_results()",
    Status="supported_with_caveat",
    Boundary=paste("Shared-owner GPCM JML with an explicit positive order, declared categories, unit-weight observed ratings and centered fixed facets.",
      "No anchors, interactions or automatic order selection. RootSE describes local adjusted-equation variation; residual bias may remain.",
      "Point estimates survive covariance failure. Conditional observed-row probabilities and descriptive residual summaries hold corrected calibration and Person profiles fixed; no fit cutoffs or rater-quality classifications.",
      "Conditional new-Person/portable EAP uses distinct adjusted-equation checks and a separate normal prior; calibration uncertainty and residual bias are not propagated.",
      "Ordinary fit tests, structural intervals, likelihood ranking and corrected Person ML/WLE remain unavailable."),
    RecommendedRoute="Read the Corrected JML section of fit_mfrm(); inspect summary(fit)$tables, then collect mfrm_results(fit).",
    stringsAsFactors=FALSE)
# From help_gpcm_scope.R:949
.mfrmr_table_.gpcm_score_side_contract_registry_data <- data.frame(
    # These selectors preserve calls accepted before the public status names
    # were simplified. They are not returned by gpcm_capability_matrix(view = 'scores').
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
# From help_reports_and_tables.R:473
.mfrmr_table_mfrmr_output_guide_out <- data.frame(
    Scope = c(
      "reports", "reports", "reviews", "reviews", "reports", "tables", "reviews",
      "reviews", "reviews", "bundles", "reports", "exports", "compatibility"
    ),
    Question = c(
      "Document the model setup and run settings",
      "Check whether data were filtered, dropped, or remapped",
      "Review response-time metadata as descriptive QC context",
      "Decide how strongly precision claims can be phrased",
      "Summarize facet variability, separation, and measurability",
      "Review category functioning and expected-score curves",
      "Screen bias, DFF, or interaction evidence",
      "Review anchors, drift, and linking readiness",
      "Compare equal-weighting and GPCM routes",
      "Turn summaries into reusable appendix tables",
      "Assemble manuscript-oriented narrative output",
      "Write files for appendix, replay, or handoff",
      "Serve a legacy-compatible downstream layout"
    ),
    OutputFamily = c(
      "report", "report", "review", "review", "report", "table", "review",
      "review", "review", "bundle", "bundle", "export", "compatibility"
    ),
    MainFunction = c(
      "mfrm_report(fit, type = 'specifications')",
      "mfrm_report(fit, type = 'data_quality')",
      "response_time_review(); mfrm_results(include = \"response_time\", response_time = ...); plot(timing); plot_data_components()",
      "mfrm_report(fit, type = 'precision')",
      "mfrm_report(fit, type = 'facet_statistics')",
      "rating_scale_table(); mfrm_report(fit, type = 'category_structure'); mfrm_report(fit, type = 'category_curves')",
      "estimate_all_bias(); estimate_bias() -> mfrm_report(); analyze_dff(); mfrm_report(fit, type = 'bias_interaction')",
      "review_mfrm_anchors() -> mfrm_report(); detect_anchor_drift(); build_linking_review() -> mfrm_report()",
      "build_model_choice_review() -> mfrm_report(); build_weighting_review(); compare_mfrm()",
      "build_summary_table_bundle()",
      "mfrm_report(); mfrm_report(fit, type = 'checklist'); build_apa_outputs()",
      "export_mfrm_results(); export_summary_appendix(); export_mfrm_bundle(); build_mfrm_manifest()",
      "run_mfrm_facets(); facets_output_file_bundle(); facets_output_contract_review()"
    ),
    UseWhen = c(
      "You need methods-section settings or reproducibility context.",
      "You need to explain retained rows, missing values, or unknown elements.",
      "You have event-level timing metadata and need rapid/slow-response screening outside the fitted MFRM likelihood.",
      "You need to separate model-based, hybrid, and exploratory precision evidence.",
      "You need facet-level reporting before writing interpretation.",
      "You need category diagnostics or curve data for figures.",
      "You need screening evidence for follow-up fairness or interaction review.",
      "You need operational scale-maintenance checks for RSM/PCM workflows.",
      "You need to review whether discrimination-based reweighting changes conclusions.",
      "You need named data.frame outputs for appendix or handoff.",
      "You need manuscript text, captions, notes, and section maps.",
      "You need files on disk rather than R objects.",
      "You need a fixed-width, graphfile, scorefile, or contract-check layout."
    ),
    TypicalInput = c(
      "mfrm_fit",
      "mfrm_fit plus optional raw data",
      "long-format rating-event data with person, time, and optional facet/score columns",
      "mfrm_fit plus mfrm_diagnostics",
      "mfrm_fit plus mfrm_diagnostics",
      "mfrm_fit",
      "mfrm_fit plus optional diagnostics/grouping",
      "anchor tables, drift results, or equating chain objects",
      "two or more fitted candidate models",
      "summary(), review, recovery, prediction, or checklist objects",
      "mfrm_results, G/D-study, network results, bias estimates or anchor/linking/model-choice reviews; fit plus diagnostics for build_apa_outputs()",
      "summary-table bundle, manifest, or fitted analysis bundle",
      "mfrm_fit or run_mfrm_facets() output"
    ),
    NextStep = c(
      "Read summary rows before adding interpretation.",
      "Inspect row-level reasons before reporting exclusions.",
      "Inspect thresholds, grouped summaries, summary(res)$next_actions, and draw-free plot data before deciding whether a separate QC note is needed.",
      "Use the status mix to decide wording strength.",
      "Use plots or summary-table bundles for presentation.",
      "Use plot helpers or export curve tables.",
      "Use estimate_all_bias() for an exploratory overview of eligible facet pairs, then summary(screens) and plot(screens). Use estimate_bias() for a specified pair; analyze_dff() answers a separate subgroup question.",
      "Use operational linking synthesis for RSM/PCM; keep GPCM linking review caveated and exploratory.",
      "Report GPCM fit gains as sensitivity evidence, not automatic scoring policy.",
      "Use apa_table() or export_summary_appendix().",
      "Use mfrm_report() on the supported saved result; add study_context for score meaning. For a fit, first call mfrm_results(fit). Copy assessment-review.Rmd for anchor/bias/model-choice modules.",
      "Check written_files and available_outputs before sharing.",
      "Prefer package-native routes unless a downstream tool requires this layout."
    ),
    GPCMStatus = c(
      "supported",
      "supported",
      "supported",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat; exploratory_gpcm_linking_review",
      "supported_with_caveat",
      "supported_for_direct_outputs",
      "supported_with_caveat",
      "summary_appendix_supported; fit_bundle_supported_with_caveat",
      "graph_only_or_blocked_by_score_side_semantics"
    ),
    Notes = c(
      "Best first report object when methods documentation is the goal.",
      "Pairs naturally with describe_mfrm_data().",
      "Timing summaries are descriptive QC only; they do not alter MFRM estimates, fit speed-accuracy models, estimate speed parameters, or define exclusion rules.",
      "Use before formal confidence or reliability language.",
      "Good bridge from diagnostics to report text.",
      "Category curves carry reusable plot data.",
      "Conditional exploratory screens, with no collection-wide multiplicity control. Retain failed pairs and unavailable cells; missing screens are not evidence of no bias. Save the complete collection with saveRDS().",
      "Operational linking conclusions remain RSM/PCM-scoped; GPCM review is caveated exploratory synthesis.",
      "Use with mfrmr_output_guide(\"gpcm_capabilities\").",
      "Works for several object classes; inspect table_index.",
      "mfrm_report() retains each supported domain's evidence and limits; declarations do not recode scores or validate claims. GPCM APA text retains its capability boundary.",
      "Use export_mfrm_results() for controlled mfrm_results analysis archives; it does not deidentify files. Choose the narrowest route needed for review and keep gpcm_boundary with GPCM bundles.",
      "Compatibility is a presentation contract, not numerical equivalence."
    ),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:590
.mfrmr_table_mfrmr_output_guide_core_workflow_rows <- data.frame(
    Scope = rep("core_workflow", 5L),
    Question = c(
      "Inspect rating design, connectedness, and score categories",
      "Fit the measurement model with shared spec and optional control",
      "Diagnose model fit, precision, local dependence, and rater patterns",
      "Partition observed-score variance and project future rating plans",
      "Assemble reports and unified ggplot2 figures"
    ),
    OutputFamily = c("entry", "entry", "review", "review", "report"),
    MainFunction = c(
      "spec <- list(person = \"Person\", facets = c(\"Rater\", \"Criterion\"), score = \"Score\", rating_min = 1, rating_max = 4, category_policy = \"preserve\"); describe_mfrm_data(data, spec = spec)",
      "fit <- fit_mfrm(data, spec = spec, model = \"RSM\", method = \"MML\", control = list(quad_points = 15)); summary(fit)",
      "diag <- diagnose_mfrm(fit, diagnostic_mode = \"both\"); summary(diag)",
      "g <- mfrm_g_study(data, person = \"Person\", facets = c(\"Rater\", \"Criterion\"), score = \"Score\"); d <- mfrm_d_study(g, plans = data.frame(Rater = c(2, 3), Criterion = c(4, 4)))",
      "res <- mfrm_results(fit, diagnostics = diag); report <- mfrm_report(res); plot(fit); plot_data(plot(fit, draw = FALSE), \"notes\")"
    ),
    UseWhen = c(
      "Before fitting: verify long-format column roles, observed versus intended categories, missing codes, and rater-criterion connectivity.",
      "You are ready to calibrate RSM, PCM, or GPCM under MML, JML, or CML using either core arguments or a reusable spec list.",
      "A fitted ordinary RSM/PCM or one-family GPCM model needs fit, separation, marginal-fit, and rater-agreement checks before interpretation.",
      "You want observed-score generalizability and dependability projections across alternative numbers of raters or tasks.",
      "You have reviewed model readiness and want reader-facing summaries, APA handoff tables, or publication-ready ggplot2 figures."
    ),
    TypicalInput = c(
      "long-format data.frame and explicit column/rubric spec",
      "long-format data.frame, spec list (or core arguments), and optional control list",
      "mfrm_fit",
      "long-format observed rating data and candidate D-study plans",
      "mfrm_fit / mfrm_diagnostics / mfrm_results"
    ),
    NextStep = c(
      "Check zero-count categories and disconnected subsets; add review_mfrm_anchors(data, spec = spec) when linking across waves.",
      "Read summary(fit)$decision before interpreting estimates; see ?fit_mfrm_technical_details for specialist identification and control options.",
      "Inspect Infit/Outfit, marginal-fit screens, and mfrm_report(type = 'precision', fit, diagnostics = diag); add analyze_dff() or estimate_bias() when needed.",
      "Inspect IdentificationStatus, GStatus, and PhiStatus alongside plot(d, type = \"error_components\") before selecting a plan.",
      "Read summary(report, view = \"reader\") and retain figure notes from plot_data(p, \"notes\"); save res with saveRDS()."
    ),
    GPCMStatus = c(
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "not_applicable",
      "summary_appendix_supported; fit_bundle_supported_with_caveat"
    ),
    Notes = c(
      "Data description checks design support without fitting a model; the same spec list can be reused in review_mfrm_anchors(), fit_mfrm(), and export_mfrm_model().",
      "This example fits ordinary RSM/PCM MML. Other estimators and models have their own supported diagnostics and result methods; G-theory planning is a separate analysis.",
      "Legacy residual/EAP fit and marginal-fit screens answer complementary questions; rater separation measures severity spread, not agreement.",
      "Observed-score G/D studies use ratings directly and require no MFRM fit. They estimate variance components on the rating scale, not latent-logit MFRM separation.",
      "Reports and ggplot2 figures organize existing evidence and cautions; they do not recompute or strengthen statistical identification."
    ),
    stringsAsFactors = FALSE
  )
.mfrmr_table_mfrmr_output_guide_public_rows <- data.frame(
    Scope = rep("public", 6L),
    Question = c(
      "1. Check your rating data and fit the model",
      "2. Read the fit summary and its recommended next step",
      "3. Review estimates, fit and precision",
      "4. Plot abilities and facet estimates with uncertainty",
      "5. Add other maps when they answer your question",
      "6. Read the report and save the reviewed results"
    ),
    OutputFamily = c("entry", "entry", "entry", "plot-data", "plot-data", "export"),
    MainFunction = c(
      paste0(
        "spec <- list(person = ..., facets = ..., score = ..., rating_min = ..., rating_max = ..., category_policy = \"preserve\"); ",
        "describe_mfrm_data(data, spec = spec); ",
        "fit <- fit_mfrm(data, spec = spec, method = \"MML\", model = \"RSM\")"
      ),
      "summary(fit, profile = \"fit\", detail = \"brief\")",
      "res <- mfrm_results(fit); summary(res)",
      "plot(res, type = \"wright\", renderer = \"native\", show_ci = TRUE, top_n = Inf, preset = \"publication\")",
      paste0(
        "fit$prep$score_map; ",
        "plot(res, type = \"wright\", renderer = \"facets\", category_labels = rubric_labels, show_ci = FALSE); ",
        "plot(res, type = \"fit_pathway\", fit_stat = \"Infit\", include_person = TRUE, person_labels = \"none\")"
      ),
      "report <- mfrm_report(res); summary(report, view = \"reader\"); export_mfrm_results(res, preset = \"starter\")"
    ),
    UseWhen = c(
      "You can name the person, facet, and ordered-score columns and confirm the intended rubric support in long-format data.",
      "The fit has completed and you need a fast check before computing diagnostic sections.",
      "The fitted model is ready for an organized first review of measures, fit, precision, and category steps.",
      "You want to compare person abilities, rater severities and criterion difficulties on the fitted logit scale.",
      "FACETS-style reading, rubric-labelled transitions, or person-inclusive fit review will help answer a focused question.",
      "You have reviewed the estimates, diagnostics and limitations and want a report or files to save."
    ),
    TypicalInput = c(
      "long-format data.frame, explicit column roles, and intended score support",
      "mfrm_fit",
      "mfrm_fit",
      "mfrm_results from mfrm_results(fit)",
      "mfrm_results plus study-specific rubric labels",
      "mfrm_results"
    ),
    NextStep = c(
      "Review retained/missing categories and the score map, then run the lightweight fit profile and confirm convergence.",
      "If the fit is usable, collect res <- mfrm_results(fit); otherwise resolve convergence or data issues first.",
      "Read summary(res)$triage and $next_actions; use $plot_map to choose optional figures, or save res directly.",
      "Inspect targeting, facet uncertainty, and every retained step; keep this figure with the analysis record.",
      "Use rubric labels from the actual instrument and treat person points as case-review prompts, not exclusion decisions.",
      "Read the report summary before export and keep replay plus data-handling metadata with every controlled analysis archive."
    ),
    GPCMStatus = c(
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "summary_appendix_supported; fit_bundle_supported_with_caveat"
    ),
    Notes = c(
      "This beginner route starts with ordinary RSM/PCM. Reuse one explicit spec list across describe_mfrm_data(), review_mfrm_anchors(), fit_mfrm(), and export_mfrm_model() (or pass core arguments directly); do not rely on automatic data-frame role inference. For a map of optional analysis branches, including G-theory planning, use mfrmr_output_guide(\"core_workflow\"). For GPCM or corrected JML, consult mfrmr_output_guide(\"gpcm_capabilities\") and online GPCM scope guide (https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-gpcm-scope.html) before diagnostics or maps.",
      "This fit-only profile is intentionally lightweight and does not compute the comprehensive diagnostic sections.",
      "The collector computes missing requested diagnostics by default. Supply existing diagnostics to reuse them, or compute = 'never' to leave absent sections unavailable. No FACETS software is required.",
      "The native map displays facet uncertainty. Choose figures for your question; plotting does not establish fit or precision.",
      "The closest FACETS-style renderer uses show_ci = FALSE; show_ci = TRUE is a deliberate hybrid that adds mfrmr uncertainty intervals. The Infit pathway adds persons only when explicitly requested.",
      "Reporting and export organize existing evidence; they do not improve model fit or create an automatic acceptance rule."
    ),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:659
.mfrmr_table_mfrmr_output_guide_calibration_rows <- data.frame(
    Scope = rep("calibration", 5L),
    Question = c(
      "Check whether a fitted route can create a portable calibration",
      "Extract, review, validate, and freeze an eligible calibration",
      "Save and load the reviewed calibration artifact",
      "Score new Persons from the frozen artifact without the source fit",
      "Review score dispositions, conditional uncertainty, and numerical edge flags"
    ),
    OutputFamily = c("guide", "review", "export", "review", "review"),
    MainFunction = c(
      "mfrmr_output_guide(\"calibration_capabilities\")",
      paste0(
        "mml_quadrature_sensitivity(); extract_mfrm_calibration(); ",
        "review_mfrm_calibration(); ",
        "update(calibration, status = 'validated'); update(calibration, status = 'frozen')"
      ),
      "save_mfrm_calibration(); load_mfrm_calibration()",
      "score_mfrm_calibration()",
      "summary(scores); plot(scores, type = \"interval\")"
    ),
    UseWhen = c(
      "You need to distinguish the narrow portable-artifact envelope from fitted-object scoring.",
      "A one-scale RSM/PCM MML fit has reviewed fixed-standard-normal grid movement; one-family estimated-normal or experimental two-family fixed-standard-normal GPCM MML passes its source checks; RSM/PCM or shared-owner GPCM JML passes its estimator-specific checks.",
      "A frozen artifact must move to a separate scoring session or controlled storage location.",
      "New response rows use only known facet levels and the calibration's recorded score map.",
      "A score batch must be reviewed before estimates are used in reporting or decisions."
    ),
    TypicalInput = c(
      "none",
      "eligible mfrm_fit; RSM/PCM MML additionally require mfrm_quadrature_sensitivity",
      "validated or frozen mfrm_calibration and an .rds path",
      "frozen mfrm_calibration plus new response rows",
      "mfrm_calibration_score"
    ),
    NextStep = c(
      "Use an available portable row or follow its fitted-object alternative.",
      "For RSM/PCM MML inspect grid movement and select its highest-grid fit; GPCM and RSM/PCM JML extraction evaluate their source checks. Resolve every refusal before freezing.",
      "Load the artifact in the scoring session and retain its calibration identity with outputs.",
      "Review row and Person dispositions before using posterior EAP estimates.",
      "Inspect every scored_review or not_scored Person and retain the interval-basis note with exported results."
    ),
    GPCMStatus = c(
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat"
    ),
    Notes = c(
      "The matrix is authoritative for portable artifacts and does not narrow fitted-object capabilities.",
      "RSM/PCM MML preserve supported facet anchors; GPCM currently requires unit weights and no anchors or interactions. JML has the same weight/structure restrictions and adds a reference prior for EAP; GPCM JML requires shared owners. Source checks do not certify population transport.",
      "Loading validates schema and semantics but does not authenticate untrusted files.",
      "Intervals are conditional on the frozen point calibration and exclude calibration-parameter uncertainty.",
      "Retain scores with saveRDS() and export score/disposition tables to CSV. These plots review the new batch; mfrm_report() describes the training mfrm_results object, not a portable score batch. Neither route establishes validity."
    ),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:718
.mfrmr_table_mfrmr_output_guide_entry_rows <- data.frame(
    Scope = c("entry", "entry", "entry", "entry", "entry"),
    Question = c(
      "Start with explicit model roles and a comprehensive first screen",
      "Open a FACETS-style result surface from an existing fit",
      "Browse the comprehensive result in a local Shiny viewer",
      "Choose the next purpose-specific helper without scanning the namespace",
      "Use column-selection prompts for exploratory data-frame input"
    ),
    OutputFamily = c("entry", "entry", "viewer", "guide", "entry"),
    MainFunction = c(
      "fit_mfrm(); diagnose_mfrm(); mfrm_results()",
      "mfrm_results()",
      "res <- mfrm_results(fit); launch_mfrmr_viewer(res)",
      "mfrmr_output_guide(\"all\"); summary(res)$next_actions",
      "mfrm_results_interactive()"
    ),
    UseWhen = c(
      "You are writing a script, Quarto document, or reproducible analysis and can name person, facet, and score columns.",
      "You already have an mfrm_fit or run_mfrm_facets() object and want fit, diagnostics, table coverage, plot routes, and next actions together.",
      "You want a local point-and-click reader for triage, QC, report text, bias screens, pathway/misfit review, tables, plots, and replay code after creating mfrm_results().",
      "You need to move from the first screen into reporting, review, export, compatibility, network, or simulation routes.",
      "You are exploring an unfamiliar data frame at the console and explicitly want prompts."
    ),
    TypicalInput = c(
      "long-format data.frame",
      "mfrm_fit, mfrm_facets_run, or conservative standard data.frame",
      "mfrm_results",
      "scope label or mfrm_results summary",
      "interactive long-format data.frame"
    ),
    NextStep = c(
      "Read summary(res), then use plot(res, type = \"qc\") and summary(res)$next_actions.",
      "Inspect summary(res)$status before treating unavailable sections as evidence.",
      "Install optional shiny support if needed; use the Replay tab output in scripts and reports, and make explicit follow-up choices for bias interaction review.",
      "Filter this guide by scope such as \"reviews\", \"reports\", \"exports\", \"facets\", or \"r\".",
      "Copy the printed replay code into a script before using the result in a report."
    ),
    GPCMStatus = c(
      "supported_with_caveat",
      "supported_with_caveat",
      "viewer_only_uses_existing_results",
      "supported",
      "supported_with_caveat"
    ),
    Notes = c(
      "Preferred route for new work: explicit fit first, then comprehensive results.",
      "mfrm_results() is a results surface over existing estimators, diagnostics, and table/report helpers.",
      "The viewer does not fit models or change diagnostics; it reads the supplied mfrm_results object and shows follow-up routes when a section is absent.",
      "Use this table as the public API map rather than memorizing every helper name.",
      "Interactive selection is deliberately opt-in and stops in non-interactive sessions."
    ),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:773
.mfrmr_table_mfrmr_output_guide_viewer_rows <- data.frame(
    Scope = rep("viewer", 7L),
    Question = c(
      "Open the standard first-screen viewer",
      "Prepare publication-oriented viewer sections",
      "Check validation, fit, and separation surfaces before reporting",
      "Inspect bias-screen prompts without choosing contrasts automatically",
      "Inspect pathway-map and row-level misfit prompts",
      "Inspect anchor and linking readiness",
      "Prepare a broad reviewer-facing viewer object"
    ),
    OutputFamily = rep("viewer", 7L),
    MainFunction = c(
      "res <- mfrm_results(fit, include = \"standard\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = \"publication\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = \"validation\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = \"bias\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = \"misfit_review\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = \"linking\"); launch_mfrmr_viewer(res)",
      "res <- mfrm_results(fit, include = c(\"publication\", \"bias\", \"misfit_review\", \"linking\")); launch_mfrmr_viewer(res)"
    ),
    UseWhen = c(
      "You want a local reader for overview, triage, status, QC, tables, plot routes, and replay code.",
      "You want APA-style draft text, table notes, figure notes, and reporting tables visible in the viewer.",
      "You want fit, precision, reliability, and FACETS-style review surfaces visible before making manuscript claims.",
      "You want facet-level bias-screen guidance while keeping interaction-bias facet-pair selection explicit in code.",
      "You want pathway-map annotations, unexpected-response rows, and displacement prompts in one inspection surface.",
      "You want anchor-readiness status and anchor plots visible before moving to explicit drift or equating checks.",
      "You are preparing a QC or review meeting and want the main publication, bias-screen, misfit-review, and linking-readiness surfaces together."
    ),
    TypicalInput = rep("mfrm_fit or mfrm_results", 7L),
    NextStep = c(
      "Read the Overview and Status tabs first; then use Tables, Plots, and Replay for drill-down.",
      "Treat report text as a draft template and reconcile it with the fitted model, diagnostics, and study design.",
      "Use precision and separation evidence as reporting context, not as automatic pass/fail criteria.",
      "Choose the substantive facet pair explicitly before running mfrm_report(fit, type = 'bias_interaction') or mfrm_report(bias, type = 'bias_pairwise').",
      "Treat unexpected rows as case-review prompts; document any exclusion or adjudication rule outside the viewer.",
      "Use detect_anchor_drift() or build_equating_chain() only after assembling an explicit list of fitted waves or forms.",
      "Use the Replay tab to move final choices back into an explicit script or Quarto document."
    ),
    GPCMStatus = c(
      "viewer_only_uses_existing_results",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "anchor_readiness_supported; exploratory_linking_review_supported_with_caveat",
      "viewer_only_uses_existing_results"
    ),
    Notes = c(
      "The viewer reads a completed mfrm_results object; it does not estimate or change diagnostics.",
      "For GPCM, publication viewer sections can show direct outputs, caveated APA text, and gpcm_boundary.",
      "This route is a display layer over existing validation and fit/separation helpers.",
      "Bias screens are follow-up prompts, not fairness conclusions.",
      "Pathway and unexpected-response displays help locate cases; they do not decide whether observations are invalid.",
      "The first-screen viewer does not infer drift from a single fitted model.",
      "Do not use the viewer as the only analysis record; keep the replayed mfrm_results() call in source control or the report source."
    ),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:834
.mfrmr_table_mfrmr_output_guide_binary_rows <- data.frame(
    Scope = c("binary", "binary", "binary"),
    Question = c(
      "Fit ordinary person-item binary responses",
      "Confirm the two-category score support",
      "Open the first-screen results for a binary Rasch run"
    ),
    OutputFamily = c("entry", "guide", "entry"),
    MainFunction = c(
      "fit_mfrm(data, person = ..., facets = \"Item\", score = ..., model = \"RSM\"); mfrm_results()",
      "describe_mfrm_data(); fit$prep$score_map; summary(fit)$settings_overview",
      "mfrm_results(fit); plot(res, type = \"wright\"); plot(res, type = \"qc\")"
    ),
    UseWhen = c(
      "The data have one person column, one item column, and ordered binary scores such as 0/1 or 1/2.",
      "Score codes may not start at zero, boundary categories may be unobserved, or you need to document the internal score map.",
      "You want the same comprehensive first screen used for rating-scale MFRM fits."
    ),
    TypicalInput = c(
      "long-format binary response data",
      "raw data or mfrm_fit",
      "mfrm_fit"
    ),
    NextStep = c(
      "Do not include the person column again in facets; pass the item column as the non-person facet.",
      "Check that fit$summary$Categories is 2. Set rating_min/rating_max only when the intended response scale includes unobserved boundary categories.",
      "Read summary(res)$triage and summary(res)$next_actions before moving to fit, category, bias, or reporting helpers."
    ),
    GPCMStatus = c(
      "rsm_recommended_for_ordinary_binary",
      "supported",
      "supported_with_caveat"
    ),
    Notes = c(
      "With two ordered categories, the RSM branch reduces to the usual binary Rasch logit up to package centering and threshold identification.",
      "Binary 1/2 input is still binary; the observed range and score mapping are recorded in prep metadata.",
      "Binary runs use the same diagnostics and plotting routes, but category-threshold interpretation has only one boundary."
    ),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:875
.mfrmr_table_mfrmr_output_guide_linking_rows <- data.frame(
    Scope = c("linking", "linking", "linking", "linking"),
    Question = c(
      "Open first-screen anchor and linking readiness from an existing fit",
      "Review intended anchor and group-anchor tables before fitting",
      "Check drift across separately fitted waves or forms",
      "Build a screened equating chain across ordered calibrations"
    ),
    OutputFamily = c("review", "review", "review", "review"),
    MainFunction = c(
      "mfrm_results(fit, include = \"linking\"); plot(res, type = \"anchors\")",
      "make_anchor_table(); review_mfrm_anchors(); fit_mfrm(anchors = ..., group_anchors = ...)",
      "detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2)); build_linking_review(drift = ...); plot(x)",
      "build_equating_chain(list(Form1 = fit1, Form2 = fit2)); build_linking_review(chain = ...); plot(type = \"chain\")"
    ),
    UseWhen = c(
      "You already have an mfrm_fit and want the stored anchor-review evidence in the comprehensive results surface.",
      "You are preparing fixed anchors or group anchors and need to catch overlap, duplicate, missing, sparse, or unsupported anchor rows before estimation.",
      "You have two or more independently fitted waves and need common-element drift and thin-link support checks.",
      "You have an ordered sequence of forms or administrations and need screened adjacent-link offsets before operational score-scale maintenance."
    ),
    TypicalInput = c(
      "mfrm_fit",
      "raw long-format data plus anchor/group-anchor tables",
      "named list of mfrm_fit objects",
      "ordered named list of mfrm_fit objects"
    ),
    NextStep = c(
      "Use summary(res$components$linking_review), plot(res, type = \"anchors\"), and build_summary_table_bundle(res$components$linking_review).",
      "Resolve issue_counts and recommendations before fitting the anchored model.",
      "Inspect common_by_facet and flagged drift rows before treating fitted waves as comparable.",
      "Inspect link support and residual spread before using cumulative offsets operationally."
    ),
    GPCMStatus = c(
      "anchor_readiness_supported; exploratory_linking_review_supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat; exploratory_gpcm_linking_review",
      "supported_with_caveat; exploratory_gpcm_linking_review"
    ),
    Notes = c(
      "The first-screen route does not infer drift from one fit; it makes the anchor-readiness evidence visible and routes users to multi-fit checks.",
      "Pre-fit anchor review is a data/design check, not a proof that anchored estimates are valid.",
      "Drift review removes common-element link offsets before flagging residual drift.",
      "The equating chain is a screened practical aid, not a full general-purpose equating framework."
    ),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:923
.mfrmr_table_mfrmr_output_guide_advanced_rows <- data.frame(
    Scope = c("simulation", "simulation", "simulation", "simulation", "network", "network"),
    Question = c(
      "Generate planned, sparse, or peer-review response data",
      "Evaluate design and recovery operating behavior",
      "Screen diagnostic behavior under misspecification scenarios",
      "Export simulation operating-characteristic tables for appendices",
      "Review co-observation connectivity as design evidence",
      "Review peer-review assignment topology"
    ),
    OutputFamily = c("simulation", "review", "simulation", "export", "review", "review"),
    MainFunction = c(
      "build_mfrm_sim_spec(); simulate_mfrm_data(); extract_mfrm_sim_spec()",
      "evaluate_mfrm_design(); simulate_mfrm_recovery(); assess_mfrm_recovery()",
      "evaluate_mfrm_diagnostic_screening(); summary(); plot(..., draw = FALSE); plot_data()",
      "summary(diag_eval); build_summary_table_bundle(diag_eval); export_summary_appendix(diag_eval)",
      "mfrm_network_analysis(); build_mfrm_network_review()",
      "build_peer_review_sim_spec(); review_peer_design(); build_mfrm_network_review(peer_review_design = ...)"
    ),
    UseWhen = c(
      "You need synthetic rating data with documented generator settings, sparse linked assignment, or peer-review assignment metadata.",
      "You need Monte Carlo evidence about design density, recovery behavior, fit/separation operating characteristics, or sparse linked coverage.",
      "You need to compare legacy residual ZSTD screens, strict marginal/pairwise screens, scenario contrasts, runtime, and optional report-review signals.",
      "You need scenario, performance, report-signal, contrast, and draw-free plot-data tables for Quarto, reviewers, or supplementary files.",
      "You need graph connectedness, shared-observation, or subset diagnostics before treating measures as comparable.",
      "You need to document reviewer load, reciprocal pairs, low-common reviewer links, or assignment topology before interpreting peer-review scores."
    ),
    TypicalInput = c(
      "simulation specification or explicit generator arguments",
      "simulation specification, generated data, or recovery-assessment output",
      "mfrm_diagnostic_screening object or its summary",
      "mfrm_diagnostic_screening object or summary.mfrm_diagnostic_screening",
      "mfrm_fit, data frame, or diagnostics with co-observation structure",
      "peer-review simulation output or peer-review design metadata"
    ),
    NextStep = c(
      "Inspect embedded metadata before fitting; preserve the simulation spec with the generated data.",
      "Separate design diagnostics and recovery evidence from inferential or validation conclusions.",
      "Read scenario_summary and performance_summary first; use plot_overview_rate or plot_report_rate for reusable figure data.",
      "Use appendix_preset = \"recommended\" for a compact handoff, or include_empty = TRUE when documenting unavailable report-signal tables.",
      "Carry design connectivity into reporting as design evidence, not as fit, separation, or fairness evidence.",
      "Use the design review before any peer-quality, fairness, fit, separation, or recovery interpretation."
    ),
    GPCMStatus = c(
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "design_diagnostic_not_measurement_gate",
      "design_diagnostic_not_measurement_gate"
    ),
    Notes = c(
      "Generator labels and slope-regime metadata document conditions; they are not fit or adequacy thresholds.",
      "Use ADEMP-style condition and metric separation when reporting simulation evidence.",
      "Diagnostic-screening simulations describe operating characteristics; they are not calibrated inferential tests or standalone validation criteria.",
      "The appendix route reuses the package-wide summary-table contract instead of creating a separate simulation-only export API.",
      "Network review is a design/connectivity layer and does not replace MFRM estimates.",
      "Peer-review topology is an assignment-design diagnostic, not a reviewer-quality decision."
    ),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:985
.mfrmr_table_mfrmr_output_guide_gpcm_rows <- data.frame(
    Scope = rep("gpcm", 2L),
    Question = c(
      "Check the GPCM support matrix",
      "Find alternatives for unavailable GPCM routes"
    ),
    OutputFamily = c("guide", "review"),
    MainFunction = c(
      "mfrmr_output_guide(\"gpcm_capabilities\")",
      "mfrmr_output_guide(\"gpcm_capabilities\", view = \"unavailable\")"
    ),
    UseWhen = c(
      "You need to confirm which GPCM helper families are supported, caveated, blocked, or deferred before choosing a route.",
      "A GPCM route is blocked or deferred and you need an available alternative."
    ),
    TypicalInput = c(
      "none",
      "none"
    ),
    NextStep = c(
      "Use supported rows directly; for caveated, blocked, or deferred rows, read Boundary and RecommendedRoute.",
      "Read Boundary and RecommendedRoute before choosing a substitute analysis."
    ),
    GPCMStatus = c(
      "bounded_support_matrix",
      "out_of_scope_route_guidance"
    ),
    Notes = c(
      "The capability matrix is the user-facing GPCM support matrix.",
      "This table lists unavailable routes and the supported alternatives; it does not expand GPCM availability."
    ),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:1019
.mfrmr_table_mfrmr_output_guide_migration_entry_rows <- data.frame(
    Scope = c(
      rep("facets", 4L),
      rep("conquest", 2L)
    ),
    Question = c(
      "1. Check score support, then open a FACETS-organized review from an explicit MML fit",
      "2. Inspect targeting with the native Wright map and facet SE or CI",
      "3. Add the FACETS-style ruler with rubric-labelled steps",
      "4. Review Infit by measure, adding persons explicitly when needed",
      "1. Fit the supported overlap model explicitly with MML in mfrmr",
      "2. State the ConQuest comparison scope before preparing external review"
    ),
    OutputFamily = c(
      "entry", "plot-data", "plot-data", "plot-data",
      "entry", "compatibility"
    ),
    MainFunction = c(
      paste0(
        "describe_mfrm_data(data, person = ..., facets = ..., score = ..., rating_min = ..., rating_max = ...); ",
        "fit <- fit_mfrm(data, person = ..., facets = ..., score = ..., rating_min = ..., rating_max = ..., method = \"MML\"); ",
        "review <- summary(fit, profile = \"facets\", detail = \"brief\"); res <- review$results"
      ),
      "plot(res, type = \"wright\", renderer = \"native\", show_ci = TRUE, top_n = Inf, preset = \"publication\")",
      paste0(
        "fit$prep$score_map; ",
        "plot(res, type = \"wright\", renderer = \"facets\", category_labels = rubric_labels, show_ci = FALSE)"
      ),
      paste0(
        "plot(res, type = \"fit_pathway\", fit_stat = \"Infit\", include_person = TRUE, ",
        "top_n_person = 12, person_labels = \"none\", facet_labels = \"flagged\")"
      ),
      paste0(
        "fit_lr <- fit_mfrm(data, person = \"Person\", facets = \"Item\", score = \"Score\", ",
        "method = \"MML\", model = \"RSM\", population_formula = ~ X, person_data = person_data)"
      ),
      "mfrmr_output_guide(\"conquest\"); build_conquest_overlap_bundle(fit_lr)"
    ),
    UseWhen = c(
      "You are moving from FACETS terminology to an explicit, reproducible mfrmr analysis.",
      "You need the shared logit scale and mfrmr facet uncertainty before any compatibility-oriented plot.",
      "Readers need the familiar asterisk ruler and actual evaluation labels for adjacent category transitions.",
      "You need an Infit-centred follow-up and have a reason to inspect a bounded subset of person measures.",
      "Your design is inside the documented unidimensional RSM/PCM MML overlap that mfrmr implements.",
      "You plan to compare mfrmr with a separately run ConQuest analysis and need to state the boundary first."
    ),
    TypicalInput = c(
      "long-format data.frame with explicit person, facet, and score roles",
      "mfrm_results from summary(fit, profile = \"facets\")",
      "mfrm_results plus named labels from the rating rubric",
      "mfrm_results with available diagnostics",
      "long-format data.frame inside the documented overlap scope",
      "eligible latent-regression MML RSM/PCM fit with one numeric person covariate"
    ),
    NextStep = c(
      "Use the native Wright map to inspect targeting and uncertainty when that answers your question; FACETS-style views offer a familiar presentation for migration.",
      "Inspect targeting, uncertainty, and every retained step before opening the FACETS-style renderer.",
      "Verify that each displayed transition uses the instrument's real category wording; do not infer numerical equivalence from the layout.",
      "Treat flagged or extreme person points as review prompts and document any substantive follow-up rule separately.",
      "Read the scope note before generating a comparison bundle or extracting tables from an external ConQuest run.",
      "Run the generated command in ConQuest, use normalize_conquest_overlap_exports() on its four comparison CSV files, retain the history CSV for objective/free-dimension verification, and then use review_conquest_overlap()."
    ),
    GPCMStatus = c(
      rep("supported_with_caveat", 4L),
      rep("blocked_for_gpcm; rsm_pcm_overlap_only", 2L)
    ),
    Notes = c(
      "The model is estimated by mfrmr. FACETS-style organization does not mean that FACETS software was run.",
      "The native Wright map retains facet uncertainty. Choose figures for the analysis question; a particular figure is not an acceptance criterion.",
      "The closest FACETS-style renderer uses show_ci = FALSE and reproduces Table 6-style ruler grammar and labelled step lines, not optimizer-level numerical identity; show_ci = TRUE is an mfrmr uncertainty hybrid.",
      "Persons are opt-in because person identifiers and dense labels require deliberate privacy and readability choices.",
      "This call runs mfrmr only; it does not execute ConQuest, read a ConQuest command file, or parse raw ConQuest output.",
      "The bundle prepares a scoped comparison contract and command-text template. It does not execute ConQuest or parse raw report text."
    ),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:1096
.mfrmr_table_mfrmr_output_guide_user_pathway_rows <- data.frame(
    Scope = c(
      "facets", "facets", "facets", "facets", "facets", "facets", "facets",
      "facets", "facets", "facets", "facets",
      "conquest", "conquest", "conquest",
      "r", "r", "r", "r"
    ),
    Question = c(
      "State the FACETS relationship before using FACETS-style routes",
      "Translate FACETS direct and group anchor blocks",
      "Review anchor drift across forms, raters, or waves",
      "List fit measures and misfit flags by facet",
      "Explain FACETS df and ZSTD conversion",
      "Bring an external FACETS fit table into the review",
      "Review rating-scale categories, fair averages, and expected curves",
      "Review FACETS Table 14-style bias and interaction signals",
      "Draw a Wright map / variable map on the common logit scale",
      "Check score support and rater response patterns before fitting claims",
      "Write residual and subset files for external review",
      "Prepare a scoped ConQuest overlap case",
      "Compare extracted ConQuest tables after the external run",
      "State where mfrmr is less flexible than ConQuest",
      "Reuse plotting data for custom graphics",
      "Start from data-quality plot data for QC dashboards",
      "Reuse response-time plot data for custom QC graphics",
      "Combine tables and plot data for reports"
    ),
    OutputFamily = c(
      "compatibility", "review", "review", "table", "review", "review",
      "table", "review", "plot-data", "report",
      "export",
      "compatibility", "review", "compatibility",
      "plot-data", "plot-data", "plot-data", "bundle"
    ),
    MainFunction = c(
      "facets_guide('positioning'); facets_guide('coverage'); run_mfrm_facets(); run_mfrm_facets(); facets_output_file_bundle()",
      "review_mfrm_anchors(); make_anchor_table(); fit_mfrm(anchors = ..., group_anchors = ...)",
      "anchor_to_baseline(); detect_anchor_drift(); build_equating_chain(); plot(drift)",
      "fit_measures_table(); facets_chisq_table(); displacement_table()",
      "facets_guide('fit_df'); diagnose_mfrm(fit_df_method = \"both\")",
      "read_facets_results(); facets_fit_review(); plot(..., type = \"df_sensitivity\")",
      "rating_scale_table(); mfrm_report(fit, type = 'category_structure'); mfrm_report(fit, type = 'category_curves'); fair_average_table(); plot(x, type = \"fair_average\")",
      "estimate_all_bias(); estimate_bias(); mfrm_report(fit, type = 'bias_interaction'); mfrm_report(bias, type = 'bias_pairwise'); plot(bias, type = \"heatmap\")",
      "plot(fit, type = \"wright\"); plot(fit, type = \"wright\", view = \"unified\"); plot_data(type = \"wright\")",
      "mfrm_report(fit, type = 'data_quality'); plot(..., type = \"dashboard\")",
      "write_mfrm_residual_file(); write_mfrm_subset_file(); facets_output_file_bundle()",
      "build_conquest_overlap_bundle()",
      "normalize_conquest_overlap_exports(); review_conquest_overlap()",
      "mfrm_report(fit, type = 'checklist'); reference_case_benchmark()",
      "mfrm_results(fit, include = \"misfit_review\"); mfrmr_output_guide(\"intervals\"); plot_data_components(); plot_data(); plot(..., draw = FALSE); plot(fit, type = \"pathway\", draw = FALSE); plot_data(mfrm_report(type = 'category_curves', ...), component = \"plot_long\"); plot(bias, type = \"heatmap\", draw = FALSE); plot(info, type = \"sem\", draw = FALSE)",
      "plot_data(mfrm_report(type = 'data_quality', ...), type = \"dashboard\")",
      "response_time_review(); plot(timing, draw = FALSE); plot_data_components(); plot_data()",
      "build_summary_table_bundle(); build_visual_summaries()"
    ),
    UseWhen = c(
      "You need to explain the limits of FACETS correspondence while using familiar names, coverage maps, fixed files, or graphfile-style handoff.",
      "You are translating FACETS D/A or D/G anchor blocks before fitting.",
      "You need to screen common-element drift across administrations, forms, raters, or waves.",
      "You want a Table 7-like view of measures, standard errors, and fit status.",
      "You need to show whether a ZSTD difference is caused by df convention rather than MnSq.",
      "You have already extracted a FACETS fit table and want a df/ZSTD-sensitive side-by-side review.",
      "You want FACETS Table 8/category and Table 12 fair-average style evidence.",
      "You want a FACETS Table 14-like route for local interaction-bias screening.",
      "You want a variable-map view of persons, facet levels, and step thresholds.",
      "You want a pre-interpretation QC screen for zero categories, dominant raters, or dropped rows.",
      "You need standalone residual rows or connected-subset membership files for a reviewer, spreadsheet, or external QC workflow.",
      "You need the narrow documented MML latent-regression overlap bundle.",
      "You have the four comparison CSV files requested by the generated ConQuest command and have retained its additional history CSV for verification.",
      "You need to explain why a ConQuest command-file workflow is not interchangeable with this package.",
      "You want to draw your own ggplot2/base/plotly figure from package plot data.",
      "You want the dashboard tables without opening a graphics device.",
      "You have response-time metadata and want reusable timing tables for ggplot2, plotly, Quarto, or dashboard QC views.",
      "You need stable data frames and reusable plot-data objects for an R Markdown or Quarto report."
    ),
    TypicalInput = c(
      "mfrm_fit or run_mfrm_facets() output",
      "raw data plus anchor and/or group-anchor tables",
      "baseline anchors, baseline fit, new data, or a list of fitted waves",
      "mfrm_fit plus optional diagnostics",
      "mfrm_fit, mfrm_diagnostics, or a fit-measures/review table",
      "mfrm_fit plus extracted FACETS table",
      "mfrm_fit plus optional diagnostics",
      "mfrm_fit plus diagnostics",
      "mfrm_fit",
      "mfrm_fit plus optional raw data",
      "mfrm_fit plus optional diagnostics",
      "eligible MML RSM/PCM fit",
      "ConQuest parameter, regression, covariance, and case-EAP CSVs plus the overlap bundle",
      "mfrm_fit plus optional diagnostics or benchmark request",
      "mfrm_plot_data or any mfrmr object with a plot method",
      "mfrm_data_quality bundle",
      "mfrm_response_time_review or long-format rating-event data",
      "summary/checklist/report/review objects"
    ),
    NextStep = c(
      "Start with facets_guide('positioning'), then use native mfrmr objects for inference and FACETS-style files for handoff layout.",
      "Review issue_counts and recommendations before choosing anchor_policy for fit_mfrm().",
      "Check drift flags and link residuals before treating linked measures as comparable.",
      "Use threshold profiles for mean-square sensitivity; ZSTD-only evidence is separate by default. Use mfrm_screening_sensitivity() for known-truth simulation rates.",
      "Compare MnSq first, then df, then ZSTD; label convention-sensitive flags explicitly.",
      "Normalize the external table first, then inspect df_sensitivity, df_sensitive, and external_comparison.",
      "Check zero/sparse categories and threshold ordering before reporting fair averages.",
      "Use estimate_all_bias() for eligible facet pairs, summary(screens) for counts and availability, and plot(screens) for an overview. Select pair in plot(screens, pair = ...) for a detailed view; use estimate_bias() for a prespecified pair and the report helpers for follow-up.",
      "Use draw = FALSE or plot_data(type = \"wright\") when you need reusable coordinates for custom graphics.",
      "Resolve severe QC flags before interpreting fit or fairness outputs.",
      "Keep residual, subset, and graph/score files distinct; use the native writers unless a legacy graph/score contract is required.",
      "Run ConQuest externally; retain the command, alias maps and original bundle. Set external calibration and scoring precision through conquest_control.",
      "Supply the generated report_file for stopping/model metadata. Review missing, extra, non-numeric and status rows; establish a common origin before interpreting EAP/intercept errors.",
      "Document that mfrmr currently exposes selected overlap checks, not the full ConQuest modeling language.",
      "Start with plot_data_components(); for interval-aware figures use mfrmr_output_guide(\"intervals\"); for pathway maps use pathway_long/pathway_annotations/fit_measures; for category, bias, and information plots use plot_long plus annotations/settings.",
      "Use component names such as quality_flags, category_usage_by_facet, and facet_response_patterns.",
      "Use the table, thresholds, overview, and notes components; keep timing interpretation descriptive unless a separate speed-accuracy model is fitted.",
      "Keep table objects and plot-data objects separate so custom reporting remains reproducible."
    ),
    GPCMStatus = c(
      "graph_only_or_blocked_by_score_side_semantics",
      "supported_with_caveat",
      "supported_with_caveat; exploratory_gpcm_linking_review",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported",
      "supported",
      "blocked_for_gpcm; rsm_pcm_overlap_only",
      "blocked_for_gpcm; rsm_pcm_overlap_only",
      "blocked_for_gpcm; rsm_pcm_overlap_only",
      "supported",
      "supported",
      "supported",
      "supported_for_direct_outputs"
    ),
    Notes = c(
      "mfrmr is not a FACETS numerical clone; familiar names help transition, but estimates remain package-native unless external output is supplied.",
      "Direct anchors fix element logits; group anchors constrain a group mean. Overlapping constraints are retained jointly and must be compatible.",
      "Operational linking conclusions remain RSM/PCM-scoped; GPCM linking review is caveated exploratory synthesis.",
      "Closest current route for FACETS users who expect fit measures in one table.",
      "The guide explains engine df, FACETS-style df, Wilson-Hilferty ZSTD, and WHEXACT caveats.",
      "This is a review of supplied rectangular output, not raw FACETS text parsing; use df_sensitive for convention-sensitive rows.",
      "GPCM fair averages are slope-aware direct outputs, not FACETS score-side equivalence.",
      "Conditional screening, not formal DFF or a fairness decision. Per-pair adjustment is not collection-wide multiplicity control. Keep unavailable pairs/cells and the complete collection when saving. FACETS-style presentation does not establish numerical equivalence to FACETS.",
      "Wright maps visualize fitted scale locations; under GPCM, interpret step/threshold locations with slope-aware caveats.",
      "Separates global score-support gaps from facet-level category restriction; neither local avoidance nor a near-zero severity estimate is by itself a reason to select GPCM.",
      "Residual and subset writers are package-native CSV/TSV handoff routes, not exact FACETS fixed-field command-file clones.",
      "ConQuest support is intentionally scoped to a documented comparison case.",
      "Estimates come from CSVs or extracted tables. Optional generated report metadata records stopping and location; it does not certify input identity or numerical precision.",
      "Use this row when reporting scope differences to ConQuest users.",
      "Best R-first route for users who want full control over graphics, interval-aware displays, fit-annotated pathway maps, bias-screening views, and TIF/conditional-SEM plots.",
      "The accessor avoids depending on the underlying object structure in user scripts.",
      "Response-time plot data are a QC display contract, not a measurement-model extension.",
      "Use this path for Quarto/R Markdown pipelines and downstream custom tables."
    ),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:1253
.mfrmr_table_mfrmr_output_guide_model_rows <- data.frame(
    Scope = rep("models", 3),
    Question = c("Describe specified fixed raters and tasks",
      "Generalize from a sampled rater population",
      "Model dependence among ratings within a Person"),
    OutputFamily = rep("entry", 3),
    MainFunction = c("fit_mfrm()", "fit_mfrm_random_rater()", "fit_mfrm_testlet()"),
    UseWhen = c("You want to describe the particular raters or tasks included in the data.",
      "One random rater effect is shared across all Persons rated by that rater; population assumptions are justified.",
      "An explicit non-overlapping testlet groups ratings within each Person; fixed facets retain separate roles."),
    TypicalInput = rep("Long-format ratings with explicit column roles and score categories", 3),
    NextStep = c("summary(fit) first. For ordinary RSM/PCM MML/JML mfrm_fit results, use diagnose_mfrm(), mfrm_results() and ordinary Wright maps. For CML, use mfrm_facet_intervals(), plot(intervals), apa_table(intervals) and saveRDS(); see mfrmr_output_guide(\"intervals\") for full structural and comparison-only results. For GPCM or corrected JML, consult mfrmr_output_guide(\"gpcm_capabilities\") and online GPCM scope guide (https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-gpcm-scope.html); use the model-specific mfrm_results() / mfrm_report() routes.",
      "score_mfrm_persons() for abilities of source Persons; score_mfrm_random_rater(newdata = ...) for a supplied complete scoring roster; predict() for probabilities at supplied abilities; plot(); plot_data(); mfrm_results() -> mfrm_report() -> export_mfrm_results(); see online random-rater guide (https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-random-raters.html).",
      "summary(); score_mfrm_persons() for abilities of source Persons; predict(newdata = ...) for a supplied scoring roster with known fixed-facet levels; plot(); plot_data(); as_ggplot(); mfrm_results() -> mfrm_report() -> export_mfrm_results(); see online testlet guide (https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-testlets.html) and online testlet-applications guide (https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-testlet-applications.html) for task/criterion allocation and unequal-block examples."),
    GPCMStatus = c("supported_with_caveat", "unavailable; RSM only", "unavailable; RSM only"),
    Notes = c("Native CML returns mfrm_cml_fit or a CML mfrm_comparison_fit, with no Person abilities, population SD, ordinary diagnostics, Wright maps or mfrm_results() support. JML/MML comparison-only results are descriptive, without structural intervals. The mfrm_fit class also includes different model/estimator contracts. One-family GPCM has operation-specific caveats; two-family GPCM and corrected JML do not supply ordinary fit tests or Wright/Pathway maps. Their separately supported response diagnostics are descriptive. A finite estimate or shared result class does not authorize another model's analysis.",
      "Distinct mfrm_random_rater class: reports accept matching saved Person scores, response predictions and bootstrap intervals. Person scoring uses joint conditional rater Laplace integration and excludes calibration uncertainty. Ordinary diagnostics, viewer, response-MI pooling and portable calibration are unavailable; few-rater accuracy remains unresolved.",
      "Distinct mfrm_testlet class: stored-result reports accept matching saved Person scores. One common local variance; no task-specific variances, halo diagnosis or enforced equal task weights. Numerical checks are not model-fit diagnostics; Person intervals exclude calibration uncertainty. Ordinary diagnostics, viewer, response-MI pooling and portable calibration are unavailable."),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:1274
.mfrmr_table_mfrmr_output_guide_workflow_rows <- data.frame(
    Scope = c("features", "imputation", "gtheory"),
    Question = c("Describe groups from external person, rater or task attributes",
      "Analyze missing scores on assigned ratings with multiple imputation",
      "Plan assessment counts or weights on an observed-score scale"),
    OutputFamily = rep("entry", 3),
    MainFunction = c("mfrm_features(); mfrm_cluster(); mfrm_pca(); mfrm_cluster_imputed(); mfrm_cluster_compare()",
      "review_mfrm_imputations(); fit_mfrm_imputed(); pool_mfrm_imputed()",
      "mfrm_g_study(); mfrm_d_study(); compare_mfrm(); mfrm_report()"),
    UseWhen = c("Exploratory groups summarize selected external attributes; numeric PCA/k-means and mixed-feature grouping use different distances.",
      "Reviewed completions preserve observed scores, allowed categories and the assigned roster, with a justified imputation model.",
      "The question concerns G/Phi/SEM for declared crossed or supported nested facets and fixed score components."),
    TypicalInput = c("One row per entity with explicit IDs and selected features; use separate tables for different entity roles.",
      "Original long-format rating roster and every completed dataset, with assigned missing scores distinguished from unassigned combinations.",
      "Numeric observed scores, Person IDs, declared facet columns, future counts and score weights."),
    NextStep = c("summary() for reviews and comparisons; plot() and plot_data() for fitted PCA, partitions and imputation co-membership. Retain the transformation and grouping with saveRDS(); export selected tables with write.csv(). See online feature-analysis guide (https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-external-features.html).",
      "Inspect summary(analyses) for every completion; summary(pooled); plot(pooled); plot_data(pooled); saveRDS(pooled); write.csv(summary(pooled), ...). See online response-imputation guide (https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-response-imputation.html).",
      "Start with summary(g) and plot(g) for score components; use type = 'covariance' for between-score matrices. With D-study result d, inspect summary(d) and plot(d), choosing metric, score and panel_by explicitly. Use plot(d, type = 'sem') for error in score units, or type = 'error_components' to see which sources contribute to each future plan. For uncertainty, see confint.mfrm_multivariate_gstudy and confint.mfrm_multivariate_d_study; summary(d, intervals = TRUE, assumption = 'normal') collects supported coefficient/SEM intervals. Pass g/d or a paired comparison directly to mfrm_report(); attach saved intervals explicitly. build_summary_table_bundle(report), apa_table(report, which = 'coefficients') and export_summary_appendix(report) retain reporting context. Save the full report with saveRDS(); use templates/gtheory-report.Rmd for a complete editable manuscript. See vignette('mfrmr-gtheory')."),
    GPCMStatus = c("not_applicable", "unavailable; fixed-standard-normal RSM/PCM MML only", "not_applicable"),
    Notes = c("Descriptive groups, not abilities, rater quality or validated latent classes. Pair the same feature imputations when comparing settings; do not pool cluster labels or PCA bases. Use dedicated tables/plots and RDS saving, not mfrm_results(); as_ggplot() supports PCA scree/scores/loadings, saved dendrograms, imputation co-membership, silhouettes and numeric/categorical profiles.",
      "Pool eligible non-Person facet targets and full covariances only; no EAP, cluster-label or fit-statistic pooling. No unassigned-cell filling, general coverage guarantee or extended-model pooling. The pooled object uses dedicated tables/plots and RDS saving, not mfrm_results(); as_ggplot() preserves saved pointwise MI intervals and inference settings.",
      "G/Phi describe observed-score dependability; measurement SEM is error in score units, not a Person posterior SD or a coefficient SE. Error contributions retain signed covariance/interaction terms and are point projections, not intervals. Component, coefficient and paired-plan uncertainty have separate methods and design restrictions; an available point does not guarantee an available interval. Normal-model F limits have a restricted exact scope; MLS, generalized and profile methods retain their approximate or experimental qualifications. No general small-sample, nonnormal or simultaneous coverage guarantee is supplied. Keep original points, any separate IntervalCenter, numerical failures and method notes. confint.mfrm_multivariate_gstudy documents component/covariance methods; confint.mfrm_multivariate_d_study documents coefficient/SEM choices; compare_mfrm documents paired-delta contrasts. Use dedicated results and RDS saving, not mfrm_results(). plot(), plot_data(), and as_ggplot() support the documented G/D and paired-delta difference views."),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:1299
.mfrmr_table_mfrmr_output_guide_feedback_rows <- data.frame(
    Scope = rep("feedback", 5),
    Question = c(
      "How uncertain are fixed-rater severities or prespecified differences?",
      "Which ordinary-model rating patterns need review, and do flags depend on the cutoff?",
      "Which response residuals need review under supported RSMs or corrected GPCM JML?",
      "How uncertain is an observed rater's severity in a shared-rater model?",
      "How often does a warning rule flag unaffected or detect affected raters?"),
    OutputFamily = c("entry", "review", "review", "entry", "review"),
    MainFunction = c("mfrm_facet_intervals()",
      "fit_measures_table()", "mfrm_response_diagnostics()",
      "confint(); mfrm_random_rater_intervals()",
      "mfrm_screening_performance(); mfrm_screening_sensitivity()"),
    UseWhen = c(
      "The target is a specified fixed rater or contrast, conditional on the fitted facet levels.",
      "Review ordinary Infit/Outfit and directional flags; choose lower/upper and flag_basis explicitly when a rule is prespecified.",
      "Review same-data residuals under their probability definition: posterior integration for supported RSMs or two-family GPCM MML, or conditional fitted probabilities for corrected JML.",
      "The target is an observed rater's latent severity relative to the modeled rater population, not a fixed-facet coefficient.",
      "A simulation provides prespecified truth and every planned replication/target, including failed or unavailable screens."),
    TypicalInput = c(
      "Native RSM/PCM CML full or comparison-only results; ordinary fixed-standard-normal RSM/PCM MML; direct MML estimated-normal RSM/PCM or one-family GPCM; or experimental two-family GPCM MML. Use unit weights, a facet and optional named contrast matrix. Matching full RSM/PCM MML interaction fits instead use comparison_review. One-family GPCM also admits fixed N(0,1).",
      "Ordinary RSM/PCM or supported one-family GPCM fit, or matching diagnose_mfrm() result; not two-family GPCM, corrected JML, testlet or shared-rater fits. Select the actual rater facet column.",
      "A supported ordinary/extended RSM fit, two-family GPCM fixed-grid EM or adaptive direct MML fit, or explicit corrected GPCM JML point solution; optional observed-row and grouping selections.",
      "A shared-rater fit; saved mfrm_random_rater_intervals output for bootstrap review without new refits.",
      "Planned roster with known Affected status plus saved flags, or saved Infit/Outfit and explicit threshold profiles."),
    NextStep = c(
      "For full CML use mfrm_facet_intervals(fit, facet); for CML comparison-only fits omit facet and reuse saved targets. CML permits only method = 'model', scale = 'native'. For ordinary fixed-population RSM/PCM MML choose 'model' or 'sandwich'; other supported MML routes use 'model' intervals, with two-family GPCM still experimental. For full MML interaction targets supply comparison_review; scale = 'standardized' requests population-SD units where supported. All interval results support summary(), plot(), as_ggplot(), apa_table() and saveRDS(). Only supported MML intervals attach with mfrm_results(fit, intervals = list(raters = intervals), compute = 'never'); plot type is 'facet_raters' for RSM/PCM or 'gpcm_raters' for GPCM. See mfrmr_output_guide(\"intervals\").",
      "Inspect settings, threshold_profiles and profile_summary_by_facet; keep underfit and overfit separate. Use the ordinary results pathway plot with matching diagnostics. Save the full review, not just flagged rows.",
      "Save diagnostics; inspect summary(diagnostics), plot(diagnostics) and plot_data(diagnostics). Attach with mfrm_results(fit, response_diagnostics = diagnostics, compute = 'never') for reports and residual plots; inspect tables$response_overview for available, unresolved and unselected rows. Model-aware pathway maps remain limited to supported RSM extensions.",
      "Begin with point estimates in summary(fit) and plot(fit). confint(fit, parm = 'raters') requests the normal approximation; bootstrap fitting is separate and can be costly. Retain all bootstrap trials and unavailable or infinite endpoints when saving/reporting.",
      "Inspect target and family rates together with availability and all-trial bounds; plot(performance), plot_data(performance), and saveRDS(performance). Compare threshold profiles without automatically choosing the best one."),
    GPCMStatus = c("supported_with_caveat one-family MML locations; experimental two-family; no JML structural-CI support", "supported_with_caveat",
      "two-family MML posterior residuals; corrected JML conditional residuals", "not_applicable", "not_applicable"),
    Notes = c(
      "Pointwise fixed-facet intervals, not simultaneous classifications or random-rater population inference. CML uses conditional information and estimates no population SD; its intervals are asymptotic. Native scale is the default. Explicit MML standardized contrasts divide by the same fit's population SD and include its uncertainty and cross-covariance; estimated SD requires an intercept-only normal population, not a regression residual SD. Inspect IdentificationBasis, numerical eligibility and unavailable rows separately; these do not prove global MML identification or finite-sample coverage. Sandwich SEs do not correct a biased estimate or MNAR. GPCM location differences do not imply uniform rating differences when slopes/steps vary. One-family MML Wald intervals assume a correctly specified, identified regular model.",
      "Flags are descriptive review prompts, not probabilities of poor rater quality. Severity is not misfit. Threshold sensitivity on observed data does not estimate false-flag or detection rates; GPCM retains its separate capability and inference limits.",
      "Posterior predictive and corrected-JML conditional Infit/Outfit have different probability definitions. Zero-variance corrected-JML rows can leave Infit defined but Outfit unavailable; no rows are silently dropped. No classic cutoffs, ZSTD tests, automatic exclusion or calibrated diagnostic accuracy is supplied.",
      "Individual-rater intervals are not automatic. Normal and bootstrap approximations remain unqualified for general coverage; average prediction coverage does not establish coverage at each fixed severity. Do not substitute conditional Person intervals or population-SD profiles.",
      "Known truth is required: real-data flags alone cannot estimate these rates. Monte Carlo intervals describe simulation uncertainty, not severity uncertainty. Unavailable screens are retained, and raters within one replication are not independent trials."),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:1341
.mfrmr_table_mfrmr_output_guide_data <- data.frame(
    Scope = "feedback", Question = "How can I prepare a sheet for one rater?",
    OutputFamily = "review", MainFunction = "mfrm_report()",
    UseWhen = "Share selected saved summaries with one recipient after reviewing the assessment context.",
    TypicalInput = "mfrm_results from native additive RSM/PCM or two-family GPCM MML. Attach matching model-specific diagnostics and intervals explicitly.",
    NextStep = "Use mfrm_report(res, style = 'rater', facet = 'Rater', rater = 'R01', output = 'html'). Review its path before copying the standalone HTML file. Choose audience = 'researcher' for technical guidance or max_cases = 0 to omit individual ratings.",
    GPCMStatus = "experimental descriptive two-family MML sheets; one-family GPCM unavailable",
    Notes = "No refitting, interval calculation, automatic warning cutoff or rater-quality classification. The sheet omits source identifiers; patterns may still be recognizable. Do not distribute the comprehensive source bundle as an individual sheet.",
    stringsAsFactors = FALSE)
# From help_reports_and_tables.R:1351
.mfrmr_table_mfrmr_output_guide_data_1 <- data.frame(
    Scope = "calibration", Question = "How uncertain is a judgment at a supplied ability cut?",
    OutputFamily = "table",
    MainFunction = "score_mfrm_persons(); predict_mfrm_units(); score_mfrm_calibration() with cut_scores",
    UseWhen = "Ordinary RSM/PCM conditional ability probabilities are needed on the calibration scale; choose the eligible source-roster, fitted-object or portable route.",
    TypicalInput = "Eligible calibration, response rows and strictly increasing ability cuts; unit weights",
    NextStep = "Inspect $decisions and Status/Reason; use apa_table(x, which = 'decisions'). Native and portable batches also support export_summary_appendix(). Save the complete score object for reuse.",
    GPCMStatus = "unavailable; ordinary RSM/PCM only",
    Notes = "Calibration, prior and cuts are fixed. Review whether the scoring prior matches the target population; numerical checks do not validate that match. Estimated-prior uncertainty is excluded. No Person-difference test, calibration-error propagation or automatic CEFR alignment; review-only, prior-only and unavailable states remain explicit.",
    stringsAsFactors = FALSE)
# From help_reports_and_tables.R:1362
.mfrmr_table_mfrmr_output_guide_rating_evaluation_rows <- data.frame(
    Scope = c(rep("feedback", 4), "calibration", "linking"),
    Question = c(
      "How closely do observed ratings agree across raters?",
      "How does one score source compare with reference ratings?",
      "Do rater residuals and category thresholds suggest centrality?",
      "How accurately does each rater match fixed expert reference ratings?",
      "How accurate and repeatable are classifications under a fixed rating plan?",
      "How sensitive is a group contrast to the DIF comparison method?"),
    OutputFamily = rep("table", 6),
    MainFunction = c(
      "pairwise_kappa_table(); krippendorff_alpha_table(); gwet_ac2_table(); pairwise_icc_table()",
      "score_comparison_table()", "rater_centrality_table()", "fit_rater_accuracy()",
      "classification_table()", "mantel_haenszel_table(); ordinal_logistic_table()"),
    UseWhen = c(
      "Choose pairwise weighted kappa/QWK, panel alpha/AC2 or pairwise ICC for the declared rating scale and target.",
      "Compare human or automated scores using QWK, correlation and SMD; an optional second reference supplies the degradation baseline.",
      "Describe RSM residual-expected-score correlation and fit, and/or the spread of rater-owned PCM thresholds.",
      "Fit a binary Rasch accuracy model to exact reference matches, with specified benchmark difficulty facets.",
      "Evaluate Lee summed-score probabilities, the Rudner ML normal approximation and conditional SEM at supplied ability cuts.",
      "Compare binary MH, multi-category/multi-group GMH or ordinal-logistic results with residual analyze_dff() output on an explicitly matched roster."),
    TypicalInput = c(
      "Long ratings with explicit rater and rated-unit keys; declare category order/universe or a meaningful interval scale for ICC. Duplicate rater-unit cells are rejected.",
      "Aligned scores/reference ratings and numeric categories; optional reference2 and matching ordinary additive RSM/PCM rater fit/diagnostics.",
      "Existing ordinary additive JML/MML RSM fit and/or rater-owned PCM threshold_fit; when both are supplied their retained rosters and coding must match.",
      "Observed/reference categories, rater IDs and benchmark facets; each benchmark has one fixed reference. Repeated rater-benchmark cells are rejected.",
      "Ordinary RSM/PCM calibration, fixed rating_plan, true ability cuts, sum-score cuts and theta points; optional population weights and distinct operational ability cuts.",
      "Independent Persons, one response per Person-target cell and justified matching scores/strata. MH uses two groups; GMH and ordinal logistic accept multiple groups/categories. Ordinal logistic requires the optional ordinal package and a positive-width matching range shared by all groups."),
    NextStep = c(
      "Inspect table, settings and unit/case exclusions. Select ICC agreement versus consistency and single versus two-rating average explicitly. Save each complete result with saveRDS().",
      "Inspect table, criteria, cases and counts. Default screen = 'none'; use screen = 'williamson2012' only for that explicit application. Save the complete result, including any MFRM attachment.",
      "Inspect table, thresholds, categories and sources; retain unavailable-index reasons and separate source readiness. Save the complete result with saveRDS().",
      "Inspect table, difficulty, cases and settings, including estimate-use/source status. Save the full result and native fit; export individual data frames with write.csv().",
      "Inspect table, cuts, probabilities, scores and source. marginal and classification_matrix require explicit theta_weights. Save the complete plan, settings and outputs with saveRDS().",
      "Follow online linking and DFF guide (https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-linking-and-dff.html) to align directions and audit method-specific cases. Retain native effect scales, GMH omnibus tests/category counts, excluded strata, logistic contrasts, diagnostics and multiplicity families."),
    GPCMStatus = c("not_applicable", "raw-score comparison; GPCM fit attachment unavailable",
      "unavailable; ordinary RSM/PCM only", "not_applicable",
      "unavailable; ordinary RSM/PCM only", "not_applicable"),
    Notes = c(
      "Observed-score agreement is not MFRM separation reliability or criterion accuracy. Coefficients have different chance models and missingness denominators; ICC pairs may use different units and must not be averaged into a panel ICC. No universal quality cutoff or confidence interval is supplied.",
      "The reference is not necessarily error-free. Williamson thresholds are application-specific examples, not general validity criteria. Severity/fit are separate from criterion accuracy; request screen = 'williamson2012' explicitly when applicable.",
      "Descriptive indices, not a validated centrality diagnosis or Bayesian omega estimate. Low Infit has other explanations; MML expectations use saved EAP plug-in scores. Binary rubrics cannot supply threshold spread.",
      "Accuracy logits concern exact reference matches, not rater severity or examinee ability. Binary coding discards error direction/size; reference uncertainty is excluded. JML is exploratory with infinite extreme estimates; MML EAP/SD condition on fitted difficulty and population parameters.",
      "Calibration, cuts and plan are fixed. Lee and Rudner may describe different decision rules; the Rudner normal approximation can fail for short plans or extremes. Conditional ability SEM is not posterior SD. No automatic cuts or calibration-error propagation; source review and unavailable outputs remain explicit.",
      "Exact stratification and a linear logistic matching relationship are different models. Different exclusions or significance labels do not establish method robustness or fairness. No adjustment for repeated ratings, matching error or unequal rating-plan exposure is supplied."),
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:1410
.mfrmr_table_mfrmr_output_guide_model_export_row <- data.frame(
    Scope = "exports",
    Question = "Estimate externally and bring saved Bayesian summaries or new-Person scores into figures and reports",
    OutputFamily = "export",
    MainFunction = "export_mfrm_model(); read_mfrm_posterior(); predict.mfrm_posterior_summary()",
    UseWhen = "You need editable Stan/brms model code (or optional CmdStanR execution via run_cmdstan = TRUE), shared-calibration posterior contrasts, or calibration-posterior scoring for new Persons.",
    TypicalInput = "Unit-weight RSM/PCM or one-family GPCM (Stan or brms for fixed N(0,1); Stan for estimated normal population or two-family GPCM), supplied via fit or data + spec. Supported fixed facet/group and step constraints are preserved; no interactions or shrinkage.",
    NextStep = "Review the model and priors, then run run.R (or run_cmdstan = TRUE). Return with x <- read_mfrm_posterior(directory); inspect summary(x) and x$checks before confint(x), plot(x), predict(x, newdata = ...) or mfrm_report(x).",
    GPCMStatus = "one-family Stan/brms (scoring supported); two-family Stan only (scoring excluded)",
    Notes = "The reader checks saved-summary and basis consistency, not model adequacy. Stored credible intervals retain fixed-value and sampling-review flags; joint draws (posterior-draws.rds) are required for contrasts, custom levels and full calibration-posterior new-Person scoring (conditioning = 'posterior'). Exact anchors exclude external calibration uncertainty. Original labels are retained; review before sharing.",
    stringsAsFactors = FALSE
  )
# From help_reports_and_tables.R:1423
.mfrmr_table_mfrmr_output_guide_data_2 <- data.frame(
    Scope = "network", Question = "Which facet levels share residual profiles after fitting?",
    OutputFamily = "report", MainFunction = "mfrm_residual_network(); mfrm_report()",
    UseWhen = "A stated unexplained-structure question follows model and overlap review; node levels belong to one fitted facet.",
    TypicalInput = "A fit and matching diagnostics; explicit aggregation/missingness, overlap threshold and optional group count.",
    NextStep = "Inspect pairs and person_usage; plot(net, type = 'matrix'/'network'/'dendrogram'); mfrm_report(net) -> build_summary_table_bundle() -> export_summary_appendix(). Save the complete result with saveRDS().",
    GPCMStatus = "ordinary one-family diagnostics only; extended-model residuals unavailable",
    Notes = "Signed standardized-residual correlations, not raw Yen Q3, partial correlations, EGA or a fitted residual-network model. Hierarchical grouping uses common complete persons and sqrt(2*(1-r)) distance. Unavailable pairs and clustering remain explicit. Groups are exploratory, not rater quality or latent classes; random forests are a separately validated supervised follow-up.",
    stringsAsFactors = FALSE)
# From help_reports_and_tables.R:1433
.mfrmr_table_mfrmr_output_guide_network_rows <- data.frame(
    Scope = "network", OutputFamily = "report",
    Question = c("Are planned or observed ratings connected before fitting?",
      "Which raters agree, score higher, or show inconsistent score differences?",
      "Are within-rater criterion associations stronger than between-rater associations?",
      "Do declared binary rater ties show reciprocity or covariate associations?"),
    MainFunction = c("mfrm_network_analysis(); build_mfrm_network_review()",
      "rater_network_analysis(); mfrm_report()",
      "rater_halo_network_analysis(); mfrm_report()",
      "fit_rater_network(); mfrm_report()"),
    UseWhen = c("You need to inspect planned assignment or observed overlap before interpreting comparisons.",
      "You want complementary observed-score agreement/direction diagnostics after checking shared contexts.",
      "A rubric question motivates a declared same-rater minus other-rater correlation contrast.",
      "The research question concerns network configurations or exogenous rater attributes, with a prespecified tie rule."),
    TypicalInput = c("Raw long ratings/assignments with person/facet keys and an explicit observed/planned basis, or an existing fit.",
      "An ordinary fit and matching diagnostics; rater/context facets, agreement metric and thresholds.",
      "An ordinary fit and matching diagnostics; rater/criterion/context facets including Person for bootstrap intervals.",
      "A rater/halo network, strict binary threshold, ERGM formula and optional complete Node-keyed covariates."),
    NextStep = c("Inspect all nodes, isolated levels and row_usage; plot the graph and improve overlap where substantively justified.",
      "Use KrippendorffAlpha for signed agreement or DirectionalMagnitude for network_fit; plot, mfrm_report() and export_summary_appendix().",
      "Declare halo_reference; inspect halo_contrast and bootstrap_draws, including failures, then report/export the same target.",
      "Review summary(model), backend warnings, MCMC diagnostics and simulated GOF; confint(model) extracts conditional coefficient intervals. Use plot(), mfrm_report() and export_summary_appendix()."),
    GPCMStatus = c("Design links do not depend on a fitted response model.",
      "Observed-score relationships, not GPCM-specific fit or slope-adjusted effects.",
      "Observed-score associations, not a latent halo parameter.",
      "A binary network likelihood, not a GPCM rating likelihood."),
    Notes = c("Connectedness is not model identification. An unassigned or unscored cell is not a zero response.",
      "Negative alpha, zero and unavailable agreement differ. SWS/PUS depend on score units and have no universal Rasch-style cutoffs; signed path centralities are withheld.",
      "Person-cluster resampling conditions on observed raters/criteria and a fixed pair set. Undefined replicates withhold the interval. The contrast does not establish causal halo.",
      "Optional ergm/network packages. Missing dyads stay NA; missing='model' assumes ignorability. Threshold/model selection and estimated-edge uncertainty are not included."),
    stringsAsFactors = FALSE)
# From help_visual_diagnostics.R:711
.mfrmr_table_visual_reporting_template_out <- data.frame(
    FigureFamily = c(
      "Wright map",
      "Pathway map",
      "Category characteristic curves",
      "Category probability surface",
      "Information curves",
      "QC dashboard",
      "Unexpected / displacement",
      "Strict marginal visuals",
      "Bias / DFF visuals",
      "Residual PCA",
      "Guttman scalogram",
      "Residual Q-Q",
      "Rater trajectory (linked waves)",
      "Rater agreement heatmap",
      "Response-time review",
      "Empirical-Bayes shrinkage funnel"
    ),
    Scope = c(
      "manuscript",
      "manuscript",
      "manuscript",
      "surface",
      "manuscript",
      "diagnostic",
      "appendix",
      "appendix",
      "diagnostic",
      "appendix",
      "diagnostic",
      "appendix",
      "diagnostic",
      "diagnostic",
      "diagnostic",
      "appendix"
    ),
    PrimaryHelper = c(
      "plot(fit, type = \"wright\", preset = \"publication\")",
      "plot(fit, type = \"pathway\", preset = \"publication\")",
      "plot(fit, type = \"ccc\", preset = \"publication\")",
      "plot(fit, type = \"ccc_surface\", draw = FALSE)",
      "compute_information(fit) -> plot(..., preset = \"publication\")",
      "plot(fit, type = \"qc\", diagnostics = diagnostics, preset = \"publication\")",
      "plot(x, type = \"unexpected\"); plot(x, type = \"displacement\")",
      "plot(x, type = \"marginal_fit\"); plot(x, type = \"marginal_pairwise\")",
      "plot(x, type = \"bias\"); plot(x, type = \"heatmap\"); plot(x, type = \"summary\")",
      "analyze_residual_pca() -> plot(x, type = \"residual_pca\")",
      "plot(fit, type = \"guttman\", diagnostics = diagnostics)",
      "plot(fit, type = \"residual_qq\", diagnostics = diagnostics)",
      "plot((list(T1 = fit_a, T2 = fit_b))[[1L]], type = \"trajectory\", comparison = (list(T1 = fit_a, T2 = fit_b))[-1L], labels = names(list(T1 = fit_a, T2 = fit_b)))",
      "plot(fit, type = \"agreement\", view = \"heatmap\", diagnostics = diagnostics)",
      "response_time_review(...); plot(timing)",
      "plot(fit_eb, type = \"shrinkage\", view = \"funnel\", show_ci = TRUE, preset = \"publication\")"
    ),
    DefaultPlacement = c(
      "Main text when targeting, spread, or shared-logit interpretation is central.",
      "Main text or category-functioning subsection for ordered-category interpretation.",
      "Main text or appendix; pair with pathway when category behavior is central.",
      "Appendix, teaching, review, or downstream interactive rendering only.",
      "Main text when precision or targeting across theta is a substantive claim.",
      "Screening dashboard; usually methods appendix or local triage rather than the final main figure.",
      "Case-review appendix or quality-control supplement.",
      "Diagnostic appendix after diagnostic_mode = \"both\".",
      "Main text only if interaction/DFF is a study question; otherwise diagnostic appendix.",
      "Diagnostic appendix or sensitivity discussion.",
      "Teaching material or diagnostic appendix; not a standalone fit claim.",
      "Diagnostic appendix or supplement after a fit screen.",
      "Diagnostic appendix for rater-training/drift review; requires anchor-linked waves.",
      "Diagnostic appendix when rater count makes the bar-chart form too busy.",
      "Diagnostic appendix or data-quality supplement when response-time metadata are available.",
      "Appendix or methods supplement when small-N facet estimates were empirically shrunk."
    ),
    WhatToReport = c(
      "Describe whether persons, facet levels, and thresholds overlap on the same logit scale.",
      "Describe expected-score progression and the theta regions where categories dominate.",
      "Describe whether categories peak in the intended order and whether adjacent curves separate.",
      "Describe it as exploratory category-probability support, not as a default manuscript figure.",
      "Describe where measurement information is highest or weakest across theta.",
      "Describe which components triggered follow-up, not a single pass/fail publication verdict.",
      "Describe which responses or levels need local review.",
      "Describe which facet/category cells or pairwise structures need follow-up.",
      "Describe screened interaction or group-by-facet DFF patterns with low-count and threshold caveats.",
      "Describe residual structure as exploratory follow-up after the main fit screen.",
      "Describe the Guttman-style ordering as a teaching screen and call out where the overlay marks unexpected responses.",
      "Describe tail behavior of person-level residuals as exploratory follow-up, not as a formal normality test.",
      "Describe rater-level movement across waves under the stated linking assumption; name the anchor route explicitly.",
      "Describe pairwise agreement or correlation structure as a compact alternative to the interrater bar chart.",
      "Describe rapid/slow response-time patterns by person, facet, or score category as descriptive QC context.",
      "Describe how far raw facet estimates moved toward the facet mean and whether confidence whiskers remain wide."
    ),
    CaptionSkeleton = c(
      "Figure X. Wright map showing person measures, facet-level locations, and step thresholds on the shared logit scale.",
      "Figure X. Expected score pathway across theta, with dominant-category regions for the fitted rating scale.",
      "Figure X. Category characteristic curves showing fitted category probabilities across theta.",
      "Appendix Figure X. Exploratory category-probability surface showing theta, retained category index, and fitted probability.",
      "Figure X. Test information curve showing where the fitted model provides relatively stronger or weaker measurement precision.",
      "Appendix Figure X. Quality-control dashboard summarizing diagnostic components that require follow-up.",
      "Appendix Figure X. Local response or level-review display for unexpected responses and displacement diagnostics.",
      "Appendix Figure X. Strict marginal diagnostic display for retained facet/category or pairwise follow-up evidence.",
      "Figure/Appendix Figure X. Bias or differential-functioning screening display for the specified facet pair or group contrast.",
      "Appendix Figure X. Residual PCA scree or loading display used for exploratory residual-structure review.",
      "Appendix Figure X. Guttman-style person x facet-level response matrix with unexpected-response overlay.",
      "Appendix Figure X. Normal Q-Q plot of person-level standardized residual aggregates.",
      "Appendix Figure X. Rater severity trajectory across waves under the specified anchor-linking route.",
      "Appendix Figure X. Pairwise rater x rater agreement heatmap for the specified metric.",
      "Appendix Figure X. Descriptive response-time review showing rapid and slow response-time thresholds across rating events.",
      "Appendix Figure X. Empirical-Bayes shrinkage funnel showing raw and shrunken facet-level estimates with confidence whiskers."
    ),
    ResultsWording = c(
      "The Wright map was inspected to evaluate targeting and shared-scale overlap among persons, facet levels, and thresholds.",
      "The pathway plot was inspected to evaluate whether expected scores and dominant-category regions progressed in the intended order.",
      "The category characteristic curves were inspected to evaluate the ordering and separation of fitted response categories.",
      "The category-probability surface was used as exploratory support for understanding the fitted category-probability structure.",
      "The information curve was inspected to identify theta regions with relatively stronger or weaker measurement precision.",
      "The QC dashboard was used as a triage screen to identify components requiring more specific diagnostic follow-up.",
      "Unexpected-response and displacement displays were used to identify local cases or levels requiring review.",
      "Strict marginal displays were used as follow-up evidence for facet/category and pairwise local-dependence patterns.",
      "Bias/DFF displays were used to screen interaction or group-functioning patterns under the documented screening threshold.",
      "Residual PCA displays were used as exploratory follow-up for residual structure after the main model dimension.",
      "The Guttman scalogram was inspected as an exploratory teaching view of person x facet-level response ordering and unexpected responses.",
      "The residual Q-Q plot was inspected as exploratory follow-up on the distribution of person-level standardized residuals.",
      "The rater trajectory plot was inspected, under the stated anchor-linking assumption, to screen for drift across waves.",
      "The pairwise agreement heatmap was inspected as a compact alternative to the bar-chart form of the interrater review.",
      "Response-time summaries were inspected as descriptive quality-control context outside the fitted MFRM likelihood.",
      "The shrinkage funnel was inspected to show which small-N facet levels moved most after empirical-Bayes pooling."
    ),
    WhatNotToClaim = c(
      "Do not present targeting as proof of global model fit.",
      "Do not treat smooth category progression as proof that the rating scale is valid.",
      "Do not overstate overlapping curves as definitive category failure without category counts and context.",
      "Use the surface as exploratory mfrmr output or downstream renderer input; prefer 2D CCC/pathway plots for reports.",
      "Do not ignore the precision tier or approximation caveats used to compute the curve.",
      "Do not cite the dashboard alone as inferential evidence.",
      "Do not interpret a single flagged case as final evidence by itself.",
      "Do not treat strict marginal visuals as standalone hypothesis tests.",
      "Do not claim formal DIF unless the design and inferential route support that wording.",
      "Do not treat residual PCA as a standalone dimensionality test.",
      "Do not treat the scalogram as a global fit claim; it is a teaching-oriented ordering view.",
      "Do not treat the Q-Q plot as a formal normality test.",
      "Do not claim rater drift without an explicit anchor-linking route across the supplied waves.",
      "Do not treat agreement or correlation heatmap cells as formal reliability coefficients.",
      "Do not treat response-time flags as speed-accuracy parameters, cheating proof, or automatic exclusion rules.",
      "Do not treat shrinkage movement as automatic evidence of rater quality or facet bias."
    ),
    BeginnerCheck = c(
      "Check gaps between person density and thresholds/facet levels.",
      "Check whether the dominant-category bands progress in the expected order.",
      "Check whether every retained category has a visible peak or clear role.",
      "Read surface$data$category_support and surface$data$interpretation_guide before rendering.",
      "Check whether the information peak covers the theta region of interest.",
      "Open the component rows or plots behind any dashboard warning.",
      "Sort by magnitude and inspect repeated patterns, not isolated extremes only.",
      "Confirm diagnostic_mode = \"both\" and inspect low-count or sparse-cell caveats.",
      "Confirm the tested facet pair or group-by-facet contrast, low-count cells, and screening threshold.",
      "Start with the scree plot, then inspect loadings only for targeted follow-up.",
      "Check whether the overlay concentrates in a few persons/facet cells rather than spreading uniformly.",
      "Check whether the tails depart sharply from the identity line before claiming non-Gaussian residuals.",
      "Confirm that the waves share an anchor or were post-hoc linked before interpreting movement.",
      "Switch between metric = \"exact\" and metric = \"correlation\" and check that both tell a consistent story.",
      "Start with the distribution plot, then inspect whether rapid/slow rates concentrate in persons or facet levels.",
      "Start with the longest raw-to-shrunken segments and compare their CI width before and after pooling."
    ),
    ThreeDPolicy = c(
      "2D recommended; 3D Wright maps are discouraged.",
      "2D report default.",
      "2D report default.",
      "advanced surface data only; no package-native interactive renderer.",
      "2D information curves available; no package-native 3D information surface.",
      "2D dashboard only; 3D not recommended.",
      "2D point/profile views preferred.",
      "2D heatmap/bar views preferred.",
      "2D heatmap/profile views preferred.",
      "2D scree/loadings preferred.",
      "2D matrix display; 3D not recommended.",
      "2D Q-Q display; 3D not applicable.",
      "2D trajectory display; 3D not recommended.",
      "2D heatmap display; 3D not recommended.",
      "2D distribution and grouped dot displays; 3D not recommended.",
      "2D caterpillar/funnel display; 3D not recommended."
    ),
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1057
.mfrmr_table_mfrmr_interval_guide_out <- data.frame(
    Route = c(
      "Facet-measure fit table",
      "Fit-measure forest plot",
      "Wright map uncertainty overlay",
      "Unified Wright map uncertainty overlay",
      "Rater severity profile",
      "Manuscript Figure 1 composite",
      "Fair-average diagnostic interval",
      "Bias-interaction interval overlay",
      "Displacement interval overlay",
      "Group contrast summary",
      "Facet-equivalence ROPE review",
      "Anchor drift forest plot",
      "Rater trajectory plot",
      "Empirical-Bayes shrinkage funnel",
      "Facet ICC interval review"
    ),
    Scope = c(
      "table,fit,reporting",
      "visual,fit,reporting",
      "visual,fit,reporting",
      "visual,fit,reporting",
      "visual,fit,reporting",
      "visual,fit,reporting",
      "table,visual,gpcm,reporting",
      "visual,bias,gpcm,reporting",
      "visual,linking,reporting",
      "visual,bias,gpcm,reporting",
      "table,visual,equivalence,reporting",
      "visual,linking,gpcm,reporting",
      "visual,linking,gpcm,reporting",
      "visual,shrinkage,reporting",
      "table,visual,hierarchical,reporting"
    ),
    PrimaryHelper = c(
      "fit_measures_table(ci_level = 0.95)",
      "fit_measures_table(...); plot(type = \"measure_ci\", ci_level = 0.95)",
      "plot(fit, type = \"wright\", show_ci = TRUE, ci_level = 0.95)",
      "plot(fit, type = \"wright\", view = \"unified\", show_ci = TRUE, ci_level = 0.95)",
      "plot(fit, type = \"rater_severity\", ci_level = 0.95)",
      "plot(fit, type = \"apa_summary\", ci_level = 0.95)",
      "plot(fit, type = \"fair_average\", show_ci = TRUE, ci_level = 0.95); fair_average_table(fit_gpcm, fair_se = TRUE, ci_level = 0.95)",
      "plot(..., type = \"bias\", show_ci = TRUE, ci_level = 0.95)",
      "plot(..., type = \"displacement\", show_ci = TRUE, ci_level = 0.95)",
      "plot(..., type = \"summary\")",
      "analyze_facet_equivalence(ci_level = 0.95); plot(x, type = \"facet_equivalence\")",
      "detect_anchor_drift(...); plot(drift, type = \"forest\", ci_level = 0.95)",
      "plot(fits[[1L]], type = \"trajectory\", comparison = fits[-1L], labels = names(fits), ci_level = 0.95)",
      "plot(..., type = \"shrinkage\", view = \"funnel\", show_ci = TRUE, ci_level = 0.95); plot(fit, type = \"shrinkage\", show_ci = TRUE, ci_level = 0.95)",
      "compute_facet_icc(ci_method = \"boot\", ci_level = 0.95); plot(analyze_hierarchical_structure(...))"
    ),
    DisplayRoute = c(
      "Use the returned table or facets_table.",
      "Use plot(fit_measures, type = \"measure_ci\", draw = FALSE) for reusable plot data.",
      "Use plot_data(..., component = \"locations\") or draw the ggplot Wright map.",
      "Use plot_data(..., type = \"wright\", view = \"unified\", component = \"locations\") or draw the ggplot Wright map.",
      "Use draw = FALSE to reuse the ranked severity table and band labels.",
      "Use draw = FALSE to reuse wright, severity, threshold, and summary panels.",
      "Use plot_data(..., type = \"fair_average\", show_ci = TRUE); inspect plot_data and notes.",
      "Use ranked or scatter views; heatmap and profile views intentionally omit intervals.",
      "Use view = \"lollipop\" with draw = FALSE for interval-ready data.",
      "Use draw = FALSE when rebuilding the summary figure.",
      "Use eligible MML forest/ROPE output for grand-mean proximity; read pairwise TOST separately.",
      "Use draw = FALSE to inspect CI_Lower / CI_Upper before plotting.",
      "Use linked-wave fit lists only; the helper does not perform linking.",
      "Use on fits augmented by empirical-Bayes shrinkage columns; draw = FALSE returns CI-ready table columns.",
      "Use ICC tables for interval values; plots expose them when finite."
    ),
    DefaultLevel = rep(0.95, 15L),
    IntervalColumns = c(
      "CI_Lower, CI_Upper, CI_Level",
      "CI_Lower, CI_Upper, CI_Level",
      "CI_Lower, CI_Upper, CI_Level in locations",
      "CI_Lower, CI_Upper, CI_Level in locations",
      "Level, Estimate, SE, CI_Lower, CI_Upper, Band",
      "severity panel includes CI_Lower, CI_Upper, ci_level",
      "AdjustedAverageCI_* / StandardizedAdjustedAverageCI_*, FairCIEligible, FairCIReportingUse in tables; CI_Lower / CI_Upper / CI_Level, CI_Eligible, CI_ReportingUse in plot data",
      "CI_Lower, CI_Upper, CI_Level on ranked_table and scatter_data",
      "CI_Lower, CI_Upper, CI_Level",
      "CI_Lower, CI_Upper, CI_Level when contrast SEs are available",
      "CI_Lower, CI_Upper; DeviationCI_Lower, DeviationCI_Upper for plots; CI90_Lower, CI90_Upper for TOST",
      "CI_Lower, CI_Upper, CI_Level",
      "CI_Lower, CI_Upper, CI_Level",
      "RawCI_Lower, RawCI_Upper, ShrunkCI_Lower, ShrunkCI_Upper, CI_Level when show_ci = TRUE",
      "ICC_CI_Lower, ICC_CI_Upper, ICC_CI_Level, ICC_CI_Method"
    ),
    Basis = c(
      "Approximate Wald interval on facet measure: estimate +/- z * SE.",
      "Approximate Wald interval on facet measure recomputed for the requested ci_level.",
      "Approximate facet-level SE overlay on the shared logit scale.",
      "Approximate facet-level SE overlay on the shared logit scale.",
      "Approximate Wald interval around centered facet severity using ModelSE.",
      "Composite overview; interval evidence comes from the rater severity panel.",
      "RSM/PCM plot: focal-measure delta-method interval with thresholds/references fixed. GPCM-MML table/plot: joint structural covariance for non-Person rows, with Person EAP/reference means fixed.",
      "Profile-likelihood limits for GPCM bias rows when available, otherwise per-cell SE fallback.",
      "Approximate Wald interval around displacement using DisplacementSE.",
      "Residual contrast approximation or refit conditional plug-in interval; refit SEs omit baseline-anchor uncertainty and cross-refit covariance.",
      "Joint MML covariance for pair differences and deviations from the equally weighted facet mean.",
      "Approximate drift interval using supplied anchor-drift SE columns.",
      "Approximate per-rater severity interval across already linked waves.",
      "Descriptive normal bands from original and plug-in shrunken SEs; variance estimates are held fixed.",
      "Explicit parametric percentile bootstrap of refitted ICC ratios; the default supplies point estimates only."
    ),
    UseFor = c(
      "Report facet estimates with uncertainty in tables.",
      "Show which facet levels have wide measure uncertainty before discussing fit flags.",
      "Show targeting and location uncertainty on a compact variable map.",
      "Show targeting and uncertainty across persons, facets, and thresholds.",
      "Compare signed rater locations and qualified uncertainty; neutral guides are optional.",
      "Build a manuscript Figure 1 overview while preserving reusable panel data.",
      "Inspect fair-score uncertainty separately from historical measure-level SE columns; FairZ is not a z-score.",
      "Screen interaction-bias cells while showing uncertainty around the bias-size estimate.",
      "Review anchor or calibration tension without treating displacement as a binary decision.",
      "Describe group residual differences; linked refit intervals require separate uncertainty review.",
      "Decide whether an interval lies within, overlaps, or falls outside the practical equivalence band.",
      "Review whether common elements drift materially across forms or waves.",
      "Inspect rater movement across anchored waves or training occasions.",
      "Show how much partial pooling moved noisy facet estimates.",
      "Report clustering / nesting uncertainty without treating ICC alone as a design decision."
    ),
    InterpretationBoundary = c(
      "CI width is precision evidence, not a fit pass/fail rule.",
      "Fit status still comes from MnSq/ZSTD review; the CI plot is a precision display.",
      "Use for targeting and uncertainty context; it is not global model-fit proof.",
      "Use for targeting and uncertainty context; it is not global model-fit proof.",
      "Distance-from-zero guides are not homogeneity, equivalence or rater-quality decisions; use covariance-aware contrasts and a justified practical bound.",
      "Composite figures orient readers; panel intervals should be interpreted through the source helper.",
      "Diagnostic-only: CI_Eligible / FairCIEligible remain FALSE; finite or regularized covariance does not establish full-refit coverage. Gap whiskers hold the observed mean fixed.",
      "Bias intervals remain screening evidence unless the study design supports stronger inferential wording.",
      "Intervals support follow-up review; they do not decide anchor validity by themselves.",
      "Both routes remain screening-only; adequate linking does not make refit uncertainty formally eligible. Inspect ContrastDirection because residual and severity contrasts use different units and signs.",
      "Requires inference-ready MML and unregularized covariance; pairwise TOST is unadjusted and ROPE is descriptive.",
      "Drift claims require explicit multi-fit wave or form designs.",
      "Trajectory movement is interpretable only after the supplied fits are on a common scale.",
      "No calibrated coverage or automatic rater-quality decision: prior-variance uncertainty and cross-level covariance are omitted; zero width after full pooling is not perfect precision.",
      "ICC intervals describe clustering uncertainty, not model adequacy by themselves."
    ),
    GPCMStatus = c(
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "rsm_pcm_route; GPCM manuscript claims require explicit capability caveat",
      "supported_with_caveat",
      "supported_with_caveat",
      "exploratory_only",
      "supported_with_caveat",
      "unavailable_when_gpcm_inference_is_ineligible",
      "exploratory_for_gpcm; linking synthesis supported_with_caveat",
      "exploratory_for_gpcm; linking synthesis supported_with_caveat",
      "not_gpcm_specific",
      "not_gpcm_specific"
    ),
    Notes = c(
      "The helper already adds CI columns to the returned fit-measure table.",
      "Use this when reviewers ask for a forest-style estimate display.",
      "The standard plot route also accepts show_ci and ci_level.",
      "This explicit helper is useful for publication-style maps.",
      "Use facet = ... for non-Rater severity facets.",
      "Designed for RSM/PCM manuscript routes; inspect returned panel data before publication.",
      "The table fair_se option provides GPCM-MML structural SEs, not RSM/PCM fair-score SEs; RSM/PCM conditional plot intervals require a fitted model, not only a stored table bundle.",
      "Heatmaps remain pattern displays and do not draw intervals.",
      "Best used after reviewing the underlying displacement table.",
      "Use together with mfrm_report(dif, type = 'dff') for narrative boundaries.",
      "The deprecated conf_level alias still routes to ci_level with a warning.",
      "Pair with build_linking_review() only where that route is in scope.",
      "Use with anchor-linked waves, not independent raw calibrations.",
      "Requires empirical-Bayes shrinkage output; ordinary fits do not carry all shrinkage columns.",
      "Requires lme4 for the fitted random-intercept model. Inspect bootstrap failures and ICC_CI_Status; the former profile method is withdrawn."
    ),
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1232
.mfrmr_table_mfrmr_interval_guide_data <- data.frame(
    Route = c("Fixed-facet model/sandwich intervals", "Assigned-score MI facet intervals"),
    Scope = c("table,visual,fit,gpcm,reporting", "table,visual,fit,reporting"),
    PrimaryHelper = c(
      "mfrm_facet_intervals(fit, facet, method = \"model\", level = 0.95)",
      "pool_mfrm_imputed(analyses, facet, ci_level = 0.95)"
    ),
    DisplayRoute = c(
      "For supported MML fits, use plot(result), as_ggplot(result), apa_table(result), or attach it with mfrm_results(fit, intervals = list(raters = result), compute = \"never\"). See the separate CML and MML interaction routes below.",
      "Use summary(result) or plot(result, draw = FALSE)."
    ),
    DefaultLevel = c(0.95, 0.95),
    IntervalColumns = c(
      "Lower, Upper, SE, ModelLower, ModelUpper, ModelSE, Status; CIEligible and CoverageQualified on experimental routes",
      "Lower, Upper, SE, DF, Status"
    ),
    Basis = c(
      "Pointwise normal intervals from full observed-information or one-way cluster sandwich covariance; estimates are unchanged.",
      "Rubin pooling of full within-imputation model covariance and between-imputation covariance, with scalar t reference."
    ),
    UseFor = c(
      "Compare uncertainty for fixed facet estimates and prespecified within-facet contrasts from supported MML fits, including rater differences.",
      "Report eligible fixed facet estimates and contrasts after proper imputation of missing assigned scores."
    ),
    InterpretationBoundary = c(
      "Sandwich support is limited to fixed-population RSM/PCM and requires many independent Persons or declared larger clusters. One-family GPCM locations use model-information Wald intervals under regular MML assumptions; two-family locations remain experimental. Location differences need not be uniform rating differences. Finite-sample coverage is not guaranteed.",
      "Depends on adequate imputations and complete-data inference; excludes EAP pooling, sandwich pooling and simultaneous rater decisions."
    ),
    GPCMStatus = c("supported_with_caveat one-family MML locations; experimental two-family; no JML or GPCM sandwich", "unavailable; RSM/PCM MML only"),
    Notes = c(
      "Unit weights and unregularized joint information. Native-location extensions include estimated normal RSM/PCM populations and fixed or intercept-only normal one-family GPCM; two families use fixed N(0,1). Inspect helper-specific scope, Status and scale; standardized contrasts include estimated population-SD uncertainty.",
      "All completions must qualify on a common identified scale; unassigned events stay unassigned. Inspect Status and the imputation model."
    ),
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1268
.mfrmr_table_mfrmr_interval_guide_data_1 <- data.frame(
    Route = c("CML conditional-information intervals", "MML interaction-contrast intervals"),
    Scope = rep("table,visual,fit,reporting", 2),
    PrimaryHelper = c(
      "mfrm_facet_intervals(fit, level = 0.95)",
      "mfrm_facet_intervals(fit, comparison_review = review, scale = \"standardized\", level = 0.95)"
    ),
    DisplayRoute = c(
      "summary(result), plot(result), as_ggplot(result), apa_table(result) and saveRDS(result); CML does not support mfrm_results().",
      "summary(result), plot(result), as_ggplot(result), apa_table(result) and saveRDS(result); attach with mfrm_results(fit, intervals = list(comparisons = result), compute = \"never\") for reports and saved plot type = 'facet_comparisons'."
    ),
    DefaultLevel = rep(0.95, 2),
    IntervalColumns = c(
      "Estimate, SE, Lower, Upper, Status, CIEligible, InferenceReview; comparison-only results also retain ConditionalState, IdentificationBasis and EstimateReason",
      "Estimate, NativeEstimate, SE, Lower, Upper, CIEligible, CoverageQualified, IdentificationBasis, MarginalIdentificationState"
    ),
    Basis = c(
      "Pointwise asymptotic Wald intervals from joint conditional information after conditioning on each Person's total and observed roster; comparison-only results reuse saved identified-subspace covariance.",
      "Pointwise model-information intervals from the full joint MML covariance. Standardized contrasts use the joint delta-method derivative of contrast/population SD, including SD uncertainty and cross-covariance."
    ),
    UseFor = c(
      "Read requested contrasts from a CML fit_scope = 'comparisons' result. For a full mfrm_cml_fit, add facet and optional named contrasts to the helper call.",
      "Read declared facet-by-origin contrasts from a matching full native RSM/PCM MML interaction fit; use scale = 'native' for original fitted units."
    ),
    InterpretationBoundary = c(
      "Native units only; CML supplies no population SD, Person abilities, ordinary diagnostics or consolidated reports. Unidentified targets stay missing. Finite-MLE and information checks do not guarantee finite-sample coverage.",
      "Estimated-SD standardization requires a common intercept-only normal population; a regression residual SD is not marginal population SD. Native intervals also admit origin-specific population means. Numerical eligibility and conditional identification are separate from global marginal identification and finite-sample coverage. JML/MML comparison-only fits remain descriptive."
    ),
    GPCMStatus = rep("unavailable; RSM/PCM only", 2),
    Notes = c(
      "Requires method = 'model' and scale = 'native'. Omit comparison_review and contrasts for comparison-only fits: targets and checks are already saved. Retain missing rows, reasons, target weights and joint covariance when saving; see online linking and DFF guide (https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-linking-and-dff.html).",
      "Requires method = 'model', unit weights and a matching review. Fixed N(0,1) has known SD 1; an estimated SD comes from this same fit, never external or empirical Person scores. Inspect helper-specific model, source and numerical checks and retained population assumptions; see online linking and DFF guide (https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-linking-and-dff.html)."
    ),
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1304
.mfrmr_table_mfrmr_interval_guide_data_2 <- data.frame(
    Route = "Conditional-normal population intervals",
    Scope = "table,fit,reporting,visual",
    PrimaryHelper = "mfrm_population_intervals(fit, level = 0.95, contrasts = L)",
    DisplayRoute = "summary(ci), vcov(ci), apa_table(ci), plot(ci) or plot(ci, type = 'contrasts'); as_ggplot(ci) reuses saved values. Attach with mfrm_results(fit, intervals = list(population = ci), compute = \"never\") for reports and table exports.",
    DefaultLevel = 0.95,
    IntervalColumns = "Lower, Upper, SE, WorkingLower, WorkingUpper, WorkingSE, NaturalScaleStatus, Status, CIEligible, InferenceReview",
    Basis = "Pointwise normal coefficient/contrast intervals and exponentiated log-variance intervals, using the inverse full joint MML information including nuisance parameters.",
    UseFor = "Estimate conditional population means, prespecified linear combinations and residual population variance under the fitted predictor coding.",
    InterpretationBoundary = "Experimental RSM/PCM direct MML only. CIEligible describes numerical availability, not established coverage. Not individual ability differences, causal effects, zero-variance boundary inference or calibration-inclusive Person intervals.",
    GPCMStatus = "unavailable; estimated normal RSM/PCM population only",
    Notes = "Use contrasts = NULL for coefficients and variance only, or supply L with fitted coefficient column names. Requires unit weights, full-rank coding, unanchored centered facets/steps and no interactions. Retain checks, unavailable rows and interpretation_notes; vcov(ci) uses coefficient/log-variance coordinates, with contrast_covariance stored separately. Plots separate coefficients from contrasts, retain unavailable rows and exclude residual variance from their native-ability axis; inspect population_coding, population_spec and contrast_weights in plot_data().",
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1319
.mfrmr_table_mfrmr_interval_guide_data_3 <- data.frame(
    Route = c("Observed random-rater explicit normal approximation", "Observed random-rater bootstrap intervals",
      "Random-rater population SD profile"),
    Scope = c("table,visual,fit,reporting", "table,visual,fit,reporting", "table,fit,reporting"),
    PrimaryHelper = c("confint(fit, parm = \"raters\", level = 0.95)",
      "mfrm_random_rater_intervals(fit, nsim = 499, seed = 123, level = 0.95)",
      "confint(fit, parm = \"rater_sd\", level = 0.95)"),
    DisplayRoute = c("Use plot(fit, intervals = \"normal\", draw = FALSE); defaults show point estimates only.",
      "Use plot(result, draw = FALSE), summary(result) or confint(result).",
      "Inspect the interval and its profile attribute."),
    DefaultLevel = rep(0.95, 3),
    IntervalColumns = c("Lower, Upper; IntervalStatus, CIEligible, InferenceReview in diagnostics; source checks attribute", "Lower, Upper; availability attribute",
      "Lower, Upper; profile attribute"),
    Basis = c("Normal prediction interval with first-order calibration-adjusted prediction SE.",
      "Full-refit parametric prediction-error bootstrap; studentized by default, unscaled error comparison available.",
      "Profile likelihood with an asymptotic one-degree chi-square cutoff; includes zero."),
    UseFor = c("Describe realized observed-rater effects relative to the assumed population mean.",
      "Compare model-based pointwise prediction intervals for the same realized observed-rater target.",
      "Estimate variation across the assumed rater population, including at an estimated zero variance."),
    InterpretationBoundary = c("Nominal coverage is not established; explicit approximation only, not a quality classification. Automatic bounds are withheld.",
      "Positive source SD/SE required. Unresolved roots can give unbounded limits; no general coverage or familywise guarantee.",
      "This is a population-variation target, not an interval for any one rater or future score; finite-sample accuracy is not guaranteed."),
    GPCMStatus = rep("unavailable; shared-rater RSM only", 3),
    Notes = c("Numerical/information failures and estimated variance boundaries withhold regular intervals.",
      "Generate from the fitted ability population and refit estimated SDs. Preserve all planned draws and inspect tail resolution; saved roots support new levels without refitting.",
      "Profiles need RTMB and refit estimated ability SD; an estimated ability-variance boundary blocks this profile. Failed checks retain the evaluated profile."),
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1348
.mfrmr_table_mfrmr_interval_guide_data_4 <- data.frame(
    Route = c("Testlet fixed-facet calibration", "Testlet conditional Person scores"),
    Scope = rep("table,visual,fit,reporting", 2),
    PrimaryHelper = c("confint(fit, parm = 'calibration', level = 0.95)", "predict(testlet_fit, newdata)"),
    DisplayRoute = c("Use plot(fit, facet = 'Rater', intervals = 'normal', level = 0.95) or summary(fit, calibration_intervals = 'normal'). Defaults omit bounds.",
      "Use scores$table, summary(scores), plot(scores, draw = FALSE) or as_ggplot(scores)."),
    DefaultLevel = rep(0.95, 2),
    IntervalColumns = c("Lower, Upper; Estimate, SE, IntervalStatus, CIEligible, InferenceReview in diagnostics; source checks attribute", "Lower, Upper, ConditionalSD, Status, Reason"),
    Basis = c("Explicit observed-information normal approximation for fixed facets and steps in the Person-specific testlet RSM.",
      "Continuous equal-tail posterior intervals conditional on calibration and the fitted or specified normal Person population."),
    UseFor = c("Describe fixed facet effects while modeling dependence within Person/testlet blocks.",
      "Score all supplied ratings jointly for a Person without re-estimating calibration."),
    InterpretationBoundary = c("Finite-sample coverage is not established. Estimated variance boundaries withhold bounds; no regular variance interval is supplied.",
      "Excludes calibration/population estimation uncertainty, Person-contrast inference and simultaneous decisions. Missing Persons return the prior only; zero ability variance withholds scores."),
    GPCMStatus = rep("unavailable; Person-specific testlet RSM only", 2),
    Notes = c("Numerical and information checks must pass. Not a random rater shared across Persons.",
      "Unavailable rows retain reasons; new fixed-facet levels are refused. Supply the complete rating set for each Person. Small calibration samples can reduce marginal interval coverage; see online testlet guide (https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-testlets.html)."),
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1368
.mfrmr_table_mfrmr_interval_guide_data_5 <- data.frame(
    Route = "Shared-rater fixed-facet and step calibration", Scope = "table,fit,reporting",
    PrimaryHelper = "confint(fit, parm = 'calibration', level = 0.95)",
    DisplayRoute = "Use summary(fit, calibration_intervals = 'normal', level = 0.95) or mfrm_results(fit, calibration_intervals = 'normal', calibration_level = 0.95). Defaults omit bounds.",
    DefaultLevel = 0.95, IntervalColumns = "Lower, Upper; Estimate, SE, IntervalStatus, CIEligible, InferenceReview in diagnostics; source checks attribute",
    Basis = "Explicit observed-information normal approximation for fixed facets and steps in the shared-rater RSM.",
    UseFor = "Describe calibration effects separately from realized rater effects and population SDs.",
    InterpretationBoundary = "Finite-sample coverage is not established. Numerical/information failures and estimated variance boundaries withhold bounds.",
    GPCMStatus = "unavailable; shared-rater RSM only",
    Notes = "Uses saved estimates and SEs without refitting. Rebuild output from older fits to apply the default; older result bundles retain their stored tables.",
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1381
.mfrmr_table_mfrmr_interval_guide_data_6 <- data.frame(
    Route = "Shared-rater conditional Person scores", Scope = "table,visual,fit,reporting",
    PrimaryHelper = "score_mfrm_random_rater(fit, persons = ids)",
    DisplayRoute = "Use scores$table, summary(scores), plot(scores) or as_ggplot(scores); attach with mfrm_results(fit, scores = scores).",
    DefaultLevel = 0.95, IntervalColumns = "Lower, Upper, ConditionalSD, Status, Reason",
    Basis = "Continuous marginal posterior with joint conditional rater Laplace integration and calibration held fixed.",
    UseFor = "Score requested Persons while retaining the complete scoring roster and shared-rater uncertainty.",
    InterpretationBoundary = "Excludes calibration/population estimation uncertainty, Person contrasts and coverage guarantees. Numerical checks do not certify Laplace accuracy.",
    GPCMStatus = "unavailable; shared-rater RSM only",
    Notes = "persons selects outputs, not data. newdata replaces the entire roster. Prior-only and unavailable rows remain explicit.",
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1394
.mfrmr_table_mfrmr_interval_guide_data_7 <- data.frame(
    Route = "GPCM relative-slope intervals", Scope = "gpcm,visual,table,fit,reporting",
    PrimaryHelper = "confint(fit, parm = \"slopes\", level = 0.95)",
    DisplayRoute = "plot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(slopes = result)). diagnose_mfrm() retains default relative/model intervals.",
    DefaultLevel = 0.95, IntervalColumns = "Lower, Upper; CIEligible, CIUse, InferenceReview in diagnostics",
    Basis = "Pointwise log-Wald intervals from the inverse full joint MML observed information, with sum-zero log-slope transformation.",
    UseFor = "Sampling uncertainty in relative discriminations with geometric mean one.",
    InterpretationBoundary = "Default relative/model target; explicit options select standardized slopes, contrasts, sandwich or Bonferroni intervals. These are not rater-quality intervals or general coverage guarantees.",
    GPCMStatus = "supported_with_caveat; eligible one-family GPCM MML only",
    Notes = "Requires current likelihood metadata, adequate convergence/categories, unit weights, q>=31 and positive unregularized information. Ordinary Wright/Pathway maps do not display these slope intervals.",
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1407
.mfrmr_table_mfrmr_interval_guide_data_8 <- data.frame(
    Route = c("GMFRM component-slope intervals", "GPCM slope profile intervals",
      "Corrected-JML local root uncertainty", "GMFRM step-offset intervals"),
    Scope = c("gpcm,visual,table,fit,reporting", "gpcm,visual,table,fit,reporting",
      "gpcm,table,fit,reporting", "gpcm,visual,table,fit,reporting"),
    PrimaryHelper = c("confint(fit, parm = \"slopes\", level = 0.95)",
      "confint(fit, parm = \"slopes\", method = \"profile\", slope = selected_slope, level = 0.95)",
      "summary(fit)$tables$uncertainty; summary(fit)$tables$slopes",
      "confint(fit, parm = \"steps\", level = 0.95)"),
    DisplayRoute = c(
      "plot(result), apa_table(result); attach with mfrm_results(fit, intervals = list(slopes = result)).",
      "print(result), plot(result), apa_table(result, which = \"profile_endpoints\"); attach the selected profile to mfrm_results().",
      "summary(fit), mfrm_results(fit), mfrm_report(); point-only plots have no structural confidence bounds.",
      "summary(result), plot(result), apa_table(result); attach with mfrm_results(fit, intervals = list(steps = result))."),
    DefaultLevel = c(.95, .95, NA_real_, .95),
    IntervalColumns = c(
      "Lower, Upper; CIEligible, CoverageQualified, InferenceReview in diagnostics",
      "Lower, Upper; CI_Lower, CI_Upper, CIEligible, CIUse, InferenceReview in diagnostics; endpoint status in the profile table",
      "RootSE, LogRootSE; no structural Lower or Upper bounds",
      "StepOwner, StepLevel, Step, Estimate, SE, Lower, Upper, Status, CIEligible, CoverageQualified, InferenceReview"),
    Basis = c(
      "Experimental component log-Wald intervals from full joint MML information on the fixed N(0,1) population scale.",
      "Experimental likelihood-ratio inversion for one selected slope with an asymptotic chi-square(1) reference.",
      "Experimental full estimating-equation covariance around the adjusted root under the declared Person/roster sampling law.",
      "Experimental pointwise normal intervals using constrained steps and full joint marginal information."),
    UseFor = c("Inspect uncertainty about either owner's component discrimination.",
      "Inspect asymmetric slope uncertainty and retain partial or unbounded outcomes.",
      "Describe local variation separately from remaining structural estimation bias.",
      "Inspect uncertainty in within-level category-step offsets."),
    InterpretationBoundary = c(
      "CIEligible is numerical availability; CoverageQualified remains FALSE. The first family has geometric mean one; the second is free. No two-family sandwich or slope-contrast intervals.",
      "Computed bounds do not prove nominal coverage. An unresolved side is not an infinite limit or a calibrated one-sided interval; search limits are not endpoints.",
      "RootSE is not a qualified structural confidence interval. A covariance or t adjustment alone cannot remove residual bias.",
      "Not location-inclusive category boundaries or ordering tests. Binary fixed steps have no inferential interval; coverage is unqualified."),
    GPCMStatus = c("experimental two-family MML only; coverage unqualified",
      "experimental one- and two-family MML only; no JML profiles",
      "experimental corrected JML only; structural intervals unavailable",
      "experimental two-family MML only; coverage unqualified"),
    Notes = c("Uses the fitted fixed-grid EM or adaptive direct integration route; scale defaults to standardized. Not an interval for the product of two slopes or for rater quality.",
      "Select one exact slope level; for two families use a named owner/level value. Profiling refits nuisance parameters and can be costly; displaying saved results does not refit.",
      "Inspect correction order, sampling law, point status and covariance reason. Conditional Person posterior intervals are a different target; see mfrmr_output_guide(\"gpcm_capabilities\").",
      "Dependent steps retain cross-covariances; numerical refusals retain reasons and missing bounds. Ordinary intervals after a limiting reduction are unavailable."),
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1444
.mfrmr_table_mfrmr_interval_guide_data_9 <- data.frame(
    Route = c("GPCM curve uncertainty", "GPCM bootstrap slope intervals"),
    Scope = "gpcm,visual,table,reporting",
    PrimaryHelper = c("mfrm_curve_intervals(fit, grid)", "confint(bootstrap_mfrm_gpcm(fit, seed = 123))"),
    DisplayRoute = "plot(result), as_ggplot(result), apa_table(result), plot_data(result); attach with mfrm_results(fit, intervals = list(uncertainty = result)).",
    DefaultLevel = .95,
    IntervalColumns = c("Lower, Upper, CIEligible, InferenceReview", "Matrix bounds; diagnostics and availability attributes"),
    Basis = c("Full calibration covariance at fixed native-scale ability and rating context; logit or log transformation.",
      "Fitted-model basic bootstrap errors; unresolved refits enclose all possible empirical limits."),
    UseFor = c("Uncertainty in category probabilities or information per rating.", "Approximate slope uncertainty under the fitted population and analyzed assignment."),
    InterpretationBoundary = c("Not Person-score intervals or a continuous simultaneous confidence band.",
      "Not an exact small-sample method; failed refits can leave infinite bounds. Null-model LRT draws cannot supply slope intervals."),
    GPCMStatus = "supported_with_caveat; eligible one-family GPCM MML only",
    Notes = c("Default model covariance and pointwise intervals; sandwich and finite-grid Bonferroni are explicit options.",
      "Default relative 95% pointwise intervals; select scale, level and contrasts explicitly. Generating the bootstrap can be costly; displaying saved output does not refit."),
    stringsAsFactors = FALSE
  )
# From help_visual_diagnostics.R:1462
.mfrmr_table_mfrmr_interval_guide_data_10 <- data.frame(
    Route = "Binary rater-network coefficient intervals",
    Scope = "table,visual,reporting",
    PrimaryHelper = "fit_rater_network(...); confint(model, level = 0.95)",
    DisplayRoute = "summary(model); plot(model, type = 'coefficients'); mfrm_report(model)",
    DefaultLevel = .95,
    IntervalColumns = "Percentage-labelled bounds; diagnostics and notes attributes",
    Basis = "Approximate pointwise normal ERGM coefficient intervals in conditional log-odds coordinates.",
    UseFor = "Prespecified binary network configurations or node covariates, after estimation diagnostics.",
    InterpretationBoundary = "Not MFRM parameters, causal halo or estimated-edge uncertainty; backend failure keeps missing bounds.",
    GPCMStatus = "Network likelihood, not a GPCM rating likelihood",
    Notes = "Changing confint level does not change the stored 95% coefficient table/plot. Review MCMC and GOF; numerical availability is not convergence certification.",
    stringsAsFactors = FALSE)

# --- Phase B1 extracted pure constants and feature-coverage table ---
.mfrmr_const_.gpcm_unavailable_routes <- structure(list(Area = c("FACETS output-contract score-side review", 
"Native MCMC and posterior-predictive sampling", "Formal structural confidence intervals for corrected JML"
), Helper = c("facets_output_contract_review()", NA, NA), Status = c("blocked", 
"deferred", "deferred"), Boundary = c("Limited to direct scorefile export rather than the full FACETS-style output-contract review. Direct scorefile export is available with caveats, but contract-wide coverage and metric claims still require a broader free-discrimination score-side review contract.", 
"mfrmr does not run native GPCM MCMC or posterior-predictive sampling. export_mfrm_model() writes Stan/brms code for eligible one-family MML sources and Stan code for two-family sources, adding explicit structural priors and retaining supported fixed constraints. Conditional posterior response diagnostics are a different, non-MCMC calculation.", 
"Formal corrected-JML structural intervals are unavailable. The explicit corrected estimator reports local adjusted-equation RootSE, not established structural coverage. Uncorrected JML location SEs and post-hoc Person intervals answer different questions. None is a bias-corrected structural confidence interval."
), RecommendedRoute = c("Use direct fair-average tables and graph-only compatibility outputs; use package-native scorefile export with its stated caveats, and keep full FACETS output-contract reviews on the `RSM` / `PCM` route.", 
"Use MML and conditional posterior scoring for their stated targets. Use export_mfrm_model(format = 'stan' or 'brms') for eligible one-family sources, or format = 'stan' for two-family sources. Then review priors, sampler diagnostics and posterior fit; code export is not native Bayesian estimation.", 
"Use current JML outputs within their descriptive scope, or explicitly choose MML inference if its population assumptions suit the analysis; do not transfer MML intervals to JML."
)), class = "data.frame", row.names = c(NA, -3L))
.mfrmr_const_.mfrm_review_report_classes <- c("mfrm_bias", "mfrm_anchor_review", "mfrm_linking_review", "mfrm_model_choice_review"
)
.mfrmr_const_.mfrm_study_report_classes <- c("mfrm_multivariate_gstudy", "mfrm_design_recommendation", "mfrm_d_study", 
"mfrm_multivariate_d_study", "mfrm_multivariate_d_comparison", 
"mfrm_residual_network", "mfrm_rater_network", "mfrm_halo_network", 
"mfrm_network_ergm", "mfrm_posterior_summary", "mfrm_posterior_scores", 
"mfrm_bias_collection", "mfrm_bias", "mfrm_anchor_review", "mfrm_linking_review", 
"mfrm_model_choice_review")
.mfrmr_const_.mfrm_step_interpretation_note <- "A Step describes the transition between adjacent score categories, not a learning stage or a pass/fail cut. At the corresponding predictor value, the two categories have equal probability, not necessarily probability 0.5 each. Stored step offsets and full ability-axis crossings differ when other facet effects or interactions are included; check the reference profile and step owner."
.mfrmr_const_.mfrmr_plot_guide <- structure(list(Question = c("Inspect signed pairwise rater agreement", 
"Compare weighted network inconsistency indices", "Inspect conditional binary-network coefficients", 
"Compare a binary network with model simulations", "Compare persons, facet levels and category steps", 
"Show expected scores across ability", "Review severity together with response fit", 
"Compare facet locations and their uncertainty", "Inspect category functioning", 
"Review pooled category counts", "Review steps within their threshold owner", 
"Compare category curve families", "Compare group-pair DFF / DIF values on a 2D scatterplot", 
"Compare fixed-rater estimates and interval methods", "Review conditional interaction departures", 
"Explore bias across all facet pairs", "Read latent-regression coefficients and uncertainty", 
"Read prespecified conditional population contrasts", "Compare same-rater and other-rater score associations", 
"Show GPCM slope uncertainty", "Show GPCM probability or information uncertainty", 
"Compare observed raters in a shared-rater model", "Inspect testlet-model facet estimates", 
"Review conditional Person scores from a shared-rater model", 
"Review conditional Person scores from a testlet model", "Review response residuals under supported RSMs, two-family GPCM MML or corrected GPCM JML", 
"Compare ordinary and extended model results", "Compare screening rules across known-truth conditions", 
"Show screening performance with uncertainty", "Show pooled fixed-facet intervals after multiple imputation", 
"Report saved external posterior intervals", "Review new-Person Bayesian posterior scores and variance sources", 
"Inspect all residual associations and missing pairs", "Locate residual co-movement after model review", 
"Inspect exploratory groups of residual profiles", "Inspect separation of external-feature groups", 
"Describe an external feature within groups", "Inspect a hierarchy of external-feature groups", 
"Inspect group stability across feature imputations", "Choose how many external-feature components to inspect", 
"Locate entities on external-feature components", "Identify features contributing to a component", 
"Plan facet counts with an observed-score D-study", "Inspect sources of observed-score variation", 
"Plan reliability for a multivariate score or composite", "Plan absolute or relative error in score units", 
"Explain which error sources change across plans", "Compare D-study plans including the reference", 
"Inspect observed coverage across rating subsets", "Customize the underlying precision values"
), InputClass = c("mfrm_rater_network", "mfrm_rater_network", 
"mfrm_network_ergm", "mfrm_network_ergm", "mfrm_fit", "mfrm_fit", 
"mfrm_fit", "mfrm_fit", "mfrm_fit", "mfrm_rating_scale", "mfrm_rating_scale", 
"mfrm_category_curves", "mfrm_dif", "mfrm_facet_intervals", "mfrm_bias_interaction", 
"mfrm_bias_collection", "mfrm_population_intervals", "mfrm_population_intervals", 
"mfrm_halo_network", "mfrm_slope_intervals", "mfrm_curve_intervals", 
"mfrm_random_rater", "mfrm_testlet", "mfrm_random_rater_scores", 
"mfrm_testlet_scores", "mfrm_response_diagnostics", "mfrm_extended_comparison", 
"mfrm_screening_sensitivity", "mfrm_screening_performance", "mfrm_pooled", 
"mfrm_posterior_summary", "mfrm_posterior_scores", "mfrm_residual_network", 
"mfrm_residual_network", "mfrm_residual_network", "mfrm_clusters", 
"mfrm_clusters", "mfrm_hierarchical_clusters", "mfrm_imputed_clusters", 
"mfrm_pca", "mfrm_pca", "mfrm_pca", "mfrm_d_study", "mfrm_multivariate_gstudy", 
"mfrm_multivariate_d_study", "mfrm_multivariate_d_study", "mfrm_multivariate_d_study", 
"mfrm_multivariate_d_comparison", "mfrm_bundle", "mfrm_information"
), PlotCall = c("plot(x, type = \"network\", draw = FALSE)", 
"plot(x, type = \"fit\", metric = \"SWS\", draw = FALSE)", "plot(x, type = \"coefficients\", draw = FALSE)", 
"plot(x, type = \"gof\", draw = FALSE)", "plot(x, type = \"wright\", draw = FALSE)", 
"plot(x, type = \"pathway\", draw = FALSE)", "plot(x, type = \"fit_pathway\", draw = FALSE)", 
"plot(x, type = \"rater_severity\", draw = FALSE)", "plot(x, type = \"ccc\", draw = FALSE)", 
"plot(x, type = \"counts\", draw = FALSE)", "plot(x, type = \"thresholds\", draw = FALSE)", 
"plot(x, draw = FALSE)", "plot(x, type = \"scatter\", draw = FALSE)", 
"plot(x, draw = FALSE)", "plot(x, type = \"scatter\", show_ci = TRUE, draw = FALSE)", 
"plot(x, draw = FALSE)", "plot(x, draw = FALSE)", "plot(x, type = \"contrasts\", draw = FALSE)", 
"plot(x, type = \"edge_distribution\", draw = FALSE)", "plot(x, draw = FALSE)", 
"plot(x, draw = FALSE)", "plot(x, draw = FALSE)", "plot(x, draw = FALSE)", 
"plot(x, draw = FALSE)", "plot(x, draw = FALSE)", "plot(x, draw = FALSE)", 
"plot(x, draw = FALSE)", "plot(x, draw = FALSE)", "plot(x, draw = FALSE)", 
"plot(x, draw = FALSE)", "plot(x, quantity = \"location\", draw = FALSE)", 
"plot(x, type = \"intervals\", draw = FALSE)", "plot(x, type = \"matrix\", draw = FALSE)", 
"plot(x, type = \"network\", draw = FALSE)", "plot(x, type = \"dendrogram\", draw = FALSE)", 
"plot(x, type = \"silhouette\", draw = FALSE)", "plot(x, type = \"profile\", feature = \"Years\", draw = FALSE)", 
"plot(x, type = \"dendrogram\", draw = FALSE)", "plot(x, draw = FALSE)", 
"plot(x, type = \"scree\", draw = FALSE)", "plot(x, type = \"scores\", draw = FALSE)", 
"plot(x, type = \"loadings\", draw = FALSE)", "plot(x, type = \"coefficients\", draw = FALSE)", 
"plot(x, draw = FALSE)", "plot(x, type = \"coefficients\", draw = FALSE)", 
"plot(x, type = \"sem\", draw = FALSE)", "plot(x, type = \"error_components\", draw = FALSE)", 
"plot(x, type = \"coefficients\", draw = FALSE)", "plot(x, type = \"design_matrix\", draw = FALSE)", 
"plot(x, type = \"tif\", draw = FALSE)"), PlotName = c("rater_network", 
"rater_network", "network_ergm", "network_ergm", "wright_map", 
"pathway_map", "fit_pathway", "rater_severity_profile", "category_characteristic_curves", 
"rating_scale", "rating_scale", "category_curves", "dif_scatter", 
"facet_interval_methods", "table13_bias", "bias_collection", 
"population_intervals", "population_intervals", "halo_network", 
"gpcm_slope_intervals", "gpcm_curve_intervals", "random_rater_severity", 
"testlet_calibration", "random_rater_scores", "testlet_scores", 
"response_diagnostics", "extended_model_comparison", "screening_sensitivity", 
"screening_performance", "pooled_facet_intervals", "posterior_intervals", 
"posterior_scores", "local_dependence_heatmap", "residual_network", 
"residual_network", "cluster_silhouette", "cluster_profile", 
"cluster_dendrogram", "cluster_co_membership", "feature_pca_scree", 
"feature_pca_scores", "feature_pca_loadings", "d_study", "multivariate_gstudy", 
"multivariate_d_study", "multivariate_d_study", "multivariate_d_study", 
"multivariate_d_comparison", "subset_connectivity", "information_tif"
), DataComponent = c("edges", "table", "table", "draws", "locations", 
"expected", "table", "data", "probabilities", "category_table", 
"threshold_table", "plot_long", "data", "table", "scatter_data", 
"table", "table", "table", "table", "table", "table", "table", 
"table", "table", "table", "table", "table", "table", "table", 
"table", "table", "table", "matrix", "edges", "clustering", "table", 
"table", "tree", "matrix", "table", "table", "table", "series", 
"table", "series", "series", "series", "series", "matrix", "plot"
), GGPlot = c("dedicated", "dedicated", "dedicated", "dedicated", 
"dedicated", "dedicated", "dedicated", "dedicated", "dedicated", 
"dedicated", "dedicated", "dedicated", "dedicated", "dedicated", 
"dedicated", "dedicated", "dedicated", "dedicated", "dedicated", 
"native", "native", "dedicated", "dedicated", "dedicated", "dedicated", 
"dedicated", "dedicated", "dedicated", "dedicated", "dedicated", 
"dedicated", "dedicated", "dedicated", "dedicated", "dedicated", 
"dedicated", "dedicated", "dedicated", "dedicated", "dedicated", 
"dedicated", "dedicated", "dedicated", "dedicated", "dedicated", 
"dedicated", "dedicated", "dedicated", "generic", "generic"), 
    GGPlotCall = c("as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(x)", "as_ggplot(x)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", "as_ggplot(p)", 
    "as_ggplot(p)", "as_ggplot(p, component = \"matrix\")", "as_ggplot(p, component = \"plot\")"
    ), Notes = c("Create with weight_metric='KrippendorffAlpha'. Width is magnitude; dashed edges are negative. Missing pairs are not zero. Returns a ggplot network view; use plot_data() for custom graph libraries.", 
    "Create with weight_metric='DirectionalMagnitude'. Choose SWS or PUS, retain unavailable rows, and report score units. These are not Rasch MnSq or calibrated pass/fail indices.", 
    "Pointwise normal intervals require adequate backend estimation. A coefficient is a conditional network log-odds effect, not MFRM severity.", 
    "Requires saved GOF from fit_rater_network(). Long simulation draws support custom plots; inspect MCMC diagnostics separately. GOF does not test causal halo.", 
    "Native Wright view for supported ordinary/one-family fits; unavailable for two-family GPCM or corrected JML. Inspect mfrmr_output_guide(\"gpcm_capabilities\") and the source uncertainty settings.", 
    "A reference-profile prediction, not an average over the observed rating arrangement. This ordinary plot route excludes two-family GPCM and corrected JML.", 
    "Severity and misfit are different; screening bands do not establish rater quality. This ordinary plot route excludes two-family GPCM and corrected JML.", 
    "Normal uncertainty bands, not likelihood-profile intervals or pairwise tests. Inspect CIUse, SE_Method and IntervalStatus; JML bands remain exploratory.", 
    "Predicted category probabilities; these curves alone do not show interval uncertainty. This mfrm_fit plot route excludes two-family GPCM and corrected JML; use their separately supported result/curve routes.", 
    "Observed counts and expected-count overlay; weighted counts are not independent Persons. Review owner_category_table separately for owner-level support.", 
    "Point estimates in owner/step order, with unavailable steps retained. Stored SEs and CI status are not converted into curve or gap intervals.", 
    "Create with mfrm_report(fit, type = 'category_curves'). Faceted ggplot overview separating probabilities, cumulative probabilities and information. Custom graphics must retain curve-family scales and CurveGroup; curve intervals are not supplied.", 
    "Plots Group 1 versus Group 2 measures (refit) or mean residuals (residual) with identity guide and aligned X/Y marginal histograms when at least eight finite pairs are plotted. Unavailable cells are withheld, not zeroed.", 
    "Native RSM/PCM CML uses conditional-information intervals in native units, including saved comparison-only targets; it has no population SD. Ordinary fixed-population RSM/PCM MML permits model or sandwich intervals; other supported MML routes use model-information intervals, with two-family GPCM still experimental. MML standardized contrasts retain the same fit's population-SD uncertainty and cross-covariance. Preserves target weights, IdentificationBasis where present and unavailable rows; absent estimates have labels without plotted points. No covariance is recomputed. CML uses these dedicated plots/tables and RDS saving, without mfrm_results().", 
    "Create with mfrm_report(x, type = 'bias_interaction'). Observed-minus-expected average versus conditional logit bias, with aligned marginal histograms when at least eight finite cells are plotted. Saved thresholds and conditional interval status are retained.", 
    "Signed cell shifts grouped by pair, with observed counts and screening availability. Select pair for individual heatmaps or ranked views. Conditional plug-in screens; no collection-wide multiplicity control or formal bias test.", 
    "Saved experimental RSM/PCM population intervals, without recalculation. Unavailable rows, native ability units, predictor coding and numerical checks remain explicit; coefficient magnitude depends on predictor units.", 
    "Requires saved contrasts from mfrm_population_intervals(). Inspect contrast_weights and population_spec; contrasts can describe means or differences, not individual ability differences or causal effects. No automatic significance decision.", 
    "Observed-score correlations before graph filters; selected halo_summary metrics and retained-edge matrices also convert. Associations do not establish causal halo. Graph centrality is not middle-category use.", 
    "Already a ggplot. Use as_ggplot(x), not conversion of the extracted table; intervals remain approximate.", 
    "Already a ggplot. One-family MML uses its saved inference; two-family MML shows fitted curves with unavailable intervals. Coverage is not guaranteed.", 
    "Conditional severity estimates; normal intervals require an explicit approximation request.", 
    "Select the facet for the intended comparison; normal intervals are an explicit approximation.", 
    "Conditional on saved calibration. Use style = 'precision' or 'distribution' for other views.", 
    "Conditional on saved calibration. Prior-only and unavailable scores are not ordinary observed estimates.", 
    "Model-specific posterior or conditional plug-in probabilities; paired views retain available Infit when Outfit is undefined. No reference cutoffs.", 
    "Comparison requires a common target and scale. A graphical difference is not a model-selection test.", 
    "Use style = 'curves' for trends. Simulation rates do not establish an observed rater's quality.", 
    "Displays screening rates and saved Monte Carlo intervals; Monte Carlo uncertainty differs from severity uncertainty.", 
    "Saved pointwise MI t intervals; no repooling. Missingness and imputation-model assumptions remain.", 
    "Saved equal-tailed credible intervals (and shared-calibration contrasts or empirical draw slabs when posterior-draws.rds is attached), retaining fixed values and sampling review.", 
    "Continuous equal-tailed Person intervals marginalized across calibration draws (or conditional on posterior means); use type = 'variance' for within/between variance shares or type = 'predictive' for row-level score bands.", 
    "Signed Pearson correlations of Person-by-facet standardized-residual means; retain pair overlap and unavailable cells. No calibrated local-independence test.", 
    "Solid positive and dashed negative edges; thickness is absolute correlation. Circular positions are not distances. Thresholding is descriptive, not EGA or causal inference.", 
    "Available only after explicit common-person clustering. The supplied group count is not an estimated number of latent dimensions. Stability and calibration uncertainty are not estimated.", 
    "Descriptive clustering quality, not response-model fit or latent ability.", 
    "Replace Years with one selected feature; categorical profiles also provide a matrix.", 
    "Gower dissimilarities and the recorded linkage; the tree does not establish latent dimensions.", 
    "Pairwise co-membership fractions; preserve excluded IDs and unavailable cells.", 
    "External-feature PCA, not a test of response-model dimensionality.", 
    "Requires two components; axes summarize the selected external features, not fitted ability.", 
    "Loadings depend on the recorded centering and scaling choices.", 
    "ggplot views also offer error_variance, heatmap, contour and surface3d; other varying conditions need explicit panels.", 
    "Raw variance components, including interactions/residuals; select multiple scores for panels or type = 'covariance' for covariance heatmaps. Negative estimates remain visible. No component SEs/intervals or future-plan scaling.", 
    "Choose score(s) or composite(s), metric and panel_by for the other facet count. Curves compare counts with the remaining conditions fixed; observed-score projections omit variance-component uncertainty.", 
    "SEM is in the selected score's units; retain score identity and composite weights.", 
    "Signed contributions sum to planned error variance, not SEM. Includes composite covariance; compare relevant complete plans and inspect totals for unavailable metrics.", 
    "The default shows point projections for all plans. Use view = \"differences\" for paired difference intervals.", 
    "Use a subset_connectivity_report() result. Matrix conversion omits the observation-share panel. Coverage alone does not establish connectedness or a missingness mechanism.", 
    "This component becomes points from its first two numeric columns. Direct plot(x, type = 'tif') renders the full curve and annotations."
    ), ResultFunction = c("rater_network_analysis", "rater_network_analysis", 
    "fit_rater_network", "fit_rater_network", "fit_mfrm", "fit_mfrm", 
    "fit_mfrm", "fit_mfrm", "fit_mfrm", "rating_scale_table", 
    "rating_scale_table", "mfrm_report", "analyze_dff", "mfrm_facet_intervals", 
    "mfrm_report", "estimate_all_bias", "mfrm_population_intervals", 
    "mfrm_population_intervals", "rater_halo_network_analysis", 
    "confint.mfrm_fit", "mfrm_curve_intervals", "fit_mfrm_random_rater", 
    "fit_mfrm_testlet", "score_mfrm_random_rater", "predict.mfrm_testlet", 
    "mfrm_response_diagnostics", "compare_mfrm", "mfrm_screening_sensitivity", 
    "mfrm_screening_performance", "pool_mfrm_imputed", "read_mfrm_posterior", 
    "predict.mfrm_posterior_summary", "mfrm_residual_network", 
    "mfrm_residual_network", "mfrm_residual_network", "mfrm_cluster", 
    "mfrm_cluster", "mfrm_cluster", "mfrm_cluster_imputed", "mfrm_pca", 
    "mfrm_pca", "mfrm_pca", "mfrm_d_study", "mfrm_g_study", "mfrm_d_study", 
    "mfrm_d_study", "mfrm_d_study", "compare_mfrm", "subset_connectivity_report", 
    "compute_information"), NextStep = c("Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure.", 
    "Use GGPlotCall; inspect DataComponent with plot_data(p, component = ...) before interpreting the figure."
    )), row.names = c(NA, -50L), class = "data.frame")
.mfrmr_const_diagnostic_screening_report_audit_empty <- list(ReportIndexAvailable = FALSE, ReportAuditError = NA_character_, 
    ReportReviewAreas = NA_real_, ReportReadyAreas = NA_real_, 
    ReportRequestIfNeededAreas = NA_real_, ReportFitReadiness = NA_character_, 
    ReportFitReviewSignalCount = NA_real_, ReportPrecisionReadiness = NA_character_, 
    ReportPrecisionReviewSignalCount = NA_real_, ReportMisfitReadiness = NA_character_, 
    ReportMisfitReviewSignalCount = NA_real_)
.mfrmr_const_gpcm_fair_average_rationale <- "The diagnostics/QC dashboard keeps the embedded fair-average panel disabled for `GPCM` fits so it does not present score-side adjustments as a FACETS-equivalent reporting surface. Use `fair_average_table()` directly for the supported slope-aware element-conditional GPCM fair averages, and keep its documented SE caveat in force."
.mfrmr_const_mfrm_bias_uncertainty_note <- "Bias uncertainty is conditional on the fitted person, facet, step and slope values; calibration uncertainty is not propagated. These intervals and tail areas are screening summaries, not formal fairness tests. Check Profile CI Status: search limits are not likelihood-ratio endpoints, and missing bounds do not mean infinity."
.mfrmr_const_mfrm_checkpoint_schema_id <- "mfrmr_mml_em_checkpoint"
.mfrmr_const_mfrm_checkpoint_schema_version <- 2L
.mfrmr_const_mfrm_gpcm_product_note <- "Method qualification is incomplete (experimental two-family GPCM). Numerical convergence and available bounds do not establish general interval coverage or rater-quality decisions. CIEligible records numerical interval availability; CoverageQualified = FALSE means coverage is unestablished, not zero or a failed numerical check. Inspect the saved numerical checks and target-specific restrictions; curve intervals and ordinary fit/bias tests remain unavailable."
.mfrmr_const_mfrm_ic_contract_required_fields <- c("ICContractVersion", "N", "ResponseRows", "WeightedResponseTotal", 
"Persons", "Npar", "LogLik", "Deviance", "WeightPolicy", "ICEligible", 
"ICSelectable", "ICStatus", "ICSampleSize", "ICSampleSizeBasis", 
"AIC", "BIC", "SABIC", "SABICSelectable", "AICFormula", "BICFormula", 
"SABICFormula", "IntegrationEvaluationId", "ICQuadraturePoints", 
"ICIntegrationTier", "ICIntegrationStatus", "ICIntegrationSelectable"
)
.mfrmr_const_mfrm_ic_contract_version <- "mfrmr_ic_person_v2"
.mfrmr_const_mfrm_ic_formula_identifiers <- c(AIC = "aic_deviance_plus_2k", BIC = "bic_person_count", SABIC = "sclove_n_plus_2_over_24"
)
.mfrmr_const_mfrm_jml_note <- "Experimental profile-score-adjusted JML. RootSE describes local variation around the adjusted-equation solution; residual bias may remain. Method qualification is incomplete; numerical availability does not establish statistical accuracy. It is not a standard error with established coverage for the true structural parameter. Person profiles condition on the adjusted calibration. No confidence intervals for structural parameters, ordinary fit tests, likelihood ranking or rater-quality classifications are supplied."
.mfrmr_const_mfrm_results_response_time_aliases <- c("responsetime", "responsetimeseconds", "responsetimemilliseconds", 
"responsetimems", "responsemilliseconds", "responsems", "rt", 
"rtseconds", "rtmilliseconds", "rtms", "duration", "durationseconds", 
"durationmilliseconds", "elapsedtime", "elapsedseconds", "elapsedmilliseconds", 
"latency", "latencyseconds", "latencymilliseconds")
.mfrmr_const_mfrm_separation_interpretation <- "Separation reliability describes differences among facet locations relative to their estimation errors. High Person values indicate distinguishable abilities; high rater values indicate distinguishable severities, not inter-rater agreement. Low rater values can also reflect imprecision and do not establish agreement. The index does not test every rater pair or quantify the practical size of severity differences. Reliability, separation and Strata are approximate compatibility indices using marginal SEs; joint-information SEs do not validate this variance decomposition. They do not account for covariance among estimates. EAP-based separation is not posterior-variance EAP reliability. Model and fit-adjusted values are companion indices, not confidence limits. Strata describes hypothetical distinguishable strata, not discovered groups. Facet heterogeneity chi-square summaries use diagonal SE weights, not full-covariance joint tests."
.mfrmr_const_mfrmr_adaptive_quadrature_note <- "The quadrature_review table holds calibration parameters and the prior fixed and compares a fixed-prior grid with mode/curvature-adapted grids. Inspect both fixed/adaptive differences and changes between adaptive orders. Computed rows are numerical diagnostics, not certified accuracy or revised scores; unavailable rows retain the reason. Fit and score readiness are unchanged."
.mfrmr_const_mfrmr_calibration_empty_refusals <- structure(list(Code = character(0), FieldPath = character(0), 
    Detail = character(0), Severity = character(0)), class = "data.frame", row.names = integer(0))
.mfrmr_const_mfrmr_calibration_operational_scoring_policy <- list(contract_id = "mfrmr_operational_scoring_v1", missing_response_policies = c("error", 
"omit"), very_sparse_max_responses = 1L, quadrature_edge_mass_threshold = 0x1.999999999999ap-5, 
    estimate_basis = "posterior_eap_fixed_calibration", uncertainty_basis = "conditional_on_frozen_point_calibration", 
    prior_sensitivity_status = "not_evaluated_fixed_basis")
.mfrmr_const_mfrmr_calibration_schema_id <- "mfrmr.fixed_calibration"
.mfrmr_const_mfrmr_calibration_semantic_identity_version <- "mfrmr-calibration-semantic-identity-v1"
.mfrmr_const_mfrmr_jml_gpcm_asymptotically_affine_contract_version <- "mfrmr-jml-gpcm-asymptotically-affine-transport-0.2.3-v1"
.mfrmr_const_mfrmr_jml_gpcm_boundary_classification_contract_version <- "mfrmr-jml-gpcm-fixed-objective-boundary-0.2.3-v2"
.mfrmr_const_mfrmr_jml_gpcm_boundary_compactification_contract_version <- "mfrmr-jml-gpcm-boundary-compactification-0.2.3-v1"
.mfrmr_const_mfrmr_jml_gpcm_terminal_gradient_contract_version <- "mfrmr-jml-gpcm-fixed-objective-terminal-gradient-0.2.3-v1"
.mfrmr_const_mfrmr_jml_recession_fit_policy <- list(contract_version = "mfrmr-jml-recession-fit-policy-v1", 
    scope = "additive_structural_and_joint_recession", native_timeout_seconds = 10L, 
    attempts_per_stage = 1L, retry_after_unaccepted = FALSE, 
    maximum_native_seconds_per_positive_target = 20L)
.mfrmr_const_mfrmr_nonlinear_local_estimability_contract_version <- "mfrmr-nonlinear-local-estimability-0.2.3-v1"
.mfrmr_const_mfrmr_readiness_contract_states <- list(ReadinessScope = c("fit", "parameter", "comparison"), InputState = c("pass", 
"review", "blocked", "legacy_unknown"), EstimabilityState = c("identified", 
"population_assumption_linked", "weak_information", "structurally_unidentified", 
"not_evaluated", "legacy_unknown"), CategoryState = c("adequate", 
"weak_information", "unsupported_coordinate", "not_applicable", 
"not_evaluated", "legacy_unknown"), BoundaryState = c("finite", 
"has_exclusions", "not_applicable", "not_evaluated", "legacy_unknown", 
"nonfinite_maximum"), NumericalState = c("ready", "review", "failed", 
"not_run", "legacy_unknown"), FitReadiness = c("ready", "ready_with_exclusions", 
"review", "blocked", "legacy_unknown"), ParameterStatus = c("estimable", 
"fixed", "weak_information", "unbounded_low", "unbounded_high", 
"unbounded_both", "aliased", "unsupported", "not_estimated", 
"not_evaluated", "legacy_unknown", "finite_numerical_solution", 
"finite_local_solution", "numerical_unresolved", "finite_maximum_absent", 
"finite_likelihood_limit", "unidentified_likelihood_limit", "limit_not_evaluated"
), ComparisonEligibility = c("eligible", "ineligible", "missing", 
"failed", "not_applicable"), ExpectedAction = c("return_ready_fit", 
"return_review_fit", "return_partial_fit", "return_blocked_diagnostic", 
"stop_before_fit", "retain_parameter", "label_legacy", "include_metric", 
"exclude_metric", "report_missing", "report_failed"), EvidenceRole = c("unit_positive", 
"unit_negative", "migration", "comparison_positive", "comparison_negative"
))
.mfrmr_const_person_fit_threshold_table <- structure(list(Threshold = c("5pct", "1pct"), TwoSidedAlpha = c(0x1.999999999999ap-5, 
0x1.47ae147ae147bp-7), AbsZ = c(0x1.f5c0331eeff81p+0, 0x1.49b4c64d6915fp+1
), Rule = c("|z| > 1.96", "|z| > 2.58")), class = "data.frame", row.names = c(NA, 
-2L))
.mfrmr_const_simulation_default_output_facet_names <- c("Rater", "Criterion")
.mfrmr_const_simulation_empty_population_spec <- list(active = FALSE, formula = NULL, terms = NULL, coefficients = NULL, 
    sigma2 = NULL, design_columns = NULL, xlevels = NULL, contrasts = NULL, 
    person_id = NULL, covariate_template = NULL, notes = "No latent-regression population generator is stored in this simulation specification.")
.mfrmr_const_simulation_reserved_output_names <- c("Study", "Person", "Score", "Group", "Weight", "TemplatePerson"
)
.mfrmr_const_summary_table_bundle_supported_summary_classes <- c("summary.mfrm_fit", "summary.mfrm_diagnostics", "summary.mfrm_precision_review", 
"summary.mfrm_fit_measures", "summary.mfrm_facets_fit_review", 
"summary.mfrm_person_fit_indices", "summary.mfrm_data_description", 
"summary.mfrm_reporting_checklist", "summary.mfrm_apa_outputs", 
"summary.mfrm_design_evaluation", "summary.mfrm_signal_detection", 
"summary.mfrm_diagnostic_screening", "summary.mfrm_recovery_simulation", 
"summary.mfrm_recovery_assessment", "summary.mfrmr_recovery_validation", 
"summary.mfrm_population_prediction", "summary.mfrm_structural_design_review", 
"summary.mfrm_facets_run", "summary.mfrm_results", "summary.mfrm_report", 
"summary.mfrm_bias", "summary.mfrm_anchor_review", "summary.mfrm_peer_review_design_review", 
"summary.mfrm_network_review", "summary.mfrm_linking_review", 
"summary.mfrm_misfit_casebook", "summary.mfrm_model_choice_review", 
"summary.mfrm_weighting_review", "summary.mfrm_calibration_score", 
"summary.mfrm_unit_prediction", "summary.mfrm_plausible_values"
)
.mfrmr_const_synthetic_truth_targets <- list(Rater = c(-0x1.999999999999ap-2, 0x0p+0, 0x1.999999999999ap-2
), Task = c(-0x1p-1, -0x1.5555555555556p-3, 0x1.5555555555554p-3, 
0x1p-1), Criterion = c(-0x1.3333333333333p-2, 0x0p+0, 0x1.3333333333333p-2
))
.mfrmr_const_warning_threshold_profiles <- list(profiles = list(strict = list(n_obs_min = 0x1.9p+7, n_person_min = 0x1.9p+5, 
    low_cat_min = 0x1.ep+3, min_facet_levels = 0x1p+2, misfit_ratio_warn = 0x1.47ae147ae147bp-4, 
    missing_fit_ratio_warn = 0x1.3333333333333p-3, zstd2_ratio_warn = 0x1.47ae147ae147bp-4, 
    zstd3_ratio_warn = 0x1.eb851eb851eb8p-6, expected_var_min = 0x1.3333333333333p-2, 
    pca_first_eigen_warn = 0x1.8p+0, pca_first_prop_warn = 0x1.999999999999ap-4), 
    standard = list(n_obs_min = 0x1.9p+6, n_person_min = 0x1.ep+4, 
        low_cat_min = 0x1.4p+3, min_facet_levels = 0x1.8p+1, 
        misfit_ratio_warn = 0x1.999999999999ap-4, missing_fit_ratio_warn = 0x1.999999999999ap-3, 
        zstd2_ratio_warn = 0x1.999999999999ap-4, zstd3_ratio_warn = 0x1.999999999999ap-5, 
        expected_var_min = 0x1.999999999999ap-3, pca_first_eigen_warn = 0x1p+1, 
        pca_first_prop_warn = 0x1.999999999999ap-4), lenient = list(
        n_obs_min = 0x1.ep+5, n_person_min = 0x1.4p+4, low_cat_min = 0x1.4p+2, 
        min_facet_levels = 0x1p+1, misfit_ratio_warn = 0x1.3333333333333p-3, 
        missing_fit_ratio_warn = 0x1.3333333333333p-2, zstd2_ratio_warn = 0x1.3333333333333p-3, 
        zstd3_ratio_warn = 0x1.47ae147ae147bp-4, expected_var_min = 0x1.999999999999ap-4, 
        pca_first_eigen_warn = 0x1.8p+1, pca_first_prop_warn = 0x1.999999999999ap-3)), 
    pca_reference_bands = list(eigenvalue = c(critical_minimum = 0x1.6666666666666p+0, 
    caution = 0x1.8p+0, common = 0x1p+1, strong = 0x1.8p+1), 
        proportion = c(minor = 0x1.999999999999ap-5, caution = 0x1.999999999999ap-4, 
        strong = 0x1.999999999999ap-3)))
.mfrmr_table_facets_feature_coverage_all <- structure(list(FACETSArea = c("Output table", "Output table", 
"Output table", "Output table", "Output table", "Output table", 
"Output table", "Output table", "Output table", "Output table", 
"Output table", "Output table", "Output table", "Output table", 
"Output table", "Output table", "Output table", "Output table", 
"Output table", "Output table", "Output table", "Output table", 
"R/Web plots", "R/Web plots", "R/Web plots", "R/Web plots", "R/Web plots", 
"R/Web plots", "R/Web plots", "Output file", "Output file", "Output file", 
"Output file", "Output file", "Output file", "Output file", "Output file", 
"Output file", "Graph menu", "Graph menu", "Graph menu", "Graph menu", 
"Graph menu", "Graph menu", "Specification/workflow", "Specification/workflow", 
"Specification/workflow", "Current scope boundary", "Current scope boundary", 
"Current scope boundary", "Current scope boundary", "Current scope boundary", 
"Observation weighting", "Current scope boundary", "Current scope boundary", 
"Current scope boundary"), FACETSFeature = c("Table 1: specification summary", 
"Table 2: data summary report", "Table 3: main iteration report", 
"Table 4: unexpected responses", "Table 5: measurable data summary", 
"Table 6.0: all-facet Wright map rulers", "Table 6.0.0: disjoint element listing", 
"Table 6.2: graphical facet statistics", "Table 7: facet measurement report", 
"Table 7: reliability and chi-square", "Table 7: agreement statistics", 
"Table 8.1: dichotomous/binomial/Poisson statistics", "Table 8.1: polytomous rating-scale/partial-credit statistics", 
"Table 8: scale-structure bar chart", "Table 8: scale-structure probability curves", 
"Table 9: bias-estimation iteration report", "Table 10: unexpected after allowing for bias", 
"Table 11: bias-calculation counts", "Table 12: bias summary report", 
"Table 13: DIF/bias detail report", "Table 14: pairwise bias report", 
"DIF/bias Excel plot", "Scatterplots and histograms from FACETS menus", 
"X-Y plot: R Statistics", "X-Y plot: Webpage", "X-Y-Z plot: R Statistics", 
"Histogram: R Statistics", "Generalizability Theory via R package gtheory", 
"Connectivity network graph via igraph", "Specification settings file", 
"Anchor output file", "Graph plotting file", "Output report file", 
"Residuals output file", "Score output file", "Simulated data file", 
"Subset group-anchor file", "Winsteps control and data file", 
"Category probability curves", "Expected score ICC/IRF", "Cumulative probability curves", 
"Test information function", "Category information function", 
"Conditional probability curves", "Full FACETS command-file parser and UI option surface", 
"Exact FACETS line-printer report emulation", "Raw FACETS report-text import", 
"FACETS or third-party frozen-calibration import", "General threshold or step anchors and starting-value import", 
"Multiple observed scales and scale-specific PCM", "Nominal/multinomial response models", 
"Binomial-trial and Poisson/count response models", "Row-frequency weights for ordered ratings", 
"Native multidimensional estimation and dimension-specific scores", 
"Unrestricted GPCM", "FACETS free-slope polytomous GPCM comparison"
), FACETSReference = c("table1.htm", "table2.htm", "table3.htm", 
"table4.htm", "table5.htm", "table6.htm", "table6_0_0.htm", "table6_2.htm", 
"table7.htm", "table7summarystatistics.htm", "table7agreementstatistics.htm", 
"table8_1dichotomous.htm", "table8_1ratingscale.htm", "table8barchart.htm", 
"table8curves.htm", "table9.htm", "table10.htm", "table11.htm", 
"table12.htm", "table13.htm", "table14.htm", "difbiasplot.htm", 
"outputtableindex.htm", "xyplotr.htm", "xyplotwebpage.htm", "xyzplotr.htm", 
"histogramr.htm", "gtheory.htm", "networkgraph.htm", "specificationfile.htm", 
"anchorfile.htm", "graphoutputfile.htm", "outputfile.htm", "residualfile.htm", 
"scorefile.htm", "simulatedfile.htm", "subsetfile.htm", "winstepsfile.htm", 
"graphs.htm", "graphs.htm", "graphs.htm", "graphs.htm", "graphs.htm", 
"graphs.htm", "index.htm", "outputtableindex.htm", "outputtableindex.htm", 
"current mfrmr public contract", "current mfrmr public contract", 
"current mfrmr public contract", "current mfrmr public contract", 
"models.htm", "current mfrmr weight contract", "current mfrmr public contract", 
"current mfrmr public contract", "t7menu.htm"), mfrmrRoute = c("mfrm_report(fit, type = 'specifications')", 
"mfrm_report(fit, type = 'data_quality'); describe_mfrm_data()", 
"mfrm_report(fit, type = 'iterations')", "unexpected_response_table(); plot(x, type = \"unexpected\")", 
"measurable_summary_table(); describe_mfrm_data()", "plot(renderer = \"facets\", type = \"wright\", view = \"unified\"); plot(fit, type = \"wright\")", 
"subset_connectivity_report()", "mfrm_report(fit, type = 'facet_statistics'); plot(...)", 
"fit_measures_table(); diagnose_mfrm(); summary(fit)", "facets_chisq_table(); diagnose_mfrm()$reliability", 
"interrater_agreement_table(); rater_network_analysis(); rater_halo_network_analysis(); plot(x, type = \"agreement\")", 
"rating_scale_table() for two-category ordered scores", "rating_scale_table(); mfrm_report(fit, type = 'category_structure')", 
"mfrm_report(fit, type = 'category_structure')", "mfrm_report(fit, type = 'category_curves'); plot(fit, type = \"ccc\")", 
"estimate_bias(); mfrm_report(bias, type = 'bias_iterations')", 
"unexpected_after_bias_table()", "bias_count_table()", "summary(estimate_bias(...)); plot(x, type = \"bias\")", 
"estimate_bias(); mfrm_report(fit, type = 'bias_interaction')", 
"mfrm_report(bias, type = 'bias_pairwise'); build_fixed_reports()", 
"plot(plot = ..., type = \"bias\")", "plot_data(); package plot helpers", 
"plot_data(); user-defined R plotting", "none", "plot(fit, type = \"ccc_surface\"); plot_data()", 
"plot_data(); plot(fit, type = \"wright\"); plot(x, type = \"qc\")", 
"mfrm_g_study(); mfrm_d_study(); compare_mfrm(); mfrm_generalizability(); mfrm_d_study()", 
"subset_connectivity_report(); mfrm_network_analysis(); rater_network_analysis(); rater_halo_network_analysis(); plot(..., type = \"network\")", 
"build_mfrm_manifest(); build_mfrm_replay_script()", "make_anchor_table(); export_mfrm_bundle(include = \"anchors\")", 
"facets_output_file_bundle(include = \"graph\"); read_facets_results(graph_file = ...); plot()", 
"export_summary_appendix(); build_fixed_reports()", "write_mfrm_residual_file(); diagnose_mfrm(); unexpected_response_table(); residual plot helpers", 
"facets_output_file_bundle(include = \"score\"); read_facets_results(); facets_fit_review(); plot()", 
"simulate_mfrm_data(); build_mfrm_sim_spec()", "write_mfrm_subset_file(); group_anchors; review_mfrm_anchors(); make_anchor_table()", 
"none", "mfrm_report(fit, type = 'category_curves'); plot(fit, type = \"ccc\")", 
"plot(fit, type = \"pathway\"); mfrm_report(fit, type = 'category_curves')", 
"mfrm_report(fit, type = 'category_curves'); plot(..., type = \"cumulative\")", 
"compute_information(); plot(type = \"tif\")", "mfrm_report(fit, type = 'category_curves'); plot(..., type = \"category_information\"); compute_information(); plot(type = \"iif\")", 
"mfrm_report(fit, type = 'category_curves')", "run_mfrm_facets(); fit_mfrm()", 
"build_fixed_reports() for selected tables", "read_facets_results() for delimited/fixed-field score extracts", 
"no external import; native route: mfrmr_output_guide(\"calibration_capabilities\"); load_mfrm_calibration(); score_mfrm_calibration()", 
"not available in the current package", "not available in the current package", 
"not available in the current package", "not available in the current package", 
"fit_mfrm(weight = ...)", "not available in the current package", 
"not available for unrestricted GPCM", "none as a direct common-estimand comparison"
), Status = c("implemented", "implemented", "partial", "implemented", 
"partial", "implemented", "supported_with_caveat", "partial", 
"supported_with_caveat", "supported_with_caveat", "supported_with_caveat", 
"partial", "supported_with_caveat", "partial", "implemented", 
"implemented", "implemented", "partial", "partial", "implemented", 
"implemented", "partial", "partial", "partial", "not_targeted", 
"partial", "partial", "supported_with_caveat", "implemented", 
"partial", "implemented", "implemented", "partial", "implemented", 
"partial", "partial", "partial", "not_implemented", "implemented", 
"implemented", "implemented", "implemented", "implemented", "partial", 
"not_targeted", "not_targeted", "partial", "not_implemented", 
"not_implemented", "not_implemented", "not_implemented", "not_implemented", 
"supported_with_caveat", "not_implemented", "not_implemented", 
"not_implemented"), SurfaceCoverage = c("available", "available", 
"partial", "available", "partial", "familiar_visual_grammar_available", 
"available_with_caveat", "partial", "available_with_caveat", 
"available_with_caveat", "available_with_caveat", "partial", 
"available_with_caveat", "partial", "available", "available", 
"available", "partial", "partial", "available", "available", 
"partial", "partial", "partial", "out_of_scope", "partial", "partial", 
"available_with_caveat", "available", "partial", "available", 
"available", "partial", "available", "partial", "partial", "partial", 
"unavailable", "available", "available", "available", "available", 
"available", "partial", "out_of_scope", "out_of_scope", "partial", 
"unavailable", "unavailable", "unavailable", "unavailable", "unavailable", 
"available_with_caveat", "unavailable", "unavailable", "unavailable"
), StatisticalContract = c("package_native_not_facets_equivalent", 
"package_native_not_facets_equivalent", "partial_package_native_contract", 
"package_native_not_facets_equivalent", "partial_package_native_contract", 
"package_native_not_facets_equivalent", "package_native_caveated", 
"partial_package_native_contract", "package_native_caveated", 
"package_native_caveated", "package_native_caveated", "partial_package_native_contract", 
"package_native_caveated", "partial_package_native_contract", 
"package_native_not_facets_equivalent", "package_native_not_facets_equivalent", 
"package_native_not_facets_equivalent", "partial_package_native_contract", 
"partial_package_native_contract", "package_native_not_facets_equivalent", 
"package_native_not_facets_equivalent", "partial_package_native_contract", 
"partial_package_native_contract", "partial_package_native_contract", 
"not_applicable", "partial_package_native_contract", "partial_package_native_contract", 
"package_native_caveated", "package_native_not_facets_equivalent", 
"partial_package_native_contract", "package_native_not_facets_equivalent", 
"package_native_not_facets_equivalent", "partial_package_native_contract", 
"package_native_not_facets_equivalent", "partial_package_native_contract", 
"partial_package_native_contract", "partial_package_native_contract", 
"not_available", "package_native_not_facets_equivalent", "package_native_not_facets_equivalent", 
"package_native_not_facets_equivalent", "package_native_not_facets_equivalent", 
"package_native_not_facets_equivalent", "partial_package_native_contract", 
"not_applicable", "not_applicable", "partial_package_native_contract", 
"not_available", "not_available", "not_available", "not_available", 
"not_available", "package_native_caveated", "not_available", 
"not_available", "not_available"), ValidationEvidence = c("external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "not_applicable", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "not_applicable", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "external_match_not_established", 
"external_match_not_established", "not_applicable", "not_applicable", 
"external_match_not_established", "not_applicable", "not_applicable", 
"not_applicable", "not_applicable", "not_applicable", "external_match_not_established", 
"not_applicable", "not_applicable", "not_applicable"), OperationalStatus = c("package_route_available", 
"package_route_available", "partial_workflow_only", "package_route_available", 
"partial_workflow_only", "package_route_available", "available_with_mandatory_caveat", 
"partial_workflow_only", "available_with_mandatory_caveat", "available_with_mandatory_caveat", 
"available_with_mandatory_caveat", "partial_workflow_only", "available_with_mandatory_caveat", 
"partial_workflow_only", "package_route_available", "package_route_available", 
"package_route_available", "partial_workflow_only", "partial_workflow_only", 
"package_route_available", "package_route_available", "partial_workflow_only", 
"partial_workflow_only", "partial_workflow_only", "external_only", 
"partial_workflow_only", "partial_workflow_only", "available_with_mandatory_caveat", 
"package_route_available", "partial_workflow_only", "package_route_available", 
"package_route_available", "partial_workflow_only", "package_route_available", 
"partial_workflow_only", "partial_workflow_only", "partial_workflow_only", 
"blocked", "package_route_available", "package_route_available", 
"package_route_available", "package_route_available", "package_route_available", 
"partial_workflow_only", "external_only", "external_only", "partial_workflow_only", 
"blocked", "blocked", "blocked", "blocked", "blocked", "available_with_mandatory_caveat", 
"blocked", "blocked", "blocked"), Capability = c("Structured run settings and reproducibility context.", 
"Rows, exclusions, missingness, score support, and response-pattern QC.", 
"Convergence and replayed iteration evidence.", "Case-level unexpected-response screening.", 
"Facet coverage, category counts, and subset/connectivity checks.", 
"Common-logit person/facet/threshold display with FACETS-style asterisk ruler or native SE/CI rendering.", 
"Co-observation graph components and facet coverage, with the fitted identification audit.", 
"Facet statistics and visual summaries.", "Measures, SEs, fit, anchoring status, and review flags.", 
"Rasch/FACETS-style separation, reliability, and chi-square summaries.", 
"Raw-category observed agreement and model-probability expected agreement, plus pairwise rater-network, rater-by-criterion halo network, and rater-agreement views.", 
"Two-category Rasch-category summaries are available.", "Core category diagnostics and thresholds for one RSM scale or one PCM step facet on the package's shared observed score scale.", 
"Category structure and transition summaries.", "Category probability and expected-score curve data.", 
"Bias recalibration path and final iteration status.", "Unexpected rows after the current bias-screening layer.", 
"Cell counts, logit shifts and separate baseline/remaining score residuals.", 
"Distributional and visual bias summaries are available.", "Ranked cell-level bias/interactions with screening statistics.", 
"Pairwise contrasts for two-way bias runs.", "R-native scatter, heatmap, and facet-profile bias displays.", 
"Reusable plot data supports custom R graphics.", "Users can build X-Y plots from returned data frames.", 
"No package-native Webpage plot generator.", "Selected 3D/surface-ready plot data are available.", 
"Several package outputs include histogram-like summaries.", 
"Observed-score univariate/multivariate component models for supported crossed/nested designs, fixed score composites and D-study plans, with component/covariance plots, curves and paired normal-theory plan comparisons. The separate main-effects route retains residual-scaling sensitivity and IdentificationStatus columns.", 
"Separate facet-level co-observation, rater score-relation, and rater-by-criterion halo networks with reusable node/edge tables.", 
"R-native reproducibility manifest and replay script.", "Candidate direct-anchor tables mechanically extracted from fitted estimates.", 
"Graphfile-style native output and separate import of reported category/expected-score curves.", 
"Structured appendix/report artifacts.", "Standalone observation-level residual CSV/TSV output, residual tables, and residual visualizations are available.", 
"Native observation-level score export and separate FACETS element-level import, including standalone source-measure and fit plots.", 
"Simulation data and explicit simulation specifications.", "Connected-subset summary/node files and group-anchor inputs/checks are available.", 
"No Winsteps control/data export route.", "Category probability curve data and plots.", 
"Expected-score curves over theta.", "Cumulative category-probability curve data, flipped direction data, and approximate .5 boundaries are available.", 
"Design-weighted test/scale information curves.", "Category-specific information contributions, total information curves, and facet/level contribution curves are available.", 
"Category probability curves conditional on theta are available.", 
"R function arguments are the package interface.", "Selected fixed-width handoff is available.", 
"Fit/score table import is supported.", "Native mfrmr portable artifacts support fixed-standard-normal RSM/PCM MML, qualified estimated-normal GPCM MML and qualified reference-prior RSM/PCM or shared-owner GPCM JML; consult mfrmr_output_guide(\"calibration_capabilities\") for scope and source checks.", 
"No current public route accepts general threshold or step anchors or a threshold starting-value contract.", 
"Each fit uses one observed score scale and one homogeneous response-model family.", 
"The current RSM, PCM, and GPCM routes model ordered category probabilities only.", 
"Binary ordered scores are available as the two-category special case of the current ordered-response kernel.", 
"A positive numeric observation weight multiplies that row's conditional ordered-category likelihood contribution and can represent a defensible row-replication weight.", 
"The current public estimator and score routes are unidimensional.", 
"JML requires slope_facet to equal step_facet; MML permits separate owners with one slope family.", 
"FACETS PCM/JMLE can serve as the direct equal-discrimination comparison after the full estimation contract is aligned."
), Limitation = c("Not an exact FACETS line-printer layout.", 
"Structured QC replaces FACETS text layout.", "Does not reproduce the complete FACETS iteration trace.", 
"Structured table and plots, not printer-identical FACETS output.", 
"Does not reproduce FACETS response moments, raw/residual variance and global Pearson summaries; this is substantive partial coverage.", 
"Visual correspondence does not establish numerical equivalence; compare output from a documented FACETS version under aligned settings.", 
"These are not FACETS identification subsets; a single component can conceal confounded panels.", 
"FACETS M/S/Q/X printer-graph formatting is not reproduced exactly.", 
"Estimator and person-score basis, extreme handling, df/ZSTD conventions, and FACETS options can differ; external numerical equivalence is not established.", 
"Uses package-native structured output and documented df conventions; external numerical equivalence is not established.", 
"The package does not translate category positions across multiple independent scales, apply FACETS agreement-based SE inflation, or establish external Table 7 parity.", 
"FACETS binomial-trial and Poisson-specific reports are not implemented.", 
"Multiple independent scales and scale-specific anchors/starting values are not reproduced. Cumulative boundaries are grid approximations; category residual fit is descriptive, with no unit-baseline ZSTD test.", 
"FACETS line-printer artwork is not reproduced exactly.", "Uses R-native plot data rather than FACETS graph text.", 
"Conditional screening semantics are documented separately.", 
"Structured table replaces FACETS text layout.", "FACETS Table 11 response moments and variance decompositions are not supplied.", 
"FACETS vertical frequency bar-chart is not reproduced exactly.", 
"Reported as screening evidence, not final fairness inference.", 
"Higher-order runs omit pairwise sections by design.", "Excel-specific output is not implemented.", 
"FACETS arbitrary R/Web plotting menus are not mirrored.", "No dedicated FACETS-style arbitrary X-Y plot wrapper.", 
"Webpage menu output is a FACETS UI feature.", "No arbitrary FACETS X-Y-Z plot wrapper.", 
"No general FACETS histogram menu clone.", "Not a FACETS/gtheory UI clone or general multivariate/profile G-theory implementation. Incomplete source data do not authorize sparse future plans. Component SEs/intervals use balanced ANOVA and normal random effects for a score or fixed composite; two-score covariance intervals have explicit generalized and conservative choices with signed bounds. Explicit reml_profile component intervals also accept MINQUE(0), retaining original points and a separate REML center without supplying a sampling SE. Separately, vcov(g) supplies normal-model sampling covariance and SEs for original ANOVA/MINQUE components, including incomplete sources; product-moment correction retains negative or unidentified sampling variances and does not establish normal-reference intervals. Joint reml_profile covariance intervals also accept identifiable incomplete sources, with signed bounds, no sampling SE and unestablished finite-sample coverage. Balanced crossed G also accepts an explicit experimental score interval using extended nuisance parameters; empty numerical confidence sets and failed calculations have distinct diagnostics, with no Phi or paired-plan transfer. Explicit experimental reml_profile G/Phi and SEM intervals fit the used ratings under normal effects, preserving ANOVA/MINQUE points and reporting a separate REML IntervalCenter; finite-sample and boundary coverage are not guaranteed. With reference, the shared-profile transformation supplies G/Phi/SEM differences for one-facet plans or nested plans with a common future child count, including incomplete sources; the base approximation and numerical limitations remain. SEM intervals profile error variance before taking square roots and do not enumerate remote disconnected accepted regions. Plan-difference intervals have a separate normal-theory scope. Inspect negative components, metric-specific statuses and main-effects boundary/singularity flags.", 
"Co-observation connectedness does not establish full design rank; consult the retained identification audit. Response networks likewise do not establish a common scale. R-native igraph analysis and display rather than FACETS menu output.", 
"Does not write a FACETS command specification file.", "Export does not certify source readiness, cross-run identity, or invariance; uses R/CSV tables rather than FACETS fixed syntax.", 
"Import supports named CSV/TSV and validated ASCII fixed-width headings, preserves source coding and availability, and does not align Graphfile and element coordinates or reconstruct a calibration. Command-level graph options are not fully mirrored.", 
"Full FACETS report-file emulation is not implemented.", "Uses package-native residual columns rather than exact FACETS fixed-field residual syntax.", 
"Export and import have different units/formats. Fixed imports require validated ASCII all-field headings; use named delimited columns for other layouts or non-ASCII labels. Imported results are descriptive, without external-calibration scoring or inferred joint uncertainty. GPCM score-side equivalence is outside scope.", 
"Not a FACETS simulated-data file clone.", "The standalone subset writer exports connectivity review tables, not a full FACETS UI-compatible subset command file.", 
"Would require a separate Winsteps output contract.", "R-native plots replace FACETS graph menu output.", 
"Not labeled as FACETS ICC/IRF menu output.", "R-native plot data replace FACETS graph-menu output.", 
"R-native information definition and plot data.", "R-native plot data replace FACETS graph-menu output.", 
"FACETS conditional-probability menu semantics are not mirrored exactly.", 
"Parsing arbitrary FACETS command files is outside the package scope.", 
"Exact full report emulation is outside the package scope.", 
"General raw FACETS report parsing is not implemented.", "No current route converts a FACETS or another program's calibration file into an mfrmr portable artifact; native artifact scoring does not establish transportability or external-program equivalence.", 
"Element and group anchors do not make threshold ladders fixed or supply a general calibration-import schema.", 
"There is no per-observation ScaleId contract, scale-specific category map, or ragged scale-specific PCM threshold block.", 
"A category-probability vector that sums to one is not an unordered nominal-response or multinomial-logit model; category order enters every current likelihood.", 
"Grouped binomial trials, Poisson counts, negative-binomial counts, and other count likelihoods are not implemented; integer scores are interpreted as ordered category codes.", 
"It is not a general collapsed-person frequency table: for MML, powering responses inside one Person pattern is not equivalent to replicating a complete Person pattern after marginalization. It also does not create a count-response family, model within-cell dependence, or make non-unit-weight fits eligible for the common information-criterion panel.", 
"Residual PCA is exploratory dimensionality evidence, not native multidimensional estimation or dimension-specific scoring.", 
"GPCM support does not establish an unrestricted free-discrimination model family.", 
"FACETS Table 7 Estimated Discrimination is a post-fit diagnostic that does not update other Rasch estimates, so it is not the jointly estimated GPCM slope from mfrmr."
), Alternative = c("Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.", 
"Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.", 
"Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.", 
"Use package-native R output where suitable, or run the relevant external program for its program-specific file, interface, or report.", 
"Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.", 
"Build the display from package plot data or another R graphics system; use FACETS externally for its menu-specific view.", 
"Start with the G-theory vignette and declare the score, random facets and assignments. Use the main-effects adapter only for its different decomposition; use FACETS externally for its UI or other external-only options.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use package-native R output where suitable, or run the relevant external program for its program-specific file, interface, or report.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the documented mfrmr route; use FACETS externally only when its exact layout or option surface is required.", 
"Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.", 
"Use package-native R output where suitable, or run the relevant external program for its program-specific file, interface, or report.", 
"Use package-native R output where suitable, or run the relevant external program for its program-specific file, interface, or report.", 
"Use the closest documented mfrmr table or plot for analysis; use FACETS externally when the omitted statistic or format is required.", 
"Use the native mfrmr calibration workflow for eligible fits; use a separately validated external workflow when third-party calibration import is required.", 
"Use current element/group anchor routes only for their documented scope; retain threshold anchoring for a later release.", 
"Fit supported single-scale designs separately; retain multi-scale and mixed-family workflows for a later release.", 
"Use a nominal-response or multinomial-regression implementation externally when category order is not substantively defined.", 
"Use FACETS or another count-model implementation for an appropriate binomial-trial or Poisson estimand; do not relabel an ordered-category fit as a count model.", 
"Retain one distinguishable event per row when possible; preserve distinct Person response patterns, and report the exact likelihood-weight interpretation.", 
"Use exploratory dimensionality diagnostics and external multidimensional software when a multidimensional estimator is required.", 
"Use mfrmr_output_guide(\"gpcm_capabilities\") and the documented GPCM route; retain unrestricted GPCM for a later release.", 
"Use FACETS for the matched PCM/JML comparison or as a deliberately misspecified equal-discrimination control; use a genuinely slope-estimating program only after the GPCM kernel and identification are matched."
)), class = "data.frame", row.names = c(NA, -56L))

# --- Phase B1 reporting checklist static schemas ---
.mfrmr_table_external_software_scope_base <- structure(list(Software = c("mfrmr native", "FACETS", "ConQuest", 
"SPSS"), Relationship = c("primary estimation and reporting workflow", 
"FACETS-style reporting and file handoff", "scoped external-table comparison for latent-regression overlap", 
"table/report handoff only"), CurrentSupport = c("active", "active compatibility layer", 
"not active for this fit", "CSV/data.frame outputs only"), PrimaryHelpers = c("fit_mfrm() -> diagnose_mfrm() -> mfrm_report(fit, type = 'checklist') -> build_apa_outputs()", 
"facets_guide('positioning'), facets_guide('coverage'), run_mfrm_facets(), facets_output_file_bundle(), facets_output_contract_review()", 
"build_conquest_overlap_bundle() -> normalize_conquest_overlap_*() -> review_conquest_overlap()", 
"export_mfrm_bundle(), export_summary_appendix(), as.data.frame()"
), Boundary = c("Package-native results are the authoritative analysis objects.", 
"Results remain mfrmr estimates; use an external FACETS run plus review helpers only when numerical comparison is needed.", 
"Requires an external ConQuest run and extracted output tables for the documented overlap case.", 
"CSV/data-frame outputs support reporting handoff; native SPSS integration is not implemented."
), RecommendedWording = c("Estimated with mfrmr under the stated model/method settings.", 
"Estimated with mfrmr; FACETS-style outputs were used for handoff or report organization unless external FACETS output is explicitly compared.", 
"ConQuest overlap is limited to the documented latent-regression MML comparison scope.", 
"Tables were exported for possible SPSS/reporting use; analysis was not performed in SPSS."
)), class = "data.frame", row.names = c(NA, -4L))
.mfrmr_table_visual_scope_base <- structure(list(Visualization = c("QC dashboard", "Wright map", 
"Pathway / CCC", "Category probability surface", "Information curves", 
"Strict marginal visuals", "Bias / DIF visuals", "Residual PCA visuals"
), Role = c("first-pass diagnostic triage", "shared-scale targeting and spread", 
"ordered-category structure and category dominance", "exploratory theta x category x probability review", 
"precision and targeting across theta", "strict marginal fit follow-up", 
"interaction and group-functioning screening", "exploratory residual-structure follow-up"
), CurrentSupport = c("not listed in reporting checklist", "not listed in reporting checklist", 
"not listed in reporting checklist", "not ready for current fit: step/threshold estimates are required", 
"not listed in reporting checklist", "not listed in reporting checklist", 
"not listed in reporting checklist", "not listed in reporting checklist"
), SupportedModels = c("RSM/PCM; GPCM residual stack with documented fair-average boundary", 
"RSM/PCM/GPCM when person, facet, and step locations are available", 
"RSM/PCM/GPCM when step/threshold estimates are available", "RSM/PCM/GPCM when step/threshold estimates are available", 
"RSM/PCM/GPCM where compute_information() supports the fitted object", 
"RSM/PCM MML diagnostic_mode = \"both\" where strict marginal bundles are available", 
"Model-dependent; requires supplied bias/DIF screening results", 
"Model-dependent; requires residual PCA computation"), PrimaryHelper = c("plot(x, type = \"qc\") / plot(x, type = \"facet_dashboard\")", 
"plot(fit, type = \"wright\") / plot(x, type = \"wright\", view = \"unified\")", 
"plot(fit, type = \"pathway\") / plot(fit, type = \"ccc\")", 
"plot(fit, type = \"ccc_surface\")", "compute_information() -> plot(x)", 
"plot(x, type = \"marginal_fit\") / plot(x, type = \"marginal_pairwise\")", 
"plot(x, type = \"bias\") / plot(x, type = \"heatmap\")", "analyze_residual_pca() -> plot(x, type = \"residual_pca\")"
), DrawFreeRoute = c("plot(fit, type = \"qc\", diagnostics = diagnostics, draw = FALSE)", 
"plot(fit, type = \"wright\", draw = FALSE)", "plot(fit, type = \"ccc\", draw = FALSE)", 
"plot(fit, type = \"ccc_surface\", draw = FALSE)", "plot(compute_information(fit), draw = FALSE)", 
"plot(diagnostics, type = \"marginal_fit\", draw = FALSE)", "plot(bias_results[[1]], type = \"bias\", draw = FALSE)", 
"plot(analyze_residual_pca(diagnostics, mode = \"overall\"), type = \"residual_pca\", draw = FALSE)"
), ReportUse = c("triage figure; usually not the final manuscript figure by itself", 
"good candidate for reports when targeting/spread is the point", 
"good candidate for reports as descriptive category-functioning evidence", 
"exploratory or teaching appendix only; not a default APA figure", 
"report when precision/targeting is a substantive question and precision tier supports the wording", 
"exploratory follow-up, not a standalone inferential test", "screening follow-up, not a formal hypothesis-test figure by itself", 
"exploratory follow-up, not a standalone dimensionality test"
), ThreeDStatus = c("2D dashboard only; 3D not recommended", 
"2D recommended; 3D Wright maps are discouraged", "2D report default; surface plot data available through the category route", 
"advanced surface data only; no package-native interactive renderer", 
"2D information curves available; no package-native 3D information surface", 
"2D heatmap/bar style preferred; 3D not recommended", "2D heatmap/profile preferred; 3D not recommended", 
"2D scree/loadings preferred; 3D not recommended"), Boundary = c("Summarizes flags; inspect the component plots before making claims.", 
"Shows common-scale locations but does not prove model fit.", 
"Descriptive category-functioning evidence, not proof of rating-scale validity.", 
"Returned data are exploratory mfrmr output for advanced visualization.", 
"Depends on the fitted model and precision tier; interpret with checklist caveats.", 
"Requires strict marginal diagnostics; use as corroborating evidence.", 
"Requires a bias/DIF result object; treat as screening unless separately justified.", 
"Residual PCA is exploratory residual-structure review, not a formal dimensionality decision."
), InterpretationCheck = c("Review component warnings before citing the dashboard.", 
"Report targeting/spread, then check fit diagnostics separately.", 
"Check ordered peaks and dominance bands in the 2D CCC/pathway views.", 
"Inspect category_support before using the surface in an appendix or downstream renderer.", 
"State whether the curve is model-based, design-weighted, or approximate.", 
"Confirm diagnostic_mode = \"both\" and describe this as follow-up evidence.", 
"Confirm the tested pair, low-count cells, and screening threshold.", 
"Use scree/loadings as exploratory residual-structure evidence only."
)), class = "data.frame", row.names = c(NA, -8L))
.mfrmr_table_report_checklist_core_schema <- structure(list(Section = c("Method Section", "Method Section", 
"Method Section", "Method Section", "Method Section", "Method Section", 
"Method Section", "Method Section", "Global Fit", "Global Fit", 
"Global Fit", "Facet-Level Statistics", "Facet-Level Statistics", 
"Facet-Level Statistics", "Element-Level Statistics", "Element-Level Statistics", 
"Element-Level Statistics", "Element-Level Statistics", "Rating Scale Diagnostics", 
"Rating Scale Diagnostics", "Rating Scale Diagnostics", "Rating Scale Diagnostics", 
"Bias / Interaction Analysis", "Bias / Interaction Analysis", 
"Visual Displays", "Visual Displays", "Visual Displays", "Visual Displays", 
"Visual Displays", "Visual Displays", "Visual Displays", "Visual Displays", 
"Visual Displays"), Item = c("Model specification", "Data description", 
"Precision basis", "Convergence", "Connectivity assessed", "Empirical-Bayes shrinkage choice and assumptions", 
"Facet rating-count screening", "Hierarchical structure review", 
"Standardized residuals", "PCA of residuals", "Fit/separation reporting boundary", 
"Separation / strata / reliability", "Fixed/random variability summary", 
"RMSE and true SD", "Measures with SE", "95% confidence intervals", 
"Infit and Outfit statistics", "Misfit counts", "Category counts", 
"Average measures by category", "Threshold ordering", "Category probability curves", 
"Facet pairs tested", "Screen-positive interactions", "Wright map", 
"QC / facet dashboard", "Residual PCA visuals", "Connectivity / design-matrix visual", 
"Inter-rater / displacement visuals", "Strict marginal visuals", 
"Bias / DIF visuals", "Precision / information curves", "Fit/category visuals"
), Severity = c("required", "required", "required", "required", 
"required", "recommended", "recommended", "recommended", "required", 
"recommended", "recommended", "required", "required", "recommended", 
"required", "recommended", "required", "recommended", "required", 
"recommended", "required", "recommended", "recommended", "recommended", 
"recommended", "recommended", "recommended", "recommended", "recommended", 
"recommended", "recommended", "recommended", "optional"), SourceComponent = c("fit$config", 
"fit$prep + fit$config", "diagnostics$precision_profile", "fit$summary + fit$opt", 
"diagnostics$subsets", "fit$config$facet_shrinkage + fit$shrinkage_report", 
"fit$summary$FacetSampleSizeFlag + facet_small_sample_review()", 
"analyze_hierarchical_structure(data, facets)", "diagnostics$obs", 
"diagnostics$pca", "mfrm_report(fit, type = 'precision')$fit_separation_basis + fit_measures_table() + facets_fit_review()", 
"diagnostics$reliability", "diagnostics$reliability + diagnostics$facets_chisq", 
"diagnostics$reliability", "diagnostics$measures", "diagnostics$measures", 
"diagnostics$measures or diagnostics$fit", "diagnostics$fit", 
"diagnostics$obs", "diagnostics$obs", "fit$steps", "fit$steps", 
"bias_results", "bias_results$table", "plot.mfrm_fit", "diagnostics$obs + diagnostics$fit", 
"diagnostics$pca", "diagnostics$subsets", "diagnostics$obs + diagnostics$measures", 
"diagnostics$marginal_fit", "bias_results", "fit + compute_information()", 
"diagnostics$fit + fit$steps"), PlotHelper = c(NA, NA, NA, NA, 
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 
NA, NA, NA, NA, "plot.mfrm_fit() / plot(x, type = \"wright\", view = \"unified\")", 
"plot(x, type = \"qc\") / plot(x, type = \"facet_dashboard\")", 
"plot(x, type = \"residual_pca\")", "plot.mfrm_subset_connectivity()", 
"plot(x, type = \"displacement\") / plot(x, type = \"agreement\")", 
"plot(x, type = \"marginal_fit\") / plot(x, type = \"marginal_pairwise\")", 
"plot(x, type = \"bias\") / plot(x, type = \"heatmap\")", "plot(x)", 
"plot.mfrm_fit() / plot.mfrm_category_curves()"), DrawFreeRoute = c(NA, 
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 
NA, NA, NA, NA, NA, NA, NA, "plot(fit, type = \"wright\", draw = FALSE)", 
"plot(fit, type = \"qc\", diagnostics = diagnostics, draw = FALSE)", 
"plot(analyze_residual_pca(diagnostics, mode = \"overall\"), type = \"residual_pca\", mode = \"overall\", view = \"scree\", draw = FALSE)", 
"plot(subset_connectivity_report(fit, diagnostics = diagnostics), type = \"design_matrix\", draw = FALSE)", 
"plot(displacement_table(fit, diagnostics = diagnostics), type = \"displacement\", draw = FALSE)", 
"plot(diagnostics, type = \"marginal_fit\", draw = FALSE)", "plot(bias_results[[1]], type = \"bias\", draw = FALSE)", 
"plot(compute_information(fit), draw = FALSE)", "plot(fit, type = \"ccc\", draw = FALSE)"
), PlotReturnClass = c(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "ggplot", 
"ggplot", "ggplot", "ggplot", "ggplot", "ggplot", "ggplot", "ggplot", 
"ggplot"), MissingAction = c("Fit a model first so the APA report can name the model and estimation method.", 
"Populate the basic design counts so the manuscript can describe the sample and scale.", 
"Run diagnostics so the report can explain whether precision is model-based, hybrid, or exploratory.", 
"Resolve convergence before reporting model results.", "Run the subset/connectivity diagnostics and summarize whether the design is connected.", 
"Document whether zero-centered pooling is substantively appropriate for the facet and decision.", 
"Run `facet_small_sample_review(fit)` and report retained rating counts. Inspect targeting, connectedness and estimator-specific uncertainty.", 
"Run `analyze_hierarchical_structure(fit)` once per design and pass the result to `mfrm_report(type = 'checklist', ..., hierarchical_structure = hs)`.", 
"Compute diagnostics so global fit and local residual screening can be reported.", 
"Run residual PCA if you want to comment on unexplained residual structure.", 
"Run `diagnose_mfrm()` before writing fit, separation, reliability, or ZSTD language. Use `diagnose_mfrm(..., fit_df_method = \"both\")` when FACETS-style df/ZSTD review is needed.", 
"Compute facet reliability/separation before describing facet spread and precision.", 
"Compute facet variability summaries before discussing fixed/random spread across facets.", 
"Expose RMSE/TrueSD columns if you want the manuscript to summarize facet spread in detail.", 
"Compute element-level measures and SE before reporting facet-level results.", 
"Add SE first if you plan to report approximate confidence intervals.", 
"Compute fit statistics before reporting misfit or element-level screening.", 
"Summarize element-level misfit counts if the manuscript reports quality-control findings.", 
"Expose observed score counts before commenting on category use.", 
"Retain person-measure information if the manuscript discusses average measures by category.", 
"Fit step/threshold estimates before reporting category structure.", 
"Retain the threshold table if you plan to include category probability curves.", 
"Run bias screening if the manuscript needs interaction-level follow-up.", 
"Run bias screening before discussing interaction-level anomalies.", 
"Compute or document this component before manuscript export.", 
"Run diagnose_mfrm() so the QC and facet dashboards can be rendered from the current analysis bundle.", 
"Run residual PCA if you want scree/loadings visuals for residual-structure follow-up.", 
"Run subset/connectivity diagnostics before showing design-matrix or linkage visuals.", 
"Retain fit and residual outputs if you want displacement or inter-rater follow-up figures.", 
"For MML reporting runs, call diagnose_mfrm(..., diagnostic_mode = \"both\") to enable strict marginal follow-up visuals where supported.", 
"Run bias or DIF screening before discussing interaction-level visuals.", 
"Resolve convergence before using information or precision curves in reporting.", 
"Add fit or threshold inputs if you want figure-ready diagnostics."
), AvailableAction = c("", "", "", "", "", "Report the chosen adjustment or absence of adjustment, original estimates, and uncertainty limitations.", 
"Report the counts and discuss sparse/marginal levels. Availability of this screen is not evidence of adequate sample size or precision.", 
"Report nesting classifications and (where applicable) the Kish design effect before generalizing rater severity beyond the sampled raters.", 
"Use standardized residuals as screening diagnostics, not as standalone proof of model adequacy.", 
"Report residual PCA as exploratory residual-structure follow-up, not as a standalone dimensionality test.", 
"Use `mfrm_report(type = 'precision', fit, diagnostics = diagnostics)$fit_separation_basis` before drafting fit/separation wording; export `fit_measures_table()` or `facets_fit_review()` when df/ZSTD sensitivity or external FACETS matching is part of the report.", 
"", "", "", "", "", "", "", "Use category counts as descriptive support for category use, not as a standalone quality verdict.", 
"Report average measures by category as descriptive scale-functioning evidence.", 
"Describe threshold ordering as category-structure evidence under the fitted model, not as a standalone proof of scale validity.", 
"Use category probability curves as descriptive follow-up for scale structure.", 
"", "Report these findings as screening results, not as formal hypothesis tests.", 
"Include a Wright map when the manuscript benefits from a shared-scale targeting display.", 
"Use the dashboard as a first-pass triage view, then move to the specific follow-up plot behind each flag.", 
"Use residual PCA plots as exploratory structure follow-up, not as standalone dimensionality proof.", 
"Use the design-matrix view to support linkage and comparability claims.", 
"Use displacement and inter-rater views to localize QC issues after dashboard screening.", 
"Treat strict marginal plots as exploratory corroboration screens, then corroborate with design review and legacy diagnostics.", 
"Use bias/DIF plots as screening follow-up, not as formal hypothesis tests.", 
"", "Use category curves and fit visuals as local descriptive follow-up after QC screening."
)), class = "data.frame", row.names = c(NA, -33L))
.mfrmr_table_report_checklist_pop_schema <- structure(list(Section = c("Population Model", "Population Model", 
"Population Model", "Population Model", "Population Model", "Population Model"
), Item = c("Latent-regression basis", "Population coefficients and residual variance", 
"Model-matrix covariate coding", "Complete-case omission review", 
"Population-model posterior scoring wording", "ConQuest overlap wording"
), Severity = c("required", "required", "required", "required", 
"recommended", "recommended"), SourceComponent = c("fit$population", 
"summary(fit)$population_coefficients + summary(fit)$population_overview", 
"summary(fit)$population_coding + fit$population$xlevels + fit$population$contrasts", 
"summary(fit)$population_overview + summary(fit)$caveats", "predict_mfrm_units() / sample_mfrm_plausible_values()", 
"README latent-regression status + review_conquest_overlap()"
), PlotHelper = c(NA_character_, NA_character_, NA_character_, 
NA_character_, NA_character_, NA_character_), DrawFreeRoute = c(NA_character_, 
NA_character_, NA_character_, NA_character_, NA_character_, NA_character_
), PlotReturnClass = c(NA_character_, NA_character_, NA_character_, 
NA_character_, NA_character_, NA_character_), MissingAction = c("Fit with `method = \"MML\"`, `population_formula`, and one-row-per-person `person_data` before reporting latent regression.", 
"Inspect `summary(fit)$population_coefficients` and `summary(fit)$population_overview` before reporting latent-regression effects.", 
"Inspect `summary(fit)$population_coding` and document categorical levels/contrasts before scoring or reporting the population model.", 
"Review omitted persons/rows and the population-data policy before reporting the population model.", 
"Compute or document this component before manuscript export.", 
"Compute or document this component before manuscript export."
), AvailableAction = c("", "", "Use `summary(fit)$population_coding` to document categorical levels, contrasts, and encoded columns used by scoring/replay.", 
"", "When reporting EAP/PV outputs, state whether they use the fitted population-model posterior and document the required `person_data` input.", 
"")), class = "data.frame", row.names = c(NA, -6L))

# --- Phase B1 Batch B1-2 static tables (bundle summaries, scopes, specialized ggplot bar specs) ---
.mfrmr_bundle_export_reporting_maps <- list(
  bundle = data.frame(
    Area = c(
      "Export counts",
      "Artifact catalog / file inventory",
      "Human-readable review",
      "Replay / archival bridge"
    ),
    CoveredHere = c("yes", "yes", "yes", "yes"),
    CompanionOutput = c(
      "summary(bundle)$summary / format_summary",
      "summary(bundle)$artifact_catalog",
      "bundle HTML artifact when requested",
      "manifest / replay script / zip bundle"
    ),
    stringsAsFactors = FALSE
  ),
  appendix = data.frame(
    Area = c(
      "Export counts",
      "Artifact catalog / handoff",
      "Human-readable review",
      "Downstream manuscript bridge"
    ),
    CoveredHere = c("yes", "yes", "yes", "yes"),
    CompanionOutput = c(
      "summary(appendix)$summary / format_summary",
      "summary(appendix)$artifact_catalog",
      "appendix HTML artifact when include_html = TRUE",
      "CSV appendix tables + apa_table() / manuscript QA"
    ),
    stringsAsFactors = FALSE
  )
)

.mfrmr_bundle_summary_defaults <- list(
  title = "mfrmr Bundle Summary",
  summary = "Summary table",
  preview = "Preview",
  settings = "Settings"
)

.mfrmr_bundle_summary_maps <- list(
  mfrm_unexpected = list(title = "mfrmr Unexpected Response Summary", summary = "Threshold summary", preview = "Flagged responses"),
  mfrm_fair_average = list(title = "mfrmr Adjusted Score Summary", summary = "Overview", preview = "Facet-level adjusted-score rows"),
  mfrm_displacement = list(title = "mfrmr Displacement Summary", summary = "Displacement summary", preview = "Displacement rows"),
  mfrm_interrater = list(title = "mfrmr Agreement Summary", summary = "Agreement summary", preview = "Rater-pair rows"),
  mfrm_facets_chisq = list(title = "mfrmr Facet Variability Summary", summary = "Facet variability summary", preview = "Facet rows"),
  mfrm_bias_interaction = list(title = "mfrmr Bias Interaction Summary", summary = "Interaction summary", preview = "Ranked interaction rows"),
  mfrm_bias_iteration = list(title = "mfrmr Bias Iteration Summary", summary = "Iteration summary", preview = "Iteration rows"),
  mfrm_bias_pairwise = list(title = "mfrmr Bias Pairwise Summary", summary = "Pairwise summary", preview = "Contrast rows"),
  mfrm_rating_scale = list(title = "mfrmr Rating Scale Summary", summary = "Category/threshold summary", preview = "Category rows"),
  mfrm_category_structure = list(title = "mfrmr Category Structure Summary", summary = "Category structure overview", preview = "Category structure rows"),
  mfrm_category_curves = list(title = "mfrmr Category Curves Summary", summary = "Curve grid summary", preview = "Boundary / curve rows"),
  mfrm_measurable = list(title = "mfrmr Measurable Summary", summary = "Run overview", preview = "Facet/category rows"),
  mfrm_unexpected_after_bias = list(title = "mfrmr Unexpected-after-Bias Summary", summary = "After-bias threshold summary", preview = "After-bias flagged rows"),
  mfrm_output_bundle = list(title = "mfrmr Output File Bundle Summary", summary = "Output overview", preview = "Output preview rows"),
  mfrm_residual_pca = list(title = "mfrmr Residual PCA Summary", summary = "PCA overview", preview = "Eigenvalue / loading rows"),
  mfrm_specifications = list(title = "mfrmr Specifications Summary", summary = "Specification header", preview = "Specification rows"),
  mfrm_data_quality = list(title = "mfrmr Data Quality Summary", summary = "Data quality overview", preview = "Review rows"),
  mfrm_fit_measures = list(title = "mfrmr Fit Measures Summary", summary = "Fit-status overview", preview = "Fit-measure rows"),
  mfrm_facets_fit_df_guide = list(title = "mfrmr FACETS Fit df Guide", summary = "Guide overview", preview = "Comparison steps"),
  mfrm_iteration_report = list(title = "mfrmr Iteration Report Summary", summary = "Iteration overview", preview = "Iteration rows"),
  mfrm_subset_connectivity = list(title = "mfrmr Subset Connectivity Summary", summary = "Subset overview", preview = "Subset/node rows"),
  mfrm_facet_statistics = list(title = "mfrmr Facet Profile Summary", summary = "Facet-profile overview", preview = "Facet-profile rows"),
  mfrm_precision_review = list(title = "mfrmr Precision Review Summary", summary = "Precision overview", preview = "Review checks"),
  mfrm_facets_contract_review = list(title = "mfrmr FACETS Output Contract Review Summary", summary = "Contract review overview", preview = "Lowest-coverage items"),
  mfrm_reference_review = list(title = "mfrmr Reference Review Summary", summary = "Reference review overview", preview = "Attention items"),
  mfrm_reference_benchmark = list(title = "mfrmr Reference Case Check Summary", summary = "Case check summary", preview = "Reference-case fit runs"),
  mfrm_reporting_checklist = list(title = "mfrmr Reporting Checklist Summary", summary = "Checklist coverage", preview = "Checklist items"),
  mfrm_bias_collection = list(title = "mfrmr Bias Collection Summary", summary = "Interaction summary", preview = "Per-pair results"),
  mfrm_manifest = list(title = "mfrmr Manifest Summary", summary = "Analysis overview", preview = "Manifest tables"),
  mfrm_replay_script = list(title = "mfrmr Replay Script Summary", summary = "Replay settings", preview = "Script text"),
  mfrm_conquest_overlap_bundle = list(title = "mfrmr ConQuest Overlap Bundle Summary", summary = "Overlap scope summary", preview = "Comparison targets"),
  mfrm_conquest_overlap_tables = list(title = "mfrmr ConQuest Overlap Table Normalization Summary", summary = "Normalization overview", preview = "Standardized tables"),
  mfrm_conquest_overlap_review = list(title = "mfrmr ConQuest Overlap Review Summary", summary = "Comparison overview", preview = "Attention items"),
  export_bundle = list(title = "mfrmr Export Bundle Summary", summary = "Export overview", preview = "Written files"),
  mfrm_export_bundle = list(title = "mfrmr Export Bundle Summary", summary = "Export overview", preview = "Written files"),
  summary_appendix_export = list(title = "mfrmr Summary Appendix Export Summary", summary = "Appendix export overview", preview = "Written appendix files"),
  mfrm_summary_appendix_export = list(title = "mfrmr Summary Appendix Export Summary", summary = "Appendix export overview", preview = "Written appendix files"),
  mfrm_facet_equivalence = list(title = "mfrmr Facet Equivalence Summary", summary = "Equivalence overview", preview = "Pairwise / ROPE rows")
)

.mfrmr_simple_bundle_summary_specs <- list(
  mfrm_unexpected = list(
    validator = "unexpected",
    summary_candidates = "summary",
    preview_candidates = "table",
    settings_candidates = "thresholds",
    notes = "Unexpected-response summary for quick residual screening.",
    append_object_notes = FALSE
  ),
  mfrm_displacement = list(
    validator = "",
    summary_candidates = "summary",
    preview_candidates = "table",
    settings_candidates = "thresholds",
    notes = "Displacement summary for anchor drift and baseline drift checks.",
    append_object_notes = FALSE
  ),
  mfrm_interrater = list(
    validator = "descriptive",
    summary_candidates = "summary",
    preview_candidates = "pairs",
    settings_candidates = "settings",
    notes = "Inter-rater agreement compares matched scoring contexts; severity spread is distinct from agreement.",
    append_object_notes = TRUE
  ),
  mfrm_facets_chisq = list(
    validator = "",
    summary_candidates = "summary",
    preview_candidates = "table",
    settings_candidates = "thresholds",
    notes = "Facet variability summary with fixed/random reference tests.",
    append_object_notes = FALSE
  ),
  mfrm_bias_interaction = list(
    validator = "",
    summary_candidates = "summary",
    preview_candidates = c("ranked_table", "facet_profile"),
    settings_candidates = "thresholds",
    notes = "Bias interaction report with ranked cells and facet-level profiles.",
    append_object_notes = FALSE
  ),
  mfrm_measurable = list(
    validator = "",
    summary_candidates = "summary",
    preview_candidates = c("facet_coverage", "category_stats", "subsets"),
    settings_candidates = character(0),
    notes = "Measurable-data summary with facet coverage, category diagnostics, and subset/connectivity checks.",
    append_object_notes = FALSE
  ),
  mfrm_specifications = list(
    validator = "",
    summary_candidates = "header",
    preview_candidates = c("data_spec", "facet_labels", "output_spec", "convergence_control", "anchor_summary"),
    settings_candidates = character(0),
    notes = "Model specification summary for method and run documentation.",
    append_object_notes = FALSE
  ),
  mfrm_iteration_report = list(
    validator = "",
    summary_candidates = "summary",
    preview_candidates = "table",
    settings_candidates = "settings",
    notes = "Legacy-compatible Table 3 replay of estimation iterations.",
    append_object_notes = FALSE
  ),
  mfrm_subset_connectivity = list(
    validator = "",
    summary_candidates = "summary",
    preview_candidates = c("listing", "nodes"),
    settings_candidates = "settings",
    notes = "Legacy-compatible Table 6 subset/connectivity report with subset and node listings.",
    append_object_notes = FALSE
  ),
  mfrm_facets_fit_df_guide = list(
    validator = "",
    summary_candidates = "summary",
    preview_candidates = c("decision_guide", "column_guide", "formula_guide"),
    settings_candidates = "settings",
    notes = "FACETS-style fit df and ZSTD comparison guide. Compare MnSq first, then df and ZSTD.",
    append_object_notes = FALSE
  )
)

.mfrmr_scope_reference_benchmark_base <- data.frame(
  Area = c(
    "Package reference check",
    "Latent-regression omission policy",
    "ConQuest-overlap package-side check",
    "External ConQuest validation"
  ),
  Interpretation = c(
    "Use as a package reference check.",
    "Complete-case omission behavior is reviewed only when the omission case is requested.",
    "The check covers package-side export, normalization, and review plumbing only.",
    "The package reference benchmark is not a substitute for reviewing external ConQuest output."
  ),
  stringsAsFactors = FALSE
)

.mfrmr_scope_conquest_command_base <- data.frame(
  Area = c(
    "ConQuest command template",
    "Command-comment syntax",
    "Official command-reference alignment",
    "Overlap model scope",
    "External output requirements",
    "External comparison scope"
  ),
  Interpretation = c(
    "Use the command text as a starting point for a local ConQuest run, not as an executed benchmark.",
    "The executable command contains commands only; explanatory prose remains in the bundle README.",
    "CSV input with PID/keeps variables needs explicit widths in the command template.",
    "The bundle does not generalize to full many-facet or polytomous ConQuest workflows.",
    "Review and combine external parameter, beta, sigma, and case outputs before review normalization.",
    "External comparison remains scoped until external outputs are reviewed and tolerances are justified."
  ),
  stringsAsFactors = FALSE
)

.mfrmr_scope_conquest_normalization_base <- data.frame(
  Area = c(
    "Extracted table normalization",
    "Raw ConQuest text parsing",
    "Bundle matching",
    "Pre-review table check",
    "Generated estimation metadata"
  ),
  Interpretation = c(
    "Population, item, and case tables have been converted to the mfrmr review contract.",
    "No general report parser is used; optional generated estimation metadata are described separately below.",
    "Identifier matching and numerical comparison are intentionally handled by the review step.",
    "Resolve duplicate IDs or non-numeric estimates before treating the review as clean.",
    "Stopping/model metadata are separate from estimate extraction; they do not establish numerical precision or common input data."
  ),
  stringsAsFactors = FALSE
)

.mfrmr_scope_conquest_review_base <- data.frame(
  Area = c(
    "User-supplied table review",
    "Raw ConQuest text parsing",
    "External comparison scope",
    "Attention items",
    "External stopping status",
    "Location alignment"
  ),
  Interpretation = c(
    "The review compares supplied normalized tables against the mfrmr overlap bundle.",
    "This helper does not parse raw ConQuest report text.",
    "Numerical agreement is limited to the documented overlap and supplied tables.",
    "Nonzero attention items include row mismatches, unknown origins and failed external stopping.",
    "A met stopping criterion does not establish numerical precision or inferential validity.",
    "Unknown origins withhold aligned EAP/intercept errors; raw differences remain descriptive."
  ),
  stringsAsFactors = FALSE
)

.mfrmr_gg_bar_view_specs <- data.frame(
  nm = c(
    "specifications", "specifications", "specifications",
    "anchor_review", "anchor_review", "anchor_review",
    "data_description", "data_description", "data_description",
    "measurable", "measurable", "measurable",
    "data_quality", "data_quality", "data_quality", "data_quality", "data_quality",
    "fit_measures",
    "facet_statistics", "facet_statistics",
    "visual_summaries"
  ),
  p_kind = c(
    "convergence", "facet_elements", "issue_counts",
    "convergence", "facet_elements", "issue_counts",
    "facet_levels", "missing", "*",
    "category_counts", "subset_observations", "*",
    "row_review", "facet_category_usage", "facet_response_patterns", "missing_rows", "*",
    "status",
    "sds", "*",
    "*"
  ),
  label_mode = c(
    "col", "col", "col",
    "col", "col", "col",
    "col", "col", "col",
    "col", "subset_prefix", "col",
    "col", "facet_level", "facet_level", "col", "col",
    "col",
    "col", "col",
    "col"
  ),
  label_col = c(
    "Setting", "Facet", "Issue",
    "Setting", "Facet", "Issue",
    "Facet", "Column", "Score",
    "Category", "Subset", "Facet",
    "Status", "Facet", "Facet", "Field", "Score",
    "FitStatus",
    "Facet", "Facet",
    "Visual"
  ),
  val_col = c(
    "Value", "Elements", "N",
    "Value", "Elements", "N",
    "Levels", "Missing", "WeightedN",
    "Count", "Observations", "Levels",
    "N", "IssueCategories", "DominantPercent", "Count", "Count",
    "Rows",
    "SD", "Mean",
    "Messages"
  ),
  val_scale = c(
    1, 1, 1,
    1, 1, 1,
    1, 1, 1,
    1, 1, 1,
    1, 1, 100, 1, 1,
    1,
    1, 1,
    1
  ),
  ylab = c(
    "Value", "Elements", "Rows",
    "Value", "Elements", "Rows",
    "Levels", "Missing", "Weighted N",
    "Count", "Observations", "Levels",
    "Rows", "Zero or sparse categories", "Dominant score (%)", "Rows", "Count",
    "Rows",
    "SD", "Mean",
    "Messages"
  ),
  fill_key = c(
    "accent_primary", "accent_primary", "fail",
    "accent_primary", "accent_primary", "fail",
    "success", "accent_tertiary", "accent_primary",
    "success", "accent_tertiary", "accent_primary",
    "accent_primary", "accent_primary", "accent_primary", "accent_secondary", "accent_tertiary",
    "accent_primary",
    "accent_tertiary", "accent_primary",
    "accent_tertiary"
  ),
  h_ref = c(
    NA_real_, NA_real_, NA_real_,
    NA_real_, NA_real_, NA_real_,
    NA_real_, NA_real_, NA_real_,
    NA_real_, NA_real_, NA_real_,
    NA_real_, NA_real_, 95, NA_real_, NA_real_,
    NA_real_,
    NA_real_, NA_real_,
    NA_real_
  ),
  stringsAsFactors = FALSE
)

# --- Phase B1 Batch B1-3 simulation structural design static registries ---
.mfrmr_table_sim_report_mode_registry <- structure(list(mode = c("brief", "snapshot", "operation"), payload_contract = c("arbitrary_facet_design_report_brief", 
"arbitrary_facet_design_report_snapshot", "arbitrary_facet_design_report_operation"
), default_surface = c("digest", "digest", "digest"), carries_nested_graph = c(FALSE, 
FALSE, TRUE), note = c("Selected surface plus headline table and surface index.", 
"Compact headline metadata plus one selected surface.", "Full compact report operation with selected surface and nested registry."
)), row.names = c(NA, -3L), class = c("tbl_df", "tbl", "data.frame"
))
simulation_structural_design_review_metric_registry <- structure(list(metric = c("total_observations", "observations_per_person", 
"observations_per_criterion", "expected_observations_per_rater", 
"assignment_fraction"), basis_class = c("exact_identity", "exact_identity", 
"exact_identity", "balanced_expectation", "density_ratio"), formula = c("n_person * raters_per_person * n_criterion", 
"raters_per_person * n_criterion", "n_person * raters_per_person", 
"(n_person * raters_per_person * n_criterion) / n_rater", "raters_per_person / n_rater"
), interpretation = c("Total number of scored observations implied by the current design row.", 
"Number of scored observations contributed by one person under the current design row.", 
"Number of scored observations contributed to one criterion across persons.", 
"Average expected rater load under balanced assignment, not a guaranteed realized count.", 
"Fraction of available raters assigned to each person."), psychometric = c(FALSE, 
FALSE, FALSE, FALSE, FALSE)), row.names = c(NA, -5L), class = c("tbl_df", 
"tbl", "data.frame"))
simulation_structural_design_review_load_balance_registry <- structure(list(metric = c("expected_observations_per_rater", 
"expected_person_assignments_per_rater", "observation_load_floor", 
"observation_load_ceiling", "observation_load_remainder", "perfect_integer_observation_balance"
), basis_class = c("balanced_expectation", "balanced_expectation", 
"integer_balance_bound", "integer_balance_bound", "exact_identity", 
"exact_identity"), formula = c("(n_person * raters_per_person * n_criterion) / n_rater", 
"(n_person * raters_per_person) / n_rater", "floor((n_person * raters_per_person * n_criterion) / n_rater)", 
"ceiling((n_person * raters_per_person * n_criterion) / n_rater)", 
"(n_person * raters_per_person * n_criterion) %% n_rater", "as.integer(((n_person * raters_per_person * n_criterion) %% n_rater) == 0)"
), interpretation = c("Average observation load per rater under balanced assignment, not a guaranteed realized count.", 
"Average person-assignment load per rater under balanced assignment, not a guaranteed realized count.", 
"Lower integer observation count per rater under the most even observation-level split implied by the current design row.", 
"Upper integer observation count per rater under the most even observation-level split implied by the current design row.", 
"Number of observations left over after equal integer splitting across raters.", 
"Indicator that the total observation count is divisible by the number of raters."
), psychometric = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)), row.names = c(NA, 
-6L), class = c("tbl_df", "tbl", "data.frame"))
simulation_structural_design_review_coverage_registry <- structure(list(metric = c("person_criterion_cells", "criterion_replications_per_person", 
"rater_pair_overlap_per_cell", "total_rater_pair_overlaps", "pair_coverage_fraction_per_cell", 
"redundant_scoring"), basis_class = c("exact_identity", "exact_identity", 
"exact_identity", "exact_identity", "exact_ratio", "exact_identity"
), formula = c("n_person * n_criterion", "raters_per_person", 
"choose(raters_per_person, 2)", "n_person * n_criterion * choose(raters_per_person, 2)", 
"ifelse(choose(n_rater, 2) > 0, choose(raters_per_person, 2) / choose(n_rater, 2), 0)", 
"as.integer(raters_per_person > 1)"), interpretation = c("Number of person-by-criterion cells implied by the current design row.", 
"Number of ratings attached to each person-by-criterion cell.", 
"Number of distinct rater pairs overlapping within one scored cell.", 
"Total number of rater-pair overlaps implied across all person-by-criterion cells.", 
"Fraction of available rater pairs represented within one scored cell; set to 0 when fewer than two raters are available.", 
"Indicator that the design uses more than one rater per scored cell."
), psychometric = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)), row.names = c(NA, 
-6L), class = c("tbl_df", "tbl", "data.frame"))
simulation_structural_design_review_guardrail_registry <- structure(list(guardrail = c("rater_linking_regime", "pair_coverage_regime", 
"integer_balance_regime", "redundancy_regime"), basis_class = c("exact_classification", 
"exact_classification", "exact_classification", "exact_classification"
), rule = c("ifelse(raters_per_person <= 1, 'single_rater', ifelse(raters_per_person >= n_rater, 'fully_crossed', 'partial_overlap'))", 
"ifelse(pair_coverage_fraction_per_cell <= 0, 'no_pair_coverage', ifelse(pair_coverage_fraction_per_cell >= 1, 'full_pair_coverage', 'partial_pair_coverage'))", 
"ifelse(perfect_integer_observation_balance == 1, 'integer_balanced', 'integer_unbalanced')", 
"ifelse(redundant_scoring == 1, 'redundant', 'single_rater_only')"
), interpretation = c("Exact cell-level linking regime implied by the current assignments-per-person relative to the available rater count.", 
"Exact pair-coverage regime implied by the current within-cell rater overlap fraction.", 
"Exact integer-balance regime induced by the current total observation count and rater count.", 
"Exact indicator of whether each scored cell uses more than one rater."
), psychometric = c(FALSE, FALSE, FALSE, FALSE)), row.names = c(NA, 
-4L), class = c("tbl_df", "tbl", "data.frame"))
simulation_structural_design_review_readiness_registry <- structure(list(indicator = c("supports_multi_rater_cells", "supports_pair_overlap", 
"supports_integer_balanced_load", "supports_full_pair_coverage"
), basis_class = c("exact_indicator", "exact_indicator", "exact_indicator", 
"exact_indicator"), rule = c("as.integer(redundancy_regime == 'redundant')", 
"as.integer(pair_coverage_regime != 'no_pair_coverage')", "as.integer(integer_balance_regime == 'integer_balanced')", 
"as.integer(pair_coverage_regime == 'full_pair_coverage')"), 
    interpretation = c("Exact indicator that each scored cell uses more than one rater.", 
    "Exact indicator that the current design yields at least one within-cell rater pair overlap.", 
    "Exact indicator that the total observation count is evenly divisible across raters.", 
    "Exact indicator that every available rater pair is represented within each scored cell."
    ), psychometric = c(FALSE, FALSE, FALSE, FALSE)), row.names = c(NA, 
-4L), class = c("tbl_df", "tbl", "data.frame"))
.mfrmr_table_structural_design_table_index_base <- structure(list(Table = c("overview", "profile_summary", "load_balance_summary", 
"coverage_summary", "guardrail_summary", "readiness_summary", 
"recommendation_table"), Role = c("overview", "profile", "load_balance", 
"coverage", "guardrails", "readiness", "recommendation"), Description = c("Headline active-branch configuration and selected branch surface.", 
"Deterministic observation/load profile for the current design grid.", 
"Balanced-expectation and integer split summaries.", "Coverage/connectivity summaries implied by the current design grid.", 
"Exact overlap/balance regime summaries.", "Exact structural readiness indicators and tier summaries.", 
"Conservative deterministic recommendation ranking."), stringsAsFactors = c(FALSE, 
FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)), row.names = c(NA, 
-7L), class = c("tbl_df", "tbl", "data.frame"))
.mfrmr_map_structural_design_direct_routes <- c(structural_design_profile = "profile_metrics", structural_design_load_balance = "load_balance", 
structural_design_coverage = "coverage", structural_design_readiness = "readiness_tiers", 
structural_design_appendix_roles = "appendix_roles", structural_design_appendix_sections = "appendix_sections", 
structural_design_appendix_presets = "appendix_presets", structural_design_selection_table_presets = "selection_tables", 
structural_design_selection_handoff_presets = "selection_handoff_presets", 
structural_design_selection_handoff = "selection_handoff", structural_design_selection_handoff_bundles = "selection_handoff_bundles", 
structural_design_selection_handoff_roles = "selection_handoff_roles", 
structural_design_selection_handoff_role_sections = "selection_handoff_role_sections", 
structural_design_selection_tables = "selection_tables", structural_design_selection_summary = "selection_bundles", 
structural_design_selection_roles = "selection_roles", structural_design_selection_sections = "selection_sections"
)
.mfrmr_sim_schema_drop_map <- list(compact_review_summary = "review", compact_review_table = "review", 
    compact_review_plot = "review", design_review_profile = "design_review", 
    design_review_load_balance = "design_review_profile", design_review_overview = c("design_review", 
    "design_review_profile"), design_review_load_balance_overview = "design_review_load_balance", 
    design_review_coverage = "design_review_profile", design_review_coverage_overview = "design_review_coverage", 
    design_review_guardrails = c("design_review_coverage", "design_review_load_balance"
    ), design_review_guardrail_overview = "design_review_guardrails", 
    design_review_readiness = "design_review_guardrails", design_review_readiness_overview = "design_review_readiness", 
    design_review_recommendation = c("design_review_readiness", 
    "design_review_profile"), design_review_recommendation_overview = "design_review_recommendation")