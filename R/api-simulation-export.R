#' Convert simulation evaluation objects to data frames
#'
#' @param x A simulation evaluation object returned by
#'   [evaluate_mfrm_design()], [evaluate_mfrm_signal_detection()], or
#'   [evaluate_mfrm_bias_detection()].
#' @param row.names Ignored; included for compatibility with
#'   [as.data.frame()].
#' @param optional Ignored; included for compatibility with [as.data.frame()].
#' @param component Table component to extract. The default is `"results"` for
#'   raw replication-level results. Other useful components include
#'   `"rep_overview"`, `"design_summary"`, `"detection_summary"`,
#'   `"estimates"`, `"reliability"`, and `"fit_summary"` when those tables are
#'   available for the object class.
#' @param ... Reserved for future extensions.
#'
#' @details
#' The simulation evaluators already store their core outputs as ordinary data
#' frames. These methods make that contract explicit and provide a stable route
#' for `write.csv(as.data.frame(x, component = "results"), ...)` and custom
#' graphics workflows.
#'
#' For [evaluate_mfrm_design()], the `"results"` component includes
#' facet-level separation, strata, reliability, fit summaries, and recovery
#' metrics for each design and replication. For
#' [evaluate_mfrm_bias_detection()], use `"estimates"` for fitted measure
#' estimates and `"reliability"` or `"fit_summary"` for simulation-derived
#' reliability coefficients.
#'
#' @return A base `data.frame`.
#' @examples
#' spec <- build_mfrm_arbitrary_sim_spec(
#'   n_person = 10,
#'   facets = c(Rater = 3, Criteria = 2, Task = 2),
#'   facets_per_person = c(Rater = 2),
#'   score_levels = 4
#' )
#' targets <- data.frame(Rater = "Rater03", Task = "Task02", Effect = -0.5)
#' eval <- suppressWarnings(evaluate_mfrm_bias_detection(
#'   spec,
#'   bias_targets = targets,
#'   reps = 1,
#'   fit_method = "JML",
#'   maxit = 20,
#'   bias_max_iter = 1,
#'   seed = 1
#' ))
#' head(as.data.frame(eval, component = "estimates"))
#' head(as.data.frame(eval, component = "reliability"))
#' @export
as.data.frame.mfrm_design_evaluation <- function(x,
                                                 row.names = NULL,
                                                 optional = FALSE,
                                                 component = c("results", "rep_overview", "design_summary", "overview"),
                                                 ...) {
  component <- match.arg(component)
  if (component %in% c("design_summary", "overview")) {
    s <- summary.mfrm_design_evaluation(x, digits = 6)
    return(mfrm_simulation_component_df(s[[component]]))
  }
  mfrm_simulation_component_df(x[[component]])
}

#' @export
as.data.frame.summary.mfrm_design_evaluation <- function(x,
                                                         row.names = NULL,
                                                         optional = FALSE,
                                                         component = c("design_summary", "overview"),
                                                         ...) {
  component <- match.arg(component)
  mfrm_simulation_component_df(x[[component]])
}

#' @export
as.data.frame.mfrm_signal_detection <- function(x,
                                                row.names = NULL,
                                                optional = FALSE,
                                                component = c("results", "rep_overview", "detection_summary", "overview"),
                                                ...) {
  component <- match.arg(component)
  if (component %in% c("detection_summary", "overview")) {
    s <- summary.mfrm_signal_detection(x, digits = 6)
    return(mfrm_simulation_component_df(s[[component]]))
  }
  mfrm_simulation_component_df(x[[component]])
}

#' @export
as.data.frame.summary.mfrm_signal_detection <- function(x,
                                                        row.names = NULL,
                                                        optional = FALSE,
                                                        component = c("detection_summary", "overview"),
                                                        ...) {
  component <- match.arg(component)
  mfrm_simulation_component_df(x[[component]])
}

#' @export
as.data.frame.mfrm_bias_detection <- function(x,
                                              row.names = NULL,
                                              optional = FALSE,
                                              component = c(
                                                "results", "estimates", "reliability", "fit_statistics",
                                                "fit_summary", "pair_results", "rep_overview",
                                                "target_summary", "pair_summary", "design_grid"
                                              ),
                                              ...) {
  component <- match.arg(component)
  mfrm_simulation_component_df(x[[component]])
}

#' @export
as.data.frame.summary.mfrm_bias_detection <- function(x,
                                                      row.names = NULL,
                                                      optional = FALSE,
                                                      component = c("target_summary", "pair_summary", "fit_summary"),
                                                      ...) {
  component <- match.arg(component)
  mfrm_simulation_component_df(x[[component]])
}

mfrm_simulation_component_df <- function(x) {
  if (is.null(x)) return(data.frame())
  out <- as.data.frame(x, stringsAsFactors = FALSE)
  rownames(out) <- NULL
  out
}
