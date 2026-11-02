build_synthetic_joint_bundle <- function(fit, dir, chains = 4L, iterations = 60L,
                                         backend = "Stan", seed = 20261031L) {
  set.seed(seed)
  bundle <- mfrmr:::mfrm_model_export_data(fit, 1.1, 0.8, 0.5)
  saveRDS(bundle, file.path(dir, "model-data.rds"))
  spec <- mfrmr:::.mfrm_extract_bundle_spec(bundle)
  helpers <- mfrmr:::.mfrm_posterior_helpers()
  n_tot <- iterations * chains

  parts <- list()
  add_mat <- function(mat, nms) {
    if (ncol(mat) > 0L) {
      colnames(mat) <- nms
      parts[[length(parts) + 1L]] <<- mat
    }
  }

  if (identical(spec$schema_version, 2L)) {
    pop_mean <- matrix(rnorm(n_tot, 0.1, 0.25), ncol = 1L)
    pop_log_sd <- matrix(rnorm(n_tot, -0.05, 0.15), ncol = 1L)
    pop_sd <- exp(pop_log_sd)
    theta_raw <- matrix(rnorm(n_tot * spec$J), nrow = n_tot, ncol = spec$J)
    theta <- as.numeric(pop_mean) + as.numeric(pop_sd) * theta_raw
    add_mat(theta, paste0("theta[", seq_len(spec$J), "]"))
    add_mat(pop_mean, "population_mean")
    add_mat(pop_sd, "population_sd")
    add_mat(pop_log_sd, "population_log_sd")
    add_mat(theta_raw, paste0("theta_raw[", seq_len(spec$J), "]"))
  } else {
    theta <- matrix(rnorm(n_tot * spec$J), nrow = n_tot, ncol = spec$J)
    add_mat(theta, paste0("theta[", seq_len(spec$J), "]"))
    if (identical(backend, "brms")) {
      add_mat(theta, paste0("b_personp", seq_len(spec$J)))
    }
  }

  Z_loc <- if (spec$P > 0L) matrix(rnorm(n_tot * spec$P, 0, 0.6), n_tot, spec$P) else matrix(0, n_tot, 0L)
  locations <- sweep(Z_loc %*% t(spec$location_basis), 2L, spec$location_offset, "+")
  add_mat(locations, paste0("locations[", seq_len(spec$L), "]"))
  if (spec$P > 0L) {
    loc_free_nms <- if (identical(backend, "Stan")) {
      paste0("location_free[", seq_len(spec$P), "]")
    } else {
      paste0("b_z", seq_len(spec$P))
    }
    add_mat(Z_loc, loc_free_nms)
  }

  B_step <- mfrmr:::.mfrm_full_step_basis(spec)
  n_step_free <- ncol(B_step)
  Z_step <- if (n_step_free > 0L) matrix(rnorm(n_tot * n_step_free, 0, 0.5), n_tot, n_step_free) else matrix(0, n_tot, 0L)
  steps <- sweep(Z_step %*% t(B_step), 2L, spec$step_offset, "+")
  K <- spec$C - 1L
  step_nms <- unlist(lapply(seq_len(spec$G), function(g) {
    paste0("steps[", g, ",", seq_len(K), "]")
  }), use.names = FALSE)
  add_mat(steps, step_nms)
  if (n_step_free > 0L) {
    if (isTRUE(spec$affine)) {
      sf_nms <- if (identical(backend, "Stan")) {
        paste0("step_free[", seq_len(spec$T), "]")
      } else {
        paste0("b_step", seq_len(spec$T), "offset_constant")
      }
    } else if (identical(backend, "Stan")) {
      sf_nms <- unlist(lapply(seq_len(spec$G), function(g) {
        paste0("step_free[", g, ",", seq_len(spec$Q), "]")
      }), use.names = FALSE)
    } else if (spec$G == 1L) {
      sf_nms <- paste0("b_step", seq_len(spec$Q), "offset_Intercept")
    } else {
      sf_nms <- unlist(lapply(seq_len(spec$G), function(g) {
        paste0("b_step", seq_len(spec$Q), "offset_ownerg", g)
      }), use.names = FALSE)
    }
    add_mat(Z_step, sf_nms)
  }

  if (spec$A > 0L) {
    Z_slope <- if (spec$S > 0L) matrix(rnorm(n_tot * spec$S, 0, 0.25), n_tot, spec$S) else matrix(0, n_tot, 0L)
    log_slopes <- Z_slope %*% t(spec$slope_basis)
    slopes <- exp(log_slopes)
    add_mat(slopes, paste0("component_slopes[", seq_len(spec$A), "]"))
    add_mat(log_slopes, paste0("log_component_slopes[", seq_len(spec$A), "]"))
    if (spec$S > 0L) {
      sl_nms <- if (identical(backend, "Stan")) {
        paste0("log_slope_free[", seq_len(spec$S), "]")
      } else {
        paste0("b_slope", seq_len(spec$S), "offset_constant")
      }
      add_mat(Z_slope, sl_nms)
    }
  }

  full_mat <- do.call(cbind, parts)
  draws_arr <- array(full_mat, dim = c(iterations, chains, ncol(full_mat)),
                     dimnames = list(NULL, NULL, colnames(full_mat)))
  sampler <- data.frame(
    chain = seq_len(chains),
    num_divergent = rep(0, chains),
    num_max_treedepth = rep(0, chains),
    ebfmi = rep(0.85, chains)
  )
  old_wd <- setwd(dir)
  on.exit(setwd(old_wd), add = TRUE)
  helpers$summarize_mfrm_draws(draws_arr, bundle, sampler, backend)
  invisible(list(bundle = bundle, draws = draws_arr))
}

