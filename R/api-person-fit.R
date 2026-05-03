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
# - lz* (placeholder): a finite-sample-adjusted variant of lz that
#   uses cn = 0 and dn = 1/N. The full Snijders (2001) bias-correction
#   (which propagates ability-information uncertainty) is scheduled
#   for a follow-up release; for now treat lz_star as a finite-N
#   inflation of lz, not as the published Snijders statistic.
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
#' already exposes with the standardized log-likelihood `lz` and a
#' finite-sample-adjusted variant `lz*`.
#'
#' @param diagnostics Output from [diagnose_mfrm()].
#' @param fit Optional `mfrm_fit` from [fit_mfrm()]. When supplied,
#'   the helper attaches the person measures and computes a
#'   finite-sample-adjusted variant of `lz` (column `lz_star`);
#'   when `NULL`, only the uncorrected `lz` is returned.
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
#'   \item{`lz_star`}{Finite-sample-adjusted lz, returned only when
#'     `fit` was supplied (otherwise `NA`). The current implementation
#'     uses the placeholder \eqn{c_n = 0}, \eqn{d_n = 1/N} so that
#'     \eqn{lz^* = lz / \sqrt{1 + 1/N}}; the full Snijders (2001)
#'     correction that propagates ability-information uncertainty is
#'     scheduled for a follow-up release. Treat the `lz_star` column
#'     as a finite-N inflation of `lz`, not as the published Snijders
#'     statistic.}
#' }
#'
#' Under the conditional-independence assumption of the MFRM, `lz` is
#' asymptotically standard normal. Practical reporting thresholds:
#' |lz| > 1.96 flags a person at the 5% level; |lz| > 2.58 at the
#' 1% level. The placeholder `lz_star` is on the same scale as `lz`
#' but does not yet carry the published Snijders null distribution.
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
#' #   a 1% flag. The same thresholds applied to `lz_star` are
#' #   approximate because mfrmr's `lz_star` is the placeholder
#' #   `lz / sqrt(1 + 1/N)`, not the published Snijders (2001) lz*.
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

  # lz* placeholder: cn = 0, dn = 1/N. The full Snijders (2001) form
  # requires the score derivative r(theta) and test information
  # I(theta) at the estimated theta; that derivation is scheduled for
  # a follow-up release. The placeholder is a finite-sample inflation
  # only and does not carry the published Snijders null distribution.
  out$lz_star <- NA_real_
  if (!is.null(fit) && inherits(fit, "mfrm_fit")) {
    person_tbl <- as.data.frame(fit$facets$person %||% data.frame(),
                                 stringsAsFactors = FALSE)
    if (nrow(person_tbl) > 0L &&
        all(c("Person", "Estimate") %in% names(person_tbl))) {
      n_per <- tapply(obs$PrObserved, obs$Person,
                       function(v) sum(is.finite(v)), simplify = FALSE)
      person_n <- as.numeric(unlist(n_per[out$Person]))
      cn_val <- 0
      dn_val <- 1 / pmax(person_n, 1L)
      out$lz_star <- (out$lz - cn_val) / sqrt(1 + dn_val)
    }
  }
  out[, c("Person", "N", "LogLik", "lz", "lz_star"), drop = FALSE]
}
