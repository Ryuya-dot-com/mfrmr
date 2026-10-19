mfrm_segmented_two_sum <- function(a, b) {
  s <- a + b; z <- s - a
  list(hi = s, lo = (a - (s - z)) + (b - z))
}
mfrm_segmented_dd_add <- function(a, b) {
  x <- mfrm_segmented_two_sum(a$hi, b$hi)
  mfrm_segmented_two_sum(x$hi, x$lo + a$lo + b$lo)
}
mfrm_segmented_relative_logits <- function(origin, displacement, offset, slope) {
  theta <- mfrm_segmented_two_sum(origin, displacement)
  categories <- vector("list", length(offset)); current <- list(hi = origin * 0, lo = origin * 0)
  for (k in seq_along(offset)) {
    categories[[k]] <- mfrm_segmented_dd_add(current, list(hi = offset[k], lo = 0))
    current <- mfrm_segmented_dd_add(current, theta)
  }
  high <- max.col(do.call(cbind, lapply(categories, `[[`, "hi")), ties.method = "first")
  top_hi <- top_lo <- numeric(length(origin))
  for (k in seq_along(offset)) {
    take <- high == k; top_hi[take] <- categories[[k]]$hi[take]; top_lo[take] <- categories[[k]]$lo[take]
  }
  matrix(vapply(categories, function(x) {
    d <- mfrm_segmented_dd_add(x, list(hi = -top_hi, lo = -top_lo))
    slope * (d$hi + d$lo)
  }, numeric(length(origin))), nrow = length(origin), ncol = length(offset))
}
# Internal candidate; public fitting, information and scoring still use their
# declared integration rule. This evaluator alone cannot qualify that pipeline.
mfrm_legendre_unit_rule <- function(order) {
  if (length(order) != 1L || !is.numeric(order) || !is.finite(order) ||
      order < 2L || order != floor(order)) stop("Invalid Legendre order.")
  i <- seq_len(order - 1L)
  J <- matrix(0, order, order)
  J[cbind(i, i + 1L)] <- i / sqrt(4 * i^2 - 1)
  e <- eigen(J + t(J), symmetric = TRUE); at <- order(e$values)
  list(nodes = (e$values[at] + 1) / 2, weights = e$vectors[1L, at]^2)
}

mfrm_gmfrm_segmented_evaluator <- function(idx, config, sizes) {
  if (!identical(config$method, "MML") || !identical(config$model, "GPCM") ||
      is.null(config$gpcm_spec$component_levels) ||
      isTRUE(config$population_spec$active) || any((idx$weight %||% 1) != 1)) {
    stop("Segmented candidate requires unweighted two-family MML with fixed N(0,1).")
  }
  n <- length(idx$score_k); p <- sum(unlist(sizes, use.names = FALSE))
  categories <- seq_len(config$n_cat) - 1L; K <- max(categories)
  adjacent <- mfrmr_estimability_adjacent_design(
    NULL, idx, config, sizes, include_person = FALSE, include_population_beta = FALSE)
  mapping <- Matrix::sparseMatrix(i = seq_len(ncol(adjacent$design)),
    j = adjacent$map$OptimizerIndex, x = 1, dims = c(ncol(adjacent$design), p))
  adjacent <- as.matrix(adjacent$design %*% mapping)
  cumulative <- Reduce(`+`, lapply(seq_len(K), function(k)
    adjacent[seq_len(n) + (k - 1L) * n, , drop = FALSE]), accumulate = TRUE)
  slopes <- build_param_slices(sizes)$log_slopes
  Z <- matrix(0, n, p)
  Z[, slopes] <- as.matrix(gpcm_log_slope_design(config$gpcm_spec))[idx$slope_idx, , drop = FALSE]
  # Native signed/centered/anchored category derivatives are constant in theta.
  delta <- lapply(seq_len(n), function(i) {
    D <- rbind(0, do.call(rbind, lapply(cumulative, function(x) x[i, , drop = FALSE])))
    matrix(D[idx$score_k[i] + 1L, ], K + 1L, p, byrow = TRUE) - D
  })
  groups <- split(seq_len(n), idx$person)
  rules <- lapply(c(16L, 32L), mfrm_legendre_unit_rule)
  cached_par <- NULL; state <- NULL; evaluations <- 0L; hits <- 0L
  fail <- function(message, diagnostics = NULL, person_errors = NULL) {
    error <- new_adaptive_quadrature_numeric_error(message)
    error$integration <- diagnostics
    error$person_errors <- person_errors
    stop(error)
  }

  compute <- function(par) {
    if (!is.numeric(par) || length(par) != p || any(!is.finite(par)))
      stop("Segmented MML requires a finite free-parameter vector of the expected length.")
    params <- expand_params(par, sizes, config)
    a <- params$slopes[idx$slope_idx]
    steps <- t(apply(params$steps_mat, 1L, function(x) c(0, cumsum(x))))
    offset <- outer(compute_base_eta(idx, params, config), categories) -
      steps[idx$step_idx, , drop = FALSE]
    value <- 0; gradient <- numeric(p)
    nll_error <- 0; score_error <- tail_score <- numeric(p); tail_nll <- 0
    person_errors <- list()
    for (rows in groups) {
      y <- idx$score_k[rows]; aa <- a[rows]; zz <- Z[rows, , drop = FALSE]
      off <- offset[rows, , drop = FALSE]
      kernel <- function(theta, derivatives = FALSE, origin = theta, displacement = 0) {
        nq <- length(theta); joint <- stats::dnorm(theta, log = TRUE)
        theta_score <- -theta
        U <- if (derivatives) matrix(0, nq, p) else NULL
        for (j in seq_along(rows)) {
          # Root finding only locates integration segments; compensated local
          # coordinates are essential for the integration nodes and score.
          logits <- if (derivatives) {
            mfrm_segmented_relative_logits(origin, displacement, off[j, ], aa[j])
          } else aa[j] * (outer(theta, categories) +
            matrix(off[j, ], nq, K + 1L, byrow = TRUE))
          if (any(!is.finite(logits))) fail("Non-finite segmented response logits.")
          high <- logits[, 1L]
          for (k in seq_len(K)) high <- pmax(high, logits[, k + 1L])
          lp <- logits - high
          lp <- lp - log(rowSums(exp(lp))); probability <- exp(lp)
          residual <- drop(probability %*% (y[j] - categories))
          joint <- joint + lp[, y[j] + 1L]
          theta_score <- theta_score + aa[j] * residual
          if (derivatives) {
            U <- U + aa[j] * (probability %*% delta[[rows[j]]]) +
              outer(rowSums(probability * (logits[, y[j] + 1L] - logits)), zz[j, ])
          }
        }
        if (any(!is.finite(c(joint, theta_score, U))))
          fail("Non-finite segmented likelihood or score.")
        list(joint = joint, theta_score = theta_score, score = U)
      }
      mode <- stats::uniroot(function(x) kernel(x)$theta_score, c(-1, 1),
        extendInt = "downX", check.conv = TRUE, tol = 1e-14)$root
      peak <- kernel(mode, TRUE)$joint
      cuts <- mode; ends <- numeric(2)
      for (side in c(-1, 1)) for (drop in c(.5, 2, 8, 32, 64)) {
        bound <- stats::uniroot(function(x) kernel(x)$joint - peak + drop,
          sort(c(mode, mode + side * (sqrt(2 * drop) + 1))), tol = 1e-14)$root
        cuts <- c(cuts, bound)
        if (drop == 64) ends[(side + 3L) / 2L] <- bound
      }
      for (j in seq_along(rows)) for (k in seq_len(K)) for (l in 0:(k - 1L)) {
        crossing <- -(off[j, k + 1L] - off[j, l + 1L]) / (k - l)
        cuts <- c(cuts, crossing + c(-40, -16, -4, -1, 0, 1, 4, 16, 40) /
          (aa[j] * (k - l)))
      }
      cuts <- sort(unique(c(ends, cuts[cuts > ends[1L] & cuts < ends[2L]])))
      widths <- diff(cuts); lower <- head(cuts, -1L)
      integrate_rule <- function(rule) {
        origin <- rep(lower, each = length(rule$nodes))
        displacement <- as.vector(outer(rule$nodes, widths))
        nodes <- origin + displacement
        ker <- kernel(nodes, TRUE, origin, displacement)
        w <- as.vector(outer(rule$weights, widths)) * exp(ker$joint - peak)
        mass <- sum(w)
        if (!is.finite(mass) || mass <= 0) fail("Invalid segmented normalizer.")
        list(mass = mass, log_marginal = peak + log(mass), score = colSums(w * ker$score) / mass)
      }
      low <- integrate_rule(rules[[1L]]); high <- integrate_rule(rules[[2L]])
      person_errors[[length(person_errors) + 1L]] <- list(rows = rows,
        mode = mode, cuts = cuts, low = low, high = high)
      nll_error <- nll_error + abs(high$log_marginal - low$log_marginal)
      score_error <- score_error + abs(high$score - low$score)
      # Complete-score envelope c0+c1*abs(theta), including nonlinear slopes.
      c0 <- c1 <- numeric(p)
      for (j in seq_along(rows)) {
        c0 <- c0 + aa[j] * (apply(abs(delta[[rows[j]]]), 2L, max) +
          max(abs(off[j, y[j] + 1L] - off[j, ])) * abs(zz[j, ]))
        c1 <- c1 + aa[j] * max(abs(y[j] - categories)) * abs(zz[j, ])
      }
      mass_bound <- 0; score_bound <- numeric(p)
      for (j in 1:2) {
        at <- kernel(ends[j], TRUE); s <- c(1, -1)[j] * at$theta_score
        if (!is.finite(s) || s <= 0) fail("Invalid segmented tail slope.")
        h <- exp(at$joint - peak)
        mass_bound <- mass_bound + h / s
        score_bound <- score_bound + h * ((c0 + c1 * abs(ends[j])) / s + c1 / s^2)
      }
      tail_nll <- tail_nll + log1p(mass_bound / high$mass)
      tail_score <- tail_score + (score_bound + abs(high$score) * mass_bound) / high$mass
      value <- value - high$log_marginal; gradient <- gradient - high$score
    }
    diagnostics <- c(NLLRuleDifference = nll_error, ScoreRuleDifference = max(score_error),
      TailNLLBound = tail_nll, TailScoreBound = max(tail_score))
    if (any(!is.finite(c(value, gradient, diagnostics))) ||
        nll_error > 1e-7 || max(score_error) > 1e-6 ||
        tail_nll > 1e-8 || max(tail_score) > 1e-7)
      fail("Segmented likelihood/score integration did not meet its accuracy criteria.",
        diagnostics, person_errors)
    list(value = value, gradient = gradient, integration = diagnostics,
      score_error = list(rule = score_error, tail = tail_score))
  }
  evaluate <- function(par) {
    if (!is.null(cached_par) && identical(par, cached_par)) { hits <<- hits + 1L; return(state) }
    cached_par <<- NULL; evaluations <<- evaluations + 1L
    candidate <- tryCatch(compute(par), error = function(e) {
      e$parameters <- if (is.numeric(par)) par + 0 else par
      e$evaluation <- evaluations
      stop(e)
    })
    state <<- candidate; cached_par <<- par + 0
    state
  }
  list(value = function(par) evaluate(par)$value,
    gradient = function(par) evaluate(par)$gradient, evaluate = evaluate,
    diagnostics = function() list(Evaluations = evaluations, CacheHits = hits),
    optimization_scale = config$n_person)
}
