#' Population-SD profiles and explicit shared-rater model intervals
#'
#' @param object A result from [fit_mfrm_random_rater()]. Profiling requires
#'   estimated rater SD.
#' @param parm `"rater_sd"` (default) profiles population variation.
#'   `"raters"` explicitly requests first-order normal prediction intervals
#'   for all observed raters. These are not supplied automatically because
#'   their nominal coverage is not established.
#'   `"calibration"` explicitly requests observed-information normal
#'   approximations for fixed-facet levels and steps, excluding population SDs.
#' @param level Confidence level, between zero and one; default 0.95.
#' @param ... Unused.
#' @return A one-row matrix with `Lower` and `Upper`, and attributes `level`,
#'   `method`, `profile` and `note`. The profile retains every evaluated SD,
#'   refitted likelihood and numerical checks. Unresolved profiles stop with an
#'   explanatory error rather than substituting a Wald interval.
#'   With `parm = "raters"`, one row per rater, computed from saved estimates
#'   and `PredictionSE` without refitting or RTMB. Attributes retain the method,
#'   target, level and interpretation. Unresolved numerical/information checks,
#'   estimated variance boundaries and unavailable SEs give missing bounds.
#'   With `parm = "calibration"`, one row per fixed-facet level or step,
#'   with the same level/method/target/note attributes and availability guards.
#'   Default calibration tables omit bounds; this explicit calculation uses
#'   saved SEs without refitting and does not establish finite-sample coverage.
#' @details For `parm = "rater_sd"`, fixed facets, steps and any estimated
#'   ability SD are refitted at
#'   each candidate rater SD, including zero. A specified known ability SD
#'   stays fixed. Earlier saved fits retain their known N(0,1) population. The interval is the connected profile region around the fitted SD
#'   satisfying twice the log-likelihood loss no greater than
#'   `qchisq(level, df = 1)`. It uses the same approximate marginal likelihood as
#'   the fit. The lower bound is zero when the zero-variance submodel belongs
#'   to this region. An estimated boundary can therefore have a positive upper
#'   limit even though ordinary Wald intervals are unavailable.
#'
#'   This is an asymptotic likelihood-ratio interval, not a finite-sample coverage
#'   guarantee. The chi-square reference is nonregular at a true zero variance;
#'   the usual one-degree-of-freedom cutoff is conservative under the standard
#'   single-variance boundary asymptotics. Few raters, Laplace error and design
#'   misspecification can alter coverage. The numerical checks do not establish
#'   those asymptotic conditions. The calculation stops if the fitted or profiled
#'   ability variance is an estimated zero boundary; that additional nuisance
#'   boundary needs a different qualification. No ability-SD interval is supplied.
#'   This interval does not quantify the predictive
#'   distribution of a replacement rater, whose variation is a different target.
#'
#'   The separate `parm = "raters"` calculation uses the conditional mode plus
#'   or minus `qnorm((1 + level)/2) * PredictionSE`. It targets realized,
#'   uncentered rater effects relative to the population mean. First-order
#'   calibration uncertainty does not ensure nominal coverage. In particular,
#'   few-rater coverage remains unresolved; see
#'   `vignette("mfrmr-random-raters")`. Requesting this approximation does not
#'   make it qualified for classification or exclusion of raters. It is not a
#'   profile interval, a bootstrap or an interval for a difference of raters.
#' @references Self, S. G. and Liang, K.-Y. (1987). Asymptotic properties of
#'   maximum likelihood estimators and likelihood ratio tests under nonstandard
#'   conditions. *Journal of the American Statistical Association*, 82, 605--610.
#'   \doi{10.1080/01621459.1987.10478472}.
#' @export
confint.mfrm_random_rater <- function(object, parm = "rater_sd", level = .95, ...) {
  rlang::check_dots_empty()
  if (!identical(parm, "rater_sd") && !identical(parm, "raters") && !identical(parm, "calibration")) stop("Choose parm = 'rater_sd', 'raters' or 'calibration'.", call. = FALSE)
  if (!is.numeric(level) || is.complex(level) || length(level) != 1L ||
      !is.finite(level) || level <= 0 || level >= 1) stop("Supply 0 < level < 1.", call. = FALSE)
  if (identical(parm, "calibration")) return(mfrm_extended_calibration_confint(object, level))
  if (identical(parm, "raters")) {
    se <- object$raters$PredictionSE
    if (!isTRUE(object$checks$NumericalReady) || !isTRUE(object$checks$InformationPositive) ||
        isTRUE(object$checks$EstimatedVarianceBoundary) ||
        isTRUE(object$checks$EstimatedPersonVarianceBoundary)) se[] <- NA_real_
    se[!is.finite(se) | se < 0] <- NA_real_
    bounds <- object$raters$Estimate + stats::qnorm((1 + level) / 2) * cbind(Lower = -se, Upper = se)
    rownames(bounds) <- object$raters$Rater
    return(structure(bounds, level = level, method = "First-order normal prediction approximation",
      target = "Realized uncentered rater effects relative to the population mean",
      note = "Nominal coverage is not established. Explicit approximation only; not a rater-quality classification or a rater-difference interval."))
  }
  if (!is.null(object$settings$fixed_rater_sd)) stop("The rater SD was fixed, not estimated.", call. = FALSE)
  if (!isTRUE(object$checks$NumericalReady) || !isTRUE(object$checks$InformationPositive)) {
    stop("Resolve the fit's numerical and information checks before profiling.", call. = FALSE)
  }
  fixed_person_sd <- mfrm_random_rater_fixed_person_sd(object)
  if (isTRUE(object$checks$EstimatedPersonVarianceBoundary)) {
    stop("Rater-SD profiling is unavailable at an estimated Person variance boundary; the nuisance-boundary reference is not qualified.", call. = FALSE)
  }
  if (!is.null(fixed_person_sd)) {
    low <- mfrm_random_rater_objective(object$input, object$settings$quad_points,
      fixed_person_sd = fixed_person_sd)
    high <- mfrm_random_rater_objective(object$input, 2L * object$settings$quad_points + 1L,
      fixed_person_sd = fixed_person_sd)
    start <- c(object$calibration$beta, object$calibration$steps)
  }
  target <- -object$loglik + stats::qchisq(level, 1) / 2
  records <- list()
  evaluate <- function(sd) {
    key <- sprintf("%.17g", sd)
    if (!is.null(records[[key]])) return(records[[key]]$NLL - target)
    if (is.null(fixed_person_sd)) {
      refit <- mfrm_random_rater_fit(object$input, object$settings$quad_points,
        fixed_sd = sd, maxit = object$settings$maxit, fixed_person_sd = NULL,
        person_variance_max = object$settings$person_variance_max)
      nll <- -refit$loglik
      checks <- refit$checks
      good <- isTRUE(checks$NumericalReady) && isTRUE(checks$InformationPositive) &&
        !isTRUE(checks$EstimatedPersonVarianceBoundary)
      records[[key]] <<- data.frame(SD = sd, NLL = nll, PersonSD = refit$calibration$person_sd,
        EstimatedPersonVarianceBoundary = checks$EstimatedPersonVarianceBoundary,
        OptimizerCode = checks$OptimizerCode, MaxGradient = checks$MaxGradient,
        LogLikDifference = checks$LogLikDifference, GradientDifference = checks$GradientDifference,
        NumericalReady = good)
    } else {
      fn <- function(p) as.numeric(low$fn(c(p, sd)))
      gr <- function(p) head(as.vector(low$gr(c(p, sd))), length(start))
      opt <- stats::nlminb(start, fn, gr,
        control = list(iter.max = object$settings$maxit, eval.max = 3L * object$settings$maxit,
          rel.tol = 1e-12, x.tol = 1e-10))
      if (opt$convergence != 0L || max(abs(gr(opt$par))) >= 1e-4) {
        proposal <- mfrm_optimizer_curvature_proposal(opt$par, fn, gr)
        if (!is.null(proposal$par)) opt <- stats::nlminb(proposal$par, fn, gr,
          control = list(iter.max = object$settings$maxit, eval.max = 3L * object$settings$maxit,
            rel.tol = 1e-12, x.tol = 1e-10))
      }
      nll <- fn(opt$par); gradient <- gr(opt$par)
      high_nll <- as.numeric(high$fn(c(opt$par, sd)))
      high_gradient <- head(as.vector(high$gr(c(opt$par, sd))), length(start))
      good <- opt$convergence == 0L && max(abs(gradient)) < 1e-4 &&
        abs(high_nll - nll) < 1e-5 && max(abs(high_gradient - gradient)) < 1e-4
      records[[key]] <<- data.frame(SD = sd, NLL = nll, OptimizerCode = opt$convergence,
        MaxGradient = max(abs(gradient)),
        LogLikDifference = abs(high_nll - nll), GradientDifference = max(abs(high_gradient - gradient)),
        NumericalReady = good)
      records[[key]]$PersonSD <<- fixed_person_sd
      records[[key]]$EstimatedPersonVarianceBoundary <<- FALSE
    }
    if (!good) rlang::abort(paste0("Profile numerical checks failed at rater SD ", signif(sd, 5),
      ". Review integration, optimization, information and any estimated Person-variance boundary before interpreting limits."),
      class = "mfrm_profile_error", profile = do.call(rbind, records))
    if (nll < -object$loglik - 1e-5) stop("The profile found a better likelihood than the source fit; refit before interpreting limits.", call. = FALSE)
    nll - target
  }
  estimate <- object$calibration$rater_sd
  at_zero <- evaluate(0)
  lower <- if (at_zero <= 0) 0 else stats::uniroot(evaluate, c(0, estimate), tol = 1e-5)$root
  upper <- max(.25, estimate * 1.5)
  for (i in 1:12) {
    if (evaluate(upper) >= 0) break
    upper <- upper * 2
  }
  if (evaluate(upper) < 0) stop("No upper profile crossing was found within the search range; no finite limit is reported.", call. = FALSE)
  upper <- stats::uniroot(evaluate, c(estimate, upper), tol = 1e-5)$root
  profile <- do.call(rbind, records); rownames(profile) <- NULL
  profile <- profile[order(profile$SD), ]
  structure(matrix(c(lower, upper), 1L, dimnames = list("rater_sd", c("Lower", "Upper"))),
    level = level, method = "Approximate marginal profile likelihood; chi-square(1) cutoff",
    profile = profile, note = "Boundary and small-rater coverage is not guaranteed; limits are not replacement-rater prediction intervals.")
}

# Strip automatic endpoints from current and earlier saved fits consistently.
mfrm_random_rater_table <- function(object, intervals = "none") {
  tab <- object$raters
  tab$Lower <- tab$Upper <- rep(NA_real_, nrow(tab))
  if (identical(intervals, "normal")) {
    bounds <- confint(object, parm = "raters")
    tab$Lower <- bounds[, "Lower"]; tab$Upper <- bounds[, "Upper"]
  }
  tab
}
