# Direct finite boundary charts. No native inverse, Hessian or optimizer is
# used here. Common scale is variance v; rater slopes are c, not log(c).
mfrm_segmented_two_product <- function(a, b) {
  product <- a * b
  split <- 134217729
  aa <- split * a; bb <- split * b
  if (any(!is.finite(c(product, aa, bb)))) stop(new_adaptive_quadrature_numeric_error(
    "Affine logit product is outside the compensated arithmetic range."))
  ah <- aa - (aa - a); al <- a - ah
  bh <- bb - (bb - b); bl <- b - bh
  list(hi = product, lo = ((ah * bh - product) + ah * bl + al * bh) + al * bl)
}

mfrm_segmented_affine_logits <- function(origin, displacement, intercept, slope) {
  increment <- mfrm_segmented_dd_add(mfrm_segmented_two_product(origin, slope),
    mfrm_segmented_two_product(displacement, slope))
  current <- list(hi = origin * 0, lo = origin * 0)
  values <- lapply(intercept, function(b) {
    answer <- mfrm_segmented_dd_add(current, list(hi = b, lo = 0))
    current <<- mfrm_segmented_dd_add(current, increment)
    answer
  })
  at <- max.col(do.call(cbind, lapply(values, `[[`, "hi")), ties.method = "first")
  top <- list(hi = origin * 0, lo = origin * 0)
  for (k in seq_along(values)) {
    take <- at == k; top$hi[take] <- values[[k]]$hi[take]; top$lo[take] <- values[[k]]$lo[take]
  }
  matrix(vapply(values, function(x) {
    d <- mfrm_segmented_dd_add(x, list(hi = -top$hi, lo = -top$lo))
    d$hi + d$lo
  }, numeric(length(origin))), length(origin), length(intercept))
}

mfrm_gmfrm_natural_evaluator <- function(idx, config, sizes,
                                        chart = c("rater_intercepts", "common_scale"),
                                        variance_score = c("auto", "heat", "prior")) {
  chart <- match.arg(chart)
  variance_score <- match.arg(variance_score)
  if (chart != "common_scale" && variance_score != "auto")
    stop("Variance-score representations apply only to the common-scale chart.")
  interior <- mfrm_gmfrm_coordinates(config, sizes, chart)
  if (any((idx$weight %||% 1) != 1)) stop("Natural charts require unweighted observations.")
  owners <- config$slope_facet; n <- lengths(config$gpcm_spec$component_levels)
  ni <- n[1L]; nr <- n[2L]; K <- config$n_cat - 1L
  sl <- build_param_slices(sizes); p <- interior$dimension
  first <- sl[[owners[1L]]]; second <- sl[[owners[2L]]]
  location <- c(first, second, sl$steps)
  alpha <- head(sl$log_slopes, ni - 1L); rcoords <- tail(sl$log_slopes, nr)
  natural <- if (chart == "rater_intercepts") rcoords else tail(rcoords, 1L)
  lower <- rep(-Inf, p); lower[natural] <- 0
  ci <- sum_zero_jacobian(ni); cr <- sum_zero_jacobian(nr); ct <- sum_zero_jacobian(K)
  cells <- config$gpcm_spec$cells[idx$slope_idx, , drop = FALSE]
  ii <- cells[[1L]]; rr <- cells[[2L]]
  qcols <- matrix(length(first) + seq_len(nr * K), nr, K, byrow = TRUE)
  tcols <- matrix(sl$steps, nr, K - 1L, byrow = TRUE)
  categories <- 0:K; groups <- split(seq_along(idx$score_k), idx$person)
  rules <- lapply(c(16L, 32L), mfrm_legendre_unit_rule)
  fail <- function(message, integration = NULL, score_error = NULL) {
    e <- new_adaptive_quadrature_numeric_error(message)
    e$integration <- integration; e$score_error <- score_error; stop(e)
  }
  check <- function(z) {
    if (!is.numeric(z) || is.complex(z) || length(z) != p || any(!is.finite(z)))
      stop("Natural coordinates require a finite real vector of the expected length.")
    if (any(z[natural] < 0)) fail("Natural slope/variance coordinates must be nonnegative.")
  }
  from_native <- function(par) {
    z <- interior$to_chart(par)
    z[natural] <- exp(z[natural] * if (chart == "common_scale") 2 else 1)
    if (any(!is.finite(z)) || any(z[natural] <= 0))
      fail("Native transformation left the representable positive interior.")
    z
  }
  # At a boundary only targets independent of the unsupported native blocks
  # are returned. A defined chart target is not an identification certificate.
  target <- function(z, C) {
    check(z)
    if (!is.numeric(C) || is.complex(C) || length(C) != p || any(!is.finite(C)))
      stop("Supply a finite real native target vector.")
    zero <- natural[z[natural] == 0]
    unavailable <- if (!length(zero)) integer() else if (chart == "common_scale")
      c(location, rcoords) else unlist(lapply(match(zero, rcoords), function(r)
        c(second[r], tcols[r, ], rcoords[r])))
    if (any(C[unavailable] != 0)) stop("This native target is not supported at this boundary.")
    temp <- z; temp[zero] <- 1
    temp[natural] <- log(temp[natural]) / if (chart == "common_scale") 2 else 1
    out <- interior$target(temp, C)
    positive <- setdiff(natural, zero)
    out$gradient[positive] <- out$gradient[positive] /
      (z[positive] * if (chart == "common_scale") 2 else 1)
    out$gradient[zero] <- 0
    out
  }
  cached <- NULL; state <- NULL; evaluations <- 0L; hits <- 0L
  compute <- function(z) {
    check(z)
    if (chart == "common_scale" && z[natural] == 0 && variance_score == "prior")
      fail("The prior variance score requires strictly positive variance.")
    ai <- exp(drop(ci %*% z[alpha]))
    if (any(!is.finite(ai)) || any(ai <= 0)) fail("Invalid first-family slopes.")
    b <- drop(ci %*% z[first]); nobs <- length(ii)
    Z <- dA <- matrix(0, nobs, p); Z[, alpha] <- ci[ii, , drop = FALSE]
    B <- matrix(0, nobs, K + 1L)
    dB <- lapply(seq_len(K + 1L), function(k) matrix(0, nobs, p))
    if (chart == "rater_intercepts") {
      c_r <- z[rcoords]; w <- ai[ii]; slope <- w * c_r[rr]
      dA[cbind(seq_len(nobs), rcoords[rr])] <- w
      q <- matrix(z[as.vector(t(qcols))], nr, K, byrow = TRUE)
      for (k in seq_len(K)) {
        B[, k + 1L] <- -w * (k * c_r[rr] * b[ii] + rowSums(q[rr, seq_len(k), drop = FALSE]))
        dB[[k + 1L]][, first] <- -k * slope * ci[ii, , drop = FALSE]
        dB[[k + 1L]][cbind(seq_len(nobs), rcoords[rr])] <- -k * w * b[ii]
        for (l in seq_len(k)) dB[[k + 1L]][cbind(seq_len(nobs), qcols[rr, l])] <- -w
      }
    } else {
      rho <- exp(drop(cr %*% z[head(rcoords, -1L)]))
      if (any(!is.finite(rho)) || any(rho <= 0)) fail("Invalid relative rater slopes.")
      w <- ai[ii] * rho[rr]; slope <- w * sqrt(z[natural])
      Z[, head(rcoords, -1L)] <- cr[rr, , drop = FALSE]
      for (k in seq_len(K)) {
        D <- matrix(0, nobs, p); D[, first] <- k * ci[ii, , drop = FALSE]
        D[cbind(seq_len(nobs), second[rr])] <- k
        if (K > 1L) for (l in seq_len(K - 1L))
          D[cbind(seq_len(nobs), tcols[rr, l])] <- sum(ct[seq_len(k), l])
        B[, k + 1L] <- -w * drop(D %*% z)
        dB[[k + 1L]] <- -w * D
      }
    }
    if (any(!is.finite(c(w, slope, B, unlist(dB))))) fail("Non-finite natural response coefficients.")
    positive <- if (chart == "rater_intercepts") c_r[rr] > 0 else z[natural] > 0
    if (any(w <= 0) || any(slope == 0 & positive))
      fail("Positive response slope underflowed; this is not a zero boundary.")
    value <- 0; gradient <- rule_error <- tail_error <- numeric(p)
    nll_rule <- tail_nll <- 0
    forms <- c(heat = 0L, prior = 0L)
    exact_zero <- chart == "common_scale" && z[natural] == 0
    if (exact_zero) {
      # With no ability dependence, sum conditional contributions directly.
      # Keep Person grouping for the variance derivative's cross-response terms.
      lp <- B - apply(B, 1L, max); lp <- lp - log(rowSums(exp(lp)))
      pr <- exp(lp); observed <- cbind(seq_len(nobs), idx$score_k + 1L)
      scores <- Z * rowSums(pr * (B[observed] - B))
      observed_derivative <- matrix(0, nobs, p)
      for (k in categories) {
        take <- idx$score_k == k
        observed_derivative[take, ] <- dB[[k + 1L]][take, , drop = FALSE]
      }
      for (k in categories) scores <- scores + pr[, k + 1L] * (observed_derivative - dB[[k + 1L]])
      residual <- rowSums(pr * (idx$score_k - matrix(categories, nobs, K + 1L, byrow = TRUE)))
      mu <- drop(pr %*% categories)
      variance <- rowSums(pr * (matrix(categories, nobs, K + 1L, byrow = TRUE) - mu)^2)
      U <- rowsum(w * residual, idx$person, reorder = FALSE)
      A <- rowsum(w^2 * variance, idx$person, reorder = FALSE)
      value <- -sum(lp[observed]); gradient <- -colSums(scores)
      gradient[natural] <- -sum((U^2 - A) / 2)
      forms["heat"] <- length(groups)
    }
    for (rows in if (exact_zero) list() else groups) {
      use_prior <- FALSE
      if (chart == "common_scale") {
        v <- z[natural]
        heat_bound <- ((sum(w[rows] * pmax(idx$score_k[rows], K - idx$score_k[rows])))^2 +
          sum(w[rows]^2) * K^2 / 4) / 2
        # Compare prior-integrated absolute-score envelopes before quadrature.
        # Both are exact identities; this choice is not a precision certificate.
        use_prior <- v > 0 && (variance_score == "prior" ||
          (variance_score == "auto" && heat_bound > 1 / v))
        form <- if (use_prior) "prior" else "heat"
        forms[form] <- forms[form] + 1L
      }
      c0 <- c1 <- numeric(p)
      for (j in rows) {
        y <- idx$score_k[j]; maxdiff <- max(abs(y - categories))
        delta <- do.call(rbind, lapply(dB, function(d) dB[[y + 1L]][j, ] - d[j, ]))
        c0 <- c0 + apply(abs(delta), 2L, max) + max(abs(B[j, y + 1L] - B[j, ])) * abs(Z[j, ])
        c1 <- c1 + maxdiff * (abs(dA[j, ]) + slope[j] * abs(Z[j, ]))
      }
      if (chart == "common_scale") c0[natural] <- if (use_prior) 1 / (2 * v) else heat_bound
      if (any(!is.finite(c(c0, c1)))) fail("Non-finite natural score envelope.")
      kernel <- function(theta, origin = theta, displacement = 0) {
        nq <- length(theta); joint <- stats::dnorm(theta, log = TRUE)
        theta_score <- -theta; U <- matrix(0, nq, p); u_score <- u_info <- numeric(nq)
        for (j in rows) {
          logits <- mfrm_segmented_affine_logits(origin, displacement, B[j, ], slope[j])
          if (any(!is.finite(logits))) fail("Non-finite natural response logits.")
          high <- apply(logits, 1L, max); lp <- logits - high
          lp <- lp - log(rowSums(exp(lp))); pr <- exp(lp); y <- idx$score_k[j]
          residual <- drop(pr %*% (y - categories))
          joint <- joint + lp[, y + 1L]; theta_score <- theta_score + slope[j] * residual
          delta <- do.call(rbind, lapply(dB, function(d) dB[[y + 1L]][j, ] - d[j, ]))
          U <- U + pr %*% delta + outer(theta * residual, dA[j, ]) +
            outer(rowSums(pr * (logits[, y + 1L] - logits)), Z[j, ])
          if (chart == "common_scale" && !use_prior) {
            mu <- drop(pr %*% categories)
            variance <- rowSums(pr * (matrix(categories, nq, K + 1L, byrow = TRUE) - mu)^2)
            u_score <- u_score + w[j] * residual; u_info <- u_info + w[j]^2 * variance
          }
        }
        # Heat identity at v=0; prior-density score avoids squared large slopes.
        if (chart == "common_scale") U[, natural] <- if (use_prior)
          (theta^2 - 1) / (2 * v) else (u_score^2 - u_info) / 2
        if (any(!is.finite(c(joint, theta_score, U)))) fail("Non-finite natural likelihood or score.")
        list(joint = joint, theta_score = theta_score, score = U)
      }
      if (all(slope[rows] == 0)) {
        at <- kernel(0)
        value <- value - at$joint + stats::dnorm(0, log = TRUE)
        gradient <- gradient - drop(at$score)
        next
      }
      mode <- stats::uniroot(function(t) kernel(t)$theta_score, c(-1, 1),
        extendInt = "downX", check.conv = TRUE, tol = 1e-14)$root
      peak <- kernel(mode)$joint; cuts <- mode; ends <- numeric(2)
      for (side in c(-1, 1)) for (drop in c(.5, 2, 8, 32, 64)) {
        bound <- stats::uniroot(function(t) kernel(t)$joint - peak + drop,
          sort(c(mode, mode + side * (sqrt(2 * drop) + 1))), tol = 1e-14)$root
        cuts <- c(cuts, bound)
        if (drop == 64) ends[(side + 3L) / 2L] <- bound
      }
      for (j in rows[slope[rows] > 0]) for (k in seq_len(K)) for (l in 0:(k - 1L)) {
        denom <- slope[j] * (k - l)
        crossing <- -(B[j, k + 1L] - B[j, l + 1L]) / denom
        extra <- crossing + c(-40, -16, -4, -1, 0, 1, 4, 16, 40) / denom
        cuts <- c(cuts, extra[is.finite(extra)])
      }
      cuts <- sort(unique(c(ends, cuts[cuts > ends[1L] & cuts < ends[2L]])))
      width <- diff(cuts); lo <- head(cuts, -1L)
      integral <- function(rule) {
        origin <- rep(lo, each = length(rule$nodes)); delta <- as.vector(outer(rule$nodes, width))
        at <- kernel(origin + delta, origin, delta)
        weight <- as.vector(outer(rule$weights, width)) * exp(at$joint - peak)
        mass <- sum(weight)
        if (!is.finite(mass) || mass <= 0) fail("Invalid natural marginal normalizer.")
        list(mass = mass, log_marginal = peak + log(mass), score = colSums(weight * at$score) / mass)
      }
      low <- integral(rules[[1L]]); high <- integral(rules[[2L]])
      nll_rule <- nll_rule + abs(low$log_marginal - high$log_marginal)
      rule_error <- rule_error + abs(low$score - high$score)
      mass_bound <- 0; score_bound <- numeric(p)
      for (side in 1:2) {
        at <- kernel(ends[side]); s <- c(1, -1)[side] * at$theta_score
        if (!is.finite(s) || s <= 0) fail("Invalid natural tail slope.")
        h <- exp(at$joint - peak); mass_bound <- mass_bound + h / s
        bound <- h * ((c0 + c1 * abs(ends[side])) / s + c1 / s^2)
        # |(theta^2-1)/(2v)| <= (theta^2+1)/(2v); integrate the
        # quadratic envelope against the log-concave exponential tail bound.
        if (use_prior) bound[natural] <- h / (2 * v) *
          ((1 + ends[side]^2) / s + 2 * abs(ends[side]) / s^2 + 2 / s^3)
        score_bound <- score_bound + bound
      }
      tail_nll <- tail_nll + log1p(mass_bound / high$mass)
      tail_error <- tail_error + (score_bound + abs(high$score) * mass_bound) / high$mass
      value <- value - high$log_marginal; gradient <- gradient - high$score
    }
    diagnostics <- c(NLLRuleDifference = nll_rule, ScoreRuleDifference = max(rule_error),
      TailNLLBound = tail_nll, TailScoreBound = max(tail_error))
    if (any(!is.finite(c(value, gradient, diagnostics))) ||
        any(diagnostics > c(1e-7, 1e-6, 1e-8, 1e-7)))
      fail("Natural likelihood/score integration did not meet its accuracy criteria.", diagnostics,
        list(rule = rule_error, tail = tail_error, variance_score = forms))
    list(value = value, gradient = gradient, integration = diagnostics,
      score_error = list(rule = rule_error, tail = tail_error),
      boundary_coordinates = natural[z[natural] == 0],
      ability_information = if (all(slope == 0)) "none; original ability posterior equals prior" else "not assessed",
      optimality = "not assessed", chart = chart,
      variance_score = if (chart == "common_scale") forms else NULL)
  }
  evaluate <- function(z) {
    if (!is.null(cached) && identical(z, cached)) { hits <<- hits + 1L; return(state) }
    cached <<- NULL; evaluations <<- evaluations + 1L
    state <<- tryCatch(compute(z), error = function(e) {
      e$parameters <- if (is.numeric(z)) z + 0 else z; stop(e)
    })
    cached <<- z + 0; state
  }
  list(evaluate = evaluate, value = function(z) evaluate(z)$value,
    gradient = function(z) evaluate(z)$gradient, from_native = from_native,
    target = target, lower = lower, natural = natural,
    diagnostics = function() list(Evaluations = evaluations, CacheHits = hits),
    optimization_scale = config$n_person)
}
