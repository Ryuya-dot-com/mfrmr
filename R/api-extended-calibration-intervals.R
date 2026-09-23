# One presentation rule for current fits, older fits and saved-result collectors.
mfrm_extended_calibration_table <- function(object, intervals = c("none", "normal"), level = .95) {
  intervals <- match.arg(intervals)
  mfrm_random_rater_interval_level(level)
  tab <- object$calibration_table
  tab$Lower <- tab$Upper <- rep(NA_real_, nrow(tab))
  if (intervals == "normal") {
    se <- tab$SE
    eligible <- tab$Parameter %in% c("Fixed facet", "Step") &
      is.finite(tab$Estimate) & is.finite(se) & se >= 0
    ready <- isTRUE(object$checks$NumericalReady) && isTRUE(object$checks$InformationPositive) &&
      !isTRUE(object$checks$EstimatedVarianceBoundary) && !isTRUE(object$checks$EstimatedPersonVarianceBoundary)
    if (!ready) eligible[] <- FALSE
    critical <- stats::qnorm((1 - level) / 2, lower.tail = FALSE)
    tab$Lower[eligible] <- tab$Estimate[eligible] - critical * se[eligible]
    tab$Upper[eligible] <- tab$Estimate[eligible] + critical * se[eligible]
  }
  tab
}

mfrm_extended_calibration_confint <- function(object, level) {
  tab <- mfrm_extended_calibration_table(object, "normal", level)
  tab <- tab[tab$Parameter %in% c("Fixed facet", "Step"), , drop = FALSE]
  bounds <- as.matrix(tab[c("Lower", "Upper")])
  rownames(bounds) <- paste(tab$Parameter, tab$Facet, tab$Level, sep = ": ")
  structure(bounds, level = level, method = "Observed-information normal approximation",
    target = "Fixed-facet and step calibration parameters",
    note = "Pointwise approximation only; nominal coverage is not established. Missing bounds retain numerical, information, boundary or SE restrictions. No variance, Person-difference or rater-quality inference.")
}

#' Explicit normal-approximation intervals for testlet calibration
#'
#' @param object A result from [fit_mfrm_testlet()].
#' @param parm `"calibration"` returns all fixed-facet and step intervals.
#'   Variance components and Person abilities are not included.
#' @param level Nominal confidence level between zero and one; default 0.95.
#' @param ... Unused.
#' @return A matrix with `Lower` and `Upper`, one row per fixed-facet level or
#'   step, and attributes `level`, `method`, `target` and `note`.
#' @details The explicit request computes estimate plus/minus a normal quantile
#'   times the saved observed-information SE. It needs no fitting, scoring or
#'   live optimizer and does not change the source fit. Nominal finite-sample
#'   coverage is not established. Estimated variance boundaries, unresolved
#'   numerical/information checks and invalid SEs retain missing bounds.
#'   No regular variance interval, simultaneous comparison or automatic rater
#'   classification is supplied. Default fit tables, summaries and plots omit
#'   these bounds. Use `summary(fit, calibration_intervals = "normal")`,
#'   `plot(fit, intervals = "normal")`, or
#'   `mfrm_results(fit, calibration_intervals = "normal")` to select the same
#'   approximation in those outputs; their level arguments retain its nominal
#'   interpretation. [predict.mfrm_testlet()] supplies the separate conditional
#'   Person-scoring intervals.
#' @seealso [confint.mfrm_random_rater()], [mfrmr_interval_guide()]
#' @export
confint.mfrm_testlet <- function(object, parm = "calibration", level = .95, ...) {
  rlang::check_dots_empty()
  if (!identical(parm, "calibration")) stop("Use parm = 'calibration'; testlet-variance and ability-SD intervals are not supplied.", call. = FALSE)
  mfrm_extended_calibration_confint(object, level)
}
