# BFGS backtracks over unevaluable trials using +Inf. No artificial finite
# likelihood or zero gradient is supplied at a rejected profile point.
mfrm_gmfrm_zero_profile_search <- function(evaluator, maxit = 400L) {
  start <- evaluator$start
  if (!is.numeric(start) || is.complex(start) || !length(start) || any(!is.finite(start)) ||
      any(evaluator$lower != -Inf) || !is.numeric(maxit) || is.complex(maxit) ||
      length(maxit) != 1L || !is.finite(maxit) || maxit < 1 ||
      maxit > .Machine$integer.max || maxit != trunc(maxit)) stop("Invalid unconstrained profile search.")
  state <- function(x) {
    a <- evaluator$evaluate(x)
    stopifnot(is.finite(a$value), length(a$gradient) == length(start), all(is.finite(a$gradient)))
    list(parameters = x + 0, evaluation = a)
  }
  selected <- initial <- state(start); rejected <- 0L; opt <- NULL; error <- ""
  value <- function(x) tryCatch({
    a <- state(x); best <- selected$evaluation
    slack <- 64*.Machine$double.eps*max(1, abs(best$value))
    if (a$evaluation$value < best$value || (a$evaluation$value <= best$value + slack &&
        max(abs(a$evaluation$gradient)) < max(abs(best$gradient)))) selected <<- a
    a$evaluation$value
  }, mfrmr_adaptive_quadrature_numeric_error = function(e) { rejected <<- rejected + 1L; Inf })
  tryCatch({
    opt <- stats::optim(start, value, function(x) evaluator$evaluate(x)$gradient,
      method = "BFGS", control = list(maxit = as.integer(maxit), reltol = .Machine$double.eps,
        parscale = pmax(1, abs(start)), fnscale = evaluator$optimization_scale %||% 1))
    # An endpoint must be evaluable without the rejection wrapper.
    state(opt$par); value(opt$par)
  }, error = function(e) error <<- conditionMessage(e))
  score <- max(abs(selected$evaluation$gradient))
  list(selected = selected, initial = initial, optimizer = opt, error = error,
    checks = c(NuisanceScore = score), nuisance_stationary = score <= 1e-4,
    rejected_points = rejected, global_optimality = "not assessed")
}
