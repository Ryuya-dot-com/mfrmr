#' @section Common-plan Person expected-score intervals (`confint.mfrm_fair_average`):
#' Compute experimental fixed-Person parametric `"refit"` or two-stage `"delta"`
#' intervals, or conservative finite-sample `"bounded"` Hoeffding intervals, on
#' `fair_average_table(..., reference_plan = ...)` outputs from unit-weight
#' additive RSM/PCM JML (ordinary or `jml_penalty = "jeffreys"`).
#'
#' @param object For `confint()` / `summary()`, output from
#'   [fair_average_table()] with `reference_plan`, or a saved
#'   `mfrm_fair_intervals` object.
#' @param parm Person IDs (`NULL` selects all).
#' @param level Pointwise confidence level in `(0, 1)` and joint
#'   binomial order-statistic Monte Carlo endpoint-enclosure level (`0.95`
#'   default for `method = "refit"`).
#' @param mc_level Pointwise confidence level in `(0, 1)` and joint
#'   binomial order-statistic Monte Carlo endpoint-enclosure level (`0.95`
#'   default for `method = "refit"`).
#' @param nsim Replication count (`>= 2`) and seed for `method = "refit"`
#'   (unresolved refits remain in the planned denominator as `+/-Inf`, yielding
#'   `Status = "unresolved_tail"` when tail quantiles are unbounded).
#' @param seed Replication count (`>= 2`) and seed for `method = "refit"`
#'   (unresolved refits remain in the planned denominator as `+/-Inf`, yielding
#'   `Status = "unresolved_tail"` when tail quantiles are unbounded).
#' @param method `"refit"` (whole calibration-to-anchor-to-scoring parametric
#'   bootstrap basic limits), `"delta"` (analytic two-stage event-covariance
#'   propagation), or `"bounded"` (Hoeffding inequality on declared
#'   `rating_min:rating_max` with `category_policy = "preserve"`).
#' @param generator_method For `"refit"`, `"ordinary"` or `"jeffreys"`
#'   (\eqn{-\ell(b) - \tfrac12\log|I(b)|} generator).
#' @param contrasts Optional named zero-sum Person contrast matrix.
#' @param ... Unused; must be empty.
#' @param anchor_source Two-stage
#'   anchor-provenance fits, union-event index map (`list(calibration = ...,
#'   scoring = ...)`), anchor treatment (`"estimated"` vs `"fixed"`), and
#'   stationarity tolerance (`1e-4` default).
#' @param generating_fit Two-stage
#'   anchor-provenance fits, union-event index map (`list(calibration = ...,
#'   scoring = ...)`), anchor treatment (`"estimated"` vs `"fixed"`), and
#'   stationarity tolerance (`1e-4` default).
#' @param response_map Two-stage
#'   anchor-provenance fits, union-event index map (`list(calibration = ...,
#'   scoring = ...)`), anchor treatment (`"estimated"` vs `"fixed"`), and
#'   stationarity tolerance (`1e-4` default).
#' @param anchor_uncertainty Two-stage
#'   anchor-provenance fits, union-event index map (`list(calibration = ...,
#'   scoring = ...)`), anchor treatment (`"estimated"` vs `"fixed"`), and
#'   stationarity tolerance (`1e-4` default).
#' @param gradient_tol Two-stage
#'   anchor-provenance fits, union-event index map (`list(calibration = ...,
#'   scoring = ...)`), anchor treatment (`"estimated"` vs `"fixed"`), and
#'   stationarity tolerance (`1e-4` default).
#'
#' @details
#' **Two-stage delta and bounded formulas.** For stage Jacobians \eqn{H_c, H_s},
#' anchor map \eqn{A = \partial a/\partial b_c}, cross-derivative \eqn{B}, and
#' target derivatives \eqn{G_s, G_a}, union-event loadings are
#' \eqn{U_s = X_s H_s^{-1}G_s^\top} and
#' \eqn{U_c = X_c H_c^{-1}A^\top(G_a - G_s H_s^{-1}B)^\top} with categorical
#' covariance \eqn{V = \sum_e \mathrm{Cov}_{p_{g,e}}(U_s + U_c)} (Murphy &
#' Topel, 1985; `CIEligible = FALSE` pending short-exposure qualification). For
#' `"bounded"`, signed event weights \eqn{a_e} on scores in \eqn{[l, u]} have
#' Hoeffding radius \eqn{r = \sqrt{\tfrac12\log(2/\alpha)\sum_e a_e^2(u - l)^2}}
#' (`CIEligible = TRUE`, `Informative` flags bounds narrower than the full
#' rubric range; Hoeffding, 1963).
#'
#' @aliases confint.mfrm_fair_average summary.mfrm_fair_intervals
#' @rdname fair_average_table
#' @examples
#' # Long-running workflow; run explicitly when needed.
#' # example("confint.mfrm_fair_average", run.dontrun = TRUE)
#' \dontrun{
#' d <- load_mfrmr_data("example_core")
#' # Calibrate the observed ratings with ordinary joint maximum likelihood.
#' f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
#'   method = "JML", rating_min = 1, rating_max = 4, category_policy = "preserve",
#'   optimizer = "BFGS", maxit = 500, reltol = 1e-11)
#' # The bundled example's rubric is 1--4; declare it independently of sample extrema.
#' # Every Person is evaluated against these same Rater-Criterion cells.
#' plan <- unique(d[c("Rater", "Criterion")])
#' fair <- fair_average_table(f, reference_plan = plan)
#' head(fair$reference_scores) # Expected average, in internal score units.
#' # Two replications exercise the API only; they cannot qualify coverage.
#' # Explicit experimental generator; points and every refit remain ordinary JML.
#' ci <- confint(fair, parm = c("P001", "P002"), nsim = 2, seed = 71,
#'   generator_method = "jeffreys",
#'   contrasts = matrix(c(1, -1), 1,
#'     dimnames = list("P001 minus P002", c("P001", "P002"))))
#' summary(ci) # Read Status and Available alongside the limits.
#' attr(ci, "trials") # Includes unresolved refits and their reasons.
#' attr(ci, "monte_carlo") # Infinite enclosures expose the two-draw tail uncertainty.
#' plot(ci, draw = FALSE) # Saved plotting data, including the cautions.
#' # Deterministic local approximation to the same expected-score target:
#' delta <- confint(fair, parm = c("P001", "P002"), method = "delta")
#' delta[, c("Target", "Estimate", "SE", "Available", "CIEligible")]
#' attr(delta, "covariance") # Includes the covariance between Persons.
#' # Conservative alternative with explicit observed/unobserved plan support:
#' bounded <- confint(fair, parm = c("P001", "P002"), method = "bounded")
#' bounded[, c("Target", "Estimate", "DesignEstimate", "CI_Lower", "CI_Upper", "Informative")]
#' attr(bounded, "support") # Check how much of the plan was actually observed.
#' }
#' @export
#' @order 1
confint.mfrm_fair_average <- function(object, parm = NULL, level = .95,
    nsim, seed, contrasts = NULL, anchor_source = NULL, generating_fit = NULL,
    response_map = NULL, anchor_uncertainty = c("estimated", "fixed"),
    gradient_tol = 1e-4, method = c("refit", "delta", "bounded"),
    generator_method = c("ordinary", "jeffreys"), mc_level = .95, ...) {
  rlang::check_dots_empty()
  anchor_uncertainty_supplied <- !missing(anchor_uncertainty)
  anchor_uncertainty <- match.arg(anchor_uncertainty)
  method <- match.arg(method)
  generator_method_supplied <- !missing(generator_method)
  if (method != "refit" && !missing(generator_method))
    stop("`generator_method` applies only to method = 'refit'.", call. = FALSE)
  generator_method <- match.arg(generator_method)
  scalar <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x)
  if (!scalar(level) || level <= 0 || level >= 1) stop("`level` must be in (0, 1).", call. = FALSE)
  if (method != "refit" && !missing(mc_level))
    stop("`mc_level` applies only to method = 'refit'.", call. = FALSE)
  if (!scalar(mc_level) || mc_level <= 0 || mc_level >= 1)
    stop("`mc_level` must be in (0, 1).", call. = FALSE)
  if (method == "refit" && (missing(nsim) || !scalar(nsim) || nsim < 2 || nsim != floor(nsim) || nsim > .Machine$integer.max))
    stop("Supply an integer `nsim` of at least two.", call. = FALSE)
  if (method == "refit" && (missing(seed) || !scalar(seed) || seed < 0 || seed != floor(seed) || seed > .Machine$integer.max))
    stop("Supply a nonnegative integer `seed`.", call. = FALSE)
  if (method != "refit" && (!missing(nsim) || !missing(seed)))
    stop("`nsim` and `seed` apply only to method = 'refit'; omit them for deterministic intervals.", call. = FALSE)
  if (!scalar(gradient_tol) || gradient_tol <= 0) stop("`gradient_tol` must be positive.", call. = FALSE)
  fit <- object$reference_fit; plan <- object$reference_plan
  if (is.null(fit) || is.null(plan))
    stop("Recreate fair_average_table() with an explicit reference_plan.", call. = FALSE)
  mfrm_fair_reference_fit(fit)
  penalized <- mfrm_is_jeffreys_fit(fit)
  if (penalized && method == "refit") {
    if (generator_method_supplied && generator_method != "jeffreys")
      stop("Jeffreys point/refit estimation requires generator_method = 'jeffreys'.", call. = FALSE)
    generator_method <- "jeffreys"
  }
  if (!identical(object$reference_identity, mfrm_fair_fit_identity(fit)))
    stop("The retained reference fit changed; recreate fair_average_table().", call. = FALSE)
  plan <- mfrm_fair_reference_plan(fit, plan[setdiff(names(plan), "NormalizedWeight")])
  scores <- mfrm_fair_reference_scores(fit, plan)
  if (!isTRUE(all.equal(scores, object$reference_scores, tolerance = 1e-12)))
    stop("The retained reference plan or scores changed; recreate fair_average_table().", call. = FALSE)
  if (is.null(parm)) parm <- scores$Person
  if (!is.character(parm) || !length(parm) || anyNA(parm) || anyDuplicated(parm) ||
      any(!parm %in% scores$Person)) stop("`parm` must select distinct known Person identifiers.", call. = FALSE)
  if (is.null(contrasts)) {
    L <- diag(length(parm)); dimnames(L) <- list(parm, parm)
  } else {
    if (!is.matrix(contrasts) || !is.numeric(contrasts) || !nrow(contrasts) ||
        any(!is.finite(contrasts)) || is.null(rownames(contrasts)) ||
        anyNA(rownames(contrasts)) || any(!nzchar(rownames(contrasts))) ||
        anyDuplicated(rownames(contrasts)) || anyDuplicated(colnames(contrasts)) ||
        !setequal(colnames(contrasts), parm) ||
        any(abs(rowSums(contrasts)) > 1e-12 * pmax(1, rowSums(abs(contrasts)))) ||
        any(rowSums(abs(contrasts)) == 0))
      stop("`contrasts` needs finite nonzero, zero-sum rows and unique row/Person column names.", call. = FALSE)
    L <- contrasts[, parm, drop = FALSE]
  }
  selected <- scores$Estimate[match(parm, scores$Person)]
  estimate <- vapply(seq_len(nrow(L)), function(i) {
    use <- L[i, ] != 0
    sum(L[i, use] * selected[use])
  }, 0)
  if (method == "bounded") {
    if (!is.null(anchor_source) || !is.null(generating_fit) || !is.null(response_map) ||
        anchor_uncertainty_supplied || !missing(gradient_tol))
      stop("Bounded-response intervals use scoring responses directly; omit calibration/generator inputs, anchor_uncertainty and gradient_tol.", call. = FALSE)
    return(mfrm_fair_bounded_result(fit, plan, parm, L, estimate, level,
      has_contrasts = !is.null(contrasts)))
  }
  anchors <- fit$config$replay_inputs$anchors
  two_stage <- nrow(anchors) > 0L && anchor_uncertainty == "estimated"
  if (two_stage && is.null(anchor_source))
    stop("Estimated-anchor intervals are unavailable without the calibration fit and response-event maps. Use anchor_uncertainty = 'fixed' only for explicitly conditional inference.", call. = FALSE)
  if (!two_stage && (!is.null(anchor_source) || !is.null(response_map) || !is.null(generating_fit)))
    stop("Separate calibration/generator inputs require estimated anchors.", call. = FALSE)
  generator <- generating_fit %||% (if (two_stage) anchor_source else fit)
  sources <- if (two_stage) list(scoring = fit, calibration = anchor_source, generating = generator) else list(scoring = fit)
  source_checks <- lapply(sources, function(f) {
    mfrm_fair_reference_fit(f)
    if (!identical(mfrm_is_jeffreys_fit(f), penalized))
      stop("Calibration, scoring and generating sources must use the same estimator; ordinary and Jeffreys points cannot be mixed.", call. = FALSE)
    replay <- f$config$replay_inputs
    if (is.null(replay) || any(f$prep$data$Weight != 1) || nrow(replay$group_anchors %||% data.frame()) ||
        !identical(as.numeric(f$prep$score_map$OriginalScore), as.numeric(f$prep$score_map$InternalScore)))
      stop("Common-plan intervals require replay inputs, unit weights, identity score coding and no group anchors.", call. = FALSE)
    keys <- c("model", "n_cat", "rating_min", "rating_max", "facet_names", "facet_signs", "step_facet", "dummy_facets")
    if (!isTRUE(all.equal(f$config[keys], fit$config[keys], check.attributes = FALSE)))
      stop("Calibration, scoring and generating models/coding must agree.", call. = FALSE)
    mfrm_fair_refit_check(f, gradient_tol)
  })
  if (two_stage) {
    if (nrow(anchor_source$config$replay_inputs$anchors))
      stop("The initial two-stage route requires an unanchored calibration source.", call. = FALSE)
    values <- mfrm_fair_anchor_values(anchor_source, anchors)
    if (any(abs(values - anchors$Anchor) > 1e-10 * pmax(1, abs(values))))
      stop("Scoring anchors do not match the unrounded calibration estimates.", call. = FALSE)
    if (!is.list(response_map) || !setequal(names(response_map), c("calibration", "scoring")))
      stop("Provide explicit calibration/scoring response-event row maps.", call. = FALSE)
    maps <- list(calibration = mfrm_fair_response_map(anchor_source, generator,
      response_map$calibration, "response_map$calibration"),
      scoring = mfrm_fair_response_map(fit, generator, response_map$scoring, "response_map$scoring"))
    if (!setequal(unlist(maps), seq_len(nrow(generator$prep$data))))
      stop("The response maps must cover the generating fit's union of events.", call. = FALSE)
  } else maps <- list(scoring = seq_len(nrow(fit$prep$data)))
  generator_theta <- generator$facets$person$PrimaryEstimate %||% generator$facets$person$Estimate
  # A nonselected extreme Person makes this local approximation unavailable,
  # but must not discard finite selected points and their explicit diagnostic.
  generating_model <- if (penalized) c(generator$checks,
    list(par = generator$opt$par, probabilities = mfrm_fair_generator_probs(generator),
      parameter_map = generator$parameter_map)) else if (generator_method == "jeffreys")
    mfrm_fair_jeffreys_generator(generator, gradient_tol) else NULL
  probs <- if (!is.null(generating_model)) generating_model$probabilities else
    if (method == "delta" && any(!is.finite(generator_theta))) NULL else
      mfrm_fair_generator_probs(generator)
  if (!is.null(probs) && (any(!is.finite(probs)) || any(probs < 0) || any(abs(rowSums(probs) - 1) > 1e-10)))
    stop("Invalid generating probabilities.", call. = FALSE)
  truth_scores <- if (!is.null(generating_model))
    mfrm_fair_jeffreys_target(generator, generating_model$par, plan, parm) else {
      tab <- mfrm_fair_reference_scores(generator, plan)
      tab$Estimate[match(parm, tab$Person)]
    }
  truth <- drop(L %*% truth_scores)
  allowed_status <- if (generator_method == "jeffreys") c("point_estimate", "boundary_limit") else "point_estimate"
  if (any(!is.finite(truth)) || any(!is.finite(estimate)) ||
      any(!scores$Status[match(parm, scores$Person)] %in% allowed_status))
    stop("Selected targets require finite primary point estimates and generating targets.", call. = FALSE)
  if (method == "delta") return(mfrm_fair_delta_result(fit,
    if (two_stage) anchor_source else NULL, generator, plan, parm, L, estimate, truth,
    anchors, maps, probs, level, gradient_tol, anchor_uncertainty, sources, source_checks,
    has_contrasts = !is.null(contrasts)))
  draws <- matrix(NA_real_, nsim, nrow(L), dimnames = list(NULL, rownames(L)))
  person_draws <- matrix(NA_real_, nsim, length(parm), dimnames = list(NULL, parm))
  anchor_draws <- matrix(NA_real_, nsim, nrow(anchors),
    dimnames = list(NULL, if (nrow(anchors)) paste(anchors$Facet, anchors$Level, sep = ":") else NULL))
  trials <- data.frame(Replication = seq_len(nsim), CalibrationGradient = NA_real_,
    ScoringGradient = NA_real_, BoundaryPersons = NA_integer_, Available = FALSE,
    Reason = "", Warnings = "", Seconds = NA_real_)
  rng_kind <- RNGkind()
  with_preserved_rng_seed(seed, {
    cumulative <- t(apply(probs, 1L, cumsum))
    for (b in seq_len(nsim)) {
      started <- proc.time()[[3]]; messages <- character()
      result <- tryCatch(withCallingHandlers({
        # One variate per union EVENT, shared by both mapped stages.
        u <- stats::runif(nrow(probs))
        y <- pmin(rowSums(u > cumulative), ncol(probs) - 1L) + generator$prep$rating_min
        a <- anchors
        if (two_stage) {
          calibration <- mfrm_fair_refit(anchor_source, y[maps$calibration])
          check <- mfrm_fair_refit_check(calibration, gradient_tol)
          trials$CalibrationGradient[b] <- check$max_gradient
          a$Anchor <- mfrm_fair_anchor_values(calibration, anchors)
        }
        if (nrow(a)) anchor_draws[b, ] <- a$Anchor
        scored <- mfrm_fair_refit(fit, y[maps$scoring], a)
        check <- mfrm_fair_refit_check(scored, gradient_tol)
        trials$ScoringGradient[b] <- check$max_gradient
        s <- mfrm_fair_reference_scores(scored, plan)
        v <- s$Estimate[match(parm, s$Person)]
        status <- s$Status[match(parm, s$Person)]
        trials$BoundaryPersons[b] <- sum(status == "boundary_limit")
        v[!status %in% c("point_estimate", "boundary_limit")] <- NA_real_
        person_draws[b, ] <- v
        # Zero coefficients must not propagate irrelevant missing Persons.
        draws[b, ] <- vapply(seq_len(nrow(L)), function(j) {
          use <- L[j, ] != 0
          sum(L[j, use] * v[use])
        }, 0)
        if (all(is.finite(draws[b, ]))) "" else "Selected Person expected score unavailable."
      }, warning = function(w) {
        messages <<- c(messages, conditionMessage(w)); invokeRestart("muffleWarning")
      }), error = function(e) conditionMessage(e))
      trials$Available[b] <- all(is.finite(draws[b, ]))
      trials$Reason[b] <- result
      trials$Warnings[b] <- paste(unique(messages), collapse = " | ")
      trials$Seconds[b] <- proc.time()[[3]] - started
    }
  })
  bounds <- mfrm_fair_bootstrap_bounds(estimate, truth, draws, level)
  mc <- mfrm_fair_bootstrap_mc(estimate, bounds$roots, level, mc_level)
  mc_lower <- mc[mc$Endpoint == "lower", ]; mc_upper <- mc[mc$Endpoint == "upper", ]
  available <- is.finite(bounds$lower) & is.finite(bounds$upper)
  out <- data.frame(Target = rownames(L), Estimate = unname(estimate),
    CI_Lower = ifelse(available, bounds$lower, NA_real_),
    CI_Upper = ifelse(available, bounds$upper, NA_real_), Level = level,
    Available = available, Status = ifelse(available, "experimental", "unresolved_tail"),
    Planned = nsim, Resolved = bounds$available, Unresolved = nsim - bounds$available,
    ExpectedTailDraws = nsim * (1 - level) / 2, CIEligible = FALSE,
    LowerMCLower = mc_lower$Lower, LowerMCUpper = mc_lower$Upper,
    UpperMCLower = mc_upper$Lower, UpperMCUpper = mc_upper$Upper,
    MCLevel = mc_level, MCFinite = is.finite(mc_lower$Lower) & is.finite(mc_lower$Upper) &
      is.finite(mc_upper$Lower) & is.finite(mc_upper$Upper),
    Uncertainty = if (two_stage) "calibration_and_scoring_refit" else if (nrow(anchors))
      "scoring_refit_conditional_on_fixed_anchors" else "joint_calibration_and_person_refit",
    InferenceReview = "Experimental pointwise fitted-model approximation; finite-sample coverage and JML bias remain unqualified.",
    row.names = NULL)
  if (generator_method == "jeffreys") out$InferenceReview <- paste(out$InferenceReview,
    if (penalized) "Jeffreys estimation throughout original calibration, scoring and refits; this is not ordinary FACETS JML." else
      "Jeffreys generating model; the reported point and refits remain ordinary JML.")
  if (penalized) out$InferenceReview <- paste(out$InferenceReview,
    "Basic refit limits can substantially under-cover in small samples even with exact refit quantiles; see help.")
  attr(out, "draws") <- draws; attr(out, "person_draws") <- person_draws
  attr(out, "monte_carlo") <- mc
  attr(out, "anchor_draws") <- anchor_draws; attr(out, "trials") <- trials
  attr(out, "generating_target") <- setNames(truth, rownames(L))
  if (!is.null(generating_model)) attr(out, "generating_model") <- generating_model
  attr(out, "reference_plan") <- plan; attr(out, "response_map") <- maps
  attr(out, "source_checks") <- source_checks
  attr(out, "source_identity") <- lapply(sources, mfrm_fair_fit_identity)
  attr(out, "settings") <- list(parm = parm, contrasts = L, level = level, nsim = nsim,
    seed = seed, rng_kind = rng_kind, gradient_tol = gradient_tol, mc_level = mc_level,
    anchor_uncertainty = anchor_uncertainty, anchors = anchors,
    method = "basic_fixed_person_parametric_refit", generator_method = generator_method,
    estimator = if (penalized) "jeffreys_canonical_joint" else "ordinary_jml", quantile_type = 1L,
    target = if (is.null(contrasts)) "common_plan_expected_average" else "common_plan_expected_average_contrast",
    shared_responses = if (two_stage) length(intersect(maps$calibration, maps$scoring)) else 0L)
  class(out) <- c("mfrm_fair_intervals", "data.frame")
  out
}

#' @rdname fair_average_table
#' @export
summary.mfrm_fair_intervals <- function(object, ...) {
  rlang::check_dots_empty()
  object
}

#' @rdname fair_average_table
#' @param x For `print.mfrm_fair_intervals()`: A saved `mfrm_fair_intervals` result.
#'
#' For `plot()`: Saved output of [confint.mfrm_fair_average()].
#' @export
print.mfrm_fair_intervals <- function(x, ...) {
  bounded <- identical(attr(x, "settings")$method, "hoeffding_bounded_responses")
  cat(if (bounded) "Common-plan expected-score bounds (independent bounded responses)\n" else
    "Common-plan expected-score intervals (experimental)\n")
  print.data.frame(x, ...)
  cat(if (bounded) "Coverage requires the declared independence and fixed-plan assumptions; inspect Informative and plan support.\n" else
    "Numerical availability is separate from coverage qualification.\n")
  if (identical(attr(x, "settings")$generator_method, "jeffreys"))
    cat(if (identical(attr(x, "settings")$estimator, "jeffreys_canonical_joint"))
      "Jeffreys estimation throughout original calibration, scoring and refits.\n" else
      "Jeffreys generating model; displayed points and refits retain ordinary JML.\n")
  if (identical(attr(x, "settings")$method, "local_fixed_person_delta") &&
      identical(attr(x, "settings")$estimator, "jeffreys_canonical_joint"))
    cat("Analytic Jeffreys two-stage propagation; score bias and coverage remain unqualified.\n")
  if (!is.null(attr(x, "monte_carlo")))
    cat("Endpoint Monte Carlo enclosures measure simulation precision, not sampling coverage; MCFinite alone does not establish precision.\n")
  invisible(x)
}

#' @rdname fair_average_table
#' @details `plot()` method: Plot common-plan expected-score intervals
#' @param draw Logical; print the `ggplot` figure when `TRUE`.
#' @param show_title Logical; display title/cautions, off by default.
#' @param show_notes Logical; display title/cautions, off by default.
#' @return For `plot()`: Invisibly a `ggplot` object. [plot_data()] retains all
#'   result rows, uncertainty labels, `monte_carlo` enclosures, and `notes`.
#' @details For `plot()`: Points are common-plan expected scores or declared paired differences.
#'   Bars show only available pointwise bounds under the saved method. Missing
#'   bars are not zero uncertainty. Plotting never recalculates the fit or removes
#'   unresolved rows from the saved result. For refit results the bars show the
#'   empirical interval; endpoint Monte Carlo enclosures are retained in the
#'   returned table and `plot_data(p)$monte_carlo`, not drawn as sampling intervals. See
#'   [confint.mfrm_fair_average()] for
#'   the estimand, assumptions and finite-sample limitations.
#' @examples # Continue the confint.mfrm_fair_average() example:
#' # plot(ci)
#' # p <- plot(ci, draw = FALSE)
#' # plot_data(p, "notes")
#' @export
plot.mfrm_fair_intervals <- function(x, draw = TRUE, show_title = FALSE, show_notes = FALSE, ...) {
  rlang::check_dots_empty()
  d <- as.data.frame(x); y <- rev(seq_len(nrow(d)))
  note <- if (identical(attr(x, "settings")$method, "hoeffding_bounded_responses"))
    paste("Conservative pointwise bounds require independent bounded responses and a fixed plan.",
      "Points retain fitted estimates; inspect Informative and observed plan support. These bounds do not correct point bias.") else
    if (identical(attr(x, "settings")$method, "local_fixed_person_delta"))
    "Experimental pointwise delta intervals; absent bars mean unavailable information. Coverage is not qualified." else
    "Experimental pointwise expected-score intervals; absent bars mean unresolved tails. Coverage is not qualified."
  if (identical(attr(x, "settings")$generator_method, "jeffreys")) note <- paste(note,
    if (identical(attr(x, "settings")$estimator, "jeffreys_canonical_joint"))
      "Jeffreys estimation throughout original calibration, scoring and refits." else
      "Jeffreys generating model; points and refits retain ordinary JML.")
  if (!is.null(attr(x, "monte_carlo"))) note <- paste(note,
    "Bars show empirical limits; inspect endpoint Monte Carlo enclosures for simulation precision.")
  if (identical(attr(x, "settings")$method, "local_fixed_person_delta") &&
      identical(attr(x, "settings")$estimator, "jeffreys_canonical_joint")) note <- paste(note,
    "Analytic Jeffreys score and anchor derivatives; this is not inverse penalized curvature.")
  xlab <- if (identical(attr(x, "settings")$target, "common_plan_expected_average_contrast"))
    "Expected score contrast (internal units)" else "Expected average (internal score units)"
  out <- new_mfrm_plot_data("fair_reference_intervals", list(data = d,
    settings = attr(x, "settings"), reference_plan = attr(x, "reference_plan"),
    monte_carlo = attr(x, "monte_carlo"),
    plot_data = data.frame(Label = d$Target, X = d$Estimate, Y = y,
      Lower = d$CI_Lower, Upper = d$CI_Upper, Available = d$Available),
    notes = data.frame(Type = "uncertainty", Text = note),
    title = "Common-plan expected-score intervals", subtitle = note, xlab = xlab,
    display = list(show_title = show_title, show_notes = show_notes)))
  .mfrm_finalize_ggplot(out, draw = draw)
}
