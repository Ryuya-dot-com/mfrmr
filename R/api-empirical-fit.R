# Empirical fit plots and TAM-style fit p-value tables

mfrm_two_sided_z_p <- function(z) {
  z <- suppressWarnings(as.numeric(z))
  out <- rep(NA_real_, length(z))
  ok <- is.finite(z)
  out[ok] <- 2 * stats::pnorm(-abs(z[ok]))
  out
}

mfrm_adjust_p <- function(p, method) {
  p <- suppressWarnings(as.numeric(p))
  out <- rep(NA_real_, length(p))
  ok <- is.finite(p) & p >= 0 & p <= 1
  if (any(ok)) {
    out[ok] <- stats::p.adjust(p[ok], method = method)
  }
  out
}

mfrm_match_fit_reference <- function(reference) {
  reference <- tolower(as.character(reference[1] %||% "mfrmr"))
  aliases <- c(
    mfrmr = "mfrmr",
    package = "mfrmr",
    native = "mfrmr",
    facets = "facets",
    facets_df = "facets",
    facets_style = "facets",
    facets_like = "facets"
  )
  out <- unname(aliases[[reference]])
  if (is.null(out) || is.na(out)) {
    stop("`reference` must be one of 'mfrmr' or 'facets'.", call. = FALSE)
  }
  out
}

mfrm_match_zstd_cap <- function(zstd_cap) {
  zstd_cap <- tolower(as.character(zstd_cap[1] %||% "auto"))
  aliases <- c(
    auto = "auto",
    none = "none",
    no = "none",
    false = "none",
    facets = "facets",
    facets_cap = "facets"
  )
  out <- unname(aliases[[zstd_cap]])
  if (is.null(out) || is.na(out)) {
    stop("`zstd_cap` must be one of 'auto', 'none', or 'facets'.", call. = FALSE)
  }
  out
}

mfrm_zstd_cap_limit <- function(zstd_cap, reference) {
  zstd_cap <- mfrm_match_zstd_cap(zstd_cap)
  if (identical(zstd_cap, "auto")) {
    zstd_cap <- if (identical(reference, "facets")) "facets" else "none"
  }
  if (identical(zstd_cap, "facets")) 9 else Inf
}

mfrm_apply_zstd_cap <- function(z, cap = Inf) {
  z <- suppressWarnings(as.numeric(z))
  cap <- suppressWarnings(as.numeric(cap[1]))
  if (!is.finite(cap) || cap <= 0) return(z)
  pmin(pmax(z, -cap), cap)
}

mfrm_probability_fourth_moment <- function(probs) {
  if (is.null(probs) || !is.matrix(probs) || nrow(probs) == 0L) {
    return(numeric(0))
  }
  k_vals <- 0:(ncol(probs) - 1L)
  expected <- as.vector(probs %*% k_vals)
  diff <- sweep(
    matrix(k_vals, nrow = nrow(probs), ncol = ncol(probs), byrow = TRUE),
    1L,
    expected,
    "-"
  )
  as.numeric(rowSums(probs * diff^4))
}

mfrm_facets_df_one_group <- function(obs_df, cap = 9) {
  if (is.null(obs_df) || nrow(obs_df) == 0L) {
    return(data.frame(
      N = numeric(0), Infit = numeric(0), Outfit = numeric(0),
      DF_Infit = numeric(0), DF_Outfit = numeric(0),
      InfitZSTD = numeric(0), OutfitZSTD = numeric(0)
    ))
  }
  w <- get_weights(obs_df)
  var <- suppressWarnings(as.numeric(obs_df$Var))
  stdsq <- suppressWarnings(as.numeric(obs_df$StdSq))
  fourth <- suppressWarnings(as.numeric(obs_df$.FourthMoment))

  ok_mnsq <- is.finite(w) & w > 0 & is.finite(var) & var > 0 & is.finite(stdsq)
  n_w <- sum(w[ok_mnsq], na.rm = TRUE)
  info <- sum(var[ok_mnsq] * w[ok_mnsq], na.rm = TRUE)
  infit <- if (is.finite(info) && info > 0) {
    sum(stdsq[ok_mnsq] * var[ok_mnsq] * w[ok_mnsq], na.rm = TRUE) / info
  } else {
    NA_real_
  }
  outfit <- if (is.finite(n_w) && n_w > 0) {
    sum(stdsq[ok_mnsq] * w[ok_mnsq], na.rm = TRUE) / n_w
  } else {
    NA_real_
  }

  ok_df <- ok_mnsq & is.finite(fourth)
  df_out_denom <- sum(w[ok_df] * (fourth[ok_df] / (var[ok_df]^2) - 1), na.rm = TRUE)
  df_in_denom <- sum(w[ok_df] * (fourth[ok_df] - var[ok_df]^2), na.rm = TRUE)
  df_outfit <- if (is.finite(df_out_denom) && df_out_denom > 0 && n_w > 0) {
    2 * n_w^2 / df_out_denom
  } else {
    NA_real_
  }
  df_infit <- if (is.finite(df_in_denom) && df_in_denom > 0 && info > 0) {
    2 * info^2 / df_in_denom
  } else {
    NA_real_
  }

  data.frame(
    N = n_w,
    Infit = infit,
    Outfit = outfit,
    DF_Infit = df_infit,
    DF_Outfit = df_outfit,
    InfitZSTD = mfrm_apply_zstd_cap(zstd_from_mnsq(infit, df_infit), cap),
    OutfitZSTD = mfrm_apply_zstd_cap(zstd_from_mnsq(outfit, df_outfit), cap),
    stringsAsFactors = FALSE
  )
}

mfrm_facets_df_fit_source <- function(fit, diagnostics, scope, cap = 9) {
  if (identical(scope, "category")) {
    stop(
      "`reference = 'facets'` is available for element and person scopes, ",
      "not for score-category rows.",
      call. = FALSE
    )
  }
  model <- as.character(fit$config$model %||% fit$summary$Model[1] %||% NA_character_)
  if (!model %in% c("RSM", "PCM")) {
    warning(
      "`reference = 'facets'` is validated for RSM/PCM. For GPCM it is an ",
      "exploratory score-moment generalization, not a FACETS-equivalent statistic.",
      call. = FALSE
    )
  }

  obs <- as.data.frame(diagnostics$obs %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(obs) == 0L) {
    obs <- as.data.frame(compute_obs_table(fit), stringsAsFactors = FALSE)
  }
  probs <- compute_prob_matrix(fit)
  if (is.null(probs) || !is.matrix(probs) || nrow(probs) != nrow(obs)) {
    stop(
      "FACETS-style df requires observation-aligned category probabilities. ",
      "Recompute diagnostics from the original `fit` object.",
      call. = FALSE
    )
  }
  obs$.FourthMoment <- mfrm_probability_fourth_moment(probs)

  if (identical(scope, "person")) {
    facet_cols <- "Person"
  } else {
    facet_cols <- as.character(fit$config$facet_names %||% character(0))
    facet_cols <- setdiff(facet_cols, "Person")
  }
  facet_cols <- facet_cols[facet_cols %in% names(obs)]
  if (length(facet_cols) == 0L) return(data.frame())

  rows <- list()
  row_i <- 0L
  for (facet in facet_cols) {
    lev <- unique(as.character(obs[[facet]]))
    lev <- lev[!is.na(lev)]
    for (level in lev) {
      sub <- obs[as.character(obs[[facet]]) == level, , drop = FALSE]
      agg <- mfrm_facets_df_one_group(sub, cap = cap)
      if (nrow(agg) == 0L) next
      row_i <- row_i + 1L
      rows[[row_i]] <- cbind(
        data.frame(
          Scope = scope,
          Facet = facet,
          Level = level,
          parameter = if (identical(scope, "person")) level else paste(facet, level, sep = ":"),
          stringsAsFactors = FALSE
        ),
        agg
      )
    }
  }
  if (length(rows) == 0L) return(data.frame())
  do.call(rbind, rows)
}

mfrm_fit_p_source <- function(fit, diagnostics, scope) {
  if (identical(scope, "element")) {
    tbl <- as.data.frame(diagnostics$fit %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0L) return(tbl)
    if ("Facet" %in% names(tbl)) {
      tbl <- tbl[as.character(tbl$Facet) != "Person", , drop = FALSE]
      if (nrow(tbl) == 0L) return(tbl)
    }
    tbl$Scope <- "element"
    tbl$parameter <- paste(as.character(tbl$Facet), as.character(tbl$Level), sep = ":")
    return(tbl)
  }

  if (identical(scope, "person")) {
    tbl <- as.data.frame(diagnostics$measures %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0L || !"Facet" %in% names(tbl)) return(data.frame())
    tbl <- tbl[as.character(tbl$Facet) == "Person", , drop = FALSE]
    if (nrow(tbl) == 0L) return(tbl)
    tbl$Scope <- "person"
    tbl$parameter <- as.character(tbl$Level)
    return(tbl)
  }

  if (identical(scope, "category")) {
    rst <- rating_scale_table(fit, diagnostics = diagnostics)
    tbl <- as.data.frame(rst$category_table %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0L) return(tbl)
    tbl$Facet <- "Category"
    tbl$Level <- as.character(tbl$Category)
    tbl$N <- suppressWarnings(as.numeric(tbl$Count))
    tbl$Scope <- "category"
    tbl$parameter <- paste0("Category:", tbl$Level)
    return(tbl)
  }

  data.frame()
}

#' TAM-style Infit / Outfit p-value table
#'
#' Builds a compact fit table with TAM-style columns for mfrmr non-person
#' element-level, person-level, or score-category fit statistics. The output
#' keeps the familiar
#' `Outfit`, `Outfit_t`, `Outfit_p`, `Infit`, `Infit_t`, and `Infit_p`
#' layout, while also adding p-value adjustment columns and the active
#' `MisfitDirection` label used elsewhere in mfrmr.
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()]. When omitted,
#'   diagnostics are computed with `residual_pca = "none"`.
#' @param scope Which fit surface to report: `"element"` (default; non-person
#'   facet levels from `diagnostics$fit`), `"person"` (person rows from
#'   `diagnostics$measures`), or `"category"` (score categories from
#'   [rating_scale_table()]).
#' @param p_adjust P-value adjustment method passed to [stats::p.adjust()].
#'   Default `"holm"` mirrors the common TAM summary handoff.
#' @param alpha Significance level used for logical p-value flags.
#' @param lower,upper Optional MnSq screening band. `NULL` uses the active
#'   [mfrm_misfit_thresholds()] options.
#' @param reference Fit-standardization reference. `"mfrmr"` (default) keeps
#'   the package-native degrees of freedom (`DF_Outfit = sum(w)`,
#'   `DF_Infit = sum(w * Var)`). `"facets"` keeps the same MnSq aggregation
#'   but recomputes the Wilson-Hilferty degrees of freedom with the
#'   Wright-Masters/FACETS moment convention.
#' @param zstd_cap ZSTD cap policy. `"auto"` uses no cap for
#'   `reference = "mfrmr"` and the FACETS \eqn{\pm 9} cap for
#'   `reference = "facets"`. Use `"none"` or `"facets"` to override.
#'
#' @details
#' `fit_p_table()` is intentionally a reporting and screening table, not a new
#' model-fit estimator. For a reported set of rows \eqn{G}, let
#' \eqn{r_i = y_i - \hat{\mu}_i}, \eqn{v_i = \widehat{\mathrm{Var}}(Y_i)},
#' \eqn{z_i = r_i / \sqrt{v_i}}, and \eqn{w_i} be the case weight. mfrmr's
#' mean-square summaries are
#' \deqn{\mathrm{Outfit}_G =
#'   \frac{\sum_{i \in G} w_i z_i^2}{\sum_{i \in G} w_i}}
#' and
#' \deqn{\mathrm{Infit}_G =
#'   \frac{\sum_{i \in G} w_i v_i z_i^2}{\sum_{i \in G} w_i v_i}
#'   = \frac{\sum_{i \in G} w_i r_i^2}{\sum_{i \in G} w_i v_i}.}
#' The exported `Outfit_t` and `Infit_t` columns are mfrmr's existing
#' standardized transformations (`OutfitZSTD`, `InfitZSTD`). With the default
#' diagnostics these use the Wilson-Hilferty cube-root approximation
#' \deqn{Z =
#'   \frac{\mathrm{MnSq}^{1/3} - (1 - 2/(9\,df))}
#'        {\sqrt{2/(9\,df)}} ,}
#' where \eqn{df = \sum w_i} for outfit and \eqn{df = \sum w_i v_i} for
#' infit. The displayed p-values are two-sided normal-tail approximations,
#' \deqn{p = 2\Phi(-|Z|),}
#' followed by [stats::p.adjust()] for `*_p_adj`.
#'
#' With `reference = "facets"`, mfrmr recomputes only the df and ZSTD layer.
#' Let \eqn{C_i = E[(Y_i - E_i)^4]} be the model fourth central moment. The
#' FACETS-style df values are
#' \deqn{df_{\mathrm{Outfit}} =
#'   \frac{2(\sum_i w_i)^2}
#'        {\sum_i w_i(C_i / v_i^2 - 1)}}
#' and
#' \deqn{df_{\mathrm{Infit}} =
#'   \frac{2(\sum_i w_i v_i)^2}
#'        {\sum_i w_i(C_i - v_i^2)}.}
#' This branch is intended for FACETS migration and parity checks in RSM/PCM.
#' It does not change the fitted estimates or the MnSq values.
#'
#' The column names intentionally resemble `TAM::tam.fit()` output, but the
#' values are not guaranteed to equal TAM values. TAM's MML fit route is
#' simulation/posterior based and can evaluate item, facet, or contrast
#' hypotheses through its fit matrix interface. Likewise, `mirt::itemfit()`
#' treats `S_X2`, `X2`, `G2`, and `infit` as distinct item-fit families; the
#' mfrmr p-values here are not `S_X2` chi-square p-values.
#'
#' @references
#' Chalmers, R. P. (2012). mirt: A Multidimensional Item Response Theory
#' Package for the R Environment. \emph{Journal of Statistical Software},
#' 48(6), 1-29. \doi{10.18637/jss.v048.i06}
#'
#' mirt `itemfit()` reference:
#' \url{https://philchalmers.github.io/mirt/docs/reference/itemfit.html}
#'
#' TAM `tam.fit()` reference:
#' \url{https://alexanderrobitzsch.github.io/TAM/reference/tam.fit.html}
#'
#' TAM `msq.itemfit()` reference:
#' \url{https://alexanderrobitzsch.github.io/TAM/reference/msq.itemfit.html}
#'
#' @return A data frame with TAM-style fit columns plus mfrmr screening columns:
#' `Scope`, `parameter`, `Facet`, `Level`, `N`, `Outfit`, `Outfit_t`,
#' `Outfit_p`, `Outfit_p_adj`, `Infit`, `Infit_t`, `Infit_p`, `Infit_p_adj`,
#' `DF_Outfit`, `DF_Infit`, `DFMethod`, `FitReference`, `ZSTDCap`,
#' `MisfitDirection`, `MnSqFlag`, `PFlag`, and `PAdjustMethod`. When
#' `p_adjust = "holm"`, compatibility aliases `Outfit_pholm` and
#' `Infit_pholm` are also included.
#'
#' @seealso [diagnose_mfrm()], [plot_empirical_fit()], [plot_person_fit()]
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' tab <- fit_p_table(fit, diagnostics = diag)
#' head(tab[, c("parameter", "Outfit", "Outfit_p", "Outfit_p_adj",
#'              "Infit", "Infit_p", "Infit_p_adj", "MisfitDirection")])
#' facets_tab <- fit_p_table(fit, diagnostics = diag, reference = "facets")
#' head(facets_tab[, c("parameter", "DFMethod", "Outfit_t", "Outfit_p")])
#' fit_p_table(fit, diagnostics = diag, scope = "person")[1:3, ]
#'
#' \dontrun{
#' # Optional orientation against mirt/TAM on the same wide item matrix.
#' # Similar estimates can still yield different fit p values because each
#' # package uses its own estimation, scoring, and fit-test conventions.
#' toy$Score0 <- toy$Score - 1L
#' toy$Item <- paste(toy$Rater, toy$Criterion, sep = "__")
#' wide <- reshape(toy[, c("Person", "Item", "Score0")],
#'                 idvar = "Person", timevar = "Item", direction = "wide")
#' rownames(wide) <- wide$Person
#' resp <- wide[, setdiff(names(wide), "Person")]
#' names(resp) <- sub("^Score0\\.", "", names(resp))
#'
#' if (requireNamespace("TAM", quietly = TRUE)) {
#'   tam_fit <- TAM::tam.mml(resp = resp, irtmodel = "PCM2", verbose = FALSE)
#'   summary(TAM::tam.fit(tam_fit, progress = FALSE))
#' }
#' if (requireNamespace("mirt", quietly = TRUE)) {
#'   mirt_fit <- mirt::mirt(resp, 1, itemtype = "Rasch", verbose = FALSE)
#'   mirt::itemfit(mirt_fit, fit_stats = "infit", method = "ML")
#'   mirt::itemfit(mirt_fit, fit_stats = "S_X2")
#' }
#' }
#' @export
fit_p_table <- function(fit,
                        diagnostics = NULL,
                        scope = c("element", "person", "category"),
                        p_adjust = "holm",
                        alpha = 0.05,
                        lower = NULL,
                        upper = NULL,
                        reference = c("mfrmr", "facets"),
                        zstd_cap = c("auto", "none", "facets")) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  scope <- match.arg(scope)
  reference <- mfrm_match_fit_reference(reference)
  zstd_cap <- mfrm_match_zstd_cap(zstd_cap)
  zstd_cap_limit <- mfrm_zstd_cap_limit(zstd_cap, reference)
  p_adjust <- .validate_p_adjust_method(p_adjust)
  alpha <- suppressWarnings(as.numeric(alpha[1]))
  if (!is.finite(alpha) || alpha <= 0 || alpha >= 1) {
    stop("`alpha` must be a single number in (0, 1).", call. = FALSE)
  }
  if (is.null(diagnostics)) {
    diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
  }

  band <- mfrm_misfit_thresholds(lower = lower, upper = upper)
  lower <- as.numeric(band["lower"])
  upper <- as.numeric(band["upper"])

  tbl <- if (identical(reference, "facets")) {
    mfrm_facets_df_fit_source(fit, diagnostics, scope, cap = zstd_cap_limit)
  } else {
    mfrm_fit_p_source(fit, diagnostics, scope)
  }
  if (nrow(tbl) == 0L) {
    return(data.frame())
  }

  for (nm in c("Facet", "Level", "parameter", "Scope")) {
    if (!nm %in% names(tbl)) tbl[[nm]] <- NA_character_
  }
  for (nm in c("N", "Infit", "Outfit", "InfitZSTD", "OutfitZSTD", "DF_Infit", "DF_Outfit")) {
    if (!nm %in% names(tbl)) tbl[[nm]] <- NA_real_
    tbl[[nm]] <- suppressWarnings(as.numeric(tbl[[nm]]))
  }

  missing_infit_z <- !is.finite(tbl$InfitZSTD) & is.finite(tbl$Infit) & is.finite(tbl$DF_Infit)
  if (any(missing_infit_z)) {
    tbl$InfitZSTD[missing_infit_z] <- zstd_from_mnsq(
      tbl$Infit[missing_infit_z],
      tbl$DF_Infit[missing_infit_z]
    )
  }
  missing_outfit_z <- !is.finite(tbl$OutfitZSTD) & is.finite(tbl$Outfit) & is.finite(tbl$DF_Outfit)
  if (any(missing_outfit_z)) {
    tbl$OutfitZSTD[missing_outfit_z] <- zstd_from_mnsq(
      tbl$Outfit[missing_outfit_z],
      tbl$DF_Outfit[missing_outfit_z]
    )
  }
  tbl$InfitZSTD <- mfrm_apply_zstd_cap(tbl$InfitZSTD, zstd_cap_limit)
  tbl$OutfitZSTD <- mfrm_apply_zstd_cap(tbl$OutfitZSTD, zstd_cap_limit)

  infit_p <- mfrm_two_sided_z_p(tbl$InfitZSTD)
  outfit_p <- mfrm_two_sided_z_p(tbl$OutfitZSTD)
  infit_p_adj <- mfrm_adjust_p(infit_p, p_adjust)
  outfit_p_adj <- mfrm_adjust_p(outfit_p, p_adjust)
  direction <- mfrm_classify_mnsq_direction(
    tbl$Infit,
    tbl$Outfit,
    lower = lower,
    upper = upper
  )
  mnsq_flag <- direction %in% c("underfit", "overfit", "mixed")
  p_flag <- (is.finite(infit_p_adj) & infit_p_adj <= alpha) |
    (is.finite(outfit_p_adj) & outfit_p_adj <= alpha)

  out <- data.frame(
    Scope = as.character(tbl$Scope),
    parameter = as.character(tbl$parameter),
    Facet = as.character(tbl$Facet),
    Level = as.character(tbl$Level),
    N = tbl$N,
    DF_Outfit = tbl$DF_Outfit,
    DF_Infit = tbl$DF_Infit,
    DFMethod = if (identical(reference, "facets")) "facets_moment" else "mfrmr_information",
    FitReference = reference,
    ZSTDCap = if (is.finite(zstd_cap_limit)) zstd_cap_limit else NA_real_,
    Outfit = tbl$Outfit,
    Outfit_t = tbl$OutfitZSTD,
    Outfit_p = outfit_p,
    Outfit_p_adj = outfit_p_adj,
    Infit = tbl$Infit,
    Infit_t = tbl$InfitZSTD,
    Infit_p = infit_p,
    Infit_p_adj = infit_p_adj,
    MisfitDirection = direction,
    MnSqFlag = mnsq_flag,
    PFlag = p_flag,
    Alpha = alpha,
    PAdjustMethod = p_adjust,
    stringsAsFactors = FALSE
  )
  if (identical(p_adjust, "holm")) {
    out$Outfit_pholm <- out$Outfit_p_adj
    out$Infit_pholm <- out$Infit_p_adj
  }
  ord_metric <- pmax(
    ifelse(is.finite(out$Outfit_t), abs(out$Outfit_t), 0),
    ifelse(is.finite(out$Infit_t), abs(out$Infit_t), 0),
    na.rm = TRUE
  )
  out[order(out$PFlag, out$MnSqFlag, ord_metric, decreasing = TRUE), , drop = FALSE]
}

mfrm_resolve_empirical_target <- function(fit, diagnostics, facet, level) {
  facet_names <- c("Person", as.character(fit$config$facet_names %||% character(0)))
  facet_names <- unique(facet_names[!is.na(facet_names) & nzchar(facet_names)])
  if (length(facet_names) == 0L) {
    stop("`fit` does not expose any facet names.", call. = FALSE)
  }

  if (is.null(facet) || !nzchar(as.character(facet[1]))) {
    non_person <- setdiff(facet_names, "Person")
    facet <- if (length(non_person) > 0L) non_person[1] else facet_names[1]
  } else {
    facet <- as.character(facet[1])
  }
  if (!facet %in% facet_names) {
    stop("`facet` must be one of: ", paste(facet_names, collapse = ", "), ".",
         call. = FALSE)
  }

  obs <- as.data.frame(diagnostics$obs %||% data.frame(), stringsAsFactors = FALSE)
  if (!facet %in% names(obs)) {
    stop("`diagnostics$obs` does not include facet column `", facet, "`.",
         call. = FALSE)
  }
  levels_available <- unique(as.character(obs[[facet]]))
  levels_available <- levels_available[!is.na(levels_available) & nzchar(levels_available)]
  if (length(levels_available) == 0L) {
    stop("No observed levels are available for facet `", facet, "`.",
         call. = FALSE)
  }

  if (is.null(level) || !nzchar(as.character(level[1]))) {
    fit_tbl <- as.data.frame(diagnostics$fit %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(fit_tbl) > 0L && all(c("Facet", "Level", "Infit", "Outfit") %in% names(fit_tbl))) {
      fit_sub <- fit_tbl[as.character(fit_tbl$Facet) == facet, , drop = FALSE]
      if (nrow(fit_sub) > 0L) {
        infit <- suppressWarnings(as.numeric(fit_sub$Infit))
        outfit <- suppressWarnings(as.numeric(fit_sub$Outfit))
        score <- pmax(
          ifelse(is.finite(infit), abs(log(pmax(infit, 1e-6))), 0),
          ifelse(is.finite(outfit), abs(log(pmax(outfit, 1e-6))), 0),
          na.rm = TRUE
        )
        level <- as.character(fit_sub$Level[which.max(score)])
      }
    }
    if (is.null(level) || !nzchar(as.character(level[1]))) {
      level <- levels_available[1]
    }
  } else {
    level <- as.character(level[1])
  }
  if (!level %in% levels_available) {
    stop("`level` must be an observed level of `", facet, "`. Available examples: ",
         paste(utils::head(levels_available, 8), collapse = ", "), ".",
         call. = FALSE)
  }

  list(facet = facet, level = level)
}

mfrm_empirical_bin_ids <- function(theta, bins) {
  theta <- suppressWarnings(as.numeric(theta))
  bins <- max(1L, as.integer(bins[1]))
  out <- rep(NA_integer_, length(theta))
  ok <- is.finite(theta)
  n_ok <- sum(ok)
  if (n_ok == 0L) return(out)
  bins <- min(bins, n_ok)
  ord <- which(ok)[order(theta[ok])]
  out[ord] <- pmax(1L, ceiling(seq_along(ord) * bins / n_ok))
  out
}

mfrm_empirical_fit_bins <- function(df, bins, min_bin_n) {
  df$.Bin <- mfrm_empirical_bin_ids(df$PersonMeasure, bins)
  df <- df[is.finite(df$.Bin), , drop = FALSE]
  if (nrow(df) == 0L) return(data.frame())
  min_bin_n <- max(1L, as.integer(min_bin_n[1]))
  split_df <- split(df, df$.Bin)
  rows <- lapply(split_df, function(d) {
    w <- d$.Weight
    obs <- d$.ObservedMetric
    exp <- d$.ExpectedMetric
    total_w <- sum(w, na.rm = TRUE)
    se <- if (is.finite(total_w) && total_w > 0) {
      sqrt(sum((w^2) * d$.ExpectedVar, na.rm = TRUE)) / total_w
    } else {
      NA_real_
    }
    observed <- weighted_mean(obs, w)
    expected <- weighted_mean(exp, w)
    data.frame(
      Bin = as.integer(d$.Bin[1]),
      Rows = nrow(d),
      N = total_w,
      ThetaMin = min(d$PersonMeasure, na.rm = TRUE),
      ThetaMax = max(d$PersonMeasure, na.rm = TRUE),
      MeanPersonMeasure = weighted_mean(d$PersonMeasure, w),
      Observed = observed,
      Expected = expected,
      Residual = observed - expected,
      SE = se,
      StdResidual = if (is.finite(se) && se > 0) (observed - expected) / se else NA_real_,
      LowN = is.finite(total_w) && total_w < min_bin_n,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out[order(out$Bin), , drop = FALSE]
}

#' mirt-style empirical fit plot for an MFRM facet level
#'
#' Plots observed response behavior against model-expected behavior across
#' person-measure bins for one facet level. This gives a mirt-inspired
#' empirical fit view for many-facet models: points show empirical bin means
#' (or empirical category proportions), and the line shows the corresponding
#' fitted-model expectation in the same bins.
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()]. When omitted,
#'   diagnostics are computed with `residual_pca = "none"`.
#' @param facet Facet to inspect. `NULL` uses the first non-person facet.
#' @param level Level within `facet`. `NULL` chooses the most extreme
#'   element-level MnSq row within the selected facet, falling back to the
#'   first observed level.
#' @param category Optional score category. When `NULL`, the plot compares
#'   observed and expected mean score. When supplied, the plot compares the
#'   observed category proportion with the fitted category probability.
#' @param bins Number of approximately equal-count person-measure bins.
#' @param min_bin_n Minimum weighted bin size flagged in the returned table.
#' @param draw If `TRUE`, draw with base graphics.
#' @param preset Visual preset.
#' @param main Optional plot title.
#'
#' @details
#' This is a descriptive empirical overlay, not mirt's `S_X2` test and not a
#' replacement for strict marginal diagnostics. It is designed for the common
#' research workflow: identify a level with [fit_p_table()],
#' [plot_bubble()], or `summary(diagnose_mfrm(...))`, then inspect where the
#' observed response curve departs from the fitted model across the person
#' measure scale.
#'
#' The plot forms approximately equal-count bins \eqn{B_b} after sorting rows
#' by `PersonMeasure`. For the mean-score view, each bin reports
#' \deqn{\bar{y}_b = \frac{\sum_{i \in B_b} w_i y_i}{\sum_{i \in B_b} w_i},
#' \qquad
#' \bar{\mu}_b = \frac{\sum_{i \in B_b} w_i \hat{\mu}_i}
#'                    {\sum_{i \in B_b} w_i}.}
#' The displayed standard error is
#' \deqn{SE_b =
#'   \frac{\sqrt{\sum_{i \in B_b} w_i^2 v_i}}{\sum_{i \in B_b} w_i}.}
#' For the category-probability view, \eqn{y_i} is replaced by
#' \eqn{I(Y_i = k)}, \eqn{\hat{\mu}_i} by
#' \eqn{\hat{p}_{ik} = P(Y_i = k)}, and \eqn{v_i} by
#' \eqn{\hat{p}_{ik}(1 - \hat{p}_{ik})}.
#'
#' This resembles the empirical overlays in `mirt::itemfit(empirical.plot=...)`
#' because both compare empirical bin behavior to expected model curves.
#' However, mirt's `S_X2.plot` is constructed from conditional sum-score
#' information used by the `S_X2` statistic, while this mfrmr plot bins by
#' estimated person measure for a selected facet level and does not return a
#' chi-square statistic, degrees of freedom, RMSEA, or `p.S_X2`.
#'
#' @references
#' Chalmers, R. P. (2012). mirt: A Multidimensional Item Response Theory
#' Package for the R Environment. \emph{Journal of Statistical Software},
#' 48(6), 1-29. \doi{10.18637/jss.v048.i06}
#'
#' mirt `itemfit()` reference:
#' \url{https://philchalmers.github.io/mirt/docs/reference/itemfit.html}
#'
#' @return An `mfrm_plot_data` object. The `bin_table` / `data` slot contains
#' `Bin`, `N`, `MeanPersonMeasure`, `Observed`, `Expected`, `Residual`, `SE`,
#' `StdResidual`, and `LowN`; `raw_table` contains the filtered row-level
#' metrics used to build the bins.
#'
#' @seealso [fit_p_table()], [plot_bubble()], [plot_person_fit()],
#'   [plot_qc_dashboard()]
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' p <- plot_empirical_fit(fit, diagnostics = diag,
#'                         facet = "Rater", bins = 5, draw = FALSE)
#' p$data$target
#' p$data$bin_table
#' p_cat <- plot_empirical_fit(fit, diagnostics = diag,
#'                             facet = "Rater", category = 4,
#'                             bins = 5, draw = FALSE)
#' p_cat$data$metric
#'
#' \dontrun{
#' # mirt's empirical plot is item-based; this mfrmr plot is facet-level.
#' # Use it as an observed-vs-expected diagnostic layer, not as S_X2.
#' plot_empirical_fit(fit, diagnostics = diag,
#'                    facet = "Rater", level = "R01", bins = 6)
#' }
#' @export
plot_empirical_fit <- function(fit,
                               diagnostics = NULL,
                               facet = NULL,
                               level = NULL,
                               category = NULL,
                               bins = 10L,
                               min_bin_n = 5L,
                               draw = TRUE,
                               preset = c("standard", "publication", "compact"),
                               main = NULL) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  if (is.null(diagnostics)) {
    diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
  }
  if (is.null(diagnostics$obs) || nrow(diagnostics$obs) == 0L) {
    stop("`diagnostics$obs` is empty. Run diagnose_mfrm() first.",
         call. = FALSE)
  }
  bins <- suppressWarnings(as.integer(bins[1]))
  if (!is.finite(bins) || bins < 1L) {
    stop("`bins` must be a positive integer.", call. = FALSE)
  }
  min_bin_n <- suppressWarnings(as.integer(min_bin_n[1]))
  if (!is.finite(min_bin_n) || min_bin_n < 1L) {
    stop("`min_bin_n` must be a positive integer.", call. = FALSE)
  }
  style <- resolve_plot_preset(preset)
  target <- mfrm_resolve_empirical_target(fit, diagnostics, facet, level)
  obs <- as.data.frame(diagnostics$obs, stringsAsFactors = FALSE)
  obs$.RowId <- seq_len(nrow(obs))
  obs <- obs[as.character(obs[[target$facet]]) == target$level, , drop = FALSE]
  if (nrow(obs) == 0L) {
    stop("No observations remain for the selected facet level.", call. = FALSE)
  }
  needed <- c("Person", "PersonMeasure", "Observed", "Expected", "Var")
  missing_cols <- setdiff(needed, names(obs))
  if (length(missing_cols) > 0L) {
    stop("`diagnostics$obs` is missing required columns: ",
         paste(missing_cols, collapse = ", "), ".", call. = FALSE)
  }

  obs$.Weight <- get_weights(obs)
  metric <- "mean_score"
  category_value <- NA_real_
  if (is.null(category)) {
    obs$.ObservedMetric <- suppressWarnings(as.numeric(obs$Observed))
    obs$.ExpectedMetric <- suppressWarnings(as.numeric(obs$Expected))
    obs$.ExpectedVar <- pmax(suppressWarnings(as.numeric(obs$Var)), 0)
    ylab <- "Mean score"
  } else {
    category_value <- suppressWarnings(as.numeric(category[1]))
    if (!is.finite(category_value) ||
        category_value != as.integer(category_value) ||
        category_value < fit$prep$rating_min ||
        category_value > fit$prep$rating_max) {
      stop("`category` must be an integer score category in the fitted rating range [",
           fit$prep$rating_min, ", ", fit$prep$rating_max, "].",
           call. = FALSE)
    }
    probs <- compute_prob_matrix(fit)
    if (nrow(probs) != nrow(diagnostics$obs)) {
      stop("Could not align fitted category probabilities with diagnostics rows.",
           call. = FALSE)
    }
    col_idx <- as.integer(category_value - fit$prep$rating_min + 1)
    p_cat <- probs[obs$.RowId, col_idx]
    obs$.ObservedMetric <- as.numeric(suppressWarnings(as.numeric(obs$Observed)) == category_value)
    obs$.ExpectedMetric <- p_cat
    obs$.ExpectedVar <- pmax(p_cat * (1 - p_cat), 0)
    metric <- "category_probability"
    ylab <- paste0("Pr(score = ", category_value, ")")
  }

  ok <- is.finite(obs$PersonMeasure) &
    is.finite(obs$.ObservedMetric) &
    is.finite(obs$.ExpectedMetric) &
    is.finite(obs$.Weight) &
    obs$.Weight > 0
  obs <- obs[ok, , drop = FALSE]
  if (nrow(obs) == 0L) {
    stop("No finite observations remain for empirical fit plotting.",
         call. = FALSE)
  }

  bin_tbl <- mfrm_empirical_fit_bins(obs, bins = bins, min_bin_n = min_bin_n)
  if (nrow(bin_tbl) == 0L) {
    stop("Could not form empirical fit bins.", call. = FALSE)
  }

  fit_tab <- fit_p_table(fit, diagnostics = diagnostics, scope = "element")
  fit_row <- fit_tab[
    as.character(fit_tab$Facet) == target$facet &
      as.character(fit_tab$Level) == target$level,
    ,
    drop = FALSE
  ]
  if (nrow(fit_row) > 1L) fit_row <- fit_row[1, , drop = FALSE]

  plot_title <- if (!is.null(main) && nzchar(as.character(main[1]))) {
    as.character(main[1])
  } else {
    paste0("Empirical fit: ", target$facet, ":", target$level)
  }
  plot_subtitle <- if (identical(metric, "mean_score")) {
    "Observed bin mean score vs fitted expected score"
  } else {
    paste0("Observed bin proportion vs fitted category probability (category ", category_value, ")")
  }

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    ylim <- range(
      c(bin_tbl$Observed, bin_tbl$Expected,
        bin_tbl$Observed - 1.96 * bin_tbl$SE,
        bin_tbl$Observed + 1.96 * bin_tbl$SE),
      finite = TRUE
    )
    if (!all(is.finite(ylim)) || diff(ylim) == 0) {
      ylim <- range(c(bin_tbl$Observed, bin_tbl$Expected, 0, 1), finite = TRUE)
    }
    graphics::plot(
      x = bin_tbl$MeanPersonMeasure,
      y = bin_tbl$Observed,
      pch = 21,
      bg = style$accent_primary,
      col = "white",
      xlab = "Person measure (logit)",
      ylab = ylab,
      main = plot_title,
      ylim = ylim
    )
    graphics::title(sub = plot_subtitle, line = 2.2, cex.sub = 0.9)
    graphics::lines(
      x = bin_tbl$MeanPersonMeasure,
      y = bin_tbl$Expected,
      col = style$fail,
      lwd = 2
    )
    ci_ok <- is.finite(bin_tbl$SE) & bin_tbl$SE > 0
    if (any(ci_ok)) {
      graphics::arrows(
        x0 = bin_tbl$MeanPersonMeasure[ci_ok],
        y0 = bin_tbl$Observed[ci_ok] - 1.96 * bin_tbl$SE[ci_ok],
        x1 = bin_tbl$MeanPersonMeasure[ci_ok],
        y1 = bin_tbl$Observed[ci_ok] + 1.96 * bin_tbl$SE[ci_ok],
        length = 0.03,
        angle = 90,
        code = 3,
        col = grDevices::adjustcolor(style$neutral, alpha.f = 0.65)
      )
    }
    graphics::legend(
      "topleft",
      legend = c("Observed bins", "Model expected"),
      pch = c(21, NA),
      pt.bg = c(style$accent_primary, NA),
      lty = c(NA, 1),
      col = c(style$accent_primary, style$fail),
      bty = "n",
      cex = 0.85
    )
  }

  raw_keep <- unique(intersect(
    c("Person", target$facet, "PersonMeasure", "Observed", "Expected",
      ".ObservedMetric", ".ExpectedMetric", ".ExpectedVar", ".Weight"),
    names(obs)
  ))
  raw_tbl <- obs[, raw_keep, drop = FALSE]
  names(raw_tbl) <- sub("^\\.", "", names(raw_tbl))

  out <- new_mfrm_plot_data(
    "empirical_fit",
    list(
      data = bin_tbl,
      bin_table = bin_tbl,
      raw_table = raw_tbl,
      fit_table = fit_row,
      target = data.frame(
        Facet = target$facet,
        Level = target$level,
        Category = category_value,
        stringsAsFactors = FALSE
      ),
      metric = metric,
      title = plot_title,
      subtitle = plot_subtitle,
      legend = new_plot_legend(
        label = c("Observed bins", "Model expected"),
        role = c("empirical", "model"),
        aesthetic = c("point", "line"),
        value = c(style$accent_primary, style$fail)
      ),
      reference_lines = new_reference_lines(),
      preset = style$name
    )
  )
  invisible(out)
}
