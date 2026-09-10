#' Analyze practical equivalence within a facet
#'
#' @param fit Output from [fit_mfrm()]. Requires an inference-ready MML fit
#'   with unregularized observed-information covariance and estimable contrasts.
#' @param diagnostics Optional matching output from [diagnose_mfrm()]. Supplied
#'   diagnostics must retain all target-facet levels, model-based SEs and
#'   ordinary-inference eligibility. Estimates and covariance are always taken
#'   from `fit`; supplying diagnostics cannot override its restrictions.
#' @param facet Character scalar naming a non-person facet. When `NULL`, a
#'   rater-like facet is preferred, otherwise the first model facet is used.
#' @param equivalence_bound Positive practical-equivalence bound in logits.
#'   The default `0.5` is not a universal threshold. Choose the smallest
#'   practically meaningful difference for the intended use before inspecting
#'   the equivalence results.
#' @param ci_level Confidence level for level and grand-mean-deviation intervals
#'   (default `0.95`). Pairwise TOST always uses alpha 0.05 and 90% intervals.
#' @param conf_level Deprecated alias for `ci_level`; when supplied it takes
#'   precedence and emits a lifecycle deprecation warning.
#'
#' @details
#' Pair differences use the full constrained covariance from the MML observed
#' information: \eqn{\mathrm{Var}(A-B) = \mathrm{Var}(A) + \mathrm{Var}(B) -
#' 2\mathrm{Cov}(A,B)}. No model is refitted. JML, inference-ineligible fits,
#' missing or regularized covariance, and singular contrast covariance stop
#' with an error. Levels with fixed or unavailable contrasts are not silently
#' dropped. Known anchors are treated as fixed; their uncertainty is excluded.
#' Non-unit observation weights are inference-ineligible, including weights
#' normalized to mean one. Older bundles must retain the current readiness
#' contract as well as the covariance basis before they can be displayed.
#'
#' The heterogeneity table uses a joint Wald chi-square test of equality of
#' the facet levels. Non-significant heterogeneity is neither necessary nor
#' sufficient for practical equivalence. `FixedChiSq`, `FixedDF`, and
#' `FixedProb` retain their column names but use this joint contrast test.
#' Separation and reliability remain descriptive summaries.
#'
#' `GrandMean` is the equally weighted mean of the facet estimates. For each
#' deviation from that mean, uncertainty includes the covariance with the
#' estimated mean. `ROPEPct` is the mass of its normal confidence distribution
#' inside the practical bound; it is descriptive, not a Bayesian posterior
#' probability or a separate equivalence decision.
#'
#' The former BIC/Bayes-factor heuristic is unavailable: a Wald statistic is
#' not a fitted likelihood comparison. For compatibility, `BF01` is `NA` and
#' `BF01Label` states why no value is supplied.
#'
#' @section What this analysis means:
#' The analysis asks whether differences between facet levels fall within a
#' prespecified practical bound under the fitted model. These are asymptotic
#' normal-approximation tests; numerical eligibility does not establish
#' finite-sample coverage or adequacy of the rating design.
#'
#' @section What this analysis does not justify:
#' A non-significant difference is not evidence of equivalence. Pairwise
#' conclusions are unadjusted for multiplicity: selecting some positive pairs
#' does not provide family-wise error control for that selected set. Estimated
#' linking or anchor uncertainty, population transport, and model
#' misspecification require separate evaluation.
#'
#' @section Decision rule:
#' Each pair uses two one-sided normal tests at alpha 0.05. `Equivalent` is
#' true when both tests reject non-equivalence, equivalently when its 90%
#' interval lies strictly inside the bound. `Decision` summarizes all pairs
#' as `"all_pairs_equivalent"`, `"partial_pairwise_equivalence"`, or
#' `"no_pairwise_equivalence_established"`. No pair may be omitted from the
#' all-pairs summary. Heterogeneity and ROPE summaries do not change this rule.
#'
#' @section Interpreting output:
#' Start with `summary$Decision` and examine the corresponding `pairwise`
#' differences, SEs and intervals. A negative result can reflect imprecision
#' or a material difference. `chi_square` addresses exact equality, while
#' `rope` and `forest` describe proximity to the facet mean.
#'
#' @section How to read the main outputs:
#' - `summary`: pairwise decision, covariance basis and multiplicity convention.
#' - `pairwise`: differences, covariance-aware SEs, 90% intervals and TOST tests.
#' - `chi_square`: joint Wald heterogeneity test and descriptive separation.
#' - `rope` / `forest`: `Measure`, marginal `SE` and `CI_Lower`/`CI_Upper`, plus
#'   `Deviation`, `DeviationSE` and `DeviationCI_Lower`/`DeviationCI_Upper` for
#'   proximity to the equally weighted facet mean.
#'
#' @section Recommended next step:
#' Review numerical integration and the model's uncertainty assumptions before
#' interpreting a borderline result. Sensitivity to another practical bound
#' should be reported transparently, without selecting a bound to obtain a
#' desired decision.
#'
#' @section Typical workflow:
#' 1. Fit and review an MML model with [fit_mfrm()].
#' 2. Prespecify the practical bound and run `analyze_facet_equivalence()`.
#' 3. Read `summary` and `pairwise`.
#' 4. Use [plot_facet_equivalence()] for descriptive grand-mean proximity.
#'
#' @section Output:
#' A bundle with `summary`, `chi_square`, `pairwise`, `rope`, `forest`, and
#' `settings`. Older bundles without the current inference/covariance basis
#' must be recomputed before using `summary()`, `print()`, or plotting.
#'
#' @return A named list with class `mfrm_facet_equivalence`.
#' @seealso [facets_chisq_table()], [fair_average_table()], [plot_facet_equivalence()]
#' @concept confidence intervals
#' @concept facet equivalence
#' @concept reporting workflow
#' @references
#' Schuirmann, D. J. (1987). A comparison of the two one-sided tests
#' procedure and the power approach for assessing the equivalence of
#' average bioavailability. *Journal of Pharmacokinetics and
#' Biopharmaceutics, 15*(6), 657-680.
#' @examples
#' \donttest{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "MML", quad_points = 31, maxit = 150)
#' eq <- analyze_facet_equivalence(fit, facet = "Rater")
#' eq$summary[, c("Facet", "Elements", "Decision", "MeanROPE")]
#' head(eq$pairwise[, c("ElementA", "ElementB", "Equivalent")])
#' }
#' @export
analyze_facet_equivalence <- function(fit,
                                      diagnostics = NULL,
                                      facet = NULL,
                                      equivalence_bound = 0.5,
                                      ci_level = 0.95,
                                      conf_level = NULL) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  if (!is.numeric(equivalence_bound) || length(equivalence_bound) != 1 || !is.finite(equivalence_bound) ||
      equivalence_bound <= 0) {
    stop("`equivalence_bound` must be a positive finite number.", call. = FALSE)
  }
  # `conf_level` is the deprecated spelling; the canonical name
  # elsewhere in mfrmr is `ci_level`. When both are supplied we honor
  # `conf_level` and route the notification through
  # lifecycle so users can control verbosity with
  # options(lifecycle_verbosity = "..."). `conf_level` will be
  # deprecated; prefer `ci_level` in new code.
  if (!is.null(conf_level)) {
    lifecycle::deprecate_warn(
      when = "0.1.6",
      what = "analyze_facet_equivalence(conf_level = )",
      with = "analyze_facet_equivalence(ci_level = )"
    )
    ci_level <- conf_level
  }
  conf_level <- ci_level
  if (!is.numeric(conf_level) || length(conf_level) != 1 || !is.finite(conf_level) ||
      conf_level <= 0 || conf_level >= 1) {
    stop("`ci_level` must be a single number between 0 and 1.", call. = FALSE)
  }

  if (!identical(fit$config$method, "MML") || !mfrm_inference_ready(fit)) {
    stop("Facet equivalence requires an inference-ready MML fit; ordinary inference is unavailable for this fit.",
         call. = FALSE)
  }
  if (!is.null(diagnostics)) {
    mfrm_results_validate_diagnostics_identity(
      fit, diagnostics, helper = "analyze_facet_equivalence()"
    )
    if (!isTRUE(diagnostics$precision_profile$SupportsFormalInference)) {
      stop("Supplied diagnostics do not support ordinary inference.", call. = FALSE)
    }
  }

  facet_names <- as.character(fit$config$facet_names)
  if (is.null(facet)) {
    facet <- infer_default_rater_facet(facet_names) %||% facet_names[1]
  }
  if (length(facet) != 1L || is.na(facet) || !facet %in% facet_names) {
    stop("`facet` must be one of: ", paste(facet_names, collapse = ", "), ".", call. = FALSE)
  }
  spec <- fit$config$facet_specs[[facet]]
  labels <- as.character(spec$levels)
  n_elem <- length(labels)
  if (n_elem < 2L) {
    stop("Facet '", facet, "' has fewer than 2 estimated levels.", call. = FALSE)
  }
  facet_df <- fit$facets$others[fit$facets$others$Facet == facet, , drop = FALSE]
  idx <- match(labels, as.character(facet_df$Level))
  est <- as.numeric(facet_df$Estimate[idx])
  if (anyNA(idx) || anyDuplicated(facet_df$Level) || !all(is.finite(est))) {
    stop("Complete finite facet estimates are required; no levels may be dropped.", call. = FALSE)
  }

  # Always derive uncertainty from this fit, never from supplied SE columns.
  covariance <- compute_mml_parameter_covariance(fit)
  if (!identical(covariance$status, "ok") || is.null(covariance$cov)) {
    stop("Facet equivalence requires unregularized MML observed-information covariance.", call. = FALSE)
  }
  slice <- covariance$param_slices[[facet]]
  jac <- constraint_jacobian(spec)
  facet_cov <- symmetrize_matrix(
    jac %*% covariance$cov[slice, slice, drop = FALSE] %*% t(jac)
  )
  contrasts <- cbind(diag(n_elem - 1L), -1)
  contrast_rank <- qr(contrasts %*% jac)$rank
  if (contrast_rank < n_elem - 1L) {
    stop("All facet contrasts must be independent under the model constraints; fixed or unidentified contrasts cannot be tested.",
         call. = FALSE)
  }
  contrast_cov <- contrasts %*% facet_cov %*% t(contrasts)
  contrast_chol <- tryCatch(chol(contrast_cov), error = function(e) NULL)
  if (!all(is.finite(facet_cov)) || is.null(contrast_chol)) {
    stop("All facet contrasts must have positive-definite covariance; fixed or unidentified contrasts cannot be tested.",
         call. = FALSE)
  }
  se <- covariance_diag_se(facet_cov)
  if (!all(is.finite(se))) {
    stop("Facet covariance has invalid marginal variances.", call. = FALSE)
  }
  if (!is.null(diagnostics)) {
    rows <- diagnostics$measures[diagnostics$measures$Facet == facet, , drop = FALSE]
    row_idx <- match(labels, as.character(rows$Level))
    if (!all(c("Level", "SE", "SupportsFormalInference") %in% names(rows)) ||
        nrow(rows) != n_elem || anyNA(row_idx) || anyDuplicated(rows$Level) ||
        !isTRUE(all(rows$SupportsFormalInference[row_idx])) ||
        !isTRUE(all.equal(as.numeric(rows$SE[row_idx]), se, tolerance = 1e-8,
                          check.attributes = FALSE))) {
      stop("Supplied facet diagnostics must contain all levels with matching model-based SEs and ordinary-inference eligibility.",
           call. = FALSE)
    }
  }

  grand_mean <- mean(est)
  centering <- diag(n_elem) - 1 / n_elem
  deviation_se <- covariance_diag_se(centering %*% facet_cov %*% t(centering))
  df_chi <- n_elem - 1L
  standardized <- forwardsolve(t(contrast_chol), contrasts %*% est)
  chi2_val <- sum(standardized ^ 2)
  p_chi <- stats::pchisq(chi2_val, df = df_chi, lower.tail = FALSE)
  sep_sd <- stats::sd(est)
  rmse <- sqrt(mean(se ^ 2))
  true_sd <- sqrt(max(sep_sd ^ 2 - rmse ^ 2, 0))
  separation <- if (rmse > 0) true_sd / rmse else NA_real_
  reliability <- separation ^ 2 / (1 + separation ^ 2)

  z_ci <- stats::qnorm(1 - (1 - conf_level) / 2)
  z_tost <- stats::qnorm(0.95)
  pair_idx <- utils::combn(seq_len(n_elem), 2)
  pairwise_tbl <- if (is.null(dim(pair_idx))) {
    data.frame()
  } else {
    pairwise_rows <- lapply(seq_len(ncol(pair_idx)), function(k) {
      i <- pair_idx[1, k]
      j <- pair_idx[2, k]
      diff <- est[i] - est[j]
      se_diff <- sqrt(facet_cov[i, i] + facet_cov[j, j] - 2 * facet_cov[i, j])
      z_lower <- (diff + equivalence_bound) / se_diff
      z_upper <- (diff - equivalence_bound) / se_diff
      p_lower <- stats::pnorm(z_lower, lower.tail = FALSE)
      p_upper <- stats::pnorm(z_upper, lower.tail = TRUE)
      p_tost <- max(p_lower, p_upper)
      data.frame(
        ElementA = labels[i],
        ElementB = labels[j],
        Diff = diff,
        SE_Diff = se_diff,
        CI90_Lower = diff - z_tost * se_diff,
        CI90_Upper = diff + z_tost * se_diff,
        P_Lower = p_lower,
        P_Upper = p_upper,
        P_TOST = p_tost,
        Equivalent = is.finite(p_tost) & p_tost < 0.05,
        stringsAsFactors = FALSE
      )
    })
    pairwise_tbl <- do.call(rbind, pairwise_rows)
    if (is.null(pairwise_tbl)) pairwise_tbl <- data.frame()
    pairwise_tbl
  }
  n_pairs <- nrow(pairwise_tbl)
  n_equiv <- if (n_pairs > 0) sum(pairwise_tbl$Equivalent, na.rm = TRUE) else 0L

  rope_tbl <- data.frame(
    Element = labels,
    Measure = est,
    Deviation = est - grand_mean,
    SE = se,
    DeviationSE = deviation_se,
    DeviationCI_Lower = est - grand_mean - z_ci * deviation_se,
    DeviationCI_Upper = est - grand_mean + z_ci * deviation_se,
    CI_Lower = est - z_ci * se,
    CI_Upper = est + z_ci * se,
    stringsAsFactors = FALSE
  )
  rope_tbl$ROPEPct <- 100 * (
    stats::pnorm(equivalence_bound, mean = rope_tbl$Deviation, sd = rope_tbl$DeviationSE) -
      stats::pnorm(-equivalence_bound, mean = rope_tbl$Deviation, sd = rope_tbl$DeviationSE)
  )
  rope_tbl$ROPEStatus <- ifelse(
    rope_tbl$DeviationCI_Lower >= -equivalence_bound & rope_tbl$DeviationCI_Upper <= equivalence_bound,
    "inside",
    ifelse(
      rope_tbl$DeviationCI_Lower > equivalence_bound | rope_tbl$DeviationCI_Upper < -equivalence_bound,
      "outside",
      "overlap"
    )
  )

  mean_rope <- if (nrow(rope_tbl) > 0) mean(rope_tbl$ROPEPct, na.rm = TRUE) else NA_real_
  all_pairs_equivalent <- n_pairs > 0L && n_equiv == n_pairs
  any_pair_equivalent <- n_pairs > 0L && n_equiv > 0L
  decision <- if (all_pairs_equivalent) {
    "all_pairs_equivalent"
  } else if (any_pair_equivalent) {
    "partial_pairwise_equivalence"
  } else {
    "no_pairwise_equivalence_established"
  }

  chi_square_tbl <- data.frame(
    Facet = facet,
    Elements = n_elem,
    GrandMean = grand_mean,
    FixedChiSq = chi2_val,
    FixedDF = df_chi,
    FixedProb = p_chi,
    TestBasis = "Wald test of joint facet contrasts",
    Separation = separation,
    Reliability = reliability,
    stringsAsFactors = FALSE
  )

  summary_tbl <- data.frame(
    Facet = facet,
    Elements = n_elem,
    EquivalenceBound = equivalence_bound,
    GrandMean = grand_mean,
    FixedProb = p_chi,
    PairwiseComparisons = n_pairs,
    PairwiseEquivalent = n_equiv,
    PairwiseEquivalentPct = if (n_pairs > 0) 100 * n_equiv / n_pairs else NA_real_,
    BF01 = NA_real_,
    BF01Label = "Unavailable: requires fitted likelihood comparison",
    MeanROPE = mean_rope,
    AllPairsEquivalent = all_pairs_equivalent,
    AnyPairEquivalent = any_pair_equivalent,
    PairwiseDecisionBasis = "pairwise_tost_summary",
    InferenceReady = TRUE,
    CovarianceBasis = "mml_observed_information_contrasts",
    MultiplicityAdjustment = "none",
    Decision = decision,
    stringsAsFactors = FALSE
  )

  out <- list(
    summary = summary_tbl,
    chi_square = chi_square_tbl,
    pairwise = as.data.frame(pairwise_tbl, stringsAsFactors = FALSE),
    rope = as.data.frame(rope_tbl, stringsAsFactors = FALSE),
    forest = as.data.frame(rope_tbl, stringsAsFactors = FALSE),
    settings = list(
      facet = facet,
      equivalence_bound = equivalence_bound,
      ci_level = conf_level,
      mean_basis = "equal_weight_facet_mean",
      contrast_rank = contrast_rank,
      readiness_contract_version = mfrmr_readiness_contract_version(),
      covariance_basis = "mml_observed_information_contrasts"
    )
  )
  as_mfrm_bundle(out, "mfrm_facet_equivalence")
}

validate_facet_equivalence_bundle <- function(x) {
  if (!isTRUE(x$summary$InferenceReady) ||
      !identical(x$settings$readiness_contract_version,
                 mfrmr_readiness_contract_version()) ||
      !identical(x$settings$contrast_rank, x$summary$Elements - 1L) ||
      !identical(x$settings$covariance_basis, "mml_observed_information_contrasts") ||
      !identical(x$summary$CovarianceBasis, "mml_observed_information_contrasts")) {
    stop("This equivalence bundle lacks the current inference and covariance basis. Recompute it with analyze_facet_equivalence() from an eligible MML fit.",
         call. = FALSE)
  }
  invisible(x)
}

#' Plot facet-equivalence results
#'
#' @param x Output from [analyze_facet_equivalence()] or an eligible MML
#'   [fit_mfrm()] object. Legacy equivalence bundles must be recomputed.
#' @param diagnostics Optional matching output from [diagnose_mfrm()] when
#'   `x` is an `mfrm_fit` object.
#' @param facet Facet to analyze when `x` is an `mfrm_fit` object.
#' @param type Plot type: `"forest"` (default) or `"rope"`.
#' @param draw If `TRUE` (default), draw the plot. If `FALSE`, return the
#'   prepared plotting data.
#' @param ... Additional graphical arguments passed to base plotting functions.
#'
#' @details
#' Fit inputs use the same eligibility checks as [analyze_facet_equivalence()].
#' Bundle inputs display the already calculated results. Both routes require
#' the current inference and covariance basis, including when `draw = FALSE`.
#'
#' @section Plot types:
#' - `"forest"` shows each level's deviation from the equally weighted facet
#'   mean, with covariance-aware deviation intervals and the practical region
#'   around zero. The raw marginal measure intervals remain in the data table.
#' - `"rope"` shows the normal confidence-distribution mass within that region.
#'
#' @section Interpreting output:
#' Both plots describe grand-mean proximity. Colors in the forest plot indicate
#' whether the deviation interval is inside, outside, or overlaps the practical
#' region. Neither plot establishes pairwise equivalence or a Bayesian
#' probability. Read the pairwise TOST results for pair-specific conclusions.
#'
#' @section Typical workflow:
#' 1. Run [analyze_facet_equivalence()] with a prespecified practical bound.
#' 2. Use `type = "forest"` to inspect deviations and their uncertainty.
#' 3. Use `type = "rope"` for a descriptive proximity view.
#'
#' @return Invisibly returns the plotting data and inference/covariance basis.
#'   With `draw = FALSE`, returns the data without drawing.
#' @seealso [analyze_facet_equivalence()]
#' @concept confidence intervals
#' @concept facet equivalence
#' @concept visual diagnostics
#' @examples
#' \donttest{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "MML", quad_points = 31, maxit = 150)
#' eq <- analyze_facet_equivalence(fit, facet = "Rater")
#' pdat <- plot_facet_equivalence(eq, type = "forest", draw = FALSE)
#' c(pdat$facet, pdat$type)
#' }
#' @export
plot_facet_equivalence <- function(x,
                                   diagnostics = NULL,
                                   facet = NULL,
                                   type = c("forest", "rope"),
                                   draw = TRUE,
                                   ...) {
  type <- match.arg(type)
  if (inherits(x, "mfrm_fit")) {
    x <- analyze_facet_equivalence(
      fit = x,
      diagnostics = diagnostics,
      facet = facet
    )
  }
  if (!inherits(x, "mfrm_facet_equivalence")) {
    stop("`x` must be output from analyze_facet_equivalence() or fit_mfrm().", call. = FALSE)
  }

  validate_facet_equivalence_bundle(x)

  forest_df <- as.data.frame(x$forest %||% data.frame(), stringsAsFactors = FALSE)
  settings <- x$settings %||% list()
  summary_tbl <- as.data.frame(x$summary %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(forest_df) == 0) {
    stop("No equivalence rows are available for plotting.", call. = FALSE)
  }

  out <- list(
    data = forest_df,
    facet = as.character(settings$facet %||% summary_tbl$Facet[1] %||% ""),
    grand_mean = suppressWarnings(as.numeric(summary_tbl$GrandMean[1] %||% NA_real_)),
    equivalence_bound = suppressWarnings(as.numeric(settings$equivalence_bound %||% summary_tbl$EquivalenceBound[1] %||% NA_real_)),
    type = type,
    inference_ready = TRUE,
    covariance_basis = settings$covariance_basis
  )
  if (!isTRUE(draw)) {
    return(out)
  }

  dots <- list(...)

  if (identical(type, "forest")) {
    ord <- order(forest_df$Deviation, decreasing = FALSE, na.last = TRUE)
    forest_df <- forest_df[ord, , drop = FALSE]
    ypos <- seq_len(nrow(forest_df))
    cols <- ifelse(
      forest_df$ROPEStatus == "inside",
      "#2E8B57",
      ifelse(forest_df$ROPEStatus == "outside", "#C0392B", "#D68910")
    )
    xlim <- range(c(forest_df$DeviationCI_Lower, forest_df$DeviationCI_Upper,
                    -out$equivalence_bound, out$equivalence_bound), finite = TRUE)
    do.call(graphics::plot, c(list(
      x = forest_df$Deviation,
      y = ypos,
      xlim = xlim,
      yaxt = "n",
      ylab = "",
      xlab = "Deviation from facet mean (logits)",
      main = paste0(out$facet, ": facet equivalence"),
      pch = 19,
      col = cols
    ), dots))
    graphics::axis(2, at = ypos, labels = forest_df$Element, las = 2)
    graphics::rect(
      xleft = -out$equivalence_bound,
      ybottom = 0.5,
      xright = out$equivalence_bound,
      ytop = nrow(forest_df) + 0.5,
      border = NA,
      col = grDevices::adjustcolor("#2E8B57", alpha.f = 0.12)
    )
    graphics::abline(v = 0, lty = 2, col = "gray40")
    graphics::segments(forest_df$DeviationCI_Lower, ypos, forest_df$DeviationCI_Upper, ypos, col = cols, lwd = 2)
    graphics::points(forest_df$Deviation, ypos, pch = 19, col = cols)
  } else {
    ord <- order(forest_df$ROPEPct, decreasing = TRUE, na.last = TRUE)
    forest_df <- forest_df[ord, , drop = FALSE]
    cols <- "#4477AA"
    mids <- graphics::barplot(
      height = forest_df$ROPEPct,
      names.arg = forest_df$Element,
      las = 2,
      ylim = c(0, 100),
      col = cols,
      ylab = "% in ROPE",
      main = paste0(out$facet, ": descriptive grand-mean proximity"),
      ...
    )
    out$bar_midpoints <- mids
  }

  invisible(out)
}

#' @export
plot.mfrm_facet_equivalence <- function(x, ...) {
  plot_facet_equivalence(x, ...)
}
