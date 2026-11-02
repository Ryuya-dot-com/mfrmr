# Private common-zero profile; neither the outer problem nor its Hessian is
# assumed convex. Targets are fixed original discrimination coordinates only.
mfrm_gmfrm_zero_profile_evaluator <- function(start, idx, config, sizes, fixed = integer()) {
  initial <- mfrm_gmfrm_zero_location_problem(start, idx, config, sizes)
  location <- initial$location
  discrimination <- setdiff(seq_along(start), c(location, length(start)))
  if (!is.numeric(fixed) || is.complex(fixed) || anyNA(fixed) ||
      any(!fixed %in% discrimination) || anyDuplicated(fixed))
    stop("Only original discrimination coordinates can be fixed in this profile.")
  free <- setdiff(discrimination, fixed)
  if (!length(free)) stop("At least one discrimination coordinate must remain free.")
  at <- match(free, discrimination)
  warm <- start[location]; cached <- NULL; state <- NULL
  solves <- failures <- hits <- 0L; rejected <- list()
  fail <- function(message, x, attempts = list()) {
    failures <<- failures + 1L
    rejected[[length(rejected) + 1L]] <<- list(outer = x, reason = message,
      inner_status = vapply(attempts, `[[`, "", "status"))
    e <- new_adaptive_quadrature_numeric_error(message)
    e$outer <- x; e$inner_attempts <- attempts; stop(e)
  }
  evaluate <- function(x) {
    if (!is.numeric(x) || is.complex(x) || length(x) != length(free) || any(!is.finite(x))) {
      cached <<- state <<- NULL
      stop("Profile coordinates must be a finite real vector of the expected length.")
    }
    if (!is.null(cached) && identical(x, cached)) { hits <<- hits + 1L; return(state) }
    cached <<- state <<- NULL
    z <- start + 0; z[free] <- x
    problem <- tryCatch(mfrm_gmfrm_zero_location_problem(z, idx, config, sizes),
      error = function(e) fail(conditionMessage(e), x))
    attempts <- list()
    # Every point uses the same policy: last qualified locations, then zero.
    # Rejected trials never become the next warm start.
    for (inner_start in list(warm, warm*0)) {
      solves <<- solves + 1L
      fit <- tryCatch(mfrm_gmfrm_zero_location_search(problem, inner_start),
        error = function(e) list(status = conditionMessage(e)))
      attempts[[length(attempts) + 1L]] <- fit
      if (!identical(fit$status, "stationary_convex_candidate")) next
      details <- tryCatch(problem$evaluate(fit$parameters, profile = TRUE), error = function(e) NULL)
      if (is.null(details) || max(abs(details$profile$gradient_correction[at])) > 1e-6) next
      z[location] <- fit$parameters
      answer <- list(value = details$value, gradient = details$profile$gradient[at],
        hessian = details$profile$hessian[at, at, drop = FALSE], parameters = z,
        inner = fit, gradient_correction = details$profile$gradient_correction[at],
        inner_attempts = vapply(attempts, `[[`, "", "status"),
        optimality = "outer/global optimality not assessed")
      warm <<- fit$parameters + 0; cached <<- x + 0; state <<- answer
      return(answer)
    }
    fail("Inner location problem did not qualify; no profile value or gradient returned.", x, attempts)
  }
  list(evaluate = evaluate, value = function(x) evaluate(x)$value,
    gradient = function(x) evaluate(x)$gradient, start = start[free], free = free,
    fixed = fixed, lower = rep(-Inf, length(free)), optimization_scale = config$n_person,
    diagnostics = function() list(inner_solves = solves, failed_points = failures,
      cache_hits = hits, rejected = rejected))
}
