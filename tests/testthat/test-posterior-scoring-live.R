live_integrate_person_mean_sd <- function(post, person_rows_df) {
  spec <- post$bundle_spec
  sc_spec <- post$scoring_spec
  sc <- sc_spec$source_columns
  facet_cols <- sc$facets
  score_col <- sc$score
  n_cat <- nrow(sc_spec$categories)
  k_max <- n_cat - 1L
  k_seq <- 0:k_max
  score_vals <- as.numeric(sc_spec$categories$Score)
  M <- mfrmr:::.mfrm_flatten_draws_array(post$draws$array)

  loc_mat <- M[, paste0("locations[", seq_len(spec$L), "]"), drop = FALSE]
  step_mat <- M[, unlist(lapply(seq_len(spec$G), function(g) paste0("steps[", g, ",", seq_len(k_max), "]")), use.names = FALSE), drop = FALSE]
  slope_mat <- if (identical(sc_spec$model, "GPCM") && spec$A > 0L) {
    M[, paste0("component_slopes[", seq_len(spec$A), "]"), drop = FALSE]
  } else {
    matrix(1, nrow = nrow(M), ncol = 1L)
  }
  mu_vec <- if (identical(spec$schema_version, 2L)) as.numeric(M[, "population_mean"]) else rep(0, nrow(M))
  sig_vec <- if (identical(spec$schema_version, 2L)) as.numeric(M[, "population_sd"]) else rep(1, nrow(M))
  n_draws <- length(mu_vec)
  y_obs <- sc_spec$categories$Category[match(as.numeric(person_rows_df[[score_col]]), score_vals)] - 1L

  draw_mu <- numeric(n_draws)
  draw_var <- numeric(n_draws)
  for (m in seq_len(n_draws)) {
    mu_m <- mu_vec[m]
    sig_m <- sig_vec[m]
    deltas <- vapply(seq_len(nrow(person_rows_df)), function(r) {
      sum(vapply(seq_along(sc_spec$facet_names), function(fi) {
        fn <- sc_spec$facet_names[fi]
        lv <- as.character(person_rows_df[[facet_cols[fi]]][r])
        li <- sc_spec$facet_loc_indices[[fn]][match(lv, sc_spec$facet_levels[[fn]])]
        sc_spec$facet_signs[[fn]] * loc_mat[m, li]
      }, numeric(1)))
    }, numeric(1))
    alphas <- vapply(seq_len(nrow(person_rows_df)), function(r) {
      if (identical(sc_spec$model, "GPCM") && length(sc_spec$slope_facet) == 1L) {
        slf <- sc_spec$slope_facet
        f_col <- facet_cols[match(slf, sc_spec$facet_names)]
        si <- match(as.character(person_rows_df[[f_col]][r]), as.character(sc_spec$slope_levels$Level))
        slope_mat[m, si]
      } else {
        1
      }
    }, numeric(1))
    cs_list <- lapply(seq_len(nrow(person_rows_df)), function(r) {
      g <- if (identical(sc_spec$model, "RSM")) {
        1L
      } else {
        sf <- sc_spec$step_facet
        f_col <- facet_cols[match(sf, sc_spec$facet_names)]
        match(as.character(person_rows_df[[f_col]][r]), sc_spec$step_owners)
      }
      c(0, cumsum(as.numeric(step_mat[m, (g - 1L) * k_max + seq_len(k_max)])))
    })

    lp_fn <- function(th) {
      out <- stats::dnorm(th, mean = mu_m, sd = sig_m, log = TRUE)
      for (r in seq_len(nrow(person_rows_df))) {
        u <- alphas[r] * (outer(th + deltas[r], k_seq) - matrix(cs_list[[r]], nrow = length(th), ncol = n_cat, byrow = TRUE))
        rmx <- apply(u, 1L, max)
        eu <- exp(u - rmx)
        out <- out + (u[, y_obs[r] + 1L] - rmx) - log(rowSums(eu))
      }
      out
    }
    opt <- stats::optimize(lp_fn, interval = c(mu_m - 20 * sig_m, mu_m + 20 * sig_m), maximum = TRUE, tol = 1e-13)
    ts <- opt$maximum
    hs <- opt$objective
    lo <- ts - 12 * sig_m
    hi <- ts + 12 * sig_m
    ds <- function(th) exp(lp_fn(th) - hs)
    i0 <- stats::integrate(ds, lo, ts, rel.tol = 1e-12, abs.tol = 1e-14)$value +
      stats::integrate(ds, ts, hi, rel.tol = 1e-12, abs.tol = 1e-14)$value
    i1 <- stats::integrate(function(th) (th - ts) * ds(th), lo, ts, rel.tol = 1e-12, abs.tol = 1e-14)$value +
      stats::integrate(function(th) (th - ts) * ds(th), ts, hi, rel.tol = 1e-12, abs.tol = 1e-14)$value
    i2 <- stats::integrate(function(th) (th - ts)^2 * ds(th), lo, ts, rel.tol = 1e-12, abs.tol = 1e-14)$value +
      stats::integrate(function(th) (th - ts)^2 * ds(th), ts, hi, rel.tol = 1e-12, abs.tol = 1e-14)$value
    dm <- i1 / i0
    draw_mu[m] <- ts + dm
    draw_var[m] <- i2 / i0 - dm^2
  }
  mn <- mean(draw_mu)
  wsd <- sqrt(mean(draw_var))
  bsd <- sqrt(mean((draw_mu - mn)^2))
  c(Estimate = mn, WithinSD = wsd, BetweenSD = bsd, SD = sqrt(wsd^2 + bsd^2))
}

test_that("live export_mfrm_model(run_cmdstan = TRUE) and held-out predict() work end-to-end for RSM and 1-family GPCM", {
  skip_if_not_installed("cmdstanr")
  cmdstan_ok <- tryCatch({
    p <- cmdstanr::cmdstan_path()
    is.character(p) && nzchar(p) && dir.exists(p)
  }, error = function(e) FALSE)
  skip_if(!cmdstan_ok, "CmdStan toolchain not configured")

  ratings <- load_mfrmr_data("example_core")
  all_p <- unique(as.character(ratings$Person))
  cal_p <- all_p[1:8]
  new_p <- all_p[9:10]
  cal_data <- ratings[ratings$Person %in% cal_p, , drop = FALSE]
  new_data <- ratings[ratings$Person %in% new_p, , drop = FALSE]
  # Keep only facet levels observed in cal_data
  for (fc in c("Rater", "Criterion")) {
    new_data <- new_data[new_data[[fc]] %in% unique(cal_data[[fc]]), , drop = FALSE]
  }
  anchor <- data.frame(Facet = "Rater", Level = as.character(cal_data$Rater[1L]), Anchor = 0)
  cmd_args <- list(
    seed = 20261031L,
    chains = 2L,
    parallel_chains = 1L,
    iter_warmup = 80L,
    iter_sampling = 50L,
    refresh = 0L,
    show_messages = FALSE,
    show_exceptions = FALSE
  )

  # 1. Ordinary RSM live CmdStan execution + --summarize replay + held-out scoring
  rsm_dir <- tempfile("live-b3-rsm-")
  on.exit(unlink(rsm_dir, recursive = TRUE), add = TRUE)
  res_rsm <- export_mfrm_model(
    output_dir = rsm_dir,
    format = "stan",
    acknowledge_sensitive = TRUE,
    data = cal_data,
    spec = list(
      person = "Person",
      facets = c("Rater", "Criterion"),
      score = "Score",
      model = "RSM",
      anchors = anchor
    ),
    write_json = TRUE,
    run_cmdstan = TRUE,
    cmdstan_args = cmd_args
  )

  expect_true(all(c("fit.rds", "predictive-draws.rds", "posterior-summary.rds", "posterior-draws.rds") %in% names(res_rsm$files)))
  expect_true(all(file.exists(res_rsm$files)))
  expect_s3_class(res_rsm$posterior, "mfrm_posterior_summary")
  expect_equal(dim(res_rsm$posterior$draws$array)[1:2], c(50L, 2L))

  # Replay `--summarize` from saved fit.rds without recompiling or sampling
  old_wd <- setwd(rsm_dir)
  on.exit(setwd(old_wd), add = TRUE)
  env_run <- new.env(parent = globalenv())
  sys.source("run.R", envir = env_run)
  invisible(utils::capture.output(env_run$run_mfrm_stan(args = "--summarize")))
  setwd(old_wd)
  reloaded_rsm <- read_mfrm_posterior(rsm_dir, draws = "require")
  expect_equal(reloaded_rsm$parameters$mean, res_rsm$posterior$parameters$mean, tolerance = 1e-12)

  scored_rsm <- predict(res_rsm$posterior, newdata = new_data, type = "both", cut_scores = c(Pass = 0))
  p1 <- scored_rsm$estimates$Person[1L]
  ref_rsm <- live_integrate_person_mean_sd(res_rsm$posterior, new_data[new_data$Person == p1, , drop = FALSE])
  expect_lt(max(abs(as.numeric(scored_rsm$estimates[1L, names(ref_rsm)]) - unname(ref_rsm))), 1e-10)

  # 2. Estimated-population one-family GPCM live CmdStan execution + held-out scoring
  gpcm_dir <- tempfile("live-b3-gpcm-")
  on.exit(unlink(gpcm_dir, recursive = TRUE), add = TRUE)
  res_gpcm <- export_mfrm_model(
    output_dir = gpcm_dir,
    format = "stan",
    acknowledge_sensitive = TRUE,
    data = cal_data,
    spec = list(
      person = "Person",
      facets = c("Rater", "Criterion"),
      score = "Score",
      model = "GPCM",
      step_facet = "Criterion",
      slope_facet = "Criterion",
      anchors = anchor
    ),
    run_cmdstan = TRUE,
    cmdstan_args = cmd_args
  )

  expect_s3_class(res_gpcm$posterior, "mfrm_posterior_summary")
  expect_identical(res_gpcm$posterior$source$Model, "GPCM")
  expect_match(res_gpcm$posterior$source$Population, "estimated", fixed = TRUE)

  scored_gpcm <- predict(
    res_gpcm$posterior,
    newdata = new_data,
    type = "both",
    cut_scores = c(Low = -0.5, High = 0.5),
    keep_person_draws = TRUE
  )
  p1_g <- scored_gpcm$estimates$Person[1L]
  ref_gpcm <- live_integrate_person_mean_sd(res_gpcm$posterior, new_data[new_data$Person == p1_g, , drop = FALSE])
  expect_lt(max(abs(as.numeric(scored_gpcm$estimates[1L, names(ref_gpcm)]) - unname(ref_gpcm))), 1e-10)
  expect_true(all(scored_gpcm$estimates$SD > scored_gpcm$estimates$WithinSD))

  # Plug-in mean mode on the live GPCM bundle also runs cleanly
  plug_gpcm <- predict(res_gpcm$posterior, newdata = new_data, conditioning = "plugin_mean")
  expect_identical(unique(plug_gpcm$estimates$Status), "available_conditional")
  expect_true(all(is.na(plug_gpcm$estimates$BetweenSD)))
})
