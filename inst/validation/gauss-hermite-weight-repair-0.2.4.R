# Run from the development root after pkgload::load_all(). This is a numerical
# regression audit, not a parameter-recovery or interval-coverage experiment.

gh_legacy_rule <- function(n) {
  if (n == 1) return(list(nodes = 0, weights = 1, zero_eigenvector_entries = 0L))
  i <- seq_len(n - 1)
  j <- matrix(0, n, n)
  j[cbind(i, i + 1)] <- j[cbind(i + 1, i)] <- sqrt(i / 2)
  e <- eigen(j, symmetric = TRUE)
  list(nodes = sqrt(2) * e$values,
       weights = (sqrt(pi) * e$vectors[1, ]^2) / sqrt(pi),
       zero_eigenvector_entries = sum(e$vectors[1, ] == 0))
}

gh_pattern_oracle <- function(scores, difficulty, limit = 40) {
  counts <- tabulate(scores + 1L, nbins = 4L)
  n <- length(scores)
  score_sum <- sum(scores)
  # Independently expressed four-category RSM with zero steps and N(0,1).
  moments <- function(x) {
    eta <- outer(x - difficulty, 0:3)
    center <- apply(eta, 1L, max)
    exponent <- exp(eta - center)
    denominator <- rowSums(exponent)
    list(log = score_sum * (x - difficulty) -
           n * (center + log(denominator)) + dnorm(x, log = TRUE),
         expected = as.vector(exponent %*% (0:3)) / denominator)
  }
  mode <- optimize(function(x) moments(x)$log, c(-limit, limit),
                   maximum = TRUE, tol = 1e-10)$maximum
  log_peak <- moments(mode)$log
  integral <- function(multiplier) {
    integrand <- function(x) exp(moments(x)$log - log_peak) * multiplier(x)
    parts <- lapply(list(c(-limit, mode), c(mode, limit)), function(bound) {
      integrate(integrand, bound[1], bound[2], rel.tol = 1e-11,
                abs.tol = 1e-12, subdivisions = 1000L)
    })
    stopifnot(all(vapply(parts, function(x) x$message == "OK", TRUE)))
    c(value = sum(vapply(parts, `[[`, 0, "value")),
      error = sum(vapply(parts, `[[`, 0, "abs.error")))
  }
  mass <- integral(function(x) rep(1, length(x)))
  mean <- integral(identity)[1] / mass[1]
  variance <- integral(function(x) (x - mean)^2)[1] / mass[1]
  gradient <- integral(function(x) score_sum - n * moments(x)$expected)[1] / mass[1]
  log_mass <- log_peak + log(mass[1])
  # log f''(theta) = -1 - n Var(K | theta) < 0. Tangent exponentials
  # therefore bound both omitted tails, even when the crude normal-tail
  # bound is too loose relative to a long pattern's marginal probability.
  ends <- moments(c(-limit, limit))
  slopes <- score_sum - n * ends$expected - c(-limit, limit)
  stopifnot(slopes[1] > 0, slopes[2] < 0)
  tails <- ends$log - log(abs(slopes))
  log_tail_bound <- max(tails) + log(sum(exp(tails - max(tails))))
  c(nll = -unname(log_mass), mean = unname(mean), sd = sqrt(unname(variance)),
    gradient = unname(gradient), relative_error = unname(mass[2] / mass[1]),
    log_relative_tail_bound = log_tail_bound - unname(log_mass))
}

run_gh_weight_audit <- function(output_dir) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  write <- function(x, name) write.csv(x, file.path(output_dir, paste0(name, ".csv")),
                                      row.names = FALSE)
  orders <- c(31L, 61L, 121L, 181L, 301L)
  rules <- do.call(rbind, lapply(c(1:201, 241L, 301L, 351L, 381L), function(n) {
    q <- mfrmr:::gauss_hermite_normal(n)
    old <- gh_legacy_rule(n)
    data.frame(q = n, zero_eigenvector = old$zero_eigenvector_entries,
               zero_old = sum(old$weights == 0), zero_new = sum(q$weights == 0),
               minimum_weight = min(q$weights), sum_weights = sum(q$weights),
               node_change = max(abs(q$nodes - old$nodes)),
               weight_change = max(abs(q$weights - old$weights)))
  }))
  stopifnot(all(rules$zero_new == 0), all(abs(rules$sum_weights - 1) < 1e-13))
  write(rules, "rules")
  write(do.call(rbind, lapply(c(orders, 381L), function(n) {
    q <- mfrmr:::gauss_hermite_normal(n)
    data.frame(q = n, node = q$nodes, weight = q$weights)
  })), "nodes-weights")

  data <- mfrmr::load_mfrmr_data("example_operational")
  fits <- list()
  refits <- list()
  fixed <- list()
  for (model in c("RSM", "PCM")) {
    for (n in orders[1:4]) {
      fit <- mfrmr::fit_mfrm(data, "Person", c("Rater", "Criterion"), "Score",
                             model = model, method = "MML", quad_points = n,
                             step_facet = if (model == "PCM") "Criterion" else NULL)
      fits[[paste(model, n)]] <- fit
      config <- fit$config
      sizes <- mfrmr:::build_param_sizes(config)
      idx <- mfrmr:::build_indices(fit$prep, config$step_facet, config$slope_facet)
      values <- lapply(list(old = gh_legacy_rule(n), new = mfrmr:::gauss_hermite_normal(n)),
                       function(q) {
        p <- mfrmr:::expand_params(fit$opt$par, sizes, config)
        posterior <- mfrmr:::compute_person_posterior_summary(
          idx, config, p, q, fit$prep$levels$Person)$estimates
        list(nll = mfrmr:::mfrm_loglik_mml(fit$opt$par, idx, config, sizes, q),
             grad = mfrmr:::mfrm_grad_mml(fit$opt$par, idx, config, sizes, q),
             posterior = posterior)
      })
      fixed[[length(fixed) + 1L]] <- data.frame(
        model = model, q = n, nll_change = abs(values$old$nll - values$new$nll),
        gradient_change = max(abs(values$old$grad - values$new$grad)),
        eap_change = max(abs(values$old$posterior$Estimate - values$new$posterior$Estimate)),
        sd_change = max(abs(values$old$posterior$SD - values$new$posterior$SD)))
      # Reoptimize identical starting values with the old rule. Keep the result
      # separate from fixed-parameter comparisons and from the public fit.
      start <- mfrmr:::build_initial_param_vector(config, sizes)
      old_fit <- mfrmr:::run_mfrm_direct_optimization(
        start, "MML", idx, config, sizes, n, config$estimation_control$maxit,
        config$estimation_control$reltol, quad = gh_legacy_rule(n),
        suppress_convergence_warning = TRUE)
      new_fit <- mfrmr:::run_mfrm_direct_optimization(
        start, "MML", idx, config, sizes, n, config$estimation_control$maxit,
        config$estimation_control$reltol, quad = mfrmr:::gauss_hermite_normal(n),
        suppress_convergence_warning = TRUE)
      refits[[length(refits) + 1L]] <- data.frame(
        model = model, q = n, old_code = old_fit$convergence, new_code = new_fit$convergence,
        nll_change = abs(old_fit$value - new_fit$value),
        coordinate_change = max(abs(old_fit$par - new_fit$par)))
    }
  }
  write(do.call(rbind, fixed), "fixed-parameters")
  write(do.call(rbind, refits), "refits")
  saveRDS(fits, file.path(output_dir, "fits.rds"))

  # Actual response-pattern likelihoods: short/long, central/extreme and
  # deliberately difficult ratings. These are numerical probes, not a DGP.
  base <- fits[["RSM 31"]]
  config <- base$config
  config$n_person <- 1L
  sizes <- mfrmr:::build_param_sizes(config)
  cases <- expand.grid(n = c(4L, 100L, 1000L), difficulty = c(-16, 0, 8, 16),
                       pattern = c("balanced", "high", "low"), stringsAsFactors = FALSE)
  patterns <- list()
  for (case in seq_len(nrow(cases))) {
    spec <- cases[case, ]
    scores <- switch(spec$pattern, balanced = rep(0:3, length.out = spec$n),
                     high = rep(3L, spec$n), low = rep(0L, spec$n))
    idx <- list(person = rep(1L, spec$n),
                facets = setNames(rep(list(rep(1L, spec$n)), 2L), config$facet_names),
                step_idx = rep(1L, spec$n), slope_idx = rep(1L, spec$n),
                score_k = scores, weight = NULL)
    par <- rep(0, length(base$opt$par))
    par[1] <- spec$difficulty
    params <- mfrmr:::expand_params(par, sizes, config)
    oracle <- gh_pattern_oracle(scores, spec$difficulty)
    oracle_check <- gh_pattern_oracle(scores, spec$difficulty, limit = 45)
    stopifnot(max(abs(oracle[1:4] - oracle_check[1:4])) < 1e-8,
              oracle["relative_error"] < 1e-9,
              oracle["log_relative_tail_bound"] < log(1e-12))
    for (n in orders) for (version in c("old", "new")) {
      q <- if (version == "old") gh_legacy_rule(n) else mfrmr:::gauss_hermite_normal(n)
      posterior <- mfrmr:::compute_person_posterior_summary(idx, config, params, q, "P")$estimates
      gradient <- mfrmr:::mfrm_grad_mml(par, idx, config, sizes, q)[1]
      fn <- function(p) mfrmr:::mfrm_loglik_mml(p, idx, config, sizes, q)
      h <- 1e-4
      plus <- minus <- par
      plus[1] <- plus[1] + h
      minus[1] <- minus[1] - h
      numerical <- (fn(plus) - fn(minus)) / (2*h)
      patterns[[length(patterns) + 1L]] <- data.frame(
        case = case, spec, q = n, version = version,
        nll = fn(par), eap = posterior$Estimate, sd = posterior$SD,
        gradient = gradient, gradient_fd_error = abs(gradient - numerical),
        nll_oracle_error = abs(fn(par) - oracle["nll"]),
        eap_oracle_error = abs(posterior$Estimate - oracle["mean"]),
        sd_oracle_error = abs(posterior$SD - oracle["sd"]),
        gradient_oracle_error = abs(gradient - oracle["gradient"]),
        oracle_relative_error = oracle["relative_error"],
        oracle_log_relative_tail_bound = oracle["log_relative_tail_bound"])
    }
  }
  write(do.call(rbind, patterns), "patterns")

  calibration <- list()
  for (model in c("RSM", "PCM")) {
    sensitivity <- mfrmr::mml_quadrature_sensitivity(fits[[paste(model, 31)]], data,
                                                   quad_points = c(31L, 61L))
    fit <- sensitivity$fits$q61
    for (n in c(31L, 61L, 121L, 181L)) {
      draft <- mfrmr::extract_mfrm_calibration(fit, scoring_quad_points = n,
                                               quadrature_review = sensitivity)
      review <- mfrmr::review_mfrm_calibration(draft)
      stopifnot(nrow(review) == 0L)
      frozen <- mfrmr::freeze_mfrm_calibration(mfrmr::validate_mfrm_calibration(draft))
      path <- file.path(output_dir, paste0(model, "-scoring-", n, ".rds"))
      mfrmr::save_mfrm_calibration(frozen, path, overwrite = TRUE)
      restored <- mfrmr::load_mfrm_calibration(path)
      portable <- mfrmr::score_mfrm_calibration(restored, data)
      fitted <- mfrmr::predict_mfrm_units(fit, data, scoring_quad_points = n)
      calibration[[length(calibration) + 1L]] <- data.frame(
        model = model, fit_q = 61L, scoring_q = n, review_refusals = nrow(review),
        source_ready = mfrmr:::mfrm_inference_ready(fit),
        eap_difference = max(abs(portable$estimates$Estimate - fitted$estimates$Estimate)),
        sd_difference = max(abs(portable$estimates$SD - fitted$estimates$SD)))
    }
  }
  write(do.call(rbind, calibration), "calibration")
  capture.output(sessionInfo(), file = file.path(output_dir, "session.txt"))
  invisible(output_dir)
}

# Additional fixed-parameter checks of transformed priors; readiness is kept.
run_gh_population_audit <- function(output_dir) {
  data <- mfrmr::load_mfrmr_data("example_operational")
  people <- unique(data[c("Person", "Group")])
  fits <- list(
    RSM_population = mfrmr::fit_mfrm(data, "Person", c("Rater", "Criterion"), "Score",
                                     population_formula = ~Group, person_data = people),
    GPCM = mfrmr::fit_mfrm(data, "Person", c("Rater", "Criterion"), "Score",
                           model = "GPCM", step_facet = "Criterion", slope_facet = "Criterion")
  )
  rows <- list()
  for (model in names(fits)) {
    fit <- fits[[model]]
    config <- fit$config
    sizes <- mfrmr:::build_param_sizes(config)
    idx <- mfrmr:::build_indices(fit$prep, config$step_facet, config$slope_facet)
    params <- mfrmr:::expand_params(fit$opt$par, sizes, config)
    for (n in c(31L, 61L, 121L, 181L)) {
      values <- lapply(list(old = gh_legacy_rule(n), new = mfrmr:::gauss_hermite_normal(n)),
                       function(q) {
        post <- mfrmr:::compute_person_posterior_summary(
          idx, config, params, q, fit$prep$levels$Person,
          population_spec = mfrmr:::materialize_population_spec(config, params))$estimates
        list(nll = mfrmr:::mfrm_loglik_mml(fit$opt$par, idx, config, sizes, q),
             gradient = mfrmr:::mfrm_grad_mml(fit$opt$par, idx, config, sizes, q),
             eap = post$Estimate, sd = post$SD)
      })
      rows[[length(rows) + 1L]] <- data.frame(
        model = model, q = n, source_ready = mfrmr:::mfrm_inference_ready(fit),
        nll_change = abs(values$old$nll - values$new$nll),
        gradient_change = max(abs(values$old$gradient - values$new$gradient)),
        eap_change = max(abs(values$old$eap - values$new$eap)),
        sd_change = max(abs(values$old$sd - values$new$sd)))
    }
    scored <- mfrmr::predict_mfrm_units(fit, data, person_data = people,
                                        scoring_quad_points = 181L, readiness_policy = "review")
    stopifnot(all(is.finite(scored$estimates$Estimate)), all(is.finite(scored$estimates$SD)))
  }
  result <- do.call(rbind, rows)
  write.csv(result, file.path(output_dir, "other-models.csv"), row.names = FALSE)
  invisible(result)
}
