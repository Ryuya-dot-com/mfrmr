#' Check residual dimensionality with parallel-analysis thresholds
#'
#' @param x Output from [fit_mfrm()], [diagnose_mfrm()], or
#'   [analyze_residual_pca()].
#' @param mode Residual matrix scope: `"both"`, `"overall"`, or `"facet"`.
#' @param facets Optional facet subset for facet-level matrices. When supplied,
#'   the same subset is also used to form the overall combined-facet residual
#'   matrix.
#' @param method Null-generation method. `"residual_normal"` simulates
#'   independent standard-normal residual matrices with the same missingness
#'   pattern; `"permutation"` permutes observed standardized residuals within
#'   each residual column; `"parametric"` simulates responses from the fitted
#'   model and is available only when `x` is an `mfrm_fit`.
#' @param reps Number of null replications.
#' @param quantile Parallel-analysis quantile used as the decision threshold.
#'   The default `.95` follows the conservative Glorfeld-style convention.
#' @param pca_max_factors Maximum number of components retained in output, or
#'   `"auto"` to use the matrix rank cap used by [analyze_residual_pca()].
#' @param seed Optional random seed for reproducible null simulations.
#'
#' @details
#' This function adds a simulation-calibrated layer to the residual PCA tools.
#' It compares each observed residual eigenvalue with eigenvalues obtained
#' under a unidimensional null reference.
#'
#' The three null methods answer different questions:
#' - `"residual_normal"` is Horn-style parallel analysis on independent
#'   normal residual matrices with the observed matrix shape and missingness.
#' - `"permutation"` preserves the empirical column distributions of the
#'   standardized residual matrix, while removing cross-column association.
#' - `"parametric"` samples categorical responses from the fitted `mfrmr`
#'   model, then recomputes standardized residual matrices using the fitted
#'   expected scores and variances. It preserves the observed design and the
#'   fitted category-response model, but it does not refit the model in each
#'   replication.
#'
#' The procedure is exploratory. It is not FACETS ZSTD, TAM itemfit ZSTD,
#' or mirt's S-X2 item-fit statistic. It is a residual-structure diagnostic
#' for deciding whether residual components are larger than expected under a
#' chosen null reference.
#'
#' @return
#' An object of class `mfrm_residual_dimensionality`, containing:
#' - `observed`: observed residual PCA eigenvalue table
#' - `null_distribution`: replication-level null eigenvalues
#' - `comparison`: observed eigenvalues joined to null mean, SD, and quantile
#' - `settings`: method, repetitions, quantile, and PCA settings
#'
#' @section Mathematical definition:
#' For a standardized residual matrix `R`, `mfrmr` computes the eigenvalues
#' of the positive-definite adjusted residual correlation matrix. In parallel
#' analysis, the observed eigenvalue `lambda_j` is compared with a null
#' threshold `q_j`, the selected quantile of simulated null eigenvalues for
#' component `j`. The component is flagged when `lambda_j > q_j`.
#'
#' @section References:
#' - Horn, J. L. (1965). A rationale and test for the number of factors in
#'   factor analysis. *Psychometrika*, 30, 179-185.
#' - Glorfeld, L. W. (1995). An improvement on Horn's parallel analysis
#'   methodology. *Educational and Psychological Measurement*, 55, 377-393.
#' - Linacre, J. M. (1998). Structure in Rasch residuals: Why principal
#'   components analysis (PCA)? *Rasch Measurement Transactions*, 12(2), 636.
#' - Linacre, J. M. (1998). Detecting multidimensionality: Which residual
#'   data-type works best? *Journal of Outcome Measurement*, 2(3), 266-283.
#' - Chou, Y.-T., & Wang, W.-C. (2010). Checking dimensionality in item
#'   response models with principal component analysis on standardized
#'   residuals. *Educational and Psychological Measurement*, 70, 717-731.
#' - Timmerman, M. E., & Lorenzo-Seva, U. (2011). Dimensionality assessment of
#'   ordered polytomous items with parallel analysis. *Psychological Methods*,
#'   16, 209-220.
#'
#' @seealso [analyze_residual_pca()], [plot_residual_dimensionality()],
#'   [plot_residual_pca()]
#' @examples
#' \donttest{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 20)
#' dim_check <- check_residual_dimensionality(
#'   fit,
#'   mode = "overall",
#'   method = "parametric",
#'   reps = 5,
#'   seed = 123
#' )
#' dim_check
#' head(as.data.frame(dim_check))
#' plot_residual_dimensionality(dim_check, draw = FALSE)$data$data
#' }
#' @export
check_residual_dimensionality <- function(x,
                                          mode = c("both", "overall", "facet"),
                                          facets = NULL,
                                          method = c("residual_normal", "permutation", "parametric"),
                                          reps = 100L,
                                          quantile = 0.95,
                                          pca_max_factors = 10L,
                                          seed = NULL) {
  mode <- match.arg(tolower(as.character(mode[1])), c("both", "overall", "facet"))
  method <- match.arg(tolower(as.character(method[1])), c("residual_normal", "permutation", "parametric"))
  reps <- as.integer(reps[1])
  if (!is.finite(reps) || reps < 1L) stop("`reps` must be a positive integer.")
  quantile <- suppressWarnings(as.numeric(quantile[1]))
  if (!is.finite(quantile) || quantile <= 0 || quantile >= 1) {
    stop("`quantile` must be a number between 0 and 1.")
  }
  pca_max_factors <- .resolve_pca_max_factors(pca_max_factors)

  if (!is.null(seed)) {
    old_seed_exists <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    old_seed <- if (old_seed_exists) get(".Random.seed", envir = .GlobalEnv) else NULL
    set.seed(as.integer(seed[1]))
    on.exit({
      if (old_seed_exists) {
        assign(".Random.seed", old_seed, envir = .GlobalEnv)
      } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
        rm(".Random.seed", envir = .GlobalEnv)
      }
    }, add = TRUE)
  }

  fit <- if (inherits(x, "mfrm_fit")) x else NULL
  if (inherits(x, "mfrm_residual_pca")) {
    if (method == "parametric") {
      stop("`method = \"parametric\"` requires an `mfrm_fit` object.")
    }
    pca <- x
    diagnostics <- NULL
  } else {
    if (inherits(x, "mfrm_fit")) {
      diagnostics <- diagnose_mfrm(
        x,
        residual_pca = "none",
        pca_max_factors = pca_max_factors
      )
    } else if (is.list(x) && !is.null(x$obs)) {
      diagnostics <- x
    } else {
      stop("`x` must be output from fit_mfrm(), diagnose_mfrm(), or analyze_residual_pca().")
    }
    if (method == "parametric" && is.null(fit)) {
      stop("`method = \"parametric\"` requires an `mfrm_fit` object.")
    }
    pca <- analyze_residual_pca(
      diagnostics,
      mode = mode,
      facets = facets,
      pca_max_factors = pca_max_factors
    )
  }

  bundles <- collect_residual_dimensionality_bundles(pca, mode = mode, facets = facets)
  observed <- build_residual_dimensionality_observed(bundles, pca_max_factors = pca_max_factors)
  if (nrow(observed) == 0L) {
    stop("No observed residual PCA eigenvalues were available for dimensionality checking.")
  }

  null_distribution <- if (method == "parametric") {
    build_parametric_residual_dimensionality_null(
      fit = fit,
      diagnostics = diagnostics,
      mode = mode,
      facets = pca$facet_names,
      reps = reps,
      pca_max_factors = pca_max_factors
    )
  } else {
    build_matrix_residual_dimensionality_null(
      bundles = bundles,
      method = method,
      reps = reps,
      pca_max_factors = pca_max_factors
    )
  }
  if (nrow(null_distribution) == 0L) {
    stop("No null eigenvalues could be computed for residual dimensionality checking.")
  }

  comparison <- compare_residual_dimensionality(
    observed = observed,
    null_distribution = null_distribution,
    quantile = quantile
  )

  out <- list(
    method = method,
    mode = mode,
    facets = pca$facet_names %||% character(0),
    reps = reps,
    quantile = quantile,
    pca_max_factors = pca_max_factors,
    observed = observed,
    null_distribution = null_distribution,
    comparison = comparison,
    settings = data.frame(
      Method = method,
      Mode = mode,
      Reps = reps,
      Quantile = quantile,
      PCAMaxFactors = if (is.na(pca_max_factors)) "auto" else as.character(pca_max_factors),
      stringsAsFactors = FALSE
    )
  )
  as_mfrm_bundle(out, "mfrm_residual_dimensionality")
}

collect_residual_dimensionality_bundles <- function(pca, mode = "both", facets = NULL) {
  out <- list()
  if (mode %in% c("overall", "both") && !is.null(pca$overall)) {
    out[[length(out) + 1L]] <- list(scope = "overall", facet = "Overall", bundle = pca$overall)
  }
  if (mode %in% c("facet", "both") && !is.null(pca$by_facet) && length(pca$by_facet) > 0L) {
    by <- pca$by_facet
    if (!is.null(facets)) {
      by <- by[intersect(names(by), as.character(facets))]
    }
    for (facet in names(by)) {
      out[[length(out) + 1L]] <- list(scope = "facet", facet = facet, bundle = by[[facet]])
    }
  }
  if (length(out) == 0L) {
    stop("No residual PCA bundles were available for the requested `mode` and `facets`.")
  }
  out
}

build_residual_dimensionality_observed <- function(bundles, pca_max_factors = 10L) {
  tbls <- lapply(bundles, function(entry) {
    tbl <- build_pca_variance_table(entry$bundle)
    if (nrow(tbl) == 0L) return(data.frame())
    tbl <- cap_component_table(tbl, pca_max_factors = pca_max_factors)
    data.frame(
      Scope = entry$scope,
      Facet = entry$facet,
      Component = tbl$Component,
      ObservedEigenvalue = tbl$Eigenvalue,
      ObservedProportion = tbl$Proportion,
      ObservedCumulative = tbl$Cumulative,
      stringsAsFactors = FALSE
    )
  })
  tbls <- tbls[vapply(tbls, nrow, integer(1)) > 0L]
  if (length(tbls) == 0L) data.frame() else dplyr::bind_rows(tbls)
}

cap_component_table <- function(tbl, pca_max_factors = 10L) {
  if (is.na(pca_max_factors) || !is.finite(pca_max_factors)) return(tbl)
  cap <- max(1L, as.integer(pca_max_factors))
  tbl[tbl$Component <= cap, , drop = FALSE]
}

build_matrix_residual_dimensionality_null <- function(bundles,
                                                      method = c("residual_normal", "permutation"),
                                                      reps = 100L,
                                                      pca_max_factors = 10L) {
  method <- match.arg(method)
  tbls <- list()
  idx <- 1L
  for (entry in bundles) {
    mat <- entry$bundle$residual_matrix %||% NULL
    if (is.null(mat)) next
    mat <- as.matrix(mat)
    for (rep_id in seq_len(reps)) {
      sim_mat <- if (method == "residual_normal") {
        simulate_independent_residual_matrix(mat)
      } else {
        permute_residual_matrix_columns(mat)
      }
      eig <- residual_matrix_eigenvalues(sim_mat, pca_max_factors = pca_max_factors)
      if (length(eig) == 0L) next
      tbls[[idx]] <- data.frame(
        Scope = entry$scope,
        Facet = entry$facet,
        Rep = rep_id,
        Component = seq_along(eig),
        NullEigenvalue = eig,
        stringsAsFactors = FALSE
      )
      idx <- idx + 1L
    }
  }
  if (length(tbls) == 0L) data.frame() else dplyr::bind_rows(tbls)
}

simulate_independent_residual_matrix <- function(mat) {
  out <- matrix(stats::rnorm(length(mat)), nrow = nrow(mat), ncol = ncol(mat))
  dimnames(out) <- dimnames(mat)
  out[is.na(mat)] <- NA_real_
  out
}

permute_residual_matrix_columns <- function(mat) {
  out <- mat
  for (j in seq_len(ncol(out))) {
    ok <- which(!is.na(out[, j]))
    if (length(ok) > 1L) {
      out[ok, j] <- sample(out[ok, j], length(ok), replace = FALSE)
    }
  }
  out
}

residual_matrix_eigenvalues <- function(mat, pca_max_factors = 10L) {
  if (is.null(mat)) return(numeric(0))
  mat <- as.matrix(mat)
  storage.mode(mat) <- "numeric"
  if (nrow(mat) < 2L || ncol(mat) < 2L) return(numeric(0))
  keep <- colSums(!is.na(mat)) > 1L
  mat <- mat[, keep, drop = FALSE]
  if (ncol(mat) < 2L) return(numeric(0))
  cor_mat <- tryCatch(
    suppressWarnings(stats::cor(mat, use = "pairwise.complete.obs")),
    error = function(e) NULL
  )
  if (is.null(cor_mat) || nrow(cor_mat) < 2L) return(numeric(0))
  cor_mat[is.na(cor_mat)] <- 0
  diag(cor_mat) <- 1
  cor_mat <- ensure_positive_definite(cor_mat)
  eig <- tryCatch(
    suppressWarnings(as.numeric(eigen(cor_mat, symmetric = TRUE, only.values = TRUE)$values)),
    error = function(e) numeric(0)
  )
  eig <- eig[is.finite(eig)]
  if (length(eig) == 0L) return(eig)
  if (!is.na(pca_max_factors) && is.finite(pca_max_factors)) {
    eig <- head(eig, max(1L, as.integer(pca_max_factors)))
  }
  eig
}

build_parametric_residual_dimensionality_null <- function(fit,
                                                          diagnostics,
                                                          mode = "both",
                                                          facets = NULL,
                                                          reps = 100L,
                                                          pca_max_factors = 10L) {
  if (is.null(fit) || is.null(diagnostics) || is.null(diagnostics$obs)) {
    return(data.frame())
  }
  prob <- compute_prob_matrix(fit)
  if (is.null(prob) || nrow(prob) == 0L || ncol(prob) == 0L) return(data.frame())
  prob <- as.matrix(prob)
  prob[!is.finite(prob)] <- 0
  row_sums <- rowSums(prob)
  if (any(row_sums <= 0)) return(data.frame())
  prob <- prob / row_sums

  score_values <- seq(fit$prep$rating_min, by = 1L, length.out = ncol(prob))
  obs <- diagnostics$obs
  if (nrow(obs) != nrow(prob)) {
    stop("The fitted probability matrix and diagnostics$obs have different row counts.")
  }
  facet_names <- facets
  if (is.null(facet_names) || length(facet_names) == 0L) {
    facet_names <- infer_facet_names(diagnostics)
  }
  facet_names <- as.character(facet_names)
  tbls <- list()
  idx <- 1L
  for (rep_id in seq_len(reps)) {
    sampled <- vapply(seq_len(nrow(prob)), function(i) {
      sample(score_values, size = 1L, prob = prob[i, ])
    }, numeric(1))
    sim_obs <- obs
    sim_obs$Observed <- sampled
    sim_obs$Residual <- sim_obs$Observed - sim_obs$Expected
    var_ok <- is.finite(sim_obs$Var) & sim_obs$Var > 0
    sim_obs$StdResidual <- NA_real_
    sim_obs$StdResidual[var_ok] <- sim_obs$Residual[var_ok] / sqrt(sim_obs$Var[var_ok])
    sim_obs$StdSq <- sim_obs$StdResidual^2

    if (mode %in% c("overall", "both")) {
      overall <- compute_pca_overall(sim_obs, facet_names = facet_names, max_factors = pca_max_factors)
      tbl <- build_pca_variance_table(overall)
      if (nrow(tbl) > 0L) {
        tbl <- cap_component_table(tbl, pca_max_factors = pca_max_factors)
        tbls[[idx]] <- data.frame(
          Scope = "overall",
          Facet = "Overall",
          Rep = rep_id,
          Component = tbl$Component,
          NullEigenvalue = tbl$Eigenvalue,
          stringsAsFactors = FALSE
        )
        idx <- idx + 1L
      }
    }

    if (mode %in% c("facet", "both")) {
      by_facet <- compute_pca_by_facet(sim_obs, facet_names = facet_names, max_factors = pca_max_factors)
      for (facet in names(by_facet)) {
        tbl <- build_pca_variance_table(by_facet[[facet]])
        if (nrow(tbl) == 0L) next
        tbl <- cap_component_table(tbl, pca_max_factors = pca_max_factors)
        tbls[[idx]] <- data.frame(
          Scope = "facet",
          Facet = facet,
          Rep = rep_id,
          Component = tbl$Component,
          NullEigenvalue = tbl$Eigenvalue,
          stringsAsFactors = FALSE
        )
        idx <- idx + 1L
      }
    }
  }
  if (length(tbls) == 0L) data.frame() else dplyr::bind_rows(tbls)
}

compare_residual_dimensionality <- function(observed, null_distribution, quantile = 0.95) {
  null_summary <- null_distribution |>
    dplyr::group_by(.data$Scope, .data$Facet, .data$Component) |>
    dplyr::summarize(
      NullMean = mean(.data$NullEigenvalue, na.rm = TRUE),
      NullSD = stats::sd(.data$NullEigenvalue, na.rm = TRUE),
      NullQuantile = as.numeric(stats::quantile(
        .data$NullEigenvalue,
        probs = quantile,
        na.rm = TRUE,
        names = FALSE,
        type = 7
      )),
      NullReps = dplyr::n(),
      .groups = "drop"
    )
  out <- dplyr::left_join(
    observed,
    null_summary,
    by = c("Scope", "Facet", "Component")
  )
  out$Excess <- out$ObservedEigenvalue - out$NullQuantile
  out$ExcessRatio <- out$ObservedEigenvalue / out$NullQuantile
  out$ExceedsNull <- ifelse(is.finite(out$Excess), out$Excess > 0, NA)
  out$Decision <- ifelse(
    is.na(out$ExceedsNull),
    "no_null_threshold",
    ifelse(out$ExceedsNull,
    "exceeds_parallel_threshold",
    "within_parallel_threshold")
  )
  out
}

#' Coerce residual dimensionality output to a data frame
#'
#' @param x Output from [check_residual_dimensionality()].
#' @param row.names Ignored.
#' @param optional Ignored.
#' @param component Component to return: `"comparison"`, `"observed"`, or
#'   `"null_distribution"`.
#' @param ... Additional arguments ignored.
#'
#' @return A data frame.
#' @export
as.data.frame.mfrm_residual_dimensionality <- function(x,
                                                       row.names = NULL,
                                                       optional = FALSE,
                                                       component = c("comparison", "observed", "null_distribution"),
                                                       ...) {
  component <- match.arg(component)
  as.data.frame(x[[component]], stringsAsFactors = FALSE)
}

#' @export
print.mfrm_residual_dimensionality <- function(x, ...) {
  cat("<mfrm_residual_dimensionality>\n")
  cat("  method   : ", x$method %||% "<unknown>", "\n", sep = "")
  cat("  mode     : ", x$mode %||% "<unknown>", "\n", sep = "")
  cat("  reps     : ", x$reps %||% NA_integer_, "\n", sep = "")
  cat("  quantile : ", x$quantile %||% NA_real_, "\n", sep = "")
  cmp <- x$comparison %||% data.frame()
  if (nrow(cmp) > 0L) {
    flagged <- sum(cmp$ExceedsNull %||% FALSE, na.rm = TRUE)
    cat("  flagged  : ", flagged, " of ", nrow(cmp), " components\n", sep = "")
    print(utils::head(cmp, n = min(8L, nrow(cmp))), row.names = FALSE)
  }
  invisible(x)
}

#' @export
summary.mfrm_residual_dimensionality <- function(object, ...) {
  cmp <- object$comparison %||% data.frame()
  overview <- data.frame(
    Method = object$method %||% NA_character_,
    Mode = object$mode %||% NA_character_,
    Reps = object$reps %||% NA_integer_,
    Quantile = object$quantile %||% NA_real_,
    Components = nrow(cmp),
    Exceeding = if (nrow(cmp) > 0L) sum(cmp$ExceedsNull, na.rm = TRUE) else 0L,
    stringsAsFactors = FALSE
  )
  flagged <- if (nrow(cmp) > 0L) {
    cmp[!is.na(cmp$ExceedsNull) & cmp$ExceedsNull, , drop = FALSE]
  } else {
    data.frame()
  }
  out <- list(
    overview = overview,
    flagged = flagged,
    comparison = cmp
  )
  class(out) <- c("summary.mfrm_residual_dimensionality", "list")
  out
}

#' @export
print.summary.mfrm_residual_dimensionality <- function(x, ...) {
  cat("<summary.mfrm_residual_dimensionality>\n")
  print(x$overview, row.names = FALSE)
  if (!is.null(x$flagged) && nrow(x$flagged) > 0L) {
    cat("\nFlagged residual components:\n")
    print(x$flagged, row.names = FALSE)
  } else {
    cat("\nNo residual components exceeded the selected parallel-analysis threshold.\n")
  }
  invisible(x)
}

#' Plot residual dimensionality parallel-analysis output
#'
#' @param x Output from [check_residual_dimensionality()].
#' @param mode `"overall"` or `"facet"`.
#' @param facet Facet to plot when `mode = "facet"`. If omitted, the first
#'   available facet is used.
#' @param components Optional component indices to display.
#' @param draw If `TRUE`, draw the plot using base graphics.
#' @param preset Visual preset (`"standard"`, `"publication"`, or `"compact"`).
#'
#' @return An `mfrm_plot_data` object. The payload contains the comparison
#'   table used for plotting and can be inspected or saved.
#' @seealso [check_residual_dimensionality()], [plot_residual_pca()]
#' @examples
#' \donttest{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 20)
#' dim_check <- check_residual_dimensionality(fit, mode = "overall",
#'                                            method = "parametric", reps = 5)
#' plot_residual_dimensionality(dim_check, draw = FALSE)
#' }
#' @export
plot_residual_dimensionality <- function(x,
                                         mode = c("overall", "facet"),
                                         facet = NULL,
                                         components = NULL,
                                         draw = TRUE,
                                         preset = c("standard", "publication", "compact")) {
  if (!inherits(x, "mfrm_residual_dimensionality")) {
    stop("`x` must be output from check_residual_dimensionality().")
  }
  mode <- match.arg(tolower(as.character(mode[1])), c("overall", "facet"))
  style <- resolve_plot_preset(preset)
  cmp <- x$comparison %||% data.frame()
  if (nrow(cmp) == 0L) stop("No comparison table is available to plot.")
  cmp <- cmp[cmp$Scope == mode, , drop = FALSE]
  if (mode == "facet") {
    available <- unique(cmp$Facet)
    available <- available[!is.na(available) & nzchar(available)]
    if (length(available) == 0L) stop("No facet-level dimensionality results are available.")
    if (is.null(facet)) facet <- available[1]
    if (!facet %in% available) stop("Requested `facet` is not available in `x`.")
    cmp <- cmp[cmp$Facet == facet, , drop = FALSE]
  }
  if (!is.null(components)) {
    cmp <- cmp[cmp$Component %in% as.integer(components), , drop = FALSE]
  }
  if (nrow(cmp) == 0L) stop("No rows remain after applying plot filters.")
  cmp <- cmp[order(cmp$Component), , drop = FALSE]

  title <- if (mode == "overall") {
    "Residual Dimensionality Parallel Analysis"
  } else {
    paste0("Residual Dimensionality Parallel Analysis - ", facet)
  }
  subtitle <- paste0(
    "Observed residual eigenvalues vs ",
    formatC(100 * x$quantile, digits = 3, format = "fg"),
    "% null quantile (", x$method, ")"
  )
  y_lim <- range(c(cmp$ObservedEigenvalue, cmp$NullMean, cmp$NullQuantile), na.rm = TRUE)
  if (!all(is.finite(y_lim))) y_lim <- c(0, 1)
  y_lim[1] <- min(0, y_lim[1])

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    graphics::plot(
      cmp$Component,
      cmp$ObservedEigenvalue,
      type = "b",
      pch = 16,
      col = style$accent_primary,
      ylim = y_lim,
      xlab = "Component",
      ylab = "Eigenvalue",
      main = title
    )
    graphics::lines(cmp$Component, cmp$NullQuantile, type = "b", pch = 17,
                    lty = 2, col = style$accent_secondary)
    graphics::lines(cmp$Component, cmp$NullMean, type = "b", pch = 1,
                    lty = 3, col = style$neutral)
    graphics::abline(h = 1, lty = 3, col = style$grid)
    graphics::legend(
      "topright",
      legend = c("Observed", "Null quantile", "Null mean"),
      col = c(style$accent_primary, style$accent_secondary, style$neutral),
      pch = c(16, 17, 1),
      lty = c(1, 2, 3),
      bty = "n"
    )
  }

  invisible(new_mfrm_plot_data(
    "residual_dimensionality",
    list(
      plot = "parallel_analysis",
      mode = mode,
      facet = if (mode == "facet") facet else NULL,
      title = title,
      subtitle = subtitle,
      legend = new_plot_legend(
        label = c("Observed", "Null quantile", "Null mean"),
        role = c("observed", "threshold", "null_mean"),
        aesthetic = c("line-point", "line-point", "line-point"),
        value = c(style$accent_primary, style$accent_secondary, style$neutral)
      ),
      reference_lines = new_reference_lines("h", 1, "Unit eigenvalue", "dotted", "reference"),
      data = cmp,
      preset = style$name
    )
  ))
}
