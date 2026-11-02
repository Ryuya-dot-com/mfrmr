# Private finite-interior finish in native coordinates. The caller preserves
# the original data/constraint and checks the natural chart and independent
# reference. This does not change a previous optimizer's convergence code.
mfrm_gmfrm_finish_interior <- function(start, evaluator, fixed = integer()) {
  p <- length(start); n <- evaluator$optimization_scale
  if (!is.numeric(start) || is.complex(start) || !p || any(!is.finite(start)) ||
      !is.numeric(fixed) || is.complex(fixed) || any(!is.finite(fixed)) ||
      any(fixed != trunc(fixed) | fixed < 1 | fixed > p) || anyDuplicated(fixed) ||
      !is.numeric(n) || is.complex(n) || length(n) != 1L || !is.finite(n) || n <= 0)
    stop("Invalid native interior-finish inputs.")
  free <- setdiff(seq_len(p), fixed)
  if (!length(free) || length(free) > 64L)
    stop("Interior finish requires 1-64 free native coordinates.")
  embed <- function(z) { par <- start + 0; par[free] <- z; par }
  evaluations <- 0L; cached <- NULL; cached_at <- NULL
  evaluate <- function(z) {
    if (!is.null(cached_at) && identical(z, cached_at)) return(cached)
    par <- embed(z)
    if (any(!is.finite(par))) stop("Nonfinite interior-finish trial.")
    evaluations <<- evaluations + 1L
    a <- evaluator$evaluate(par)
    e <- a$score_error
    if (!is.numeric(a$value) || is.complex(a$value) || length(a$value) != 1L ||
        !is.finite(a$value) || !is.numeric(a$gradient) || is.complex(a$gradient) ||
        length(a$gradient) != p || any(!is.finite(a$gradient)) ||
        !is.list(e) || !identical(sort(names(e)), c("rule", "tail")) ||
        any(lengths(e) != p) || any(vapply(e, function(x)
          !is.numeric(x) || is.complex(x) || any(!is.finite(x)) || any(x < 0), TRUE)))
      stop("Interior finish requires a finite total NLL, full gradient and componentwise integration diagnostics.")
    cached_at <<- z + 0; cached <<- a; a
  }
  value <- function(z) evaluate(z)$value
  gradient <- function(z) evaluate(z)$gradient[free]
  out <- list(initial = NULL, selected = NULL, proposal = NULL, information = NULL,
    checks = NULL, status = "numerical_refusal", error = "", fixed = fixed, free = free,
    scope = "native interior local candidate only; natural-coordinate and independent checks pending",
    global_optimality = "not assessed")
  tryCatch({
    z <- start[free]; initial <- evaluate(z)
    out$initial <- out$selected <- list(parameters=start + 0, evaluation=initial)
    if (any(initial$gradient[free] != 0)) {
      out$proposal <- mfrm_optimizer_curvature_proposal(z, value, gradient)
      if (is.null(out$proposal$par)) {
        out$status <- "proposal_unavailable"; out$error <- out$proposal$error
        out$evaluations <- evaluations; return(out)
      }
      z <- out$proposal$par
      out$selected <- list(parameters=embed(z), evaluation=evaluate(z))
    }
    terminal <- out$selected$evaluation; g <- terminal$gradient[free]
    out$checks <- c(RawScore=max(abs(g)), MeanScore=max(abs(g))/n,
      FixedError=max(c(0, abs(out$selected$parameters[fixed]-start[fixed]))))
    if (any(out$checks > c(1e-4, 1e-6, 0))) {
      out$status <- "score_unresolved"
      out$evaluations <- evaluations; return(out)
    }
    # At the selected point, not at the proposal origin. Retain the entire
    # nuisance matrix; a slope block is not joint marginal information.
    hessians <- lapply(c(1e-4, 5e-5), function(h) {
      raw <- matrix(vapply(seq_along(z), function(j) {
        d <- z*0; d[j] <- h
        (gradient(z+d)-gradient(z-d))/(2*h)
      }, numeric(length(z))), nrow=length(z))
      if (any(!is.finite(raw))) stop("Nonfinite terminal marginal curvature.")
      list(raw=raw, symmetric=(raw+t(raw))/2)
    })
    H <- hessians[[2]]$symmetric
    coarse <- chol2inv(chol(hessians[[1]]$symmetric))
    root <- chol(H); V <- chol2inv(root)
    delta <- drop(V %*% g); e <- Reduce(`+`, terminal$score_error)[free]
    decrement <- sum(g*delta); integration <- drop(crossprod(e, abs(V) %*% e))
    if (any(!is.finite(c(decrement, integration))) || decrement < 0 || integration < 0)
      stop("Invalid information-scaled precision diagnostic.")
    out$information <- list(parameters=out$selected$parameters, free=free,
      hessian=H, covariance=V, hessians=hessians, newton_step=-delta,
      predicted_decrease=decrement/2, regularized=FALSE)
    out$checks <- c(out$checks,
      StandardizedScore=sqrt(decrement),
      InverseResidual=norm(H %*% V-diag(length(free)), "I"),
      CovarianceChange=norm(root %*% (coarse-V) %*% t(root), "2"),
      IntegrationDiagnostic=sqrt(integration))
    out$status <- if (all(is.finite(out$checks)) &&
      all(out$checks <= c(1e-4, 1e-6, 0, 1e-4, 1e-6, .01, 1e-5)))
      "interior_numerical_candidate" else "precision_unresolved"
  }, error=function(e) { out$error <<- conditionMessage(e) })
  out$evaluations <- evaluations
  out
}
