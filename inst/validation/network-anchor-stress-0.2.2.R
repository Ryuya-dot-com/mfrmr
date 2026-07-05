# Network/anchor stress checks for the 0.2.2 diagnostic-network updates.
#
# Run from the package root:
#
#   Rscript inst/validation/network-anchor-stress-0.2.2.R
#
# The script writes:
#   inst/validation/network-anchor-stress-0.2.2-summary.csv
#   inst/validation/network-anchor-stress-0.2.2-checks.csv
#   inst/validation/network-anchor-stress-0.2.2-rater-modes.csv
#   inst/validation/network-anchor-stress-0.2.2.md

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

stress_load_package <- function(pkg_dir = ".") {
  if (requireNamespace("pkgload", quietly = TRUE) &&
      file.exists(file.path(pkg_dir, "DESCRIPTION"))) {
    pkgload::load_all(pkg_dir, quiet = TRUE)
  } else {
    library(mfrmr)
  }
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop("The network stress checks require igraph.", call. = FALSE)
  }
}

score_from_eta <- function(eta) {
  as.integer(cut(
    eta,
    breaks = c(-Inf, -1.15, -0.35, 0.35, 1.15, Inf),
    labels = 1:5
  ))
}

simulate_self_teacher <- function(seed,
                                  n_person = 24,
                                  n_teacher = 4,
                                  teachers_per_person = 2,
                                  collapse_self = FALSE,
                                  self_shift = -0.55) {
  set.seed(seed)
  persons <- sprintf("P%02d", seq_len(n_person))
  teachers <- sprintf("T%02d", seq_len(n_teacher))
  tasks <- sprintf("Task%02d", 1:2)
  criteria <- sprintf("C%02d", 1:3)
  theta <- stats::setNames(stats::rnorm(n_person, 0, 0.85), persons)
  teacher_severity <- stats::setNames(seq(-0.15, 0.35, length.out = n_teacher),
                                      teachers)
  self_severity <- stats::setNames(stats::rnorm(n_person, self_shift, 0.20),
                                   persons)
  task_effect <- stats::setNames(c(-0.20, 0.20), tasks)
  criterion_effect <- stats::setNames(c(-0.25, 0.00, 0.25), criteria)

  rows <- vector("list", length(persons))
  for (i in seq_along(persons)) {
    person_id <- persons[i]
    if (teachers_per_person > 0L) {
      assigned <- teachers[((i - 1L + seq_len(teachers_per_person) - 1L) %%
                              length(teachers)) + 1L]
    } else {
      assigned <- character(0)
    }
    rows[[i]] <- expand.grid(
      Person = person_id,
      Rater = c(person_id, assigned),
      Task = tasks,
      Criterion = criteria,
      stringsAsFactors = FALSE
    )
  }
  dat <- do.call(rbind, rows)
  dat$Role <- ifelse(dat$Rater == dat$Person, "Self", "Teacher")
  dat$Assessor <- if (isTRUE(collapse_self)) {
    ifelse(dat$Role == "Self", "Self", dat$Rater)
  } else {
    dat$Rater
  }
  severity <- ifelse(dat$Role == "Self",
                     self_severity[dat$Person],
                     teacher_severity[dat$Rater])
  eta <- theta[dat$Person] - severity -
    task_effect[dat$Task] - criterion_effect[dat$Criterion] +
    stats::rnorm(nrow(dat), 0, 0.45)
  dat$Score <- score_from_eta(eta)
  dat
}

simulate_speaking_peer_teacher <- function(seed,
                                           n_person = 24,
                                           n_teacher = 2,
                                           teachers_per_person = 2,
                                           peers_per_person = 2,
                                           self_shift = -0.55,
                                           peer_shift = 0.05) {
  set.seed(seed)
  persons <- sprintf("P%02d", seq_len(n_person))
  teachers <- sprintf("T%02d", seq_len(n_teacher))
  tasks <- sprintf("Speech%02d", 1:2)
  criteria <- c("Fluency", "Pronunciation", "Content")
  theta <- stats::setNames(stats::rnorm(n_person, 0, 0.85), persons)
  self_severity <- stats::setNames(stats::rnorm(n_person, self_shift, 0.20),
                                   persons)
  peer_severity <- stats::setNames(stats::rnorm(n_person, peer_shift, 0.18),
                                   persons)
  teacher_severity <- stats::setNames(seq(-0.20, 0.30, length.out = n_teacher),
                                      teachers)
  task_effect <- stats::setNames(c(-0.15, 0.15), tasks)
  criterion_effect <- stats::setNames(c(-0.20, 0.05, 0.20), criteria)

  make_rows <- function(person_id, raters, role) {
    if (length(raters) == 0L) {
      return(NULL)
    }
    out <- expand.grid(
      Person = person_id,
      Rater = raters,
      Task = tasks,
      Criterion = criteria,
      stringsAsFactors = FALSE
    )
    out$Role <- role
    out
  }

  rows <- vector("list", length(persons) * 3L)
  pos <- 1L
  for (i in seq_along(persons)) {
    person_id <- persons[i]
    peer_ids <- persons[((i - 1L + seq_len(peers_per_person)) %%
                           length(persons)) + 1L]
    teacher_ids <- teachers[((i - 1L + seq_len(teachers_per_person) - 1L) %%
                               length(teachers)) + 1L]
    rows[[pos]] <- make_rows(person_id, person_id, "Self")
    pos <- pos + 1L
    rows[[pos]] <- make_rows(person_id, peer_ids, "Peer")
    pos <- pos + 1L
    rows[[pos]] <- make_rows(person_id, teacher_ids, "Teacher")
    pos <- pos + 1L
  }
  dat <- do.call(rbind, rows)
  dat$Assessor <- ifelse(dat$Role == "Self", "Self", dat$Rater)
  dat$RoleSpecificRater <- ifelse(
    dat$Role == "Self",
    "Self",
    paste(dat$Role, dat$Rater, sep = "_")
  )

  severity <- numeric(nrow(dat))
  severity[dat$Role == "Self"] <- self_severity[dat$Person[dat$Role == "Self"]]
  severity[dat$Role == "Peer"] <- peer_severity[dat$Rater[dat$Role == "Peer"]]
  severity[dat$Role == "Teacher"] <- teacher_severity[dat$Rater[dat$Role == "Teacher"]]
  eta <- theta[dat$Person] - severity -
    task_effect[dat$Task] - criterion_effect[dat$Criterion] +
    stats::rnorm(nrow(dat), 0, 0.45)
  dat$Score <- score_from_eta(eta)
  dat
}

simulate_teacher_panel_gap <- function(seed,
                                       n_person = 24,
                                       n_teacher = 4) {
  set.seed(seed)
  persons <- sprintf("P%02d", seq_len(n_person))
  teachers <- sprintf("T%02d", seq_len(n_teacher))
  tasks <- sprintf("Task%02d", 1:2)
  criteria <- sprintf("C%02d", 1:3)
  theta <- stats::setNames(stats::rnorm(n_person, 0, 0.85), persons)
  teacher_severity <- stats::setNames(seq(-0.25, 0.35, length.out = n_teacher),
                                      teachers)
  task_effect <- stats::setNames(c(-0.20, 0.20), tasks)
  criterion_effect <- stats::setNames(c(-0.25, 0.00, 0.25), criteria)
  rows <- vector("list", length(persons))
  for (i in seq_along(persons)) {
    panel <- if (i <= n_person / 2) teachers[1:2] else teachers[3:4]
    rows[[i]] <- expand.grid(
      Person = persons[i],
      Rater = panel,
      Task = tasks,
      Criterion = criteria,
      stringsAsFactors = FALSE
    )
  }
  dat <- do.call(rbind, rows)
  eta <- theta[dat$Person] - teacher_severity[dat$Rater] -
    task_effect[dat$Task] - criterion_effect[dat$Criterion] +
    stats::rnorm(nrow(dat), 0, 0.45)
  dat$Score <- score_from_eta(eta)
  dat
}

fit_stress <- function(dat, rater_col, model_facets = NULL) {
  if (is.null(model_facets)) {
    model_facets <- c(rater_col, "Task", "Criterion")
  }
  model_facets <- unique(as.character(model_facets))
  suppressWarnings(
    fit_mfrm(
      dat,
      person = "Person",
      facets = model_facets,
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
    LayoutFinite = finite_columns(layout, c("PlotX", "PlotY")),
    NodePlotFinite = finite_columns(node_plot, c("PlotX", "PlotY")),
    EdgePlotFinite = finite_columns(
      edge_plot,
      c("PlotX", "PlotY", "PlotXEnd", "PlotYEnd", "EdgeWidth")
    ),
    stringsAsFactors = FALSE
  )
}

rater_network_downstream_counts <- function(rn) {
  as_df <- function(x) {
    as.data.frame(x %||% data.frame(), stringsAsFactors = FALSE)
  }
  nonempty_count <- function(tbl, col) {
    if (nrow(tbl) == 0L || !col %in% names(tbl)) {
      return(0L)
    }
    sum(nzchar(trimws(as.character(tbl[[col]]))), na.rm = TRUE)
  }
  collapse_col <- function(tbl, col) {
    if (nrow(tbl) == 0L || !col %in% names(tbl)) {
      return(NA_character_)
    }
    vals <- unique(as.character(tbl[[col]]))
    vals <- vals[!is.na(vals) & nzchar(vals)]
    if (length(vals) == 0L) NA_character_ else paste(vals, collapse = ";")
  }
  assumption_checks <- as_df(rn$assumption_checks)
  visualization_map <- as_df(rn$visualization_map)
  report_templates <- as_df(rn$report_templates)
  data.frame(
    AssumptionCheckRows = nrow(assumption_checks),
    VisualizationRows = nrow(visualization_map),
    ReportTemplateRows = nrow(report_templates),
    AvoidRows = nonempty_count(report_templates, "Avoid"),
    VisualizationRoutes = collapse_col(visualization_map, "Route"),
    TemplateIds = collapse_col(report_templates, "TemplateId"),
    stringsAsFactors = FALSE
  )
}

network_row <- function(name, seed, dat, rater_col,
                        self_levels = character(),
                        model_facets = NULL,
                        projection_facets = rater_col,
                        context_facets = c("Person", "Task", "Criterion"),
                        expect = list()) {
  if (is.null(model_facets)) {
    model_facets <- c(rater_col, "Task", "Criterion")
  }
  model_facets <- unique(as.character(model_facets))
  projection_facets <- as.character(projection_facets)
  context_facets <- as.character(context_facets)

  fit <- fit_stress(dat, rater_col, model_facets = model_facets)
  diag <- diagnose_mfrm(fit, residual_pca = "none")
  full <- mfrm_network_analysis(fit, diagnostics = diag)
  projected <- mfrm_network_analysis(fit, diagnostics = diag,
                                     facets = projection_facets)
  review <- build_mfrm_network_review(
    fit,
    diagnostics = diag,
    facets = projection_facets
  )
  review_plot <- plot(review, type = "centrality", draw = FALSE)
  review_network_plot <- plot(review, type = "network", draw = FALSE)
  review_network_metrics <- network_plot_metrics(review_network_plot)
  rater_modes <- lapply(c("severity_direction", "agreement", "disagreement"),
                        function(mode) {
    rater_network_analysis(
      fit,
      diagnostics = diag,
      rater_facet = rater_col,
      context_facets = context_facets,
      mode = mode,
      min_pair_n = 1
    )
  })
  names(rater_modes) <- c("severity_direction", "agreement", "disagreement")

  node_tbl <- as.data.frame(projected$node_metrics, stringsAsFactors = FALSE)
  self_nodes <- node_tbl[
    node_tbl$Facet == rater_col & node_tbl$Level %in% self_levels,
    ,
    drop = FALSE
  ]
  self_severity_index <- NA_real_
  if ("severity_direction" %in% names(rater_modes) && length(self_levels) == 1L) {
    sev_nodes <- as.data.frame(rater_modes$severity_direction$node_metrics,
                               stringsAsFactors = FALSE)
    self_row <- sev_nodes[sev_nodes$Rater == self_levels[1], , drop = FALSE]
    if (nrow(self_row) > 0L) {
      self_severity_index <- suppressWarnings(as.numeric(self_row$SeverityIndex[1]))
    }
  }

  mode_summary <- function(mode) {
    rn <- rater_modes[[mode]]
    cbind(data.frame(
      Scenario = name,
      Seed = seed,
      Mode = mode,
      PairRows = rn$summary$PairRows[1],
      EligiblePairRows = rn$summary$EligiblePairRows[1],
      ZeroOverlapPairs = rn$summary$ZeroOverlapPairs[1],
      Edges = rn$summary$Edges[1],
      Components = rn$summary$Components[1],
      stringsAsFactors = FALSE
    ), rater_network_downstream_counts(rn))
  }

  summary <- data.frame(
    Scenario = name,
    Seed = seed,
    Rows = nrow(dat),
    Persons = length(unique(dat$Person)),
    RaterFacet = rater_col,
    RaterLevels = length(unique(dat[[rater_col]])),
    ModelFacets = paste(model_facets, collapse = ";"),
    ProjectionFacets = paste(projection_facets, collapse = ";"),
    FitConverged = isTRUE(fit$summary$Converged[1]),
    FullComponents = full$summary$Components[1],
    FullArticulationPoints = full$summary$ArticulationPoints[1],
    FullBridges = full$summary$Bridges[1],
    FullConnected = isTRUE(full$summary$Connected[1]),
    ProjectedComponents = projected$summary$Components[1],
    ProjectedArticulationPoints = projected$summary$ArticulationPoints[1],
    ProjectedBridges = projected$summary$Bridges[1],
    ProjectedConnected = isTRUE(projected$summary$Connected[1]),
    SelfNodeCount = nrow(self_nodes),
    SelfDegreeMin = if (nrow(self_nodes) > 0L) min(self_nodes$Degree) else NA_real_,
    SelfDegreeMax = if (nrow(self_nodes) > 0L) max(self_nodes$Degree) else NA_real_,
    SelfSeverityIndex = self_severity_index,
    AssumptionCheckRows = nrow(review$assumption_checks %||% data.frame()),
    VisualizationRows = nrow(review$visualization_map %||% data.frame()),
    ReportTemplateRows = nrow(review$report_templates %||% data.frame()),
    ReviewPlotAvailable = inherits(review_plot, "mfrm_plot_data"),
    ReviewNetworkPlotAvailable = review_network_metrics$PlotAvailable[1],
    NetworkLayoutRows = review_network_metrics$LayoutRows[1],
    NetworkNodePlotRows = review_network_metrics$NodePlotRows[1],
    NetworkEdgePlotRows = review_network_metrics$EdgePlotRows[1],
    NetworkLayoutFinite = review_network_metrics$LayoutFinite[1],
    NetworkNodePlotFinite = review_network_metrics$NodePlotFinite[1],
    NetworkEdgePlotFinite = review_network_metrics$EdgePlotFinite[1],
    stringsAsFactors = FALSE
  )
  list(
    summary = summary,
    rater_modes = do.call(rbind, lapply(names(rater_modes), mode_summary)),
    objects = list(fit = fit, diagnostics = diag, full = full,
                   projected = projected, review = review,
                   review_plot = review_plot,
                   review_network_plot = review_network_plot,
                   rater_modes = rater_modes),
    expect = expect
  )
}

stress_check <- function(scenario, check, passed, detail = "") {
  data.frame(
    Scenario = scenario,
    Check = check,
    Passed = isTRUE(passed),
    Detail = as.character(detail %||% ""),
    stringsAsFactors = FALSE
  )
}

anchor_group_only_check <- function() {
  toy <- mfrmr:::sample_mfrm_data(seed = 42)
  group_anchors <- data.frame(
    Facet = c("Rater", "Rater"),
    Level = c("R1", "R2"),
    Group = c("G1", "G1"),
    GroupValue = c(0, 0),
    stringsAsFactors = FALSE
  )
  review <- review_mfrm_anchors(
    data = toy,
    person = "Person",
    facets = c("Rater", "Task", "Criterion"),
    score = "Score",
    group_anchors = group_anchors,
    min_common_anchors = 4,
    min_obs_per_element = 20,
    min_obs_per_category = 8
  )
  rater_row <- review$facet_summary[review$facet_summary$Facet == "Rater",
                                    ,
                                    drop = FALSE]
  has_rec <- any(grepl("common constrained anchor/group-anchor levels",
                       review$recommendations,
                       fixed = TRUE))
  list(
    summary = data.frame(
      Scenario = "group_anchor_only_low_common",
      Seed = 42,
      Rows = nrow(toy),
      Persons = length(unique(toy$Person)),
      RaterFacet = "Rater",
      RaterLevels = length(unique(toy$Rater)),
      ModelFacets = "Rater;Task;Criterion",
      ProjectionFacets = "Rater",
      FitConverged = NA,
      FullComponents = NA_integer_,
      FullArticulationPoints = NA_integer_,
      FullBridges = NA_integer_,
      FullConnected = NA,
      ProjectedComponents = NA_integer_,
      ProjectedArticulationPoints = NA_integer_,
      ProjectedBridges = NA_integer_,
      ProjectedConnected = NA,
      SelfNodeCount = NA_integer_,
      SelfDegreeMin = NA_real_,
      SelfDegreeMax = NA_real_,
      SelfSeverityIndex = NA_real_,
      AssumptionCheckRows = NA_integer_,
      VisualizationRows = NA_integer_,
      ReportTemplateRows = NA_integer_,
      ReviewPlotAvailable = NA,
      ReviewNetworkPlotAvailable = NA,
      NetworkLayoutRows = NA_integer_,
      NetworkNodePlotRows = NA_integer_,
      NetworkEdgePlotRows = NA_integer_,
      NetworkLayoutFinite = NA,
      NetworkNodePlotFinite = NA,
      NetworkEdgePlotFinite = NA,
      stringsAsFactors = FALSE
    ),
    rater_modes = data.frame(),
    checks = rbind(
      stress_check(
        "group_anchor_only_low_common",
        "direct_anchor_count_zero",
        nrow(rater_row) == 1L && identical(as.integer(rater_row$AnchoredLevels[1]), 0L),
        paste0("AnchoredLevels=", rater_row$AnchoredLevels[1])
      ),
      stress_check(
        "group_anchor_only_low_common",
        "group_anchor_recommendation_present",
        has_rec,
        paste(review$recommendations, collapse = " | ")
      )
    )
  )
}

scenario_checks <- function(res) {
  s <- res$summary
  rm <- res$rater_modes
  name <- s$Scenario[1]
  rows <- list(
    stress_check(name, "fit_converged_or_anchor_only",
                 isTRUE(s$FitConverged[1]) || is.na(s$FitConverged[1]),
                 paste0("FitConverged=", s$FitConverged[1])),
    stress_check(name, "full_graph_connected",
                 isTRUE(s$FullConnected[1]) || is.na(s$FullConnected[1]),
                 paste0("FullComponents=", s$FullComponents[1])),
    stress_check(name, "all_rater_modes_returned",
                 nrow(rm) == 3L || nrow(rm) == 0L,
                 paste0("mode_rows=", nrow(rm)))
  )
  if (!is.na(s$FitConverged[1])) {
    rows <- c(rows, list(
      stress_check(name, "downstream_review_tables_available",
                   s$AssumptionCheckRows[1] >= 10L &&
                     s$VisualizationRows[1] >= 5L &&
                     s$ReportTemplateRows[1] >= 5L &&
                     isTRUE(s$ReviewPlotAvailable[1]),
                   paste0(
                     "checks=", s$AssumptionCheckRows[1],
                     "; visuals=", s$VisualizationRows[1],
                     "; templates=", s$ReportTemplateRows[1],
                     "; plot=", s$ReviewPlotAvailable[1]
                   ))
      ,
      stress_check(name, "network_plot_payload_available",
                   isTRUE(s$ReviewNetworkPlotAvailable[1]) &&
                     s$NetworkLayoutRows[1] > 0L &&
                     s$NetworkNodePlotRows[1] > 0L &&
                     s$NetworkEdgePlotRows[1] > 0L &&
                     isTRUE(s$NetworkLayoutFinite[1]) &&
                     isTRUE(s$NetworkNodePlotFinite[1]) &&
                     isTRUE(s$NetworkEdgePlotFinite[1]),
                   paste0(
                     "layout=", s$NetworkLayoutRows[1],
                     "; node_plot=", s$NetworkNodePlotRows[1],
                     "; edge_plot=", s$NetworkEdgePlotRows[1],
                     "; finite=", all(
                       isTRUE(s$NetworkLayoutFinite[1]),
                       isTRUE(s$NetworkNodePlotFinite[1]),
                       isTRUE(s$NetworkEdgePlotFinite[1])
                     )
                   ))
      ,
      stress_check(name, "rater_mode_downstream_tables_available",
                   nrow(rm) == 3L &&
                     all(c("AssumptionCheckRows", "VisualizationRows",
                           "ReportTemplateRows", "AvoidRows") %in% names(rm)) &&
                     all(rm$AssumptionCheckRows >= 6L) &&
                     all(rm$VisualizationRows >= 5L) &&
                     all(rm$ReportTemplateRows >= 5L) &&
                     all(rm$AvoidRows >= 5L),
                   paste0(
                     "checks=", paste(rm$AssumptionCheckRows, collapse = ","),
                     "; visuals=", paste(rm$VisualizationRows, collapse = ","),
                     "; templates=", paste(rm$ReportTemplateRows, collapse = ","),
                     "; avoid=", paste(rm$AvoidRows, collapse = ",")
                   ))
    ))
  }
  if (grepl("^self_only", name)) {
    rows <- c(rows, list(
      stress_check(name, "projected_graph_disconnected",
                   !isTRUE(s$ProjectedConnected[1]) &&
                     s$ProjectedComponents[1] == s$Persons[1],
                   paste0("ProjectedComponents=", s$ProjectedComponents[1])),
      stress_check(name, "all_modes_empty_edges",
                   nrow(rm) == 3L && all(rm$Edges == 0),
                   paste0("Edges=", paste(rm$Edges, collapse = ","))),
      stress_check(name, "all_modes_zero_overlap_only",
                   nrow(rm) == 3L && all(rm$EligiblePairRows == 0) &&
                     all(rm$ZeroOverlapPairs == rm$PairRows),
                   paste0("ZeroOverlap=", paste(rm$ZeroOverlapPairs, collapse = ",")))
    ))
  }
  if (grepl("^mixed_literal", name)) {
    rows <- c(rows, list(
      stress_check(name, "projected_connected_with_self_leaves",
                   isTRUE(s$ProjectedConnected[1]) &&
                     s$SelfNodeCount[1] == s$Persons[1] &&
                     s$SelfDegreeMin[1] == 1 && s$SelfDegreeMax[1] == 1,
                   paste0("self_degree=", s$SelfDegreeMin[1], "-",
                          s$SelfDegreeMax[1])),
      stress_check(name, "zero_overlap_and_edges_coexist",
                   any(rm$ZeroOverlapPairs > 0) && any(rm$Edges > 0),
                   paste0("zero=", paste(rm$ZeroOverlapPairs, collapse = ","),
                          "; edges=", paste(rm$Edges, collapse = ",")))
    ))
  }
  if (grepl("^self_teacher_role_rater_only", name)) {
    rows <- c(rows, list(
      stress_check(name, "rater_only_projection_preserves_self_leaves",
                   isTRUE(s$ProjectedConnected[1]) &&
                     s$SelfNodeCount[1] == s$Persons[1] &&
                     s$SelfDegreeMin[1] == 1 && s$SelfDegreeMax[1] == 1,
                   paste0("self_degree=", s$SelfDegreeMin[1], "-",
                          s$SelfDegreeMax[1]))
    ))
  }
  if (grepl("^self_teacher_role_rater_projection", name)) {
    rows <- c(rows, list(
      stress_check(name, "role_projection_masks_rater_only_question",
                   isTRUE(s$ProjectedConnected[1]) &&
                     s$ProjectedComponents[1] == 1L &&
                     s$ProjectedBridges[1] == 0L &&
                     s$SelfDegreeMin[1] > 1,
                   paste0("ProjectedComponents=", s$ProjectedComponents[1],
                          "; bridges=", s$ProjectedBridges[1],
                          "; self_degree=", s$SelfDegreeMin[1], "-",
                          s$SelfDegreeMax[1]))
    ))
  }
  if (grepl("^speaking_peer_literal", name)) {
    rows <- c(rows, list(
      stress_check(name, "student_raters_are_not_self_specific_leaves",
                   isTRUE(s$ProjectedConnected[1]) &&
                     s$SelfNodeCount[1] == s$Persons[1] &&
                     s$SelfDegreeMin[1] > 1,
                   paste0("student_rater_degree=", s$SelfDegreeMin[1], "-",
                          s$SelfDegreeMax[1])),
      stress_check(name, "peer_literal_network_edges_present",
                   any(rm$Edges > 0),
                   paste0("Edges=", paste(rm$Edges, collapse = ",")))
    ))
  }
  if (grepl("^speaking_peer_collapsed_self", name)) {
    rows <- c(rows, list(
      stress_check(name, "collapsed_self_assessor_connected_to_all_persons",
                   isTRUE(s$ProjectedConnected[1]) &&
                     s$SelfNodeCount[1] == 1L &&
                     s$SelfDegreeMin[1] == s$Persons[1],
                   paste0("self_degree=", s$SelfDegreeMin[1])),
      stress_check(name, "collapsed_self_assessor_more_lenient",
                   is.finite(s$SelfSeverityIndex[1]) &&
                     s$SelfSeverityIndex[1] < 0,
                   paste0("SelfSeverityIndex=", round(s$SelfSeverityIndex[1], 3)))
    ))
  }
  if (grepl("^speaking_role_only", name)) {
    rows <- c(rows, list(
      stress_check(name, "role_only_three_mode_network",
                   isTRUE(s$ProjectedConnected[1]) &&
                     s$RaterLevels[1] == 3L &&
                     s$SelfNodeCount[1] == 1L,
                   paste0("levels=", s$RaterLevels[1],
                          "; components=", s$ProjectedComponents[1])),
      stress_check(name, "role_only_self_more_lenient",
                   is.finite(s$SelfSeverityIndex[1]) &&
                     s$SelfSeverityIndex[1] < 0,
                   paste0("SelfSeverityIndex=", round(s$SelfSeverityIndex[1], 3)))
    ))
  }
  if (grepl("^assessor_collapsed", name)) {
    rows <- c(rows, list(
      stress_check(name, "self_mode_more_lenient",
                   is.finite(s$SelfSeverityIndex[1]) &&
                     s$SelfSeverityIndex[1] < 0,
                   paste0("SelfSeverityIndex=", round(s$SelfSeverityIndex[1], 3))),
      stress_check(name, "assessor_network_edges_present",
                   any(rm$Edges > 0),
                   paste0("Edges=", paste(rm$Edges, collapse = ",")))
    ))
  }
  if (grepl("^two_panel_gap", name)) {
    rows <- c(rows, list(
      stress_check(name, "full_graph_masks_panel_gap",
                   isTRUE(s$FullConnected[1]) &&
                     !isTRUE(s$ProjectedConnected[1]) &&
                     s$ProjectedComponents[1] == 2L,
                   paste0("full=", s$FullComponents[1],
                          "; projected=", s$ProjectedComponents[1]))
    ))
  }
  if (grepl("^coverage_T0", name)) {
    rows <- c(rows, list(
      stress_check(name, "coverage_zero_disconnected_after_projection",
                   !isTRUE(s$ProjectedConnected[1]) &&
                     s$ProjectedComponents[1] == s$Persons[1],
                   paste0("ProjectedComponents=", s$ProjectedComponents[1]))
    ))
  }
  if (grepl("^coverage_T1_rotating", name)) {
    rows <- c(rows, list(
      stress_check(name, "coverage_one_rotating_panel_disconnected",
                   !isTRUE(s$ProjectedConnected[1]) &&
                     s$ProjectedComponents[1] == 4L,
                   paste0("ProjectedComponents=", s$ProjectedComponents[1]))
    ))
  }
  if (grepl("^coverage_T1_common|^coverage_T4", name)) {
    rows <- c(rows, list(
      stress_check(name, "coverage_common_or_full_connected_after_projection",
                   isTRUE(s$ProjectedConnected[1]) &&
                     s$ProjectedComponents[1] == 1L,
                   paste0("ProjectedComponents=", s$ProjectedComponents[1]))
    ))
  }
  do.call(rbind, rows)
}

write_markdown <- function(summary_tbl, mode_tbl, check_tbl, output_path) {
  failed <- check_tbl[!check_tbl$Passed, , drop = FALSE]
  lines <- c(
    "# Network/anchor stress checks for 0.2.2",
    "",
    "This artifact stress-tests projected MFRM design networks, zero-overlap",
    "rater networks, self-rater identity designs, disconnected rater panels,",
    "coverage-dose behavior, role/mode specifications, peer-rater designs,",
    "and group-anchor-only low-common-anchor guidance.",
    "",
    paste0("- Scenarios: ", length(unique(summary_tbl$Scenario))),
    paste0("- Checks: ", nrow(check_tbl)),
    paste0("- Failed checks: ", nrow(failed)),
    "",
    "## Scenario summary",
    "",
    paste(
      "Scenario | Full components | Projected components | Projected bridges |",
      "Self degree | Self severity index | Downstream rows | Network plot payload"
    ),
    "--- | ---: | ---: | ---: | --- | ---: | --- | ---"
  )
  scenario_lines <- apply(summary_tbl, 1, function(row) {
    cell <- function(name) trimws(as.character(row[[name]]))
    paste(
      cell("Scenario"),
      cell("FullComponents"),
      cell("ProjectedComponents"),
      cell("ProjectedBridges"),
      paste0(cell("SelfDegreeMin"), "-", cell("SelfDegreeMax")),
      cell("SelfSeverityIndex"),
      paste0(
        "checks=", cell("AssumptionCheckRows"),
        "; visuals=", cell("VisualizationRows"),
        "; templates=", cell("ReportTemplateRows")
      ),
      paste0(
        "layout=", cell("NetworkLayoutRows"),
        "; nodes=", cell("NetworkNodePlotRows"),
        "; edges=", cell("NetworkEdgePlotRows")
      ),
      sep = " | "
    )
  })
  lines <- c(
    lines,
    scenario_lines,
    "",
    "## Interpretation checkpoints",
    "",
    "- The full Person-plus-all-facet graph remains connected in designs where",
    "  broad task/criterion facets act as hubs; rater-specific design questions",
    "  should use a projected graph such as `facets = \"Rater\"`.",
    "- Adding `Role` to the projection can answer a method-mode question, but it",
    "  can also hide the individual self-rater leaf/bridge pattern. Compare",
    "  `self_teacher_role_rater_only_projection` with",
    "  `self_teacher_role_rater_projection`.",
    "- When student IDs appear as both self-raters and peer-raters, the literal",
    "  `Rater` facet estimates student-rater behavior, not a self-assessment",
    "  mode. Use an `Assessor` or `Role` facet when the estimand is self-vs-other",
    "  mode severity.",
    "- Teacher coverage is not a simple dose count: one common teacher links the",
    "  projected graph, while one rotating teacher per person can leave separate",
    "  teacher-panel components.",
    "- Draw-free network figures are checked as reusable plot payloads: layout,",
    "  node_plot, and edge_plot rows must be available for downstream graphics.",
    "- Each rater-network mode is checked for assumption checks, visualization",
    "  routes, APA-style report templates, and non-empty wording-to-avoid",
    "  guardrails, including zero-overlap designs with no retained edges.",
    "",
    "## Failed checks"
  )
  if (nrow(failed) == 0L) {
    lines <- c(lines, "", "None.")
  } else {
    fail_lines <- paste0(
      "- ", failed$Scenario, " / ", failed$Check, ": ", failed$Detail
    )
    lines <- c(lines, "", fail_lines)
  }
  lines <- c(
    lines,
    "",
    "## Rater-mode rows",
    "",
    paste(
      "Scenario | Mode | Pair rows | Zero-overlap pairs | Edges |",
      "Downstream rows"
    ),
    "--- | --- | ---: | ---: | ---: | ---"
  )
  mode_lines <- apply(mode_tbl, 1, function(row) {
    cell <- function(name) trimws(as.character(row[[name]]))
    paste(
      cell("Scenario"),
      cell("Mode"),
      cell("PairRows"),
      cell("ZeroOverlapPairs"),
      cell("Edges"),
      paste0(
        "checks=", cell("AssumptionCheckRows"),
        "; visuals=", cell("VisualizationRows"),
        "; templates=", cell("ReportTemplateRows"),
        "; avoid=", cell("AvoidRows")
      ),
      sep = " | "
    )
  })
  lines <- c(
    lines,
    mode_lines,
    "",
    "See `network-anchor-stress-0.2.2-summary.csv`,",
    "`network-anchor-stress-0.2.2-checks.csv`, and",
    "`network-anchor-stress-0.2.2-rater-modes.csv` for machine-readable output."
  )
  writeLines(lines, output_path, useBytes = TRUE)
}

run_network_anchor_stress <- function(pkg_dir = ".") {
  stress_load_package(pkg_dir)
  validation_dir <- file.path(pkg_dir, "inst", "validation")
  scenarios <- list(
    network_row(
      "self_only_zero_overlap",
      20260701,
      simulate_self_teacher(20260701, teachers_per_person = 0),
      "Rater",
      self_levels = sprintf("P%02d", 1:24)
    ),
    network_row(
      "mixed_literal_self_plus_teachers_seed1",
      20260702,
      simulate_self_teacher(20260702, teachers_per_person = 2),
      "Rater",
      self_levels = sprintf("P%02d", 1:24)
    ),
    network_row(
      "mixed_literal_self_plus_teachers_seed2",
      20260703,
      simulate_self_teacher(20260703, teachers_per_person = 2),
      "Rater",
      self_levels = sprintf("P%02d", 1:24)
    ),
    network_row(
      "self_teacher_role_rater_only_projection",
      20260711,
      simulate_self_teacher(20260711, teachers_per_person = 2),
      "Rater",
      self_levels = sprintf("P%02d", 1:24),
      model_facets = c("Role", "Rater", "Task", "Criterion"),
      projection_facets = "Rater"
    ),
    network_row(
      "self_teacher_role_rater_projection",
      20260712,
      simulate_self_teacher(20260712, teachers_per_person = 2),
      "Rater",
      self_levels = sprintf("P%02d", 1:24),
      model_facets = c("Role", "Rater", "Task", "Criterion"),
      projection_facets = c("Role", "Rater")
    ),
    network_row(
      "speaking_peer_literal_student_ids",
      20260713,
      simulate_speaking_peer_teacher(20260713),
      "Rater",
      self_levels = sprintf("P%02d", 1:24)
    ),
    network_row(
      "speaking_peer_collapsed_self_assessor",
      20260714,
      simulate_speaking_peer_teacher(20260714),
      "Assessor",
      self_levels = "Self"
    ),
    network_row(
      "speaking_role_only_modes",
      20260715,
      simulate_speaking_peer_teacher(20260715),
      "Role",
      self_levels = "Self"
    ),
    network_row(
      "assessor_collapsed_self_plus_teachers_seed1",
      20260704,
      simulate_self_teacher(20260704, teachers_per_person = 2,
                            collapse_self = TRUE),
      "Assessor",
      self_levels = "Self"
    ),
    network_row(
      "assessor_collapsed_self_plus_teachers_seed2",
      20260705,
      simulate_self_teacher(20260705, teachers_per_person = 2,
                            collapse_self = TRUE),
      "Assessor",
      self_levels = "Self"
    ),
    network_row(
      "two_panel_gap_full_graph_masked",
      20260706,
      simulate_teacher_panel_gap(20260706),
      "Rater"
    ),
    network_row(
      "coverage_T0",
      20260707,
      simulate_self_teacher(20260707, teachers_per_person = 0),
      "Rater",
      self_levels = sprintf("P%02d", 1:24)
    ),
    network_row(
      "coverage_T1_rotating_panel",
      20260708,
      simulate_self_teacher(20260708, teachers_per_person = 1),
      "Rater",
      self_levels = sprintf("P%02d", 1:24)
    ),
    network_row(
      "coverage_T1_common_teacher",
      20260710,
      simulate_self_teacher(20260710, n_teacher = 1, teachers_per_person = 1),
      "Rater",
      self_levels = sprintf("P%02d", 1:24)
    ),
    network_row(
      "coverage_T4",
      20260709,
      simulate_self_teacher(20260709, teachers_per_person = 4),
      "Rater",
      self_levels = sprintf("P%02d", 1:24)
    )
  )
  anchor <- anchor_group_only_check()

  summary_tbl <- do.call(rbind, c(lapply(scenarios, `[[`, "summary"),
                                  list(anchor$summary)))
  mode_tbl <- do.call(rbind, lapply(scenarios, `[[`, "rater_modes"))
  check_tbl <- do.call(rbind, c(lapply(scenarios, scenario_checks),
                                list(anchor$checks)))
  mode_summary <- mode_tbl
  summary_out <- file.path(validation_dir,
                           "network-anchor-stress-0.2.2-summary.csv")
  checks_out <- file.path(validation_dir,
                          "network-anchor-stress-0.2.2-checks.csv")
  modes_out <- file.path(validation_dir,
                         "network-anchor-stress-0.2.2-rater-modes.csv")
  md_out <- file.path(validation_dir, "network-anchor-stress-0.2.2.md")
  utils::write.csv(summary_tbl, summary_out, row.names = FALSE)
  utils::write.csv(check_tbl, checks_out, row.names = FALSE)
  utils::write.csv(mode_summary, modes_out, row.names = FALSE)
  write_markdown(summary_tbl, mode_summary, check_tbl, md_out)
  list(
    summary = summary_tbl,
    rater_modes = mode_summary,
    checks = check_tbl,
    outputs = c(summary = summary_out, checks = checks_out,
                rater_modes = modes_out, markdown = md_out)
  )
}

if (identical(environment(), globalenv())) {
  result <- run_network_anchor_stress(".")
  print(result$summary)
  print(result$checks)
  failed <- result$checks[!result$checks$Passed, , drop = FALSE]
  if (nrow(failed) > 0L) {
    stop("Network/anchor stress checks failed: ", nrow(failed),
         " check(s).", call. = FALSE)
  }
  cat("Wrote stress artifacts:\n")
  cat(paste0("- ", unname(result$outputs), collapse = "\n"), "\n")
}
