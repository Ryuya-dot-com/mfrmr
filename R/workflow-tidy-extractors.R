# ==============================================================================
# Tidy Extractors: tidy(), glance(), augment()
# ==============================================================================

#' Tidy a Many-Facet Model or Workflow Object
#'
#' Extracts tidy `tibble` summaries of parameters, rater diagnostics, persons,
#' thresholds, GPCM discrimination slopes, dynamic rater drift, or generalizability studies.
#'
#' @param x A `tidymfrm`, `mfrm_fast_fit`, or `mfrm_fast_gtheory` object.
#' @param component Component to extract: `"raters"`, `"facets"`, `"persons"`,
#'   `"steps"`, `"slopes"`, `"g_study"`, `"d_study"`, `"dff"`, or `"drift"`.
#' @param conf.level Confidence level for Wald intervals (default `0.95`).
#' @param use_real_se Logical; if `TRUE` (default), constructs `conf.low` and
#'   `conf.high` using `RealSE` (inflated for misfit) rather than `ModelSE`.
#' @details Intervals use the public `confint()` contract, including
#'   exponentiated log-slope intervals for GPCM. When calibration is not ready,
#'   interval endpoints are `NA`; `inference_status` and `inference_reason`
#'   explain why. Point estimates and SE columns remain descriptive outputs.
#' @param ... Additional arguments (unused).
#' @return A [tibble::tibble()].
#' @examples
#' utils::data("mfrmr_example_core", package = "mfrmr")
#' wf <- mfrm_analysis(mfrmr_example_core, "Person", c("Rater", "Criterion"), "Score")
#' tidy(wf, component = "raters")
#' glance(wf)
#' head(augment(wf))
#' @export
tidy <- function(x, ...) {
  UseMethod("tidy")
}

#' Glance at a Single-Row Summary of a Many-Facet Workflow or Fit
#'
#' Returns a one-row `tibble` summarizing graph connectivity, model convergence and inference readiness,
#' information criteria, latent EAP reliability, observed-score `G` and `Phi`,
#' and flagged rater counts.
#'
#' @param x A `tidymfrm` or `mfrm_fast_fit` object.
#' @param ... Additional arguments (unused).
#' @return A single-row [tibble::tibble()]. `model` is the API code and
#'   `model_label` is the display name, including GMFRM discrimination facets.
#' @examples
#' utils::data("mfrmr_example_core", package = "mfrmr")
#' wf <- mfrm_analysis(mfrmr_example_core, "Person", c("Rater", "Criterion"), "Score")
#' glance(wf)
#' @export
glance <- function(x, ...) {
  UseMethod("glance")
}

#' Augment Observation Rows with Expected Scores and Standardized Residuals
#'
#' Appends observation-level expected rubric scores, raw and standardized Pearson
#' residuals, observed category probabilities, and unexpected-response flags
#' (`|StdResidual| >= 2.0`) to the analyzed rating rows.
#'
#' @param x A `tidymfrm` object.
#' @param ... Additional arguments (unused).
#' @return A [tibble::tibble()] of observation-level expectations and residuals.
#' @examples
#' utils::data("mfrmr_example_core", package = "mfrmr")
#' wf <- mfrm_analysis(mfrmr_example_core, "Person", c("Rater", "Criterion"), "Score")
#' head(augment(wf))
#' @export
augment <- function(x, ...) {
  UseMethod("augment")
}

#' @rdname tidy
#' @export
tidy.tidymfrm <- function(x,
                          component = c("raters", "facets", "persons", "steps", "slopes",
                                        "g_study", "d_study", "dff", "drift"),
                          conf.level = 0.95,
                          use_real_se = TRUE,
                          ...) {
  component <- match.arg(component)
  x <- .tidymfrm_refresh(x)

  if (component == "raters") {
    if (is.null(x$diagnostics)) stop("No rater diagnostics found; run `step_mfrm_diagnose()`.", call. = FALSE)
    rt <- x$diagnostics$raters
    ci <- .tidymfrm_intervals(x$fit, "facets", conf.level, use_real_se)
    ci <- ci[match(paste(rt$Facet, rt$Level), paste(x$fit$facets$Facet, x$fit$facets$Level)), , drop = FALSE]
    return(tibble::tibble(
      facet = rt$Facet,
      term = rt$Level,
      estimate = rt$Estimate,
      std.error = rt$ModelSE,
      real.se = rt$RealSE,
      conf.low = ci[, 1L], conf.high = ci[, 2L],
      inference_status = rt$InferenceStatus, inference_reason = rt$InferenceReason,
      fair_m = rt$FairM,
      infit_mnsq = rt$InfitMnSq,
      infit_zstd = rt$InfitZSTD,
      outfit_mnsq = rt$OutfitMnSq,
      outfit_zstd = rt$OutfitZSTD,
      observed_min = rt$ObservedMin,
      observed_max = rt$ObservedMax,
      at_minimum = rt$AtMinimum,
      at_maximum = rt$AtMaximum,
      score_pattern = rt$ScorePattern,
      flag = rt$DiagnosticFlag,
      action = rt$RecommendedAction
    ))
  }
  if (component %in% c("facets", "persons", "steps", "slopes")) {
    return(tidy.mfrm_fast_fit(x$fit, component = component, conf.level = conf.level, use_real_se = use_real_se))
  }
  if (component == "g_study") {
    return(x$gtheory$variance_components)
  }
  if (component == "d_study") {
    return(x$gtheory$d_study)
  }
  if (component == "dff") {
    if (is.null(x$diagnostics$dff)) return(tibble::tibble())
    return(x$diagnostics$dff)
  }
  if (component == "drift") {
    if (is.null(x$drift)) return(tibble::tibble())
    return(tibble::as_tibble(as.data.frame(x$drift, component = "severity")))
  }
}

#' @rdname tidy
#' @export
tidy.mfrm_fast_fit <- function(x,
                               component = c("facets", "persons", "steps", "slopes"),
                               conf.level = 0.95,
                               use_real_se = TRUE,
                               ...) {
  component <- match.arg(component)
  ci <- .tidymfrm_intervals(x, if (component == "persons") "person" else component, conf.level, use_real_se)
  readiness <- summary(x)$readiness
  status <- readiness$status
  reason <- paste(readiness$reason_codes, collapse = "; ")
  if (component == "slopes") {
    sl <- x$slopes
    if (is.null(sl) || nrow(sl) == 0L) return(tibble::tibble())
    return(tibble::tibble(
      facet = sl$Facet,
      term = sl$Level,
      estimate = sl$Estimate,
      log.estimate = sl$LogEstimate,
      std.error = sl$ModelSE,
      sandwich.se = sl$SandwichSE,
      conf.low = ci[, 1L], conf.high = ci[, 2L],
      inference_status = status, inference_reason = reason,
      formula = sl$Formula
    ))
  }
  if (component == "facets") {
    fc <- x$facets
    return(tibble::tibble(
      facet = fc$Facet,
      term = fc$Level,
      estimate = fc$Estimate,
      std.error = fc$ModelSE,
      real.se = fc$RealSE,
      sandwich.se = fc$SandwichSE,
      conf.low = ci[, 1L], conf.high = ci[, 2L],
    inference_status = status, inference_reason = reason,
      fair_m = fc$FairM,
      infit_mnsq = fc$InfitMnSq,
      infit_zstd = fc$InfitZSTD,
      outfit_mnsq = fc$OutfitMnSq,
      outfit_zstd = fc$OutfitZSTD
    ))
  }
  if (component == "persons") {
    pt <- x$person
    return(tibble::tibble(
      term = pt$Person,
      estimate = pt$Estimate,
      std.error = pt$ModelSE,
      real.se = pt$RealSE,
      wle = pt$WLE,
      wle.se = pt$WLE_SE,
      conf.low = ci[, 1L], conf.high = ci[, 2L],
    inference_status = status, inference_reason = reason,
      fair_m = pt$FairM,
      infit_mnsq = pt$InfitMnSq,
      infit_zstd = pt$InfitZSTD,
      extreme_flag = pt$ExtremeFlag
    ))
  }
  st <- x$steps
  tibble::tibble(
    scale = st$ScaleLevel,
    step = st$Step,
    estimate = st$Estimate,
    std.error = st$ModelSE,
    conf.low = ci[, 1L], conf.high = ci[, 2L],
    inference_status = status, inference_reason = reason
  )
}

#' @rdname tidy
#' @export
tidy.mfrm_fast_gtheory <- function(x, component = c("g_study", "d_study"), ...) {
  component <- match.arg(component)
  if (component == "d_study") tibble::as_tibble(mfrm_d_study(x)) else tibble::as_tibble(x$variance_components)
}

#' @rdname glance
#' @export
glance.tidymfrm <- function(x, ...) {
  x <- .tidymfrm_refresh(x)
  fit_summary <- if (!is.null(x$fit)) summary(x$fit)
  readiness <- fit_summary$readiness
  tibble::tibble(
    model = if (!is.null(x$fit)) x$fit$model else NA_character_,
    method = if (!is.null(x$fit)) x$fit$method else NA_character_,
    score_method = if (!is.null(x$fit)) x$fit$score_method else NA_character_,
    n_obs = x$connectivity$n_obs,
    n_person = x$connectivity$n_person,
    connected = x$connectivity$connected,
    n_subsets = x$connectivity$n_subsets,
    converged = if (!is.null(x$fit)) x$fit$converged else NA,
    inference_ready = if (!is.null(readiness)) readiness$ready else NA,
    inference_status = if (!is.null(readiness)) readiness$status else "not_assessed",
    logLik = if (!is.null(x$fit)) x$fit$loglik else NA_real_,
    eap_reliability = if (!is.null(x$fit)) x$fit$population$eap_reliability else NA_real_,
    g_coef = if (!is.null(x$gtheory)) x$gtheory$g_study_summary$G else NA_real_,
    phi_coef = if (!is.null(x$gtheory)) x$gtheory$g_study_summary$Phi else NA_real_,
    flagged_raters = if (!is.null(x$diagnostics)) .tidymfrm_flag_count(x$diagnostics$raters) else NA_integer_,
    unavailable_raters = if (!is.null(x$diagnostics)) sum(x$diagnostics$raters$DiagnosticFlag == "Review required") else NA_integer_,
    unexpected_ratings = if (!is.null(x$diagnostics)) nrow(x$diagnostics$unexpected) else NA_integer_,
    elapsed_sec = x$elapsed_sec,
    model_label = if (!is.null(fit_summary)) .tidymfrm_model_label(x$fit, fit_summary) else NA_character_
  )
}

#' @rdname glance
#' @export
glance.mfrm_fast_fit <- function(x, ...) {
  fit_summary <- summary(x)
  readiness <- fit_summary$readiness
  tibble::tibble(
    model = x$model,
    method = x$method,
    score_method = x$score_method,
    n_obs = x$n_obs,
    n_person = x$n_person,
    connected = x$connectivity$connected,
    n_subsets = x$connectivity$n_subsets,
    converged = x$converged,
    inference_ready = readiness$ready,
    inference_status = readiness$status,
    logLik = x$loglik,
    eap_reliability = x$population$eap_reliability,
    elapsed_sec = x$elapsed_sec,
    model_label = .tidymfrm_model_label(x, fit_summary)
  )
}

#' @rdname augment
#' @export
augment.tidymfrm <- function(x, ...) {
  x <- .tidymfrm_check_diagnostics(x)
  if (!is.null(x$diagnostics$observations)) {
    return(x$diagnostics$observations)
  }
  if (is.null(x$fit)) stop("Run `step_mfrm_measure()` before `augment()`.", call. = FALSE)
  .tidymfrm_observation_residuals(x$data, x$spec$person, x$spec$facets, x$spec$score, x$fit)
}
