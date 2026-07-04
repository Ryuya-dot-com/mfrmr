# ==============================================================================
# Cross-analysis audit surface
# ==============================================================================

audit_status <- function(ok, review = FALSE, missing = FALSE) {
  if (isTRUE(ok)) "ok" else if (isTRUE(review)) "review" else if (isTRUE(missing)) "missing" else "not_run"
}

audit_row <- function(area, checkpoint, status, evidence = "",
                      next_action = "", boundary = "") {
  data.frame(
    Area = area,
    Checkpoint = checkpoint,
    Status = status,
    Evidence = as.character(evidence %||% ""),
    NextAction = as.character(next_action %||% ""),
    Boundary = as.character(boundary %||% ""),
    stringsAsFactors = FALSE
  )
}

audit_has_rows <- function(x) {
  is.data.frame(x) && nrow(x) > 0L
}

#' Build a cross-analysis audit for an MFRM workflow
#'
#' @description
#' `mfrm_analysis_audit()` is a lightweight review layer over existing analysis
#' objects. It does not fit new models by default and it does not turn evidence
#' into a single pass/fail decision. Instead, it records which parts of a
#' defensible MFRM workflow are present, which raise review signals, and which
#' remain unrun.
#' When a [mfrm_generalizability()] object carries its design check, the
#' review adds a `g_study_interaction_identifiability` checkpoint for
#' interaction and highest-order cell review.
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()].
#' @param generalizability Optional output from [mfrm_generalizability()].
#' @param generalizability_bootstrap Optional output from
#'   [bootstrap_mfrm_generalizability()].
#' @param comparison Optional output from [compare_mfrm_generalizability()].
#' @param d_study Optional output from [mfrm_d_study()].
#' @param bias_results Optional bias/DIF object or list, for example from
#'   [estimate_bias()], [analyze_dff()], or [analyze_dif_mh()].
#' @param resamples Optional output from [draw_mfrm_resamples()].
#' @param hierarchical_structure Optional output from
#'   [analyze_hierarchical_structure()].
#' @param run_diagnostics Logical. If `TRUE` and `diagnostics = NULL`, compute
#'   [diagnose_mfrm()] with `residual_pca = "none"`. The default `FALSE`
#'   avoids surprising long-running work.
#'
#' @return An object of class `mfrm_analysis_audit`, a list with `overview`,
#'   `checkpoints`, `next_actions`, and `components`.
#'
#' @examples
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 30)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' analysis_review <- mfrm_analysis_audit(fit, diagnostics = diag)
#' analysis_review$checkpoints
#' }
#' @export
mfrm_analysis_audit <- function(fit,
                                diagnostics = NULL,
                                generalizability = NULL,
                                generalizability_bootstrap = NULL,
                                comparison = NULL,
                                d_study = NULL,
                                bias_results = NULL,
                                resamples = NULL,
                                hierarchical_structure = NULL,
                                run_diagnostics = FALSE) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  if (!is.logical(run_diagnostics) || length(run_diagnostics) != 1L || is.na(run_diagnostics)) {
    stop("`run_diagnostics` must be a single TRUE/FALSE value.", call. = FALSE)
  }
  if (is.null(diagnostics) && isTRUE(run_diagnostics)) {
    diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
  }

  fit_summary <- as.data.frame(fit$summary %||% data.frame(), stringsAsFactors = FALSE)
  converged <- isTRUE(fit_summary$Converged[1] %||% FALSE)
  rows <- list()
  rows[[length(rows) + 1L]] <- audit_row(
    "model_fit",
    "estimation_convergence",
    audit_status(converged, review = !converged),
    evidence = paste0("Converged = ", converged),
    next_action = if (converged) "Inspect diagnostics and precision evidence." else "Review optimizer message, iterations, anchors, and model specification.",
    boundary = "Convergence is required before strong fit, precision, or fairness claims."
  )

  diag_available <- !is.null(diagnostics) && is.list(diagnostics)
  rows[[length(rows) + 1L]] <- audit_row(
    "diagnostics",
    "diagnose_mfrm_available",
    audit_status(diag_available, missing = !diag_available),
    evidence = if (diag_available) "diagnostics supplied" else "diagnostics not supplied",
    next_action = if (diag_available) "Review fit, residual, strict marginal, and precision sections." else "Run diagnose_mfrm(fit, diagnostic_mode = \"both\") when feasible.",
    boundary = "Fit diagnostics are evidence summaries, not automatic validity decisions."
  )
  if (diag_available) {
    rel <- as.data.frame(diagnostics$reliability %||% data.frame(), stringsAsFactors = FALSE)
    obs <- as.data.frame(diagnostics$obs %||% data.frame(), stringsAsFactors = FALSE)
    rows[[length(rows) + 1L]] <- audit_row(
      "precision",
      "reliability_table",
      audit_status(audit_has_rows(rel), missing = !audit_has_rows(rel)),
      evidence = paste0(nrow(rel), " reliability row(s)"),
      next_action = if (audit_has_rows(rel)) "Separate MFRM separation reliability from G-theory G/Phi." else "Run diagnostics with reliability output available.",
      boundary = "MFRM reliability remains on the fitted-measure precision route."
    )
    rows[[length(rows) + 1L]] <- audit_row(
      "residuals",
      "observation_residuals",
      audit_status(audit_has_rows(obs) && "StdResidual" %in% names(obs),
                   missing = !(audit_has_rows(obs) && "StdResidual" %in% names(obs))),
      evidence = paste0(nrow(obs), " observation row(s)"),
      next_action = "Use local dependence, person fit, and residual plots when residual claims matter.",
      boundary = "Residual screens are exploratory unless backed by a prespecified operating-characteristic study."
    )
  }

  gt_available <- inherits(generalizability, "mfrm_generalizability")
  gt_singular <- gt_available && isTRUE(generalizability$design$singular_fit)
  rows[[length(rows) + 1L]] <- audit_row(
    "generalizability",
    "g_study",
    audit_status(gt_available && !gt_singular, review = gt_available && gt_singular,
                 missing = !gt_available),
    evidence = if (gt_available) {
      paste0("G = ", generalizability$coefficients$G[1],
             "; Phi = ", generalizability$coefficients$Phi[1],
             "; singular = ", gt_singular)
    } else {
      "G-study not supplied"
    },
    next_action = if (gt_available) "Report as observed-score G-theory complement." else "Run mfrm_generalizability() when design generalizability is a reporting question.",
    boundary = "G/Phi are not MFRM separation reliability."
  )

  gt_design_check <- if (gt_available) {
    generalizability$design$design_check %||% NULL
  } else {
    NULL
  }
  gt_design_available <- inherits(gt_design_check, "mfrm_generalizability_design_check")
  gt_design_overview <- if (gt_design_available) {
    as.data.frame(gt_design_check$overview %||% data.frame(),
                  stringsAsFactors = FALSE)
  } else {
    data.frame()
  }
  gt_design_review_count <- if (nrow(gt_design_overview) > 0L) {
    suppressWarnings(as.integer(gt_design_overview$ReviewCount[1] %||% 0L))
  } else {
    0L
  }
  gt_design_sensitivity_count <- if (nrow(gt_design_overview) > 0L) {
    suppressWarnings(as.integer(gt_design_overview$SensitivityOnlyCount[1] %||% 0L))
  } else {
    0L
  }
  rows[[length(rows) + 1L]] <- audit_row(
    "design_structure",
    "g_study_interaction_identifiability",
    audit_status(
      gt_design_available &&
        gt_design_review_count == 0L &&
        gt_design_sensitivity_count == 0L,
      review = gt_design_available &&
        (gt_design_review_count > 0L || gt_design_sensitivity_count > 0L),
      missing = !gt_design_available
    ),
    evidence = if (gt_design_available) {
      paste0(
        "review = ", gt_design_review_count,
        "; sensitivity_only = ", gt_design_sensitivity_count,
        "; highest-order = ",
        gt_design_overview$HighestOrderStatus[1] %||% NA_character_
      )
    } else {
      "G-study design check not supplied"
    },
    next_action = if (gt_design_available) {
      "Review interaction_overview and highest_order_review before interpreting expanded variance components."
    } else {
      "Run mfrm_generalizability() or check_mfrm_generalizability_design() before making interaction-variance claims."
    },
    boundary = "Design checks describe observed crossing and replication; they do not prove variance components are stable."
  )

  boot_available <- inherits(generalizability_bootstrap, "mfrm_generalizability_bootstrap")
  rows[[length(rows) + 1L]] <- audit_row(
    "uncertainty",
    "g_study_bootstrap",
    audit_status(boot_available, missing = gt_available && !boot_available),
    evidence = if (boot_available) {
      paste0(generalizability_bootstrap$overview$RepsSucceeded[1], "/",
             generalizability_bootstrap$overview$RepsRequested[1],
             " successful bootstrap replicate(s)")
    } else {
      "G-study bootstrap not supplied"
    },
    next_action = if (boot_available) "Inspect interval width and failed replicates before reporting." else "Run bootstrap_mfrm_generalizability() before making strong G/Phi difference claims.",
    boundary = "Bootstrap intervals summarize observed-data stability, not known-truth recovery."
  )

  cmp_available <- inherits(comparison, "mfrm_generalizability_comparison")
  cmp_singular <- cmp_available && isTRUE(comparison$summary$ExpandedSingular[1] %||% FALSE)
  cmp_review <- if (cmp_available) {
    as.data.frame(comparison$comparison_review %||% data.frame(),
                  stringsAsFactors = FALSE)
  } else {
    data.frame()
  }
  cmp_review_n <- if (nrow(cmp_review) > 0L && "Status" %in% names(cmp_review)) {
    sum(cmp_review$Status %in% "review", na.rm = TRUE)
  } else {
    0L
  }
  cmp_sensitivity_n <- if (nrow(cmp_review) > 0L && "Status" %in% names(cmp_review)) {
    sum(cmp_review$Status %in% "sensitivity_only", na.rm = TRUE)
  } else {
    0L
  }
  cmp_status <- audit_status(
    cmp_available && !cmp_singular && cmp_review_n == 0L && cmp_sensitivity_n == 0L,
    review = cmp_available &&
      (cmp_singular || cmp_review_n > 0L || cmp_sensitivity_n > 0L),
    missing = !cmp_available
  )
  rows[[length(rows) + 1L]] <- audit_row(
    "sensitivity",
    "g_study_interaction_comparison",
    cmp_status,
    evidence = if (cmp_available) {
      paste0("DeltaG = ", comparison$summary$DeltaG[1],
             "; DeltaPhi = ", comparison$summary$DeltaPhi[1],
             "; expanded singular = ", cmp_singular,
             "; comparison review = ", cmp_review_n,
             "; comparison sensitivity_only = ", cmp_sensitivity_n)
    } else {
      "interaction comparison not supplied"
    },
    next_action = if (cmp_available) {
      "Review comparison$comparison_review, design-check plots, and warnings before replacing the main-effects baseline."
    } else {
      "Run compare_mfrm_generalizability() when named interactions are substantively important."
    },
    boundary = "Expanded models are sensitivity evidence when sparse or singular."
  )

  ds_available <- inherits(d_study, "mfrm_d_study") || is.data.frame(d_study)
  rows[[length(rows) + 1L]] <- audit_row(
    "design_planning",
    "d_study_projection",
    audit_status(ds_available, missing = gt_available && !ds_available),
    evidence = if (ds_available) paste0(nrow(as.data.frame(d_study)), " D-study row(s)") else "D-study not supplied",
    next_action = if (ds_available) "Review residual-scaling assumptions and target decision bands." else "Run mfrm_d_study() when planned facet counts are under discussion.",
    boundary = "D-study projections inherit the declared G-study decomposition."
  )

  rows[[length(rows) + 1L]] <- audit_row(
    "fairness",
    "bias_or_dif_evidence",
    audit_status(!is.null(bias_results), missing = is.null(bias_results)),
    evidence = if (is.null(bias_results)) "bias/DIF object not supplied" else paste(class(bias_results), collapse = "/"),
    next_action = if (is.null(bias_results)) "Run the appropriate DFF/DIF or bias screen when group or facet fairness claims matter." else "Inspect effect sizes, uncertainty, sparse cells, and target-direction validation.",
    boundary = "Screening evidence is not standalone proof of invariance or fairness."
  )

  rows[[length(rows) + 1L]] <- audit_row(
    "stability",
    "observed_data_resampling",
    audit_status(inherits(resamples, "mfrm_resamples"), missing = is.null(resamples)),
    evidence = if (inherits(resamples, "mfrm_resamples")) paste0(nrow(resamples$manifest), " resample manifest row(s)") else "resamples not supplied",
    next_action = if (inherits(resamples, "mfrm_resamples")) "Inspect stratum and preserve-facet coverage." else "Use build_mfrm_resampling_spec() and draw_mfrm_resamples() for observed-data stability review.",
    boundary = "Observed-data resampling checks stability against full-data estimates, not parameter recovery."
  )

  rows[[length(rows) + 1L]] <- audit_row(
    "design_structure",
    "hierarchical_or_sample_adequacy",
    audit_status(inherits(hierarchical_structure, "mfrm_hierarchical_structure"),
                 missing = is.null(hierarchical_structure)),
    evidence = if (inherits(hierarchical_structure, "mfrm_hierarchical_structure")) "hierarchical structure object supplied" else "hierarchical structure review not supplied",
    next_action = if (inherits(hierarchical_structure, "mfrm_hierarchical_structure")) "Review nested facets, sparse levels, ICC, and design effects." else "Run analyze_hierarchical_structure() for nesting and sample-adequacy review.",
    boundary = "Design-structure checks describe the observed design and do not refit the MFRM."
  )

  data <- as.data.frame(fit$prep$data %||% data.frame(), stringsAsFactors = FALSE)
  has_weight <- "Weight" %in% names(data)
  rows[[length(rows) + 1L]] <- audit_row(
    "data_policy",
    "weights_and_missingness",
    "info",
    evidence = paste0("Rows = ", nrow(data), "; Weight column = ", has_weight),
    next_action = "Document missing-code handling, weights, and assignment mechanism before strong operational claims.",
    boundary = "Data-policy evidence is design documentation, not a psychometric fit statistic."
  )

  checkpoints <- dplyr::bind_rows(rows)
  status_rank <- c(review = 1L, missing = 2L, not_run = 3L, info = 4L, ok = 5L)
  next_actions <- checkpoints[
    checkpoints$Status %in% c("review", "missing", "not_run"),
    ,
    drop = FALSE
  ]
  if (nrow(next_actions) > 0L) {
    next_actions$.rank <- unname(status_rank[next_actions$Status])
    next_actions <- next_actions[order(next_actions$.rank, next_actions$Area), , drop = FALSE]
    next_actions$.rank <- NULL
  }
  overview <- data.frame(
    Checkpoints = nrow(checkpoints),
    OK = sum(checkpoints$Status == "ok", na.rm = TRUE),
    Review = sum(checkpoints$Status == "review", na.rm = TRUE),
    Missing = sum(checkpoints$Status == "missing", na.rm = TRUE),
    NotRun = sum(checkpoints$Status == "not_run", na.rm = TRUE),
    Info = sum(checkpoints$Status == "info", na.rm = TRUE),
    stringsAsFactors = FALSE
  )
  out <- list(
    overview = overview,
    checkpoints = checkpoints,
    next_actions = next_actions,
    components = list(
      fit = fit,
      diagnostics = diagnostics,
      generalizability = generalizability,
      generalizability_bootstrap = generalizability_bootstrap,
      comparison = comparison,
      d_study = d_study,
      bias_results = bias_results,
      resamples = resamples,
      hierarchical_structure = hierarchical_structure
    ),
    terminology = c(
      "The audit is a workflow coverage and caution layer, not a pass/fail validity decision.",
      "Rows marked missing can be not applicable when the corresponding claim is not part of the analysis.",
      "Use review rows to decide which specialist helper or external validation step should come next."
    )
  )
  class(out) <- c("mfrm_analysis_audit", "list")
  out
}

#' @export
summary.mfrm_analysis_audit <- function(object, ...) {
  if (!inherits(object, "mfrm_analysis_audit")) {
    stop("`object` must be output from mfrm_analysis_audit().", call. = FALSE)
  }
  out <- list(
    overview = object$overview,
    checkpoints = object$checkpoints,
    next_actions = object$next_actions,
    terminology = object$terminology
  )
  class(out) <- "summary.mfrm_analysis_audit"
  out
}

#' @export
print.summary.mfrm_analysis_audit <- function(x, ...) {
  cat("MFRM analysis audit summary\n")
  print(x$overview, row.names = FALSE)
  if (nrow(x$next_actions) > 0L) {
    cat("\nNext actions\n")
    cols <- intersect(c("Area", "Checkpoint", "Status", "NextAction"),
                      names(x$next_actions))
    print(x$next_actions[, cols, drop = FALSE], row.names = FALSE)
  }
  cat("\nNotes\n")
  for (line in x$terminology) cat(" - ", line, "\n", sep = "")
  invisible(x)
}

#' @export
print.mfrm_analysis_audit <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}
