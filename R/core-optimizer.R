# ==============================================================================
# Optimizer dispatch and MML / EM scaffolding
# ==============================================================================
#
# Internal helpers for running the underlying optim() / nlminb() loops
# and the MML-EM hybrid scaffolding. Split out of `mfrm_core.R` for
# 0.1.6 so the engine-dispatch layer lives in a single file. The
# functions are internal (no @export); they are called from
# `mfrm_estimate()` once estimation configuration / parameter cache /
# initial values have been built upstream.

build_mfrm_mml_em_state <- function(par, idx, config, sizes, quad) {
  params <- expand_params(par, sizes, config)
  base_eta <- compute_base_eta(idx, params, config)
  logprob_bundle <- mfrm_mml_logprob_bundle(
    idx = idx,
    config = config,
    quad = quad,
    params = params,
    base_eta = base_eta
  )
  posterior_bundle <- mfrm_mml_posterior_bundle(logprob_bundle)

  list(
    params = params,
    base_eta = base_eta,
    logprob_bundle = logprob_bundle,
    posterior_bundle = posterior_bundle,
    marginal_loglik = sum(posterior_bundle$person_bundle$log_marginal)
  )
}

mfrm_em_population_sd_update <- function(state,
                                         bounds = c(0.05, 10)) {
  bounds <- normalize_population_sd_bounds(bounds)
  person_bundle <- state$posterior_bundle$person_bundle
  posterior <- person_bundle$posterior
  if (is.null(posterior) || nrow(posterior) == 0L) {
    return(bounds[1])
  }
  nodes <- state$logprob_bundle$quad_basis$nodes[person_bundle$person_ids, , drop = FALSE]
  sigma2 <- sum(posterior * (nodes^2), na.rm = TRUE) / nrow(posterior)
  sigma <- sqrt(max(sigma2, bounds[1]^2))
  min(max(sigma, bounds[1]), bounds[2])
}

mfrm_population_sd_profile <- function(par,
                                       idx,
                                       config,
                                       sizes,
                                       quad_points,
                                       sigma,
                                       bounds = c(0.05, 10),
                                       z = stats::qnorm(0.975)) {
  bounds <- normalize_population_sd_bounds(bounds)
  sigma <- as.numeric(sigma[1] %||% NA_real_)
  unavailable <- function(reason, detail) {
    list(
      se = NA_real_,
      ci = c(NA_real_, NA_real_),
      obs_info = NA_real_,
      second_derivative = NA_real_,
      step = NA_real_,
      status = "unavailable",
      reason = reason,
      detail = detail
    )
  }

  if (!is.finite(sigma) || sigma <= 0) {
    return(unavailable(
      "invalid_sigma",
      "SE unavailable because the estimated population SD is not positive and finite."
    ))
  }
  boundary_tol <- max(1e-8, 1e-6 * max(abs(sigma), 1))
  if (sigma <= bounds[1] + boundary_tol || sigma >= bounds[2] - boundary_tol) {
    return(unavailable(
      "boundary",
      "SE unavailable because the estimated population SD is on a configured boundary."
    ))
  }

  h <- max(1e-3, abs(sigma) * 1e-3)
  h <- min(h, (sigma - bounds[1]) / 2, (bounds[2] - sigma) / 2)
  if (!is.finite(h) || h <= 0) {
    return(unavailable(
      "boundary",
      "SE unavailable because a centered finite-difference step would cross the configured bounds."
    ))
  }

  ll_at <- function(s) {
    quad_s <- make_mml_quadrature(quad_points, sd = s)
    state_s <- build_mfrm_mml_em_state(par, idx, config, sizes, quad_s)
    state_s$marginal_loglik
  }

  ll0 <- tryCatch(ll_at(sigma), error = function(e) NA_real_)
  llp <- tryCatch(ll_at(sigma + h), error = function(e) NA_real_)
  llm <- tryCatch(ll_at(sigma - h), error = function(e) NA_real_)
  if (!all(is.finite(c(ll0, llp, llm)))) {
    return(unavailable(
      "profile_failed",
      "SE unavailable because profile log-likelihood evaluations failed."
    ))
  }

  d2 <- (llp - 2 * ll0 + llm) / (h^2)
  obs_info <- -d2
  if (!is.finite(obs_info) || obs_info <= 0) {
    return(list(
      se = NA_real_,
      ci = c(NA_real_, NA_real_),
      obs_info = obs_info,
      second_derivative = d2,
      step = h,
      status = "unavailable",
      reason = "flat_or_nonconcave",
      detail = "SE unavailable because the conditional profile curvature was flat or non-concave."
    ))
  }

  se <- sqrt(1 / obs_info)
  ci <- c(
    max(bounds[1], sigma - z * se),
    min(bounds[2], sigma + z * se)
  )
  list(
    se = se,
    ci = ci,
    obs_info = obs_info,
    second_derivative = d2,
    step = h,
    status = "ok",
    reason = "conditional_profile_curvature",
    detail = "Conditional/profile-like SE computed with other fitted parameters held fixed."
  )
}

mfrm_grad_mml_complete_data_core <- function(params,
                                             base_eta,
                                             idx,
                                             config,
                                             sizes,
                                             quad,
                                             obs_posterior,
                                             step_cum = NULL) {
  if (isTRUE(config$population_spec$active)) {
    stop("Complete-data EM updates are currently implemented only when `population = NULL`.",
         call. = FALSE)
  }
  if (facet_interactions_active(config)) {
    stop("Complete-data EM updates are currently implemented only for additive fits without model-estimated facet interactions.",
         call. = FALSE)
  }

  n <- length(idx$score_k)
  if (n == 0L) return(rep(0, sum(unlist(sizes))))

  score_k <- idx$score_k
  weight <- idx$weight
  logprob_bundle <- mfrm_mml_logprob_bundle(
    idx = idx,
    config = config,
    quad = quad,
    params = params,
    base_eta = base_eta,
    step_cum = step_cum,
    include_probs = TRUE,
    include_linear_part = identical(config$model, "GPCM")
  )
  n_nodes <- ncol(obs_posterior)
  grad_facets_exp <- lapply(config$facet_names, function(f) numeric(length(params$facets[[f]])))
  names(grad_facets_exp) <- config$facet_names

  if (identical(config$model, "RSM")) {
    k_cat <- ncol(logprob_bundle$prob_list[[1]])
    n_steps <- k_cat - 1L
    k_vals <- 0:(k_cat - 1L)
    I_geq <- outer(score_k, seq_len(n_steps), ">=") * 1.0
    grad_step_centered <- numeric(n_steps)

    for (q in seq_len(n_nodes)) {
      probs_q <- logprob_bundle$prob_list[[q]]
      expected_q <- as.vector(probs_q %*% k_vals)
      residual_q <- score_k - expected_q
      if (!is.null(weight)) residual_q <- residual_q * weight

      obs_post_q <- obs_posterior[, q]
      w_residual <- residual_q * obs_post_q

      for (facet in config$facet_names) {
        sign_f <- if (!is.null(config$facet_signs[[facet]])) config$facet_signs[[facet]] else -1
        rs <- rowsum(matrix(sign_f * w_residual, ncol = 1), idx$facets[[facet]], reorder = FALSE)
        f_ids <- as.integer(rownames(rs))
        grad_facets_exp[[facet]][f_ids] <- grad_facets_exp[[facet]][f_ids] + as.vector(rs)
      }

      step_resid <- (compute_P_geq(probs_q) - I_geq) * obs_post_q
      if (!is.null(weight)) step_resid <- step_resid * weight
      grad_step_centered <- grad_step_centered + colSums(step_resid)
    }

    grad_step_free <- project_sum_zero_gradient(grad_step_centered)
    grad_log_slope_free <- numeric(0)
  } else if (identical(config$model, "GPCM")) {
    k_cat <- ncol(logprob_bundle$prob_list[[1]])
    n_steps <- k_cat - 1L
    n_criteria <- nrow(params$steps_mat)
    k_vals <- 0:(k_cat - 1L)
    slope_idx_int <- idx$slope_idx
    slope_obs <- params$slopes[slope_idx_int]
    I_geq <- outer(score_k, seq_len(n_steps), ">=") * 1.0
    grad_step_mat <- matrix(0, n_criteria, n_steps)
    grad_log_slope_exp <- numeric(length(params$slopes))
    obs_idx <- cbind(seq_len(n), score_k + 1L)

    for (q in seq_len(n_nodes)) {
      probs_q <- logprob_bundle$prob_list[[q]]
      linear_part_q <- logprob_bundle$linear_part_list[[q]]
      expected_q <- as.vector(probs_q %*% k_vals)
      residual_q <- slope_obs * (score_k - expected_q)
      if (!is.null(weight)) residual_q <- residual_q * weight

      obs_post_q <- obs_posterior[, q]
      w_residual <- residual_q * obs_post_q

      for (facet in config$facet_names) {
        sign_f <- if (!is.null(config$facet_signs[[facet]])) config$facet_signs[[facet]] else -1
        rs <- rowsum(matrix(sign_f * w_residual, ncol = 1), idx$facets[[facet]], reorder = FALSE)
        f_ids <- as.integer(rownames(rs))
        grad_facets_exp[[facet]][f_ids] <- grad_facets_exp[[facet]][f_ids] + as.vector(rs)
      }

      step_resid <- (compute_P_geq(probs_q) - I_geq) * slope_obs * obs_post_q
      if (!is.null(weight)) step_resid <- step_resid * weight
      rs_step <- rowsum(step_resid, idx$step_idx, reorder = FALSE)
      rs_ids <- as.integer(rownames(rs_step))
      grad_step_mat[rs_ids, ] <- grad_step_mat[rs_ids, ] + rs_step

      obs_linear <- linear_part_q[obs_idx]
      expected_linear <- rowSums(probs_q * linear_part_q)
      slope_score <- slope_obs * (obs_linear - expected_linear) * obs_post_q
      if (!is.null(weight)) slope_score <- slope_score * weight
      rs_slope <- rowsum(matrix(slope_score, ncol = 1), slope_idx_int, reorder = FALSE)
      slope_ids <- as.integer(rownames(rs_slope))
      grad_log_slope_exp[slope_ids] <- grad_log_slope_exp[slope_ids] + as.vector(rs_slope)
    }

    grad_step_free <- project_step_matrix_gradient(grad_step_mat)
    grad_log_slope_free <- project_sum_zero_gradient(grad_log_slope_exp)
  } else {
    k_cat <- ncol(logprob_bundle$prob_list[[1]])
    n_steps <- k_cat - 1L
    n_criteria <- nrow(params$steps_mat)
    k_vals <- 0:(k_cat - 1L)
    I_geq <- outer(score_k, seq_len(n_steps), ">=") * 1.0
    grad_step_mat <- matrix(0, n_criteria, n_steps)

    for (q in seq_len(n_nodes)) {
      probs_q <- logprob_bundle$prob_list[[q]]
      expected_q <- as.vector(probs_q %*% k_vals)
      residual_q <- score_k - expected_q
      if (!is.null(weight)) residual_q <- residual_q * weight

      obs_post_q <- obs_posterior[, q]
      w_residual <- residual_q * obs_post_q

      for (facet in config$facet_names) {
        sign_f <- if (!is.null(config$facet_signs[[facet]])) config$facet_signs[[facet]] else -1
        rs <- rowsum(matrix(sign_f * w_residual, ncol = 1), idx$facets[[facet]], reorder = FALSE)
        f_ids <- as.integer(rownames(rs))
        grad_facets_exp[[facet]][f_ids] <- grad_facets_exp[[facet]][f_ids] + as.vector(rs)
      }

      step_resid <- (compute_P_geq(probs_q) - I_geq) * obs_post_q
      if (!is.null(weight)) step_resid <- step_resid * weight
      rs_step <- rowsum(step_resid, idx$step_idx, reorder = FALSE)
      rs_ids <- as.integer(rownames(rs_step))
      grad_step_mat[rs_ids, ] <- grad_step_mat[rs_ids, ] + rs_step
    }

    grad_step_free <- project_step_matrix_gradient(grad_step_mat)
    grad_log_slope_free <- numeric(0)
  }

  grad_facet_free <- unlist(lapply(config$facet_names, function(f) {
    constraint_grad_project(grad_facets_exp[[f]], config$facet_specs[[f]])
  }))

  -c(grad_facet_free, grad_step_free, grad_log_slope_free)
}

run_mfrm_direct_optimization <- function(start,
                                         method,
                                         idx,
                                         config,
                                         sizes,
                                         quad_points,
                                         maxit,
                                         reltol,
                                         quad = NULL,
                                         optimizer_method = "BFGS",
                                         suppress_convergence_warning = FALSE) {
  control <- list(maxit = maxit, reltol = reltol)

  if (method == "JMLE") {
    cache <- make_param_cache(sizes, config, idx, is_mml = FALSE)
  } else {
    quad <- quad %||% make_mml_quadrature(quad_points, config = config)
    cache <- make_param_cache(sizes, config, idx, is_mml = TRUE)
  }

  fn <- function(par, idx, config, sizes, quad = NULL) {
    cache$ensure(par)
    if (method == "JMLE") {
      mfrm_loglik_jmle_cached(cache, idx, config)
    } else {
      mfrm_loglik_mml_cached(cache, idx, config, quad)
    }
  }

  gr <- function(par, idx, config, sizes, quad = NULL) {
    cache$ensure(par)
    if (method == "JMLE") {
      mfrm_grad_jmle_cached(cache, idx, config, sizes)
    } else {
      mfrm_grad_mml_cached(cache, idx, config, sizes, quad)
    }
  }

  opt <- tryCatch(
    optim(par = start, fn = fn, gr = gr, method = "BFGS",
          control = control, idx = idx, config = config, sizes = sizes,
          quad = quad),
    error = function(e) {
      stop("Model optimization failed: ", conditionMessage(e), ". ",
           "Possible causes: (1) insufficient data for the number of parameters, ",
           "(2) extreme score distributions, (3) near-constant responses. ",
           "Try reducing facets, increasing maxit, or checking data quality.",
           call. = FALSE)
    }
  )

  final_gradient <- tryCatch(
    gr(opt$par, idx = idx, config = config, sizes = sizes, quad = quad),
    error = function(e) rep(NA_real_, length(opt$par))
  )
  opt$optimizer_diagnostics <- build_optimizer_diagnostics(
    opt = opt,
    gradient = final_gradient,
    reltol = reltol,
    maxit = maxit,
    optimizer_method = optimizer_method,
    convergence_basis = "optimizer_gradient"
  )

  warn_large_gradient <- isTRUE(getOption("mfrmr.warn_large_gradient", TRUE))
  large_gradient_plateau <- identical(
    opt$optimizer_diagnostics$ConvergenceStatus,
    "converged_plateau_large_gradient"
  )
  should_warn <- !isTRUE(suppress_convergence_warning) &&
    (opt$convergence != 0 || (isTRUE(warn_large_gradient) && isTRUE(large_gradient_plateau)))
  if (isTRUE(should_warn)) {
    warning("Optimizer result needs convergence review (code = ", opt$convergence,
            ", status = ", opt$optimizer_diagnostics$ConvergenceStatus, "). ",
            opt$optimizer_diagnostics$ConvergenceDetail, " ",
            "For higher-precision estimates, increase maxit (current: ", maxit,
            ") while keeping or tightening reltol (current: ", reltol,
            "); for exploratory approximate fits, a looser reltol may stop earlier.",
            call. = FALSE)
  }

  opt
}

run_mfrm_mml_em_optimization <- function(start,
                                         idx,
                                         config,
                                         sizes,
                                         quad_points,
                                         maxit,
                                         reltol,
                                         m_step_maxit = NULL,
                                         m_step_reltol = NULL,
                                         suppress_convergence_warning = FALSE,
                                         checkpoint = NULL) {
  estimate_population_sd <- isTRUE(config$estimate_population_sd)
  population_sd_bounds <- normalize_population_sd_bounds(config$population_sd_bounds %||% c(0.05, 10))
  population_sd <- as.numeric(config$population_prior_sd %||% 1)
  if (isTRUE(estimate_population_sd)) {
    population_sd <- min(max(population_sd, population_sd_bounds[1]), population_sd_bounds[2])
  }
  quad <- make_mml_quadrature(quad_points, config = config, sd = population_sd)
  par <- as.numeric(start)
  prev_loglik <- -Inf
  converged <- FALSE
  ll_trace <- numeric(0)
  sigma_trace <- if (isTRUE(estimate_population_sd)) population_sd else numeric(0)
  rel_change <- NA_real_
  total_fn <- 0L
  total_gr <- 0L

  # Resumable-fit checkpoint scaffolding. `checkpoint` is a list with
  # `file` (path) and `every_iter` (integer >= 1). When set, the
  # current EM state is `saveRDS()`-ed every `every_iter` outer EM
  # iterations so a long fit can resume after a crash via
  # `resume_mfrm_fit()`. We also try to load an existing checkpoint
  # before the first iteration; when found, `par` and `it` are
  # reseeded. The checkpoint format is intentionally tied to this
  # function's local state -- it should not be hand-edited.
  ckpt_file <- NULL
  ckpt_every <- 1L
  start_it <- 1L
  if (!is.null(checkpoint)) {
    if (!is.list(checkpoint) || is.null(checkpoint$file) ||
        !nzchar(as.character(checkpoint$file))) {
      stop("`checkpoint` must be a list with a non-empty `file` path.",
           call. = FALSE)
    }
    ckpt_file <- as.character(checkpoint$file)
    ckpt_every <- max(1L, as.integer(checkpoint$every_iter %||% 1L))
    if (file.exists(ckpt_file)) {
      saved <- tryCatch(readRDS(ckpt_file), error = function(e) NULL)
      if (is.list(saved) && identical(saved$.mfrm_checkpoint_kind %||% "",
                                       "mml_em")) {
        par <- as.numeric(saved$par)
        prev_loglik <- as.numeric(saved$prev_loglik %||% -Inf)
        ll_trace <- as.numeric(saved$ll_trace %||% numeric(0))
        sigma_trace <- as.numeric(saved$sigma_trace %||% sigma_trace)
        saved_sd <- as.numeric(saved$population_sd %||% NA_real_)
        if (!is.finite(saved_sd) && length(sigma_trace) > 0L) {
          saved_sd <- utils::tail(sigma_trace, 1L)
        }
        if (is.finite(saved_sd)) {
          population_sd <- saved_sd
        }
        quad <- make_mml_quadrature(quad_points, config = config, sd = population_sd)
        total_fn <- as.integer(saved$total_fn %||% 0L)
        total_gr <- as.integer(saved$total_gr %||% 0L)
        start_it <- as.integer(saved$next_iter %||% 1L)
        message("Resumed MML EM from checkpoint at iteration ",
                start_it, " (", ckpt_file, ").")
      } else {
        warning("Existing checkpoint file '", ckpt_file, "' did not look ",
                "like an mfrmr MML EM checkpoint; starting from scratch.",
                call. = FALSE)
      }
    }
  }
  m_step_maxit <- if (is.null(m_step_maxit)) {
    max(5L, min(50L, as.integer(maxit)))
  } else {
    as.integer(m_step_maxit)
  }
  m_step_reltol <- if (is.null(m_step_reltol)) {
    max(as.numeric(reltol), 1e-5)
  } else {
    as.numeric(m_step_reltol)
  }

  for (it in seq.int(start_it, maxit)) {
    state <- build_mfrm_mml_em_state(par, idx, config, sizes, quad)
    ll_trace <- c(ll_trace, state$marginal_loglik)

    if (it > 1L) {
      rel_change <- abs(state$marginal_loglik - prev_loglik) / (abs(prev_loglik) + 1e-10)
      if (is.finite(rel_change) && rel_change < reltol) {
        converged <- TRUE
        break
      }
    }
    prev_loglik <- state$marginal_loglik

    cache <- make_param_cache(sizes, config, idx, is_mml = TRUE)
    obs_posterior_fixed <- state$posterior_bundle$obs_posterior

    fn <- function(par, idx, config, sizes, quad, obs_posterior_fixed) {
      cache$ensure(par)
      logprob_bundle <- mfrm_mml_logprob_bundle(
        idx = idx,
        config = config,
        quad = quad,
        params = cache$params(),
        base_eta = cache$base_eta(),
        step_cum = cache$step_cum()
      )
      -sum(logprob_bundle$log_prob_mat * obs_posterior_fixed)
    }

    gr <- function(par, idx, config, sizes, quad, obs_posterior_fixed) {
      cache$ensure(par)
      mfrm_grad_mml_complete_data_core(
        params = cache$params(),
        base_eta = cache$base_eta(),
        idx = idx,
        config = config,
        sizes = sizes,
        quad = quad,
        obs_posterior = obs_posterior_fixed,
        step_cum = cache$step_cum()
      )
    }

    m_opt <- tryCatch(
      optim(
        par = par,
        fn = fn,
        gr = gr,
        method = "BFGS",
        control = list(maxit = m_step_maxit, reltol = m_step_reltol),
        idx = idx,
        config = config,
        sizes = sizes,
        quad = quad,
        obs_posterior_fixed = obs_posterior_fixed
      ),
      error = function(e) {
        stop("EM M-step optimization failed: ", conditionMessage(e), ". ",
             "Try increasing `maxit`, reducing model complexity, or using `mml_engine = 'direct'`.",
             call. = FALSE)
      }
    )

    par <- m_opt$par
    total_fn <- total_fn + as.integer(unname(m_opt$counts[["function"]] %||% 0L))
    total_gr <- total_gr + as.integer(unname(m_opt$counts[["gradient"]] %||% 0L))

    if (isTRUE(estimate_population_sd)) {
      population_sd <- mfrm_em_population_sd_update(
        state = state,
        bounds = population_sd_bounds
      )
      quad <- make_mml_quadrature(quad_points, config = config, sd = population_sd)
      sigma_trace <- c(sigma_trace, population_sd)
    }

    # Periodic checkpoint write. We snapshot the post-M-step state so
    # `resume_mfrm_fit()` continues at the next iteration with the
    # same `par` and accumulated trace. tryCatch shields the fit from
    # transient I/O failures (full disk, permission flap).
    if (!is.null(ckpt_file) && (it %% ckpt_every == 0L)) {
      tryCatch(
        saveRDS(
          list(
            .mfrm_checkpoint_kind = "mml_em",
            par = par,
            prev_loglik = prev_loglik,
            ll_trace = ll_trace,
            sigma_trace = sigma_trace,
            population_sd = population_sd,
            total_fn = total_fn,
            total_gr = total_gr,
            next_iter = it + 1L,
            quad_points = quad_points,
            maxit = maxit,
            reltol = reltol,
            timestamp = format(Sys.time(), tz = "UTC", usetz = TRUE)
          ),
          file = ckpt_file
        ),
        error = function(e) {
          warning("MML EM checkpoint write to '", ckpt_file,
                  "' failed: ", conditionMessage(e),
                  ". Continuing without checkpoint.",
                  call. = FALSE)
        }
      )
    }
  }

  final_state <- build_mfrm_mml_em_state(par, idx, config, sizes, quad)
  final_loglik <- final_state$marginal_loglik
  if (length(ll_trace) == 0L ||
      !isTRUE(isTRUE(all.equal(tail(ll_trace, 1L), final_loglik, tolerance = 1e-12)))) {
    ll_trace <- c(ll_trace, final_loglik)
  }

  final_gradient <- tryCatch(
    mfrm_grad_mml_core(
      params = final_state$params,
      base_eta = final_state$base_eta,
      idx = idx,
      config = config,
      sizes = sizes,
      quad = quad
    ),
    error = function(e) rep(NA_real_, length(par))
  )

  opt <- list(
    par = par,
    value = -final_loglik,
    counts = stats::setNames(c(total_fn, total_gr), c("function", "gradient")),
    convergence = if (isTRUE(converged)) 0L else 1L,
    message = if (isTRUE(converged)) {
      "EM converged by relative log-likelihood change."
    } else {
      "EM reached max iterations before the relative log-likelihood change met the tolerance."
    },
    ll_trace = ll_trace,
    sigma_trace = sigma_trace,
    em_relative_change = rel_change,
    em_iterations = as.integer(length(ll_trace) - 1L)
  )

  if (isTRUE(estimate_population_sd)) {
    profile <- mfrm_population_sd_profile(
      par = par,
      idx = idx,
      config = config,
      sizes = sizes,
      quad_points = quad_points,
      sigma = population_sd,
      bounds = population_sd_bounds
    )
    opt$estimated_population_sd <- population_sd
    opt$population_sd_profile <- profile
  }

  opt$optimizer_diagnostics <- build_optimizer_diagnostics(
    opt = opt,
    gradient = final_gradient,
    reltol = reltol,
    maxit = maxit,
    optimizer_method = "EM",
    convergence_basis = "relative_loglik"
  )
  opt$em_diagnostics <- list(
    EMIterations = as.integer(length(ll_trace) - 1L),
    EMConverged = isTRUE(converged),
    EMRelativeChange = rel_change,
    MStepMaxit = m_step_maxit,
    MStepReltol = m_step_reltol
  )

  if (opt$convergence != 0 && !isTRUE(suppress_convergence_warning)) {
    warning("EM did not fully converge (status = ",
            opt$optimizer_diagnostics$ConvergenceStatus, "). ",
            opt$optimizer_diagnostics$ConvergenceDetail, " ",
            "Consider increasing maxit (current: ", maxit, ") ",
            "or using `mml_engine = 'direct'`.",
            call. = FALSE)
  }

  opt
}

run_mfrm_optimization <- function(start,
                                  method,
                                  idx,
                                  config,
                                  sizes,
                                  quad_points,
                                  maxit,
                                  reltol,
                                  suppress_convergence_warning = FALSE,
                                  checkpoint = NULL) {
  requested_engine <- normalize_mml_engine(config$estimation_control$mml_engine_requested %||% "direct")
  estimate_population_sd <- isTRUE(config$estimate_population_sd)
  if (isTRUE(estimate_population_sd)) {
    if (!identical(method, "MML")) {
      stop("`estimate_population_sd = TRUE` is available only for `method = 'MML'`.",
           call. = FALSE)
    }
    if (isTRUE(config$population_spec$active)) {
      stop("`estimate_population_sd = TRUE` currently supports ordinary MML only; latent-regression MML already estimates `sigma2` in its separate branch.",
           call. = FALSE)
    }
    if (facet_interactions_active(config)) {
      stop("`estimate_population_sd = TRUE` currently supports additive MML only; facet-interaction free-SD estimation is not yet implemented.",
           call. = FALSE)
    }
  }
  requested_for_plan <- if (isTRUE(estimate_population_sd)) "em" else requested_engine
  engine_plan <- resolve_mml_engine_plan(
    method = method,
    model = config$model,
    requested = requested_for_plan,
    population_active = isTRUE(config$population_spec$active),
    interaction_active = facet_interactions_active(config)
  )
  if (isTRUE(estimate_population_sd)) {
    override_notice <- if (!identical(requested_engine, "em")) {
      paste0(
        "`estimate_population_sd = TRUE` requires the MML EM variance M-step; ",
        "overriding requested `mml_engine = '", requested_engine, "'` to `mml_engine = 'em'`."
      )
    } else {
      "`estimate_population_sd = TRUE` uses the MML EM variance M-step."
    }
    engine_plan$Requested <- requested_engine
    engine_plan$Used <- "em"
    engine_plan$Fallback <- !identical(requested_engine, "em")
    engine_plan$Detail <- paste(engine_plan$Detail, override_notice)
    config$population_sd_engine_notice <- override_notice
  }

  if (isTRUE(engine_plan$Fallback) &&
      identical(method, "MML") &&
      !isTRUE(suppress_convergence_warning)) {
    warning(engine_plan$Detail, call. = FALSE)
  }

  if (!identical(method, "MML") || identical(engine_plan$Used, "direct")) {
    opt <- run_mfrm_direct_optimization(
      start = start,
      method = method,
      idx = idx,
      config = config,
      sizes = sizes,
      quad_points = quad_points,
      maxit = maxit,
      reltol = reltol,
      suppress_convergence_warning = suppress_convergence_warning
    )
  } else if (identical(engine_plan$Used, "em")) {
    opt <- run_mfrm_mml_em_optimization(
      start = start,
      idx = idx,
      config = config,
      sizes = sizes,
      quad_points = quad_points,
      maxit = maxit,
      reltol = reltol,
      suppress_convergence_warning = suppress_convergence_warning,
      checkpoint = checkpoint
    )
  } else {
    em_maxit <- compute_hybrid_em_maxit(maxit)
    em_reltol <- compute_hybrid_em_reltol(reltol)
    em_opt <- run_mfrm_mml_em_optimization(
      start = start,
      idx = idx,
      config = config,
      sizes = sizes,
      quad_points = quad_points,
      maxit = em_maxit,
      reltol = em_reltol,
      m_step_maxit = compute_hybrid_em_mstep_maxit(em_maxit),
      m_step_reltol = em_reltol,
      suppress_convergence_warning = TRUE
    )
    opt <- run_mfrm_direct_optimization(
      start = em_opt$par,
      method = method,
      idx = idx,
      config = config,
      sizes = sizes,
      quad_points = quad_points,
      maxit = maxit,
      reltol = reltol,
      suppress_convergence_warning = suppress_convergence_warning
    )
    opt$em_diagnostics <- em_opt$em_diagnostics
    opt$em_warm_start_trace <- em_opt$ll_trace
  }

  if (identical(method, "MML")) {
    em_diag <- opt$em_diagnostics %||% list()
    opt$mml_engine <- list(
      Requested = engine_plan$Requested,
      Used = engine_plan$Used,
      Detail = engine_plan$Detail,
      Fallback = isTRUE(engine_plan$Fallback),
      EMIterations = as.integer(em_diag$EMIterations %||% NA_integer_),
      EMConverged = as.logical(em_diag$EMConverged %||% NA),
      EMRelativeChange = as.numeric(em_diag$EMRelativeChange %||% NA_real_)
    )
  }

  opt
}
