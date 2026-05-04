# ==============================================================================
# Person fit indices: lz, lz* (Drasgow et al. 1985 / Snijders 2001)
# ==============================================================================
#
# `compute_person_fit_indices()` extends the Infit / Outfit / ZSTD
# columns that `diagnose_mfrm()` already returns with two
# additional person-level statistics:
#
# - lz (Drasgow, Levine & Williams, 1985): standardized log-likelihood
#   under the fitted model. Computed in its proper polytomous form
#   using the per-observation category probability `Pr(X = x | theta)`
#   from the model (not the Gaussian-residual approximation used in
#   earlier mfrmr releases). The centering term is the per-item
#   negentropy E[log P_k] = sum_k P_k log P_k and the variance term is
#   sum_k P_k (log P_k)^2 - (sum_k P_k log P_k)^2, summed across the
#   person's observations. Asymptotically standard normal under the
#   conditional-independence assumption when person ability is known.
# - lz*: Snijders-style score-projection correction for JML fits,
#   conditional on the fitted non-person parameters. For MML/EAP fits,
#   `lz_star` is deliberately left `NA` because the published Snijders
#   correction is an asymptotic correction for estimated person parameters
#   under ML/WL/BM-style ability estimating equations, not for EAP
#   posterior means. A separate `lz_finite_n` column carries the old
#   finite-N shrinkage screen under an explicit non-Snijders name.
#
# Note: earlier mfrmr versions reported an `ECI4` column whose
# implementation was the standardized chi-square (sum StdSq - n) /
# sqrt(2 n) rather than the Tatsuoka & Tatsuoka (1983) extended-caution
# index. That column was a duplicate of the existing `OutfitZSTD`
# statistic in `diagnose_mfrm()$measures` under the linear (Smith
# whexact) approximation and has been removed in 0.2.0; use
# `OutfitZSTD` instead.

#' Person fit indices: lz, lz*
#'
#' Computes person-level fit statistics for an MFRM bundle, extending
#' the Infit / Outfit / ZSTD columns that `diagnose_mfrm()$measures`
#' already exposes with the standardized log-likelihood `lz`, a
#' Snijders-style `lz_star` for JML fits, and an explicitly named
#' finite-N heuristic `lz_finite_n`.
#'
#' @param diagnostics Output from [diagnose_mfrm()].
#' @param fit Optional `mfrm_fit` from [fit_mfrm()]. When supplied,
#'   the helper can compute the JML/ML-style Snijders correction
#'   (column `lz_star`) and returns a `lz_star_method` audit column.
#'   When `NULL`, only `lz` and `lz_finite_n` are returned, with
#'   `lz_star = NA`.
#'
#' @return A data frame with one row per Person and columns:
#' \describe{
#'   \item{`Person`}{Person ID.}
#'   \item{`N`}{Number of contributing response opportunities.}
#'   \item{`LogLik`}{Sum of log P(X = x | theta) under the fitted
#'     model. Computed from the per-observation category probability
#'     `PrObserved` (the model probability of the observed category),
#'     not from a Gaussian residual approximation.}
#'   \item{`lz`}{Drasgow et al. (1985) standardized log-likelihood,
#'     in its proper polytomous form.}
#'   \item{`lz_star`}{Snijders-style score-projection corrected statistic,
#'     computed for JML fits by projecting the log-likelihood weights away
#'     from the person-score estimating equation. For MML/EAP fits this
#'     column is `NA` because EAP posterior means do not satisfy the ML
#'     person-score equation used by the correction.}
#'   \item{`lz_finite_n`}{Finite-N heuristic retained for continuity:
#'     \eqn{lz / \sqrt{1 + 1/N}}. This is not the published Snijders
#'     statistic.}
#'   \item{`lz_star_method`}{Audit label describing whether `lz_star`
#'     was computed and why it may be unavailable.}
#' }
#'
#' Under the conditional-independence assumption of the MFRM, `lz` is
#' asymptotically standard normal. Practical reporting thresholds:
#' |lz| > 1.96 flags a person at the 5% level; |lz| > 2.58 at the
#' 1% level. `lz_star` should be read as a conditional person-fit
#' statistic: it corrects for estimated JML person measures but still
#' treats the fitted non-person parameters as fixed.
#'
#' Note: this implementation reads the model category probabilities
#' directly from the diagnostics bundle. Earlier mfrmr releases used
#' a Gaussian-residual approximation
#' \eqn{\log P(X = x) \approx -\tfrac{1}{2}(R^2/V) - \tfrac{1}{2}\log(2\pi V)}
#' as a stand-in for \eqn{\log P}, which overstated the per-item
#' variance of \eqn{\log P} for polytomous items, shrinking the
#' reported `lz` toward zero. Numerical `lz` values are therefore
#' not directly comparable across mfrmr releases; treat the values
#' returned here as the polytomous statistic and re-evaluate any
#' historical `|lz| > 1.96` flagging that was based on the earlier
#' approximation.
#'
#' @section References:
#' - Drasgow, F., Levine, M. V., & Williams, E. A. (1985).
#'   Appropriateness measurement with polychotomous item response
#'   models and standardized indices.
#'   *British Journal of Mathematical and Statistical Psychology, 38*(1), 67-86.
#' - Snijders, T. A. B. (2001). Asymptotic null distribution of
#'   person fit statistics with estimated person parameter.
#'   *Psychometrika, 66*(3), 331-342.
#'
#' @seealso [diagnose_mfrm()]
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none",
#'                       diagnostic_mode = "legacy")
#' pf <- compute_person_fit_indices(diag, fit = fit)
#' head(pf)
#' # Look for: |lz| > 1.96 (5% level) flags a person whose response
#' #   pattern is statistically inconsistent with the model; > 2.58 is
#' #   a 1% flag. `lz_star_method` tells you whether the Snijders-style
#' #   correction was computed or left unavailable for the active estimator.
#' @export
compute_person_fit_indices <- function(diagnostics, fit = NULL) {
  if (is.null(diagnostics) || !is.list(diagnostics) ||
      is.null(diagnostics$obs)) {
    stop("`diagnostics` must be a non-empty `mfrm_diagnostics` bundle.",
         call. = FALSE)
  }
  obs <- as.data.frame(diagnostics$obs, stringsAsFactors = FALSE)
  needed <- c("Person", "PrObserved", "ItemEntropy", "ItemVarLogP")
  missing_cols <- setdiff(needed, names(obs))
  if (length(missing_cols) > 0L) {
    stop("`diagnostics$obs` is missing required columns: ",
         paste(missing_cols, collapse = ", "),
         ". This typically means the diagnostics bundle was generated ",
         "by an mfrmr version older than 0.2.0; refit and re-diagnose ",
         "to populate the per-observation probability columns.",
         call. = FALSE)
  }
  obs$Person <- as.character(obs$Person)
  obs$PrObserved <- suppressWarnings(as.numeric(obs$PrObserved))
  obs$ItemEntropy <- suppressWarnings(as.numeric(obs$ItemEntropy))
  obs$ItemVarLogP <- suppressWarnings(as.numeric(obs$ItemVarLogP))

  # True Drasgow et al. (1985) lz computed from the polytomous category
  # probabilities. log_p is the model log-probability of the observed
  # category; e_logp is the per-item negentropy E[log P]; var_logp is
  # the per-item Var(log P). All three terms are summed across each
  # person's observations to form lz = (l - E[l]) / sqrt(Var[l]).
  log_p <- log(pmax(obs$PrObserved, .Machine$double.eps))

  agg <- by(
    data.frame(log_p = log_p,
               e_logp = obs$ItemEntropy,
               var_logp = obs$ItemVarLogP,
               stringsAsFactors = FALSE),
    obs$Person,
    function(d) {
      ok <- is.finite(d$log_p) & is.finite(d$e_logp) &
            is.finite(d$var_logp) & d$var_logp >= 0
      d <- d[ok, , drop = FALSE]
      if (nrow(d) == 0L) {
        return(c(N = 0L, LogLik = NA_real_, lz = NA_real_))
      }
      ll <- sum(d$log_p)
      e_ll <- sum(d$e_logp)
      var_ll <- sum(d$var_logp)
      lz_val <- if (var_ll > 0) (ll - e_ll) / sqrt(var_ll) else NA_real_
      c(N = nrow(d), LogLik = ll, lz = lz_val)
    }
  )
  out <- do.call(rbind, lapply(agg, function(x) as.data.frame(t(x))))
  out$Person <- rownames(out)
  rownames(out) <- NULL
  out <- out[, c("Person", "N", "LogLik", "lz"), drop = FALSE]
  out$N <- as.integer(out$N)

  out$lz_finite_n <- out$lz / sqrt(1 + 1 / pmax(out$N, 1L))
  out$lz_star <- NA_real_
  out$lz_star_method <- "unavailable_no_fit"
  if (!is.null(fit) && inherits(fit, "mfrm_fit")) {
    method <- as.character(fit$config$method %||% NA_character_)
    if (identical(method, "JMLE")) {
      star <- compute_lz_star_jml(fit = fit, obs = obs)
      idx <- match(out$Person, star$Person)
      out$lz_star <- star$lz_star[idx]
      out$lz_star_method <- star$lz_star_method[idx]
    } else {
      out$lz_star_method <- "unavailable_for_eap_mml"
    }
  }
  out[, c("Person", "N", "LogLik", "lz", "lz_star", "lz_finite_n",
          "lz_star_method"), drop = FALSE]
}

compute_lz_star_jml <- function(fit, obs) {
  probs <- compute_prob_matrix(fit)
  if (!is.matrix(probs) || nrow(probs) != nrow(obs) || ncol(probs) < 2L) {
    return(data.frame(
      Person = unique(as.character(obs$Person)),
      lz_star = NA_real_,
      lz_star_method = "unavailable_probability_matrix",
      stringsAsFactors = FALSE
    ))
  }
  eps <- .Machine$double.eps
  probs <- pmax(probs, eps)
  probs <- probs / rowSums(probs)
  k_vals <- 0:(ncol(probs) - 1L)
  log_probs <- log(probs)
  expected_k <- as.vector(probs %*% k_vals)
  score_slope <- suppressWarnings(as.numeric(obs$ScoreSlope %||% rep(1, nrow(obs))))
  score_slope[!is.finite(score_slope)] <- 1

  r_mat <- sweep(matrix(k_vals, nrow = nrow(probs), ncol = ncol(probs), byrow = TRUE),
                 1, expected_k, "-")
  r_mat <- sweep(r_mat, 1, score_slope, "*")
  e_logp <- as.numeric(rowSums(probs * log_probs))
  e_r <- as.numeric(rowSums(probs * r_mat))
  centered_w <- sweep(log_probs, 1, e_logp, "-")
  centered_r <- sweep(r_mat, 1, e_r, "-")
  var_w <- pmax(as.numeric(rowSums(probs * centered_w^2)), 0)
  cov_wr <- as.numeric(rowSums(probs * centered_w * centered_r))
  var_r <- pmax(as.numeric(rowSums(probs * centered_r^2)), 0)

  score_k <- suppressWarnings(as.integer(obs$score_k %||% (obs$Observed - min(obs$Observed, na.rm = TRUE))))
  obs_col <- pmin(pmax(score_k + 1L, 1L), ncol(probs))
  log_p <- log_probs[cbind(seq_len(nrow(probs)), obs_col)]
  centered_log_p <- log_p - e_logp
  centered_score <- centered_r[cbind(seq_len(nrow(probs)), obs_col)]

  pieces <- data.frame(
    Person = as.character(obs$Person),
    centered_log_p = centered_log_p,
    centered_score = centered_score,
    var_w = var_w,
    cov_wr = cov_wr,
    var_r = var_r,
    stringsAsFactors = FALSE
  )
  by_person <- split(pieces, pieces$Person)
  rows <- lapply(by_person, function(d) {
    ok <- is.finite(d$centered_log_p) & is.finite(d$centered_score) &
      is.finite(d$var_w) &
      is.finite(d$cov_wr) & is.finite(d$var_r) & d$var_w >= 0 & d$var_r >= 0
    d <- d[ok, , drop = FALSE]
    if (nrow(d) == 0L) {
      return(data.frame(lz_star = NA_real_,
                        lz_star_method = "unavailable_no_valid_terms",
                        stringsAsFactors = FALSE))
    }
    total_score_var <- sum(d$var_r, na.rm = TRUE)
    if (!is.finite(total_score_var) || total_score_var <= 0) {
      return(data.frame(lz_star = NA_real_,
                        lz_star_method = "unavailable_zero_score_information",
                        stringsAsFactors = FALSE))
    }
    c_hat <- sum(d$cov_wr, na.rm = TRUE) / total_score_var
    tau2 <- sum(d$var_w - 2 * c_hat * d$cov_wr + c_hat^2 * d$var_r,
                na.rm = TRUE)
    if (!is.finite(tau2) || tau2 <= 0) {
      return(data.frame(lz_star = NA_real_,
                        lz_star_method = "unavailable_zero_projected_variance",
                        stringsAsFactors = FALSE))
    }
    data.frame(
      lz_star = sum(d$centered_log_p - c_hat * d$centered_score,
                    na.rm = TRUE) / sqrt(tau2),
      lz_star_method = "snijders_score_projection_jml",
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  out$Person <- names(rows)
  rownames(out) <- NULL
  out[, c("Person", "lz_star", "lz_star_method"), drop = FALSE]
}
