# Saved planning results: describe the decision without rerunning simulations.
.mfrm_plan_review <- function(x, costs, limits, targets) {
  metrics <- c("G", "Phi", "RelativeSEM", "AbsoluteSEM")
  tab <- x$comparisons
  grid <- x$design_grid
  n <- nrow(grid)
  ref <- x$reference
  required <- c("Reference", "Scenario", "Metric", "ReferenceValue", "Value",
    "Difference", "SE", "Lower", "Upper", "Status")
  if (!is.data.frame(grid) || ncol(grid) != 2L || n < 2L ||
      !all(vapply(grid, function(v) is.numeric(v) && !is.complex(v) && is.null(dim(v)), logical(1))) ||
      any(!is.finite(as.matrix(grid)) | as.matrix(grid) < 1 | as.matrix(grid) != floor(as.matrix(grid))) ||
      length(ref) != 1L || !is.numeric(ref) || is.complex(ref) || !is.null(dim(ref)) ||
      !is.finite(ref) || !ref %in% seq_len(n) ||
      !is.data.frame(tab) || !all(required %in% names(tab)))
    stop("The saved comparison must retain its reference, crossed design grid and paired results.", call. = FALSE)
  candidates <- setdiff(seq_len(n), ref)
  expected <- as.vector(outer(candidates, metrics, paste, sep = "/"))
  keys <- paste(tab$Scenario, tab$Metric, sep = "/")
  if (!is.numeric(tab$Scenario) || is.complex(tab$Scenario) || !is.null(dim(tab$Scenario)) ||
      anyDuplicated(keys) || !setequal(keys, expected) ||
      anyNA(tab$Reference) || any(tab$Reference != ref) ||
      !all(vapply(tab[c("ReferenceValue", "Value", "Difference", "SE", "Lower", "Upper")],
        is.numeric, logical(1))) ||
      !isTRUE(all.equal(tab$Difference, tab$Value - tab$ReferenceValue, tolerance = 0)))
    stop("The saved comparison needs each candidate/metric once with consistent paired differences.", call. = FALSE)

  named_bounds <- function(value, allowed, name) {
    if (is.null(value)) return(numeric())
    if (!is.numeric(value) || is.complex(value) || !is.null(dim(value)) ||
        is.null(names(value)) || anyNA(names(value)) || anyDuplicated(names(value)) ||
        any(!names(value) %in% allowed) || any(!is.finite(value) | value < 0))
      stop("`", name, "` must be a uniquely named vector of finite nonnegative bounds for ",
        paste(allowed, collapse = ", "), ".", call. = FALSE)
    value
  }
  if (is.null(costs)) costs <- data.frame(Scenario = seq_len(n))
  if (!is.data.frame(costs) || anyNA(names(costs)) || anyDuplicated(names(costs)) ||
      any(!nzchar(trimws(names(costs)))) || !"Scenario" %in% names(costs) ||
      !is.numeric(costs$Scenario) || is.complex(costs$Scenario) || !is.null(dim(costs$Scenario)) ||
      anyNA(costs$Scenario) || anyDuplicated(costs$Scenario) ||
      !setequal(costs$Scenario, seq_len(n)))
    stop("`costs` must have unique column names and each Scenario exactly once, including the reference.", call. = FALSE)
  cost_names <- setdiff(names(costs), "Scenario")
  valid_cost <- function(v) is.numeric(v) && !is.complex(v) && is.null(dim(v)) &&
    !any(is.nan(v) | (!is.na(v) & (!is.finite(v) | v < 0)))
  if (!all(vapply(costs[cost_names], valid_cost, logical(1))))
    stop("Cost columns must contain finite nonnegative numbers or NA for unknown costs.", call. = FALSE)
  costs <- as.data.frame(costs[match(seq_len(n), costs$Scenario), , drop = FALSE])
  rownames(costs) <- NULL
  limits <- named_bounds(limits, cost_names, "limits")
  targets <- named_bounds(targets, metrics, "targets")
  if (any(targets[intersect(names(targets), c("G", "Phi"))] > 1))
    stop("G and Phi point targets must be between zero and one.", call. = FALSE)

  plans <- data.frame(Scenario = seq_len(n), IsReference = seq_len(n) == ref,
    RatingsPerPerson = apply(grid, 1L, function(v) prod(as.double(v))))
  for (metric in metrics) {
    rows <- tab[tab$Metric == metric, , drop = FALSE]
    if (length(unique(rows$ReferenceValue)) != 1L)
      stop("Reference values must agree across the saved comparisons.", call. = FALSE)
    plans[[metric]] <- rows$Value[match(seq_len(n), rows$Scenario)]
    plans[[metric]][ref] <- rows$ReferenceValue[1L]
  }
  checks <- data.frame(Scenario = integer(), Type = character(), Criterion = character(),
    Value = numeric(), Relation = character(), Threshold = numeric(), Status = character())
  for (type in c("resource", "point_target")) {
    values <- if (type == "resource") costs else plans
    bounds <- if (type == "resource") limits else targets
    for (name in names(bounds)) {
      value <- values[[name]]
      lower <- type == "point_target" && name %in% c("G", "Phi")
      pass <- if (lower) value >= bounds[[name]] else value <= bounds[[name]]
      checks <- rbind(checks, data.frame(Scenario = seq_len(n), Type = type,
        Criterion = name, Value = value, Relation = if (lower) ">=" else "<=",
        Threshold = bounds[[name]], Status = ifelse(!is.finite(value), "unavailable",
          ifelse(pass, "pass", "fail"))))
    }
  }
  aggregate_status <- function(type, passed, failed) vapply(seq_len(n), function(i) {
    status <- checks$Status[checks$Scenario == i & checks$Type == type]
    if (!length(status)) "not_requested" else if (any(status == "fail")) failed else
      if (any(status == "unavailable")) "unavailable" else passed
  }, character(1))
  plans$Feasibility <- aggregate_status("resource", "feasible", "infeasible")
  plans$TargetStatus <- aggregate_status("point_target", "pass", "fail")
  component_psd <- x$component_diagnostics$PositiveSemidefinite
  review <- !length(component_psd) || !all(component_psd %in% TRUE) ||
    !isTRUE(x$sampling_covariance_psd)
  plans$ReviewRequired <- review

  differences <- tab
  ok <- tab$Status %in% "Available" & is.finite(tab$Difference) &
    is.finite(tab$Lower) & is.finite(tab$Upper) & tab$Lower <= tab$Upper
  larger <- tab$Metric %in% c("G", "Phi")
  direction <- rep("unavailable", nrow(tab))
  direction[ok] <- "inconclusive"
  direction[ok & ((larger & tab$Lower > 0) | (!larger & tab$Upper < 0))] <- "improved"
  direction[ok & ((larger & tab$Upper < 0) | (!larger & tab$Lower > 0))] <- "worse"
  same <- vapply(tab$Scenario, function(i) all(grid[i, ] == grid[ref, ]), logical(1))
  direction[ok & same & tab$Difference == 0 & tab$Lower == 0 & tab$Upper == 0] <- "identical_plan"
  differences$Direction <- direction
  differences$Feasibility <- plans$Feasibility[match(tab$Scenario, plans$Scenario)]
  differences$TargetStatus <- plans$TargetStatus[match(tab$Scenario, plans$Scenario)]
  differences$ReviewRequired <- review
  notes <- c(
    "Observed-score G/Phi and measurement SEM under the stored G-study; not latent-ability or Bayesian future-plan predictions. State the score definition and sampled universe.",
    "RatingsPerPerson is the product of future crossed facet counts, not total ratings in a cohort. Costs and resource units are user supplied; source Person counts do not define a future cohort.",
    "Feasibility concerns requested limits only. Point-target pass/fail is not a confidence statement about population target attainment; no targets or limits are imposed by default.",
    "Direction uses the saved paired difference interval. Inconclusive does not mean equivalent. Identical plans share a zero difference by construction, not an empirical equivalence finding.",
    "Intervals are approximate and pointwise for prespecified plans and fixed score weights. Searching for a winner can introduce selection bias; no best-plan or selection-adjusted guarantee is provided.",
    "All plans, costs, unavailable results and component diagnostics are retained. ReviewRequired flags non-PSD or missing covariance diagnostics; available intervals do not establish model fit or finite-sample coverage.")
  x$planning <- list(plans = plans, costs = costs, checks = checks, differences = differences,
    basis = data.frame(Target = "Observed-score mean", Kind = x$kind, Score = x$score,
      FutureDesign = "Complete crossed random facets", ComponentTreatment = "raw",
      Uncertainty = x$method, Level = x$level, Reference = ref), notes = notes)
  x
}

.mfrm_design_target <- function(facets) {
  data.frame(Facet = facets,
    Target = ifelse(facets == "Person", "Person differentiation", "Facet calibration"),
    Interpretation = ifelse(facets == "Person",
      "Distinguishing Persons in the simulated population; not classification accuracy at a cut score.",
      "Distinguishing facet-level locations; high separation reliability does not mean high inter-rater agreement."),
    stringsAsFactors = FALSE)
}

#' @rdname recommend_mfrm_design
#' @details `summary()` method: Review a simulation-based design recommendation
#' @param object A simulation-based result from [recommend_mfrm_design()].
#' @details For `summary()`: Recommendations screen the saved simulation aggregates under the requested
#' criteria. The default targets non-Person facet calibration. For Person
#' differentiation, request `facets = "Person"` when recommending the design.
#' Neither target establishes classification accuracy, inter-rater agreement,
#' a universal minimum sample size or precision outside the simulated population.
#'
#' `checks` has one row per design, target facet and criterion, including
#' unavailable metrics and inactive constraints. `DesignRow` links these rows
#' to the complete, ranked `design_table`. `Selected` marks the first passing
#' plan under the stored `prefer` order; it does not establish an optimum over
#' unevaluated plans. `Pass` and selected plans are reused without recalculation.
#' Threshold sources are recorded for new results; older saved results show
#' `not_recorded`. No confidence intervals or selection-adjusted uncertainty
#' are calculated. Retain the simulation's generating assumptions and replication
#' evidence with the recommendation.
#' @return For `summary()`: `summary()` returns a `summary.mfrm_design_recommendation` list
#' containing `target`, `thresholds`, `checks`, `design_table`, `facet_table`,
#' `recommended`, and `notes`. Print methods return their input invisibly.
#' @seealso [recommend_mfrm_design()], [plot.mfrm_design_recommendation()],
#'   [mfrm_report()], [export_summary_appendix()]
#' @examples # Saved synthetic simulation; one replication illustrates structure only.
#' saved <- readRDS(system.file("examples", "simulation-design.rds",
#'   package = "mfrmr", mustWork = TRUE))
#' rec <- recommend_mfrm_design(saved$result, facets = "Person")
#' summary(rec)
#' report <- mfrm_report(rec)
#' report$tables$checks
#' @export
summary.mfrm_design_recommendation <- function(object, ...) {
  rlang::check_dots_empty()
  x <- object
  if (!is.data.frame(x$design_table) || !is.data.frame(x$facet_table) ||
      !is.list(x$thresholds) || !length(x$thresholds$facets))
    stop("The recommendation must retain its design/facet tables and thresholds.", call. = FALSE)
  designs <- as.data.frame(x$design_table)
  designs$DesignRow <- seq_len(nrow(designs))
  designs$Selected <- FALSE
  selected <- which(designs$Pass %in% TRUE)
  if (length(selected)) designs$Selected[selected[1L]] <- TRUE
  keys <- simulation_design_group_variables(x$design_descriptor)
  facets <- dplyr::left_join(x$facet_table, designs[c(keys, "DesignRow")], by = keys)
  criteria <- c(Separation = "MeanSeparation", Reliability = "MeanReliability",
    SeverityRMSE = "MeanSeverityRMSE", MisfitRate = "MeanMisfitRate",
    Convergence = "ConvergenceRate")
  limits <- c("min_separation", "min_reliability", "max_severity_rmse",
    "max_misfit_rate", "min_convergence_rate")
  checks <- lapply(seq_along(criteria), function(i) {
    value <- facets[[criteria[i]]]
    data.frame(DesignRow = facets$DesignRow, Facet = facets$Facet,
      Criterion = names(criteria)[i], Value = value,
      Relation = if (startsWith(limits[i], "min")) ">=" else "<=",
      Threshold = x$thresholds[[limits[i]]],
      Status = ifelse(!is.finite(value), "unavailable",
        ifelse(facets[[paste0(names(criteria)[i], "Pass")]] %in% TRUE, "pass", "fail")))
  })
  add <- function(name, value, limit, relation, pass, active = TRUE) {
    data.frame(DesignRow = designs$DesignRow, Facet = "All requested facets",
      Criterion = name, Value = value, Relation = relation,
      Threshold = if (is.null(limit)) NA_real_ else limit,
      Status = if (!active) rep("not_requested", nrow(designs)) else
        ifelse(!is.finite(value), "unavailable", ifelse(pass %in% TRUE, "pass", "fail")))
  }
  checks <- dplyr::bind_rows(checks,
    add("Facet coverage", vapply(designs$DesignRow, function(i)
      sum(x$thresholds$facets %in% facets$Facet[facets$DesignRow == i]), integer(1)),
      designs$FacetsRequired, "=", designs$FacetsMissing == ""),
    add("Total ratings", designs$MaxRatings, x$thresholds$max_ratings, "<=",
      designs$RatingsPass, !is.null(x$thresholds$max_ratings)),
    add("Ratings per rater", designs$MaxRatingsPerRater, x$thresholds$max_ratings_per_rater, "<=",
      designs$RaterWorkloadPass, !is.null(x$thresholds$max_ratings_per_rater)),
    add("Connected assignments", ifelse(designs$ConnectivityStatus == "not_assessed", NA_real_,
      as.numeric(designs$ConnectivityStatus == "connected")), 1, "=", designs$ConnectivityPass,
      isTRUE(x$thresholds$require_connected)))
  thresholds <- data.frame(Setting = names(x$thresholds),
    Value = vapply(x$thresholds, function(v) if (is.null(v)) "not_requested" else paste(v, collapse = ", "), character(1)),
    Source = unname(x$threshold_sources[names(x$thresholds)] %||%
      rep("not_recorded", length(x$thresholds))), stringsAsFactors = FALSE)
  thresholds$Source[is.na(thresholds$Source)] <- "not_recorded"
  notes <- c(unlist(x$caveats, use.names = FALSE),
    "Separation reliability describes reproducible differences within a facet, not inter-rater agreement. Low separation can reflect small differences or insufficient precision.",
    "Thresholds are planning choices, not universal standards. Passing describes the evaluated conditions only; no minimum sample size outside those conditions is established.",
    "Averaged simulation metrics do not guarantee every replication meets a threshold. Inspect the source evaluation's replication counts, failures and Monte Carlo uncertainty.",
    "No plan-selection uncertainty or confidence intervals are supplied. Sparse-overlap review is separate from Pass.")
  structure(list(target = .mfrm_design_target(x$thresholds$facets),
    thresholds = thresholds, checks = as.data.frame(checks), design_table = designs,
    facet_table = as.data.frame(x$facet_table), recommended = x$recommended, notes = notes),
    class = "summary.mfrm_design_recommendation")
}

#' @rdname recommend_mfrm_design
#' @export
print.summary.mfrm_design_recommendation <- function(x, ...) {
  rlang::check_dots_empty()
  cat("Simulation-based design recommendation\n")
  print(x$target, row.names = FALSE)
  cat("\n", sum(x$design_table$Pass %in% TRUE), "of", nrow(x$design_table), "evaluated designs pass.\n")
  if (nrow(x$recommended)) print(x$recommended) else cat("No evaluated design meets all requested criteria.\n")
  cat("Use $checks for all criterion outcomes and $thresholds for their source.\n")
  cat("This screen does not establish agreement, classification accuracy or a universal sample size.\n")
  invisible(x)
}

#' @rdname recommend_mfrm_design
#' @name print.mfrm_design_recommendation
#' @aliases print.mfrm_design_recommendation
#' @usage \method{print}{mfrm_design_recommendation}(x, ...)
#' @rawNamespace S3method(print,mfrm_design_recommendation,print.mfrm_bundle)
NULL

#' @rdname recommend_mfrm_design
#' @details `plot()` method: Plot criteria behind a design recommendation
#' @param draw Logical; draw the criterion-status matrix. Use `FALSE` to
#'   retrieve every criterion and source table without drawing.
#' @param ... Unused; extra arguments are rejected.
#' @return For `plot()`: An invisible `ggplot` object whose underlying payload
#'   (accessible via [plot_data()]) retains `table` (long criterion outcomes),
#'   `designs`, `targets`, `thresholds` and interpretation notes.
#' @details For `plot()`: Columns are ranked candidates, labelled by `DesignRow`; an asterisk
#'   marks the selected candidate. Rows combine the facet and criterion.
#'   Grey means unavailable and white means not requested, neither a passing
#'   result. Selection follows the stored ordering, not a new utility function.
#'   For custom ggplot/raincloud graphics, use `plot_data(x, "table")` or obtain
#'   full design metrics with `plot_data(x, "designs", format = "long",
#'   value_cols = c("MinReliability", "MaxRatings"))`. These aggregate metrics
#'   are not replication-level distributions for a raincloud plot.
#' @seealso [summary.mfrm_design_recommendation()], [as_ggplot()], [plot_data()]
#' @examples saved <- readRDS(system.file("examples", "simulation-design.rds",
#'   package = "mfrmr", mustWork = TRUE))
#' rec <- recommend_mfrm_design(saved$result, facets = "Person")
#' plot(rec)
#' head(plot_data(rec, "table"))
#' @export
plot.mfrm_design_recommendation <- function(x, draw = TRUE, ...) {
  rlang::check_dots_empty()
  s <- summary(x)
  tab <- s$checks
  tab$Check <- paste(ifelse(tab$Facet == "All requested facets", "Design", tab$Facet),
    tab$Criterion, sep = ": ")
  if (isTRUE(draw) && !nrow(s$design_table)) {
    stop("No evaluated designs to plot.", call. = FALSE)
  }
  out <- new_mfrm_plot_data("design_recommendation", list(table = tab,
    designs = s$design_table, targets = s$target, thresholds = s$thresholds,
    notes = data.frame(Type = "interpretation", Text = s$notes)))
  .mfrm_finalize_ggplot(out, draw = draw)
}
