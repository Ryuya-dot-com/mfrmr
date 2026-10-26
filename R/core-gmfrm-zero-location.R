# Private fixed-discrimination subproblem, only at common variance zero.
mfrm_gmfrm_zero_location_problem <- function(z, idx, config, sizes) {
  map <- mfrm_gmfrm_coordinates(config, sizes, "common_scale")
  if (!is.numeric(z) || is.complex(z) || length(z) != map$dimension ||
      any(!is.finite(z)) || tail(z, 1L) != 0)
    stop("Location subproblem requires finite common-zero coordinates.")
  if (any((idx$weight %||% 1) != 1)) stop("Location subproblem requires unweighted observations.")
  owners <- config$slope_facet; n <- lengths(config$gpcm_spec$component_levels)
  ni <- n[1L]; nr <- n[2L]; K <- config$n_cat - 1L
  sl <- build_param_slices(sizes)
  location <- c(sl[[owners[1L]]], sl[[owners[2L]]], sl$steps)
  nb <- length(location); ci <- sum_zero_jacobian(ni); ct <- sum_zero_jacobian(K)
  cells <- config$gpcm_spec$cells
  counts <- matrix(tabulate((idx$slope_idx - 1L)*(K + 1L) + idx$score_k + 1L,
    nrow(cells)*(K + 1L)), nrow(cells), K + 1L, byrow = TRUE)
  keep <- rowSums(counts) > 0; cells <- cells[keep, , drop = FALSE]
  counts <- counts[keep, , drop = FALSE]; totals <- rowSums(counts)
  ii <- cells[[1L]]; rr <- cells[[2L]]; nc <- nrow(cells)
  loga <- drop(ci %*% z[head(sl$log_slopes, ni - 1L)])
  logr <- drop(sum_zero_jacobian(nr) %*% head(tail(z, nr), -1L))
  a <- exp(loga); rho <- exp(logr); w <- a[ii]*rho[rr]
  if (any(!is.finite(c(a, rho, w))) || any(c(a, rho, w) <= 0)) stop("Invalid fixed discrimination products.")
  tcols <- matrix(sl$steps, nr, K - 1L, byrow = TRUE)
  D <- lapply(0:K, function(k) {
    d <- matrix(0, nc, nb); d[, sl[[owners[1L]]]] <- -k*ci[ii, , drop = FALSE]
    d[cbind(seq_len(nc), sl[[owners[2L]]][rr])] <- -k
    if (k > 0L && K > 1L) for (l in seq_len(K - 1L))
      d[cbind(seq_len(nc), tcols[rr, l])] <- -sum(ct[seq_len(k), l])
    d
  })
  # Observed categories in one cell must tie along any recession direction.
  # Full rank of these equalities is sufficient (not necessary) for coercivity.
  equalities <- matrix(0, 0L, nb)
  for (j in seq_len(nc)) {
    observed <- which(counts[j, ] > 0)
    for (k in observed[-1L]) equalities <- rbind(equalities, D[[k]][j, ] - D[[observed[1L]]][j, ])
  }
  rank <- if (nrow(equalities)) qr(equalities, tol = 1e-12)$rank else 0L
  support <- list(rank = rank, dimension = nb, finite_unique = rank == nb,
    criterion = "full rank of within-cell observed-category logit differences; sufficient only")
  X <- lapply(D, function(d) w*d)
  scale <- vapply(seq_len(nb), function(j) max(abs(vapply(X, function(x) max(abs(x[, j])), 0))), 0)
  if (any(!is.finite(scale)) || any(scale <= 0)) stop("Unrepresented or non-finite location columns.")
  evaluate <- function(location_value, profile = FALSE) {
    if (!is.numeric(location_value) || is.complex(location_value) ||
        length(location_value) != nb || any(!is.finite(location_value)))
      stop("Location values must be a finite real vector.")
    logits <- vapply(X, function(x) drop(x %*% location_value), numeric(nc))
    if (any(!is.finite(logits))) stop("Non-finite location logits.")
    lp <- logits - apply(logits, 1L, max); lp <- lp - log(rowSums(exp(lp)))
    pr <- exp(lp); meanX <- matrix(0, nc, nb)
    gradient <- numeric(nb); hessian <- matrix(0, nb, nb)
    for (k in seq_len(K + 1L)) {
      meanX <- meanX + pr[, k]*X[[k]]
      gradient <- gradient + drop(crossprod(X[[k]], totals*pr[, k] - counts[, k]))
    }
    for (k in seq_len(K + 1L)) {
      centered <- (X[[k]] - meanX)*sqrt(totals*pr[, k])
      hessian <- hessian + crossprod(centered)
    }
    value <- -sum(counts*lp)
    if (any(!is.finite(c(value, gradient, hessian)))) stop("Non-finite location derivatives.")
    answer <- list(value = value, gradient = gradient, hessian = hessian)
    if (isTRUE(profile)) {
      Z <- cbind(ci[ii, , drop = FALSE], sum_zero_jacobian(nr)[rr, , drop = FALSE])
      mean_logit <- rowSums(pr*logits)
      row_score <- rowSums((totals*pr - counts)*logits)
      cross <- matrix(0, nb, ncol(Z))
      for (k in seq_len(K + 1L)) {
        cross <- cross + crossprod(X[[k]], (totals*pr[, k] - counts[, k])*Z) +
          crossprod(X[[k]] - meanX, (totals*pr[, k]*(logits[, k] - mean_logit))*Z)
      }
      curvature <- row_score + totals*rowSums(pr*(logits - mean_logit)^2)
      H <- hessian/outer(scale, scale); R <- chol(H)
      if (rcond(H) < 1e-12) stop("Unresolved location curvature for profiling.")
      inverse <- function(b) backsolve(R, forwardsolve(t(R), b/scale))/scale
      answer$profile <- list(gradient = drop(crossprod(Z, row_score)),
        hessian = crossprod(Z, curvature*Z) - crossprod(cross, inverse(cross)),
        # First-order diagnostic, not a rigorous bound on the profile score error.
        gradient_correction = drop(crossprod(cross, inverse(gradient))))
      if (any(!is.finite(unlist(answer$profile)))) stop("Non-finite profile derivatives.")
    }
    answer
  }
  list(evaluate = evaluate, location = location, start = z[location], support = support,
    scale = scale, max_logit_change = function(d) max(abs(unlist(lapply(X, function(x) x %*% d)))))
}

mfrm_gmfrm_zero_location_search <- function(problem, start = problem$start, maxit = 80L) {
  if (length(maxit) != 1L || !is.finite(maxit) || maxit < 1 || maxit != as.integer(maxit))
    stop("maxit must be a positive integer.")
  current <- problem$evaluate(start); par <- start; status <- "iteration_limit"
  history <- current$value; iteration <- 0L; decrement <- NA_real_
  if (!isTRUE(problem$support$finite_unique)) status <- "finite_optimum_not_certified"
  else for (iteration in seq_len(maxit)) {
    scale <- problem$scale
    H <- current$hessian / outer(scale, scale); g <- current$gradient / scale
    R <- tryCatch(chol(H), error = function(e) NULL)
    if (is.null(R) || rcond(H) < 1e-12) { status <- "unresolved_curvature"; break }
    step <- -backsolve(R, forwardsolve(t(R), g)) / scale
    decrement <- -sum(current$gradient*step)
    if (!is.finite(decrement) || decrement < 0) { status <- "invalid_newton_direction"; break }
    if (max(abs(current$gradient)) <= 1e-6 && max(abs(g)) <= 1e-8 && decrement <= 1e-12) {
      status <- "stationary_convex_candidate"; break
    }
    fraction <- min(1, 10/max(10, problem$max_logit_change(step)))
    accepted <- FALSE; slack <- 64*.Machine$double.eps*max(1, abs(current$value))
    for (backtrack in seq_len(50L)) {
      trial <- tryCatch(problem$evaluate(par + fraction*step), error = function(e) NULL)
      if (!is.null(trial) && (trial$value <= current$value - 1e-4*fraction*decrement ||
          (trial$value <= current$value + slack &&
           max(abs(trial$gradient/scale)) < max(abs(g)) && fraction*decrement <= slack))) {
        accepted <- TRUE; break
      }
      fraction <- fraction/2
    }
    if (!accepted) { status <- "line_search_unresolved"; break }
    par <- par + fraction*step; current <- trial; history <- c(history, current$value)
  }
  list(parameters = par, evaluation = current, status = status, iterations = iteration,
    decrement = decrement, history = history, support = problem$support,
    scope = "fixed finite discrimination, common variance zero; outer optimality not assessed")
}
