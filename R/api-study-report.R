.mfrm_study_report_classes <- function() c("mfrm_multivariate_gstudy",
  "mfrm_multivariate_d_study", "mfrm_multivariate_d_comparison", "mfrm_residual_network",
  "mfrm_rater_network", "mfrm_halo_network", "mfrm_network_ergm",
  .mfrm_review_report_classes())

.mfrm_review_report_classes <- function() c("mfrm_bias", "mfrm_anchor_review",
  "mfrm_linking_review", "mfrm_model_choice_review")

.mfrm_report_context <- function(report, context) {
  if (is.null(context)) return(report)
  if (!is.character(context) || !is.null(dim(context)) || !length(context) ||
      is.null(names(context)) || anyNA(context) || anyNA(names(context)) ||
      any(!nzchar(trimws(context))) || any(!nzchar(trimws(names(context)))) ||
      anyDuplicated(names(context)))
    stop("`study_context` must be a nonempty named character vector with unique fields and nonmissing, nonblank values.", call. = FALSE)
  report$study_context <- data.frame(Field = names(context), Value = unname(context),
    Source = "User declaration; not verified by the model", stringsAsFactors = FALSE)
  report$tables$study_context <- report$study_context
  if (inherits(report, "mfrm_rater_feedback"))
    report$notes["study_context"] <- "Context supplied for this recipient; it does not change the numerical results."
  if (!is.null(report$evidence_roles)) {
    report$evidence_roles["study_context"] <- "study_design"
    report$evidence_descriptions["study_context"] <- "User-declared study and score meaning"
  }
  report$markdown <- paste(report$markdown,
    "\n\n## User-declared study and score meaning\n",
    "These declarations do not recode data, alter estimates or establish validity.\n",
    mfrm_report_markdown_table(report$study_context, max_rows = nrow(report$study_context)),
    sep = "\n")
  report
}

.mfrm_report_matrix_rows <- function(matrices) {
  do.call(rbind, lapply(names(matrices), function(source) {
    m <- matrices[[source]]
    grid <- expand.grid(Row = rownames(m), Column = colnames(m),
      stringsAsFactors = FALSE)
    data.frame(Source = source, grid, Estimate = as.vector(m), row.names = NULL)
  }))
}

.mfrm_study_report <- function(x, style, intervals) {
  domain <- class(x)[1L]
  if (style == "rater") stop("`style = 'rater'` requires mfrm_results.", call. = FALSE)
  if (!is.null(intervals) && !inherits(x, c("mfrm_multivariate_gstudy", "mfrm_multivariate_d_study")))
    stop("Saved `intervals` apply only to G/D-study reports.", call. = FALSE)
  tables <- list(); roles <- descriptions <- character()
  add <- function(name, value, role, description) {
    tables[[name]] <<- as.data.frame(value, stringsAsFactors = FALSE)
    roles[name] <<- role; descriptions[name] <<- description
  }
  notes <- character(); saved_intervals <- NULL
  if (inherits(x, .mfrm_review_report_classes())) {
    # Keep the established summary/export route, with full source tables below.
    b <- build_summary_table_bundle(x, include_empty = TRUE,
      top_n = .Machine$integer.max)
    title <- b$overview$Title[1L]
    for (nm in names(b$tables)) {
      i <- match(nm, b$table_index$Table)
      add(nm, b$tables[[nm]], b$table_index$Role[i], b$table_index$Description[i])
    }
    notes <- b$notes
    if (inherits(x, "mfrm_bias")) {
      add("bias_cells", x$table, "bias_screening_rows", "All stored bias cells, unrounded and including unavailable results")
      add("iterations", x$iteration %||% data.frame(), "bias_iteration_status", "Complete stored recalibration history")
      notes <- c(notes, "Positive Bias Size increases expected coded scores; substantive benefit depends on rubric direction.",
        "Screening tail areas and multiplicity summaries remain conditional plug-in screens, not evidence of unfairness. No new adjustment is applied by this report.")
      title_route <- "estimate_bias()"
      route <- "plot(bias_interaction_report(x)); report$tables$bias_cells"
      issue <- "Name the prespecified interaction, cell family, score direction, uncertainty basis and substantive follow-up."
    } else if (inherits(x, "mfrm_anchor_review")) {
      add("anchors", x$anchors %||% data.frame(), "study_design", "Direct anchors supplied to the receiving-data review")
      add("group_anchors", x$group_anchors %||% data.frame(), "study_design", "Group constraints supplied to the receiving-data review")
      add("anchor_issues", x$issues %||% data.frame(), "anchor_issue_counts", "All anchor-review issues")
      add("constraints", data.frame(CenteringScope = x$centering_scope %||% NA_character_),
        "study_design", "Stored centering convention")
      notes <- c(notes, "Anchor review checks receiving-data compatibility; it does not establish invariance, successful estimation or propagation of source-calibration uncertainty.")
      title_route <- "review_mfrm_anchors() / anchor_review()"
      route <- "report$tables$anchors; report$tables$anchor_issues; build_linking_review()"
      issue <- "Record anchor source, values, units/direction, centering, invariance rationale and conditional or propagated uncertainty."
    } else if (inherits(x, "mfrm_linking_review")) {
      notes <- c(notes, x$key_warnings,
        "Missing drift or chain evidence is not evidence of invariance. This report does not create or combine calibrations.")
      title_route <- "build_linking_review()"
      route <- "report$tables$status; report$tables$reporting_map"
      issue <- "Distinguish anchor readiness, drift evidence and equating-chain evidence; report which waves and uncertainty sources were actually analyzed."
    } else {
      if (is.data.frame(x$comparison$lrt)) add("lrt", x$comparison$lrt,
        "study_diagnostics", "Stored likelihood-ratio results and eligibility; not computed by the report")
      notes <- c(notes, x$key_warnings, x$comparison_warnings,
        "Information-criterion comparability and likelihood-ratio eligibility are separate. AIC rank alone does not choose the construct, scoring rule or operational model.")
      title_route <- "build_model_choice_review()"
      route <- "report$tables$comparison_table; report$tables$model_roles"
      issue <- "State model roles, comparison eligibility and how target estimates or substantive conclusions change."
    }
  } else if (inherits(x, c("mfrm_rater_network", "mfrm_halo_network", "mfrm_network_ergm"))) {
    ergm <- inherits(x, "mfrm_network_ergm")
    title <- if (ergm) "Binary rater-network model" else "Rater-network relationships"
    if (ergm) {
      for (nm in c("settings", "coefficients", "diagnostics", "warnings", "nodes", "dyads", "gof_table"))
        if (nrow(x[[nm]])) add(nm, x[[nm]], "study_diagnostics", gsub("_", " ", nm))
      add("source_settings", data.frame(Setting = names(x$source_settings),
        Value = vapply(x$source_settings, function(v) paste(v, collapse = ", "), character(1))),
        "study_design", "Source rating network definition")
      notes <- x$notes
    } else {
      for (nm in c("summary", "node_metrics", "network_fit", "pair_metrics", "edge_metrics",
                   "halo_summary_by_rater", "halo_contrast", "contrast_pairs", "caveats"))
        if (is.data.frame(x[[nm]])) add(nm, x[[nm]], "study_diagnostics", gsub("_", " ", nm))
      add("settings", data.frame(Setting = names(x$settings),
        Value = vapply(x$settings, function(v) paste(v, collapse = ", "), character(1))),
        "study_design", "Network definition and thresholds")
      notes <- x$caveats$Message
    }
    issue <- "Report node/dyad definitions, score direction, overlap, thresholds, missingness and estimation diagnostics. Network evidence does not establish causal rater effects."
    route <- "plot(x); report$tables; result$bootstrap_draws or result$gof_draws"
    title_route <- "rater_network_analysis()/rater_halo_network_analysis() -> optional fit_rater_network()"
  } else if (inherits(x, "mfrm_residual_network")) {
    title <- "Residual associations and exploratory groups"
    add("settings", x$settings, "study_design", "Residual definition, sample, threshold and clustering settings")
    add("nodes", x$nodes, "study_diagnostics", "All facet levels, displayed degree and exploratory membership")
    add("pairs", x$pairs, "study_diagnostics", "All residual pairs, including overlap and unavailable associations")
    add("clustering", summary(x)$clustering, "study_diagnostics", "Clustering availability and interpretation boundary")
    add("source_model", data.frame(Model = x$source$model %||% NA_character_,
      Method = x$source$method %||% NA_character_, Facets = paste(x$source$facets, collapse = ", ")),
      "study_design", "Source measurement model; residuals are conditional on its estimates")
    notes <- x$notes
    issue <- "Descriptive associations and exploratory groups; no calibrated edge or cluster inference."
    route <- "plot(x); x$pairs; x$person_usage; x$cell_counts"
    title_route <- "mfrm_residual_network()"
  } else {
    d <- if (inherits(x, "mfrm_multivariate_d_study")) x else NULL
    g <- if (is.null(d)) x else d$gstudy
    comparison <- inherits(x, "mfrm_multivariate_d_comparison")
    design <- if (comparison) x$source_design else g$design
    rows <- if (comparison) x$source_rows else g$data_usage$counts
    title <- if (comparison) "Paired D-study plan comparisons" else
      if (is.null(d)) "G-study variance and covariance report" else "G/D-study assessment planning report"
    nesting <- if (is.null(design$nesting)) "Crossed" else
      paste(names(design$nesting), "within", unname(design$nesting), collapse = "; ")
    add("source_design", data.frame(Method = design$method, Structure = nesting,
      Balanced = design$balanced, Complete = design$complete,
      ScoreConvention = design$score_convention), "study_design", "Observed source design and estimator")
    add("source_counts", data.frame(Factor = names(design$counts),
      ObservedLevels = unname(design$counts)), "study_design", "Observed levels; distinct from future D-study counts")
    add("source_rows", data.frame(Quantity = names(rows), Rows = unname(rows)),
      "study_design", "Input, retained and excluded source rows")
    if (!is.null(design$child_counts)) add("source_child_counts",
      data.frame(Parent = names(design$child_counts), Children = unname(design$child_counts)),
      "study_design", "Observed child counts within each parent")
    if (comparison) {
      add("comparisons", x$comparisons, "study_estimates", "Paired plan differences, SEs, intervals and availability")
      add("comparison_covariance", .mfrm_report_matrix_rows(list(Differences = x$covariance)),
        "study_estimates", "Sampling covariance between plan differences sharing a G-study")
      add("comparison_settings", data.frame(Reference = x$reference, Kind = x$kind,
        Score = x$score, Level = x$level, Method = x$method,
        SamplingCovariancePSD = x$sampling_covariance_psd), "study_design", "Paired comparison target and approximation")
      add("design_grid", cbind(Scenario = seq_len(nrow(x$design_grid)), x$design_grid),
        "study_design", "Future plans compared with the stated reference")
      add("weights", data.frame(Score = names(x$weights), Weight = unname(x$weights)),
        "study_design", "Prespecified score/composite weights, used as supplied")
      add("component_diagnostics", x$component_diagnostics, "study_diagnostics", "Source component admissibility")
      notes <- c("Differences share one estimated source: use paired uncertainty, not independent-plan SEs.",
        "Positive G/Phi differences and negative SEM differences favor the comparison plan. This is not a cost-effectiveness ranking.",
        "The stored normal-theory paired delta intervals are approximate, pointwise and not selection-adjusted. Unavailable rows remain present.")
    } else {
      add("score_definition", data.frame(Score = design$scores, Role = "Fixed observed-score component",
        Direction = "Specify rubric endpoints and any recoding in the manuscript"),
        "study_design", "Fixed scores and required substantive direction; no automatic standardization")
      add("components", .mfrm_report_matrix_rows(g$components), "study_estimates",
        "Signed source variances and covariances in products of score units")
      add("component_diagnostics", g$component_diagnostics, "study_diagnostics", "Original component PSD/rank diagnostics")
      if (!is.null(g$degrees_of_freedom)) add("degrees_of_freedom", g$degrees_of_freedom,
        "study_design", "Source ANOVA degrees of freedom")
      add("data_policy", data.frame(Missing = g$data_usage$missing,
        ObservedFraction = design$observed_fraction), "study_design",
        "Missing-score policy and coverage of retained-level cells; not assignment completion")
      if (!is.null(d)) {
        add("coefficients", summary(d), "study_estimates", "G, Phi, measurement SEM and their universe/error variances for every plan and score")
        add("design_grid", cbind(Scenario = seq_len(nrow(d$design_grid)), d$design_grid),
          "study_design", "Future complete balanced plans; not observed source counts")
        if (!is.null(d$weights)) {
          w <- d$weights
          if (!is.matrix(w)) w <- matrix(w, dimnames = list(names(w), "Composite"))
          add("weights", .mfrm_report_matrix_rows(list(Composite = w)),
            "study_design", "Fixed composite weights, used as supplied without normalization")
        }
        add("component_policy", data.frame(Policy = d$negative_components),
          "study_design", "D-study treatment of inadmissible covariance estimates")
        add("effective_components", .mfrm_report_matrix_rows(d$effective_components),
          "study_estimates", "Covariance components used for projection; compare with the original estimates")
        if (!is.null(intervals)) {
          if (is.logical(intervals)) stop("Supply saved confint(d) results, not TRUE/FALSE; reporting never computes intervals.", call. = FALSE)
          sx <- summary(d, intervals = intervals)
          saved_intervals <- sx$intervals
          add("intervals", sx$table, "study_estimates", "Saved plan/contrast intervals, including method, target and unavailable rows")
          notes <- c(notes, sx$notes)
        }
      } else if (!is.null(intervals)) {
        saved_intervals <- .mfrm_gstudy_report_intervals(g, intervals)
        columns <- unique(unlist(lapply(saved_intervals, names), use.names = FALSE))
        interval_rows <- lapply(seq_along(saved_intervals), function(i) {
          row <- as.data.frame(saved_intervals[[i]])
          for (name in setdiff(columns, names(row))) row[[name]] <- NA
          cbind(Interval = names(saved_intervals)[i], row[columns])
        })
        add("intervals", do.call(rbind, interval_rows), "study_estimates", "Saved component intervals with original points, centers and availability")
        targets <- lapply(seq_along(saved_intervals), function(i) {
          ci <- saved_intervals[[i]]; w <- attr(ci, "weights")
          score <- if (is.null(w)) attr(ci, "score_pair") else names(w)
          data.frame(Interval = names(saved_intervals)[i], Kind = attr(ci, "kind"),
            Score = score, Weight = if (is.null(w)) NA_real_ else unname(w),
            Assumption = attr(ci, "assumption"), row.names = NULL)
        })
        add("interval_targets", do.call(rbind, targets), "study_design",
          "Component interval scores/composite weights and asserted random-effects assumption")
        notes <- c(notes, unlist(lapply(saved_intervals, function(ci) attr(ci, "notes")), use.names = FALSE))
      }
      add("uncertainty", data.frame(Status = if (is.null(saved_intervals)) "not_requested" else "supplied",
        Interpretation = if (is.null(saved_intervals)) "Point estimates only; no intervals were supplied." else
          "Read each method and availability status; supplied intervals are not a blanket inference approval."),
        "study_diagnostics", "Uncertainty evidence supplied explicitly to the report")
      notes <- c(notes,
        "Persons are the differentiation target; score columns are fixed components, not additional random facets. State the sampled universe and exchangeability assumptions.",
        "G concerns relative decisions; Phi concerns absolute decisions. Report universe/error variances and measurement SEM alongside coefficients. SEM is not the sampling SE of a coefficient.",
        "Future counts describe complete balanced plans under source component invariance, not new observed data. Prespecify composite weights, score units and direction; weights are not normalized.",
        "Retain signed estimates and component diagnostics. A PSD repair or truncation changes the projection and does not validate the source model.",
        "Intervals are pointwise under their recorded assumptions and method-specific calibration. They are not simultaneous or adjusted for choosing the best plan after inspecting results.")
    }
    issue <- "Review the intended score use, sampled universe, component admissibility and supplied uncertainty."
    route <- "plot(x); report$tables; confint(g/d)"
    title_route <- "mfrm_g_study() -> mfrm_d_study()"
  }
  notes <- unique(notes)
  add("interpretation_notes", data.frame(Note = notes), "study_notes", "Interpretation boundaries to retain with tables and figures")
  first <- data.frame(Area = "Overall", Status = "review", Readiness = "Interpretation requires study context",
    MainIssue = issue, NextAction = "Complete the study-specific Methods and Results interpretation.",
    PrimaryRoute = route)
  index <- data.frame(Area = unname(descriptions), EvidenceStatus = "stored",
    PrimaryTable = names(tables), Role = unname(roles), PlotRoute = "plot(report$source)")
  markdown <- c(paste0("# ", title), "", issue,
    "", "Complete the study question, sampling/assignment, rubric endpoints, score direction and decision criteria before manuscript use.")
  for (name in names(tables)) markdown <- c(markdown, "", paste0("## ", descriptions[name]), "",
    mfrm_report_markdown_table(tables[[name]]))
  structure(list(title = title, style = style, source_include = domain,
    source_domain = domain, source = x, intervals = saved_intervals,
    first_screen = first, report_index = index, template_index = data.frame(),
    decision = data.frame(), routes = data.frame(Stage = title_route,
      Route = "mfrm_report(x) -> build_summary_table_bundle(report) -> export_summary_appendix()"),
    tables = tables, evidence_roles = roles, evidence_descriptions = descriptions,
    notes = notes, markdown = paste(markdown, collapse = "\n")), class = "mfrm_report")
}

# Context retained on newly computed component intervals for safe report reuse.
.mfrm_gstudy_interval_context <- function(ci, g) {
  attr(ci, "source_summary") <- g[c("design", "components", "mean_products", "degrees_of_freedom")]
  needs_data <- any(grepl("REML|^Residual-contrast", ci$Method))
  attr(ci, "source_requires_data") <- needs_data
  if (needs_data) attr(ci, "source_data") <- g$data
  ci
}

.mfrm_gstudy_report_intervals <- function(g, intervals) {
  if (is.data.frame(intervals)) intervals <- list(intervals)
  if (!is.list(intervals) || !length(intervals) ||
      !all(vapply(intervals, is.data.frame, logical(1))))
    stop("Supply saved confint(g) results or a list of them.", call. = FALSE)
  for (ci in intervals) {
    if (!nrow(ci) || !all(c("Source", "Estimate", "Lower", "Upper", "Level", "Method", "Status") %in% names(ci)) ||
        !identical(attr(ci, "assumption"), "normal") ||
        !isTRUE(all.equal(attr(ci, "source_summary"),
          g[c("design", "components", "mean_products", "degrees_of_freedom")], tolerance = 0)) ||
        (isTRUE(attr(ci, "source_requires_data")) &&
          !isTRUE(all.equal(attr(ci, "source_data"), g$data, tolerance = 0))) ||
        !isTRUE(all.equal(attr(ci, "source_rows"), g$data_usage$counts, tolerance = 0)))
      stop("Component interval source does not match; recreate confint(g) with this version and G-study.", call. = FALSE)
    if (anyNA(ci$Source) || anyDuplicated(ci$Source) || !all(ci$Source %in% names(g$components)))
      stop("Component intervals require distinct, known source components.", call. = FALSE)
    pair <- attr(ci, "score_pair"); w <- attr(ci, "weights")
    if (identical(attr(ci, "kind"), "Covariance")) {
      if (length(pair) != 2L || !all(pair %in% g$design$scores))
        stop("Component covariance intervals must retain their score pair.", call. = FALSE)
      point <- vapply(g$components[ci$Source], function(m) m[pair[1], pair[2]], numeric(1))
    } else {
      if (!is.numeric(w) || !identical(names(w), g$design$scores) || any(!is.finite(w)))
        stop("Component intervals must retain their original score weights.", call. = FALSE)
      point <- vapply(g$components[ci$Source], function(m) drop(crossprod(w, m %*% w)), numeric(1))
    }
    if (!isTRUE(all.equal(unname(point), ci$Estimate, tolerance = 1e-10)))
      stop("Component interval point estimates do not match the retained target and source.", call. = FALSE)
  }
  labels <- names(intervals) %||% rep("", length(intervals))
  blank <- is.na(labels) | !nzchar(labels)
  labels[blank] <- paste0("Interval", which(blank))
  names(intervals) <- make.unique(labels)
  intervals
}
