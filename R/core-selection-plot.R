# Shared data selection for appendix/report plots.
.mfrmr_selection_plot_specs <- data.frame(Type = c("selection_handoff_presets", "selection_tables", "selection_handoff", "selection_handoff_bundles", 
"selection_handoff_roles", "selection_handoff_role_sections", "selection_bundles", "selection_roles", 
"selection_sections"), Field = c("selection_handoff_preset_summary", "selection_table_summary", "selection_handoff_summary", 
"selection_handoff_bundle_summary", "selection_handoff_role_summary", "selection_handoff_role_section_summary", 
"selection_summary", "selection_role_summary", "selection_section_summary"), Label = c("Preset", "Table", 
"AppendixSection", "AppendixSection", "Role", "AppendixSection", "Bundle", "Role", "AppendixSection"), 
    Label2 = c("", "", "", "Bundle", "", "Role", "", "", ""), Value = c("PlotReadyTables", "Rows", "PlotReadyTables", 
    "PlotReadyTables", "PlotReadyTables", "PlotReadyTables", "TablesSelected", "Tables", "Tables"), Colour = c("#f4a261", 
    "#e76f51", "#ff9f1c", "#5c677d", "#9c6644", "#7f5539", "#54a24b", "#b279a2", "#2a9d8f"), BundleTitle = c("Summary bundle handoff presets (%s)", 
    "Summary bundle selection tables (%s)", "Summary bundle selection handoff (%s)", "Summary bundle handoff bundles (%s)", 
    "Summary bundle handoff roles (%s)", "Summary bundle handoff role-sections (%s)", "Summary bundle appendix bundles (%s)", 
    "Summary bundle appendix roles (%s)", "Summary bundle appendix sections (%s)"), BundleSubtitle = c("Preset-level plot-ready appendix handoff for `%s`", 
    "Selected appendix tables for preset `%s`", "Plot-ready appendix handoff by section for preset `%s`", 
    "Plot-ready appendix handoff by section and bundle for preset `%s`", "Plot-ready appendix handoff by role for preset `%s`", 
    "Plot-ready appendix handoff by section and role for preset `%s`", "Appendix tables by source bundle for preset `%s`", 
    "Selected appendix roles for preset `%s`", "Selected appendix sections for preset `%s`"), StructuralSubtitle = c("Plot-ready appendix handoff by preset for `%s`", 
    "Selected appendix tables for preset `%s`", "Plot-ready appendix handoff by section for preset `%s`", 
    "Plot-ready appendix handoff by section and bundle for preset `%s`", "Plot-ready appendix handoff by role for preset `%s`", 
    "Plot-ready appendix handoff by section and role for preset `%s`", "Appendix tables by bundle for preset `%s`", 
    "Selected appendix roles for preset `%s`", "Selected appendix sections for preset `%s`"), ExportTitle = c("Appendix handoff by preset", 
    "Selected appendix tables", "Appendix handoff by section", "Appendix handoff by section and bundle", 
    "Appendix handoff by role", "Appendix handoff by role and section", "Appendix tables by bundle", 
    "Selected appendix roles", "Selected appendix sections"), BundleError = c("`x` does not contain appendix handoff-preset rows for preset `%s`.", 
    "`x` does not contain appendix table-selection rows for preset `%s`.", "`x` does not contain appendix handoff rows for preset `%s`.", 
    "`x` does not contain appendix handoff-bundle rows for preset `%s`.", "`x` does not contain appendix handoff-role rows for preset `%s`.", 
    "`x` does not contain appendix handoff role-section rows for preset `%s`.", "`x` does not contain appendix bundle-selection rows for preset `%s`.", 
    "`x` does not contain appendix role-selection rows for preset `%s`.", "`x` does not contain appendix section-selection rows for preset `%s`."
    ), StructuralError = c("No structural-design appendix handoff-preset summary is available for preset `%s`.", 
    "No structural-design appendix table selection is available for preset `%s`.", "No structural-design appendix handoff summary is available for preset `%s`.", 
    "No structural-design appendix handoff-bundle summary is available for preset `%s`.", "No structural-design appendix handoff-role summary is available for preset `%s`.", 
    "No structural-design appendix handoff role-section summary is available for preset `%s`.", "No structural-design appendix selection summary is available for preset `%s`.", 
    "No structural-design appendix role summary is available for preset `%s`.", "No structural-design appendix section summary is available for preset `%s`."
    ), ExportError = c("No appendix handoff-preset summary is available for plotting.", "No appendix table selection summary is available for plotting.", 
    "No appendix handoff summary is available for plotting.", "No appendix handoff-bundle summary is available for plotting.", 
    "No appendix handoff-role summary is available for plotting.", "No appendix handoff role-section summary is available for plotting.", 
    "No appendix selection summary is available for plotting.", "No appendix role-selection summary is available for plotting.", 
    "No appendix section summary is available for plotting."), stringsAsFactors = FALSE)


resolve_selection_plot_inputs <- function(sx, type, selection_value,
                                           appendix_preset = NULL,
                                           context = c("bundle", "structural", "export")) {
  context <- match.arg(context)
  type <- match.arg(type, .mfrmr_selection_plot_specs$Type)
  spec <- .mfrmr_selection_plot_specs[match(type, .mfrmr_selection_plot_specs$Type), , drop = FALSE]
  if (context == "structural" && type == "selection_tables") {
    tbl <- structural_design_selection_table_summary(sx$selection_catalog, preset = appendix_preset)
  } else {
    tbl <- as.data.frame(do.call("$", list(sx, spec$Field)) %||% data.frame(), stringsAsFactors = FALSE)
    if (context != "export") {
      if (type == "selection_tables") {
        tbl <- summary_table_bundle_filter_selection_tables(tbl, appendix_preset = appendix_preset)
      } else {
        tbl <- tbl[as.character(tbl$Preset %||% "") %in% appendix_preset, , drop = FALSE]
      }
    }
  }
  columns <- c(spec$Label, spec$Label2[nzchar(spec$Label2)], spec$Value)
  if (nrow(tbl) == 0L || !all(columns %in% names(tbl))) {
    error_column <- switch(context, bundle = "BundleError", structural = "StructuralError", export = "ExportError")
    message <- spec[[error_column]]
    if (context != "export") message <- sprintf(message, appendix_preset)
    stop(simpleError(message, call = if (context == "bundle") sys.call(-1L) else NULL))
  }
  labels <- as.character(tbl[[spec$Label]])
  if (nzchar(spec$Label2)) labels <- paste0(labels, " :: ", as.character(tbl[[spec$Label2]]))
  measure <- resolve_selection_plot_measure(tbl, type, selection_value = selection_value)
  title <- if (context == "bundle") sprintf(spec$BundleTitle, appendix_preset) else spec$ExportTitle
  subtitle <- if (context == "bundle") {
    sprintf(spec$BundleSubtitle, appendix_preset)
  } else if (context == "structural") {
    sprintf(spec$StructuralSubtitle, appendix_preset)
  } else NULL
  list(table = tbl, labels = labels, measure = measure, colour = spec$Colour,
    title = title, subtitle = subtitle)
}
