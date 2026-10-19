# Private orchestration for one data/model/constraint. The caller supplies
# bound evaluators and an independent reference(z, native_parameters) callback.
# The callback returns reference$nll (and, in the interior, qualified,
# native_gradient and native componentwise score_error). No public fit is made.
mfrm_gmfrm_procedure <- function(starts, native, natural, reference,
                                 fixed = integer(), comparisons = list(), maxit = 400L) {
  real <- function(x, n) is.numeric(x) && !is.complex(x) && length(x) == n && all(is.finite(x))
  names_ok <- is.list(starts) && length(starts) >= 2L &&
    length(names(starts)) == length(starts) && !anyNA(names(starts)) &&
    all(nzchar(names(starts))) && !anyDuplicated(names(starts))
  p <- length(natural$lower); n <- native$optimization_scale
  if (!names_ok || !p || !is.numeric(natural$lower) || anyNA(natural$lower) ||
      any(!natural$lower %in% c(-Inf, 0)) || !real(n, 1L) || n <= 0 ||
      !identical(n, natural$optimization_scale) || !is.function(reference) ||
      !is.function(native$evaluate) || !is.function(natural$evaluate) ||
      !is.function(natural$target) || !is.function(natural$from_native) ||
      !real(fixed, length(fixed)) || anyDuplicated(fixed) ||
      any(fixed != trunc(fixed) | fixed < 1 | fixed > p) ||
      !real(maxit, 1L) || maxit < 1 || maxit > .Machine$integer.max || maxit != trunc(maxit))
    stop("Invalid private GMFRM procedure inputs.")
  free <- setdiff(seq_len(p), fixed); original <- starts[[1]][fixed]
  if (!length(free) || length(free) > 64L) stop("Procedure requires 1-64 free native coordinates.")
  for (z in starts) {
    if (!real(z, p) || any(z < natural$lower) || !identical(z[fixed], original))
      stop("Every prescribed start must satisfy the same original constraint and bounds.")
    # Fixed native indices are valid only for unchanged chart coordinates.
    for (j in fixed) {
      C <- replace(numeric(p), j, 1); t <- natural$target(z, C)
      if (!isTRUE(all.equal(t$gradient, C, tolerance=1e-12)) || t$value != z[j])
        stop("The fixed coordinate requires a transformed constraint, not a native index.")
    }
  }
  phase <- function(calculate) {
    value <- NULL; error <- NULL; warnings <- character()
    withCallingHandlers(tryCatch(value <- calculate(), error=function(e) error <<- e),
      warning=function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") })
    list(value=value, error=error, warnings=warnings)
  }
  candidates <- attempts <- setNames(vector("list", length(starts)), names(starts))
  refs <- setNames(rep(NA_real_, length(starts)), names(starts))
  for (name in names(starts)) {
    stages <- list(search=phase(function()
      mfrm_gmfrm_bounded_search(starts[[name]], natural, fixed, maxit)))
    search <- stages$search$value; candidate <- NULL
    if (!is.null(search)) {
      # Stage failures retain their endpoint and never erase the prescribed start.
      stages$handoff <- phase(function() mfrm_gmfrm_candidate(search, natural))
      candidate <- stages$handoff$value
      if (!is.null(candidate) && !length(candidate$boundary)) {
        stages$finish <- phase(function() {
          map <- mfrm_gmfrm_procedure_map(search$selected$parameters, natural)
          a <- native$evaluate(map$parameters)
          checks <- c(NLL=abs(a$value-search$selected$evaluation$value),
            Gradient=max(abs(drop(crossprod(map$jacobian,a$gradient))-search$selected$evaluation$gradient)))
          if (any(!is.finite(checks)) || any(checks > c(1e-7,1e-6)))
            stop("Native and natural search endpoints disagree.")
          mfrm_gmfrm_finish_interior(map$parameters, native, fixed)
        })
        finish <- stages$finish$value
        if (identical(finish$status, "interior_numerical_candidate")) {
          stages$chart <- phase(function() mfrm_gmfrm_procedure_chart(finish, natural, original))
          chart <- stages$chart$value
          if (isTRUE(chart$passed)) stages$reference <- phase(function()
            mfrm_gmfrm_procedure_reference(reference(chart$parameters, finish$selected$parameters),
              finish, chart, original, n))
        }
        stages$handoff <- phase(function() mfrm_gmfrm_candidate(search, natural,
          finish, stages$chart$value, stages$reference$value))
        candidate <- stages$handoff$value
        if (identical(candidate$status, "reference_qualified_local_candidate"))
          refs[name] <- candidate$stages$reference$reference$nll
      } else if (!is.null(candidate)) {
        # A boundary likelihood is a feasible witness, never an interior covariance.
        stages$reference <- phase(function() {
          r <- reference(search$selected$parameters, NULL)
          if (!real(r$reference$nll, 1L) ||
              abs(r$reference$nll-search$selected$evaluation$value) > 1e-7)
            stop("Boundary reference NLL does not match the saved endpoint.")
          r
        })
        if (!is.null(stages$reference$value)) refs[name] <- stages$reference$value$reference$nll
      }
    }
    candidates[name] <- list(candidate)
    failed <- names(stages)[vapply(stages, function(s) !is.null(s$error), TRUE)]
    attempts[[name]] <- list(start=starts[[name]], stages=stages, candidate=candidate,
      failed_stages=failed, status=if(length(failed)) paste0(tail(failed,1), "_error") else candidate$status)
  }
  complete <- all(vapply(candidates, function(a) !is.null(a), TRUE))
  selection <- if (complete) mfrm_gmfrm_select_candidates(candidates, names(starts), refs, comparisons) else NULL
  list(status=if(is.null(selection)) "incomplete_start_execution" else selection$status,
    attempts=attempts, selection=selection, candidate=selection$candidate,
    reference_nll=refs, comparisons=comparisons, fixed=fixed, fixed_values=original,
    maxit=maxit, scope="private local procedure; caller-bound data/model and independent reference",
    global_optimality="not assessed", interval_qualification="not assessed")
}

# The existing target map supplies dp/dz for either chart and any score ladder.
# No inverse is requested at a zero-slope boundary; no Hessian is transported.
mfrm_gmfrm_procedure_map <- function(z, natural) {
  p <- length(z)
  targets <- lapply(seq_len(p), function(j) natural$target(z, replace(numeric(p),j,1)))
  list(parameters=vapply(targets, `[[`, 0, "value"),
    jacobian=t(vapply(targets, `[[`, numeric(p), "gradient")))
}

mfrm_gmfrm_procedure_chart <- function(finish, natural, original) {
  p <- finish$selected$parameters; z <- natural$from_native(p)
  a <- natural$evaluate(z); map <- mfrm_gmfrm_procedure_map(z, natural)
  V <- finish$information$covariance; free <- finish$free
  e <- drop(crossprod(abs(solve(map$jacobian)), Reduce(`+`, a$score_error)))
  checks <- c(NLL=abs(a$value-finish$selected$evaluation$value),
    Gradient=max(abs(a$gradient-drop(crossprod(map$jacobian,finish$selected$evaluation$gradient)))),
    RawNatural=max(abs(a$gradient[free])), Target=max(c(0,abs(z[finish$fixed]-original))),
    Roundtrip=max(abs(map$parameters-p)),
    IntegrationDiagnostic=sqrt(drop(crossprod(e[free],abs(V)%*%e[free]))))
  list(parameters=z, evaluation=a, jacobian=map$jacobian, checks=checks,
    passed=all(is.finite(checks)) && all(checks >= 0 & checks <= c(1e-7,1e-6,1e-4,0,1e-12,1e-5)))
}

mfrm_gmfrm_procedure_reference <- function(r, finish, chart, original, n) {
  p <- finish$selected$parameters; g <- r$native_gradient; e <- r$score_error
  if (!is.numeric(g) || is.complex(g) || length(g) != length(p) || any(!is.finite(g)) ||
      !is.list(e) || !identical(sort(names(e)), c("rule","tail")) ||
      any(lengths(e) != length(p)) || any(vapply(e, function(x)
        !is.numeric(x) || is.complex(x) || any(!is.finite(x)) || any(x < 0), TRUE)) ||
      !is.numeric(r$reference$nll) || is.complex(r$reference$nll) ||
      length(r$reference$nll) != 1L || !is.finite(r$reference$nll))
    stop("Independent reference requires finite NLL, full native gradient and componentwise diagnostics.")
  J <- chart$jacobian; gz <- drop(crossprod(J,g)); free <- finish$free
  V <- finish$information$covariance; error <- Reduce(`+`,e)[free]
  checks <- c(NLLNative=abs(r$reference$nll-finish$selected$evaluation$value),
    NLLNatural=abs(r$reference$nll-chart$evaluation$value),
    GradientNative=max(abs(g-finish$selected$evaluation$gradient)),
    GradientNatural=max(abs(gz-chart$evaluation$gradient)),
    RawNative=max(abs(g[free])), MeanNative=max(abs(g[free]))/n,
    StandardizedNative=sqrt(drop(crossprod(g[free],V%*%g[free]))), RawNatural=max(abs(gz[free])),
    NaturalRule=max(drop(crossprod(abs(J),e$rule))), NaturalTail=max(drop(crossprod(abs(J),e$tail))),
    IntegrationDiagnostic=sqrt(drop(crossprod(error,abs(V)%*%error))),
    Target=max(c(0,abs(p[finish$fixed]-original))))
  r$natural_gradient <- gz; r$checks <- checks
  r$passed <- isTRUE(r$reference$qualified) && all(is.finite(checks)) &&
    all(checks >= 0 & checks <= c(1e-7,1e-7,1e-6,1e-6,1e-4,1e-6,1e-4,1e-4,1e-6,1e-7,1e-5,0))
  r
}
