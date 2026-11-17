# Shared-rater RSM: persons are integrated before the common rater effect.

#' Fit a rating-scale model with shared random rater severity
#'
#' Estimate rater severity when the raters are modeled as draws from a specified
#' population. Each rater has one effect shared across everyone they rate.
#' The rating-scale model (RSM) uses approximate marginal maximum likelihood,
#' with optional additive fixed facets. For a local effect within one person's
#' performance instead, see [fit_mfrm_testlet()].
#'
#' @param data Long-format data, one row per observed or assigned rating.
#' @param person Names of the person, rater and numeric score columns.
#' @param rater Names of the person, rater and numeric score columns.
#' @param score Names of the person, rater and numeric score columns.
#' @param facets Character vector of fixed-facet columns; default none. Include
#'   task or criterion columns explicitly when their difficulties are part of
#'   the intended model; their presence in `data` alone does not include them.
#' @param score_levels Required consecutive integer score categories, in order.
#' @param rater_sd `NULL` estimates the population SD of rater severity.
#'   A nonnegative number fixes it as known; zero removes rater heterogeneity.
#' @param quad_points Number of standard-normal Gauss-Hermite points for each
#'   person integral, from 7 to 241; default 31. The result is also evaluated at
#'   `2 * quad_points + 1` points to check this integral's numerical stability.
#'   This check does not assess the separate rater Laplace approximation.
#'   If `checks$PersonQuadratureStable` is false, refit with more points and
#'   recheck all of `checks`; a higher-order evaluation alone does not refit
#'   the calibration. No allowed order is universally sufficient.
#' @param maxit Maximum optimizer iterations per start; default 300.
#' @param missing `"fail"` (default) refuses missing assigned scores;
#'   `"omit"` explicitly analyzes observed scores and records omitted rows.
#'
#' @param person_sd `NULL` (default) estimates the normal ability SD. A finite
#'   positive number fixes it as known; `person_sd = 1` retains the standard
#'   normal population. This is a population restriction with Rasch slope one.
#' @param person_variance_max Positive upper search bound for estimated ability
#'   variance; default 16. Reaching it fails numerical readiness; increase the
#'   bound and refit rather than interpreting a capped estimate as a solution.
#'
#' @details
#' Fits the crossed random-rater RSM
#' \deqn{\log\{P(Y_{prj}=k)/P(Y_{prj}=k-1)\} = \theta_p - u_r - x_{prj}'\beta - \delta_k,}
#' with independent \eqn{\theta_p \sim N(0, \sigma_p^2)} and shared rater
#' severities \eqn{u_r \sim N(0, \sigma_r^2)}, sum-to-zero fixed-facet effects
#' \eqn{\beta}, and free adjacent steps \eqn{\delta_k}. Person integrals use
#' Gauss-Hermite quadrature conditional on \eqn{u}, and the joint shared-rater
#' integral uses RTMB's Laplace approximation (unit weights, connected design,
#' observed categories). Extreme fixed-facet separation and zero-variance
#' boundaries (checked via one-sided variance scores) fail `checks$NumericalReady`
#' or withhold regular intervals.
#'
#' Calibration and conditional-mode rater bounds (`ConditionalSD` vs
#' `PredictionSE`) are omitted by default and requested explicitly via
#' `confint(fit, parm = "calibration" | "rater_sd" | "raters")`; finite-sample
#' coverage is not guaranteed with few raters (see the
#' [online random-rater guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-random-raters.html)
#' for likelihood and coverage benchmarks, and [fit_mfrm_testlet()] for
#' Person-specific local dependence).
#' @return An `mfrm_random_rater` object with `calibration_table`, `raters`,
#'   full covariance matrices, `checks`, analysis data/omitted-row accounting,
#'   model settings and optimizer records. It contains no native pointers;
#'   save it with `saveRDS()`. Its summary, plot and prediction methods are
#'   specific to this model; it is not an ordinary `mfrm_fit` or portable
#'   fixed-facet calibration object.
#'   Calibration and summary rater tables retain `IntervalStatus`, `CIEligible` and
#'   `InferenceReview` for normal-interval availability. These distinguish
#'   unrequested bounds, unsupported targets and unresolved checks or variance
#'   boundaries; see [confint.mfrm_random_rater()]. Retained points require
#'   the separate fit checks and are not certified by these fields.
#' @references Van den Noortgate, W., De Boeck, P. and Meulders, M. (2003).
#'   Cross-classification multilevel logistic models in psychometrics.
#'   *Journal of Educational and Behavioral Statistics*, 28, 369--386.
#'   \doi{10.3102/10769986028004369}.
#'
#'   Huang, S. and Cai, L. (2024). Cross-classified item response theory
#'   modeling with an application to student evaluation of teaching.
#'   *Journal of Educational and Behavioral Statistics*, 49, 311--341.
#'   \doi{10.3102/10769986231193351}.
#'
#'   Kristensen, K., Nielsen, A., Berg, C. W., Skaug, H. and Bell,
#'   B. M. (2016). TMB: Automatic differentiation and Laplace approximation.
#'   *Journal of Statistical Software*, 70(5), 1--21. \doi{10.18637/jss.v070.i05}.
#' @seealso [score_mfrm_random_rater()], [predict.mfrm_random_rater()], [plot.mfrm_random_rater()],
#'   [mfrm_response_diagnostics()] for descriptive posterior predictive residuals,
#'   [confint.mfrm_random_rater()], [mfrm_random_rater_intervals()], [mfrm_results()]
#' @examples
#' # Optional workflow; run the example explicitly as shown below.
#' # example("fit_mfrm_random_rater", run.dontrun = TRUE)
#' \dontrun{
#' # Inspecting this saved synthetic fit does not require RTMB.
#' example <- readRDS(system.file("examples", "extended-models.rds", package = "mfrmr"))
#' fit <- example$random_rater$fit
#' # To refit instead, install optional RTMB >= 2.0 and run:
#' # ratings <- load_mfrmr_data("example_core")
#' # fit <- fit_mfrm_random_rater(ratings, "Person", "Rater", "Score",
#' #   facets = "Criterion", score_levels = 1:4, quad_points = 121)
#' summary(fit)
#' plot(fit)
#' recipe <- system.file("examples", "extended-models.R", package = "mfrmr")
#' # Run source(recipe) separately to regenerate the saved fits.
#' }
#' @export
#' @order 1
fit_mfrm_random_rater <- function(data, person, rater, score, facets = character(),
                                  score_levels, rater_sd = NULL, quad_points = 31L,
                                  maxit = 300L, missing = c("fail", "omit"),
                                  person_sd = NULL, person_variance_max = 16) {
  if (!is.null(rater_sd) && (!is.numeric(rater_sd) || is.complex(rater_sd) ||
      length(rater_sd) != 1L || !is.finite(rater_sd) || rater_sd < 0)) {
    stop("`rater_sd` must be NULL or a finite nonnegative known SD.", call. = FALSE)
  }
  if (!is.null(person_sd) && (!is.numeric(person_sd) || is.complex(person_sd) ||
      length(person_sd) != 1L || !is.finite(person_sd) || person_sd <= 0 ||
      !is.finite(person_sd^2) || person_sd^2 <= 0)) {
    stop("`person_sd` must be NULL or a finite positive known SD with finite positive variance.", call. = FALSE)
  }
  if (!is.numeric(person_variance_max) || is.complex(person_variance_max) ||
      length(person_variance_max) != 1L || !is.finite(person_variance_max) || person_variance_max <= 0) {
    stop("`person_variance_max` must be a finite positive variance bound.", call. = FALSE)
  }
  for (arg in c("quad_points", "maxit")) {
    x <- get(arg)
    if (!is.numeric(x) || is.complex(x) || length(x) != 1L || !is.finite(x) ||
        x != floor(x) || x < (if (arg == "quad_points") 7 else 1) ||
        x > (if (arg == "quad_points") 241 else 10000)) {
      stop("Use integer quad_points from 7 to 241 and maxit from 1 to 10000.", call. = FALSE)
    }
  }
  input <- mfrm_random_rater_data(data, person, rater, facets, score, score_levels, missing)
  out <- mfrm_random_rater_fit(input, as.integer(quad_points), rater_sd, as.integer(maxit),
    fixed_person_sd = person_sd, person_variance_max = person_variance_max)
  out$input <- input
  dimnames(out$rater_covariance) <- list(input$levels[[rater]], input$levels[[rater]])
  dimnames(out$conditional_rater_covariance) <- dimnames(out$rater_covariance)
  out$settings <- list(method = "MML: Person quadrature and shared-rater Laplace",
    model = "RSM", person_distribution = "N(0, person_sd^2)", rater_distribution = "N(0, rater_sd^2)",
    fixed_rater_sd = rater_sd, fixed_person_sd = person_sd,
    person_variance_max = person_variance_max, quad_points = quad_points, maxit = maxit,
    missing = match.arg(missing), RTMB_version = as.character(utils::packageVersion("RTMB")))
  ready <- isTRUE(out$checks$NumericalReady) && isTRUE(out$checks$InformationPositive)
  boundary <- isTRUE(out$checks$EstimatedVarianceBoundary) ||
    isTRUE(out$checks$EstimatedPersonVarianceBoundary)
  nb <- ncol(input$X); ns <- length(score_levels) - 1L
  table <- list(); at <- 0L
  for (f in facets) {
    b <- input$basis[[f]]; index <- at + seq_len(ncol(b)); at <- max(index)
    se <- if (ready && !boundary) sqrt(pmax(0, diag(b %*% out$covariance[index, index, drop = FALSE] %*% t(b)))) else rep(NA_real_, nrow(b))
    table[[length(table) + 1L]] <- data.frame(Parameter = "Fixed facet", Facet = f, Level = rownames(b),
      Estimate = as.vector(b %*% out$calibration$beta[index]), SE = se)
  }
  table[[length(table) + 1L]] <- data.frame(Parameter = "Step", Facet = score, Level = as.character(score_levels[-1L]),
    Estimate = out$calibration$steps, SE = if (ready && !boundary) sqrt(diag(out$covariance)[nb + seq_len(ns)]) else NA_real_)
  se_sd <- if (ready && !boundary && is.null(rater_sd)) sqrt(diag(out$covariance)[nb + ns + 1L]) else NA_real_
  table[[length(table) + 1L]] <- data.frame(Parameter = "Population SD", Facet = rater, Level = "Rater population",
    Estimate = out$calibration$rater_sd, SE = se_sd)
  table[[length(table) + 1L]] <- data.frame(Parameter = "Population SD", Facet = person,
    Level = "Person population", Estimate = out$calibration$person_sd,
    SE = if (ready && !boundary && is.null(person_sd)) sqrt(tail(diag(out$covariance), 1L)) else NA_real_)
  out$calibration_table <- do.call(rbind, table); rownames(out$calibration_table) <- NULL
  out$calibration_table <- mfrm_extended_calibration_table(out)
  se_rater <- sqrt(pmax(0, diag(out$rater_covariance)))
  out$raters <- data.frame(Rater = input$levels[[rater]],
    Persons = as.integer(input$workload[input$levels[[rater]]]),
    Estimate = out$rater_mode, ConditionalSD = sqrt(pmax(0, diag(out$conditional_rater_covariance))),
    PredictionSE = se_rater, Lower = NA_real_, Upper = NA_real_)
  if (!ready) {
    detail <- if (!isTRUE(out$checks$PersonQuadratureStable)) {
      if (quad_points < 241L) paste0(
        " Person quadrature is not stable. Refit with a larger `quad_points` (up to 241) and recheck $checks.") else
        " Person quadrature remains unresolved at the maximum `quad_points = 241`; do not use this fit for inference."
    } else ""
    warning(paste0("Numerical or information checks require review; regular intervals are unavailable. Inspect $checks.",
      detail), call. = FALSE)
  }
  out$call <- match.call()
  class(out) <- "mfrm_random_rater"
  out
}

#' @rdname fit_mfrm_random_rater
#' @param object A fitted `mfrm_random_rater` object.
#' @param ... For `summary.mfrm_random_rater()`: Unused by summary and print.
#'
#' For `plot()`: Unused.
#' @param calibration_intervals For summaries, `"none"` (default) omits
#'   calibration bounds; `"normal"` explicitly requests their pointwise normal
#'   approximation. This does not select individual-rater intervals.
#' @param level Nominal level for explicitly requested summary calibration
#'   intervals; default 0.95. Numerical and variance-boundary restrictions remain.
#' @export
summary.mfrm_random_rater <- function(object, ..., calibration_intervals = c("none", "normal"), level = .95) {
  rlang::check_dots_empty()
  calibration_intervals <- match.arg(calibration_intervals)
  list(calibration = mfrm_extended_calibration_table(object, calibration_intervals, level), raters = mfrm_random_rater_table(object), checks = object$checks,
    calibration_intervals = list(method = calibration_intervals, level = level),
    settings = object$settings, data_usage = c(Input = object$input$input_rows,
      Analyzed = nrow(object$input$data), Omitted = length(object$input$omitted_rows)),
    notes = c(if (calibration_intervals == "none") "Calibration bounds are omitted by default; SEs are observed-information approximations. Request calibration_intervals = 'normal' explicitly to inspect pointwise bounds." else
      "Explicit calibration intervals use an observed-information normal approximation, not established finite-sample coverage.",
      "Individual-rater intervals are not supplied automatically: nominal coverage is not established. PredictionSE is a first-order approximation. Use confint(object, parm = 'raters') only to inspect that normal approximation.",
      if (isTRUE(object$checks$EstimatedVarianceBoundary) ||
          isTRUE(object$checks$EstimatedPersonVarianceBoundary)) "An estimated variance is zero; regular calibration and rater intervals are withheld.",
      "Person quadrature checks do not assess the shared-rater Laplace error."))
}

#' @rdname fit_mfrm_random_rater
#' @export
print.mfrm_random_rater <- function(x, ...) {
  cat("Shared-rater RSM: approximate marginal maximum likelihood\n")
  cat("Persons:", length(x$input$levels[[x$input$columns$person]]), " Raters:", nrow(x$raters),
    " Rater population SD:", format(x$calibration$rater_sd, digits = 4), "\n")
  cat("Person population SD:", format(x$calibration$person_sd %||% 1, digits = 4), "\n")
  print(mfrm_extended_calibration_table(x), row.names = FALSE)
  cat("Calibration bounds omitted; SEs are observed-information approximations.\n")
  if (isTRUE(x$checks$EstimatedVarianceBoundary) ||
      isTRUE(x$checks$EstimatedPersonVarianceBoundary)) cat("Estimated variance boundary: regular intervals withheld.\n")
  cat("Numerical checks:", if (isTRUE(x$checks$NumericalReady)) "passed" else "review required", "\n")
  cat("Rater approximation and interval coverage require separate assessment.\n")
  invisible(x)
}

mfrm_random_rater_data <- function(data, person, rater, facets, score, score_levels,
                                   missing = c("fail", "omit"), reference = NULL) {
  missing <- match.arg(missing)
  columns <- c(person, rater, facets, score)
  if (!is.data.frame(data) || !nrow(data) || anyDuplicated(names(data)) ||
      !is.character(person) || !is.character(rater) || !is.character(facets) ||
      !is.character(score) || anyNA(columns) || anyDuplicated(columns) ||
      length(person) != 1L || length(rater) != 1L || length(score) != 1L ||
      !all(columns %in% names(data))) stop("Specify distinct existing person, rater, fixed-facet and score columns.", call. = FALSE)
  if (!is.numeric(score_levels) || is.complex(score_levels) || length(score_levels) < 2L ||
      anyNA(score_levels) || any(!is.finite(score_levels)) ||
      any(score_levels != floor(score_levels)) || any(diff(score_levels) != 1)) {
    stop("`score_levels` must declare consecutive integer categories in increasing order.", call. = FALSE)
  }
  d <- data[columns]
  for (id in c(person, rater, facets)) {
    v <- d[[id]]
    if (!is.atomic(v) || !is.null(dim(v)) || anyNA(v) || any(!nzchar(trimws(as.character(v))))) {
      stop("Person, rater and fixed-facet identifiers must be complete and nonempty.", call. = FALSE)
    }
    d[[id]] <- as.character(v)
  }
  y <- d[[score]]
  if (!is.numeric(y) || is.complex(y) || !is.null(dim(y)) || any(!is.na(y) & !y %in% score_levels)) {
    stop("Scores must be numeric members of the declared categories or NA.", call. = FALSE)
  }
  absent <- is.na(y)
  if (any(absent) && missing == "fail") stop("Assigned scores are missing; review them or explicitly use missing = 'omit'.", call. = FALSE)
  assigned_data <- d
  d <- d[!absent, , drop = FALSE]
  if (is.null(reference) && (!nrow(d) || !all(score_levels %in% d[[score]]))) {
    stop("Every declared score category must be observed for finite unconstrained step estimation.", call. = FALSE)
  }
  if (is.null(reference)) {
    levels <- lapply(d[c(person, rater, facets)], function(x) sort(unique(x)))
    if (length(levels[[person]]) < 2L || length(levels[[rater]]) < 2L) {
      stop("The shared-rater model requires multiple persons and raters.", call. = FALSE)
    }
    cells <- data.frame(Person = d[[person]], Rater = d[[rater]])
    connectivity <- mfrm_bipartite_components(cells, "Rater", "Observed")
    if (!isTRUE(connectivity$summary$Connected)) {
      stop("The initial shared-rater workflow requires a connected Person-rater assignment.", call. = FALSE)
    }
    workload <- table(unique(cells)$Rater)
    if (any(workload < 2L)) stop("Each rater must rate multiple persons in this workflow.", call. = FALSE)
    if (any(vapply(levels[facets], length, integer(1)) < 2L)) stop("Each fixed facet needs at least two observed levels.", call. = FALSE)
    basis <- lapply(levels[facets], function(x) {
      z <- qr.Q(qr(stats::contr.sum(length(x))))
      dimnames(z) <- list(x, paste0("C", seq_len(ncol(z))))
      z
    })
  } else {
    levels <- lapply(assigned_data[c(person, rater)], function(x) sort(unique(x)))
    levels[facets] <- reference$levels[facets]
    basis <- reference$basis
    for (f in facets) if (any(!assigned_data[[f]] %in% rownames(basis[[f]]))) {
      stop("Scoring contains an unknown fixed-facet level: ", f, call. = FALSE)
    }
    connectivity <- NULL
    workload <- table(unique(d[c(person, rater)])[[rater]])
  }
  X <- if (length(facets)) do.call(cbind, lapply(facets, function(f) basis[[f]][match(d[[f]], levels[[f]]), , drop = FALSE])) else matrix(numeric(), nrow(d), 0L)
  if (is.null(reference) && qr(cbind(1, X))$rank < ncol(X) + 1L) stop("Fixed-facet effects are aliased in the observed design.", call. = FALSE)
  list(data = d, assigned_data = assigned_data, input_rows = nrow(data), omitted_rows = which(absent), columns = list(
    person = person, rater = rater, facets = facets, score = score), levels = levels,
    basis = basis, X = X, y = match(d[[score]], score_levels) - 1L,
    person = match(d[[person]], levels[[person]]), rater = match(d[[rater]], levels[[rater]]),
    score_levels = score_levels, connectivity = connectivity, workload = workload)
}

# Rater variance score at zero. Unlike the SD derivative (always zero), this
# one-sided derivative can distinguish an optimum from a stationary SD boundary.
mfrm_random_rater_zero_score <- function(input, beta, steps, quad_points, person_sd = 1) {
  rule <- gauss_hermite_normal(quad_points)
  nr <- max(input$rater); total_score <- numeric(nr); total_hessian <- numeric(nr)
  offset <- if (length(beta)) as.vector(input$X %*% beta) else rep(0, length(input$y))
  for (indices in split(seq_along(input$y), input$person)) {
    loglik <- numeric(quad_points)
    score <- curvature <- matrix(0, quad_points, nr)
    for (i in indices) {
      eta <- person_sd * rule$nodes - offset[i]
      logw <- outer(eta, 0:length(steps)) - matrix(c(0, cumsum(steps)), length(eta), length(steps) + 1L, byrow = TRUE)
      shift <- apply(logw, 1L, max)
      p <- exp(logw - shift); denominator <- rowSums(p); p <- p / denominator
      loglik <- loglik + ((logw[, input$y[i] + 1L] - shift) - log(denominator))
      mean <- as.vector(p %*% (0:length(steps)))
      variance <- mfrm_category_variance(p, 0:length(steps), mean)
      r <- input$rater[i]
      score[, r] <- score[, r] + mean - input$y[i]
      curvature[, r] <- curvature[, r] - variance
    }
    loglik <- (loglik - max(loglik)) + log(rule$weights)
    posterior <- exp(loglik - max(loglik)); posterior <- posterior / sum(posterior)
    s <- colSums(posterior * score)
    total_score <- total_score + s
    total_hessian <- total_hessian + colSums(posterior * (curvature + score^2)) - s^2
  }
  .5 * sum(total_score^2 + total_hessian)
}

mfrm_random_rater_objective <- function(input, quad_points, start_sd = .5,
                                        fixed_sd = NULL, random = TRUE,
                                        fixed_person_sd = 1, start_person_sd = 1,
                                        focal_person = NULL, replicate_row = NULL) {
  if (!requireNamespace("RTMB", quietly = TRUE) || utils::packageVersion("RTMB") < "2.0") {
    stop("Install optional RTMB version 2.0 or later for shared-rater estimation.", call. = FALSE)
  }
  rule <- gauss_hermite_normal(quad_points)
  np <- max(input$person); nr <- max(input$rater)
  # Equal predictors share category log probabilities, but each Person retains
  # their own category counts. Focal ability rows must form separate cells.
  design <- data.frame(rater = input$rater, input$X)
  if (!is.null(focal_person)) design$focal <- input$person == focal_person
  key <- do.call(paste, c(lapply(design, function(x) match(x, unique(x))), sep = ":"))
  first <- match(unique(key), key); cell <- match(key, key[first]); nc <- length(first)
  categories <- seq_along(input$score_levels) - 1L
  counts <- lapply(categories, function(y) {
    rows <- which(input$y == y)
    Matrix::sparseMatrix(i = input$person[rows], j = cell[rows], x = 1, dims = c(np, nc))
  })
  theta <- matrix(rep(rule$nodes, each = nc), nc, quad_points)
  focal <- if (is.null(focal_person)) NULL else as.numeric(input$person[first] == focal_person)
  objective <- function(par) {
    sd <- if (is.null(fixed_sd)) par$sd else fixed_sd
    person_sd <- if (is.null(fixed_person_sd)) par$person_sd else fixed_person_sd
    base <- -sd * par$z[input$rater[first]]
    if (ncol(input$X)) base <- base - (RTMB::AD(input$X[first, , drop = FALSE]) %*% par$beta)[, 1L]
    eta <- RTMB::matrix(rep(base, quad_points), nc, quad_points) + person_sd * theta
    if (!is.null(focal)) eta <- eta + focal * (par$focal_ability - person_sd * theta)
    # Sum relative to each category using adjacent log odds. The two sweeps
    # preserve small differences at large finite ties in O(categories) work.
    upper <- vector("list", length(categories))
    upper[[length(categories)]] <- 0 * eta
    for (k in rev(seq_along(par$steps))) upper[[k]] <-
      RTMB::logspace_add(0 * eta, (eta - par$steps[k]) + upper[[k + 1L]])
    lower <- 0 * eta
    log_probabilities <- vector("list", length(categories))
    log_probabilities[[1L]] <- -upper[[1L]]
    for (y in seq_along(par$steps)) {
      lower <- RTMB::logspace_add(0 * eta, (par$steps[y] - eta) + lower)
      log_probabilities[[y + 1L]] <- if (y == length(par$steps)) -lower else
        -RTMB::logspace_add(lower, (eta - par$steps[y + 1L]) + upper[[y + 2L]])
    }
    person_logp <- RTMB::AD(matrix(0, np, quad_points))
    for (y in categories) person_logp <- person_logp +
      RTMB::AD(counts[[y + 1L]]) %*% log_probabilities[[y + 1L]]
    if (!is.null(replicate_row)) {
      # One hypothetical replicate shares this row's ability and rater. Its
      # category changes the numerator integral, never the fitted calibration.
      step_weights <- c(RTMB::AD(1), par$replicate_steps, RTMB::AD(0))
      category_weights <- step_weights[-length(step_weights)] - step_weights[-1L]
      # The residual preserves derivatives for independently varied score and
      # step indicators; it is zero for every actual response category.
      extra <- (par$replicate_score - sum(par$replicate_steps)) * eta[cell[replicate_row], ]
      for (y in categories) extra <- extra +
        category_weights[y + 1L] * log_probabilities[[y + 1L]][cell[replicate_row], ]
      person_logp <- person_logp + outer(as.numeric(seq_len(np) == input$person[replicate_row]), extra)
    }
    offset <- RTMB::apply(person_logp, 1L, max)
    person_logp <- person_logp - offset
    person_marginal <- person_logp[, 1L] + log(rule$weights[1L])
    for (q in 2:quad_points) person_marginal <- RTMB::logspace_add(
      person_marginal, person_logp[, q] + log(rule$weights[q]))
    rater_effect <- sd * par$z
    RTMB::ADREPORT(rater_effect)
    # One z per observed rater enters every person's likelihood before summing.
    -sum(offset + person_marginal) + sum(par$z^2) / 2 + nr * log(2 * pi) / 2
  }
  parameters <- list(beta = rep(0, ncol(input$X)),
    steps = seq(-1, 1, length.out = length(input$score_levels) - 1L), z = rep(0, nr))
  if (is.null(fixed_sd)) parameters$sd <- start_sd
  if (is.null(fixed_person_sd)) parameters$person_sd <- start_person_sd
  if (!is.null(focal_person)) parameters$focal_ability <- 0
  if (!is.null(replicate_row)) {
    parameters$replicate_score <- 0
    parameters$replicate_steps <- rep(0, length(parameters$steps))
  }
  RTMB::MakeADFun(objective, parameters, random = if (random) "z" else NULL,
    silent = TRUE)
}

# These differences are of the same Laplace marginal objective as the fit,
# including the change in the inner rater mode and Hessian determinant.
# An SD score at zero or a plug-in rater mode would miss these terms.
mfrm_random_rater_person_zero_score <- function(input, beta, steps, sd, quad_points) {
  par <- c(beta, steps)
  nll <- vapply(c(0, 1e-4, 5e-5, 2.5e-5), function(v) {
    obj <- mfrm_random_rater_objective(input, quad_points, fixed_sd = sd,
      fixed_person_sd = sqrt(v))
    as.numeric(obj$fn(par))
  }, numeric(1))
  slopes <- (nll[1L] - nll[-1L]) / c(1e-4, 5e-5, 2.5e-5)
  extrapolated <- 2 * slopes[2:3] - slopes[1:2]
  c(score = extrapolated[2L], difference = abs(diff(extrapolated)))
}

mfrm_random_rater_fit <- function(input, quad_points, fixed_sd, maxit,
                                  fixed_person_sd = 1, person_variance_max = 16) {
  controls <- list(iter.max = maxit, eval.max = maxit * 3L, rel.tol = 1e-12, x.tol = 1e-10)
  nb <- ncol(input$X); ns <- length(input$score_levels) - 1L
  fixed_indices <- seq_len(nb + ns)
  optimize <- function(obj, start = obj$par) {
    lower <- ifelse(names(start) %in% c("sd", "person_sd"), 0, -Inf)
    upper <- ifelse(names(start) == "person_sd", sqrt(person_variance_max), Inf)
    answer <- stats::nlminb(start, obj$fn, obj$gr, lower = lower, upper = upper, control = controls)
    answer$gradient <- as.vector(obj$gr(answer$par))
    original_code <- answer$convergence
    answer$polished <- FALSE
    if ((answer$convergence != 0L || max(abs(answer$gradient)) >= 1e-4) &&
        all(answer$par > lower + 1e-5 & answer$par < upper - 1e-5)) {
      proposal <- mfrm_optimizer_curvature_proposal(answer$par, obj$fn, obj$gr)
      if (!is.null(proposal$par) && all(proposal$par >= lower & proposal$par <= upper)) {
        if (answer$convergence != 0L) {
          answer <- stats::nlminb(proposal$par, obj$fn, obj$gr, lower = lower,
            upper = upper, control = controls)
        } else answer$par <- proposal$par
        answer$objective <- as.numeric(obj$fn(answer$par))
        answer$gradient <- as.vector(obj$gr(answer$par))
        answer$polished <- TRUE
      }
    }
    answer$original_code <- original_code
    answer
  }
  person_sd_of <- function(par, fixed) if (is.null(fixed)) unname(par["person_sd"]) else fixed
  # Fit both rater faces for a specified or estimated Person distribution.
  family <- function(person_value) {
    zero <- mfrm_random_rater_objective(input, quad_points, fixed_sd = 0,
      fixed_person_sd = person_value)
    starts <- if (is.null(person_value)) pmin(c(.75, 1.5), sqrt(person_variance_max) * .75) else 1
    zeros <- lapply(starts, function(ps) {
      start <- zero$par
      if (is.null(person_value)) start["person_sd"] <- ps
      optimize(zero, start)
    })
    zero_fit <- zeros[[which.min(vapply(zeros, `[[`, numeric(1), "objective"))]]
    zero_score <- mfrm_random_rater_zero_score(input, zero_fit$par[seq_len(nb)],
      zero_fit$par[nb + seq_len(ns)], quad_points, person_sd_of(zero_fit$par, person_value))
    estimated_boundary <- FALSE
    if (!is.null(fixed_sd) && fixed_sd == 0) {
      obj <- zero; best <- zero_fit; candidates <- zeros
    } else {
      obj <- mfrm_random_rater_objective(input, quad_points, fixed_sd = fixed_sd,
        fixed_person_sd = person_value)
      candidates <- lapply(if (is.null(fixed_sd)) c(.25, 1) else fixed_sd, function(sd) {
        start <- obj$par
        start[fixed_indices] <- zero_fit$par[fixed_indices]
        if (is.null(fixed_sd)) start["sd"] <- sd
        if (is.null(person_value)) start["person_sd"] <- max(zero_fit$par["person_sd"],
          min(1, sqrt(person_variance_max) * .75))
        optimize(obj, start)
      })
      best <- candidates[[which.min(vapply(candidates, `[[`, numeric(1), "objective"))]]
      estimated_boundary <- is.null(fixed_sd) && is.finite(zero_score) && zero_score <= 1e-5 &&
        zero_fit$objective <= best$objective + 1e-8
      if (estimated_boundary) { obj <- zero; best <- zero_fit }
    }
    list(obj = obj, best = best, zero_fit = zero_fit, zero_score = zero_score,
      candidates = candidates, rater_boundary = estimated_boundary, fixed_person = person_value,
      sd = if (estimated_boundary) 0 else if (is.null(fixed_sd)) unname(best$par["sd"]) else fixed_sd)
  }
  estimated_person_boundary <- FALSE
  person_zero_score <- high_person_zero_score <- c(score = NA_real_, difference = NA_real_)
  if (is.null(fixed_person_sd)) {
    at_zero <- family(0)
    interior <- family(NULL)
    person_zero_score <- mfrm_random_rater_person_zero_score(input,
      at_zero$best$par[seq_len(nb)], at_zero$best$par[nb + seq_len(ns)], at_zero$sd, quad_points)
    estimated_person_boundary <- all(is.finite(person_zero_score)) &&
      person_zero_score["score"] + person_zero_score["difference"] <= 1e-5 &&
      person_zero_score["difference"] < 1e-4 &&
      at_zero$best$objective <= interior$best$objective + 1e-8
    selected <- if (estimated_person_boundary) at_zero else interior
  } else selected <- family(fixed_person_sd)
  obj <- selected$obj; best <- selected$best; sd <- selected$sd
  zero_fit <- selected$zero_fit; zero_score <- selected$zero_score
  estimated_boundary <- selected$rater_boundary
  person_sd <- person_sd_of(best$par, selected$fixed_person)
  person_upper <- is.null(fixed_person_sd) && person_sd >= sqrt(person_variance_max) - 1e-5
  best$value <- as.numeric(obj$fn(best$par))
  allpar <- obj$env$parList(par = obj$env$last.par)
  boundary_ok <- (!is.null(fixed_sd) || sd > 1e-5 || estimated_boundary) &&
    (!is.null(fixed_person_sd) || person_sd > 1e-5 || estimated_person_boundary) && !person_upper
  gradient_max <- max(abs(best$gradient))
  high_order <- 2L * quad_points + 1L
  high <- mfrm_random_rater_objective(input, high_order,
    fixed_sd = if (estimated_boundary) 0 else fixed_sd, fixed_person_sd = selected$fixed_person)
  integration_difference <- abs(as.numeric(high$fn(best$par)) - best$value)
  gradient_difference <- max(abs(as.vector(high$gr(best$par)) - best$gradient))
  high_zero_score <- mfrm_random_rater_zero_score(input, zero_fit$par[seq_len(nb)],
    zero_fit$par[nb + seq_len(ns)], high_order, person_sd_of(zero_fit$par, selected$fixed_person))
  if (is.null(fixed_person_sd)) {
    high_person_zero_score <- mfrm_random_rater_person_zero_score(input,
      at_zero$best$par[seq_len(nb)], at_zero$best$par[nb + seq_len(ns)], at_zero$sd, high_order)
  }
  quadrature_stable <- isTRUE(integration_difference < 1e-5) && isTRUE(gradient_difference < 1e-4)
  # An extreme-only fixed level admits a likelihood-increasing direction:
  # move that level and compensate its zero sum with the common step mean.
  # This survives integration over persons/raters. Tiny positive eigenvalues
  # at the optimizer's finite stopping point cannot establish a finite MLE.
  separated <- any(vapply(input$columns$facets, function(facet) {
    any(vapply(split(input$y, input$data[[facet]]), function(y)
      all(y == 0L) || all(y == length(input$score_levels) - 1L), logical(1)))
  }, logical(1)))
  numerical_ready <- !separated && best$convergence == 0L && gradient_max < 1e-4 && boundary_ok &&
    quadrature_stable &&
    (!estimated_boundary || high_zero_score <= 1e-5) &&
    (!estimated_person_boundary || (high_person_zero_score["score"] + high_person_zero_score["difference"] <= 1e-5 &&
      high_person_zero_score["difference"] < 1e-4))
  H <- optimHess(best$par, obj$fn, obj$gr)
  H <- (H + t(H)) / 2
  values <- eigen(H, symmetric = TRUE, only.values = TRUE)$values
  information_ready <- !separated && all(is.finite(values)) && min(values) > max(values) * 1e-10
  covariance <- if (numerical_ready && information_ready) chol2inv(chol(H)) else matrix(NA_real_, length(best$par), length(best$par))
  obj$fn(best$par)
  conditional_cov <- sd^2 * as.matrix(Matrix::solve(obj$env$spHess(obj$env$last.par, random = TRUE)))
  # Estimated variance boundaries do not have regular calibration coordinates.
  report <- if (numerical_ready && information_ready && !estimated_boundary && !estimated_person_boundary) {
    tryCatch(RTMB::sdreport(obj, par.fixed = best$par, hessian.fixed = H,
      getReportCovariance = TRUE), error = function(e) NULL)
  } else NULL
  rater_covariance <- if (!is.null(report) && is.matrix(report$cov) &&
      all(dim(report$cov) == max(input$rater)) && all(is.finite(report$cov))) report$cov else
        matrix(NA_real_, max(input$rater), max(input$rater))
  record <- function(x) x[c("par", "objective", "convergence", "message", "gradient", "polished", "original_code")]
  list(calibration = list(beta = unname(best$par[seq_len(nb)]),
    steps = unname(best$par[nb + seq_len(ns)]), rater_sd = sd,
    person_sd = person_sd, person_variance = person_sd^2),
    coefficients = best$par, covariance = covariance, information = H,
    rater_mode = sd * as.numeric(allpar$z), conditional_rater_covariance = conditional_cov,
    rater_covariance = rater_covariance, loglik = -best$value,
    checks = data.frame(OptimizerCode = best$convergence, MaxGradient = gradient_max,
      ZeroVarianceScore = zero_score, EstimatedVarianceBoundary = estimated_boundary,
      HigherOrderZeroVarianceScore = high_zero_score,
      EstimatedPersonVarianceBoundary = estimated_person_boundary, PersonVarianceUpperBoundary = person_upper,
      PersonZeroVarianceScore = unname(person_zero_score["score"]),
      PersonZeroScoreDifference = unname(person_zero_score["difference"]),
      HigherOrderPersonZeroVarianceScore = unname(high_person_zero_score["score"]),
      HigherOrderPersonZeroScoreDifference = unname(high_person_zero_score["difference"]),
      QuadraturePoints = quad_points, CheckPoints = high_order,
      LogLikDifference = integration_difference, GradientDifference = gradient_difference,
      PersonQuadratureStable = quadrature_stable, FixedFacetSeparation = separated,
      NumericalReady = numerical_ready, InformationPositive = information_ready),
    zero_optimization = record(zero_fit),
    person_zero_optimization = if (is.null(fixed_person_sd)) record(at_zero$best) else NULL,
    optimizations = lapply(selected$candidates, record))
}

# Saved fits predating the population parameter used a known N(0,1) population.
mfrm_random_rater_fixed_person_sd <- function(object) {
  if (is.null(object$calibration$person_sd)) 1 else object$settings$fixed_person_sd
}
