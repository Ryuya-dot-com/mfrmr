# Generate lightweight output tables used by CRAN-safe vignettes.

mfrmr_generate_vignette_artifacts <- function(pkg_dir = ".",
                                             output_dir = NULL) {
  pkg_dir <- normalizePath(pkg_dir, winslash = "/", mustWork = TRUE)
  if (is.null(output_dir)) {
    output_dir <- file.path(pkg_dir, "inst", "extdata", "vignette-artifacts")
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  if (file.exists(file.path(pkg_dir, "DESCRIPTION")) &&
      requireNamespace("pkgload", quietly = TRUE)) {
    pkgload::load_all(pkg_dir, quiet = TRUE)
  } else {
    requireNamespace("mfrmr", quietly = TRUE)
  }

  write_artifact <- function(name, x, source) {
    path <- file.path(output_dir, name)
    x <- as.data.frame(x, stringsAsFactors = FALSE)
    write.csv(x, path, row.names = FALSE, na = "")
    data.frame(
      Artifact = name,
      Rows = nrow(x),
      Columns = ncol(x),
      Source = source,
      stringsAsFactors = FALSE
    )
  }

  toy <- mfrmr::load_mfrmr_data("example_core")
  fit_toy <- suppressWarnings(mfrmr::fit_mfrm(
    data = toy,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "JML",
    model = "RSM",
    maxit = 30
  ))
  diag_toy <- suppressWarnings(mfrmr::diagnose_mfrm(
    fit_toy,
    residual_pca = "none"
  ))
  res_toy <- mfrmr::mfrm_results(fit_toy)
  report_toy <- mfrmr::mfrm_report(res_toy, style = "qc")

  export_dir <- file.path(tempdir(), "mfrmr-workflow-export")
  export_toy <- mfrmr::export_mfrm_results(
    res_toy,
    output_dir = export_dir,
    include = c("default", "report"),
    overwrite = TRUE
  )
  export_files <- utils::head(export_toy$written_files)
  if ("Path" %in% names(export_files)) {
    export_files$Path <- basename(export_files$Path)
  }

  t4_toy <- mfrmr::unexpected_response_table(
    fit_toy,
    diagnostics = diag_toy,
    abs_z_min = 1.5,
    prob_max = 0.4,
    top_n = 10
  )
  t12_toy <- mfrmr::fair_average_table(fit_toy, diagnostics = diag_toy)
  t13_toy <- mfrmr::bias_interaction_report(
    mfrmr::estimate_bias(
      fit_toy,
      diag_toy,
      facet_a = "Rater",
      facet_b = "Criterion",
      max_iter = 2
    ),
    top_n = 10
  )
  summary_classes <- data.frame(
    Object = c("unexpected_response_table", "fair_average_table", "bias_interaction_report"),
    SummaryClass = c(
      paste(class(summary(t4_toy)), collapse = ", "),
      paste(class(summary(t12_toy)), collapse = ", "),
      paste(class(summary(t13_toy)), collapse = ", ")
    ),
    stringsAsFactors = FALSE
  )
  plot_components <- data.frame(
    Object = c("unexpected_response_table", "fair_average_table", "bias_interaction_report"),
    Components = c(
      paste(names(plot(t4_toy, draw = FALSE)), collapse = ", "),
      paste(names(plot(t12_toy, draw = FALSE)), collapse = ", "),
      paste(names(plot(t13_toy, draw = FALSE)), collapse = ", ")
    ),
    stringsAsFactors = FALSE
  )
  chk_toy <- mfrmr::reporting_checklist(fit_toy, diagnostics = diag_toy)
  visual_checklist <- subset(
    chk_toy$checklist,
    Section == "Visual Displays",
    c("Item", "DraftReady", "NextAction")
  )

  manifest <- rbind(
    write_artifact("workflow_fit_overview.csv", summary(fit_toy)$overview, "summary(fit_toy)$overview"),
    write_artifact("workflow_diagnostic_overview.csv", summary(diag_toy)$overview, "summary(diag_toy)$overview"),
    write_artifact("workflow_plot_components.csv", data.frame(Component = names(plot(fit_toy, draw = FALSE))), "names(plot(fit_toy, draw = FALSE))"),
    write_artifact("workflow_next_actions.csv", summary(res_toy)$next_actions, "summary(res_toy)$next_actions"),
    write_artifact("workflow_report_overview.csv", summary(report_toy)$overview, "summary(report_toy)$overview"),
    write_artifact("workflow_export_files.csv", export_files, "head(export_toy$written_files)"),
    write_artifact("workflow_summary_classes.csv", summary_classes, "class(summary(...))"),
    write_artifact("workflow_plot_object_components.csv", plot_components, "names(plot(..., draw = FALSE))"),
    write_artifact("workflow_visual_checklist.csv", visual_checklist, "reporting_checklist(...), Visual Displays")
  )
  manifest$GeneratedWith <- as.character(utils::packageVersion("mfrmr"))
  write.csv(
    manifest,
    file.path(output_dir, "manifest.csv"),
    row.names = FALSE,
    na = ""
  )
  invisible(manifest)
}
