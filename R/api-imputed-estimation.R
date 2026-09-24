#' Fit the same MFRM to every completed rating data set
#'
#' Fit a separate MFRM to each completed version of the ratings reviewed by
#' [mfrm_response_imputations()]. All fits use the same model and measurement
#' scale so eligible estimates can be combined with [pool_mfrm_imputed()].
#' Failed fits and their messages are retained for review.
#'
#' @param x An [mfrm_response_imputations()] object.
#' @param model `"RSM"` or `"PCM"`.
#' @param step_facet Required for PCM: the facet with separate step parameters.
#' @param ... Shared [fit_mfrm()] arguments, such as `quad_points`, `anchors`,
#'   `facet_interactions` or optimizer controls. They must be named. Data
#'   columns, category scale and MML identification are set by this workflow.
#'   Observation weights, latent regression, shrinkage, checkpointing and
#'   adaptive integration are not supported by this workflow.
#'
#' @return An `mfrm_imputed_fits` object with the `imputations` review, all
#'   `fits` (including `NULL` for failures), `analysis_summary` recording every
#'   fit's status, error and warnings, and common `settings`. Use
#'   [pool_mfrm_imputed()] for eligible non-person facet targets.
#'
#' @details Every fit uses the same original category ladder, facet levels,
#'   anchors and other supplied constraints, with fixed-standard-normal person
#'   MML identification. `keep_original = TRUE` prevents per-completion category
#'   collapsing. An unsupported category contrast, insufficient observed
#'   information or failed optimization is retained as a failed or ineligible
#'   analysis; subsequent pooling requires every imputation to qualify.
#'
#' A common coordinate system does not establish model adequacy. Review the
#'   imputation model, rating design and numerical integration. The fit objects
#'   retain conditional person scores for individual review; those EAPs and
#'   posterior SDs are not ordinary complete-data parameter estimates and
#'   standard errors for Rubin pooling.
#'
#' @seealso [mfrm_response_imputations()], [pool_mfrm_imputed()]
#' @export
fit_mfrm_imputed <- function(x, model = c("RSM", "PCM"), step_facet = NULL, ...) {
  model <- match.arg(model)
  if (!inherits(x, "mfrm_response_imputations")) {
    stop("`x` must come from mfrm_response_imputations().", call. = FALSE)
  }
  s <- x$settings
  x <- mfrm_response_imputations(x$data, x$completed, s$person, s$facets, s$score,
    s$event_id, x$events$ID[x$events$Imputed], s$categories, s$assigned,
    x$imputation_model, s$missing)
  if ((model == "PCM" && (length(step_facet) != 1L || is.na(step_facet) ||
      !step_facet %in% s$facets)) || (model == "RSM" && !is.null(step_facet))) {
    stop("Supply an explicit model facet as `step_facet` for PCM only.", call. = FALSE)
  }
  dots <- list(...)
  blocked <- c("data", "person", "facets", "score", "rating_min", "rating_max",
    "keep_original", "missing_codes", "method", "weight", "population_formula",
    "person_data", "person_id", "population_policy", "facet_shrinkage",
    "facet_prior_sd", "shrink_person", "checkpoint", "gpcm_mml_identification",
    "slope_facet", "mml_integration", "attach_diagnostics")
  allowed <- setdiff(names(formals(fit_mfrm)), c(blocked, "model", "step_facet"))
  if (length(dots) && (is.null(names(dots)) || anyNA(names(dots)) ||
      any(!nzchar(names(dots))) || anyDuplicated(names(dots)) ||
      any(!names(dots) %in% allowed))) {
    stop("Use named, supported shared fitting controls; the workflow fixes data, scale and MML identification.", call. = FALSE)
  }
  arguments <- c(list(person = s$person, facets = s$facets, score = s$score,
    rating_min = min(s$categories), rating_max = max(s$categories), keep_original = TRUE,
    model = model, method = "MML", step_facet = step_facet,
    mml_integration = "fixed", attach_diagnostics = FALSE), dots)
  fits <- vector("list", length(x$completed))
  runs <- vector("list", length(fits))
  rows <- x$events$Assigned & !x$events$Omitted
  for (i in seq_along(fits)) {
    warning_text <- character()
    error_text <- ""
    fit <- tryCatch(withCallingHandlers(
      do.call(fit_mfrm, c(list(data = x$completed[[i]][rows, , drop = FALSE]), arguments)),
      warning = function(w) {
        warning_text <<- c(warning_text, conditionMessage(w))
        invokeRestart("muffleWarning")
      }), error = function(e) { error_text <<- conditionMessage(e); NULL })
    fits[i] <- list(fit)
    ready <- !is.null(fit) && mfrm_inference_ready(fit)
    runs[[i]] <- data.frame(Imputation = i,
      Status = if (is.null(fit)) "failed" else if (ready) "eligible" else "review",
      InferenceReady = ready, Error = error_text,
      Warnings = paste(unique(warning_text), collapse = "\n"), stringsAsFactors = FALSE)
  }
  out <- list(imputations = x, fits = fits, analysis_summary = do.call(rbind, runs),
    settings = arguments)
  class(out) <- "mfrm_imputed_fits"
  out
}

#' @rdname fit_mfrm_imputed
#' @export
print.mfrm_imputed_fits <- function(x, ...) {
  cat("MFRM analyses of imputed assigned scores\n")
  print(x$analysis_summary[, c("Imputation", "Status"), drop = FALSE], row.names = FALSE)
  if (any(nzchar(x$analysis_summary$Warnings)) || any(nzchar(x$analysis_summary$Error))) {
    cat("Fit warnings and errors are retained in analysis_summary; review them before pooling.\n")
  }
  cat("Person EAPs and posterior SDs are not Rubin-pooled parameter inference.\n")
  invisible(x)
}

#' @rdname fit_mfrm_imputed
#' @param object An object returned by `fit_mfrm_imputed()`.
#' @export
summary.mfrm_imputed_fits <- function(object, ...) object$analysis_summary

#' Pool common facet targets across imputed rating analyses
#'
#' Combine results such as rater severity or a prespecified difference between
#' raters across completed-data fits. Rubin's rules include uncertainty within
#' each fit and variation between imputations. The calculation uses the full
#' covariance for one non-Person facet; it does not pool Person ability scores.
#'
#' @param x Output from [fit_mfrm_imputed()]. All completions must have
#'   inference-ready RSM/PCM MML fits and unregularized observed information.
#' @param facet A non-person facet column name, for example `"Rater"`.
#' @param contrasts Optional numeric matrix with one named row per target and
#'   columns named by all facet levels. For example, a row with coefficients
#'   `c(1, -1, 0)` estimates the first rater minus the second. Without it,
#'   each facet level is reported. Columns are aligned by level, not position.
#' @param ci_level Confidence level, strictly between zero and one.
#' @param df_complete Complete-data degrees of freedom, a positive number or
#'   `Inf` (default). `Inf` uses the large-sample complete-data approximation.
#'   A finite value applies the Barnard--Rubin adjustment. No residual degrees
#'   of freedom are inferred from rating-row counts: ratings within a person
#'   are not independent sampling units. A supplied finite value requires a
#'   defensible complete-data reference distribution for the chosen target.
#'
#' @return An `mfrm_pooled` object containing `table`, `within`, `between`
#'   and `total` covariance matrices, `estimates` by imputation, each
#'   `complete_covariance`, the exact `contrasts`, `facet_levels`, `settings`
#'   and source `analyses`. `MonteCarloSE` is the estimated Monte Carlo SE of
#'   the pooled point estimate, `sqrt(B / m)`; it is not its inferential SE.
#'   `MissingVarianceFraction` is `(1 + 1/m) B / T`, not the raw missing-rate.
#'   Fixed targets retain their value and zero variance, but no inferential
#'   interval or degrees of freedom. No imputation is omitted.
#'
#' @details For a common target, `Qbar` is the mean completed-data estimate,
#'   `Ubar` the mean complete-data covariance and `B` their between-imputation
#'   covariance. The total is `T = Ubar + (1 + 1/m) B`. The scalar t-reference
#'   degrees of freedom are `(m - 1) / lambda^2`, with
#'   `lambda = (1 + 1/m) B / T`, before any finite complete-data adjustment.
#'   A zero between-imputation variance has infinite large-sample degrees of
#'   freedom. Full covariances are transformed before scalar inference, so
#'   rater differences include covariance between the two estimates.
#'
#' All fits must share categories, facet levels, signs, anchors, interactions
#' and identification. Known anchors are fixed and their uncertainty is
#' excluded. Singular or regularized free-parameter information and any
#' failed/ineligible completion prevent pooling. A target fixed by a constraint
#' is labelled `"fixed"`; it is not evidence of perfect precision.
#'
#' The intervals are pointwise model-based multiple-imputation intervals,
#' conditional on adequate proper imputations and complete-data inference.
#' They are not robust intervals, simultaneous rater decisions or general
#' coverage guarantees. Do not pool EAPs, posterior SDs, fit statistics, cluster
#' labels or likelihood-ratio tests with this function. See the executable
#' assigned-score example in `vignette("mfrmr-response-imputation")`.
#' It compares joint RSM predictive completions with direct observed-score
#' inference. Proper calibration priors in the imputer and MML estimates in
#' the completed-data analyses do not give exactly identical Bayesian moments:
#' that interpretation is a large-sample approximation requiring review.
#'
#' Congeniality concerns the imputation distribution and the complete-data
#' analysis together, including its variance estimator. Preserving categories
#' or including coefficient uncertainty in an ordinal imputer does not prove
#' congeniality with an adjacent-category MFRM. Under incompatibility or model
#' misspecification, Rubin intervals can be too narrow or too wide.
#' Bootstrapping only the imputation-model training data, then completing and
#' analyzing the original roster, is not bootstrap inference for the whole
#' MI analysis. Bartlett and Hughes (2020) study the latter; their results
#' require conditions including a consistent point estimator and appropriate
#' resampling units. This function implements Rubin pooling, not that outer
#' bootstrap procedure.
#'
#' @section Bounded evaluation:
#' A joint-RSM imputation example was examined using 200 independent datasets,
#' each analyzed with MAR and low-score-dependent MNAR missingness. The design
#' had 80 Persons, three fixed raters, two criteria, scores 0--2, forty
#' completions and a correctly specified known N(0,1) Person distribution.
#' Under MAR, fixed-rater contrast coverage was 96.5 percent among 198 available
#' nominal 95 percent intervals (95 percent Monte Carlo bounds 92.9--98.6).
#' Two imputation posteriors missed the sampling-diagnostic threshold; counting
#' them as unsuccessful gives 191/200 available-and-covered trials (95.5 percent).
#' Under MNAR, coverage was 26.0 percent (Monte Carlo bounds 20.1--32.7) and
#' bias was +0.574 logits, although both missing fractions were near 14 percent.
#' The MAR imputer cannot correct selection depending on missing scores.
#' These results concern that imputer, contrast and design, not arbitrary
#' supplied completions or general coverage. See the assigned-score vignette
#' for direct-MML/Bayesian comparisons, interval widths and failure accounting.
#'
#' @references Rubin, D. B. (1987). *Multiple Imputation for Nonresponse in
#'   Surveys*. Wiley. Barnard, J. and Rubin, D. B. (1999). Small-sample degrees
#'   of freedom with multiple imputation. *Biometrika*, 86, 948--955.
#'   \doi{10.1093/biomet/86.4.948}.
#'
#'   Bartlett, J. W. and Hughes, R. A. (2020). Bootstrap inference for multiple
#'   imputation under uncongeniality and misspecification.
#'   *Statistical Methods in Medical Research*, 29, 3533--3546.
#'   \doi{10.1177/0962280220932189}.
#' @seealso [mice::pool.scalar()], [mfrm_response_imputations()], [fit_mfrm_imputed()]
#' @export
pool_mfrm_imputed <- function(x, facet, contrasts = NULL, ci_level = 0.95,
                             df_complete = Inf) {
  if (!inherits(x, "mfrm_imputed_fits") || length(x$fits) < 2L ||
      length(x$fits) != length(x$imputations$completed)) {
    stop("`x` must retain every analysis from fit_mfrm_imputed().", call. = FALSE)
  }
  if (!is.character(facet) || length(facet) != 1L || is.na(facet) ||
      !facet %in% x$imputations$settings$facets) {
    stop("`facet` must name a non-person model facet; person EAPs cannot be Rubin-pooled here.", call. = FALSE)
  }
  if (!is.numeric(ci_level) || is.complex(ci_level) || length(ci_level) != 1L ||
      !is.finite(ci_level) || ci_level <= 0 || ci_level >= 1 ||
      !is.numeric(df_complete) || is.complex(df_complete) || length(df_complete) != 1L ||
      is.na(df_complete) || df_complete <= 0) {
    stop("Supply 0 < ci_level < 1 and positive df_complete (or Inf).", call. = FALSE)
  }
  eligible <- vapply(x$fits, function(f) inherits(f, "mfrm_fit") &&
    identical(f$config$method, "MML") && f$config$model %in% c("RSM", "PCM") &&
    !isTRUE(f$config$population_spec$active) && !mfrmr_adaptive_integration(f$config) &&
    mfrm_inference_ready(f), logical(1))
  if (!all(eligible)) {
    stop("All imputations must have eligible fixed-standard-normal MML fits. Review imputation(s): ",
      paste(which(!eligible), collapse = ", "), ". No imputations were discarded.", call. = FALSE)
  }
  reference <- x$fits[[1L]]
  signature <- function(f) mfrm_checkpoint_objective_components(list(), f$config)$model
  if (!all(vapply(x$fits, function(f) identical(signature(f), signature(reference)), logical(1)))) {
    stop("Fits must share one category scale, facet levels, constraints and model specification.", call. = FALSE)
  }
  s <- x$imputations$settings
  rows <- x$imputations$events$Assigned & !x$imputations$events$Omitted
  for (i in seq_along(x$fits)) {
    prep <- prepare_mfrm_data(x$imputations$completed[[i]][rows, , drop = FALSE],
      s$person, s$facets, s$score, min(s$categories), max(s$categories), keep_original = TRUE)
    if (!identical(prep$data, x$fits[[i]]$prep$data) ||
        !identical(prep$score_map, x$fits[[i]]$prep$score_map)) {
      stop("The fitted data do not match completion ", i, ". Recreate the analyses from their imputations.", call. = FALSE)
    }
  }
  target <- mfrm_facet_contrasts(reference, facet, contrasts)
  labels <- target$labels
  contrasts <- target$contrasts
  jac <- target$jacobian
  fixed <- target$fixed
  fixed_value <- target$constant
  m <- length(x$fits)
  q <- matrix(NA_real_, m, nrow(contrasts), dimnames = list(seq_len(m), rownames(contrasts)))
  u <- vector("list", m)
  for (i in seq_len(m)) {
    f <- x$fits[[i]]
    covariance <- compute_mml_parameter_covariance(f)
    if (!identical(covariance$status, "ok") || is.null(covariance$cov) ||
        any(!is.finite(covariance$cov)) ||
        is.null(tryCatch(chol(covariance$cov), error = function(e) NULL))) {
      stop("Imputation ", i, " requires unregularized positive-definite observed-information covariance.", call. = FALSE)
    }
    expanded <- expand_params(f$opt$par, covariance$sizes, f$config)$facets[[facet]]
    q[i, ] <- drop(contrasts %*% expanded)
    q[i, fixed] <- fixed_value[fixed]
    slice <- covariance$param_slices[[facet]]
    u[[i]] <- symmetrize_matrix(jac %*% covariance$cov[slice, slice, drop = FALSE] %*% t(jac))
    if (any(!is.finite(q[i, ])) || any(!is.finite(u[[i]])) || any(diag(u[[i]])[!fixed] <= 0)) {
      stop("Imputation ", i, " has unavailable estimates or nonpositive variance for a free target.", call. = FALSE)
    }
  }
  within <- Reduce(`+`, u) / m
  between <- stats::cov(q)
  total <- within + (1 + 1 / m) * between
  estimate <- colMeans(q)
  variance <- diag(total)
  if (any(!is.finite(total))) {
    stop("The pooled covariance is not finite; review the target coefficients and completed estimates.", call. = FALSE)
  }
  lambda <- ifelse(fixed, NA_real_, (1 + 1 / m) * diag(between) / variance)
  df <- (m - 1) / lambda^2
  if (is.finite(df_complete)) {
    df_observed <- (df_complete + 1) / (df_complete + 3) * df_complete * (1 - lambda)
    df <- 1 / (1 / df + 1 / df_observed)
  }
  se <- sqrt(variance)
  margin <- stats::qt(1 - (1 - ci_level) / 2, df) * se
  result <- data.frame(Target = colnames(q), Estimate = estimate, SE = se,
    Lower = estimate - margin, Upper = estimate + margin, DF = df,
    WithinVariance = diag(within), BetweenVariance = diag(between),
    TotalVariance = variance, MissingVarianceFraction = lambda,
    MonteCarloSE = sqrt(diag(between) / m),
    Status = ifelse(fixed, "fixed", "pooled"), row.names = NULL)
  out <- list(table = result, within = within, between = between, total = total,
    estimates = q, complete_covariance = u, contrasts = contrasts, facet_levels = labels,
    settings = list(facet = facet, imputations = m, ci_level = ci_level,
      df_complete = df_complete, scale = "logits; fixed-standard-normal person distribution",
      covariance = "MML observed information", intervals = "pointwise multiple-imputation t intervals"),
    analyses = x)
  class(out) <- "mfrm_pooled"
  out
}

#' @rdname pool_mfrm_imputed
#' @param ... Unused.
#' @export
print.mfrm_pooled <- function(x, ...) {
  cat("Pooled", x$settings$facet, "targets across", x$settings$imputations, "imputations\n")
  print(x$table, row.names = FALSE)
  cat("Pointwise model-based intervals; fixed anchors exclude anchor uncertainty.\n")
  if (is.infinite(x$settings$df_complete)) cat("Large-sample complete-data reference assumed.\n")
  invisible(x)
}

#' @rdname pool_mfrm_imputed
#' @param object An object returned by `pool_mfrm_imputed()`.
#' @export
summary.mfrm_pooled <- function(object, ...) object$table
