# Self/other speaking assessment network example for 0.2.2.
#
# Run from the package root:
#
#   Rscript inst/validation/self-other-speaking-network-0.2.2.R
#
# The script writes:
#   inst/validation/self-other-speaking-network-0.2.2-summary.csv
#   inst/validation/self-other-speaking-network-0.2.2-checks.csv
#   inst/validation/self-other-speaking-network-0.2.2-templates.csv
#   inst/validation/self-other-speaking-network-0.2.2.md

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

load_package <- function(pkg_dir = ".") {
  if (requireNamespace("pkgload", quietly = TRUE) &&
      file.exists(file.path(pkg_dir, "DESCRIPTION"))) {
    pkgload::load_all(pkg_dir, quiet = TRUE)
  } else {
    library(mfrmr)
  }
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop("This validation example requires igraph.", call. = FALSE)
  }
}

score_from_eta <- function(eta) {
  as.integer(cut(
    eta,
    breaks = c(-Inf, -1.15, -0.35, 0.35, 1.15, Inf),
    labels = 1:5
  ))
}

simulate_self_other_speaking <- function(seed = 20260705,
                                         n_person = 18,
                                         n_teacher = 3,
                                         teachers_per_person = 2,
                                         self_shift = -0.55) {
  set.seed(seed)
  persons <- sprintf("S%02d", seq_len(n_person))
  teachers <- sprintf("T%02d", seq_len(n_teacher))
  tasks <- sprintf("Speech%02d", 1:2)
  criteria <- c("Fluency", "Pronunciation", "Content")

  theta <- stats::setNames(stats::rnorm(n_person, 0, 0.85), persons)
  self_severity <- stats::setNames(
    stats::rnorm(n_person, self_shift, 0.15),
    persons
  )
  teacher_severity <- stats::setNames(
    seq(-0.10, 0.35, length.out = n_teacher),
    teachers
  )
  task_effect <- stats::setNames(c(-0.15, 0.15), tasks)
  criterion_effect <- stats::setNames(c(-0.20, 0.00, 0.20), criteria)

  rows <- vector("list", length(persons))
  for (i in seq_along(persons)) {
    person_id <- persons[i]
    teacher_ids <- teachers[((i - 1L + seq_len(teachers_per_person) - 1L) %%
      length(teachers)) + 1L]
    rows[[i]] <- expand.grid(
      Person = person_id,
      Rater = c(person_id, teacher_ids),
      Task = tasks,
      Criterion = criteria,
      stringsAsFactors = FALSE
    )
  }

  dat <- do.call(rbind, rows)
  dat$AssessorType <- ifelse(dat$Rater == dat$Person, "Self", "Teacher")
  dat$Assessor <- ifelse(dat$AssessorType == "Self", "Self", dat$Rater)

  severity <- ifelse(
    dat$AssessorType == "Self",
    self_severity[dat$Person],
    teacher_severity[dat$Rater]
  )
  eta <- theta[dat$Person] - severity -
    task_effect[dat$Task] - criterion_effect[dat$Criterion] +
    stats::rnorm(nrow(dat), 0, 0.45)
  dat$Score <- score_from_eta(eta)
  dat
}

fit_example <- function(dat, facets) {
  suppressWarnings(
    fit_mfrm(
      dat,
      person = "Person",
      facets = facets,
      score = "Score",
      rating_min = 1,
      rating_max = 5,
      method = "JML",
      maxit = 120,
      min_obs_per_element = 2,
      min_obs_per_category = 1
    )
  )
}

check_row <- function(check, passed, detail) {
  data.frame(
    Check = check,
    Passed = isTRUE(passed),
    Detail = as.character(detail %||% ""),
    stringsAsFactors = FALSE
  )
}

network_plot_metrics <- function(plot_data) {
  as_df <- function(x) {
    as.data.frame(x %||% data.frame(), stringsAsFactors = FALSE)
  }
  finite_columns <- function(tbl, cols) {
    if (nrow(tbl) == 0L || !all(cols %in% names(tbl))) return(FALSE)
    all(vapply(cols, function(col) {
      vals <- suppressWarnings(as.numeric(tbl[[col]]))
      length(vals) == nrow(tbl) && all(is.finite(vals))
    }, logical(1)))
  }
  pdata <- if (inherits(plot_data, "mfrm_plot_data")) plot_data$data else list()
  layout <- as_df(pdata$layout)
  node_plot <- as_df(pdata$node_plot)
  edge_plot <- as_df(pdata$edge_plot)
  data.frame(
    PlotAvailable = inherits(plot_data, "mfrm_plot_data"),
    LayoutRows = nrow(layout),
    NodePlotRows = nrow(node_plot),
    EdgePlotRows = nrow(edge_plot),
    PlotFinite = finite_columns(layout, c("PlotX", "PlotY")) &&
      finite_columns(node_plot, c("PlotX", "PlotY")) &&
      finite_columns(edge_plot, c("PlotX", "PlotY", "PlotXEnd", "PlotYEnd", "EdgeWidth")),
    stringsAsFactors = FALSE
  )
}

extract_summary <- function(dat,
                            literal_fit,
                            mode_fit,
                            assessor_fit,
                            full_net,
                            rater_net,
                            assessor_type_net,
                            rater_review,
                            assessor_network,
                            rater_review_plot,
                            assessor_network_plot) {
  self_nodes <- rater_net$node_metrics[
    rater_net$node_metrics$Facet == "Rater" &
      rater_net$node_metrics$Level %in% unique(dat$Person),
    ,
    drop = FALSE
  ]
  assessor_type_nodes <- assessor_type_net$node_metrics[
    assessor_type_net$node_metrics$Facet == "AssessorType",
    ,
    drop = FALSE
  ]
  self_mode_node <- assessor_network$node_metrics[
    assessor_network$node_metrics$Rater == "Self",
    ,
    drop = FALSE
  ]
  review_plot_metrics <- network_plot_metrics(rater_review_plot)
  assessor_plot_metrics <- network_plot_metrics(assessor_network_plot)

  data.frame(
    Scenario = "self_teacher_speaking",
    Rows = nrow(dat),
    Persons = length(unique(dat$Person)),
    TeacherRaters = length(setdiff(unique(dat$Rater), unique(dat$Person))),
    LiteralRaterLevels = length(unique(dat$Rater)),
    AssessorLevels = length(unique(dat$Assessor)),
    LiteralFitConverged = isTRUE(literal_fit$summary$Converged[1]),
    AssessorTypeFitConverged = isTRUE(mode_fit$summary$Converged[1]),
    AssessorFitConverged = isTRUE(assessor_fit$summary$Converged[1]),
    FullComponents = full_net$summary$Components[1],
    FullArticulationPoints = full_net$summary$ArticulationPoints[1],
    FullBridges = full_net$summary$Bridges[1],
    RaterProjectedComponents = rater_net$summary$Components[1],
    RaterProjectedArticulationPoints = rater_net$summary$ArticulationPoints[1],
    RaterProjectedBridges = rater_net$summary$Bridges[1],
    SelfRaterNodes = nrow(self_nodes),
    SelfRaterDegreeMin = if (nrow(self_nodes) > 0L) min(self_nodes$Degree) else NA_real_,
    SelfRaterDegreeMax = if (nrow(self_nodes) > 0L) max(self_nodes$Degree) else NA_real_,
    AssessorTypeComponents = assessor_type_net$summary$Components[1],
    AssessorTypeArticulationPoints = assessor_type_net$summary$ArticulationPoints[1],
    SelfModeDegree = if ("Self" %in% assessor_type_nodes$Level) {
      assessor_type_nodes$Degree[assessor_type_nodes$Level == "Self"][1]
    } else {
      NA_real_
    },
    TeacherModeDegree = if ("Teacher" %in% assessor_type_nodes$Level) {
      assessor_type_nodes$Degree[assessor_type_nodes$Level == "Teacher"][1]
    } else {
      NA_real_
    },
    AssessorNetworkEdges = assessor_network$summary$Edges[1],
    SelfModeSeverityIndex = if (nrow(self_mode_node) > 0L) {
      self_mode_node$SeverityIndex[1]
    } else {
      NA_real_
    },
    AssumptionCheckRows = nrow(rater_review$assumption_checks),
    ReportTemplateRows = nrow(rater_review$report_templates),
    AvoidRows = sum(nzchar(rater_review$report_templates$Avoid)),
    ReviewNetworkPlotAvailable = review_plot_metrics$PlotAvailable[1],
    ReviewNetworkLayoutRows = review_plot_metrics$LayoutRows[1],
    ReviewNetworkNodePlotRows = review_plot_metrics$NodePlotRows[1],
    ReviewNetworkEdgePlotRows = review_plot_metrics$EdgePlotRows[1],
    ReviewNetworkPlotFinite = review_plot_metrics$PlotFinite[1],
    AssessorNetworkPlotAvailable = assessor_plot_metrics$PlotAvailable[1],
    AssessorNetworkLayoutRows = assessor_plot_metrics$LayoutRows[1],
    AssessorNetworkNodePlotRows = assessor_plot_metrics$NodePlotRows[1],
    AssessorNetworkEdgePlotRows = assessor_plot_metrics$EdgePlotRows[1],
    AssessorNetworkPlotFinite = assessor_plot_metrics$PlotFinite[1],
    stringsAsFactors = FALSE
  )
}

make_markdown <- function(summary_tbl, checks_tbl) {
  status <- if (all(checks_tbl$Passed)) "ok" else "needs_review"
  failed <- checks_tbl[!checks_tbl$Passed, , drop = FALSE]
  lines <- c(
    "# Self/other speaking assessment network example for 0.2.2",
    "",
    "This artifact fixes the recommended interpretation route for a speaking",
    "assessment design in which each learner's self-rater ID is literally the",
    "same as the `Person` ID, while teacher ratings are supplied by external",
    "raters. The example separates three questions:",
    "",
    "- the full fitted observation graph, where Task/Criterion can act as hubs;",
    "- the Person-plus-Rater projection, where literal self-rater leaves and",
    "  bridge dependencies are visible;",
    "- the Assessor/AssessorType route, where the estimand is self-versus-",
    "  teacher mode rather than literal rater identity.",
    "",
    paste0("- Status: ", status),
    paste0("- Checks: ", nrow(checks_tbl)),
    paste0("- Failed checks: ", nrow(failed)),
    "",
    "## Summary",
    "",
    paste0(
      "- Rows/persons/teacher raters: ",
      summary_tbl$Rows[1], " / ", summary_tbl$Persons[1], " / ",
      summary_tbl$TeacherRaters[1]
    ),
    paste0(
      "- Full graph: components=", summary_tbl$FullComponents[1],
      ", articulation_points=", summary_tbl$FullArticulationPoints[1],
      ", bridges=", summary_tbl$FullBridges[1]
    ),
    paste0(
      "- Person-plus-Rater projection: components=",
      summary_tbl$RaterProjectedComponents[1],
      ", articulation_points=", summary_tbl$RaterProjectedArticulationPoints[1],
      ", bridges=", summary_tbl$RaterProjectedBridges[1]
    ),
    paste0(
      "- Literal self-rater nodes: ", summary_tbl$SelfRaterNodes[1],
      ", degree range=", summary_tbl$SelfRaterDegreeMin[1],
      "-", summary_tbl$SelfRaterDegreeMax[1]
    ),
    paste0(
      "- AssessorType mode graph: components=",
      summary_tbl$AssessorTypeComponents[1],
      ", self degree=", summary_tbl$SelfModeDegree[1],
      ", teacher degree=", summary_tbl$TeacherModeDegree[1]
    ),
    paste0(
      "- Collapsed Assessor severity network: edges=",
      summary_tbl$AssessorNetworkEdges[1],
      ", self severity index=", signif(summary_tbl$SelfModeSeverityIndex[1], 4)
    ),
    paste0(
      "- Projected network plot payload: layout=",
      summary_tbl$ReviewNetworkLayoutRows[1],
      ", nodes=", summary_tbl$ReviewNetworkNodePlotRows[1],
      ", edges=", summary_tbl$ReviewNetworkEdgePlotRows[1]
    ),
    paste0(
      "- Collapsed Assessor plot payload: layout=",
      summary_tbl$AssessorNetworkLayoutRows[1],
      ", nodes=", summary_tbl$AssessorNetworkNodePlotRows[1],
      ", edges=", summary_tbl$AssessorNetworkEdgePlotRows[1]
    ),
    "",
    "## Interpretation",
    "",
    "- Use the full graph for broad observation-design connectedness.",
    "- Use `facets = \"Rater\"` when the claim is about literal self-rater",
    "  isolation or teacher bridging.",
    "- Use an `AssessorType` or collapsed `Assessor` facet when the claim is",
    "  about self-versus-teacher mode severity rather than individual rater IDs.",
    "- Use `rater_network_analysis()` on the collapsed Assessor route for",
    "  pairwise score-relationship summaries; keep it separate from the",
    "  co-observation design graph.",
    "- Use draw-free `type = \"network\"` plot payloads for custom figures;",
    "  layout coordinates are graphical positions, not model estimates.",
    "",
    "## Failed checks",
    ""
  )
  if (nrow(failed) == 0L) {
    lines <- c(lines, "None.")
  } else {
    lines <- c(lines, paste0("- ", failed$Check, ": ", failed$Detail))
  }
  lines
}

main <- function(pkg_dir = ".") {
  load_package(pkg_dir)
  out_prefix <- file.path(
    pkg_dir,
    "inst",
    "validation",
    "self-other-speaking-network-0.2.2"
  )

  dat <- simulate_self_other_speaking()
  literal_fit <- fit_example(dat, c("Rater", "Task", "Criterion"))
  literal_diag <- diagnose_mfrm(literal_fit, residual_pca = "none")
  full_net <- mfrm_network_analysis(literal_fit, diagnostics = literal_diag)
  rater_net <- mfrm_network_analysis(
    literal_fit,
    diagnostics = literal_diag,
    facets = "Rater"
  )
  rater_review <- build_mfrm_network_review(
    literal_fit,
    diagnostics = literal_diag,
    facets = "Rater"
  )
  rater_review_plot <- plot(rater_review, type = "network", draw = FALSE)

  mode_fit <- fit_example(dat, c("AssessorType", "Task", "Criterion"))
  mode_diag <- diagnose_mfrm(mode_fit, residual_pca = "none")
  assessor_type_net <- mfrm_network_analysis(
    mode_fit,
    diagnostics = mode_diag,
    facets = "AssessorType"
  )

  assessor_fit <- fit_example(dat, c("Assessor", "Task", "Criterion"))
  assessor_diag <- diagnose_mfrm(assessor_fit, residual_pca = "none")
  assessor_network <- rater_network_analysis(
    assessor_fit,
    diagnostics = assessor_diag,
    rater_facet = "Assessor",
    context_facets = c("Person", "Task", "Criterion"),
    mode = "severity_direction",
    min_pair_n = 1
  )
  assessor_network_plot <- plot(assessor_network, type = "network", draw = FALSE)

  summary_tbl <- extract_summary(
    dat = dat,
    literal_fit = literal_fit,
    mode_fit = mode_fit,
    assessor_fit = assessor_fit,
    full_net = full_net,
    rater_net = rater_net,
    assessor_type_net = assessor_type_net,
    rater_review = rater_review,
    assessor_network = assessor_network,
    rater_review_plot = rater_review_plot,
    assessor_network_plot = assessor_network_plot
  )

  checks_tbl <- rbind(
    check_row(
      "literal_fit_converged",
      summary_tbl$LiteralFitConverged[1],
      paste0("LiteralFitConverged=", summary_tbl$LiteralFitConverged[1])
    ),
    check_row(
      "full_graph_connected_but_hub_masked",
      summary_tbl$FullComponents[1] == 1L &&
        summary_tbl$FullArticulationPoints[1] == 0L &&
        summary_tbl$FullBridges[1] == 0L,
      paste0(
        "components=", summary_tbl$FullComponents[1],
        "; articulation=", summary_tbl$FullArticulationPoints[1],
        "; bridges=", summary_tbl$FullBridges[1]
      )
    ),
    check_row(
      "rater_projection_recovers_self_leaves",
      summary_tbl$RaterProjectedComponents[1] == 1L &&
        summary_tbl$SelfRaterNodes[1] == summary_tbl$Persons[1] &&
        summary_tbl$SelfRaterDegreeMin[1] == 1 &&
        summary_tbl$SelfRaterDegreeMax[1] == 1 &&
        summary_tbl$RaterProjectedBridges[1] >= summary_tbl$Persons[1],
      paste0(
        "self_nodes=", summary_tbl$SelfRaterNodes[1],
        "; degree=", summary_tbl$SelfRaterDegreeMin[1],
        "-", summary_tbl$SelfRaterDegreeMax[1],
        "; bridges=", summary_tbl$RaterProjectedBridges[1]
      )
    ),
    check_row(
      "review_downstream_tables_available",
      summary_tbl$AssumptionCheckRows[1] >= 10L &&
        summary_tbl$ReportTemplateRows[1] >= 5L &&
        summary_tbl$AvoidRows[1] >= 5L,
      paste0(
        "checks=", summary_tbl$AssumptionCheckRows[1],
        "; templates=", summary_tbl$ReportTemplateRows[1],
        "; avoid_rows=", summary_tbl$AvoidRows[1]
      )
    ),
    check_row(
      "design_network_plot_payload_available",
      summary_tbl$ReviewNetworkPlotAvailable[1] &&
        summary_tbl$ReviewNetworkLayoutRows[1] > 0L &&
        summary_tbl$ReviewNetworkNodePlotRows[1] > 0L &&
        summary_tbl$ReviewNetworkEdgePlotRows[1] > 0L &&
        summary_tbl$ReviewNetworkPlotFinite[1],
      paste0(
        "layout=", summary_tbl$ReviewNetworkLayoutRows[1],
        "; node_plot=", summary_tbl$ReviewNetworkNodePlotRows[1],
        "; edge_plot=", summary_tbl$ReviewNetworkEdgePlotRows[1],
        "; finite=", summary_tbl$ReviewNetworkPlotFinite[1]
      )
    ),
    check_row(
      "assessor_type_fit_converged",
      summary_tbl$AssessorTypeFitConverged[1],
      paste0("AssessorTypeFitConverged=", summary_tbl$AssessorTypeFitConverged[1])
    ),
    check_row(
      "assessor_type_mode_graph_is_not_literal_identity_graph",
      summary_tbl$AssessorTypeComponents[1] == 1L &&
        summary_tbl$SelfModeDegree[1] == summary_tbl$Persons[1] &&
        summary_tbl$TeacherModeDegree[1] == summary_tbl$Persons[1],
      paste0(
        "components=", summary_tbl$AssessorTypeComponents[1],
        "; self_degree=", summary_tbl$SelfModeDegree[1],
        "; teacher_degree=", summary_tbl$TeacherModeDegree[1]
      )
    ),
    check_row(
      "collapsed_assessor_network_detects_self_mode_leniency",
      summary_tbl$AssessorFitConverged[1] &&
        summary_tbl$AssessorNetworkEdges[1] > 0L &&
        is.finite(summary_tbl$SelfModeSeverityIndex[1]) &&
        summary_tbl$SelfModeSeverityIndex[1] < 0,
      paste0(
        "edges=", summary_tbl$AssessorNetworkEdges[1],
        "; self_severity_index=",
        signif(summary_tbl$SelfModeSeverityIndex[1], 4)
      )
    ),
    check_row(
      "assessor_network_plot_payload_available",
      summary_tbl$AssessorNetworkPlotAvailable[1] &&
        summary_tbl$AssessorNetworkLayoutRows[1] > 0L &&
        summary_tbl$AssessorNetworkNodePlotRows[1] > 0L &&
        summary_tbl$AssessorNetworkEdgePlotRows[1] > 0L &&
        summary_tbl$AssessorNetworkPlotFinite[1],
      paste0(
        "layout=", summary_tbl$AssessorNetworkLayoutRows[1],
        "; node_plot=", summary_tbl$AssessorNetworkNodePlotRows[1],
        "; edge_plot=", summary_tbl$AssessorNetworkEdgePlotRows[1],
        "; finite=", summary_tbl$AssessorNetworkPlotFinite[1]
      )
    )
  )

  templates_tbl <- rater_review$report_templates
  templates_tbl$ExampleScope <- "Person plus Rater"

  utils::write.csv(summary_tbl, paste0(out_prefix, "-summary.csv"), row.names = FALSE)
  utils::write.csv(checks_tbl, paste0(out_prefix, "-checks.csv"), row.names = FALSE)
  utils::write.csv(templates_tbl, paste0(out_prefix, "-templates.csv"), row.names = FALSE)
  writeLines(make_markdown(summary_tbl, checks_tbl), paste0(out_prefix, ".md"))

  cat("Wrote self/other speaking network artifacts:\n")
  cat("- ", paste0(out_prefix, "-summary.csv"), "\n", sep = "")
  cat("- ", paste0(out_prefix, "-checks.csv"), "\n", sep = "")
  cat("- ", paste0(out_prefix, "-templates.csv"), "\n", sep = "")
  cat("- ", paste0(out_prefix, ".md"), "\n", sep = "")

  invisible(list(summary = summary_tbl, checks = checks_tbl, templates = templates_tbl))
}

if (identical(environment(), globalenv())) {
  main(".")
}
