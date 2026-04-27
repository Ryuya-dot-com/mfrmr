# ==============================================================================
# Generalizability theory adapter (random rater / random item effects)
# ==============================================================================
#
# `mfrm_generalizability()` formalises the generalizability-theory
# (Cronbach et al. 1972 / Brennan 2001) decomposition that
# `compute_facet_icc()` already performs internally via
# `lme4::lmer`. The MFRM frames non-person facets as fixed effects
# for measurement; for reporting a G-coefficient, the same facets
# are re-fit as crossed random effects so the variance components
# can be combined into the canonical G / Phi indices.
#
# This helper does NOT re-fit the MFRM. It treats the rating data
# as a crossed random-effects ANOVA (Person + each non-person facet
# + residual) and returns the variance decomposition + G / Phi
# coefficients.

#' Generalizability-theory variance decomposition for an MFRM design
#'
#' Re-fits the rating data underlying an `mfrm_fit` as a crossed
#' random-effects model
#' `Score ~ 1 + (1 | Person) + (1 | Facet1) + ... + Residual`
#' via `lme4::lmer`, and returns the canonical G-theory variance
#' components plus G / Phi coefficients. Useful when reviewers ask
#' for a generalizability-theory complement to the Rasch-style
#' separation / reliability statistics that `diagnose_mfrm()`
#' already emits.
#'
#' @param fit An `mfrm_fit` from [fit_mfrm()].
#' @param data Optional data frame. When `NULL`, the rating data
#'   stored on `fit$prep$data` is used.
#' @param object_facet Facet that plays the role of the "object of
#'   measurement" -- typically `"Person"` (default).
#' @param random_facets Character vector of non-person facets to
#'   treat as random conditions of measurement. Default uses every
#'   facet other than `object_facet`.
#' @param reml Logical, passed to [lme4::lmer()] (default `TRUE`).
#'
#' @return An object of class `mfrm_generalizability` with:
#' \describe{
#'   \item{`variance_components`}{One row per random effect plus
#'     residual, with columns `Source`, `Variance`, and
#'     `ProportionVariance`.}
#'   \item{`coefficients`}{One-row data frame with `G`
#'     (generalizability coefficient, relative decision) and
#'     `Phi` (dependability coefficient, absolute decision).}
#'   \item{`design`}{Description of the crossed-random model.}
#' }
#'
#' @section Interpretation:
#' - `G` is appropriate for **relative** decisions (rank-ordering
#'   persons): `G = sigma2(p) / (sigma2(p) + sigma2(error_rel))` where
#'   the relative error term uses person x facet interactions but not
#'   facet main effects.
#' - `Phi` is appropriate for **absolute** decisions (cut-score
#'   classification): `Phi = sigma2(p) / (sigma2(p) + sigma2(error_abs))`
#'   where the absolute error term also includes facet main effects.
#' - Reporting bands follow Brennan (2001): G / Phi >= 0.8 for
#'   high-stakes decisions, >= 0.7 for routine reporting.
#'
#' @section References:
#' - Cronbach, L. J., Gleser, G. C., Nanda, H., & Rajaratnam, N.
#'   (1972). *The dependability of behavioral measurements: Theory
#'   of generalizability for scores and profiles*. Wiley.
#' - Brennan, R. L. (2001). *Generalizability theory*. Springer.
#'
#' @seealso [compute_facet_icc()], [diagnose_mfrm()]
#' @examples
#' \donttest{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' if (requireNamespace("lme4", quietly = TRUE)) {
#'   gt <- mfrm_generalizability(fit)
#'   gt$variance_components
#'   # Look for: a Person variance component well above any single
#'   #   non-person facet's variance share. Large rater or criterion
#'   #   variance shares mean those conditions add measurement error
#'   #   relative to person spread.
#'   gt$coefficients
#'   # Look for: G >= 0.7 for routine reporting, >= 0.8 for high-stakes.
#'   #   G < Phi means absolute decisions are noisier than relative
#'   #   decisions; review whether facet main effects need anchoring.
#' }
#' }
#' @export
mfrm_generalizability <- function(fit,
                                  data = NULL,
                                  object_facet = "Person",
                                  random_facets = NULL,
                                  reml = TRUE) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  if (!requireNamespace("lme4", quietly = TRUE)) {
    stop("`mfrm_generalizability()` requires the `lme4` package ",
         "(in Suggests). Install it and retry.", call. = FALSE)
  }
  if (is.null(data)) {
    data <- as.data.frame(fit$prep$data %||% data.frame(),
                          stringsAsFactors = FALSE)
  }
  if (!is.data.frame(data) || nrow(data) == 0L) {
    stop("`data` is empty or not a data frame.", call. = FALSE)
  }

  facet_names <- as.character(fit$config$facet_names %||% character(0))
  if (is.null(random_facets)) {
    random_facets <- setdiff(facet_names, object_facet)
  }
  random_facets <- as.character(random_facets)
  if (length(random_facets) == 0L) {
    stop("At least one non-person facet is required as a random ",
         "condition of measurement.", call. = FALSE)
  }
  needed_cols <- c(object_facet, random_facets, "Score")
  missing_cols <- setdiff(needed_cols, names(data))
  if (length(missing_cols) > 0L) {
    stop("Data frame is missing required columns: ",
         paste(missing_cols, collapse = ", "), ".", call. = FALSE)
  }

  for (col in c(object_facet, random_facets)) {
    if (!is.factor(data[[col]])) {
      data[[col]] <- as.factor(as.character(data[[col]]))
    }
  }
  data$Score <- suppressWarnings(as.numeric(data$Score))
  data <- data[is.finite(data$Score), , drop = FALSE]

  random_terms <- c(object_facet, random_facets)
  formula_str <- paste0(
    "Score ~ 1 + ",
    paste0("(1 | ", random_terms, ")", collapse = " + ")
  )
  formula <- stats::as.formula(formula_str)

  lmer_warnings <- character(0)
  fit_lmer <- tryCatch(
    withCallingHandlers(
      lme4::lmer(formula, data = data, REML = isTRUE(reml)),
      warning = function(w) {
        lmer_warnings <<- c(lmer_warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) e
  )
  if (inherits(fit_lmer, "error")) {
    stop("lme4::lmer failed: ", conditionMessage(fit_lmer), call. = FALSE)
  }

  vc <- as.data.frame(lme4::VarCorr(fit_lmer))
  vc <- vc[is.na(vc$var2), c("grp", "vcov")]
  total_var <- sum(vc$vcov, na.rm = TRUE)
  zero_tol <- sqrt(.Machine$double.eps)
  var_components <- data.frame(
    Source = as.character(vc$grp),
    Variance = round(as.numeric(vc$vcov), 6),
    ProportionVariance = if (is.finite(total_var) && total_var > zero_tol) {
      round(vc$vcov / total_var, 4)
    } else {
      rep(NA_real_, length(vc$vcov))
    },
    stringsAsFactors = FALSE
  )

  # G / Phi coefficients (single observation per cell convention).
  # Following Brennan (2001) for a crossed p x i design:
  #   G  = sigma2(p) / (sigma2(p) + sigma2(pi))
  #   Phi= sigma2(p) / (sigma2(p) + sigma2(i) + sigma2(pi))
  # Without an explicit interaction term in the formula above the
  # interaction variance is folded into the Residual term, which is
  # the standard one-observation-per-cell approximation.
  v <- stats::setNames(var_components$Variance, var_components$Source)
  sigma2_p <- as.numeric(v[object_facet] %||% NA_real_)
  sigma2_residual <- as.numeric(v["Residual"] %||% NA_real_)
  sigma2_main <- if (length(random_facets) > 0L) {
    sum(as.numeric(v[random_facets] %||% 0), na.rm = TRUE)
  } else 0
  if (!is.finite(sigma2_p) || sigma2_p <= 0) {
    G_coef <- NA_real_
    Phi_coef <- NA_real_
  } else {
    G_coef <- sigma2_p / (sigma2_p + sigma2_residual)
    Phi_coef <- sigma2_p / (sigma2_p + sigma2_main + sigma2_residual)
  }

  out <- list(
    variance_components = var_components,
    coefficients = data.frame(
      G = round(G_coef, 4),
      Phi = round(Phi_coef, 4),
      stringsAsFactors = FALSE
    ),
    design = list(
      object_facet = object_facet,
      random_facets = random_facets,
      formula = format(formula),
      reml = isTRUE(reml),
      lmer_warnings = lmer_warnings
    )
  )
  class(out) <- c("mfrm_generalizability", "list")
  out
}

#' @export
print.mfrm_generalizability <- function(x, ...) {
  cat("Generalizability-theory decomposition\n")
  cat(sprintf("  Object of measurement: %s\n",
              x$design$object_facet))
  cat(sprintf("  Random facets: %s\n",
              paste(x$design$random_facets, collapse = ", ")))
  cat("\nVariance components\n")
  print(x$variance_components, row.names = FALSE)
  cat(sprintf("\nG (relative): %.3f | Phi (absolute): %.3f\n",
              as.numeric(x$coefficients$G),
              as.numeric(x$coefficients$Phi)))
  if (length(x$design$lmer_warnings) > 0L) {
    cat(sprintf("\n%d lme4 warning(s) suppressed; results may be unstable.\n",
                length(x$design$lmer_warnings)))
  }
  invisible(x)
}
