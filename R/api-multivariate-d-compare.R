#' Compare prespecified multivariate D-study plans
#'
#' Estimate how much G, Phi or SEM changes from a reference plan, including
#' the dependence between plans estimated from the same G-study. This first
#' interval method requires two common random facets and an explicit normal
#' random-effects assumption.
#' @description Create a comparison with
#' `compare_mfrm(d, reference = 1, assumption = "normal")`.
#' @param x A saved plan comparison, for `plot()` or `print()`.
#' @section Input and options:
#' Supply one [mfrm_d_study()] result with at least two plans and
#' `negative_components = "raw"`. This inference does not describe
#' GENOVA-adjusted component estimators; supported population differences
#' alongside adjusted points use [confint.mfrm_multivariate_d_study()].
#' `reference` selects a row of the stored design grid (default 1).
#' Choose one original `score` or named `composite`; with neither supplied,
#' use the sole composite or the first score when there are no composites.
#' Several composites require selection. An explicit `assumption = "normal"`
#' asserts independent normal random-effect vectors with constant component
#' covariances; the assumption is not tested. `level` defaults to .95.
#' @details Use this comparison when choosing between plans specified before inspecting
#' their estimates. For example, compare two raters and six tasks with three
#' raters and four tasks. A positive G/Phi difference favors the comparison
#' plan; a negative SEM difference favors it. An interval containing zero means
#' the direction is uncertain, not that the plans are equivalent. Equal rating
#' counts do not establish equal examinee burden or cost.
#'
#' The current scope is two common random facets, complete balanced ANOVA or
#' identifiable incomplete crossed MINQUE(0), and future complete crossed plans.
#' Persons and both facets are sampled from their stated populations. The source
#' assignments are held fixed and must preserve the random-effect distributions.
#' One-facet, nested, fixed-facet, nonnormal-robust and informative-missingness
#' intervals are not provided. Ordinal score labels alone do not justify normal
#' effects. Incomplete source designs can have much weaker information than
#' complete designs with the same numbers of observed levels.
#' For G/Phi differences from a complete balanced one-facet ANOVA source, use
#' [confint.mfrm_multivariate_d_study()] with `parm = "G"` or `"Phi"` and
#' `reference`. Those methods map an F or generalized confidence set, respectively;
#' Phi retains approximate coverage. Neither uses this delta approximation.
#' The same generic supports one-facet `"RelativeSEM"` and `"AbsoluteSEM"`
#' differences by mapping a common error-SD interval. Relative SEM retains
#' exact positive-variance normal-model coverage; absolute SEM uses approximate MLS.
#' For general balanced crossed/nested two-facet plans, that generic also
#' accepts explicit `method = "mean_square_region"` with `reference` for
#' conservative G/Phi/SEM difference enclosures from shared source uncertainty.
#' These are not paired-delta intervals or tight joint difference images;
#' they can be wide. The delta method in this function keeps its crossed scope.
#'
#' The method uses raw estimated components in the Gaussian covariance of
#' quadratic-form estimates, then the delta method for paired differences and
#' a normal critical value. It uses the gradient of the difference, not a sum
#' of independent marginal variances. For a complete source design this agrees
#' with mean-square variances `2 * MS^2 / df`. These are approximate intervals,
#' not exact finite-sample guarantees. Small facet pools, uneven assignments
#' and estimates near boundaries can impair the approximation. In a bounded
#' assessment, a skewed-effect condition reduced nominal 95% coverage to about
#' 92%; this method must not be described as distribution robust.
#'
#' Negative components are retained and flagged. No components, differences
#' or interval endpoints are clipped. An unavailable point projection, boundary
#' derivative or nonpositive estimated difference variance leaves that interval
#' unavailable with a reason. Identical plans have an exact zero difference
#' when their point projections are available. Component and sampling-covariance
#' diagnostics do not establish model fit or interval accuracy.
#'
#' Intervals are pointwise for each prespecified comparison. They do not support
#' choosing the largest observed improvement, simultaneous claims over all rows,
#' or comparisons between adaptively selected score weights. SEM is measurement
#' error in score units; `SE` here is sampling uncertainty in the *difference*.
#'
#' Point projections are recomputed from the stored G-study using current rules;
#' no G-study is refitted and `x` is not modified. The G-study must retain its
#' analyzed data. For incomplete sources, covariance computation processes
#' blocks of rows to avoid a full observation-by-observation matrix; its running
#' time is still quadratic in the number of observed ratings.
#' @section Calculation and source of the approximation:
#' For one selected score or fixed composite, write its observed values as
#' the vector \eqn{z}. Its seven raw component estimates can be written as
#' \eqn{\hat\theta_s = z' A_s z}{theta_hat_s = z' A_s z}, where each symmetric \eqn{A_s} is fixed by
#' the observed design and removes the common mean: \eqn{A_s 1 = 0}.
#' For MINQUE(0), let \eqn{K_s} indicate shared levels for component \eqn{s},
#' \eqn{H = I - 11'/N}, \eqn{B_s = H K_s H}, and
#' \eqn{S_{st} = \mathrm{tr}(B_s B_t)}{S_st = tr(B_s B_t)}. Then
#' \eqn{A_s = \sum_t (S^{-1})_{st} B_t}. These are the moment equations
#' described in [mfrm_g_study()] and the MINQUE framework of Rao
#' (1971).
#'
#' Under the stated Gaussian model with covariance
#' \eqn{V = \sum_s \theta_s K_s}, the quadratic-form identity is
#' \deqn{C_{st} = \mathrm{Cov}(\hat\theta_s,\hat\theta_t)
#'              = 2\mathrm{tr}(A_s V A_t V).}{C_st = Cov(theta_hat_s, theta_hat_t) = 2 tr(A_s V A_t V).}
#' This follows from the product moment in Magnus (1978, p. 209), subtracting
#' the product of the expectations. The mean term vanishes because each
#' \eqn{A_s} removes the intercept. The identity concerns the **true** covariance;
#' this function substitutes raw estimated components into \eqn{V}.
#'
#' For a metric \eqn{f} and plans \eqn{a} and \eqn{b}, define
#' \eqn{h(\theta) = f_b(\theta) - f_a(\theta)} and
#' \eqn{g = \nabla f_b - \nabla f_a}{g = grad(f_b) - grad(f_a)}, evaluated at the component estimates.
#' The first-order delta approximation (Oehlert, 1992) gives
#' \deqn{\widehat{\mathrm{SE}}(\hat h) = \sqrt{g'\hat C g}.}{SE_hat(h_hat) = sqrt(g' C_hat g).}
#' The interval is \eqn{\hat h \pm z_{1-\alpha/2}\widehat{\mathrm{SE}}(\hat h)}{h_hat +/- z_(1-alpha/2) SE_hat(h_hat)},
#' where \eqn{\alpha = 1 - \mathrm{level}}{alpha = 1 - level}. Stacking the difference gradients
#' in \eqn{J} gives the returned joint covariance \eqn{J\hat C J'}{J C_hat J'}.
#'
#' Thus there are distinct steps: a Gaussian component-covariance identity,
#' substitution of estimates, linearization of the nonlinear metric, and a
#' normal reference interval. Only the first is an exact model identity.
#' The current balanced implementation uses the plug-in `2 * MS^2 / df`,
#' not the alternative `df + 2` moment correction. The references support
#' the G/D targets and these mathematical steps; none validates this entire
#' package procedure for every supported design. This is not an implementation
#' of all GENOVA-family interval methods.
#' @return An `mfrm_multivariate_d_comparison` list with `comparisons` (one row
#'   per comparison plan and metric), `covariance` (joint sampling covariance
#'   of those differences), `design_grid`, `reference`, selected score/composite
#'   and weights, `level`, `method`, and component/sampling-covariance diagnostics.
#'   `source_design` and `source_rows` retain the source method, observed level
#'   counts, completeness, score convention and row-use totals, without raw
#'   ratings or identifiers. `print()` displays these separately from the future
#'   plans and includes composite weights. Save the full comparison with
#'   `saveRDS()`; a CSV of `summary()` alone does not retain this context or
#'   the confidence level and approximation assumptions. Earlier saved
#'   comparisons without source context remain readable and say it is absent.
#'   `print()` returns the same comparison invisibly without recomputation.
#'   `summary()` returns the comparison table. `Status` describes interval
#'   availability; point differences can remain available without an interval.
#'   After [recommend_mfrm_design()] attaches costs and targets,
#'   `summary(x, planning = TRUE)` returns the saved planning tables and notes.
#' @references Brennan, R. L. (2001). *Generalizability theory*. Springer.
#' \doi{10.1007/978-1-4757-3456-0}. G/D targets and sampling variability.
#'
#' Rao, C. R. (1971). Estimation of variance and covariance components--MINQUE
#' theory. *Journal of Multivariate Analysis, 1*, 257--275.
#' \doi{10.1016/0047-259X(71)90001-7}. Component moment estimation.
#'
#' Magnus, J. R. (1978). The moments of products of quadratic forms in normal
#' variables. *Statistica Neerlandica, 32*(4), 201--210.
#' \doi{10.1111/j.1467-9574.1978.tb01399.x}. Gaussian product moments;
#' see p. 209.
#'
#' Oehlert, G. W. (1992). A note on the delta method.
#' *The American Statistician, 46*(1), 27--29.
#' \doi{10.1080/00031305.1992.10475842}. Taylor/moment approximation framework.
#' @seealso [mfrm_d_study()], [plot.mfrm_multivariate_d_comparison()]
#' @examples # Optional workflow; run the example explicitly as shown below.
#' # example("mfrm_d_study_comparison", run.dontrun = TRUE)
#' \dontrun{
#' # Existing fictional ratings: one row per Person-Rater-Task, two scores.
#' data("mfrmr_example_gtheory_crossed", package = "mfrmr")
#' ratings <- mfrmr_example_gtheory_crossed
#' head(ratings)
#' g <- mfrm_g_study(ratings, c("Content", "Organization"))
#' d <- mfrm_d_study(g,
#'   data.frame(Raters = c(2, 3, 4), Tasks = c(6, 4, 3)),
#'   weights = c(Content = .5, Organization = .5))
#' comparison <- compare_mfrm(d, reference = 1,
#'   assumption = "normal")
#' summary(comparison)
#' plot(comparison) # G/Phi for each plan, including the reference.
#' plot(comparison, type = "sem")
#' plot(comparison, view = "differences") # Paired difference intervals.
#' }
#' @name mfrm_d_study_comparison
#' @aliases mfrm_multivariate_d_compare
NULL

.mfrm_mvgt_component_covariance <- function(g, theta) {
  n <- g$design$counts
  data <- g$data
  ids <- c(g$design$person, if (is.null(g$design$facets)) c(g$design$rater, g$design$task) else
    unname(g$design$facets))
  if (!is.data.frame(data) || length(ids) != 3L || !all(ids %in% names(data)) ||
      nrow(data) != g$design$rows || anyNA(data[ids]) || anyDuplicated(data[ids]) ||
      !identical(unname(vapply(data[ids], function(x) length(unique(x)), integer(1))), unname(n))) {
    stop("The G-study must retain its analyzed data and matching facet identities; recreate the G-study.", call. = FALSE)
  }
  subsets <- list(1L, 2L, 3L, c(1L, 2L), c(1L, 3L), c(2L, 3L), 1:3)
  if (isTRUE(g$design$complete)) {
    if (nrow(data) != prod(as.double(n))) stop("The stored complete design is inconsistent.", call. = FALSE)
    L <- matrix(0, 7, 7)
    for (i in 1:7) for (j in 1:7) if (all(subsets[[i]] %in% subsets[[j]])) {
      L[i, j] <- prod(n[setdiff(1:3, subsets[[j]])])
    }
    inverse <- solve(L)
    df <- vapply(subsets, function(s) prod(n[s] - 1), numeric(1))
    C <- inverse %*% diag(2 * drop(L %*% theta)^2 / df) %*% t(inverse)
  } else {
    id_groups <- lapply(data[ids], factor)
    groups <- lapply(subsets, function(s) .mfrm_mvgt_group(id_groups[s]))
    S <- g$estimation$kernel_gram
    if (!is.matrix(S) || !identical(dim(S), c(7L, 7L)) || any(!is.finite(S))) {
      stop("The incomplete G-study needs its MINQUE covariance-component equations; recreate it.", call. = FALSE)
    }
    scale <- sqrt(diag(S))
    inverse <- solve(S / outer(scale, scale)) / outer(scale, scale)
    apply_V <- function(X) Reduce(`+`, lapply(1:7, function(j)
      theta[j] * rowsum(X, groups[[j]])[groups[[j]], , drop = FALSE]))
    apply_A <- function(X) {
      X <- sweep(X, 2L, colMeans(X), "-")
      B <- vapply(groups, function(group) {
        KX <- rowsum(X, group)[group, , drop = FALSE]
        as.vector(sweep(KX, 2L, colMeans(KX), "-"))
      }, numeric(length(X)))
      B %*% t(inverse)
    }
    N <- nrow(data)
    block <- max(1L, min(32L, floor(1e6 / N)))
    C <- matrix(0, 7, 7)
    for (first in seq.int(1L, N, by = block)) {
      columns <- seq.int(first, min(N, first + block - 1L))
      E <- matrix(0, N, length(columns))
      E[cbind(columns, seq_along(columns))] <- 1
      AV <- apply_A(apply_V(E))
      VA <- apply_V(matrix(apply_A(E), nrow = N))
      C <- C + 2 * crossprod(AV, matrix(VA, nrow = length(E)))
    }
  }
  if (any(!is.finite(C))) stop("Sampling covariance exceeds numeric range; review the design and rescale scores.", call. = FALSE)
  (C + t(C)) / 2
}

#' @rdname mfrm_d_study_comparison
#' @param object A saved plan comparison from `compare_mfrm(d, ...)`.
#' @param planning For `summary()`: `FALSE` returns the unchanged comparison
#'   table. `TRUE` returns the planning review attached by
#'   [recommend_mfrm_design()], without calculation.
#' @param ... For `summary.mfrm_multivariate_d_comparison()`: Further table-printing arguments for `print()`; unused arguments
#'   to `summary()` are rejected.
#'
#' For `plot()`: Reserved; additional arguments are rejected.
#' @export
summary.mfrm_multivariate_d_comparison <- function(object, ..., planning = FALSE) {
  rlang::check_dots_empty()
  if (!is.logical(planning) || length(planning) != 1L || is.na(planning))
    stop("`planning` must be TRUE or FALSE.", call. = FALSE)
  if (planning) {
    if (is.null(object$planning))
      stop("Attach costs and targets with recommend_mfrm_design() first.", call. = FALSE)
    return(object$planning)
  }
  object$comparisons
}

#' @rdname mfrm_d_study_comparison
#' @inheritParams print.mfrm_multivariate_gstudy
#' @export
print.mfrm_multivariate_d_comparison <- function(x, digits = NULL, row.names = FALSE, ...) {
  cat("D-study differences from reference scenario", x$reference, "\n")
  .mfrm_mvgt_print_source(x$source_design, x$source_rows)
  cat(x$kind, ": ", x$score, "\n", sep = "")
  if (identical(x$kind, "Composite")) {
    cat("Composite weights (not normalized):\n")
    print(x$weights, digits = digits)
  }
  cat("Future complete crossed plans; counts apply to every person and score.\n")
  if (!is.null(x$source_design$score_convention)) cat(x$source_design$score_convention, "\n")
  print(x$design_grid, digits = digits, row.names = row.names, ...)
  print(x$comparisons, digits = digits, row.names = row.names, ...)
  cat(format(100 * x$level), "% approximate pointwise intervals; normal random effects required.\n", sep = "")
  cat("Positive G/Phi or negative SEM differences favor the comparison plan.\n")
  cat("An interval containing zero does not establish equivalence.\n")
  if (any(!x$component_diagnostics$PositiveSemidefinite) || !x$sampling_covariance_psd) {
    cat("Non-PSD covariance estimates: inspect component and sampling-covariance diagnostics.\n")
  }
  if (!is.null(x$planning)) {
    cat("\nResource feasibility and point targets (all plans retained):\n")
    print(x$planning$plans, digits = digits, row.names = row.names, ...)
    print(x$planning$costs, digits = digits, row.names = row.names, ...)
    print(x$planning$differences[c("Scenario", "Metric", "Direction")], row.names = row.names)
    cat(paste(x$planning$notes, collapse = "\n"), "\n")
  }
  invisible(x)
}
