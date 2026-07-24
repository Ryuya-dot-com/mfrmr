# ==============================================================================
# Optimizer dispatch and MML / EM scaffolding
# ==============================================================================
#
# Internal helpers for running the underlying optim() / nlminb() loops
# and the MML-EM hybrid scaffolding. Split out of `mfrm_core.R` for
# so the engine-dispatch layer lives in a single file. The
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

mfrm_grad_mml_complete_data_core <- function(params,
                                             base_eta,
                                             idx,
                                             config,
                                             sizes,
                                             quad,
                                             obs_posterior,
                                             step_cum = NULL,
                                             logprob_bundle = NULL) {
  if (identical(config$model, "GPCM")) {
    stop("Complete-data EM updates are currently implemented only for RSM/PCM.",
         call. = FALSE)
  }
  if (isTRUE(config$population_spec$active)) {
    stop("Complete-data EM updates are currently implemented only when `population = NULL`.",
         call. = FALSE)
  }
  if (facet_interactions_active(config)) {
    stop("Complete-data EM updates are currently implemented only for additive RSM/PCM fits without model-estimated facet interactions.",
         call. = FALSE)
  }

  n <- length(idx$score_k)
  if (n == 0L) return(rep(0, sum(unlist(sizes))))

  score_k <- idx$score_k
  weight <- idx$weight
  if (is.null(logprob_bundle)) {
    logprob_bundle <- mfrm_mml_logprob_bundle(
      idx = idx,
      config = config,
      quad = quad,
      params = params,
      base_eta = base_eta,
      step_cum = step_cum,
      include_probs = TRUE
    )
  }
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
  }

  grad_facet_free <- unlist(lapply(config$facet_names, function(f) {
    constraint_grad_project(grad_facets_exp[[f]], config$facet_specs[[f]])
  }))

  -c(grad_facet_free, grad_step_free)
}

normalize_mfrm_optimizer <- function(optimizer = "auto") {
  value <- as.character(optimizer %||% "auto")[1]
  aliases <- c(
    auto = "auto",
    bfgs = "BFGS",
    `l-bfgs-b` = "L-BFGS-B",
    lbfgsb = "L-BFGS-B",
    `l_bfgs_b` = "L-BFGS-B"
  )
  key <- tolower(value)
  resolved <- unname(aliases[key])
  if (length(resolved) == 0L || is.na(resolved)) {
    stop("`optimizer` must be one of 'auto', 'BFGS', or 'L-BFGS-B'.",
         call. = FALSE)
  }
  resolved
}

resolve_mfrm_optimizer <- function(optimizer, n_parameters,
                                   prefer_limited_memory = FALSE) {
  requested <- normalize_mfrm_optimizer(optimizer)
  # Fixed rather than option-driven so `optimizer = "auto"` is reproducible
  # across sessions and replayed analysis bundles.
  threshold <- 200L
  used <- if (identical(requested, "auto")) {
    if (isTRUE(prefer_limited_memory) ||
        as.integer(n_parameters) >= threshold) "L-BFGS-B" else "BFGS"
  } else {
    requested
  }
  list(
    Requested = requested,
    Used = used,
    ParameterCount = as.integer(n_parameters),
    AutoThreshold = threshold
  )
}

build_mfrm_optim_control <- function(method, maxit, reltol) {
  if (identical(method, "L-BFGS-B")) {
    return(list(
      maxit = as.integer(maxit),
      lmm = 20L,
      factr = max(1, as.numeric(reltol) / .Machine$double.eps),
      pgtol = max(as.numeric(reltol), sqrt(.Machine$double.eps))
    ))
  }
  list(maxit = as.integer(maxit), reltol = as.numeric(reltol))
}

# Lazily fused objective / gradient evaluator. optim() may request several
# objective values during a line search without requesting their gradients, so
# the reusable probability workspace is built for paired objective / gradient
# methods while the gradient itself is constructed only when gr() asks for it.
# At an identical parameter vector, marginal-likelihood and posterior work is
# reused; full probability matrices are retained only when the optimizer's
# call pattern makes that reuse worthwhile.
make_mfrm_direct_evaluator <- function(method, cache, idx, config, sizes, quad,
                                       reuse_probability_workspace = TRUE) {
  cached_par <- NULL
  cached_value <- NULL
  cached_gradient <- NULL
  probability_bundle <- NULL
  logprob_bundle <- NULL
  posterior_bundle <- NULL
  shared_evaluations <- 0L
  gradient_builds <- 0L
  value_hits <- 0L
  gradient_hits <- 0L

  ensure_shared <- function(par) {
    if (identical(par, cached_par)) return(invisible(NULL))
    cache$ensure(par)
    cached_par <<- par
    cached_gradient <<- NULL
    probability_bundle <<- NULL
    logprob_bundle <<- NULL
    posterior_bundle <<- NULL
    shared_evaluations <<- shared_evaluations + 1L

    if (identical(method, "JMLE")) {
      if (isTRUE(reuse_probability_workspace)) {
        probability_bundle <<- mfrm_jmle_probability_bundle(
          eta = cache$eta(),
          score_k = idx$score_k,
          model = config$model,
          step_cum = cache$step_cum(),
          criterion_idx = idx$step_idx,
          slopes = cache$params()$slopes,
          slope_idx = idx$slope_idx
        )
        log_prob_obs <- probability_bundle$log_prob_obs
        if (!is.null(idx$weight)) log_prob_obs <- log_prob_obs * idx$weight
        cached_value <<- -sum(log_prob_obs)
      } else {
        cached_value <<- mfrm_loglik_jmle_cached(cache, idx, config)
      }
    } else if (length(idx$score_k) == 0L) {
      cached_value <<- 0
    } else {
      logprob_bundle <<- mfrm_mml_logprob_bundle(
        idx = idx,
        config = config,
        quad = quad,
        params = cache$params(),
        base_eta = cache$base_eta(),
        step_cum = cache$step_cum(),
        include_probs = isTRUE(reuse_probability_workspace),
        include_linear_part = isTRUE(reuse_probability_workspace) &&
          identical(config$model, "GPCM")
      )
      posterior_bundle <<- mfrm_mml_posterior_bundle(logprob_bundle)
      cached_value <<- -sum(
        posterior_bundle$person_bundle$log_marginal
      )
    }
    invisible(NULL)
  }

  list(
    value = function(par) {
      same <- identical(par, cached_par)
      ensure_shared(par)
      if (same) value_hits <<- value_hits + 1L
      cached_value
    },
    gradient = function(par) {
      ensure_shared(par)
      if (!is.null(cached_gradient)) {
        gradient_hits <<- gradient_hits + 1L
        return(cached_gradient)
      }
      cached_gradient <<- if (identical(method, "JMLE")) {
        mfrm_grad_jmle_cached(
          cache, idx, config, sizes,
          probability_bundle = probability_bundle
        )
      } else {
        mfrm_grad_mml_cached(
          cache, idx, config, sizes, quad,
          logprob_bundle = if (isTRUE(reuse_probability_workspace)) {
            logprob_bundle
          } else {
            NULL
          },
          posterior_bundle = posterior_bundle
        )
      }
      gradient_builds <<- gradient_builds + 1L
      cached_gradient
    },
    diagnostics = function() list(
      SharedEvaluations = shared_evaluations,
      GradientBuilds = gradient_builds,
      ValueCacheHits = value_hits,
      GradientCacheHits = gradient_hits
    )
  )
}

make_mfrm_em_mstep_evaluator <- function(cache, idx, config, sizes, quad,
                                         obs_posterior,
                                         reuse_probability_workspace = TRUE) {
  cached_par <- NULL
  cached_value <- NULL
  cached_gradient <- NULL
  logprob_bundle <- NULL

  ensure_shared <- function(par) {
    if (identical(par, cached_par)) return(invisible(NULL))
    cache$ensure(par)
    cached_par <<- par
    cached_gradient <<- NULL
    logprob_bundle <<- mfrm_mml_logprob_bundle(
      idx = idx,
      config = config,
      quad = quad,
      params = cache$params(),
      base_eta = cache$base_eta(),
      step_cum = cache$step_cum(),
      include_probs = isTRUE(reuse_probability_workspace)
    )
    cached_value <<- -sum(logprob_bundle$log_prob_mat * obs_posterior)
    invisible(NULL)
  }

  list(
    value = function(par) {
      ensure_shared(par)
      cached_value
    },
    gradient = function(par) {
      ensure_shared(par)
      if (is.null(cached_gradient)) {
        cached_gradient <<- mfrm_grad_mml_complete_data_core(
          params = cache$params(),
          base_eta = cache$base_eta(),
          idx = idx,
          config = config,
          sizes = sizes,
          quad = quad,
          obs_posterior = obs_posterior,
          step_cum = cache$step_cum(),
          logprob_bundle = if (isTRUE(reuse_probability_workspace)) {
            logprob_bundle
          } else {
            NULL
          }
        )
      }
      cached_gradient
    }
  )
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
                                         optimizer = "auto",
                                         suppress_convergence_warning = FALSE) {
  optimizer_plan <- resolve_mfrm_optimizer(
    optimizer,
    length(start),
    prefer_limited_memory = identical(method, "MML")
  )
  control <- build_mfrm_optim_control(
    optimizer_plan$Used, maxit = maxit, reltol = reltol
  )

  if (method == "JMLE") {
    cache <- make_param_cache(sizes, config, idx, is_mml = FALSE)
  } else {
    quad <- quad %||% gauss_hermite_normal(quad_points)
    cache <- make_param_cache(sizes, config, idx, is_mml = TRUE)
  }

  evaluator <- make_mfrm_direct_evaluator(
    method = method,
    cache = cache,
    idx = idx,
    config = config,
    sizes = sizes,
    quad = quad,
    reuse_probability_workspace = identical(optimizer_plan$Used, "L-BFGS-B")
  )
  fn <- function(par, ...) evaluator$value(par)
  gr <- function(par, ...) evaluator$gradient(par)

  opt <- tryCatch(
    optim(par = start, fn = fn, gr = gr, method = optimizer_plan$Used,
          control = control),
    error = function(e) {
      stop("Model optimization failed: ", conditionMessage(e), ". ",
           "Possible causes: (1) insufficient data for the number of parameters, ",
           "(2) extreme score distributions, (3) near-constant responses. ",
           "Try reducing facets, increasing maxit, or checking data quality.",
           call. = FALSE)
    }
  )

  final_gradient <- tryCatch(
    gr(opt$par),
    error = function(e) rep(NA_real_, length(opt$par))
  )
  opt$optimizer_diagnostics <- build_optimizer_diagnostics(
    opt = opt,
    gradient = final_gradient,
    reltol = reltol,
    maxit = maxit,
    optimizer_method = optimizer_plan$Used,
    convergence_basis = "optimizer_gradient"
  )
  opt$optimizer_plan <- optimizer_plan
  opt$evaluation_cache <- evaluator$diagnostics()

  if (opt$convergence != 0 && !isTRUE(suppress_convergence_warning)) {
    warning("Optimizer did not fully converge (code = ", opt$convergence,
            ", status = ", opt$optimizer_diagnostics$ConvergenceStatus, "). ",
            opt$optimizer_diagnostics$ConvergenceDetail, " ",
            "Increase `maxit` (current: ", maxit, "); if the warning persists, ",
            "inspect the model specification, data support, and starting values. ",
            "Do not interpret estimates until the review is resolved.",
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
                                         optimizer = "auto",
                                         suppress_convergence_warning = FALSE,
                                         checkpoint = NULL) {
  quad <- gauss_hermite_normal(quad_points)
  par <- as.numeric(start)
  prev_loglik <- -Inf
  converged <- FALSE
  ll_trace <- numeric(0)
  rel_change <- NA_real_
  total_fn <- 0L
  total_gr <- 0L
  optimizer_plan <- resolve_mfrm_optimizer(
    optimizer,
    length(start),
    prefer_limited_memory = TRUE
  )

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

    evaluator <- make_mfrm_em_mstep_evaluator(
      cache = cache,
      idx = idx,
      config = config,
      sizes = sizes,
      quad = quad,
      obs_posterior = obs_posterior_fixed,
      reuse_probability_workspace = identical(optimizer_plan$Used, "L-BFGS-B")
    )
    fn <- function(par, ...) evaluator$value(par)
    gr <- function(par, ...) evaluator$gradient(par)

    m_opt <- tryCatch(
      optim(
        par = par,
        fn = fn,
        gr = gr,
        method = optimizer_plan$Used,
        control = build_mfrm_optim_control(
          optimizer_plan$Used,
          maxit = m_step_maxit,
          reltol = m_step_reltol
        )
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
    em_relative_change = rel_change,
    em_iterations = as.integer(length(ll_trace) - 1L)
  )
  opt$optimizer_plan <- optimizer_plan

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
    MStepReltol = m_step_reltol,
    MStepOptimizer = optimizer_plan$Used
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
                                  optimizer = "auto",
                                  suppress_convergence_warning = FALSE,
                                  checkpoint = NULL) {
  requested_engine <- normalize_mml_engine(config$estimation_control$mml_engine_requested %||% "direct")
  engine_plan <- resolve_mml_engine_plan(
    method = method,
    model = config$model,
    requested = requested_engine,
    population_active = isTRUE(config$population_spec$active),
    interaction_active = facet_interactions_active(config)
  )

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
      optimizer = optimizer,
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
      optimizer = optimizer,
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
      optimizer = optimizer,
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
      optimizer = optimizer,
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
