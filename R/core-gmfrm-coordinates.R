# Interior coordinate adapter, not a boundary estimator or a new likelihood.
mfrm_gmfrm_coordinates <- function(config, sizes,
                                   chart = c("rater_intercepts", "common_scale")) {
  chart <- match.arg(chart)
  roles <- mfrm_gpcm_slope_roles(config)
  owners <- roles$SlopeOwner
  levels <- config$gpcm_spec$component_levels
  K <- config$n_cat - 1L; ni <- length(levels[[1L]]); nr <- length(levels[[2L]])
  fs <- config$facet_specs; ss <- mfrmr_step_specs(config)
  if (!identical(config$model, "GPCM") || length(owners) != 2L ||
      !identical(config$facet_names, owners) ||
      !identical(config$step_facet, owners[2L]) ||
      !all(config$facet_signs == -1) || length(config$interaction_specs) ||
      !isTRUE(fs[[owners[1L]]]$centered) || isTRUE(fs[[owners[2L]]]$centered) ||
      any(vapply(fs, function(x) any(!is.na(x$anchors)) || any(!is.na(x$groups)), TRUE)) ||
      length(ss) != nr || any(vapply(ss, function(x)
        any(!is.na(x$anchors)) || x$target != 0, TRUE)) ||
      !identical(sizes, build_param_sizes(config))) {
    stop("Coordinate adapter requires the unanchored native two-family identification.")
  }
  sl <- build_param_slices(sizes)
  location <- c(sl[[owners[1L]]], sl[[owners[2L]]], sl$steps)
  first <- sl[[owners[1L]]]; second <- sl[[owners[2L]]]
  p <- sum(unlist(sizes)); nb <- length(location)
  slopes <- sl$log_slopes
  rlog <- tail(slopes, nr)
  stopifnot(identical(location, seq_len(nb)), length(first) == ni - 1L,
    length(second) == nr, length(sl$steps) == nr * (K - 1L),
    length(slopes) == ni - 1L + nr, p == nb + length(slopes))
  qcols <- matrix(length(first) + seq_len(nr * K), nr, K, byrow = TRUE)
  stepcols <- matrix(sl$steps, nr, K - 1L, byrow = TRUE)
  contrast <- sum_zero_jacobian(K)
  H <- cbind(sum_zero_jacobian(nr), 1)
  check <- function(x) {
    if (!is.numeric(x) || is.complex(x) || length(x) != p || any(!is.finite(x)))
      stop("Coordinates require a finite real vector of the expected length.")
  }
  positive <- function(x) {
    answer <- exp(x)
    if (any(!is.finite(answer)) || any(answer <= 0))
      stop(new_adaptive_quadrature_numeric_error(
        "Coordinate transformation left the representable positive interior."))
    answer
  }
  to_chart <- function(par) {
    check(par); z <- unname(par)
    if (chart == "rater_intercepts") {
      c_r <- positive(par[rlog])
      for (r in seq_len(nr)) z[qcols[r, ]] <-
        c_r[r] * (par[second[r]] + drop(contrast %*% par[stepcols[r, ]]))
    } else {
      average <- mean(par[rlog]); lambda <- positive(average)
      z[location] <- lambda * par[location]
      z[rlog] <- c(head(par[rlog] - average, -1L), average)
    }
    check(z); z
  }
  decode <- function(z) {
    check(z); par <- unname(z); J <- diag(p)
    if (chart == "rater_intercepts") {
      c_r <- positive(z[rlog]); J[c(second, sl$steps), ] <- 0
      for (r in seq_len(nr)) {
        q <- z[qcols[r, ]]; average <- mean(q)
        par[second[r]] <- average / c_r[r]
        par[stepcols[r, ]] <- head(q - average, -1L) / c_r[r]
        J[second[r], qcols[r, ]] <- 1 / (K * c_r[r])
        if (K > 1L) J[stepcols[r, ], qcols[r, ]] <-
          (diag(K)[seq_len(K - 1L), , drop = FALSE] - 1 / K) / c_r[r]
        rows <- c(second[r], stepcols[r, ])
        J[rows, rlog[r]] <- -par[rows]
      }
    } else {
      lambda <- positive(z[tail(rlog, 1L)])
      par[location] <- z[location] / lambda
      par[rlog] <- drop(H %*% z[rlog])
      J[cbind(location, location)] <- 1 / lambda
      J[location, tail(rlog, 1L)] <- -par[location]
      J[rlog, rlog] <- H
    }
    if (any(!is.finite(c(par, J)))) stop(new_adaptive_quadrature_numeric_error(
      "Coordinate inverse or Jacobian is not finite in the positive interior."))
    list(parameters = par, jacobian = J)
  }
  target <- function(z, C) {
    check(C); d <- decode(z)
    list(value = sum(C * d$parameters), gradient = drop(C %*% d$jacobian))
  }
  list(chart = chart, to_chart = to_chart, decode = decode, target = target,
    dimension = p, scope = "positive_interior")
}

mfrm_gmfrm_coordinate_evaluator <- function(evaluator, coordinates) {
  evaluate <- function(z) {
    native <- NULL
    tryCatch({
      d <- coordinates$decode(z); native <- d$parameters
      a <- evaluator$evaluate(native); J <- d$jacobian
      error <- a$score_error
      if (is.null(error) || !identical(sort(names(error)), c("rule", "tail")) ||
          any(lengths(error) != length(native)) ||
          any(!is.finite(unlist(error))) || any(unlist(error) < 0))
        stop("Coordinate evaluation requires componentwise integration error diagnostics.")
      propagated <- lapply(error, function(x) drop(crossprod(abs(J), x)))
      gradient <- drop(crossprod(J, a$gradient))
      diagnostics <- a$integration
      diagnostics[c("ScoreRuleDifference", "TailScoreBound")] <-
        c(max(propagated$rule), max(propagated$tail))
      if (any(!is.finite(c(gradient, diagnostics))) ||
          max(propagated$rule) > 1e-6 || max(propagated$tail) > 1e-7) {
        e <- new_adaptive_quadrature_numeric_error(
          "Transformed score integration did not meet its accuracy criteria.")
        e$integration <- diagnostics; e$score_error <- propagated
        stop(e)
      }
      list(value = a$value, gradient = gradient, integration = diagnostics,
        score_error = propagated, native_parameters = native,
        native_integration = a$integration, chart = coordinates$chart)
    }, error = function(e) {
      e$native_parameters <- native
      e$parameters <- if (is.numeric(z)) z + 0 else z
      stop(e)
    })
  }
  list(evaluate = evaluate, value = function(z) evaluate(z)$value,
    gradient = function(z) evaluate(z)$gradient,
    diagnostics = evaluator$diagnostics,
    optimization_scale = evaluator$optimization_scale)
}
