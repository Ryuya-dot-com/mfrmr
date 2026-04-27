# ==============================================================================
# Yen Q3 local-dependence statistic
# ==============================================================================
#
# `q3_statistic()` computes the Yen (1984) Q3 index of local response
# dependence between facet-level pairs from the residuals stored on a
# diagnostics bundle. Q3 is the Pearson correlation of standardized
# residuals between two columns; under the conditional-independence
# assumption of the MFRM, |Q3| should be small.
#
# Reporting thresholds (literature consensus):
# - Yen (1984): |Q3| > 0.20 flags concern.
# - Marais (2013): |Q3| > 0.30 strict.
# - Christensen et al. (2017): adjust by average Q3, flag |Q3 - mean| > 0.20.
#
# This helper exposes the same numerical surface that
# `plot_local_dependence_heatmap()` draws, but returns a tidy
# data.frame with thresholds and interpretation labels for use in
# manuscript tables.

#' Yen Q3 local-dependence statistic between facet levels
#'
#' Computes the Q3 index (Yen, 1984) -- the Pearson correlation of
#' standardized residuals between every pair of levels of a chosen
#' facet -- from a `diagnose_mfrm()` bundle. Under the
#' conditional-independence assumption of the MFRM, |Q3| should be
#' small for every pair; large absolute values flag pairs of facet
#' elements (e.g. two raters or two items) whose residuals co-move
#' more than the main-effects model expects.
#'
#' @param fit An `mfrm_fit` from [fit_mfrm()].
#' @param diagnostics Optional [diagnose_mfrm()] output. Computed
#'   on demand when omitted.
#' @param facet Facet whose levels are paired (default `"Rater"`).
#' @param min_pairs Minimum number of shared response opportunities
#'   required to retain a pair. Pairs below the threshold drop out
#'   of the table (mirrors [plot_local_dependence_heatmap()]).
#' @param yen_threshold Yen (1984) flag threshold (default `0.20`).
#' @param marais_threshold Marais (2013) strict-flag threshold
#'   (default `0.30`).
#' @param relative_offset Christensen et al. (2017) relative-flag
#'   offset (default `0.20`); a pair is flagged relatively when
#'   `|Q3 - mean(Q3)| > relative_offset`.
#'
#' @return An object of class `mfrm_q3` containing:
#' \describe{
#'   \item{`pairs`}{A data frame with one row per facet-level pair
#'     and columns `Level1`, `Level2`, `Q3`, `N`, `AbsQ3`,
#'     `YenFlag`, `MaraisFlag`, `RelativeFlag`, and a textual
#'     `Interpretation` summarising which thresholds were exceeded.}
#'   \item{`summary`}{One-row tibble with `MeanQ3`, `MaxAbsQ3`,
#'     and the three flagged-pair counts.}
#'   \item{`thresholds`}{The thresholds used, for reproducibility.}
#'   \item{`facet`}{The facet whose levels were paired.}
#' }
#'
#' @section References:
#' - Yen, W. M. (1984). Effects of local item dependence on the fit
#'   and equating performance of the three-parameter logistic model.
#'   *Applied Psychological Measurement, 8*(2), 125-145.
#' - Marais, I. (2013). Local dependence. In *Rasch models in health*
#'   (pp. 111-130). ISTE / Wiley.
#' - Christensen, K. B., Makransky, G., & Horton, M. (2017). Critical
#'   values for Yen's Q3: Identification of local dependence in the
#'   Rasch model using residual correlations.
#'   *Applied Psychological Measurement, 41*(3), 178-194.
#'
#' @seealso [plot_local_dependence_heatmap()], [diagnose_mfrm()]
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' q3 <- q3_statistic(fit)
#' q3$summary
#' # Look for: MaxAbsQ3 < 0.20 (Yen) is the comfortable regime; values
#' #   above 0.30 (Marais) are strict-flag worthy. The summary's flag
#' #   counts give a quick triage; inspect `q3$pairs` for the offending
#' #   level pairs and follow up with content review.
#' head(q3$pairs)
#' @export
q3_statistic <- function(fit,
                         diagnostics = NULL,
                         facet = "Rater",
                         min_pairs = 5L,
                         yen_threshold = 0.20,
                         marais_threshold = 0.30,
                         relative_offset = 0.20) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  facet <- as.character(facet[1])
  facet_names <- as.character(fit$config$facet_names %||% character(0))
  if (!facet %in% facet_names) {
    stop("`facet` must be one of: ", paste(facet_names, collapse = ", "), ".",
         call. = FALSE)
  }
  yen_threshold <- as.numeric(yen_threshold[1])
  marais_threshold <- as.numeric(marais_threshold[1])
  relative_offset <- as.numeric(relative_offset[1])
  if (!is.finite(yen_threshold) || yen_threshold <= 0 ||
      !is.finite(marais_threshold) || marais_threshold <= 0 ||
      !is.finite(relative_offset) || relative_offset <= 0) {
    stop("`yen_threshold`, `marais_threshold`, and `relative_offset` ",
         "must be finite positive numbers.", call. = FALSE)
  }
  if (is.null(diagnostics)) {
    diagnostics <- suppressMessages(
      diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "legacy")
    )
  }

  # Reuse the heatmap helper's payload; it already implements the
  # standardized-residual pivot + pairwise Pearson correlation that
  # Q3 is defined as.
  h <- plot_local_dependence_heatmap(
    fit = fit,
    diagnostics = diagnostics,
    facet = facet,
    min_pairs = as.integer(min_pairs),
    draw = FALSE
  )

  pairs_df <- as.data.frame(h$data$pairs %||% data.frame(),
                             stringsAsFactors = FALSE)
  if (nrow(pairs_df) == 0L) {
    return(structure(
      list(
        pairs = data.frame(Level1 = character(0), Level2 = character(0),
                            Q3 = numeric(0), N = integer(0),
                            AbsQ3 = numeric(0), YenFlag = logical(0),
                            MaraisFlag = logical(0),
                            RelativeFlag = logical(0),
                            Interpretation = character(0),
                            stringsAsFactors = FALSE),
        summary = data.frame(MeanQ3 = NA_real_, MaxAbsQ3 = NA_real_,
                              YenFlagged = 0L, MaraisFlagged = 0L,
                              RelativeFlagged = 0L,
                              stringsAsFactors = FALSE),
        thresholds = c(yen = yen_threshold,
                        marais = marais_threshold,
                        relative_offset = relative_offset),
        facet = facet
      ),
      class = c("mfrm_q3", "list")
    ))
  }

  pairs_df$Q3 <- suppressWarnings(as.numeric(pairs_df$ResidualCor))
  pairs_df$AbsQ3 <- abs(pairs_df$Q3)
  mean_q3 <- mean(pairs_df$Q3, na.rm = TRUE)

  pairs_df$YenFlag <- is.finite(pairs_df$AbsQ3) &
                       pairs_df$AbsQ3 > yen_threshold
  pairs_df$MaraisFlag <- is.finite(pairs_df$AbsQ3) &
                         pairs_df$AbsQ3 > marais_threshold
  pairs_df$RelativeFlag <- is.finite(pairs_df$Q3) &
                           abs(pairs_df$Q3 - mean_q3) > relative_offset

  pairs_df$Interpretation <- vapply(seq_len(nrow(pairs_df)), function(i) {
    flags <- character(0)
    if (isTRUE(pairs_df$MaraisFlag[i])) flags <- c(flags, "Marais (>0.30)")
    if (isTRUE(pairs_df$YenFlag[i]) && !isTRUE(pairs_df$MaraisFlag[i])) {
      flags <- c(flags, "Yen (>0.20)")
    }
    if (isTRUE(pairs_df$RelativeFlag[i])) flags <- c(flags, "Relative (Christensen)")
    if (length(flags) == 0L) "OK" else paste(flags, collapse = ", ")
  }, character(1))

  pairs_df <- pairs_df[order(pairs_df$AbsQ3, decreasing = TRUE), , drop = FALSE]

  summary_df <- data.frame(
    MeanQ3 = mean_q3,
    MaxAbsQ3 = max(pairs_df$AbsQ3, na.rm = TRUE),
    YenFlagged = sum(pairs_df$YenFlag, na.rm = TRUE),
    MaraisFlagged = sum(pairs_df$MaraisFlag, na.rm = TRUE),
    RelativeFlagged = sum(pairs_df$RelativeFlag, na.rm = TRUE),
    stringsAsFactors = FALSE
  )

  out <- list(
    pairs = pairs_df[, c("Level1", "Level2", "Q3", "N", "AbsQ3",
                          "YenFlag", "MaraisFlag", "RelativeFlag",
                          "Interpretation"), drop = FALSE],
    summary = summary_df,
    thresholds = c(yen = yen_threshold,
                   marais = marais_threshold,
                   relative_offset = relative_offset),
    facet = facet
  )
  class(out) <- c("mfrm_q3", "list")
  out
}

#' @export
print.mfrm_q3 <- function(x, ...) {
  cat("Yen Q3 local-dependence statistic\n")
  cat(sprintf("  Facet: %s\n", x$facet))
  cat(sprintf("  Mean Q3: %.3f | Max |Q3|: %.3f\n",
              x$summary$MeanQ3, x$summary$MaxAbsQ3))
  cat(sprintf("  Flagged pairs: Yen %d / Marais %d / Relative %d (of %d)\n",
              x$summary$YenFlagged, x$summary$MaraisFlagged,
              x$summary$RelativeFlagged, nrow(x$pairs)))
  cat(sprintf("  Thresholds: Yen %.2f | Marais %.2f | Relative offset %.2f\n",
              as.numeric(x$thresholds["yen"]),
              as.numeric(x$thresholds["marais"]),
              as.numeric(x$thresholds["relative_offset"])))
  invisible(x)
}
