test_that("pure-R Vehtari MCMC diagnostics match posterior package to < 1e-12 across regimes", {
  skip_if_not_installed("posterior")
  helpers <- mfrmr:::.mfrm_posterior_helpers()
  set.seed(20261031L)
  regimes <- list(
    normal_4c = matrix(rnorm(800), 200, 4),
    ar1_4c = apply(matrix(rnorm(800), 200, 4), 2L, function(z) as.numeric(stats::filter(z, 0.65, "recursive"))),
    skew_1c = matrix(exp(rnorm(240, 0, 0.7)), 240, 1),
    shifted_4c = cbind(matrix(rnorm(600), 200, 3), rnorm(200, 2.5, 1)),
    constant_4c = matrix(-0.25, 80, 4)
  )
  for (nm in names(regimes)) {
    m <- regimes[[nm]]
    arr <- array(m, dim = c(nrow(m), ncol(m), 1L), dimnames = list(NULL, NULL, "x"))
    ours <- helpers$mfrm_summarize_draw_array(arr, level = 0.90)
    da <- posterior::as_draws_array(arr)
    ref <- suppressWarnings(posterior::summarise_draws(
      da,
      mean = base::mean, median = stats::median, sd = stats::sd,
      lower = function(z) unname(stats::quantile(z, 0.05)),
      upper = function(z) unname(stats::quantile(z, 0.95)),
      rhat = posterior::rhat, ess_bulk = posterior::ess_bulk, ess_tail = posterior::ess_tail,
      mcse_lower = function(z) unname(posterior::mcse_quantile(z, 0.05)),
      mcse_upper = function(z) unname(posterior::mcse_quantile(z, 0.95))
    ))
    cols <- c("mean", "median", "sd", "lower", "upper", "rhat", "ess_bulk", "ess_tail", "mcse_lower", "mcse_upper")
    v_o <- as.numeric(ours[1L, cols])
    v_r <- as.numeric(ref[1L, cols])
    expect_identical(is.na(v_o), is.na(v_r), info = nm)
    fin <- !is.na(v_o)
    if (any(fin)) {
      expect_lt(max(abs(v_o[fin] - v_r[fin])), 1e-12)
    }
  }
})

test_that("basis reconstruction and contrasts hold across all 4 exported schemas and both backends", {
  fixtures <- readRDS(test_path("fixtures", "anchored-facet-information.rds"))
  gpcm_fix <- readRDS(test_path("fixtures", "anchored-gpcm.rds"))
  gmfrm_fix <- readRDS(test_path("fixtures", "gmfrm-adaptive-profiles.rds"))$fit

  cases <- list(
    list(name = "unanchored_rsm_stan", fit = fixtures$RSM$fit, backend = "Stan", anchored = FALSE),
    list(name = "unanchored_pcm_brms", fit = fixtures$PCM$fit, backend = "brms", anchored = FALSE),
    list(name = "affine_gpcm_fixed_brms", fit = gpcm_fix$fixed_population$fit, backend = "brms", anchored = TRUE),
    list(name = "schema2_gpcm_pop_stan", fit = gpcm_fix$shared$fit, backend = "Stan", anchored = TRUE),
    list(name = "two_family_gmfrm_stan", fit = gmfrm_fix, backend = "Stan", anchored = FALSE)
  )

  for (cs in cases) {
    fit <- cs$fit
    if (!cs$anchored && !identical(cs$name, "two_family_gmfrm_stan")) {
      for (fc in fit$config$facet_names) {
        lvls <- fit$config$facet_levels[[fc]]
        fit$config$facet_specs[[fc]] <- mfrmr:::build_facet_constraint(lvls, centered = TRUE)
      }
    }
    dir <- tempfile(paste0("schema-", cs$name, "-"))
    dir.create(dir)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    bundle <- mfrmr:::mfrm_model_export_data(fit, 1.0, 0.8, 0.5)
    saveRDS(bundle, file.path(dir, "model-data.rds"))
    spec <- mfrmr:::.mfrm_extract_bundle_spec(bundle)
    helpers <- mfrmr:::.mfrm_posterior_helpers()
    set.seed(1031L)
    n_iter <- 50L
    n_chain <- 4L
    n_tot <- n_iter * n_chain

    parts <- list()
    add_m <- function(m, nm) {
      if (ncol(m) > 0L) {
        colnames(m) <- nm
        parts[[length(parts) + 1L]] <<- m
      }
    }
    if (identical(spec$schema_version, 2L)) {
      pm <- matrix(rnorm(n_tot, 0.2, 0.2), ncol = 1L)
      pls <- matrix(rnorm(n_tot, 0.05, 0.12), ncol = 1L)
      psd <- exp(pls)
      tr <- matrix(rnorm(n_tot * spec$J), n_tot, spec$J)
      th <- as.numeric(pm) + as.numeric(psd) * tr
      add_m(th, paste0("theta[", seq_len(spec$J), "]"))
      add_m(pm, "population_mean")
      add_m(psd, "population_sd")
      add_m(pls, "population_log_sd")
      add_m(tr, paste0("theta_raw[", seq_len(spec$J), "]"))
    } else {
      th <- matrix(rnorm(n_tot * spec$J), n_tot, spec$J)
      add_m(th, paste0("theta[", seq_len(spec$J), "]"))
      if (identical(cs$backend, "brms")) add_m(th, paste0("b_personp", seq_len(spec$J)))
    }
    Zl <- if (spec$P > 0L) matrix(rnorm(n_tot * spec$P, 0, 0.5), n_tot, spec$P) else matrix(0, n_tot, 0L)
    locs <- sweep(Zl %*% t(spec$location_basis), 2L, spec$location_offset, "+")
    add_m(locs, paste0("locations[", seq_len(spec$L), "]"))
    if (spec$P > 0L) {
      add_m(Zl, if (cs$backend == "Stan") paste0("location_free[", seq_len(spec$P), "]") else paste0("b_z", seq_len(spec$P)))
    }
    Bs <- mfrmr:::.mfrm_full_step_basis(spec)
    Zs <- if (ncol(Bs) > 0L) matrix(rnorm(n_tot * ncol(Bs), 0, 0.4), n_tot, ncol(Bs)) else matrix(0, n_tot, 0L)
    st <- sweep(Zs %*% t(Bs), 2L, spec$step_offset, "+")
    K <- spec$C - 1L
    st_nms <- unlist(lapply(seq_len(spec$G), function(g) paste0("steps[", g, ",", seq_len(K), "]")), use.names = FALSE)
    add_m(st, st_nms)
    if (ncol(Bs) > 0L) {
      sf_nms <- if (isTRUE(spec$affine)) {
        if (cs$backend == "Stan") paste0("step_free[", seq_len(spec$T), "]") else paste0("b_step", seq_len(spec$T), "offset_constant")
      } else if (cs$backend == "Stan") {
        unlist(lapply(seq_len(spec$G), function(g) paste0("step_free[", g, ",", seq_len(spec$Q), "]")), use.names = FALSE)
      } else if (spec$G == 1L) {
        paste0("b_step", seq_len(spec$Q), "offset_Intercept")
      } else {
        unlist(lapply(seq_len(spec$G), function(g) paste0("b_step", seq_len(spec$Q), "offset_ownerg", g)), use.names = FALSE)
      }
      add_m(Zs, sf_nms)
    }
    if (spec$A > 0L) {
      Za <- if (spec$S > 0L) matrix(rnorm(n_tot * spec$S, 0, 0.2), n_tot, spec$S) else matrix(0, n_tot, 0L)
      ls <- Za %*% t(spec$slope_basis)
      add_m(exp(ls), paste0("component_slopes[", seq_len(spec$A), "]"))
      add_m(ls, paste0("log_component_slopes[", seq_len(spec$A), "]"))
      if (spec$S > 0L) {
        add_m(Za, if (cs$backend == "Stan") paste0("log_slope_free[", seq_len(spec$S), "]") else paste0("b_slope", seq_len(spec$S), "offset_constant"))
      }
    }
    mat <- do.call(cbind, parts)
    arr <- array(mat, dim = c(n_iter, n_chain, ncol(mat)), dimnames = list(NULL, NULL, colnames(mat)))
    sampler <- data.frame(chain = 1:4, num_divergent = 0, num_max_treedepth = 0, ebfmi = 0.85)
    old_wd <- setwd(dir)
    helpers$summarize_mfrm_draws(arr, bundle, sampler, cs$backend)
    setwd(old_wd)

    x <- read_mfrm_posterior(dir)
    rec <- mfrmr:::.mfrm_reconstruct_constrained_draws(x$draws$array, x$bundle_spec, x$backend, tol = 1e-12)
    expect_true(all(rec$verified), info = cs$name)

    fc1 <- fit$config$facet_names[1L]
    cx <- summary(x, contrasts = c(fc1, "Person"), level = 0.85)
    expect_equal(cx$level, 0.85, info = cs$name)
    expect_true(all(c("location", "ability") %in% cx$contrasts$quantity), info = cs$name)

    if (identical(cs$name, "two_family_gmfrm_stan")) {
      # Cross-owner slope contrasts in 2-family GPCM must be rejected
      sl_p <- x$parameters[x$parameters$quantity == "log_slope", ]
      owners <- unique(sl_p$facet)
      v1 <- sl_p$variable[sl_p$facet == owners[1L]][1L]
      v2 <- sl_p$variable[sl_p$facet == owners[2L]][1L]
      expect_error(summary(x, contrasts = list(cross = stats::setNames(c(1, -1), c(v1, v2)))),
                   "single slope owner")
    }
  }
})

test_that("live CmdStanR export -> run.R -> read_mfrm_posterior -> contrasts round-trip works end-to-end", {
  skip_if_not_installed("cmdstanr")
  cmdstan_ok <- tryCatch({
    p <- cmdstanr::cmdstan_path()
    is.character(p) && nzchar(p) && dir.exists(p)
  }, error = function(e) FALSE)
  skip_if(!cmdstan_ok, "CmdStan toolchain not configured")

  ratings <- load_mfrmr_data("example_core")
  keep_p <- unique(ratings$Person)[1:8]
  sub <- ratings[ratings$Person %in% keep_p, , drop = FALSE]
  anchor <- data.frame(Facet = "Rater", Level = as.character(sub$Rater[1L]), Anchor = 0)
  spec <- list(
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "RSM",
    anchors = anchor
  )
  out_dir <- tempfile("live-stan-b2-")
  on.exit(unlink(out_dir, recursive = TRUE), add = TRUE)
  export_mfrm_model(
    output_dir = out_dir,
    format = "stan",
    acknowledge_sensitive = TRUE,
    data = sub,
    spec = spec,
    write_json = TRUE
  )

  # Compile and run short chains, then invoke summarize_mfrm_stan
  old_wd <- setwd(out_dir)
  on.exit(setwd(old_wd), add = TRUE)
  bundle <- readRDS("model-data.rds")
  mod <- cmdstanr::cmdstan_model("model.stan")
  fit <- mod$sample(
    data = bundle$stan_data, seed = 20261031L,
    chains = 2L, parallel_chains = 1L,
    iter_warmup = 80L, iter_sampling = 50L,
    refresh = 0L, show_messages = FALSE, show_exceptions = FALSE
  )
  fit$save_object("fit.rds")
  env_run <- new.env(parent = globalenv())
  sys.source("run.R", envir = env_run)
  env_run$summarize_mfrm_stan(fit)
  setwd(old_wd)

  expect_true(file.exists(file.path(out_dir, "posterior-draws.rds")))
  x <- read_mfrm_posterior(out_dir)
  expect_identical(x$source$ExportSourceMethod, "specification")
  expect_identical(x$draws$iterations, 50L)
  cx <- summary(x, contrasts = c("Rater", "Step owner"), level = 0.90)
  expect_gt(nrow(cx$contrasts), 0L)

  # Fallback via fit.rds when posterior-draws.rds is removed and draws = "require"
  unlink(file.path(out_dir, "posterior-draws.rds"))
  x_fb <- read_mfrm_posterior(out_dir, draws = "require")
  cx_fb <- summary(x_fb, contrasts = c("Rater", "Step owner"), level = 0.90)
  expect_equal(cx_fb$contrasts$lower, cx$contrasts$lower, tolerance = 1e-12)
  expect_equal(cx_fb$contrasts$upper, cx$contrasts$upper, tolerance = 1e-12)
})
