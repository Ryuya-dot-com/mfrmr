# 0.2.2 release-scope review
#
# Lightweight cross-document review for the 0.2.2 release scope. This
# helper verifies that bounded-GPCM, DIF/DFF, APA reporting, ETS display, and
# release-evidence claims remain synchronized without rerunning simulations.

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

mfrmr_rc_read_lines <- function(path) {
  if (!file.exists(path)) {
    return(character(0))
  }
  readLines(path, warn = FALSE, encoding = "UTF-8")
}

mfrmr_rc_text <- function(path) {
  paste(mfrmr_rc_read_lines(path), collapse = "\n")
}

mfrmr_rc_flat <- function(x) {
  gsub("\\s+", " ", x)
}

mfrmr_rc_has <- function(text, pattern) {
  grepl(pattern, text, fixed = TRUE)
}

mfrmr_rc_has_all <- function(text, patterns) {
  hits <- vapply(patterns, mfrmr_rc_has, logical(1), text = text)
  all(hits)
}

mfrmr_rc_missing <- function(text, patterns) {
  patterns[!vapply(patterns, mfrmr_rc_has, logical(1), text = text)]
}

mfrmr_rc_extract <- function(text, pattern, default = NA_character_) {
  hit <- regexec(pattern, text)
  parsed <- regmatches(text, hit)[[1]]
  if (length(parsed) >= 2L) {
    parsed[2]
  } else {
    default
  }
}

mfrmr_rc_public_doc_files <- function(pkg_dir) {
  list_files <- function(path, pattern) {
    if (!dir.exists(path)) {
      return(character(0))
    }
    list.files(path, pattern = pattern, recursive = TRUE, full.names = TRUE)
  }
  c(
    file.path(pkg_dir, "README.md"),
    file.path(pkg_dir, "NEWS.md"),
    list_files(file.path(pkg_dir, "vignettes"), "\\.Rmd$"),
    list_files(file.path(pkg_dir, "man"), "\\.Rd$")
  )
}

mfrmr_rc_check_row <- function(area, check, passed, detail) {
  data.frame(
    Area = area,
    Check = check,
    Passed = isTRUE(passed),
    Detail = as.character(detail %||% ""),
    stringsAsFactors = FALSE
  )
}

mfrmr_review_release_scope <- function(pkg_dir = ".") {
  pkg_dir <- normalizePath(pkg_dir, winslash = "/", mustWork = FALSE)
  validation_dir <- file.path(pkg_dir, "inst", "validation")
  reference_dir <- file.path(pkg_dir, "inst", "references")
  paths <- list(
    readme = file.path(pkg_dir, "README.md"),
    news = file.path(pkg_dir, "NEWS.md"),
    cran_comments = file.path(pkg_dir, "cran-comments.md"),
    gpcm_vignette = file.path(pkg_dir, "vignettes", "mfrmr-gpcm-scope.Rmd"),
    visual_vignette = file.path(pkg_dir, "vignettes", "mfrmr-visual-diagnostics.Rmd"),
    gpcm_help = file.path(pkg_dir, "R", "help_gpcm_scope.R"),
    visual_help = file.path(pkg_dir, "R", "help_visual_diagnostics.R"),
    facets_coverage_source = file.path(pkg_dir, "R", "help_facets_coverage.R"),
    reporting_checklist_source = file.path(pkg_dir, "R", "api-reporting-checklist.R"),
    output_guide_source = file.path(pkg_dir, "R", "help_reports_and_tables.R"),
    plotting_extras = file.path(pkg_dir, "R", "api-plotting-extras.R"),
    dif_advanced = file.path(pkg_dir, "R", "api-advanced.R"),
    dif_reports = file.path(pkg_dir, "R", "api-reports.R"),
    facets_visual_man = file.path(pkg_dir, "man", "facets_visual_contract.Rd"),
    minimum_report_man = file.path(pkg_dir, "man", "mfrmr_minimum_report_checklist.Rd"),
    output_guide_man = file.path(pkg_dir, "man", "mfrmr_output_guide.Rd"),
    plot_dif_summary_man = file.path(pkg_dir, "man", "plot_dif_summary.Rd"),
    dif_report_man = file.path(pkg_dir, "man", "dif_report.Rd"),
    gpcm_roadmap = file.path(validation_dir, "gpcm-post-0.2.2-roadmap.md"),
    evidence_map = file.path(validation_dir, "release-evidence-map-0.2.2.md"),
    evidence_checklist = file.path(validation_dir, "release-evidence-checklist-0.2.2.csv"),
    gpcm_score_side_evidence = file.path(validation_dir, "gpcm-score-side-simulation-0.2.2.md"),
    gpcm_score_side_checks = file.path(validation_dir, "gpcm-score-side-sim-checks-0.2.2.csv"),
    gpcm_score_side_external_helper = file.path(validation_dir, "gpcm-score-side-external-comparison-0.2.2.R"),
    gpcm_score_side_external_evidence = file.path(validation_dir, "gpcm-score-side-external-comparison-0.2.2.md"),
    gpcm_score_side_external_results = file.path(validation_dir, "gpcm-score-side-external-comparison-0.2.2-results.csv"),
    gpcm_score_side_external_checks = file.path(validation_dir, "gpcm-score-side-external-comparison-0.2.2-checks.csv"),
    dif_apa_evidence = file.path(validation_dir, "dif-apa-reporting-0.2.2.md"),
    dif_dff_evidence = file.path(validation_dir, "dif-dff-simulation-matrix-0.2.2.md"),
    dif_apa_note = file.path(reference_dir, "dif-apa-reporting-0.2.2.md"),
    mh_dif_note = file.path(reference_dir, "mh-dif-r-package-alignment.md")
  )
  rel_path <- function(path) {
    sub(paste0("^", gsub("([\\^$.|?*+(){}\\[\\]\\\\])", "\\\\\\1", pkg_dir), "/?"),
        "",
        path)
  }

  checks <- list()
  add_check <- function(area, check, passed, detail = "") {
    checks[[length(checks) + 1L]] <<- mfrmr_rc_check_row(
      area = area,
      check = check,
      passed = passed,
      detail = detail
    )
    invisible(NULL)
  }

  required_files <- unlist(paths, use.names = TRUE)
  for (nm in names(required_files)) {
    add_check(
      "required_files",
      paste0("file_exists_", nm),
      file.exists(required_files[[nm]]),
      rel_path(required_files[[nm]])
    )
  }

  readme <- mfrmr_rc_text(paths$readme)
  news <- mfrmr_rc_text(paths$news)
  cran_comments <- mfrmr_rc_text(paths$cran_comments)
  gpcm_vignette <- mfrmr_rc_text(paths$gpcm_vignette)
  gpcm_help <- mfrmr_rc_text(paths$gpcm_help)
  gpcm_roadmap <- mfrmr_rc_text(paths$gpcm_roadmap)
  evidence_map <- mfrmr_rc_text(paths$evidence_map)
  gpcm_score_side <- mfrmr_rc_text(paths$gpcm_score_side_evidence)
  gpcm_score_side_external <- mfrmr_rc_text(paths$gpcm_score_side_external_evidence)
  dif_apa <- mfrmr_rc_text(paths$dif_apa_evidence)
  dif_dff <- mfrmr_rc_text(paths$dif_dff_evidence)
  visual_help <- mfrmr_rc_text(paths$visual_help)
  facets_coverage_source <- mfrmr_rc_text(paths$facets_coverage_source)
  reporting_checklist_source <- mfrmr_rc_text(paths$reporting_checklist_source)
  output_guide_source <- mfrmr_rc_text(paths$output_guide_source)
  facets_visual_man <- mfrmr_rc_text(paths$facets_visual_man)
  minimum_report_man <- mfrmr_rc_text(paths$minimum_report_man)
  output_guide_man <- mfrmr_rc_text(paths$output_guide_man)
  plotting_extras <- mfrmr_rc_text(paths$plotting_extras)
  plot_dif_summary_man <- mfrmr_rc_text(paths$plot_dif_summary_man)
  dif_report_man <- mfrmr_rc_text(paths$dif_report_man)
  dif_apa_note <- mfrmr_rc_text(paths$dif_apa_note)
  mh_dif_note <- mfrmr_rc_text(paths$mh_dif_note)

  helper_env <- new.env(parent = globalenv())
  helper_error <- NULL
  helper_source_ok <- tryCatch({
    source(paths$reporting_checklist_source, local = helper_env)
    source(paths$output_guide_source, local = helper_env)
    TRUE
  }, error = function(e) {
    helper_error <<- conditionMessage(e)
    FALSE
  })
  visual_env <- new.env(parent = globalenv())
  visual_error <- NULL
  visual_source_ok <- tryCatch({
    source(paths$facets_coverage_source, local = visual_env)
    TRUE
  }, error = function(e) {
    visual_error <<- conditionMessage(e)
    FALSE
  })

  readme_scope_terms <- c(
    "## 0.2.2 release scope",
    "Core model engine",
    "First-screen workflow",
    "FACETS transition",
    "Reporting and reviewer completeness",
    "Generalizability theory",
    "Bounded `GPCM`",
    "Model-family and estimator scope",
    "DIF/DFF and fairness screening",
    "Anchoring and linking",
    "Visualization",
    "Simulation and design planning",
    "Response-time QC",
    "Release evidence"
  )
  add_check(
    "scope_contract",
    "readme_scope_map_has_all_release_areas",
    mfrmr_rc_has_all(readme, readme_scope_terms),
    paste(mfrmr_rc_missing(readme, readme_scope_terms), collapse = "; ")
  )

  news_scope_terms <- c(
    "## Release scope map",
    "Core engine",
    "First-screen workflow",
    "FACETS transition",
    "Reporting and review",
    "G-theory",
    "Bounded `GPCM`",
    "Model and estimator scope",
    "DIF/DFF fairness screening",
    "Anchoring and linking",
    "Visuals",
    "Simulation and design",
    "Response-time QC",
    "Release evidence"
  )
  add_check(
    "scope_contract",
    "news_scope_map_has_all_release_areas",
    mfrmr_rc_has_all(news, news_scope_terms),
    paste(mfrmr_rc_missing(news, news_scope_terms), collapse = "; ")
  )

  cran_scope_terms <- c(
    "The release is documented in two layers",
    "Core engine",
    "Workflow/reporting",
    "G-theory",
    "Bounded `GPCM`",
    "FACETS transition",
    "DIF/linking/visuals/simulation/RT"
  )
  add_check(
    "scope_contract",
    "cran_comments_scope_map_has_core_release_areas",
    mfrmr_rc_has_all(cran_comments, cran_scope_terms),
    paste(mfrmr_rc_missing(cran_comments, cran_scope_terms), collapse = "; ")
  )

  combined_scope_docs <- paste(readme, news, cran_comments, sep = "\n")
  core_boundary_terms <- c(
    "fit_mfrm()",
    "unidimensional",
    "No multidimensional",
    "Q-matrix",
    "arbitrary covariance",
    "`formulaA`",
    "mixture",
    "response-process"
  )
  add_check(
    "scope_contract",
    "core_engine_boundary_blocks_deferred_model_claims",
    mfrmr_rc_has_all(combined_scope_docs, core_boundary_terms),
    paste(mfrmr_rc_missing(combined_scope_docs, core_boundary_terms),
          collapse = "; ")
  )

  gtheory_terms <- c(
    "mfrm_generalizability()",
    "mfrm_d_study()",
    "check_mfrm_generalizability_design()",
    "compare_mfrm_generalizability()",
    "bootstrap_mfrm_generalizability()",
    "observed-score G-theory",
    "not fitted-logit MFRM"
  )
  add_check(
    "gtheory_scope",
    "public_docs_gtheory_is_independent_observed_score_route",
    mfrmr_rc_has_all(combined_scope_docs, gtheory_terms),
    paste(mfrmr_rc_missing(combined_scope_docs, gtheory_terms), collapse = "; ")
  )

  visual_migration_columns <- c(
    "FACETSExpectation",
    "FirstMfrmrRoute",
    "EditableDataRoute",
    "GgplotRoute",
    "ReportUse",
    "MigrationNote",
    "ClaimBoundary"
  )
  add_check(
    "visual_contract",
    "source_and_help_expose_visual_migration_columns",
    mfrmr_rc_has_all(facets_coverage_source, visual_migration_columns) &&
      mfrmr_rc_has_all(facets_visual_man, visual_migration_columns),
    paste(
      c(
        mfrmr_rc_missing(facets_coverage_source, visual_migration_columns),
        mfrmr_rc_missing(facets_visual_man, visual_migration_columns)
      ),
      collapse = "; "
    )
  )
  add_check(
    "visual_contract",
    "facets_visual_contract_source_can_be_loaded",
    isTRUE(visual_source_ok),
    visual_error %||% "loaded"
  )
  if (isTRUE(visual_source_ok) &&
      exists("facets_visual_contract", envir = visual_env, inherits = FALSE)) {
    visual_contract <- visual_env$facets_visual_contract()
    visual_required_columns <- c(
      "Scope", "FACETSVisualSurface", "FACETSReference", "mfrmrRoute",
      "Status", "ReaderUse", "PlotDataRoute", "Boundary",
      visual_migration_columns
    )
    add_check(
      "visual_contract",
      "facets_visual_contract_has_migration_schema",
      all(visual_required_columns %in% names(visual_contract)),
      paste(setdiff(visual_required_columns, names(visual_contract)),
            collapse = "; ")
    )
    add_check(
      "visual_contract",
      "facets_visual_contract_covers_core_facets_surfaces",
      any(grepl("Table 6.0", visual_contract$FACETSVisualSurface, fixed = TRUE) &
            visual_contract$Status == "implemented" &
            grepl("plot_wright_unified", visual_contract$mfrmrRoute, fixed = TRUE)) &&
        any(grepl("Table 8 scale-structure probability curves",
                  visual_contract$FACETSVisualSurface, fixed = TRUE) &
              visual_contract$Status == "implemented" &
              grepl("category_curves_report", visual_contract$mfrmrRoute, fixed = TRUE)) &&
        any(grepl("DIF/bias Excel plot",
                  visual_contract$FACETSVisualSurface, fixed = TRUE) &
              visual_contract$Status == "partial" &
              grepl("Excel workbook", visual_contract$ClaimBoundary, fixed = TRUE)) &&
        any(grepl("Graph plotting file",
                  visual_contract$FACETSVisualSurface, fixed = TRUE) &
              visual_contract$Status == "implemented" &
              grepl("facets_output_file_bundle", visual_contract$mfrmrRoute, fixed = TRUE)) &&
        any(grepl("clickable Webpage",
                  visual_contract$FACETSVisualSurface, fixed = TRUE) &
              visual_contract$Status == "not_targeted" &
              visual_contract$GgplotRoute == "not_available"),
      paste0("rows=", nrow(visual_contract))
    )
    add_check(
      "visual_contract",
      "facets_visual_contract_routes_editable_plot_data",
      any(visual_contract$FirstMfrmrRoute == "plot(fit, type = \"wright\")" &
            grepl("plot_data", visual_contract$EditableDataRoute, fixed = TRUE)) &&
        any(grepl("Category probability curves",
                  visual_contract$FACETSVisualSurface, fixed = TRUE) &
              grepl("as_ggplot", visual_contract$GgplotRoute, fixed = TRUE)) &&
        any(visual_contract$Status == "partial" &
              grepl("caption", visual_contract$MigrationNote, fixed = TRUE)),
      "visual contract routes to first plot, editable data, ggplot, and caption boundary"
    )
  } else {
    add_check(
      "visual_contract",
      "facets_visual_contract_has_migration_schema",
      FALSE,
      visual_error %||% "facets_visual_contract() unavailable"
    )
    add_check(
      "visual_contract",
      "facets_visual_contract_covers_core_facets_surfaces",
      FALSE,
      visual_error %||% "facets_visual_contract() unavailable"
    )
    add_check(
      "visual_contract",
      "facets_visual_contract_routes_editable_plot_data",
      FALSE,
      visual_error %||% "facets_visual_contract() unavailable"
    )
  }

  add_check(
    "gtheory_scope",
    "source_docs_expose_generalizability_scope",
    mfrmr_rc_has(reporting_checklist_source, '"generalizability"') &&
      mfrmr_rc_has(reporting_checklist_source, "Generalizability and D-study evidence") &&
      mfrmr_rc_has(output_guide_source,
                   "Separate G-theory generalizability from fitted MFRM reliability") &&
      mfrmr_rc_has(minimum_report_man, "generalizability") &&
      mfrmr_rc_has(output_guide_man, "mfrm_generalizability"),
    "source and generated help expose G-theory scope"
  )

  add_check(
    "gtheory_scope",
    "helper_sources_can_be_loaded_for_scope_contract",
    isTRUE(helper_source_ok),
    helper_error %||% "loaded"
  )
  if (isTRUE(helper_source_ok)) {
    minimum_checklist <- helper_env$mfrmr_minimum_report_checklist()
    gt_checklist <- helper_env$mfrmr_minimum_report_checklist("generalizability")
    psychometric_guide <- helper_env$mfrmr_output_guide("psychometric")
    add_check(
      "gtheory_scope",
      "minimum_report_checklist_has_generalizability_scope",
      nrow(gt_checklist) > 0L &&
        all(gt_checklist$Scope == "generalizability") &&
        any(grepl("mfrm_generalizability",
                  gt_checklist$mfrmrRoute,
                  fixed = TRUE)) &&
        any(grepl("fitted-logit",
                  gt_checklist$ReviewerRisk,
                  fixed = TRUE)),
      paste0("rows=", nrow(gt_checklist))
    )
    add_check(
      "gtheory_scope",
      "generalizability_not_only_in_limitations_row",
      any(minimum_checklist$Scope == "generalizability") &&
        !any(minimum_checklist$Scope == "limitations" &
               grepl("mfrm_generalizability",
                     minimum_checklist$mfrmrRoute,
                     fixed = TRUE)),
      "G-theory is a dedicated checklist scope"
    )
    add_check(
      "gtheory_scope",
      "psychometric_guide_routes_to_gstudy_dstudy",
      nrow(psychometric_guide) > 0L &&
        any(grepl("G-theory",
                  psychometric_guide$Question,
                  fixed = TRUE) &
              grepl("mfrm_generalizability",
                    psychometric_guide$MainFunction,
                    fixed = TRUE) &
              grepl("mfrm_d_study",
                    psychometric_guide$MainFunction,
                    fixed = TRUE)),
      paste0("rows=", nrow(psychometric_guide))
    )
  } else {
    add_check(
      "gtheory_scope",
      "minimum_report_checklist_has_generalizability_scope",
      FALSE,
      helper_error %||% "helper source failed"
    )
    add_check(
      "gtheory_scope",
      "generalizability_not_only_in_limitations_row",
      FALSE,
      helper_error %||% "helper source failed"
    )
    add_check(
      "gtheory_scope",
      "psychometric_guide_routes_to_gstudy_dstudy",
      FALSE,
      helper_error %||% "helper source failed"
    )
  }

  bounded_phrase <- "not a complete unrestricted GPCM implementation"
  add_check(
    "bounded_gpcm",
    "readme_names_bounded_not_complete",
    mfrmr_rc_has(mfrmr_rc_flat(readme), bounded_phrase),
    "README bounded-GPCM boundary"
  )
  add_check(
    "bounded_gpcm",
    "vignette_names_bounded_not_complete",
    mfrmr_rc_has(mfrmr_rc_flat(gpcm_vignette), bounded_phrase),
    "GPCM scope vignette boundary"
  )
  add_check(
    "bounded_gpcm",
    "help_names_bounded_not_complete",
    mfrmr_rc_has(mfrmr_rc_flat(gpcm_help), bounded_phrase),
    "help_gpcm_scope boundary"
  )
  add_check(
    "bounded_gpcm",
    "complete_route_exit_criteria_present",
    mfrmr_rc_has(gpcm_roadmap, "What would count as a complete package-native GPCM route?") &&
      mfrmr_rc_has(gpcm_roadmap, "slope_facet != step_facet") &&
      mfrmr_rc_has(mfrmr_rc_flat(gpcm_roadmap), "breaks raw-score sufficiency"),
    "roadmap complete-GPCM exit criteria"
  )
  add_check(
    "bounded_gpcm",
    "readme_explains_raw_score_non_sufficiency",
    mfrmr_rc_has(mfrmr_rc_flat(readme), "raw-score sufficiency does not carry over"),
    "README score-side boundary"
  )

  add_check(
    "score_side",
    "gpcm_score_side_status_ok",
    mfrmr_rc_has(gpcm_score_side, 'GPCMScoreSideSimulationStatus = "ok"') &&
      mfrmr_rc_has(gpcm_score_side, "FailedChecks = 0"),
    "score-side simulation fixed evidence"
  )
  add_check(
    "score_side",
    "gpcm_score_side_ratio_identity_recorded",
    mfrmr_rc_has(gpcm_score_side, "MaxSERatioDiff = 4.441e-16") &&
      mfrmr_rc_has(gpcm_score_side, "se_ratio_identity"),
    "score-side SE-ratio identity"
  )
  if (file.exists(paths$gpcm_score_side_checks)) {
    gpcm_checks <- utils::read.csv(paths$gpcm_score_side_checks,
                                   stringsAsFactors = FALSE,
                                   check.names = FALSE)
    add_check(
      "score_side",
      "gpcm_score_side_checks_csv_passes",
      nrow(gpcm_checks) > 0L &&
        "Passed" %in% names(gpcm_checks) &&
        all(as.logical(gpcm_checks$Passed), na.rm = FALSE),
      paste0("rows=", nrow(gpcm_checks))
    )
  }
  add_check(
    "score_side",
    "gpcm_score_side_external_status_ok",
    mfrmr_rc_has(gpcm_score_side_external,
                 'GPCMScoreSideExternalComparisonStatus = "ok"') &&
      mfrmr_rc_has(gpcm_score_side_external, "FailedChecks = 0"),
    "score-side external comparison fixed evidence"
  )
  add_check(
    "score_side",
    "gpcm_score_side_external_mapping_recorded",
    mfrmr_rc_has(gpcm_score_side_external, "mirt::probtrace()") &&
      mfrmr_rc_has(gpcm_score_side_external,
                   "does not claim full many-facet parameter") &&
      mfrmr_rc_has(gpcm_score_side_external,
                   "not treated as many-facet MFRM comparators") &&
      mfrmr_rc_has(gpcm_score_side_external, "tau_k = b_k") &&
      mfrmr_rc_has(gpcm_score_side_external, "tam.mml.2pl") &&
      mfrmr_rc_has(gpcm_score_side_external, "tau_k = beta + tau.Cat_k") &&
      mfrmr_rc_has(gpcm_score_side_external, "eRm") &&
      mfrmr_rc_has(gpcm_score_side_external,
                   "not treated as a free-slope GPCM score-side comparator") &&
      mfrmr_rc_has(gpcm_score_side_external, "does not validate FACETS"),
    "score-side external package mapping boundary"
  )
  if (file.exists(paths$gpcm_score_side_external_checks)) {
    gpcm_external_checks <- utils::read.csv(paths$gpcm_score_side_external_checks,
                                            stringsAsFactors = FALSE,
                                            check.names = FALSE)
    add_check(
      "score_side",
      "gpcm_score_side_external_checks_csv_passes",
      nrow(gpcm_external_checks) > 0L &&
        "Passed" %in% names(gpcm_external_checks) &&
        all(as.logical(gpcm_external_checks$Passed), na.rm = FALSE),
      paste0("rows=", nrow(gpcm_external_checks))
    )
  }
  if (file.exists(paths$gpcm_score_side_external_results)) {
    gpcm_external_results <- utils::read.csv(paths$gpcm_score_side_external_results,
                                             stringsAsFactors = FALSE,
                                             check.names = FALSE)
    add_check(
      "score_side",
      "gpcm_score_side_external_results_csv_passes",
      nrow(gpcm_external_results) == 32L &&
        all(c("Package", "Item", "Comparison", "Passed") %in%
              names(gpcm_external_results)) &&
        all(as.logical(gpcm_external_results$Passed), na.rm = FALSE),
      paste0("rows=", nrow(gpcm_external_results))
    )
  }

  add_check(
    "dif_dff_reporting",
    "dif_apa_evidence_ok",
    mfrmr_rc_has(dif_apa, 'DIFAPAReportingStatus = "ok"') &&
      mfrmr_rc_has(dif_apa, "FailedChecks = 0"),
    "DIF/DFF APA reporting evidence"
  )
  add_check(
    "dif_dff_reporting",
    "dif_dff_simulation_evidence_ok",
    mfrmr_rc_has(dif_dff, 'DIFDFFSimulationStatus = "ok"') &&
      mfrmr_rc_has(dif_dff, "FailedChecks = 0") &&
      mfrmr_rc_has(dif_dff, "bounded GPCM"),
    "DIF/DFF simulation matrix evidence"
  )
  add_check(
    "dif_dff_reporting",
    "source_notes_keep_routes_separate",
    mfrmr_rc_has(mfrmr_rc_flat(dif_apa_note), "observed-score Mantel-Haenszel") &&
      (mfrmr_rc_has(mfrmr_rc_flat(mh_dif_note), "not a fitted-MFRM route") ||
         mfrmr_rc_has(mfrmr_rc_flat(mh_dif_note),
                      "does not depend on `RSM`, `PCM`, or bounded `GPCM` likelihoods")) &&
      mfrmr_rc_has(mfrmr_rc_flat(dif_apa_note), "not confirmatory operational subgroup decisions"),
    "DIF source-boundary notes"
  )

  ets_boundary_text <- paste(readme, news, visual_help, plotting_extras,
                             plot_dif_summary_man, sep = "\n")
  add_check(
    "visualization",
    "ets_display_boundary_documented",
    mfrmr_rc_has(ets_boundary_text, "ETSDisplayEligible") &&
      mfrmr_rc_has(ets_boundary_text, 'ClassificationSystem == "ETS"'),
    "ETS color/display eligibility boundary"
  )
  add_check(
    "visualization",
    "plot_payload_contract_documented",
    mfrmr_rc_has(plotting_extras, "ETSDisplayEligible") &&
      mfrmr_rc_has(plot_dif_summary_man, "ETSDisplayEligible"),
    "plot_dif_summary draw-free payload"
  )

  public_docs <- mfrmr_rc_public_doc_files(pkg_dir)
  public_text <- paste(vapply(public_docs, mfrmr_rc_text, character(1)),
                       collapse = "\n")
  forbidden <- c(
    "bias was detected",
    "measurement bias was detected",
    "fairness was established",
    "invariance was established",
    "operational subgroup decision was made"
  )
  forbidden_hits <- forbidden[vapply(forbidden, function(phrase) {
    mfrmr_rc_has(public_text, phrase)
  }, logical(1))]
  add_check(
    "overclaim_control",
    "public_docs_avoid_positive_overclaim_phrases",
    length(forbidden_hits) == 0L,
    paste(forbidden_hits, collapse = "; ")
  )
  add_check(
    "overclaim_control",
    "dif_report_manuscript_boundary_present",
    mfrmr_rc_has(mfrmr_rc_flat(dif_report_man),
                 "standalone fairness, invariance, or operational subgroup decision"),
    "dif_report help boundary"
  )

  checklist_ok <- FALSE
  checklist_detail <- "missing"
  if (file.exists(paths$evidence_checklist)) {
    checklist <- utils::read.csv(paths$evidence_checklist,
                                 stringsAsFactors = FALSE,
                                 check.names = FALSE)
    required_items <- c(
      "gpcm_score_side_simulation",
      "gpcm_score_side_external_comparison",
      "release_scope_review",
      "dif_apa_reporting_boundary",
      "dif_dff_simulation_matrix",
      "gpcm_dff_screening"
    )
    checklist_ok <- all(required_items %in% checklist$Item)
    checklist_detail <- paste(setdiff(required_items, checklist$Item),
                              collapse = "; ")
  }
  add_check(
    "release_evidence",
    "checklist_covers_0_2_2_scope_gates",
    checklist_ok,
    checklist_detail
  )
  add_check(
    "release_evidence",
    "evidence_map_mentions_all_statuses",
    mfrmr_rc_has(evidence_map, 'DIFAPAReportingStatus =') &&
      mfrmr_rc_has(evidence_map, 'DIFDFFSimulationStatus = "ok"') &&
      mfrmr_rc_has(evidence_map, 'GPCMScoreSideSimulationStatus = "ok"') &&
      mfrmr_rc_has(evidence_map, 'GPCMScoreSideExternalComparisonStatus = "ok"') &&
      mfrmr_rc_has(evidence_map, 'ReleaseScopeReviewStatus = "ok"'),
    "release evidence map status markers"
  )

  checks_df <- do.call(rbind, checks)
  failed <- checks_df[!checks_df$Passed, , drop = FALSE]
  status <- if (nrow(failed) == 0L) "ok" else "concern"
  out <- list(
    status = status,
    checks = checks_df,
    failed_checks = nrow(failed),
    files = data.frame(
      Name = names(required_files),
      Path = unname(vapply(required_files, rel_path, character(1))),
      Exists = file.exists(required_files),
      stringsAsFactors = FALSE
    )
  )
  class(out) <- "mfrmr_release_scope_review"
  out
}

mfrmr_write_release_scope_review <- function(review, out_dir) {
  if (!inherits(review, "mfrmr_release_scope_review")) {
    stop("`review` must be output from mfrmr_review_release_scope().",
         call. = FALSE)
  }
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  checks_path <- file.path(out_dir, "release-scope-review-0.2.2-checks.csv")
  md_path <- file.path(out_dir, "release-scope-review-0.2.2.md")
  utils::write.csv(review$checks, checks_path, row.names = FALSE)
  by_area <- stats::aggregate(
    Passed ~ Area,
    data = review$checks,
    FUN = function(x) paste0(sum(x), "/", length(x))
  )
  names(by_area)[names(by_area) == "Passed"] <- "PassedChecks"
  lines <- c(
    "# Release-scope review (0.2.2)",
    "",
    "This lightweight review checks that the 0.2.2 release-scope claims",
    "remain synchronized across the README, NEWS, CRAN comments, helper output,",
    "generated help, and fixed validation evidence. It covers the comprehensive",
    "scope map, the unidimensional `fit_mfrm()` engine boundary, G-theory as an",
    "observed-score complement, bounded GPCM, DIF/DFF reporting, the FACETS",
    "visual migration contract, ETS visualization boundaries, and",
    "release-evidence status markers. It reads",
    "fixed evidence artifacts and public documentation; it does not rerun Monte",
    "Carlo simulations.",
    "",
    sprintf("- `ReleaseScopeReviewStatus = \"%s\"`;", review$status),
    sprintf("- `Checks = %d`;", nrow(review$checks)),
    sprintf("- `FailedChecks = %d`.", review$failed_checks),
    "",
    "## Area Summary",
    "",
    "```",
    utils::capture.output(print(by_area, row.names = FALSE)),
    "```",
    "",
    "## Failed Checks",
    "",
    if (review$failed_checks == 0L) {
      "No failed checks."
    } else {
      c("```", utils::capture.output(print(
        review$checks[!review$checks$Passed, , drop = FALSE],
        row.names = FALSE
      )), "```")
    },
    "",
    "## Files",
    "",
    "- `release-scope-review-0.2.2-checks.csv`"
  )
  writeLines(lines, md_path, useBytes = TRUE)
  invisible(list(checks = checks_path, markdown = md_path))
}

print.mfrmr_release_scope_review <- function(x, ...) {
  cat("mfrmr release-scope review\n")
  cat("Status:", x$status, "\n")
  cat("Checks:", nrow(x$checks), " Failed:", x$failed_checks, "\n")
  failed <- x$checks[!x$checks$Passed, , drop = FALSE]
  if (nrow(failed) > 0L) {
    cat("\nFailed checks:\n")
    print(failed, row.names = FALSE)
  }
  invisible(x)
}

if (identical(sys.nframe(), 0L)) {
  args <- commandArgs(trailingOnly = TRUE)
  pkg_dir <- if (length(args) >= 1L && nzchar(args[1])) args[1] else "."
  out_dir <- if (length(args) >= 2L && nzchar(args[2])) {
    args[2]
  } else {
    file.path("validation-results", "release-scope-review-0.2.2")
  }
  review <- mfrmr_review_release_scope(pkg_dir = pkg_dir)
  print(review)
  paths <- mfrmr_write_release_scope_review(review, out_dir = out_dir)
  cat("\nWrote:\n")
  print(unlist(paths), quote = FALSE)
  if (!identical(review$status, "ok")) {
    quit(status = 1L)
  }
}
