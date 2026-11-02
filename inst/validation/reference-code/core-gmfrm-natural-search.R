# Internal candidate search. First-order checks are not local-minimum,
# global-maximum, identification or interval-calibration certificates.
mfrm_gmfrm_natural_search <- function(start, evaluator, fixed = integer(),
                                      boundary = integer(), maxit = 400L) {
  p <- length(start); lower <- evaluator$lower
  valid_indices <- function(x) is.numeric(x) && !is.complex(x) && !anyNA(x) &&
    all(is.finite(x) & x == trunc(x) & x >= 1 & x <= p) && !anyDuplicated(x)
  if (!is.numeric(start) || is.complex(start) || any(!is.finite(start)) ||
      length(lower) != p || anyNA(lower) || any(start < lower) ||
      !valid_indices(fixed) || !valid_indices(boundary) || length(intersect(fixed, boundary)) ||
      any(lower[boundary] != 0 | start[boundary] != 0) ||
      !is.numeric(maxit) || is.complex(maxit) || length(maxit) != 1L || !is.finite(maxit) ||
      maxit < 1 || maxit > .Machine$integer.max || maxit != trunc(maxit))
    stop("Invalid natural search start, bounds, fixed indices or iteration limit.")
  free <- setdiff(seq_len(p), c(fixed, boundary))
  if (!length(free)) stop("Natural search needs at least one free coordinate.")
  embed <- function(x) { ans <- start + 0; ans[free] <- x; ans }
  state <- function(par) {
    a <- evaluator$evaluate(par)
    stopifnot(is.finite(a$value), length(a$gradient) == p, all(is.finite(a$gradient)))
    list(parameters = par + 0, evaluation = a)
  }
  selected <- state(start); initial <- selected
  nuisance <- function(s) {
    g <- s$evaluation$gradient[free]
    at <- s$parameters[free] == lower[free]; g[at] <- pmin(g[at], 0)
    max(abs(g))
  }
  consider <- function(par) {
    trial <- state(par); v <- trial$evaluation$value; best <- selected$evaluation$value
    slack <- 64 * .Machine$double.eps * max(1, abs(best))
    if (v < best || (v <= best + slack && nuisance(trial) < nuisance(selected))) selected <<- trial
    v
  }
  sub <- list(value = function(x) consider(embed(x)),
    gradient = function(x) evaluator$gradient(embed(x))[free])
  safe <- make_mfrm_boundary_safe_objective(sub)
  error <- ""; opt <- NULL
  tryCatch({
    opt <- stats::optim(start[free], safe$value, safe$gradient, method = "L-BFGS-B",
      lower = lower[free], control = list(maxit = as.integer(maxit), factr = 1,
        pgtol = 1e-8, lmm = 20L, parscale = pmax(1, abs(start[free])),
        fnscale = evaluator$optimization_scale %||% 1))
    consider(embed(opt$par))
  }, error = function(e) error <<- conditionMessage(e))
  outward <- selected$evaluation$gradient[boundary]
  checks <- c(NuisanceScore = nuisance(selected),
    OutwardViolation = max(c(0, -outward)),
    FixedError = max(c(0, abs(selected$parameters[c(fixed, boundary)] - start[c(fixed, boundary)]))))
  list(selected = selected, initial = initial, optimizer = opt, error = error,
    checks = checks, boundary_gradient = outward,
    nuisance_stationary = checks["NuisanceScore"] <= 1e-4,
    first_order_feasible = all(checks <= c(1e-4, 1e-4, 0)),
    global_optimality = "not assessed", free = free, fixed = fixed, boundary = boundary,
    rejections = c(slope = safe$rejections(), quadrature = safe$adaptive_quadrature_rejections()))
}
