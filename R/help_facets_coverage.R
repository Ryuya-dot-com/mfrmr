#' FACETS Positioning Guide
#'
#' @description
#' `facets_positioning_guide()` gives user-facing wording for the relationship
#' between `mfrmr` and FACETS. Use it when a report, migration note, or
#' methods appendix must make clear that `mfrmr` is not a FACETS numerical
#' clone.
#'
#' @details
#' The guide separates four ideas that are easy to conflate:
#'
#' - estimation authority: fitted values come from `mfrmr` unless external
#'   FACETS output is explicitly supplied;
#' - compatibility purpose: FACETS-style names and files are transition,
#'   handoff, and report-organization surfaces;
#' - external comparison: FACETS comparisons require a supplied external table
#'   and should separate MnSq differences from df/ZSTD convention differences;
#' - extension surface: native R tables, plot data, GPCM diagnostics,
#'   network views, and G/D-study helpers are package extensions, not promises
#'   of FACETS menu-level reproduction.
#'
#' @return A data.frame with columns:
#' - `Topic`
#' - `Position`
#' - `RecommendedWording`
#' - `PrimaryRoute`
#'
#' @seealso [facets_term_crosswalk()], [facets_feature_coverage()],
#'   [facets_visual_contract()],
#'   [mfrmr_output_guide()],
#'   [read_facets_fit_table()], [facets_fit_review()]
#' @examples
#' facets_positioning_guide()
#' @export
facets_positioning_guide <- function() {
  data.frame(
    Topic = c(
      "Estimation authority",
      "Compatibility purpose",
      "External FACETS comparison",
      "Reporting source of truth",
      "Extension beyond FACETS"
    ),
    Position = c(
      "mfrmr estimates are package-native; FACETS-style names do not mean that FACETS estimated the model.",
      "FACETS-style wrappers, table labels, and files support transition, handoff, and report organization, not optimizer-level reproduction.",
      "Numerical comparison requires an explicit external FACETS output table supplied by the user.",
      "Inference and reporting should be based on native fit, diagnostics, review, table, and plot-data objects.",
      "GPCM, D-study, network, and reusable visualization data are extension routes rather than FACETS menu clones."
    ),
    RecommendedWording = c(
      "The model was estimated with mfrmr; FACETS-style output names are used only to organize the report.",
      "FACETS-style outputs were generated for handoff or reader familiarity; they are not evidence of FACETS numerical equivalence.",
      "When external FACETS output is supplied, compare MnSq first and report df/ZSTD convention sensitivity separately.",
      "Report estimates, standard errors, fit summaries, and plots from documented mfrmr objects.",
      "Use package-native extensions as additional evidence and label them as mfrmr analyses."
    ),
    PrimaryRoute = c(
      "fit_mfrm(); diagnose_mfrm(); reporting_checklist()",
      "facets_feature_coverage(); facets_visual_contract(); run_mfrm_facets(); facets_output_file_bundle()",
      "read_facets_fit_table(); facets_fit_review(); fit_measures_table(df_sensitivity = TRUE)",
      "build_summary_table_bundle(); build_visual_summaries(); plot_data()",
      "gpcm_capability_matrix(); mfrm_d_study(); mfrm_network_analysis(); plot_data_components()"
    ),
    stringsAsFactors = FALSE
  )
}

#' FACETS term crosswalk
#'
#' @description
#' `facets_term_crosswalk()` maps common FACETS-facing terms to the closest
#' current `mfrmr` term, helper, and interpretation boundary. Use it when a
#' FACETS-experienced reader is looking for a familiar table, column, command
#' word, file, or graph surface in `mfrmr` help.
#'
#' @param scope Which rows to return. `"all"` returns the full table. Other
#'   values filter the `Scope` column.
#'
#' @details
#' This helper is a terminology guide, not an equivalence claim. Rows marked
#' `same_concept` or `close_mfrmr_route` identify the ordinary package route
#' for the same reporting question. Rows marked `partial_handoff`,
#' `scope_boundary`, or `not_targeted` flag places where FACETS command files,
#' output dialogs, graph windows, Excel/Web integrations, or line-printer
#' formatting are broader than the current R-native package surface.
#'
#' A useful migration sequence is:
#' [facets_positioning_guide()] -> `facets_term_crosswalk()` ->
#' [facets_feature_coverage()] -> [facets_visual_contract()]. That sequence
#' first states the software relationship, then translates vocabulary, then
#' checks feature and visual coverage.
#'
#' @return A data.frame with columns:
#' - `Scope`
#' - `FACETSTerm`
#' - `FACETSSurface`
#' - `mfrmrTerm`
#' - `mfrmrRoute`
#' - `Relationship`
#' - `ReviewerNote`
#' - `Boundary`
#'
#' @references
#' Linacre, J. M. (2026). *A user's guide to FACETS, version 4.5.0*.
#' Output tables - files - plots - graphs:
#' <https://www.winsteps.com/facetman64/outputtableindex.htm>.
#' FACETS Graphfile:
#' <https://www.winsteps.com/facetman64/graphfile.htm>.
#'
#' @seealso [facets_positioning_guide()], [facets_feature_coverage()],
#'   [facets_visual_contract()], [mfrmr_output_guide()],
#'   [fit_measures_table()], [rating_scale_table()],
#'   [anchor_linking_contract()]
#' @examples
#' facets_term_crosswalk()
#' facets_term_crosswalk("fit")
#' facets_term_crosswalk("visuals")
#' @export
facets_term_crosswalk <- function(scope = c("all", "core", "model_control",
                                            "fit", "rating_scale", "anchors",
                                            "bias", "files", "visuals",
                                            "scope_boundaries")) {
  scope <- match.arg(scope)

  row <- function(scope, facets_term, facets_surface, mfrmr_term, route,
                  relationship, reviewer_note, boundary) {
    data.frame(
      Scope = scope,
      FACETSTerm = facets_term,
      FACETSSurface = facets_surface,
      mfrmrTerm = mfrmr_term,
      mfrmrRoute = route,
      Relationship = relationship,
      ReviewerNote = reviewer_note,
      Boundary = boundary,
      stringsAsFactors = FALSE
    )
  }

  out <- do.call(rbind, list(
    row("core", "Measure", "Table 7 measurement reports",
        "Estimate / measure on the package logit scale",
        "fit_measures_table(); diagnose_mfrm(); summary(fit)",
        "same_concept",
        "Use this when FACETS readers ask where element measures are reported.",
        "Centering, anchoring, constraints, and estimation method remain package-native."),
    row("core", "S.E.", "Table 7 measurement reports",
        "SE / ModelSE / RealSE depending on the current precision route",
        "fit_measures_table(); precision_review_report()",
        "close_mfrmr_route",
        "Report the precision tier before treating intervals as formal.",
        "Standard-error wording depends on model-based, hybrid, or exploratory precision support."),
    row("fit", "Infit MnSq", "Table 7 fit columns",
        "Infit",
        "fit_measures_table(); diagnose_mfrm()",
        "same_concept",
        "Closest route for FACETS users checking element fit.",
        "ZSTD and df conventions may differ; compare MnSq before ZSTD."),
    row("fit", "Outfit MnSq", "Table 7 fit columns",
        "Outfit",
        "fit_measures_table(); diagnose_mfrm()",
        "same_concept",
        "Closest route for FACETS users checking outlier-sensitive fit.",
        "ZSTD and df conventions may differ; compare MnSq before ZSTD."),
    row("fit", "ZStd / ZSTD", "Table 7 standardized fit",
        "InfitZSTD / OutfitZSTD with df-method metadata",
        "facets_fit_df_guide(); fit_measures_table(df_sensitivity = TRUE); facets_fit_review()",
        "close_mfrmr_route",
        "Use when reviewers ask why FACETS and mfrmr ZSTD do not match exactly.",
        "Convention-sensitive; report df method and avoid treating ZSTD disagreement as automatic numerical failure."),
    row("fit", "Separation / Reliability / Strata", "Table 7 summary statistics",
        "Facet separation, reliability, and related precision summaries",
        "facets_chisq_table(); precision_review_report(); diagnose_mfrm()$reliability",
        "close_mfrmr_route",
        "Keep these separate from inter-rater agreement and validity evidence.",
        "Reliability is fitted-measure precision evidence, not observed agreement or proof of construct validity."),
    row("rating_scale", "Fair-M Average", "Table 7 / Table 8 fair-average style summaries",
        "Fair-average table",
        "fair_average_table(); plot_fair_average(); rating_scale_table()",
        "close_mfrmr_route",
        "Use as adjusted category/facet descriptive evidence.",
        "For bounded GPCM, fair averages are slope-aware direct outputs, not FACETS score-side equivalence."),
    row("rating_scale", "Rating Scale= General", "Rating-scale control",
        "Common RSM threshold structure",
        "fit_mfrm(model = \"RSM\"); rating_scale_table(); category_structure_report()",
        "close_mfrmr_route",
        "Use for shared category thresholds across the fitted rating scale.",
        "`step_facet` is guarded as inappropriate for RSM because the step structure is shared."),
    row("rating_scale", "Rating Scale= Specific", "Rating-scale control",
        "Step-facet-specific PCM threshold structure",
        "fit_mfrm(model = \"PCM\", step_facet = \"Rater\")",
        "partial_handoff",
        "Use for FACETS-facing rater-specific category-use analyses.",
        "No FACETS Rating Scale= block parser or multiple named scale blocks."),
    row("model_control", "Model=", "FACETS model statement",
        "Explicit R function arguments",
        "fit_mfrm(person = ..., facets = ..., score = ..., model = ..., step_facet = ...)",
        "partial_handoff",
        "Translate the substantive model role, not the command syntax.",
        "No parser for FACETS command characters, multiple Model= statements, or row-level dispatch."),
    row("anchors", "D/A direct anchor", "Labels= / anchor controls",
        "Direct anchor table",
        "make_anchor_table(); review_mfrm_anchors(); fit_mfrm(anchors = ...)",
        "close_mfrmr_route",
        "Use when fixed element measures are part of scale maintenance.",
        "R-native tables replace FACETS command-file label syntax."),
    row("anchors", "D/G group anchor", "Labels= / anchor controls",
        "Group-anchor table",
        "review_mfrm_anchors(); fit_mfrm(group_anchors = ...)",
        "partial_handoff",
        "Use when the group mean is constrained rather than every element fixed.",
        "Direct anchors take precedence; no FACETS Labels= parser or element-number rewrite."),
    row("anchors", "Anchorfile=", "Output files / anchor rewrite",
        "Anchor/linking contract and exported anchor tables",
        "anchor_linking_contract(); make_anchor_table(); export_mfrm_bundle(include = \"anchors\")",
        "partial_handoff",
        "Use for R-native replay and reviewer handoff.",
        "Does not write a complete FACETS specification file with final measures and ,A flags."),
    row("bias", "Table 13 bias detail", "Bias/DIF output table",
        "Bias interaction report",
        "estimate_bias(); bias_interaction_report(); plot_bias_interaction()",
        "close_mfrmr_route",
        "Report as screening evidence unless a stronger design justifies inference.",
        "Bias rows do not by themselves establish fairness, DIF, or validity conclusions."),
    row("bias", "Table 14 pairwise bias", "Bias/DIF output table",
        "Pairwise bias report",
        "bias_pairwise_report(); build_fixed_reports()",
        "close_mfrmr_route",
        "Closest route for pairwise FACETS-style bias summaries.",
        "Higher-order bias runs and low-count cells need separate caution."),
    row("visuals", "Table 6 variable map", "Output Table 6",
        "Wright map / common-logit display",
        "plot(fit, type = \"wright\"); plot_wright_unified(); plot_data(type = \"wright\")",
        "close_mfrmr_route",
        "Use for shared-scale targeting, spread, and facet-level display.",
        "R-native plotting replaces FACETS ruler text and line-printer layout."),
    row("visuals", "Table 8 curves", "Output Table 8 / graph menu",
        "Category probability and expected-score curves",
        "category_curves_report(); plot(fit, type = \"ccc\"); plot(fit, type = \"pathway\")",
        "close_mfrmr_route",
        "Use for rating-scale/category-functioning figures.",
        "Plot data are R-native; FACETS graph-window behavior is not cloned."),
    row("visuals", "Graphfile", "FACETS graph plotting file",
        "Graphfile-style category curve output",
        "facets_output_file_bundle(include = \"graph\"); facets_visual_contract()",
        "partial_handoff",
        "Use when downstream review expects curve data similar to FACETS graph output.",
        "This is not the FACETS graph window or a full command-level graph option parser."),
    row("visuals", "DIF/bias Excel plot", "FACETS Excel plot output",
        "R-native bias plots",
        "plot_bias_interaction(plot = \"scatter\"); plot_bias_interaction(plot = \"heatmap\")",
        "partial_handoff",
        "Use to inspect bias patterns without depending on Excel workbook plots.",
        "Excel workbook generation and worksheet-code semantics are not implemented."),
    row("files", "Residual file", "Output file",
        "Observation-level residual export",
        "write_mfrm_residual_file(); diagnose_mfrm(); unexpected_response_table()",
        "close_mfrmr_route",
        "Use for reviewer handoff, row-level QC, and reproducible residual review.",
        "CSV/TSV package columns replace exact FACETS fixed-field syntax."),
    row("files", "Subset file", "Output file",
        "Connected-subset export",
        "write_mfrm_subset_file(); subset_connectivity_report()",
        "partial_handoff",
        "Use for disconnected-subset and linking-support review.",
        "Exports connectivity review tables, not a full FACETS UI-compatible subset command file."),
    row("files", "Scorefile", "Output file",
        "Score-side export/import contract",
        "facets_output_file_bundle(include = \"score\"); read_facets_fit_table()",
        "partial_handoff",
        "Use only for validated Rasch-family score-side routes.",
        "Field-selection and bounded-GPCM score-side equivalence are outside the current boundary."),
    row("scope_boundaries", "Output dialog / Webpage / Excel / SPSS / Word", "FACETS UI output integrations",
        "R-native exports and table bundles",
        "export_mfrm_results(); export_mfrm_bundle(); export_summary_appendix()",
        "not_targeted",
        "Use R/CSV/HTML package exports rather than claiming FACETS UI reproduction.",
        "External-application output dialogs and clickable Webpage plots are not release goals."),
    row("scope_boundaries", "Full FACETS command file", "FACETS control language",
        "Explicit R analysis script",
        "fit_mfrm(); build_mfrm_replay_script(); build_mfrm_manifest()",
        "scope_boundary",
        "Use a reproducible R script as the analysis authority.",
        "mfrmr does not parse arbitrary FACETS command files or emulate the full UI option surface.")
  ))

  row.names(out) <- NULL
  if (identical(scope, "all")) {
    return(out)
  }
  out[out$Scope == scope, , drop = FALSE]
}

#' FACETS Feature Coverage Matrix
#'
#' @description
#' `facets_feature_coverage()` summarizes how the current `mfrmr` release maps
#' the main FACETS model-control, rating-scale, output-table, output-file, and
#' graph-menu surface to package functions.
#'
#' Use this helper before migration work when you need a public, user-facing
#' answer to three questions:
#'
#' - which FACETS outputs have a close `mfrmr` route,
#' - which outputs are only partially covered by structured R objects,
#' - which FACETS-specific outputs are not implemented or intentionally outside
#'   the current package scope.
#'
#' @param status Which rows to return. `"all"` returns the full matrix.
#'   Other values filter by the `Status` column.
#'
#' @details
#' The matrix is based on the FACETS 64-bit output index, which lists output
#' Tables 1--14, DIF/bias plots, R/Web plots, output files, and graph-menu
#' curves, plus the FACETS model and rating-scale help pages. The command and
#' model rows matter because FACETS can use multiple `Model=` statements,
#' response-family scale codes, named rating-scale blocks, and output-dialog
#' file integrations that are broader than the current `fit_mfrm()` API.
#' `mfrmr` intentionally prioritizes structured R tables and reusable plot data
#' over exact FACETS command-language, UI, or line-printer reproduction.
#'
#' Status meanings:
#'
#' - `implemented`: a package-native route covers the substantive output.
#' - `partial`: the concept is covered, but not the full FACETS formatting,
#'   option surface, file type, or external integration.
#' - `not_implemented`: a FACETS feature has no direct package-native route in
#'   the current release.
#' - `not_targeted`: the feature is tied to FACETS UI, Web/Excel handoff, or
#'   another external program format and is not a release goal.
#'
#' @return A data.frame with columns:
#' - `FACETSArea`
#' - `FACETSFeature`
#' - `FACETSReference`
#' - `mfrmrRoute`
#' - `Status`
#' - `Scope`
#' - `GapOrBoundary`
#' - `Priority`
#'
#' @references
#' Linacre, J. M. (2026). *A user's guide to FACETS, version 4.5.0*.
#' Output tables - files - plots - graphs:
#' <https://www.winsteps.com/facetman64/outputtableindex.htm>.
#' Model statement help:
#' <https://www.winsteps.com/facetman64/models.htm>.
#' Rating-scale help:
#' <https://www.winsteps.com/facetman64/ratingscale.htm>.
#'
#' @seealso [facets_positioning_guide()], [facets_term_crosswalk()],
#'   [facets_visual_contract()], [mfrmr_output_guide()],
#'   [facets_fit_df_guide()], [read_facets_fit_table()], [facets_fit_review()],
#'   [gpcm_capability_matrix()]
#' @examples
#' facets_feature_coverage()
#' facets_feature_coverage("partial")
#' facets_feature_coverage("not_implemented")
#' @export
facets_feature_coverage <- function(status = c("all", "implemented", "partial",
                                               "not_implemented", "not_targeted")) {
  status <- match.arg(status)

  row <- function(area, feature, reference, route, status, scope, gap, priority) {
    data.frame(
      FACETSArea = area,
      FACETSFeature = feature,
      FACETSReference = reference,
      mfrmrRoute = route,
      Status = status,
      Scope = scope,
      GapOrBoundary = gap,
      Priority = priority,
      stringsAsFactors = FALSE
    )
  }

  out <- do.call(rbind, list(
    row("Program/model surface", "High-capacity FACETS engine and command-language scale",
        "facets.htm",
        "fit_mfrm(); facets_positioning_guide()", "partial",
        "Package-native long-data MFRM estimation through ordinary R objects.",
        "No FACETS capacity, Windows UI, 255-facet command-surface, or optimizer-level equivalence claim.", "defer"),
    row("Model/control", "Multiple simultaneous Model= statements and heterogeneous response families",
        "models.htm",
        "none", "not_implemented",
        "One response-model family is fitted per `fit_mfrm()` call.",
        "FACETS can dispatch observations to multiple model statements in one analysis; mfrmr requires separate explicit fits.", "defer"),
    row("Model/control", "FACETS Model= matching and control characters (?, #, ranges, @, -?, X, 0)",
        "models.htm",
        "fit_mfrm(..., model = ..., step_facet = ..., positive_facets = ..., dummy_facets = ...)",
        "partial",
        "R arguments cover common model roles, orientation, and structural constraints.",
        "No parser for FACETS model statements or row-level command-character dispatch.", "defer"),
    row("Model/control", "FACETS B interaction terms in Model= statements",
        "models.htm",
        "facet_interactions; estimate_bias(); bias_interaction_report()", "partial",
        "Two-way non-person interactions and bias-screening outputs are available.",
        "FACETS `B` syntax and arbitrary higher-order model-statement matching are not mirrored.", "release_core"),
    row("Model/control", "Dichotomy and Dn dichotomization scale codes",
        "models.htm",
        "fit_mfrm() with ordered two-category scores", "partial",
        "Binary Rasch analyses are supported as ordered two-category scores.",
        "FACETS `Dn` dichotomization and command-level scale-code handling are not implemented.", "defer"),
    row("Model/control", "Missing-data Model=M row matching",
        "models.htm",
        "missing_codes; recode_missing_codes()", "partial",
        "Data-level sentinel recoding and NA omission are available.",
        "No FACETS `M` model-statement route that marks observations as missing by row-matching rules.", "defer"),
    row("Model/control", "Binomial/Bernoulli and Poisson scale codes (Bn, B100, P)",
        "models.htm; table8_1dichotomy.htm",
        "none", "not_implemented",
        "No binomial-trial, percentage-as-binomial, or Poisson-count likelihood.",
        "Do not treat bounded GPCM as FACETS binomial/Poisson support.", "not_planned"),
    row("Model/control", "Model-statement weights and R-prefixed data replication",
        "models.htm",
        "weight_col", "partial",
        "Observation weights can be supplied through a data column.",
        "No FACETS model-statement weight syntax, zero-weight residual-file semantics, SE weight adjustment, or `R` replication parser.", "defer"),
    row("Rating scale/control", "Named rating-scale blocks with General and Specific threshold structures",
        "ratingscale.htm",
        "model = \"RSM\"; model = \"PCM\", step_facet = \"Rater\"; fit$config$design_spec",
        "partial",
        "Common RSM thresholds and step-facet-specific PCM thresholds are available.",
        "No named Rating Scale= block parser, multiple named scales, or per-model-statement General/Specific dispatch.", "release_core"),
    row("Rating scale/control", "Category labels, category recoding, and starting/anchored step values",
        "ratingscale.htm",
        "rating_min; rating_max; keep_original; fit$prep$score_map; anchors",
        "partial",
        "Integer category ranges, unused categories, observed-gap recoding, and element anchors are handled.",
        "No FACETS category-label parser, arbitrary recode grammar, or rating-scale step-anchor specification.", "defer"),
    row("Anchoring/linking", "Labels= element anchoring, group anchoring, weights, and target elements",
        "elements.htm",
        "anchors; group_anchors; review_mfrm_anchors(); make_anchor_table(); anchor_linking_contract()", "partial",
        "Direct anchors and group anchors are accepted as R tables with review checks.",
        "No FACETS Labels= command-file parser, element-number management, target-element syntax, or label-file rewrite.", "release_core"),
    row("Anchoring/linking", "Anchorfile= specification rewrite with final estimates and ,A flags",
        "anchoroutputfile.htm",
        "make_anchor_table(); anchor_linking_contract(); export_mfrm_bundle(include = \"anchors\")", "partial",
        "Reusable R-native anchor tables, anchor-contract CSVs, and replay metadata can be exported from fitted estimates.",
        "Does not write a complete FACETS specification file with final measures, scales, current settings, data, and `,A` flags.", "defer"),
    row("Output dialog/file integration", "FACETS output-dialog Webpage, SPSS, Excel, Word, Rdata, and field-selection routes",
        "output_dialog_box.htm",
        "export_mfrm_results(); export_mfrm_bundle(); plot_data()", "not_targeted",
        "Package-native CSV/TSV/R objects and plot-data routes are the release target.",
        "FACETS UI-driven external-application output and selectable field dialogs are not mirrored.", "not_planned"),
    row("Output table", "Table 1: specification summary", "table1.htm",
        "specifications_report()", "implemented",
        "Structured run settings and reproducibility context.",
        "Not an exact FACETS line-printer layout.", "release_core"),
    row("Output table", "Table 2: data summary report", "table2.htm",
        "data_quality_report(); describe_mfrm_data()", "implemented",
        "Rows, exclusions, missingness, score support, and response-pattern QC.",
        "Structured QC replaces FACETS text layout.", "release_core"),
    row("Output table", "Table 3: main iteration report", "table3.htm",
        "estimation_iteration_report()", "partial",
        "Convergence and replayed iteration evidence.",
        "Does not reproduce every FACETS optimizer-internal line.", "release_core"),
    row("Output table", "Table 4: unexpected responses", "table4.htm",
        "unexpected_response_table(); plot_unexpected()", "implemented",
        "Case-level unexpected-response screening.",
        "Structured table and plots, not printer-identical FACETS output.", "release_core"),
    row("Output table", "Table 5: measurable data summary", "table5.htm",
        "measurable_summary_table(); describe_mfrm_data()", "partial",
        "Facet coverage, category counts, subset/connectivity checks, residual moments, raw-score error variance, explained-variance approximation, and approximate global Pearson chi-square review.",
        "FACETS fixed-width layout and exact command-output wording are not reproduced; variance and Pearson rows are package-native approximations.", "release_core"),
    row("Output table", "Table 6.0: all-facet Wright map rulers", "table6.htm",
        "plot(fit, type = \"wright\"); plot_wright_unified()", "implemented",
        "Common-logit person/facet/threshold display.",
        "R-native graphics replace FACETS ruler text.", "release_core"),
    row("Output table", "Table 6.0.0: disjoint element listing", "table6_0_0.htm",
        "subset_connectivity_report()", "implemented",
        "Disconnected subsets and facet-by-subset coverage.",
        "Network-style graph is not the default display.", "release_core"),
    row("Output table", "Table 6.2: graphical facet statistics", "table6_2.htm",
        "facet_statistics_report(); plot(...)", "partial",
        "Facet statistics and visual summaries.",
        "FACETS M/S/Q/X printer-graph formatting is not reproduced exactly.", "release_core"),
    row("Output table", "Table 7: facet measurement report", "table7.htm",
        "fit_measures_table(); diagnose_mfrm(); summary(fit)", "implemented",
        "Measures, SEs, fit, anchoring status, and review flags.",
        "FACETS column order/options are broader than the default table.", "release_core"),
    row("Output table", "Table 7: reliability and chi-square", "table7summarystatistics.htm",
        "facets_chisq_table(); diagnose_mfrm()$reliability", "implemented",
        "Rasch/FACETS-style separation, reliability, and chi-square summaries.",
        "Uses package-native structured output.", "release_core"),
    row("Output table", "Table 7: agreement statistics", "table7agreementstatistics.htm",
        "interrater_agreement_table(); rater_network_analysis(); rater_halo_network_analysis(); plot_interrater_agreement()", "implemented",
        "Observed/expected agreement, pairwise rater-network, rater-by-criterion halo network, and rater-agreement views.",
        "Structured output replaces FACETS text blocks.", "release_core"),
    row("Output table", "Table 8.1: dichotomous/binomial/Poisson statistics",
        "table8_1dichotomous.htm",
        "rating_scale_table() for two-category ordered scores", "partial",
        "Two-category Rasch-category summaries are available.",
        "FACETS binomial-trial and Poisson-specific reports are not implemented.", "defer"),
    row("Output table", "Table 8.1: polytomous rating-scale/partial-credit statistics",
        "table8_1ratingscale.htm",
        "rating_scale_table(); category_structure_report()", "implemented",
        "Rating-scale/partial-credit category diagnostics and thresholds.",
        "Exact FACETS text layout is not reproduced.", "release_core"),
    row("Output table", "Table 8: scale-structure bar chart", "table8barchart.htm",
        "category_structure_report()", "partial",
        "Category structure and transition summaries.",
        "FACETS line-printer artwork is not reproduced exactly.", "release_core"),
    row("Output table", "Table 8: scale-structure probability curves", "table8curves.htm",
        "category_curves_report(); plot(fit, type = \"ccc\")", "implemented",
        "Category probability and expected-score curve data.",
        "Uses R-native plot data rather than FACETS graph text.", "release_core"),
    row("Output table", "Table 9: bias-estimation iteration report", "table9.htm",
        "estimate_bias(); bias_iteration_report()", "implemented",
        "Bias recalibration path and final iteration status.",
        "Conditional screening semantics are documented separately.", "release_core"),
    row("Output table", "Table 10: unexpected after allowing for bias", "table10.htm",
        "unexpected_after_bias_table()", "implemented",
        "Unexpected rows after the current bias-screening layer.",
        "Structured table replaces FACETS text layout.", "release_core"),
    row("Output table", "Table 11: bias-calculation counts", "table11.htm",
        "bias_count_table()", "implemented",
        "Response counts behind bias estimates.",
        "Structured output replaces FACETS text layout.", "release_core"),
    row("Output table", "Table 12: bias summary report", "table12.htm",
        "summary(estimate_bias(...)); plot_bias_interaction()", "partial",
        "Distributional and visual bias summaries are available.",
        "FACETS vertical frequency bar-chart is not reproduced exactly.", "release_core"),
    row("Output table", "Table 13: DIF/bias detail report", "table13.htm",
        "estimate_bias(); bias_interaction_report()", "implemented",
        "Ranked cell-level bias/interactions with screening statistics.",
        "Reported as screening evidence, not final fairness inference.", "release_core"),
    row("Output table", "Table 14: pairwise bias report", "table14.htm",
        "bias_pairwise_report(); build_fixed_reports()", "implemented",
        "Pairwise contrasts for two-way bias runs.",
        "Higher-order runs omit pairwise sections by design.", "release_core"),
    row("Output table", "DIF/bias Excel plot", "difbiasplot.htm",
        "plot_bias_interaction(plot = ...)", "partial",
        "R-native scatter, heatmap, and facet-profile bias displays.",
        "Excel-specific output is not implemented.", "defer"),
    row("R/Web plots", "Scatterplots and histograms from FACETS menus",
        "outputtableindex.htm",
        "plot_data(); package plot helpers", "partial",
        "Reusable plot data supports custom R graphics.",
        "FACETS arbitrary R/Web plotting menus are not mirrored.", "low"),
    row("R/Web plots", "X-Y plot: R Statistics", "xyplotr.htm",
        "plot_data(); user-defined R plotting", "partial",
        "Users can build X-Y plots from returned data frames.",
        "No dedicated FACETS-style arbitrary X-Y plot wrapper.", "low"),
    row("R/Web plots", "X-Y plot: Webpage", "xyplotwebpage.htm",
        "none", "not_targeted",
        "No package-native Webpage plot generator.",
        "Webpage menu output is a FACETS UI feature.", "not_planned"),
    row("R/Web plots", "X-Y-Z plot: R Statistics", "xyzplotr.htm",
        "plot(fit, type = \"ccc_surface\"); plot_data()", "partial",
        "Selected 3D/surface-ready plot data are available.",
        "No arbitrary FACETS X-Y-Z plot wrapper.", "low"),
    row("R/Web plots", "Histogram: R Statistics", "histogramr.htm",
        "plot_data(); plot(fit, type = \"wright\"); plot_qc_dashboard()", "partial",
        "Several package outputs include histogram-like summaries.",
        "No general FACETS histogram menu clone.", "low"),
    row("R/Web plots", "Generalizability Theory via R package gtheory", "gtheory.htm",
        "mfrm_generalizability(); mfrm_d_study(); compute_facet_icc()", "implemented",
        "Observed G-study variance components plus D-study projections with residual-scaling sensitivity.",
        "Package-native G/D-study route; not a FACETS/gtheory UI clone.", "release_core"),
    row("R/Web plots", "Connectivity network graph via igraph", "networkgraph.htm",
        "subset_connectivity_report(); mfrm_network_analysis(); rater_network_analysis(); rater_halo_network_analysis(); plot(..., type = \"network\")", "implemented",
        "Facet-level co-observation network plus rater agreement/disagreement/severity-direction and halo networks with reusable node/edge tables.",
        "R-native igraph analysis and display rather than FACETS menu output.", "release_core"),
    row("Output file", "Specification settings file", "specificationfile.htm",
        "build_mfrm_manifest(); build_mfrm_replay_script()", "partial",
        "R-native reproducibility manifest and replay script.",
        "Does not write a FACETS command specification file.", "release_core"),
    row("Output file", "Anchor output file", "anchorfile.htm",
        "make_anchor_table(); export_mfrm_bundle(include = \"anchors\")", "partial",
        "Reusable anchor tables from fitted estimates.",
        "Uses R/CSV tables rather than a complete FACETS anchor specification rewrite.", "release_core"),
    row("Output file", "Graph plotting file", "graphoutputfile.htm",
        "facets_output_file_bundle(include = \"graph\")", "implemented",
        "Graphfile-style category curve output.",
        "Command-level FACETS graph options are not fully mirrored.", "release_core"),
    row("Output file", "Output report file", "outputfile.htm",
        "export_summary_appendix(); build_fixed_reports()", "partial",
        "Structured appendix/report artifacts.",
        "Full FACETS report-file emulation is not implemented.", "defer"),
    row("Output file", "Residuals output file", "residualfile.htm",
        "write_mfrm_residual_file(); diagnose_mfrm(); unexpected_response_table(); residual plot helpers", "implemented",
        "Standalone observation-level residual CSV/TSV output, residual tables, and residual visualizations are available.",
        "Uses package-native residual columns rather than exact FACETS fixed-field residual syntax.", "release_core"),
    row("Output file", "Score output file", "scorefile.htm",
        "facets_output_file_bundle(include = \"score\"); read_facets_fit_table()",
        "partial",
        "Score-side export/import is available for validated Rasch-family routes.",
        "FACETS field-selection, one-file-per-facet fixed-field layout, and bounded GPCM score-side equivalence are outside the current boundary.", "release_core"),
    row("Output file", "Simulated data file", "simulatedfile.htm",
        "simulate_mfrm_data(); build_mfrm_sim_spec()", "partial",
        "Simulation data and explicit simulation specifications.",
        "Not a FACETS simulated-data file clone.", "release_core"),
    row("Output file", "Subset group-anchor file", "subsetfile.htm",
        "write_mfrm_subset_file(); group_anchors; review_mfrm_anchors(); make_anchor_table()", "partial",
        "Connected-subset summary/node files and group-anchor inputs/checks are available.",
        "The standalone subset writer exports connectivity review tables, not a full FACETS UI-compatible subset command file.", "release_core"),
    row("Output file", "Winsteps control and data file", "winstepsfile.htm",
        "none", "not_implemented",
        "No Winsteps control/data export route.",
        "Would require a separate Winsteps output contract.", "not_planned"),
    row("Graph menu", "Category probability curves", "graphs.htm",
        "category_curves_report(); plot(fit, type = \"ccc\")", "implemented",
        "Category probability curve data and plots.",
        "R-native plots replace FACETS graph menu output.", "release_core"),
    row("Graph menu", "Expected score ICC/IRF", "graphs.htm",
        "plot(fit, type = \"pathway\"); category_curves_report()", "implemented",
        "Expected-score curves over theta.",
        "Not labeled as FACETS ICC/IRF menu output.", "release_core"),
    row("Graph menu", "Cumulative probability curves", "graphs.htm",
        "category_curves_report(); plot(..., type = \"cumulative\")", "implemented",
        "Cumulative category-probability curve data, flipped direction data, and approximate .5 boundaries are available.",
        "R-native plot data replace FACETS graph-menu output.", "release_core"),
    row("Graph menu", "Test information function", "graphs.htm",
        "compute_information(); plot_information(type = \"tif\")", "implemented",
        "Design-weighted test/scale information curves.",
        "R-native information definition and plot data.", "release_core"),
    row("Graph menu", "Category information function", "graphs.htm",
        "category_curves_report(); plot(..., type = \"category_information\"); compute_information(); plot_information(type = \"iif\")", "implemented",
        "Category-specific information contributions, total information curves, and facet/level contribution curves are available.",
        "R-native plot data replace FACETS graph-menu output.", "release_core"),
    row("Graph menu", "Conditional probability curves", "graphs.htm",
        "category_curves_report()", "partial",
        "Category probability curves conditional on theta are available.",
        "FACETS conditional-probability menu semantics are not mirrored exactly.", "defer"),
    row("Specification/workflow", "Full FACETS command-file parser and UI option surface",
        "index.htm",
        "run_mfrm_facets(); fit_mfrm()", "not_targeted",
        "R function arguments are the package interface.",
        "Parsing arbitrary FACETS command files is outside the release scope.", "not_planned"),
    row("Specification/workflow", "Exact FACETS line-printer report emulation",
        "outputtableindex.htm",
        "build_fixed_reports() for selected tables", "not_targeted",
        "Selected fixed-width handoff is available.",
        "Exact full report emulation is intentionally not a package goal.", "not_planned"),
    row("Specification/workflow", "Raw FACETS report-text import",
        "outputtableindex.htm",
        "read_facets_fit_table() for delimited/fixed-field score extracts", "partial",
        "Fit/score table import is supported.",
        "General raw FACETS report parsing is not implemented.", "defer")
  ))

  row.names(out) <- NULL
  if (identical(status, "all")) {
    return(out)
  }
  out[out$Status == status, , drop = FALSE]
}

#' FACETS visual surface contract
#'
#' @description
#' `facets_visual_contract()` maps FACETS visual, graph-menu, and graph-file
#' surfaces to the closest current `mfrmr` plotting or plot-data route. Use this
#' when a FACETS user asks, "Where is the figure I used to inspect in FACETS?"
#'
#' @param scope Which rows to return. `"all"` returns the full table.
#'   `"output_table"`, `"graph_menu"`, `"output_file"`, and `"rweb"` filter by
#'   FACETS surface family. `"implemented"`, `"partial"`, and `"not_targeted"`
#'   filter by support status.
#'
#' @details
#' This is intentionally a visual-use contract, not a promise of pixel-identical
#' reproduction. FACETS Table 6 rulers, Table 8 line-printer displays,
#' Graphs-menu bitmaps, Excel bias plots, and R/Web plot menus are mapped to
#' `mfrmr`'s R-native `plot()` helpers, `mfrm_plot_data` payloads, and export
#' bundles. Exact FACETS UI behavior, clickable Webpage plots, Excel workbook
#' plot generation, and line-printer artwork are not release goals.
#'
#' The contract is meant to answer a practical migration question for FACETS
#' users: which `mfrmr` route should be opened first, which route exposes
#' editable plot data, whether the payload can normally be sent to
#' [as_ggplot()], and which claim boundary belongs in a report or handoff note.
#'
#' @return A data.frame with columns:
#' - `Scope`
#' - `FACETSVisualSurface`
#' - `FACETSReference`
#' - `mfrmrRoute`
#' - `Status`
#' - `ReaderUse`
#' - `PlotDataRoute`
#' - `Boundary`
#' - `FACETSExpectation`
#' - `FirstMfrmrRoute`
#' - `EditableDataRoute`
#' - `GgplotRoute`
#' - `ReportUse`
#' - `MigrationNote`
#' - `ClaimBoundary`
#'
#' @references
#' FACETS output tables, files, plots, and graphs:
#' <https://www.winsteps.com/facetman64/outputtableindex.htm>.
#' FACETS Table 6.0 Wright-map rulers:
#' <https://www.winsteps.com/facetman64/table6_0.htm>.
#' FACETS Table 8 probability curves:
#' <https://www.winsteps.com/facetman64/table8curves.htm>.
#' FACETS Graphfile:
#' <https://www.winsteps.com/facetman64/graphfile.htm>.
#'
#' @seealso [facets_term_crosswalk()], [facets_feature_coverage()],
#'   [mfrmr_visual_diagnostics], [mfrmr_output_guide()], [plot_data()],
#'   [plot_data_components()], [build_visual_summaries()]
#' @examples
#' facets_visual_contract()
#' facets_visual_contract("graph_menu")
#' facets_visual_contract("partial")
#' @export
facets_visual_contract <- function(scope = c("all", "output_table", "graph_menu",
                                             "output_file", "rweb",
                                             "implemented", "partial",
                                             "not_targeted")) {
  scope <- match.arg(scope)

  row <- function(scope, surface, reference, route, status,
                  reader_use, plot_data_route, boundary) {
    data.frame(
      Scope = scope,
      FACETSVisualSurface = surface,
      FACETSReference = reference,
      mfrmrRoute = route,
      Status = status,
      ReaderUse = reader_use,
      PlotDataRoute = plot_data_route,
      Boundary = boundary,
      stringsAsFactors = FALSE
    )
  }

  out <- do.call(rbind, list(
    row(
      "output_table",
      "Table 6.0 all-facet Wright map rulers",
      "https://www.winsteps.com/facetman64/table6_0.htm",
      "plot(fit, type = \"wright\"); plot_wright_unified(); plot_data(type = \"wright\")",
      "implemented",
      "Inspect shared-logit targeting, person distribution, facet levels, and thresholds.",
      "mfrm_plot_data via draw = FALSE or plot_data(type = \"wright\")",
      "R-native Wright maps replace FACETS ruler text; vertical/Yardstick formatting is not cloned."
    ),
    row(
      "output_table",
      "Table 6.2 graphical facet statistics",
      "https://www.winsteps.com/facetman64/table6_2.htm",
      "facet_statistics_report(); plot(..., type = \"measure\"); plot(..., type = \"fit\")",
      "partial",
      "Inspect facet-level measure, SE, fit, count, raw-score, fair-average, and point-measure distributions.",
      "mfrm_plot_data from plot(facet_statistics_report(...), draw = FALSE)",
      "FACETS M/S/Q/X line-printer bars are not reproduced exactly."
    ),
    row(
      "output_table",
      "Table 8 scale-structure bar chart",
      "https://www.winsteps.com/facetman64/table8barchart.htm",
      "category_structure_report(); plot(fit, type = \"pathway\")",
      "partial",
      "Inspect category transition points, expected-score half points, and category-order warnings.",
      "category_structure_report() tables plus pathway_map mfrm_plot_data",
      "FACETS Mode/Median/Mean line-printer artwork is not reproduced exactly."
    ),
    row(
      "output_table",
      "Table 8 scale-structure probability curves",
      "https://www.winsteps.com/facetman64/table8curves.htm",
      "category_curves_report(); plot(fit, type = \"ccc\"); plot(fit, type = \"pathway\")",
      "implemented",
      "Inspect category probability curves and expected-score ogives across theta.",
      "plot_data(category_curves_report(...), component = \"plot_long\")",
      "R-native curve data and plots replace FACETS line-printer probability curves."
    ),
    row(
      "output_table",
      "DIF/bias Excel plot for Tables 13-14",
      "https://www.winsteps.com/facetman64/t13menu.htm",
      "plot_bias_interaction(plot = \"scatter\"); plot_bias_interaction(plot = \"heatmap\"); plot_bias_interaction(plot = \"profile\")",
      "partial",
      "Inspect bias/interactions by cell, target/context facet, and pairwise pattern.",
      "mfrm_plot_data from plot_bias_interaction(..., draw = FALSE)",
      "Excel workbook plot generation, worksheet-code naming, and Excel limits are not implemented."
    ),
    row(
      "rweb",
      "R/Web scatterplots and histograms from FACETS menus",
      "https://www.winsteps.com/facetman64/plots-request.htm",
      "plot_data(); plot_data_components(); package plot helpers",
      "partial",
      "Build custom X-Y, histogram, and report graphics from returned tables.",
      "plot_data() over mfrm_plot_data or source report objects",
      "FACETS arbitrary R/Web plotting dialogs and clickable webpage plots are not mirrored."
    ),
    row(
      "rweb",
      "FACETS clickable Webpage plot UI",
      "https://www.winsteps.com/facetman64/plots-request.htm",
      "none",
      "not_targeted",
      "Use package-native R objects or external graphics tools instead.",
      "none",
      "Clickable FACETS Webpage plot generation is a FACETS UI feature, not a package goal."
    ),
    row(
      "rweb",
      "Connectivity network graph via R igraph",
      "https://www.winsteps.com/facetman64/outputtableindex.htm",
      "subset_connectivity_report(); mfrm_network_analysis(); build_mfrm_network_review(); plot(..., type = \"network\")",
      "implemented",
      "Inspect connectedness, disconnected subsets, rater networks, and halo-style co-observation structures.",
      "node/edge tables plus mfrm_plot_data network payloads",
      "R-native network review replaces FACETS menu output."
    ),
    row(
      "output_file",
      "Graph plotting file / Graphfile=",
      "https://www.winsteps.com/facetman64/graphfile.htm",
      "facets_output_file_bundle(include = \"graph\"); category_curves_report()",
      "implemented",
      "Export expected scores and category probabilities for external plotting.",
      "graphfile plus category_curves_report() curve tables",
      "Command-level FACETS graph options, fixed-column variants, and external app file types are not fully mirrored."
    ),
    row(
      "graph_menu",
      "Category probability curves",
      "https://www.winsteps.com/facetman64/probabilitycurves.htm",
      "category_curves_report(); plot(fit, type = \"ccc\")",
      "implemented",
      "Inspect whether ordered categories peak in sequence and where adjacent categories overlap.",
      "plot_data(category_curves_report(...), type = \"category_probability\")",
      "R-native plots replace FACETS graph-window interaction."
    ),
    row(
      "graph_menu",
      "Expected score ICC/IRF",
      "https://www.winsteps.com/facetman64/expectedscoreicc.htm",
      "plot(fit, type = \"pathway\"); category_curves_report()",
      "implemented",
      "Inspect monotone expected-score progression and half-score threshold locations.",
      "pathway_map mfrm_plot_data and expected_ogive tables",
      "The display is not labeled as FACETS graph-window ICC/IRF output."
    ),
    row(
      "graph_menu",
      "Cumulative probability curves",
      "https://www.winsteps.com/facetman64/cumulativeprobabilities.htm",
      "category_curves_report(); plot(category_curves_report(...), type = \"cumulative\")",
      "implemented",
      "Inspect cumulative category curves and Rasch-Thurstone-style 0.5 boundaries.",
      "plot_data(category_curves_report(...), type = \"cumulative\")",
      "R-native cumulative curve data replace FACETS graph-window interaction."
    ),
    row(
      "graph_menu",
      "Test information function",
      "https://www.winsteps.com/facetman64/testinformationfunction.htm",
      "compute_information(); plot_information(type = \"tif\"); plot_information(type = \"sem\")",
      "implemented",
      "Inspect where the fitted design gives stronger or weaker measurement information.",
      "mfrm_plot_data from plot_information(..., draw = FALSE)",
      "mfrmr uses a declared design-weighted information route; FACETS notes that many-facet test information has no unique universal definition."
    ),
    row(
      "graph_menu",
      "Category information function",
      "https://www.winsteps.com/facetman64/categoryinformationfunction.htm",
      "category_curves_report(); plot(..., type = \"category_information\"); compute_information(); plot_information(type = \"iif\")",
      "implemented",
      "Inspect category-specific information contributions and facet/level information curves.",
      "category_information tables plus plot_information() payloads",
      "R-native plot data replace FACETS graph-window interaction."
    ),
    row(
      "graph_menu",
      "Conditional probability curves",
      "https://www.winsteps.com/facetman64/conditionalprobabilitycurves.htm",
      "category_curves_report()",
      "partial",
      "Inspect adjacent-category probability structure when the adjacent-category form matters.",
      "conditional_probabilities and conditional_crossings in category_curves_report() payloads",
      "FACETS conditional-probability graph-window semantics and interaction are not mirrored exactly."
    )
  ))

  out$FACETSExpectation <- ifelse(
    out$Scope == "output_table",
    "FACETS line-printer or output-table visual surface",
    ifelse(
      out$Scope == "graph_menu",
      "FACETS Graphs-menu interactive graph",
      ifelse(
        out$Scope == "output_file",
        "FACETS output file for external graphing",
        "FACETS R/Web or external plotting menu"
      )
    )
  )
  out$FirstMfrmrRoute <- vapply(strsplit(out$mfrmrRoute, ";", fixed = TRUE),
                                function(x) trimws(x[1]), character(1))
  out$FirstMfrmrRoute[out$mfrmrRoute == "none"] <- "none"
  out$EditableDataRoute <- out$PlotDataRoute
  out$EditableDataRoute[out$PlotDataRoute == "none"] <- "not_available"
  has_plot_payload <- out$Status != "not_targeted" &
    grepl("mfrm_plot_data|plot_data|tables|payload|graphfile|node/edge",
          out$PlotDataRoute,
          ignore.case = TRUE)
  out$GgplotRoute <- ifelse(
    has_plot_payload,
    "Use as_ggplot() when the listed route returns an mfrm_plot_data payload; otherwise build from plot_data() tables.",
    "not_available"
  )
  out$ReportUse <- paste0(
    out$ReaderUse,
    " Report as a diagnostic or migration figure, not as standalone validity evidence."
  )
  out$MigrationNote <- ifelse(
    out$Status == "implemented",
    "Start with FirstMfrmrRoute; use EditableDataRoute when the figure must be customized or exported.",
    ifelse(
      out$Status == "partial",
      "Start with FirstMfrmrRoute, then state the missing FACETS UI, file, or line-printer behavior in the caption or handoff note.",
      "No direct mfrmr visual route; keep this as a FACETS-only UI expectation or use external tooling."
    )
  )
  out$ClaimBoundary <- out$Boundary

  row.names(out) <- NULL
  if (identical(scope, "all")) {
    return(out)
  }
  if (scope %in% c("implemented", "partial", "not_targeted")) {
    return(out[out$Status == scope, , drop = FALSE])
  }
  out[out$Scope == scope, , drop = FALSE]
}
