# Private lower-bound search. Zero slopes are feasible values, not tiny
# positive substitutes. Optimizer success never replaces a raw KKT check.
mfrm_gmfrm_bounded_search <- function(start, evaluator, fixed = integer(), maxit = 400L) {
  p <- length(start); lower <- evaluator$lower
  objective_scale <- evaluator$optimization_scale %||% 1
  if (!is.numeric(start) || is.complex(start) || !p || any(!is.finite(start)) ||
      !is.numeric(lower) || is.complex(lower) || length(lower) != p || anyNA(lower) ||
      any(!lower %in% c(-Inf, 0)) || any(start < lower) ||
      !is.numeric(fixed) || is.complex(fixed) || any(!is.finite(fixed)) ||
      any(fixed != trunc(fixed) | fixed < 1 | fixed > p) || anyDuplicated(fixed) ||
      !is.numeric(maxit) || is.complex(maxit) || length(maxit) != 1L ||
      !is.finite(maxit) || maxit < 1 || maxit > .Machine$integer.max || maxit != trunc(maxit) ||
      !is.numeric(objective_scale) || is.complex(objective_scale) || length(objective_scale) != 1L ||
      !is.finite(objective_scale) || objective_scale <= 0)
    stop("Invalid bounded GMFRM search inputs.")
  free <- setdiff(seq_len(p), fixed)
  if (!length(free)) stop("Bounded GMFRM search needs a free coordinate.")
  parameter_scale <- pmax(1, abs(start[free]))
  embed <- function(x) { z <- start + 0; z[free] <- x*parameter_scale; z }
  state <- function(z) {
    if (any(!is.finite(z)) || any(z < lower)) stop("Invalid bounded search trial.")
    a <- evaluator$evaluate(z)
    if (!is.numeric(a$value) || is.complex(a$value) || length(a$value) != 1L || !is.finite(a$value) ||
        !is.numeric(a$gradient) || is.complex(a$gradient) || length(a$gradient) != p || any(!is.finite(a$gradient)))
      stop("Bounded search requires a finite value and full gradient.")
    list(parameters = z + 0, evaluation = a)
  }
  projected_score <- function(s) {
    g <- s$evaluation$gradient[free]
    active <- s$parameters[free] == lower[free]
    g[active] <- pmin(g[active], 0)
    max(abs(g))
  }
  initial <- selected <- state(start)
  rejected <- 0L; last_rejection <- NULL; opt <- endpoint <- NULL; error <- ""
  consider <- function(z) {
    trial <- state(z); value <- trial$evaluation$value; best <- selected$evaluation$value
    slack <- 64*.Machine$double.eps*max(1, abs(best))
    if (value < best || (value <= best + slack && projected_score(trial) < projected_score(selected)))
      selected <<- trial
    value
  }
  objective <- function(x) tryCatch(consider(embed(x))/objective_scale,
    mfrmr_adaptive_quadrature_numeric_error = function(e) {
      rejected <<- rejected + 1L
      last_rejection <<- list(parameters = embed(x), message = conditionMessage(e), integration = e$integration)
      Inf
    })
  tryCatch({
    opt <- nlminb(start[free]/parameter_scale, objective,
      function(x) state(embed(x))$evaluation$gradient[free]*parameter_scale/objective_scale,
      lower = lower[free]/parameter_scale,
      control = list(iter.max = as.integer(maxit), eval.max = as.integer(min(.Machine$integer.max, 5*maxit)),
        rel.tol = 1e-12, x.tol = 1e-10))
    endpoint <- state(embed(opt$par)); consider(endpoint$parameters)
  }, error = function(e) error <<- conditionMessage(e))
  active <- free[selected$parameters[free] == lower[free]]
  checks <- c(ProjectedScore = projected_score(selected),
    OutwardViolation = max(c(0, -selected$evaluation$gradient[active])),
    FixedError = max(c(0, abs(selected$parameters[fixed] - start[fixed]))))
  list(selected = selected, initial = initial, endpoint = endpoint, optimizer = opt, error = error,
    free = free, fixed = fixed, active = active, checks = checks,
    outward = selected$evaluation$gradient[active],
    nuisance_stationary = checks["ProjectedScore"] <= 1e-4,
    candidate = !is.null(opt) && opt$convergence == 0L && !nzchar(error) &&
      all(checks <= c(1e-4, 1e-4, 0)),
    rejected_points = rejected, last_rejection = last_rejection,
    parameter_scale = parameter_scale, objective_scale = objective_scale,
    global_optimality = "not assessed")
}
