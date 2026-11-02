oracle_posterior_person_scores <- function(post,
                                           newdata,
                                           conditioning = c("posterior", "plugin_mean"),
                                           level = 0.95,
                                           cut_scores = NULL) {
  conditioning <- match.arg(conditioning)
  spec <- post$bundle_spec
  sc_spec <- post$scoring_spec
  sc <- sc_spec$source_columns
  person_col <- sc$person %||% "Person"
  facet_cols <- sc$facets %||% sc_spec$facet_names
  score_col <- sc$score %||% "Score"
  n_cat <- nrow(sc_spec$categories)
  k_max <- n_cat - 1L
  k_seq <- 0:k_max
  score_vals <- as.numeric(sc_spec$categories$Score)

  loc_names <- paste0("locations[", seq_len(spec$L), "]")
  step_names <- unlist(lapply(seq_len(spec$G), function(g) {
    paste0("steps[", g, ",", seq_len(k_max), "]")
  }), use.names = FALSE)

  if (identical(conditioning, "posterior")) {
    M <- mfrmr:::.mfrm_flatten_draws_array(post$draws$array)
    loc_mat <- M[, loc_names, drop = FALSE]
    step_mat <- M[, step_names, drop = FALSE]
    slope_mat <- if (identical(sc_spec$model, "GPCM") && spec$A > 0L) {
      M[, paste0("component_slopes[", seq_len(spec$A), "]"), drop = FALSE]
    } else {
      matrix(1, nrow = nrow(M), ncol = 1L)
    }
    mu_vec <- if (identical(spec$schema_version, 2L)) as.numeric(M[, "population_mean"]) else rep(0, nrow(M))
    sig_vec <- if (identical(spec$schema_version, 2L)) as.numeric(M[, "population_sd"]) else rep(1, nrow(M))
  } else {
    p <- post$parameters
    mean_row <- matrix(p$mean, nrow = 1L, dimnames = list(NULL, p$variable))
    loc_mat <- mean_row[, loc_names, drop = FALSE]
    step_mat <- mean_row[, step_names, drop = FALSE]
    slope_mat <- if (identical(sc_spec$model, "GPCM") && spec$A > 0L) {
      exp(mean_row[, paste0("log_component_slopes[", seq_len(spec$A), "]"), drop = FALSE])
    } else {
      matrix(1, nrow = 1L, ncol = 1L)
    }
    mu_vec <- if (identical(spec$schema_version, 2L)) as.numeric(mean_row[, "population_mean"]) else 0
    sig_vec <- if (identical(spec$schema_version, 2L)) as.numeric(mean_row[, "population_sd"]) else 1
  }
  n_draws <- length(mu_vec)

  cum_steps <- function(m, g) {
    if (k_max == 0L) return(0)
    idx <- (g - 1L) * k_max + seq_len(k_max)
    c(0, cumsum(as.numeric(step_mat[m, idx])))
  }

  # Pre-map static row indices once; evaluate exact row parameters once per (m, r)
  n_rows_nd <- nrow(newdata)
  row_loc_idx <- matrix(0L, nrow = n_rows_nd, ncol = length(sc_spec$facet_names))
  for (fi in seq_along(sc_spec$facet_names)) {
    fn <- sc_spec$facet_names[fi]
    lv <- as.character(newdata[[facet_cols[fi]]])
    row_loc_idx[, fi] <- sc_spec$facet_loc_indices[[fn]][match(lv, sc_spec$facet_levels[[fn]])]
  }
  facet_signs_num <- as.numeric(sc_spec$facet_signs)
  has_g_slope <- identical(sc_spec$model, "GPCM") && length(sc_spec$slope_facet) == 1L
  row_slope_idx <- if (has_g_slope) {
    slf <- sc_spec$slope_facet
    f_col <- facet_cols[match(slf, sc_spec$facet_names)]
    match(as.character(newdata[[f_col]]), as.character(sc_spec$slope_levels$Level))
  } else {
    rep(1L, n_rows_nd)
  }
  row_step_g <- if (identical(sc_spec$model, "RSM")) {
    rep(1L, n_rows_nd)
  } else {
    sf <- sc_spec$step_facet
    f_col <- facet_cols[match(sf, sc_spec$facet_names)]
    match(as.character(newdata[[f_col]]), sc_spec$step_owners)
  }

  build_draw_row_spec <- function(m, r) {
    delta <- sum(facet_signs_num * loc_mat[m, row_loc_idx[r, ]])
    alpha <- if (has_g_slope) slope_mat[m, row_slope_idx[r]] else 1
    cs <- cum_steps(m, row_step_g[r])
    list(delta = delta, alpha = alpha, cs = cs)
  }

  eval_row_cat_probs <- function(theta_vec, cell) {
    n_th <- length(theta_vec)
    u <- cell$alpha * (
      outer(theta_vec + cell$delta, k_seq) -
        matrix(cell$cs, nrow = n_th, ncol = n_cat, byrow = TRUE)
    )
    rmax <- u[, 1L]
    if (n_cat > 1L) {
      for (kc in 2:n_cat) {
        rmax <- pmax(rmax, u[, kc])
      }
    }
    eu <- exp(u - rmax)
    eu / rowSums(eu)
  }

  row_cat_probs <- function(theta_vec, m, r) {
    eval_row_cat_probs(theta_vec, build_draw_row_spec(m, r))
  }

  persons <- unique(trimws(as.character(newdata[[person_col]])))
  alpha_ci <- (1 - level) / 2
  probs_q <- c(0.5, alpha_ci, 1 - alpha_ci)
  cuts_num <- if (is.null(cut_scores)) numeric(0) else as.numeric(unname(cut_scores))
  k_cut <- length(cuts_num)
  n_dec <- if (k_cut > 0L) 2L * k_cut + 1L else 0L

  est_out <- vector("list", length(persons))
  dec_out <- vector("list", length(persons))
  pred_out <- vector("list", length(persons))
  draws_out <- vector("list", length(persons))

  for (pi in seq_along(persons)) {
    pid <- persons[pi]
    r_all <- which(trimws(as.character(newdata[[person_col]])) == pid)
    raw_sc <- newdata[[score_col]][r_all]
    obs_local <- which(!is.na(raw_sc))
    r_obs <- r_all[obs_local]
    y_obs <- if (length(r_obs)) {
      sc_spec$categories$Category[match(as.numeric(raw_sc[obs_local]), score_vals)] - 1L
    } else {
      integer(0)
    }

    draw_mu <- numeric(n_draws)
    draw_var <- numeric(n_draws)
    draw_log_z <- numeric(n_draws)
    draw_modes <- numeric(n_draws)
    draw_h <- numeric(n_draws)
    draw_i0 <- numeric(n_draws)
    log_post_fns <- vector("list", n_draws)
    dec_m <- matrix(0, nrow = n_draws, ncol = n_dec)
    pred_acc <- matrix(0, nrow = length(r_all), ncol = n_cat)
    pred_exp_m <- matrix(0, nrow = length(r_all), ncol = n_draws)

    for (m in seq_len(n_draws)) {
      mu_m <- mu_vec[m]
      sig_m <- sig_vec[m]
      if (!length(r_obs)) {
        draw_mu[m] <- mu_m
        draw_var[m] <- sig_m^2
        draw_log_z[m] <- 0
        draw_modes[m] <- mu_m
        if (k_cut > 0L) {
          above <- stats::pnorm(cuts_num, mean = mu_m, sd = sig_m, lower.tail = FALSE)
          edges <- c(-Inf, cuts_num, Inf)
          bands <- diff(stats::pnorm(edges, mean = mu_m, sd = sig_m))
          dec_m[m, ] <- c(above, bands)
        }
        for (rl in seq_along(r_all)) {
          r0 <- r_all[rl]
          p_bar <- vapply(seq_len(n_cat), function(kc) {
            f_cat <- function(th) {
              stats::dnorm(th, mean = mu_m, sd = sig_m) * row_cat_probs(th, m, r0)[, kc]
            }
            i_l <- stats::integrate(f_cat, mu_m - 12 * sig_m, mu_m, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value
            i_r <- stats::integrate(f_cat, mu_m, mu_m + 12 * sig_m, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value
            i_l + i_r
          }, numeric(1))
          pred_acc[rl, ] <- pred_acc[rl, ] + p_bar
          pred_exp_m[rl, m] <- sum(p_bar * score_vals)
        }
      } else {
        obs_cells <- lapply(r_obs, function(rr) build_draw_row_spec(m, rr))
        lp_fn <- local({
          mu_loc <- mu_m
          sig_loc <- sig_m
          cells_loc <- obs_cells
          y_loc <- y_obs
          function(th) {
            out <- stats::dnorm(th, mean = mu_loc, sd = sig_loc, log = TRUE)
            for (j in seq_along(cells_loc)) {
              pr_mat <- eval_row_cat_probs(th, cells_loc[[j]])
              out <- out + log(pr_mat[, y_loc[j] + 1L])
            }
            out
          }
        })
        log_post_fns[[m]] <- lp_fn
        opt <- stats::optimize(
          function(th) lp_fn(th),
          interval = c(mu_m - 25 * sig_m, mu_m + 25 * sig_m),
          maximum = TRUE,
          tol = 1e-13
        )
        th_star <- opt$maximum
        h_star <- opt$objective
        lo_b <- th_star - 12 * sig_m
        hi_b <- th_star + 12 * sig_m
        dens_s <- function(th) exp(lp_fn(th) - h_star)
        i0 <- stats::integrate(dens_s, lo_b, th_star, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value +
          stats::integrate(dens_s, th_star, hi_b, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value
        i1 <- stats::integrate(function(th) (th - th_star) * dens_s(th), lo_b, th_star, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value +
          stats::integrate(function(th) (th - th_star) * dens_s(th), th_star, hi_b, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value
        i2 <- stats::integrate(function(th) (th - th_star)^2 * dens_s(th), lo_b, th_star, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value +
          stats::integrate(function(th) (th - th_star)^2 * dens_s(th), th_star, hi_b, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value
        d_mean <- i1 / i0
        draw_mu[m] <- th_star + d_mean
        draw_var[m] <- i2 / i0 - d_mean^2
        draw_log_z[m] <- h_star + log(i0)
        draw_modes[m] <- th_star
        draw_h[m] <- h_star
        draw_i0[m] <- i0

        cdf_m <- function(x) {
          if (x <= lo_b) return(0)
          if (x >= hi_b) return(1)
          if (x <= th_star) {
            stats::integrate(dens_s, lo_b, x, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value / i0
          } else {
            1 - stats::integrate(dens_s, x, hi_b, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value / i0
          }
        }
        if (k_cut > 0L) {
          f_cuts <- vapply(cuts_num, cdf_m, numeric(1))
          above <- 1 - f_cuts
          f_edges <- c(0, f_cuts, 1)
          bands <- diff(f_edges)
          dec_m[m, ] <- c(above, bands)
        }
        for (rl in seq_along(r_all)) {
          cell_r0 <- build_draw_row_spec(m, r_all[rl])
          p_bar <- vapply(seq_len(n_cat), function(kc) {
            f_cat <- function(th) (dens_s(th) / i0) * eval_row_cat_probs(th, cell_r0)[, kc]
            stats::integrate(f_cat, lo_b, th_star, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value +
              stats::integrate(f_cat, th_star, hi_b, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value
          }, numeric(1))
          pred_acc[rl, ] <- pred_acc[rl, ] + p_bar
          pred_exp_m[rl, m] <- sum(p_bar * score_vals)
        }
      }
    }

    mix_cdf <- function(x) {
      if (!length(r_obs)) {
        return(mean(stats::pnorm(x, mean = mu_vec, sd = sig_vec)))
      }
      vals <- vapply(seq_len(n_draws), function(m) {
        th_star <- draw_modes[m]
        sig_m <- sig_vec[m]
        lo_b <- th_star - 12 * sig_m
        hi_b <- th_star + 12 * sig_m
        if (x <= lo_b) return(0)
        if (x >= hi_b) return(1)
        fn_s <- function(th) exp(log_post_fns[[m]](th) - draw_h[m])
        if (x <= th_star) {
          stats::integrate(fn_s, lo_b, x, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value / draw_i0[m]
        } else {
          1 - stats::integrate(fn_s, x, hi_b, rel.tol = 1e-12, abs.tol = 1e-14, subdivisions = 500L)$value / draw_i0[m]
        }
      }, numeric(1))
      mean(vals)
    }

    lo_root <- min(draw_modes - 12 * sig_vec)
    hi_root <- max(draw_modes + 12 * sig_vec)
    qs <- vapply(probs_q, function(pr) {
      stats::uniroot(function(x) mix_cdf(x) - pr, interval = c(lo_root, hi_root), tol = 1e-12)$root
    }, numeric(1))

    mean_p <- mean(draw_mu)
    wsd <- sqrt(mean(draw_var))
    bsd <- sqrt(mean((draw_mu - mean_p)^2))
    tsd <- sqrt(wsd^2 + bsd^2)
    mx <- max(draw_log_z)
    log_ml <- mx + log(mean(exp(draw_log_z - mx)))

    est_out[[pi]] <- data.frame(
      Person = pid,
      Estimate = mean_p,
      Median = qs[1L],
      WithinSD = wsd,
      BetweenSD = if (identical(conditioning, "posterior")) bsd else NA_real_,
      SD = if (identical(conditioning, "posterior")) tsd else wsd,
      Lower = qs[2L],
      Upper = qs[3L],
      PersonLogMarginalLikelihood = log_ml,
      stringsAsFactors = FALSE
    )
    if (k_cut > 0L) {
      dm <- colMeans(dec_m)
      dsd <- sqrt(colMeans(sweep(dec_m, 2L, dm, "-")^2))
      dec_out[[pi]] <- data.frame(
        Person = pid,
        Probability = dm,
        ProbabilityBetweenSD = if (identical(conditioning, "posterior")) dsd else rep(NA_real_, n_dec),
        stringsAsFactors = FALSE
      )
    }
    p_mat <- pred_acc / n_draws
    exp_sc <- as.numeric(p_mat %*% score_vals)
    exp_sc2 <- as.numeric(p_mat %*% (score_vals^2))
    pred_sd <- sqrt(pmax(0, exp_sc2 - exp_sc^2))
    exp_msd <- if (identical(conditioning, "posterior")) {
      sqrt(rowMeans((pred_exp_m - rowMeans(pred_exp_m))^2))
    } else {
      rep(NA_real_, length(r_all))
    }
    pred_out[[pi]] <- cbind(
      data.frame(
        Person = pid,
        ExpectedScore = exp_sc,
        PredictiveSD = pred_sd,
        ExpectedMeanSD = exp_msd,
        stringsAsFactors = FALSE
      ),
      as.data.frame(p_mat)
    )
    draws_out[[pi]] <- data.frame(
      Person = pid,
      Draw = seq_len(n_draws),
      ConditionalMean = draw_mu,
      ConditionalSD = sqrt(draw_var),
      LogMarginalLikelihood = draw_log_z,
      stringsAsFactors = FALSE
    )
  }

  list(
    estimates = do.call(rbind, est_out),
    decisions = if (k_cut > 0L) do.call(rbind, dec_out) else NULL,
    predictive = do.call(rbind, pred_out),
    person_draws = do.call(rbind, draws_out),
    prior_mean = mean(mu_vec),
    prior_sd = sqrt(mean(sig_vec^2) + mean((mu_vec - mean(mu_vec))^2))
  )
}

build_scoring_test_bundle <- function(fit, dir, chains = 2L, iterations = 15L,
                                      backend = "Stan", constant_draws = FALSE,
                                      pop_sd_range = NULL, slope_sd = 0.2,
                                      seed = 20261031L, transform_draws = NULL) {
  set.seed(seed)
  bundle <- mfrmr:::mfrm_model_export_data(fit, 1.0, 0.8, 0.4)
  saveRDS(bundle, file.path(dir, "model-data.rds"))
  spec <- mfrmr:::.mfrm_extract_bundle_spec(bundle)
  helpers <- mfrmr:::.mfrm_posterior_helpers()
  n_tot <- iterations * chains

  rep_rows <- function(mat) {
    if (!constant_draws || nrow(mat) == 0L || ncol(mat) == 0L) return(mat)
    matrix(rep(mat[1L, ], each = nrow(mat)), nrow = nrow(mat), ncol = ncol(mat))
  }

  parts <- list()
  add_mat <- function(mat, nms) {
    if (ncol(mat) > 0L) {
      colnames(mat) <- nms
      parts[[length(parts) + 1L]] <<- mat
    }
  }

  if (identical(spec$schema_version, 2L)) {
    pop_mean <- rep_rows(matrix(rnorm(n_tot, 0.15, 0.2), ncol = 1L))
    if (!is.null(pop_sd_range)) {
      pop_sd <- rep_rows(matrix(runif(n_tot, pop_sd_range[1L], pop_sd_range[2L]), ncol = 1L))
      pop_log_sd <- log(pop_sd)
    } else {
      pop_log_sd <- rep_rows(matrix(rnorm(n_tot, -0.05, 0.12), ncol = 1L))
      pop_sd <- exp(pop_log_sd)
    }
    theta_raw <- rep_rows(matrix(rnorm(n_tot * spec$J), nrow = n_tot, ncol = spec$J))
    theta <- as.numeric(pop_mean) + as.numeric(pop_sd) * theta_raw
    add_mat(theta, paste0("theta[", seq_len(spec$J), "]"))
    add_mat(pop_mean, "population_mean")
    add_mat(pop_sd, "population_sd")
    add_mat(pop_log_sd, "population_log_sd")
    add_mat(theta_raw, paste0("theta_raw[", seq_len(spec$J), "]"))
  } else {
    theta <- rep_rows(matrix(rnorm(n_tot * spec$J), nrow = n_tot, ncol = spec$J))
    add_mat(theta, paste0("theta[", seq_len(spec$J), "]"))
    if (identical(backend, "brms")) {
      add_mat(theta, paste0("b_personp", seq_len(spec$J)))
    }
  }

  Z_loc <- if (spec$P > 0L) rep_rows(matrix(rnorm(n_tot * spec$P, 0, 0.45), n_tot, spec$P)) else matrix(0, n_tot, 0L)
  locations <- sweep(Z_loc %*% t(spec$location_basis), 2L, spec$location_offset, "+")
  add_mat(locations, paste0("locations[", seq_len(spec$L), "]"))
  if (spec$P > 0L) {
    add_mat(Z_loc, if (identical(backend, "Stan")) paste0("location_free[", seq_len(spec$P), "]") else paste0("b_z", seq_len(spec$P)))
  }

  B_step <- mfrmr:::.mfrm_full_step_basis(spec)
  n_step_free <- ncol(B_step)
  Z_step <- if (n_step_free > 0L) rep_rows(matrix(rnorm(n_tot * n_step_free, 0, 0.35), n_tot, n_step_free)) else matrix(0, n_tot, 0L)
  steps <- sweep(Z_step %*% t(B_step), 2L, spec$step_offset, "+")
  K <- spec$C - 1L
  step_nms <- unlist(lapply(seq_len(spec$G), function(g) paste0("steps[", g, ",", seq_len(K), "]")), use.names = FALSE)
  add_mat(steps, step_nms)
  if (n_step_free > 0L) {
    sf_nms <- if (isTRUE(spec$affine)) {
      if (identical(backend, "Stan")) paste0("step_free[", seq_len(spec$T), "]") else paste0("b_step", seq_len(spec$T), "offset_constant")
    } else if (identical(backend, "Stan")) {
      unlist(lapply(seq_len(spec$G), function(g) paste0("step_free[", g, ",", seq_len(spec$Q), "]")), use.names = FALSE)
    } else if (spec$G == 1L) {
      paste0("b_step", seq_len(spec$Q), "offset_Intercept")
    } else {
      unlist(lapply(seq_len(spec$G), function(g) paste0("b_step", seq_len(spec$Q), "offset_ownerg", g)), use.names = FALSE)
    }
    add_mat(Z_step, sf_nms)
  }

  if (spec$A > 0L) {
    Z_slope <- if (spec$S > 0L) rep_rows(matrix(rnorm(n_tot * spec$S, 0, slope_sd), n_tot, spec$S)) else matrix(0, n_tot, 0L)
    log_slopes <- Z_slope %*% t(spec$slope_basis)
    add_mat(exp(log_slopes), paste0("component_slopes[", seq_len(spec$A), "]"))
    add_mat(log_slopes, paste0("log_component_slopes[", seq_len(spec$A), "]"))
    if (spec$S > 0L) {
      add_mat(Z_slope, if (identical(backend, "Stan")) paste0("log_slope_free[", seq_len(spec$S), "]") else paste0("b_slope", seq_len(spec$S), "offset_constant"))
    }
  }

  full_mat <- do.call(cbind, parts)
  if (!is.null(transform_draws)) full_mat <- transform_draws(full_mat, spec)
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
  invisible(utils::capture.output(
    helpers$summarize_mfrm_draws(draws_arr, bundle, sampler, backend)
  ))
  read_mfrm_posterior(dir)
}

test_that("predictive precision is checked independently for prior-only and sparse Persons", {
  d <- expand.grid(Person = paste0("Cal", 1:4), Item = c("high", "low"),
                   stringsAsFactors = FALSE)
  d$Score <- rep(c(0, 1), 4)
  source <- mfrmr:::mfrm_prepare_export_spec(d, list(
    person = "Person", facets = "Item", score = "Score", model = "GPCM",
    step_facet = "Item", slope_facet = "Item", rating_min = 0, rating_max = 1,
    category_policy = "preserve", gpcm_mml_identification = "fixed_standard_normal"
  ))
  dir <- tempfile("predictive-precision-")
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)
  post <- build_scoring_test_bundle(source, dir, iterations = 4L, constant_draws = TRUE,
    transform_draws = function(mat, spec) {
      mat[,] <- 0
      locations <- c(0.7, -0.7)
      logs <- log(c(100, 0.01))
      mat[, paste0("locations[", 1:2, "]")] <- rep(locations, each = nrow(mat))
      mat[, "location_free[1]"] <- drop(crossprod(spec$location_basis, locations))
      mat[, paste0("component_slopes[", 1:2, "]")] <- rep(exp(logs), each = nrow(mat))
      mat[, paste0("log_component_slopes[", 1:2, "]")] <- rep(logs, each = nrow(mat))
      mat[, "log_slope_free[1]"] <- drop(crossprod(spec$slope_basis, logs))
      mat
    })
  nd <- data.frame(Person = c("Prior", "Sparse", "Regular", "Sparse"),
                   Item = c("high", "low", "low", "high"),
                   Score = c(NA, 1, NA, NA))
  old <- options(mfrmr.use_cpp11_backend = TRUE)
  on.exit(options(old), add = TRUE)
  cpp <- predict(post, nd, type = "both", missing = "omit", cut_scores = c(Pass = 0))
  options(mfrmr.use_cpp11_backend = FALSE)
  ref <- predict(post, nd, type = "both", missing = "omit", cut_scores = c(Pass = 0))
  # Near-zero quadrature differences need an absolute error bound across backends.
  # Keep the predictive values, statuses and independent integration checks intact.
  predictive_columns <- setdiff(names(cpp$predictive), "IntegrationMaxDiff")
  expect_equal(cpp$predictive[predictive_columns], ref$predictive[predictive_columns],
               tolerance = 1e-12)
  expect_identical(names(cpp$predictive), names(ref$predictive))
  expect_lte(max(abs(cpp$predictive$IntegrationMaxDiff -
                     ref$predictive$IntegrationMaxDiff)), 1e-12)
  expect_equal(cpp$estimates, ref$estimates, tolerance = 1e-12)
  expect_identical(cpp$estimates$Status, c("prior_only", "available_posterior", "prior_only"))
  expect_lt(max(cpp$estimates$IntegrationMaxDiff), 1e-6)
  high <- cpp$predictive$Item == "high"
  expect_true(all(cpp$predictive$IntegrationMaxDiff[high] > 1e-6))
  expect_true(all(cpp$predictive$Status[high] == "unavailable"))
  expect_true(all(is.na(cpp$predictive$Prob_1[high])))
  expect_true(all(is.finite(cpp$predictive$Prob_1[!high])))
  expect_equal(summary(cpp)$overview$UnavailablePredictiveRows, 2L)
  expect_true(all(is.finite(cpp$decisions$Probability)))
  expect_s3_class(plot(cpp, type = "predictive", draw = FALSE), "ggplot")
  expect_equal(as.data.frame(cpp, what = "predictive"), cpp$predictive)
  report <- mfrm_report(cpp)
  expect_equal(report$tables$predictive, cpp$predictive)
  expect_equal(report$tables$overview$UnavailablePredictiveRows, 2L)
  expect_match(paste(report$notes, collapse = " "), "2 predictive rows are unavailable")
  saved <- tempfile(fileext = ".rds")
  on.exit(unlink(saved), add = TRUE)
  saveRDS(cpp, saved)
  expect_identical(summary(readRDS(saved))$predictive, cpp$predictive)
  options(mfrmr.use_cpp11_backend = TRUE)
  fine <- predict(post, nd, type = "both", missing = "omit", quad_points = 121L)
  expect_true(all(fine$predictive$Status == "available_posterior"))
  # Prior saved score objects did not have separate predictive precision fields.
  legacy <- fine
  legacy$predictive[c("Status", "Reason", "IntegrationMaxDiff")] <- NULL
  expect_equal(summary(legacy)$predictive, legacy$predictive)
  # Independent adaptive integration: ability remains broad after the low-slope response.
  for (pid in c("Prior", "Sparse")) {
    density <- function(th) dnorm(th) * if (pid == "Sparse") plogis(0.01 * (th + 0.7)) else 1
    denom <- integrate(density, -12, 12, rel.tol = 1e-12)$value
    numer <- integrate(function(th) density(th) * plogis(100 * (th - 0.7)),
                       -12, 12, rel.tol = 1e-12, subdivisions = 1000L)$value
    row <- fine$predictive$Person == pid & fine$predictive$Item == "high"
    expect_equal(fine$predictive$Prob_1[row], numer / denom, tolerance = 1e-8)
  }
})

test_that("predict.mfrm_posterior_summary matches pure-R to < 1e-12, preserves total-variance invariants, and agrees with stats::integrate on joint draws", {
  post <- read_mfrm_posterior(
    system.file("extdata", "posterior-draws-example", package = "mfrmr"),
    draws = "require"
  )
  new_df <- data.frame(
    Person = c(
      rep("P_min", 3L),
      rep("P_max", 3L),
      rep("P_mix", 4L),
      rep("P_sparse", 3L),
      rep("P_prior", 2L)
    ),
    Rater = c(
      "R01", "R02", "R03",
      "R01", "R02", "R03",
      "R01", "R02", "R03", "R01",
      "R02", "R01", "R03",
      "R01", "R02"
    ),
    Criterion = c(
      "Accuracy", "Content", "Language",
      "Accuracy", "Content", "Language",
      "Accuracy", "Content", "Language", "Content",
      "Accuracy", "Content", "Language",
      "Accuracy", "Language"
    ),
    Score = c(
      1, 1, 1,
      3, 3, 3,
      1, 2, 3, 2,
      2, NA, NA,
      NA, NA
    ),
    stringsAsFactors = FALSE
  )
  cuts <- c(Pass = -0.25, Merit = 0.75)

  old_opt <- options(mfrmr.use_cpp11_backend = TRUE)
  on.exit(options(old_opt), add = TRUE)

  scored_cpp <- predict(
    post,
    newdata = new_df,
    type = "both",
    conditioning = "posterior",
    level = 0.90,
    cut_scores = cuts,
    missing = "omit",
    keep_person_draws = TRUE
  )

  options(mfrmr.use_cpp11_backend = FALSE)
  scored_r <- predict(
    post,
    newdata = new_df,
    type = "both",
    conditioning = "posterior",
    level = 0.90,
    cut_scores = cuts,
    missing = "omit",
    keep_person_draws = TRUE
  )
  options(mfrmr.use_cpp11_backend = TRUE)

  # 1. Exact C++ vs pure-R parity (< 1e-12) across all numeric components on all 120 bundled draws
  num_est <- c("Estimate", "Median", "SD", "WithinSD", "BetweenSD",
               "CalibrationVarShare", "Lower", "Upper", "PriorMean", "PriorSD",
               "PersonLogMarginalLikelihood")
  for (col in num_est) {
    v_c <- scored_cpp$estimates[[col]]
    v_r <- scored_r$estimates[[col]]
    expect_equal(v_c, v_r, tolerance = 1e-12, info = paste("C++ vs R estimates:", col))
  }
  expect_equal(scored_cpp$decisions$Probability, scored_r$decisions$Probability, tolerance = 1e-12)
  expect_equal(scored_cpp$decisions$ProbabilityBetweenSD, scored_r$decisions$ProbabilityBetweenSD, tolerance = 1e-12)
  expect_equal(scored_cpp$predictive$ExpectedScore, scored_r$predictive$ExpectedScore, tolerance = 1e-12)
  expect_equal(scored_cpp$predictive$PredictiveSD, scored_r$predictive$PredictiveSD, tolerance = 1e-12)
  expect_equal(scored_cpp$predictive$ExpectedMeanSD, scored_r$predictive$ExpectedMeanSD, tolerance = 1e-12)
  expect_equal(scored_cpp$person_draws$ConditionalMean, scored_r$person_draws$ConditionalMean, tolerance = 1e-12)
  expect_equal(scored_cpp$person_draws$ConditionalSD, scored_r$person_draws$ConditionalSD, tolerance = 1e-12)
  expect_equal(scored_cpp$person_draws$LogMarginalLikelihood, scored_r$person_draws$LogMarginalLikelihood, tolerance = 1e-12)

  est <- scored_cpp$estimates
  expect_identical(est$Status, c(rep("available_posterior", 4L), "prior_only"))
  expect_lt(max(est$IntegrationMaxDiff), 1e-10)

  # Strict law of total variance across varying calibration draws
  obs_est <- est[est$Status == "available_posterior", ]
  expect_true(all(obs_est$BetweenSD > 0))
  expect_true(all(obs_est$SD > obs_est$WithinSD))
  expect_lt(max(abs(obs_est$SD^2 - (obs_est$WithinSD^2 + obs_est$BetweenSD^2))), 1e-14)
  # Monotone ordering of all-min < mixed < all-max on identical facet cells
  expect_lt(est$Estimate[est$Person == "P_min"], est$Estimate[est$Person == "P_max"])

  # 2. Fast joint-draw stats::integrate + stats::uniroot oracle (< 1e-10) retained on CRAN
  gpcm_shared <- readRDS(test_path("fixtures", "anchored-gpcm.rds"))$shared$fit
  cran_dir <- tempfile("b3-cran-oracle-")
  dir.create(cran_dir)
  on.exit(unlink(cran_dir, recursive = TRUE), add = TRUE)
  post_g <- build_scoring_test_bundle(gpcm_shared, cran_dir, chains = 2L, iterations = 6L, backend = "Stan")
  sc_g <- post_g$scoring_spec$source_columns
  f1_g <- post_g$scoring_spec$facet_levels[[post_g$scoring_spec$facet_names[1L]]]
  f2_g <- post_g$scoring_spec$facet_levels[[post_g$scoring_spec$facet_names[2L]]]
  cats_g <- post_g$scoring_spec$categories$Score
  nd_g <- data.frame(Person = c("CandMin", "CandMin", "CandMix", "CandMix", "CandPrior"), stringsAsFactors = FALSE)
  names(nd_g)[1L] <- sc_g$person
  nd_g[[sc_g$facets[1L]]] <- rep(f1_g[seq_len(min(2L, length(f1_g)))], length.out = 5L)
  nd_g[[sc_g$facets[2L]]] <- rep(f2_g[seq_len(min(2L, length(f2_g)))], length.out = 5L)
  nd_g[[sc_g$score]] <- c(cats_g[1L], cats_g[1L], cats_g[1L], cats_g[length(cats_g)], NA)
  res_g <- predict(post_g, newdata = nd_g, type = "both", conditioning = "posterior",
                   level = 0.90, cut_scores = cuts, missing = "omit", keep_person_draws = TRUE)
  ref_g <- oracle_posterior_person_scores(post_g, newdata = nd_g, conditioning = "posterior",
                                          level = 0.90, cut_scores = cuts)
  for (col in c("Estimate", "Median", "WithinSD", "BetweenSD", "SD",
                "Lower", "Upper", "PersonLogMarginalLikelihood")) {
    expect_lt(max(abs(res_g$estimates[[col]] - ref_g$estimates[[col]])), 1e-10, label = col)
  }
  expect_lt(max(abs(res_g$decisions$Probability - ref_g$decisions$Probability)), 1e-10)
  expect_lt(max(abs(res_g$predictive$ExpectedScore - ref_g$predictive$ExpectedScore)), 1e-10)
})

test_that("bundled 120-draw posterior-draws-example matches stats::integrate + uniroot across all 5 profiles", {
  skip_on_cran()
  post <- read_mfrm_posterior(
    system.file("extdata", "posterior-draws-example", package = "mfrmr"),
    draws = "require"
  )
  new_df <- data.frame(
    Person = c(
      rep("P_min", 3L),
      rep("P_max", 3L),
      rep("P_mix", 4L),
      rep("P_sparse", 3L),
      rep("P_prior", 2L)
    ),
    Rater = c(
      "R01", "R02", "R03",
      "R01", "R02", "R03",
      "R01", "R02", "R03", "R01",
      "R02", "R01", "R03",
      "R01", "R02"
    ),
    Criterion = c(
      "Accuracy", "Content", "Language",
      "Accuracy", "Content", "Language",
      "Accuracy", "Content", "Language", "Content",
      "Accuracy", "Content", "Language",
      "Accuracy", "Language"
    ),
    Score = c(
      1, 1, 1,
      3, 3, 3,
      1, 2, 3, 2,
      2, NA, NA,
      NA, NA
    ),
    stringsAsFactors = FALSE
  )
  cuts <- c(Pass = -0.25, Merit = 0.75)
  scored_cpp <- predict(
    post,
    newdata = new_df,
    type = "both",
    conditioning = "posterior",
    level = 0.90,
    cut_scores = cuts,
    missing = "omit",
    keep_person_draws = TRUE
  )
  ref <- oracle_posterior_person_scores(
    post,
    newdata = new_df,
    conditioning = "posterior",
    level = 0.90,
    cut_scores = cuts
  )
  est <- scored_cpp$estimates
  expect_lt(max(abs(est$PriorMean - ref$prior_mean)), 1e-12)
  expect_lt(max(abs(est$PriorSD - ref$prior_sd)), 1e-12)
  for (col in c("Estimate", "Median", "WithinSD", "BetweenSD", "SD",
                "Lower", "Upper", "PersonLogMarginalLikelihood")) {
    expect_lt(max(abs(est[[col]] - ref$estimates[[col]])), 1e-10, label = col)
  }
  expect_lt(max(abs(scored_cpp$decisions$Probability - ref$decisions$Probability)), 1e-10)
  expect_lt(max(abs(scored_cpp$decisions$ProbabilityBetweenSD - ref$decisions$ProbabilityBetweenSD)), 1e-10)
  expect_lt(max(abs(scored_cpp$predictive$ExpectedScore - ref$predictive$ExpectedScore)), 1e-10)
  expect_lt(max(abs(scored_cpp$predictive$PredictiveSD - ref$predictive$PredictiveSD)), 1e-10)
  expect_lt(max(abs(scored_cpp$predictive$ExpectedMeanSD - ref$predictive$ExpectedMeanSD)), 1e-10)
  prob_cols <- grep("^Prob_", names(scored_cpp$predictive), value = TRUE)
  ref_prob_mat <- as.matrix(ref$predictive[, paste0("V", seq_along(prob_cols)), drop = FALSE])
  expect_lt(max(abs(as.matrix(scored_cpp$predictive[, prob_cols]) - ref_prob_mat)), 1e-10)
  expect_lt(max(abs(scored_cpp$person_draws$ConditionalMean - ref$person_draws$ConditionalMean)), 1e-10)
  expect_lt(max(abs(scored_cpp$person_draws$ConditionalSD - ref$person_draws$ConditionalSD)), 1e-10)
  expect_lt(max(abs(scored_cpp$person_draws$LogMarginalLikelihood - ref$person_draws$LogMarginalLikelihood)), 1e-10)
})

test_that("stats::integrate oracle holds across ordinary RSM, ordinary PCM, and fixed-population 1-family GPCM", {
  skip_on_cran()
  fixtures <- readRDS(test_path("fixtures", "anchored-facet-information.rds"))
  gpcm_fix <- readRDS(test_path("fixtures", "anchored-gpcm.rds"))$fixed_population$fit

  cases <- list(
    list(name = "rsm_stan", fit = fixtures$RSM$fit, backend = "Stan"),
    list(name = "pcm_brms", fit = fixtures$PCM$fit, backend = "brms"),
    list(name = "gpcm_fixed_brms", fit = gpcm_fix, backend = "brms")
  )

  for (cs in cases) {
    fit <- cs$fit
    dir <- tempfile(paste0("b3-", cs$name, "-"))
    dir.create(dir)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)
    post <- build_scoring_test_bundle(fit, dir, chains = 2L, iterations = 12L, backend = cs$backend)

    sc <- post$scoring_spec$source_columns
    f_cols <- sc$facets
    cats <- post$scoring_spec$categories$Score
    nd <- data.frame(Person = c("Cand1", "Cand1", "Cand2", "Cand2"), stringsAsFactors = FALSE)
    names(nd)[1L] <- sc$person
    for (fi in seq_along(f_cols)) {
      lv <- post$scoring_spec$facet_levels[[post$scoring_spec$facet_names[fi]]]
      nd[[f_cols[fi]]] <- rep(lv[seq_len(min(2L, length(lv)))], length.out = 4L)
    }
    nd[[sc$score]] <- c(cats[1L], cats[min(2L, length(cats))], cats[length(cats)], cats[max(1L, length(cats) - 1L)])

    res <- predict(post, newdata = nd, type = "both", cut_scores = c(Zero = 0))
    ref <- oracle_posterior_person_scores(post, newdata = nd, conditioning = "posterior", cut_scores = c(Zero = 0))
    expect_lt(max(abs(res$estimates$Estimate - ref$estimates$Estimate)), 1e-10, label = cs$name)
    expect_lt(max(abs(res$estimates$SD - ref$estimates$SD)), 1e-10, label = cs$name)
    expect_lt(max(abs(res$estimates$Lower - ref$estimates$Lower)), 1e-10, label = cs$name)
    expect_lt(max(abs(res$estimates$Upper - ref$estimates$Upper)), 1e-10, label = cs$name)
    expect_lt(max(abs(res$decisions$Probability - ref$decisions$Probability)), 1e-10, label = cs$name)
    expect_lt(max(abs(res$predictive$ExpectedScore - ref$predictive$ExpectedScore)), 1e-10, label = cs$name)
  }
})

test_that("conditioning paradigms preserve summary-only plugin_mean, constant-draw limiting equivalence, and batch invariance", {
  # 1. Summary-only legacy bundle (`posterior-example`) works with plugin_mean and fails closed on posterior
  sum_post <- read_mfrm_posterior(system.file("extdata", "posterior-example", package = "mfrmr"))
  expect_null(sum_post$draws)
  nd_sum <- data.frame(
    Person = c("NewCand1", "NewCand1", "NewCand2", "NewCand2"),
    Task = c("t1", "t2", "t1", "t2"),
    Rater = c("r1", "r2", "r2", "r1"),
    Score = c(1, 2, 3, 3),
    stringsAsFactors = FALSE
  )
  expect_error(predict(sum_post, newdata = nd_sum, conditioning = "posterior"), "posterior-draws.rds")
  plug_sum <- predict(sum_post, newdata = nd_sum, type = "both", conditioning = "plugin_mean", cut_scores = c(Pass = 0))
  ref_sum <- oracle_posterior_person_scores(sum_post, newdata = nd_sum, conditioning = "plugin_mean", cut_scores = c(Pass = 0))
  expect_identical(unique(plug_sum$estimates$Status), "available_conditional")
  expect_true(all(is.na(plug_sum$estimates$BetweenSD)))
  expect_true(all(is.na(plug_sum$estimates$CalibrationVarShare)))
  expect_true(all(is.na(plug_sum$decisions$ProbabilityBetweenSD)))
  expect_true(all(is.na(plug_sum$predictive$ExpectedMeanSD)))
  expect_lt(max(abs(plug_sum$estimates$Estimate - ref_sum$estimates$Estimate)), 1e-10)
  expect_lt(max(abs(plug_sum$estimates$SD - ref_sum$estimates$SD)), 1e-10)
  expect_lt(max(abs(plug_sum$estimates$Lower - ref_sum$estimates$Lower)), 1e-10)
  expect_lt(max(abs(plug_sum$estimates$Upper - ref_sum$estimates$Upper)), 1e-10)

  # 2. Constant calibration draws: `posterior` reduces identically to `plugin_mean` (< 1e-12) with BetweenSD == 0
  gpcm_shared <- readRDS(test_path("fixtures", "anchored-gpcm.rds"))$shared$fit
  c_dir <- tempfile("b3-const-")
  dir.create(c_dir)
  on.exit(unlink(c_dir, recursive = TRUE), add = TRUE)
  post_const <- build_scoring_test_bundle(gpcm_shared, c_dir, chains = 2L, iterations = 10L,
                                          backend = "Stan", constant_draws = TRUE)
  sc <- post_const$scoring_spec$source_columns
  f1 <- post_const$scoring_spec$facet_levels[[post_const$scoring_spec$facet_names[1L]]]
  f2 <- post_const$scoring_spec$facet_levels[[post_const$scoring_spec$facet_names[2L]]]
  cats <- post_const$scoring_spec$categories$Score
  nd_c <- data.frame(Person = c("NP1", "NP1", "NP1"), stringsAsFactors = FALSE)
  names(nd_c)[1L] <- sc$person
  nd_c[[sc$facets[1L]]] <- f1[seq_len(min(3L, length(f1)))]
  nd_c[[sc$facets[2L]]] <- f2[seq_len(min(3L, length(f2)))]
  nd_c[[sc$score]] <- c(cats[1L], cats[2L], cats[length(cats)])

  s_post <- predict(post_const, newdata = nd_c, type = "both", conditioning = "posterior", cut_scores = c(C0 = 0))
  s_plug <- predict(post_const, newdata = nd_c, type = "both", conditioning = "plugin_mean", cut_scores = c(C0 = 0))
  expect_equal(s_post$estimates$BetweenSD, 0, tolerance = 1e-13)
  expect_equal(s_post$estimates$CalibrationVarShare, 0, tolerance = 1e-13)
  expect_equal(s_post$estimates$Estimate, s_plug$estimates$Estimate, tolerance = 1e-12)
  expect_equal(s_post$estimates$Median, s_plug$estimates$Median, tolerance = 1e-12)
  expect_equal(s_post$estimates$SD, s_plug$estimates$SD, tolerance = 1e-12)
  expect_equal(s_post$estimates$Lower, s_plug$estimates$Lower, tolerance = 1e-12)
  expect_equal(s_post$estimates$Upper, s_plug$estimates$Upper, tolerance = 1e-12)
  expect_equal(s_post$decisions$Probability, s_plug$decisions$Probability, tolerance = 1e-12)
  expect_equal(s_post$predictive$ExpectedScore, s_plug$predictive$ExpectedScore, tolerance = 1e-12)

  # 3. Batch composition & row-order invariance (< 1e-15)
  joint_post <- read_mfrm_posterior(system.file("extdata", "posterior-draws-example", package = "mfrmr"))
  solo_df <- data.frame(
    Person = c("TargetP", "TargetP", "TargetP"),
    Rater = c("R01", "R02", "R03"),
    Criterion = c("Accuracy", "Content", "Language"),
    Score = c(1, 2, 3),
    stringsAsFactors = FALSE
  )
  batch_df <- rbind(
    data.frame(Person = "ExtLow", Rater = c("R01", "R02"), Criterion = c("Accuracy", "Content"), Score = c(1, 1)),
    solo_df[c(3L, 1L, 2L), ],
    data.frame(Person = "ExtHigh", Rater = c("R02", "R03"), Criterion = c("Content", "Language"), Score = c(3, 3))
  )
  solo_res <- predict(joint_post, newdata = solo_df, type = "both", cut_scores = c(Pass = 0))
  batch_res <- predict(joint_post, newdata = batch_df, type = "both", cut_scores = c(Pass = 0))
  b_row <- batch_res$estimates[batch_res$estimates$Person == "TargetP", ]
  for (col in c("Estimate", "Median", "SD", "WithinSD", "BetweenSD", "Lower", "Upper", "PersonLogMarginalLikelihood")) {
    expect_lt(abs(solo_res$estimates[[col]] - b_row[[col]]), 1e-15, label = col)
  }
})

test_that("fail-closed input guards, two-family GPCM exclusion, calibration-member audit, and CmdStan readiness work cleanly", {
  post <- read_mfrm_posterior(system.file("extdata", "posterior-draws-example", package = "mfrmr"))
  valid_nd <- data.frame(
    Person = c("New1", "New1"),
    Rater = c("R01", "R02"),
    Criterion = c("Accuracy", "Content"),
    Score = c(2, 3),
    stringsAsFactors = FALSE
  )

  expect_error(predict(post), "newdata.*required")
  expect_error(predict(post, newdata = valid_nd, conditioning = "joint"), "Joint hierarchical refitting")
  expect_error(predict(post, newdata = valid_nd, conditioning = "other"), "posterior.*plugin_mean")
  expect_error(predict(post, newdata = valid_nd, quad_points = 5L), "quad_points")
  expect_error(predict(post, newdata = valid_nd[, c("Person", "Rater")]), "missing required source column")

  # Unseen facet level, invalid category, missing score under missing = "fail"
  bad_lvl <- valid_nd
  bad_lvl$Rater[1L] <- "R_UNSEEN"
  expect_error(predict(post, newdata = bad_lvl), "Unseen level")

  bad_cat <- valid_nd
  bad_cat$Score[1L] <- 99
  expect_error(predict(post, newdata = bad_cat), "outside the calibrated ladder")

  na_nd <- valid_nd
  na_nd$Score[2L] <- NA
  expect_error(predict(post, newdata = na_nd, missing = "fail"), "missing = 'omit'")

  # Duplicate Person-by-facet cell under repeated_ratings = "review" vs "independent"
  dup_nd <- rbind(valid_nd[1L, ], valid_nd[1L, ])
  expect_error(predict(post, newdata = dup_nd), "Duplicate observed Person-by-facet")
  dup_ok <- predict(post, newdata = dup_nd, repeated_ratings = "independent")
  expect_equal(dup_ok$estimates$Observed, 2L)

  # Calibration Person overlap guard vs explicit diagnostic override
  cal_pid <- post$scoring_spec$calibration_persons[1L]
  cal_nd <- valid_nd
  cal_nd$Person <- cal_pid
  expect_error(predict(post, newdata = cal_nd, allow_calibration_persons = FALSE), "double-counts")
  cal_ok <- predict(post, newdata = cal_nd, allow_calibration_persons = TRUE, keep_person_draws = TRUE)
  expect_true(cal_ok$estimates$CalibrationMember[1L])
  expect_true(is.na(cal_ok$estimates$PersonLogMarginalLikelihood[1L]))
  expect_true(all(is.na(cal_ok$person_draws$LogMarginalLikelihood)))
  expect_match(cal_ok$estimates$Reason[1L], "allow_calibration_persons = TRUE", fixed = TRUE)
  expect_true(any(grepl("CalibrationMember = TRUE", cal_ok$notes, fixed = TRUE)))

  # Two-family product-slope GPCM bundle fails closed before scoring
  gmfrm_fit <- readRDS(test_path("fixtures", "gmfrm-adaptive-profiles.rds"))$fit
  g_dir <- tempfile("b3-gmfrm-")
  dir.create(g_dir)
  on.exit(unlink(g_dir, recursive = TRUE), add = TRUE)
  g_post <- build_scoring_test_bundle(gmfrm_fit, g_dir, chains = 2L, iterations = 10L, backend = "Stan")
  g_sc <- g_post$scoring_spec$source_columns
  g_nd <- data.frame(Person = "NewG1", stringsAsFactors = FALSE)
  names(g_nd)[1L] <- g_sc$person
  for (fi in seq_along(g_sc$facets)) {
    g_nd[[g_sc$facets[fi]]] <- g_post$scoring_spec$facet_levels[[g_post$scoring_spec$facet_names[fi]]][1L]
  }
  g_nd[[g_sc$score]] <- g_post$scoring_spec$categories$Score[1L]
  expect_error(predict(g_post, newdata = g_nd), "two-family product-slope GPCM scoring is not supported")

  # In-memory tampering fails checksum validation; saved uncentered means fail subspace verification in plugin_mean
  bad_post <- read_mfrm_posterior(system.file("extdata", "posterior-example", package = "mfrmr"))
  bad_post$parameters$mean[grepl("^locations\\[", bad_post$parameters$variable)] <- 0.5
  expect_error(
    predict(bad_post, newdata = data.frame(Person = "N1", Task = "t1", Rater = "r1", Score = 2),
            conditioning = "plugin_mean"),
    "Inconsistent exported posterior summary"
  )

  bad_sum_dir <- tempfile("b3-bad-sum-")
  dir.create(bad_sum_dir)
  on.exit(unlink(bad_sum_dir, recursive = TRUE), add = TRUE)
  src_sum_dir <- system.file("extdata", "posterior-example", package = "mfrmr")
  file.copy(file.path(src_sum_dir, c("model-data.rds", "posterior-summary.rds", "README.txt")), bad_sum_dir)
  ps_rds <- readRDS(file.path(bad_sum_dir, "posterior-summary.rds"))
  est_loc <- grepl("^locations\\[", ps_rds$parameters$variable) & ps_rds$parameters$value_role == "estimated"
  for (col in c("mean", "median", "lower", "upper")) {
    ps_rds$parameters[[col]][est_loc] <- ps_rds$parameters[[col]][est_loc] + 0.5
  }
  saveRDS(ps_rds, file.path(bad_sum_dir, "posterior-summary.rds"))
  uncentered_post <- read_mfrm_posterior(bad_sum_dir)
  expect_error(
    predict(uncentered_post, newdata = data.frame(Person = "N1", Task = "t1", Rater = "r1", Score = 2),
            conditioning = "plugin_mean"),
    "constraint subspace"
  )

  # Optional CmdStan execution pre-write guards in export_mfrm_model() and run-stan.R
  ratings <- load_mfrmr_data("example_core")
  spec <- list(person = "Person", facets = c("Rater", "Criterion"), score = "Score", model = "RSM")
  no_write_dir <- tempfile("b3-nowrite-")
  on.exit(unlink(no_write_dir, recursive = TRUE), add = TRUE)

  expect_error(
    export_mfrm_model(output_dir = no_write_dir, format = "stan", acknowledge_sensitive = TRUE,
                      data = ratings, spec = spec, run_cmdstan = FALSE, cmdstan_args = list(chains = 2L)),
    "requires `run_cmdstan = TRUE`"
  )
  expect_false(dir.exists(no_write_dir))

  expect_error(
    export_mfrm_model(output_dir = no_write_dir, format = "brms", acknowledge_sensitive = TRUE,
                      data = ratings, spec = spec, run_cmdstan = TRUE),
    "format = 'stan'"
  )
  expect_false(dir.exists(no_write_dir))

  expect_error(
    export_mfrm_model(output_dir = no_write_dir, format = "stan", acknowledge_sensitive = TRUE,
                      data = ratings, spec = spec, run_cmdstan = TRUE,
                      cmdstan_args = list(output_dir = "other")),
    "cannot override `data` or `output_dir`"
  )
  expect_false(dir.exists(no_write_dir))

  expect_error(
    export_mfrm_model(output_dir = no_write_dir, format = "stan", acknowledge_sensitive = TRUE,
                      data = ratings, spec = spec, run_cmdstan = TRUE,
                      cmdstan_args = list(unknown_arg = 1)),
    "Unsupported entries in `cmdstan_args`"
  )
  expect_false(dir.exists(no_write_dir))

  testthat::with_mocked_bindings(
    .mfrm_has_cmdstanr = function() FALSE,
    .package = "mfrmr",
    {
      expect_error(
        export_mfrm_model(output_dir = no_write_dir, format = "stan", acknowledge_sensitive = TRUE,
                          data = ratings, spec = spec, run_cmdstan = TRUE),
        "requires the `cmdstanr` package"
      )
      expect_false(dir.exists(no_write_dir))
    }
  )

  testthat::with_mocked_bindings(
    .mfrm_has_cmdstanr = function() TRUE,
    .mfrm_cmdstan_path = function() NULL,
    .package = "mfrmr",
    {
      expect_error(
        export_mfrm_model(output_dir = no_write_dir, format = "stan", acknowledge_sensitive = TRUE,
                          data = ratings, spec = spec, run_cmdstan = TRUE),
        "no configured CmdStan toolchain"
      )
      expect_false(dir.exists(no_write_dir))
    }
  )

  # Direct run-stan.R sample_args guards
  run_env <- new.env(parent = globalenv())
  sys.source(system.file("model-export", "run-stan.R", package = "mfrmr"), envir = run_env)
  expect_error(run_env$run_mfrm_stan(args = "--bad"), "Usage: Rscript run.R")
  expect_error(run_env$run_mfrm_stan(args = character(0), sample_args = list(1)), "unique non-empty")
  expect_error(run_env$run_mfrm_stan(args = character(0), sample_args = list(data = list())), "cannot override")
  expect_error(run_env$run_mfrm_stan(args = "--summarize", sample_args = list(chains = 2L)), "cannot be combined")
})

test_that("S3 methods, ggplot2 views, mfrm_report, apa_table, appendix export, and tampered validation work end-to-end", {
  post <- read_mfrm_posterior(system.file("extdata", "posterior-draws-example", package = "mfrmr"))
  nd <- data.frame(
    Person = c("CandA", "CandA", "CandA", "CandB", "CandB", "CandB", "CandPrior"),
    Rater = c("R01", "R02", "R03", "R01", "R02", "R03", "R01"),
    Criterion = c("Accuracy", "Content", "Language", "Accuracy", "Content", "Language", "Accuracy"),
    Score = c(1, 2, 2, 3, 3, NA, NA),
    stringsAsFactors = FALSE
  )
  scored <- predict(
    post,
    newdata = nd,
    type = "both",
    missing = "omit",
    cut_scores = c(Pass = 0, Distinction = 0.8),
    keep_person_draws = TRUE
  )

  expect_output(print(scored), "External Bayesian new-Person posterior scores", fixed = TRUE)
  s <- summary(scored)
  expect_s3_class(s, "summary.mfrm_posterior_scores")
  expect_output(print(s), "Person status counts", fixed = TRUE)

  ci <- confint(scored)
  expect_equal(ci$Lower, scored$estimates$Lower)
  expect_equal(confint(scored, parm = c("CandB", "CandA"))$Person, c("CandB", "CandA"))
  expect_error(confint(scored, level = 0.80), "Re-run `predict")

  expect_identical(as.data.frame(scored, what = "estimates"), scored$estimates)
  expect_identical(as.data.frame(scored, what = "predictive"), scored$predictive)
  expect_identical(as.data.frame(scored, what = "decisions"), scored$decisions)
  expect_identical(as.data.frame(scored, what = "person_draws"), scored$person_draws)
  expect_identical(as.data.frame(scored, what = "dispositions"), scored$person_dispositions)

  pred_mode <- predict(post, newdata = nd[1:3, ], type = "predictive")
  expect_identical(as.data.frame(pred_mode), pred_mode$predictive)
  expect_error(as.data.frame(pred_mode, what = "decisions"), "cut_scores")
  expect_error(as.data.frame(pred_mode, what = "person_draws"), "keep_person_draws")

  # All 3 ggplot views + plot_data + idempotent as_ggplot + ggplot_build
  for (vtype in c("intervals", "variance", "predictive")) {
    p <- plot(scored, type = vtype, draw = FALSE, reference = 0, preset = "monochrome")
    expect_s3_class(p, "ggplot")
    pd <- plot_data(p)
    expect_true(is.list(pd))
    expect_identical(pd$view_type, vtype)
    raw_pd <- attr(p, "mfrmr_plot_data")
    expect_s3_class(raw_pd, "mfrm_plot_data")
    expect_identical(raw_pd$name, "posterior_scores")
    expect_s3_class(as_ggplot(p), "ggplot")
    expect_s3_class(as_ggplot(raw_pd), "ggplot")
    expect_gte(length(ggplot2::ggplot_build(p)$data), 1L)
  }
  p_def_pred <- plot(pred_mode, draw = FALSE)
  expect_identical(plot_data(p_def_pred)$view_type, "predictive")

  plug <- predict(post, newdata = nd[1:3, ], conditioning = "plugin_mean")
  expect_error(plot(plug, type = "variance", draw = FALSE), "conditioning = 'posterior'")

  # mfrm_report, build_summary_table_bundle, apa_table (unrounded decisions!), export_summary_appendix, mfrm_results guard
  expect_error(mfrm_results(scored), "mfrm_report")
  rep_obj <- mfrm_report(scored, style = "apa", study_context = c(Construct = "Oral proficiency"))
  expect_s3_class(rep_obj, "mfrm_report")
  expect_identical(rep_obj$first_screen$Readiness, scored$posterior_decision$Interpretation[1L])
  expect_identical(rep_obj$tables$estimates, scored$estimates)
  expect_identical(rep_obj$tables$decisions, scored$decisions)
  expect_identical(rep_obj$tables$predictive, scored$predictive)

  bundle <- build_summary_table_bundle(scored)
  expect_s3_class(bundle, "mfrm_summary_table_bundle")
  expect_true(all(c("estimates", "decisions", "predictive") %in% names(bundle$tables)))

  apa_est <- apa_table(scored, which = "estimates", digits = 2)
  apa_dec <- apa_table(scored, which = "decisions", digits = 2)
  expect_s3_class(apa_est, "apa_table")
  expect_s3_class(apa_dec, "apa_table")
  # Decisions table must remain unrounded per mfrmr APA decision contract
  expect_identical(apa_dec$table$Probability, scored$decisions$Probability)

  app_dir <- tempfile("b3-app-")
  dir.create(app_dir)
  on.exit(unlink(app_dir, recursive = TRUE), add = TRUE)
  export_summary_appendix(rep_obj, output_dir = app_dir, prefix = "newp")
  html_out <- mfrm_report(scored, output = "html")
  expect_true(file.exists(html_out$path))

  rds_path <- file.path(app_dir, "scored.rds")
  saveRDS(scored, rds_path)
  reloaded <- readRDS(rds_path)
  expect_identical(summary(reloaded)$overview, s$overview)

  # Tampered object must fail validation
  tampered <- scored
  tampered$estimates$SD[1L] <- 0.001
  expect_error(print(tampered), "Inconsistent `mfrm_posterior_scores`")
})

test_that("high-slope multi-item narrow-posterior GPCM maintains C++ / pure-R parity and 63-vs-31 grid convergence", {
  # Stress-tests the 8-panel analyticity-and-curvature-scaled Gauss-Legendre grid when
  # alpha * sigma ~ 11 across 16 ratings per Person (s_z ~ 0.04, extreme & interior profiles)
  gpcm_shared <- readRDS(test_path("fixtures", "anchored-gpcm.rds"))$shared$fit
  out_dir <- tempfile("b3-narrow-gpcm-")
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE), add = TRUE)

  post <- build_scoring_test_bundle(
    gpcm_shared,
    out_dir,
    chains = 2L,
    iterations = 6L,
    backend = "Stan",
    pop_sd_range = c(2.35, 2.65),
    slope_sd = 0.75,
    seed = 20261099L
  )

  sc <- post$scoring_spec$source_columns
  f1_lvls <- post$scoring_spec$facet_levels[[post$scoring_spec$facet_names[1L]]]
  f2_lvls <- post$scoring_spec$facet_levels[[post$scoring_spec$facet_names[2L]]]
  cats <- post$scoring_spec$categories$Score
  grid_cells <- expand.grid(f1 = f1_lvls, f2 = f2_lvls, stringsAsFactors = FALSE)
  grid_cells <- grid_cells[rep(seq_len(nrow(grid_cells)), length.out = 16L), , drop = FALSE]

  make_person_rows <- function(pid, score_vec) {
    df <- data.frame(Person = rep(pid, 16L), stringsAsFactors = FALSE)
    names(df)[1L] <- sc$person
    df[[sc$facets[1L]]] <- grid_cells$f1
    df[[sc$facets[2L]]] <- grid_cells$f2
    df[[sc$score]] <- score_vec
    df
  }
  nd <- rbind(
    make_person_rows("NarrowAllMin", rep(cats[1L], 16L)),
    make_person_rows("NarrowMixed", rep(cats[c(1L, 2L, length(cats))], length.out = 16L)),
    make_person_rows("NarrowAllMax", rep(cats[length(cats)], 16L))
  )
  cuts <- c(Low = -0.5, High = 0.5)

  res_cpp <- withr::with_options(
    list(mfrmr.use_cpp11_backend = TRUE),
    predict(post, newdata = nd, type = "both", cut_scores = cuts, quad_points = 63L, repeated_ratings = "independent")
  )
  res_r <- withr::with_options(
    list(mfrmr.use_cpp11_backend = FALSE),
    predict(post, newdata = nd, type = "both", cut_scores = cuts, quad_points = 63L, repeated_ratings = "independent")
  )
  res_31 <- predict(post, newdata = nd, type = "both", cut_scores = cuts, quad_points = 31L, repeated_ratings = "independent")

  expect_identical(unique(res_cpp$estimates$Status), "available_posterior")
  expect_identical(unique(res_31$estimates$Status), "available_posterior")
  for (col in c("Estimate", "Median", "SD", "WithinSD", "BetweenSD", "Lower", "Upper", "PersonLogMarginalLikelihood")) {
    expect_lt(max(abs(res_cpp$estimates[[col]] - res_r$estimates[[col]])), 1e-12, label = paste("cpp_vs_r", col))
    expect_lt(max(abs(res_cpp$estimates[[col]] - res_31$estimates[[col]])), 1e-9, label = paste("63_vs_31", col))
  }
  expect_lt(max(abs(res_cpp$decisions$Probability - res_r$decisions$Probability)), 1e-12)
})

test_that("high-slope multi-item narrow-posterior GPCM matches adaptive stats::integrate oracle to < 1e-10", {
  skip_on_cran()
  gpcm_shared <- readRDS(test_path("fixtures", "anchored-gpcm.rds"))$shared$fit
  out_dir <- tempfile("b3-narrow-gpcm-oracle-")
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE), add = TRUE)

  post <- build_scoring_test_bundle(
    gpcm_shared,
    out_dir,
    chains = 2L,
    iterations = 6L,
    backend = "Stan",
    pop_sd_range = c(2.35, 2.65),
    slope_sd = 0.75,
    seed = 20261099L
  )

  sc <- post$scoring_spec$source_columns
  f1_lvls <- post$scoring_spec$facet_levels[[post$scoring_spec$facet_names[1L]]]
  f2_lvls <- post$scoring_spec$facet_levels[[post$scoring_spec$facet_names[2L]]]
  cats <- post$scoring_spec$categories$Score
  grid_cells <- expand.grid(f1 = f1_lvls, f2 = f2_lvls, stringsAsFactors = FALSE)
  grid_cells <- grid_cells[rep(seq_len(nrow(grid_cells)), length.out = 16L), , drop = FALSE]

  make_person_rows <- function(pid, score_vec) {
    df <- data.frame(Person = rep(pid, 16L), stringsAsFactors = FALSE)
    names(df)[1L] <- sc$person
    df[[sc$facets[1L]]] <- grid_cells$f1
    df[[sc$facets[2L]]] <- grid_cells$f2
    df[[sc$score]] <- score_vec
    df
  }
  nd <- rbind(
    make_person_rows("NarrowAllMin", rep(cats[1L], 16L)),
    make_person_rows("NarrowMixed", rep(cats[c(1L, 2L, length(cats))], length.out = 16L)),
    make_person_rows("NarrowAllMax", rep(cats[length(cats)], 16L))
  )
  cuts <- c(Low = -0.5, High = 0.5)

  res_cpp <- predict(post, newdata = nd, type = "both", cut_scores = cuts, quad_points = 63L, repeated_ratings = "independent")
  ref <- oracle_posterior_person_scores(post, newdata = nd, cut_scores = cuts)
  for (col in c("Estimate", "Median", "SD", "WithinSD", "BetweenSD", "Lower", "Upper", "PersonLogMarginalLikelihood")) {
    expect_lt(max(abs(res_cpp$estimates[[col]] - ref$estimates[[col]])), 1e-10, label = paste("oracle", col))
  }
  expect_lt(max(abs(res_cpp$decisions$Probability - ref$decisions$Probability)), 1e-10)
})
