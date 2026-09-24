#' Describe posterior predictive residuals for ordinary and extended RSMs
#'
#' Integrate uncertain abilities and local or shared-rater effects before
#' computing response means, variances and descriptive Infit/Outfit summaries.
#' @param fit A numerically ready native RSM MML [fit_mfrm()],
#'   [fit_mfrm_testlet()] or [fit_mfrm_random_rater()] result.
#' @param rows Distinct original input row numbers to return, or `NULL` for
#'   all assigned rows. This selects outputs only: every observed source rating
#'   still informs the joint posterior. Groups summarize the selected rows.
#' @param group_by Fitted identifier columns to summarize separately. `NULL`
#'   uses all Person, testlet/rater and fixed-facet columns. No grouping by score.
#' @param quad_points Normal quadrature order, 7 to 121 for testlets or 7 to
#'   241 for ordinary RSMs or shared raters. Defaults to the saved fit's order.
#'   Results are checked at `2 * quad_points + 1`;
#'   each category probability must change by no more than `1e-7`.
#' @details Calibration is held fixed. For a replicate rating sharing the
#'   original row's latent effects, the target is
#'   \deqn{p_{ik}=E[P(Y_i^{rep}=k\mid b,\widehat\psi)\mid
#'     Y_{obs},\widehat\psi],}
#'   where b includes ability, and for extensions the local effect or jointly
#'   uncertain shared-rater vector. This uses the same observed data for
#'   estimation and checking; it is not held-out prediction. Define
#'   \deqn{\mu_i=\sum_k k p_{ik},\qquad
#'     V_i=\sum_k (k-\mu_i)^2p_{ik}.}
#'   The mixture variance includes both conditional rating variance and
#'   variance of conditional means. Substituting an ability/rater estimate or
#'   averaging conditional variances alone gives a different quantity.
#'
#'   For selected observed unit-weight rows in a group, descriptive Outfit is
#'   the mean of \eqn{(y_i-\mu_i)^2/V_i}; descriptive Infit is
#'   \eqn{\sum_i(y_i-\mu_i)^2/\sum_i V_i}. These summaries have no established
#'   expectation of one. There are no default cutoffs, ZSTD, p-values, automatic
#'   flags or rater-quality classifications. Ordinary plug-in Infit/Outfit
#'   values do not have the same probability definition and must not be
#'   compared directly. No response covariance or calibration uncertainty is
#'   supplied, so these results do not calibrate a formal goodness-of-fit test.
#'
#'   Ordinary RSMs integrate normal ability by quadrature, retaining every
#'   observed rating of the relevant Person. Supported ordinary fits have
#'   unit weights, additive unanchored severity facets, no interactions or
#'   shrinkage, Person as the noncentered facet, consecutive integer source
#'   categories, and either known N(0,1) or `population_formula = ~1`.
#'   The estimated population mean and variance are both retained. This
#'   separate route does not alter the plug-in indices from [diagnose_mfrm()].
#'   Old fits that omitted scores without retaining original row positions
#'   need to be refitted from the complete assigned-score roster.
#'
#'   Testlets use nested normal quadrature. Shared raters use category-specific
#'   Laplace integrals of the complete likelihood times the replicate category
#'   probability, after integrating abilities by quadrature. Each numerator
#'   reoptimizes the joint latent rater mode; calibration is never refitted.
#'   The positive numerator integrals are normalized across categories.
#'   `NormalizationError` records the unnormalized probability sum minus one.
#'   This defect and agreement between quadrature orders are numerical
#'   diagnostics, not bounds on the Laplace approximation error. In particular,
#'   small defects do not certify accuracy with few raters or sparse ratings.
#'   Shared-rater work grows with requested rows and categories; use `rows`
#'   to inspect a subset while retaining the complete conditioning data.
#'
#'   Missing scores remain `missing_score`; they are not imputed. Nonfinite
#'   or zero predictive variances and unresolved integration remain unavailable
#'   with a reason. A group containing any unavailable observed row has no
#'   summary, rather than silently dropping that row. Entirely missing groups
#'   have no summary. A fitted zero latent variance defines the corresponding
#'   submodel's predictions; it does not establish absence of heterogeneity.
#' @return An `mfrm_response_diagnostics` object with `rows`, category
#'   `probabilities`, grouped `measures`, settings and exact source metadata.
#'   Save with `saveRDS()`; attach via
#'   `mfrm_results(fit, response_diagnostics = result, compute = "never")`.
#'   Supply two saved outputs to [compare_mfrm()] for aligned ordinary versus
#'   extended-model comparisons, using the same selected events and group_by.
#'   Collecting, plotting and exporting saved results never recomputes integrals.
#' @references Tierney, L., & Kadane, J. B. (1986). Accurate approximations
#'   for posterior moments and marginal densities. Journal of the American
#'   Statistical Association, 81(393), 82--86.
#'   \doi{10.1080/01621459.1986.10478240}. This supports the ratio-of-integrals
#'   approximation, not universal accuracy for this rating design.
#' @seealso [plot.mfrm_response_diagnostics()], [mfrm_results()],
#'   [score_mfrm_random_rater()], [predict.mfrm_testlet()]
#' @examples
#' example <- readRDS(system.file("examples", "extended-models.rds", package = "mfrmr"))
#' fit <- example$testlet$fit
#' residuals <- example$testlet$diagnostics
#' # To recompute the posterior predictive residuals:
#' # residuals <- mfrm_response_diagnostics(fit, group_by = "Rater")
#' residuals$measures
#' plot(residuals)
#' mfrm_results(fit, response_diagnostics = residuals, compute = "never")
#' @export
mfrm_response_diagnostics <- function(fit, rows = NULL, group_by = NULL,
    quad_points = fit$settings$quad_points %||% fit$config$estimation_control$quad_points) {
  ordinary <- inherits(fit, "mfrm_fit")
  if (!ordinary && (!mfrm_extended_fit(fit) || !isTRUE(fit$checks$NumericalReady) ||
      !isTRUE(fit$checks$InformationPositive))) stop("Supply a numerically ready ordinary RSM MML, testlet or shared-rater fit; review its numerical and information checks.", call. = FALSE)
  testlet <- inherits(fit, "mfrm_testlet"); maximum <- if (testlet) 121 else 241
  if (!is.numeric(quad_points) || is.complex(quad_points) || length(quad_points) != 1L ||
      !is.finite(quad_points) || quad_points != floor(quad_points) || quad_points < 7 || quad_points > maximum) stop("Invalid quad_points for this model.", call. = FALSE)
  input <- if (ordinary) mfrm_ordinary_response_input(fit) else fit$input
  columns <- input$columns
  if (is.null(input$assigned_data) && length(input$omitted_rows)) stop("The saved fit lacks its original missing-score roster; recover the complete fitted object.", call. = FALSE)
  source_data <- input$assigned_data %||% input$data
  n <- nrow(source_data); rows <- rows %||% seq_len(n)
  if (!is.numeric(rows) || is.complex(rows) || !is.null(dim(rows)) || !length(rows) || anyNA(rows) ||
      any(rows != floor(rows)) || any(rows < 1 | rows > n) || anyDuplicated(rows)) stop("`rows` must contain distinct original input row numbers.", call. = FALSE)
  identifiers <- setdiff(names(source_data), columns$score)
  group_by <- group_by %||% identifiers
  if (!is.character(group_by) || !length(group_by) || anyNA(group_by) ||
      anyDuplicated(group_by) || !all(group_by %in% identifiers)) stop("Choose distinct fitted identifier columns for group_by.", call. = FALSE)
  table <- data.frame(InputRow = rows, Score = source_data[[columns$score]][rows])
  observed <- which(!is.na(source_data[[columns$score]]))
  index <- match(rows, observed); valid <- which(!is.na(index))
  nc <- length(input$score_levels)
  probabilities <- matrix(NA_real_, length(rows), nc, dimnames = list(as.character(rows), as.character(input$score_levels)))
  table$ExpectedScore <- table$PredictiveVariance <- table$SquaredResidual <-
    table$StandardizedResidual <- table$IntegrationDifference <- table$NormalizationError <- NA_real_
  table$Status <- ifelse(is.na(index), "missing_score", "unavailable")
  table$Reason <- ifelse(is.na(index), "Assigned score is missing; no residual was computed.", "")
  # One testlet calculation per Person; shared raters require row-specific
  # numerator integrals, with all Persons retained in every integral.
  batches <- if (testlet || ordinary) split(valid, source_data[[columns$person]][rows[valid]]) else as.list(valid)
  normalizers <- list()
  for (batch in batches) {
    answer <- tryCatch(withCallingHandlers({
      calculate <- function(q) {
        if (ordinary) return(mfrm_ordinary_response_probabilities(input, index[batch], q))
        if (testlet) return(mfrm_testlet_response_probabilities(input, fit$parameters, index[batch], q))
        value <- mfrm_random_rater_response_probabilities(input, fit$calibration, index[batch], q,
          logden = normalizers[[as.character(q)]])
        normalizers[[as.character(q)]] <<- value$logden
        value
      }
      low <- calculate(quad_points); high <- calculate(2L * quad_points + 1L)
      delta <- apply(abs(high$probabilities - low$probabilities), 1L, max)
      list(high = high, delta = delta)
    }, warning = function(w) stop(conditionMessage(w), call. = FALSE)),
    error = function(e) { table$Reason[batch] <<- conditionMessage(e); NULL })
    if (is.null(answer)) next
    table$IntegrationDifference[batch] <- answer$delta
    table$NormalizationError[batch] <- answer$high$normalization_error
    for (j in seq_along(batch)) {
      at <- batch[j]; p <- answer$high$probabilities[j, ]
      if (any(!is.finite(p)) || any(p < 0) || abs(sum(p) - 1) > 1e-10 ||
          !is.finite(answer$high$normalization_error[j]) ||
          !is.finite(answer$delta[j]) || answer$delta[j] > 1e-7) {
        table$Reason[at] <- "Response integration is unresolved; increase quad_points and inspect the rating design."
        next
      }
      mu <- sum(input$score_levels * p); variance <- sum((input$score_levels - mu)^2 * p)
      if (!is.finite(variance) || variance <= 0) {
        table$Reason[at] <- "Predictive variance is nonfinite or zero."
        next
      }
      probabilities[at, ] <- p
      table$ExpectedScore[at] <- mu; table$PredictiveVariance[at] <- variance
      residual <- table$Score[at] - mu
      table$SquaredResidual[at] <- residual^2
      table$StandardizedResidual[at] <- residual / sqrt(variance)
      table$Status[at] <- "available_conditional"
    }
  }
  measures <- do.call(rbind, lapply(group_by, function(facet) do.call(rbind,
    lapply(unique(as.character(source_data[[facet]][rows])), function(id) {
      z <- table[as.character(source_data[[facet]][rows]) == id, , drop = FALSE]
      available <- z$Status == "available_conditional"; obs <- !is.na(z$Score)
      complete <- all(available[obs]) && any(obs)
      data.frame(Facet = facet, Level = id, Selected = nrow(z), Observed = sum(obs),
        Missing = sum(!obs), Available = sum(available),
        Infit = if (complete) sum(z$SquaredResidual[obs]) / sum(z$PredictiveVariance[obs]) else NA_real_,
        Outfit = if (complete) mean(z$StandardizedResidual[obs]^2) else NA_real_,
        Status = if (complete) "descriptive_only" else "unavailable",
        Reason = if (complete) "" else if (!any(obs)) "No observed scores in selected rows." else
          "At least one selected observed row is unavailable.", row.names = NULL)
    }))))
  structure(list(rows = table, probabilities = probabilities, measures = measures,
    source = mfrm_response_source(fit), source_data = source_data, source_observed = input$data,
    settings = list(model = if (ordinary) "Ordinary fixed-facet RSM" else if (testlet) "Testlet RSM" else "Shared-rater RSM",
      quad_points = quad_points, check_points = 2L * quad_points + 1L,
      probability_tolerance = 1e-7,
      group_by = group_by, calibration_uncertainty = FALSE,
      target = "Same-data posterior predictive replicate; original latent effects shared; calibration fixed",
      integration = if (ordinary) "Normal ability quadrature; fixed facets and calibration held fixed" else if (testlet) "Nested normal quadrature" else "Normalized category-specific joint-rater Laplace integrals with ability quadrature",
      limitation = "Descriptive only; no expectation-one reference, cutoffs, ZSTD or p-values. Numerical agreement does not certify approximation accuracy.",
      selection = "Selected original rows summarized; all observed source ratings condition every prediction")),
    class = "mfrm_response_diagnostics")
}

mfrm_testlet_response_probabilities <- function(input, par, rows, order) {
  rule <- gauss_hermite_normal(order)
  theta <- sqrt(mfrm_testlet_person_variance(input, par)) * rule$nodes
  nb <- ncol(input$X); ns <- length(input$score_levels) - 1L
  variance <- par[nb + ns + 1L]; steps <- par[nb + seq_len(ns)]
  gamma <- if (variance == 0) 0 else sqrt(variance) * rule$nodes
  gw <- if (variance == 0) 1 else rule$weights
  person <- match(input$data[[input$columns$person]][rows[1L]], input$persons)
  kernel <- mfrm_testlet_kernel(input, par, theta, rule, persons = person)
  lw <- kernel$loglik[, 1L] + log(rule$weights)
  pw <- exp(lw - max(lw)); pw <- pw / sum(pw)
  result <- matrix(NA_real_, length(rows), ns + 1L)
  for (block in input$groups[[person]]) {
    selected <- which(rows %in% block)
    if (!length(selected)) next
    cache <- lapply(block, function(i) {
      eta <- as.vector(outer(theta, gamma, "+")) - sum(input$X[i, ] * par[seq_len(nb)])
      logw <- outer(eta, 0:ns) - matrix(c(0, cumsum(steps)), length(eta), ns + 1L, byrow = TRUE)
      logw - mfrm_testlet_logsum_rows(logw)
    })
    loglik <- Reduce(`+`, lapply(seq_along(block), function(j)
      matrix(cache[[j]][, input$y[block[j]] + 1L], length(theta), length(gamma))))
    local <- sweep(loglik, 2L, log(gw), "+")
    local <- exp(local - mfrm_testlet_logsum_rows(local))
    joint <- as.vector(local * pw)
    for (j in selected) result[j, ] <- colSums(exp(cache[[match(rows[j], block)]]) * joint)
  }
  list(probabilities = result, normalization_error = rowSums(result) - 1)
}

mfrm_random_rater_response_probabilities <- function(input, calibration, rows, order, logden = NULL) {
  row <- rows[1L]; steps <- calibration$steps; par <- c(calibration$beta, steps)
  make <- function(replicate = NULL) mfrm_random_rater_objective(input, order,
    fixed_sd = calibration$rater_sd, fixed_person_sd = calibration$person_sd %||% 1,
    replicate_row = replicate)
  if (is.null(logden)) {
    baseline <- make(); logden <- -as.numeric(baseline$fn(par))
  }
  numerator <- make(row)
  lognum <- vapply(0:length(steps), function(k)
    -as.numeric(numerator$fn(c(par, k, as.numeric(seq_along(steps) <= k)))), numeric(1))
  if (!is.finite(logden) || any(!is.finite(lognum))) stop("Joint-rater response integration is nonfinite.")
  normalizer <- max(lognum) + log(sum(exp(lognum - max(lognum))))
  list(probabilities = matrix(exp(lognum - normalizer), 1L),
    normalization_error = expm1(normalizer - logden), logden = logden)
}

#' @rdname mfrm_response_diagnostics
#' @param object,x A saved response-diagnostics result.
#' @param ... Unused.
#' @export
summary.mfrm_response_diagnostics <- function(object, ...) {
  list(measures = object$measures, status_counts = table(object$rows$Status), settings = object$settings)
}

#' @rdname mfrm_response_diagnostics
#' @export
print.mfrm_response_diagnostics <- function(x, ...) {
  cat("Posterior predictive residual summaries (descriptive only)\n")
  print(x$measures, row.names = FALSE)
  cat("Same data used for fitting and checking; no reference cutoffs or calibrated fit test.\n")
  invisible(x)
}
