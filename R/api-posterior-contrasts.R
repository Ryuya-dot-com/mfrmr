# Internal helpers for joint posterior draws, basis verification, and contrasts (B2).

.mfrm_extract_bundle_spec <- function(bundle) {
  d <- bundle$stan_data
  affine <- isTRUE(bundle$affine)
  list(
    model = bundle$model,
    affine = affine,
    schema_version = if (is.null(bundle$population)) 1L else 2L,
    J = as.integer(d$J),
    C = as.integer(d$C),
    P = as.integer(d$P),
    L = as.integer(d$L),
    G = as.integer(d$G),
    Q = if (is.null(d$Q)) NULL else as.integer(d$Q),
    T = if (is.null(d$T)) NULL else as.integer(d$T),
    S = if (is.null(d$S)) 0L else as.integer(d$S),
    A = if (is.null(d$A)) 0L else as.integer(d$A),
    location_basis = as.matrix(d$location_basis),
    location_offset = if (is.null(d$location_offset)) rep(0, d$L) else as.numeric(d$location_offset),
    step_basis = as.matrix(d$step_basis),
    step_offset = if (is.null(d$step_offset)) rep(0, d$G * (d$C - 1L)) else as.numeric(d$step_offset),
    slope_basis = if (is.null(d$slope_basis)) matrix(0, 0L, 0L) else as.matrix(d$slope_basis),
    levels = bundle$levels,
    step_owners = bundle$step_owners,
    slope_levels = bundle$slope_levels
  )
}

.mfrm_full_step_basis <- function(spec) {
  if (isTRUE(spec$affine)) {
    return(as.matrix(spec$step_basis))
  }
  H <- as.matrix(spec$step_basis)
  K <- spec$C - 1L
  Q <- ncol(H)
  G <- spec$G
  if (Q == 0L) {
    return(matrix(0, G * K, 0L))
  }
  out <- matrix(0, G * K, G * Q)
  for (g in seq_len(G)) {
    out[(g - 1L) * K + seq_len(K), (g - 1L) * Q + seq_len(Q)] <- H
  }
  out
}

.mfrm_flatten_draws_array <- function(draws_array) {
  dims <- dim(draws_array)
  mat <- matrix(draws_array, nrow = dims[1L] * dims[2L], ncol = dims[3L])
  colnames(mat) <- dimnames(draws_array)[[3L]]
  mat
}

.mfrm_reconstruct_constrained_draws <- function(draws_array, spec, backend = c("Stan", "brms"),
                                                tol = 1e-7) {
  backend <- match.arg(backend)
  M <- .mfrm_flatten_draws_array(draws_array)
  n_draws <- nrow(M)
  vars <- colnames(M)
  reconstructed <- list()
  verified <- logical()

  check_block <- function(block_name, hat_mat, target_names) {
    reconstructed[[block_name]] <<- hat_mat
    if (all(target_names %in% vars)) {
      obs <- M[, target_names, drop = FALSE]
      scale <- pmax(1, abs(obs))
      ok <- all(is.finite(hat_mat)) && max(abs(hat_mat - obs) / scale) <= tol
      verified[[block_name]] <<- ok
      if (!ok) {
        stop(
          "Inconsistent exported posterior summary; constrained `", block_name,
          "` draws disagree with the bundle's free-coordinate basis.",
          call. = FALSE
        )
      }
    } else {
      verified[[block_name]] <<- FALSE
    }
  }

  # 1. Facet locations
  loc_free <- if (spec$P == 0L) {
    character(0)
  } else if (backend == "Stan") {
    paste0("location_free[", seq_len(spec$P), "]")
  } else {
    paste0("b_z", seq_len(spec$P))
  }
  if (spec$P == 0L || all(loc_free %in% vars)) {
    Z_loc <- if (spec$P == 0L) matrix(0, n_draws, 0L) else M[, loc_free, drop = FALSE]
    loc_hat <- sweep(Z_loc %*% t(spec$location_basis), 2L, spec$location_offset, "+")
    loc_names <- paste0("locations[", seq_len(spec$L), "]")
    colnames(loc_hat) <- loc_names
    check_block("locations", loc_hat, loc_names)
  }

  # 2. Step offsets (owner-major order: steps[1,1..K], ..., steps[G,1..K])
  K <- spec$C - 1L
  if (isTRUE(spec$affine)) {
    step_free <- if (spec$T == 0L) {
      character(0)
    } else if (backend == "Stan") {
      paste0("step_free[", seq_len(spec$T), "]")
    } else {
      paste0("b_step", seq_len(spec$T), "offset_constant")
    }
    has_step_free <- (spec$T == 0L) || all(step_free %in% vars)
  } else {
    step_free <- if (spec$Q == 0L) {
      character(0)
    } else if (backend == "Stan") {
      unlist(lapply(seq_len(spec$G), function(g) {
        paste0("step_free[", g, ",", seq_len(spec$Q), "]")
      }), use.names = FALSE)
    } else if (spec$G == 1L) {
      paste0("b_step", seq_len(spec$Q), "offset_Intercept")
    } else {
      unlist(lapply(seq_len(spec$G), function(g) {
        paste0("b_step", seq_len(spec$Q), "offset_ownerg", g)
      }), use.names = FALSE)
    }
    has_step_free <- (spec$Q == 0L) || all(step_free %in% vars)
  }
  if (has_step_free) {
    B_step <- .mfrm_full_step_basis(spec)
    Z_step <- if (length(step_free) == 0L) matrix(0, n_draws, 0L) else M[, step_free, drop = FALSE]
    step_hat <- sweep(Z_step %*% t(B_step), 2L, spec$step_offset, "+")
    step_names <- unlist(lapply(seq_len(spec$G), function(g) {
      paste0("steps[", g, ",", seq_len(K), "]")
    }), use.names = FALSE)
    colnames(step_hat) <- step_names
    check_block("steps", step_hat, step_names)
  }

  # 3. Component log slopes and slopes
  if (spec$A > 0L) {
    slope_free <- if (spec$S == 0L) {
      character(0)
    } else if (backend == "Stan") {
      paste0("log_slope_free[", seq_len(spec$S), "]")
    } else {
      paste0("b_slope", seq_len(spec$S), "offset_constant")
    }
    if (spec$S == 0L || all(slope_free %in% vars)) {
      Z_slope <- if (spec$S == 0L) matrix(0, n_draws, 0L) else M[, slope_free, drop = FALSE]
      log_slope_hat <- Z_slope %*% t(spec$slope_basis)
      log_names <- paste0("log_component_slopes[", seq_len(spec$A), "]")
      colnames(log_slope_hat) <- log_names
      check_block("log_component_slopes", log_slope_hat, log_names)

      slope_hat <- exp(log_slope_hat)
      slope_names <- paste0("component_slopes[", seq_len(spec$A), "]")
      colnames(slope_hat) <- slope_names
      check_block("component_slopes", slope_hat, slope_names)
    }
  }

  # 4. Population & abilities
  theta_names <- paste0("theta[", seq_len(spec$J), "]")
  if (identical(spec$schema_version, 2L)) {
    raw_names <- paste0("theta_raw[", seq_len(spec$J), "]")
    pop_req <- c("population_mean", "population_log_sd", raw_names)
    if (all(pop_req %in% vars)) {
      pop_sd_hat <- matrix(exp(M[, "population_log_sd"]), ncol = 1L,
                           dimnames = list(NULL, "population_sd"))
      check_block("population_sd", pop_sd_hat, "population_sd")
      theta_hat <- M[, "population_mean"] + as.numeric(pop_sd_hat) * M[, raw_names, drop = FALSE]
      colnames(theta_hat) <- theta_names
      check_block("theta", theta_hat, theta_names)
    }
  } else if (backend == "brms") {
    b_theta <- paste0("b_personp", seq_len(spec$J))
    if (all(b_theta %in% vars)) {
      theta_hat <- M[, b_theta, drop = FALSE]
      colnames(theta_hat) <- theta_names
      check_block("theta", theta_hat, theta_names)
    }
  } else if (all(theta_names %in% vars)) {
    reconstructed[["theta"]] <- M[, theta_names, drop = FALSE]
    verified[["theta"]] <- TRUE
  }

  list(reconstructed = reconstructed, verified = verified)
}

.mfrm_verify_subspace_draws <- function(M, target_names, offset, basis, tol = 1e-6) {
  if (!all(target_names %in% colnames(M))) {
    stop("Required parameter draws are missing from the posterior draws array.", call. = FALSE)
  }
  Y <- M[, target_names, drop = FALSE]
  centered <- sweep(Y, 2L, offset, "-")
  proj <- if (ncol(basis) == 0L) {
    matrix(0, nrow(Y), ncol(Y))
  } else {
    (centered %*% basis) %*% t(basis)
  }
  err <- max(abs(centered - proj) / pmax(1, abs(Y)))
  if (!is.finite(err) || err > tol) {
    stop(
      "Saved parameter draws violate the exported affine/centering constraint subspace; ",
      "regenerate posterior-draws.rds from the matching fit and model-data.rds.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

.mfrm_extract_draws_from_saved_fit <- function(dir, x, bundle) {
  fit_file <- file.path(dir, "fit.rds")
  if (!file.exists(fit_file)) {
    stop(
      "Joint posterior draws require `posterior-draws.rds` (run `Rscript run.R --summarize` in the bundle directory) or a saved `fit.rds`.",
      call. = FALSE
    )
  }
  if (identical(x$backend, "Stan")) {
    if (!requireNamespace("cmdstanr", quietly = TRUE)) {
      stop(
        "`posterior-draws.rds` is absent; reading `fit.rds` directly requires `cmdstanr`.",
        call. = FALSE
      )
    }
    fit <- readRDS(fit_file)
    arr <- fit$draws(x$parameters$variable, format = "draws_array")
    raw <- array(as.numeric(arr), dim = dim(arr),
                 dimnames = list(NULL, NULL, dimnames(arr)[[3L]]))
  } else {
    if (!requireNamespace("brms", quietly = TRUE) ||
        !requireNamespace("posterior", quietly = TRUE)) {
      stop(
        "`posterior-draws.rds` is absent; reading a brms `fit.rds` directly requires `brms` and `posterior`.",
        call. = FALSE
      )
    }
    fit <- readRDS(fit_file)
    param_file <- file.path(dir, "parameters.rds")
    if (!file.exists(param_file)) {
      stop("Reading a brms `fit.rds` without `posterior-draws.rds` requires `parameters.rds`.", call. = FALSE)
    }
    parameters <- readRDS(param_file)
    helpers <- .mfrm_posterior_helpers()
    arr <- helpers$mfrm_brms_draws(fit, parameters)
    raw <- array(as.numeric(arr), dim = dim(arr),
                 dimnames = list(NULL, NULL, dimnames(arr)[[3L]]))
  }
  if (!all(x$parameters$variable %in% dimnames(raw)[[3L]])) {
    stop("`fit.rds` does not contain all variables recorded in `posterior-summary.rds`.", call. = FALSE)
  }
  raw <- raw[, , x$parameters$variable, drop = FALSE]
  list(
    array = raw,
    iterations = as.integer(dim(raw)[1L]),
    chains = as.integer(dim(raw)[2L]),
    backend = x$backend,
    model_data_md5 = x$model_data_md5,
    posterior_summary_md5 = NA_character_
  )
}

.mfrm_load_posterior_draws <- function(dir, summary_file, x, bundle,
                                       mode = c("auto", "require", "none")) {
  mode <- match.arg(mode)
  if (identical(mode, "none")) return(NULL)
  draws_file <- file.path(dir, "posterior-draws.rds")
  if (file.exists(draws_file)) {
    d_obj <- readRDS(draws_file)
    summary_md5 <- unname(tools::md5sum(summary_file))
    if (!is.list(d_obj) ||
        !identical(d_obj$schema_version, x$schema_version) ||
        !identical(d_obj$backend, x$backend) ||
        !identical(d_obj$chains, x$chains) ||
        !identical(d_obj$model_data_md5, x$model_data_md5) ||
        !identical(d_obj$posterior_summary_md5, summary_md5) ||
        !is.array(d_obj$draws) || length(dim(d_obj$draws)) != 3L ||
        !is.numeric(d_obj$draws)) {
      stop(
        "The joint posterior draws file (`posterior-draws.rds`) does not match `posterior-summary.rds` and `model-data.rds` checksums. ",
        "Regenerate both with `Rscript run.R --summarize`; no new sampling is needed.",
        call. = FALSE
      )
    }
    return(list(
      array = d_obj$draws,
      iterations = as.integer(dim(d_obj$draws)[1L]),
      chains = as.integer(dim(d_obj$draws)[2L]),
      backend = x$backend,
      model_data_md5 = x$model_data_md5,
      posterior_summary_md5 = d_obj$posterior_summary_md5
    ))
  }
  if (identical(mode, "auto")) {
    return(NULL)
  }
  .mfrm_extract_draws_from_saved_fit(dir, x, bundle)
}

.mfrm_validate_posterior_draws_and_contrasts <- function(x, fail) {
  has_draws <- !is.null(x$draws)
  has_contrasts <- !is.null(x$contrasts) || !is.null(x$contrast_draws)
  if (!has_draws) {
    if (has_contrasts || !identical(x$level, .95)) fail()
    return(invisible(x))
  }
  if (!is.numeric(x$level) || length(x$level) != 1L || !is.finite(x$level) ||
      x$level <= 0 || x$level >= 1) {
    fail()
  }
  d <- x$draws
  p <- x$parameters
  if (!is.list(d) || !is.array(d$array) || length(dim(d$array)) != 3L ||
      !is.numeric(d$array) || any(!is.finite(d$array)) ||
      !identical(as.integer(dim(d$array)[1L]), as.integer(d$iterations)) ||
      !identical(as.integer(dim(d$array)[2L]), as.integer(x$chains)) ||
      !identical(as.integer(dim(d$array)[2L]), as.integer(d$chains)) ||
      !identical(dim(d$array)[3L], nrow(p)) ||
      !identical(dimnames(d$array)[[3L]], p$variable) ||
      !identical(d$backend, x$backend) ||
      !identical(d$model_data_md5, x$model_data_md5) ||
      dim(d$array)[1L] < 2L ||
      !is.list(x$bundle_spec)) {
    fail()
  }
  pos_idx <- which(p$quantity %in% c("slope", "population_sd"))
  if (length(pos_idx) > 0L && any(d$array[, , pos_idx, drop = FALSE] <= 0)) {
    fail()
  }
  fixed_idx <- which(p$value_role %in% c("fixed_anchor", "fixed_by_constraint"))
  for (i in fixed_idx) {
    fv <- p$fixed_value[i]
    if (any(abs(d$array[, , i] - fv) > 1e-7 * max(1, abs(fv)))) fail()
  }
  # Verify free-to-constrained basis reconstruction for every present block.
  basis_chk <- tryCatch(
    .mfrm_reconstruct_constrained_draws(d$array, x$bundle_spec, x$backend, tol = 1e-7),
    error = function(e) NULL
  )
  if (is.null(basis_chk)) fail()

  # Verify marginal moments and quantiles at x$level match x$draws$array.
  alpha_low <- (1 - x$level) / 2
  alpha_high <- 1 - alpha_low
  vary_idx <- which(!p$value_role %in% c("fixed_anchor", "fixed_by_constraint"))
  for (i in vary_idx) {
    vec <- as.numeric(d$array[, , i])
    qs <- stats::quantile(vec, probs = c(alpha_low, alpha_high), names = FALSE)
    obs <- c(p$mean[i], p$median[i], p$sd[i], p$lower[i], p$upper[i])
    exp_v <- c(base::mean(vec), stats::median(vec), stats::sd(vec), qs[1L], qs[2L])
    if (any(!is.finite(obs)) || max(abs(obs - exp_v) / pmax(1, abs(exp_v))) > 1e-7) {
      fail()
    }
  }

  if (has_contrasts) {
    ct <- x$contrasts
    cd <- x$contrast_draws
    req_cols <- c(
      "contrast_id", "label", "quantity", "facet", "lhs", "rhs", "scale",
      "value_role", "mean", "median", "sd", "lower", "upper",
      "prob_gt_zero", "prob_lt_zero", "rhat", "ess_bulk", "ess_tail",
      "mcse_lower", "mcse_upper", "endpoint_mcse_fraction",
      "credible_level", "interval_computed", "sampling_review",
      "interval_status", "fixed_value", "reference", "direction"
    )
    if (!is.data.frame(ct) || !nrow(ct) || !all(req_cols %in% names(ct)) ||
        anyNA(ct$contrast_id) || anyDuplicated(ct$contrast_id) ||
        any(!ct$value_role %in% c("estimated", "fixed_anchor", "fixed_by_constraint")) ||
        !is.list(cd) || !is.array(cd$array) || length(dim(cd$array)) != 3L ||
        !is.numeric(cd$array) || any(!is.finite(cd$array)) ||
        !identical(dim(cd$array)[1L], dim(d$array)[1L]) ||
        !identical(dim(cd$array)[2L], dim(d$array)[2L]) ||
        !identical(dim(cd$array)[3L], nrow(ct)) ||
        !identical(dimnames(cd$array)[[3L]], ct$contrast_id) ||
        any(abs(ct$credible_level - x$level) > 1e-12)) {
      fail()
    }
    num_cols <- c("mean", "median", "sd", "lower", "upper", "prob_gt_zero", "prob_lt_zero",
                  "rhat", "ess_bulk", "ess_tail", "mcse_lower", "mcse_upper",
                  "endpoint_mcse_fraction", "fixed_value")
    if (!all(vapply(ct[num_cols], function(v) is.numeric(v) && all(is.na(v) | is.finite(v)), logical(1)))) {
      fail()
    }
    c_fixed <- ct$value_role %in% c("fixed_anchor", "fixed_by_constraint")
    if (any(!is.finite(ct$mean[c_fixed])) ||
        any(abs(ct$mean[c_fixed] - ct$fixed_value[c_fixed]) > 1e-7 * pmax(1, abs(ct$fixed_value[c_fixed]))) ||
        any(!is.na(as.matrix(ct[c_fixed, setdiff(num_cols, c("mean", "median", "fixed_value")), drop = FALSE]))) ||
        any(ct$lower > ct$upper, na.rm = TRUE) ||
        !identical(ct$interval_computed, is.finite(ct$lower) & is.finite(ct$upper) & !c_fixed)) {
      fail()
    }
    global_flag <- identical(x$decision$Status, "sampling_review_required")
    for (k in seq_len(nrow(ct))) {
      vec <- as.numeric(cd$array[, , k])
      if (c_fixed[k]) {
        if (any(abs(vec - ct$fixed_value[k]) > 1e-7 * max(1, abs(ct$fixed_value[k])))) fail()
        if (!identical(ct$interval_status[k], "fixed_value_no_interval")) fail()
      } else {
        qs <- stats::quantile(vec, probs = c(alpha_low, alpha_high), names = FALSE)
        ref_val <- if (identical(ct$scale[k], "ratio")) 1 else 0
        obs <- c(ct$mean[k], ct$median[k], ct$sd[k], ct$lower[k], ct$upper[k],
                 ct$prob_gt_zero[k], ct$prob_lt_zero[k])
        exp_v <- c(base::mean(vec), stats::median(vec), stats::sd(vec), qs[1L], qs[2L],
                   base::mean(vec > ref_val), base::mean(vec < ref_val))
        if (any(!is.finite(obs)) || max(abs(obs - exp_v) / pmax(1, abs(exp_v))) > 1e-7) {
          fail()
        }
        row_flag <- global_flag || is.na(ct$rhat[k]) || ct$rhat[k] >= 1.01 ||
          is.na(ct$ess_bulk[k]) || ct$ess_bulk[k] < 100 * x$chains ||
          is.na(ct$ess_tail[k]) || ct$ess_tail[k] < 100 * x$chains
        exp_sr <- if (row_flag) "sampling_review_required" else "no_sampling_flags_detected"
        exp_is <- if (!ct$interval_computed[k]) {
          "unavailable"
        } else if (row_flag) {
          "computed_sampling_review_required"
        } else {
          "computed_model_review_required"
        }
        if (!identical(ct$sampling_review[k], exp_sr) ||
            !identical(ct$interval_status[k], exp_is)) {
          fail()
        }
      }
    }
  }
  invisible(x)
}

.mfrm_validate_credible_level <- function(level) {
  if (!is.numeric(level) || length(level) != 1L || !is.finite(level) ||
      level <= 0 || level >= 1) {
    stop("`level` must be one finite number strictly between 0 and 1.", call. = FALSE)
  }
  as.numeric(level)
}

.mfrm_recompute_posterior_level <- function(x, level) {
  level <- .mfrm_validate_credible_level(level)
  if (abs(level - x$level) <= 1e-12) return(x)
  if (is.null(x$draws)) {
    stop(
      "Only the stored 95% posterior credible interval is available. Use the backend's draws for another level.",
      call. = FALSE
    )
  }
  helpers <- .mfrm_posterior_helpers()
  alpha_low <- (1 - level) / 2
  alpha_high <- 1 - alpha_low
  p <- x$parameters
  arr <- x$draws$array
  n_iter <- dim(arr)[1L]
  n_chain <- dim(arr)[2L]
  fixed <- p$value_role %in% c("fixed_anchor", "fixed_by_constraint")
  for (i in which(!fixed)) {
    mat <- matrix(arr[, , i], nrow = n_iter, ncol = n_chain)
    vec <- as.numeric(mat)
    qs <- stats::quantile(vec, probs = c(alpha_low, alpha_high), names = FALSE)
    p$lower[i] <- qs[1L]
    p$upper[i] <- qs[2L]
    p$mcse_lower[i] <- helpers$mfrm_draws_mcse_quantile(mat, alpha_low)
    p$mcse_upper[i] <- helpers$mfrm_draws_mcse_quantile(mat, alpha_high)
  }
  p$interval_computed <- is.finite(p$lower) & is.finite(p$upper) & !fixed
  width <- p$upper - p$lower
  p$endpoint_mcse_fraction <- ifelse(
    is.finite(width) & width > 0,
    pmax(p$mcse_lower, p$mcse_upper) / width,
    NA_real_
  )
  status <- x$decision$Status
  p$interval_status <- ifelse(
    fixed, "fixed_value_no_interval",
    ifelse(
      !p$interval_computed, "unavailable",
      if (identical(status, "sampling_review_required")) {
        "computed_sampling_review_required"
      } else {
        "computed_model_review_required"
      }
    )
  )
  x$parameters <- p
  x$level <- level
  x$source$Level <- level
  if (!is.null(x$contrasts) && !is.null(x$contrast_draws) && !is.null(x$contrast_draws$specs)) {
    re <- .mfrm_evaluate_contrast_specs(x, x$contrast_draws$specs, level = level)
    x$contrasts <- re$contrasts
    x$contrast_draws <- re$contrast_draws
  }
  x
}

.mfrm_resolve_contrast_specs <- function(x, contrasts) {
  p <- x$parameters[x$parameters$role == "reported_parameter", , drop = FALSE]
  if (is.character(contrasts)) {
    if (!length(contrasts) || anyNA(contrasts) || any(!nzchar(trimws(contrasts))) ||
        anyDuplicated(contrasts)) {
      stop("`contrasts` character vector must name distinct non-empty facets or owners.", call. = FALSE)
    }
    specs <- list()
    for (fc in contrasts) {
      if (identical(fc, "steps")) fc <- "Step owner"
      if (identical(fc, "Person")) {
        sub <- p[p$quantity == "ability" & p$facet == "Person", , drop = FALSE]
      } else if (identical(fc, "Step owner")) {
        sub <- p[p$quantity == "step_offset", , drop = FALSE]
      } else if (any(p$quantity == "location" & p$facet == fc)) {
        sub <- p[p$quantity == "location" & p$facet == fc, , drop = FALSE]
      } else if (any(p$quantity == "log_slope" & p$facet == fc)) {
        sub <- p[p$quantity == "log_slope" & p$facet == fc, , drop = FALSE]
      } else {
        stop("Unknown facet/owner in `contrasts`: '", fc, "'.", call. = FALSE)
      }
      if (identical(fc, "Step owner")) {
        for (own in unique(sub$level)) {
          s_own <- sub[sub$level == own, , drop = FALSE]
          if (nrow(s_own) < 2L) {
            stop("Step owner '", own, "' has fewer than 2 step transitions to contrast.", call. = FALSE)
          }
          for (i in seq_len(nrow(s_own) - 1L)) {
            for (j in (i + 1L):nrow(s_own)) {
              # Higher transition minus lower transition so positive values indicate ordered steps.
              lhs_row <- s_own[j, , drop = FALSE]
              rhs_row <- s_own[i, , drop = FALSE]
              w <- stats::setNames(c(1, -1), c(lhs_row$variable, rhs_row$variable))
              specs[[length(specs) + 1L]] <- list(
                label = paste0(own, ": (", lhs_row$transition, ") - (", rhs_row$transition, ")"),
                weights = w,
                lhs = paste0(own, " | ", lhs_row$transition),
                rhs = paste0(own, " | ", rhs_row$transition),
                scale = "difference"
              )
            }
          }
        }
      } else {
        if (nrow(sub) < 2L) {
          stop("Facet/owner '", fc, "' has fewer than 2 levels to contrast.", call. = FALSE)
        }
        for (i in seq_len(nrow(sub) - 1L)) {
          for (j in (i + 1L):nrow(sub)) {
            lhs_row <- sub[i, , drop = FALSE]
            rhs_row <- sub[j, , drop = FALSE]
            w <- stats::setNames(c(1, -1), c(lhs_row$variable, rhs_row$variable))
            specs[[length(specs) + 1L]] <- list(
              label = paste0(fc, ": ", lhs_row$level, " - ", rhs_row$level),
              weights = w,
              lhs = lhs_row$level,
              rhs = rhs_row$level,
              scale = "difference"
            )
          }
        }
      }
    }
    return(specs)
  }

  if (is.data.frame(contrasts)) {
    if (!nrow(contrasts) || !all(c("lhs", "rhs") %in% names(contrasts))) {
      stop("A `contrasts` data.frame must be non-empty and contain `lhs` and `rhs` columns.", call. = FALSE)
    }
    lhs_col <- as.character(contrasts$lhs)
    rhs_col <- as.character(contrasts$rhs)
    facet_col <- if ("facet" %in% names(contrasts)) as.character(contrasts$facet) else rep(NA_character_, nrow(contrasts))
    qty_col <- if ("quantity" %in% names(contrasts)) as.character(contrasts$quantity) else rep(NA_character_, nrow(contrasts))
    lbl_col <- if ("label" %in% names(contrasts)) as.character(contrasts$label) else rep(NA_character_, nrow(contrasts))
    scl_col <- if ("scale" %in% names(contrasts)) as.character(contrasts$scale) else rep("difference", nrow(contrasts))
    if (anyNA(lhs_col) || anyNA(rhs_col) || any(!nzchar(trimws(lhs_col))) || any(!nzchar(trimws(rhs_col)))) {
      stop("`contrasts$lhs` and `contrasts$rhs` must be non-empty strings.", call. = FALSE)
    }
    if (anyNA(scl_col) || !all(scl_col %in% c("difference", "ratio"))) {
      stop("`contrasts$scale` must be 'difference' or 'ratio'.", call. = FALSE)
    }
    match_one <- function(token, fc, qty) {
      cand <- p
      if (!is.na(qty) && nzchar(qty)) cand <- cand[cand$quantity == qty, , drop = FALSE]
      if (!is.na(fc) && nzchar(fc)) cand <- cand[cand$facet == fc, , drop = FALSE]
      hit <- which(cand$variable == token)
      if (!length(hit)) {
        step_lbl <- ifelse(is.na(cand$transition), cand$level,
                           paste0(cand$level, " | ", cand$transition))
        full_lbl <- paste0(cand$facet, ": ", step_lbl)
        hit <- which(cand$level == token | step_lbl == token |
                     cand$transition == token | full_lbl == token)
      }
      if (length(hit) != 1L) {
        stop(
          "Contrast endpoint '", token, "' did not uniquely match one reported parameter",
          if (!is.na(fc) && nzchar(fc)) paste0(" in facet '", fc, "'") else "",
          ". Specify `facet`, `quantity`, or exact `variable` names.",
          call. = FALSE
        )
      }
      cand[hit, , drop = FALSE]
    }
    specs <- vector("list", nrow(contrasts))
    for (r in seq_len(nrow(contrasts))) {
      r_lhs <- match_one(lhs_col[r], facet_col[r], qty_col[r])
      r_rhs <- match_one(rhs_col[r], facet_col[r], qty_col[r])
      if (identical(r_lhs$variable, r_rhs$variable)) {
        stop("Contrast row ", r, " compares parameter '", r_lhs$variable, "' with itself.", call. = FALSE)
      }
      if (identical(scl_col[r], "ratio") && !identical(r_lhs$quantity, "slope")) {
        stop("`scale = 'ratio'` is supported only for positive `slope` contrasts.", call. = FALSE)
      }
      lhs_disp <- if (!is.na(r_lhs$transition)) paste0(r_lhs$level, " (", r_lhs$transition, ")") else r_lhs$level
      rhs_disp <- if (!is.na(r_rhs$transition)) paste0(r_rhs$level, " (", r_rhs$transition, ")") else r_rhs$level
      op <- if (identical(scl_col[r], "ratio")) " / " else " - "
      def_lbl <- if (identical(r_lhs$facet, r_rhs$facet)) {
        paste0(r_lhs$facet, ": ", lhs_disp, op, rhs_disp)
      } else {
        paste0(r_lhs$facet, ": ", lhs_disp, op, r_rhs$facet, ": ", rhs_disp)
      }
      specs[[r]] <- list(
        label = if (!is.na(lbl_col[r]) && nzchar(trimws(lbl_col[r]))) lbl_col[r] else def_lbl,
        weights = stats::setNames(c(1, -1), c(r_lhs$variable, r_rhs$variable)),
        lhs = lhs_disp,
        rhs = rhs_disp,
        scale = scl_col[r]
      )
    }
    return(specs)
  }

  if (is.list(contrasts) && length(contrasts) > 0L) {
    nms <- names(contrasts)
    specs <- vector("list", length(contrasts))
    for (k in seq_along(contrasts)) {
      w <- contrasts[[k]]
      if (!is.numeric(w) || !length(w) || is.null(names(w)) ||
          any(!is.finite(w)) || anyNA(names(w)) || any(!nzchar(trimws(names(w)))) ||
          anyDuplicated(names(w)) || all(abs(w) <= 1e-15)) {
        stop(
          "Each custom contrast in a list must be a named finite numeric weight vector with unique names and at least one nonzero weight.",
          call. = FALSE
        )
      }
      w <- w[abs(w) > 1e-15]
      step_lbl <- ifelse(is.na(p$transition), p$level, paste0(p$level, " | ", p$transition))
      full_lbl <- paste0(p$facet, ": ", step_lbl)
      vars <- vapply(names(w), function(tok) {
        hit <- which(p$variable == tok)
        if (!length(hit)) hit <- which(full_lbl == tok)
        if (length(hit) != 1L) {
          stop(
            "Custom contrast weight name '", tok,
            "' must uniquely match a reported `variable` (e.g. 'locations[1]') or 'Facet: Level' label.",
            call. = FALSE
          )
        }
        p$variable[hit]
      }, character(1))
      if (anyDuplicated(vars)) {
        stop("Custom contrast ", k, " references the same parameter more than once.", call. = FALSE)
      }
      names(w) <- vars
      lbl <- if (!is.null(nms) && !is.na(nms[k]) && nzchar(trimws(nms[k]))) {
        nms[k]
      } else {
        paste0("Linear contrast ", k)
      }
      lhs_val <- rhs_val <- NA_character_
      if (length(w) == 2L && isTRUE(all.equal(sort(unname(w)), c(-1, 1), tolerance = 1e-12))) {
        i_pos <- which(w > 0)
        i_neg <- which(w < 0)
        r_pos <- p[match(vars[i_pos], p$variable), ]
        r_neg <- p[match(vars[i_neg], p$variable), ]
        lhs_val <- if (!is.na(r_pos$transition)) paste0(r_pos$level, " (", r_pos$transition, ")") else r_pos$level
        rhs_val <- if (!is.na(r_neg$transition)) paste0(r_neg$level, " (", r_neg$transition, ")") else r_neg$level
      }
      specs[[k]] <- list(
        label = lbl,
        weights = w,
        lhs = lhs_val,
        rhs = rhs_val,
        scale = "difference"
      )
    }
    return(specs)
  }

  stop(
    "`contrasts` must be a character vector of facet/owner names, a `data.frame(lhs, rhs, ...)`, or a non-empty list of named numeric weight vectors.",
    call. = FALSE
  )
}

.mfrm_contrast_algebraic_role <- function(x, qty, rows, w, scale) {
  spec <- x$bundle_spec
  if (qty %in% c("ability", "population_mean", "population_sd")) {
    return(list(value_role = "estimated", fixed_value = NA_real_))
  }
  if (identical(qty, "location")) {
    full_w <- numeric(spec$L)
    loc_idx <- as.integer(sub("^locations\\[([0-9]+)\\]$", "\\1", rows$variable))
    full_w[loc_idx] <- unname(w)
    g <- if (spec$P == 0L) numeric(0) else drop(crossprod(spec$location_basis, full_w))
    if (!length(g) || max(abs(g)) <= 1e-12) {
      fval <- sum(full_w * spec$location_offset)
      has_user_anchor <- FALSE
      for (fc in unique(rows$facet)) {
        fspec <- x$constraints$facets[[fc]]
        if (!is.null(fspec)) {
          lvls <- rows$level[rows$facet == fc]
          m_idx <- match(lvls, fspec$levels)
          if (any(!is.na(fspec$anchors[m_idx])) ||
              (!is.null(fspec$groups) && any(!is.na(fspec$groups[m_idx]) & nzchar(fspec$groups[m_idx])))) {
            has_user_anchor <- TRUE
          }
        }
      }
      role <- if (has_user_anchor) "fixed_anchor" else "fixed_by_constraint"
      return(list(value_role = role, fixed_value = fval))
    }
    return(list(value_role = "estimated", fixed_value = NA_real_))
  }
  if (identical(qty, "step_offset")) {
    K <- spec$C - 1L
    full_w <- numeric(spec$G * K)
    g_idx <- as.integer(sub("^steps\\[([0-9]+),([0-9]+)\\]$", "\\1", rows$variable))
    k_idx <- as.integer(sub("^steps\\[([0-9]+),([0-9]+)\\]$", "\\2", rows$variable))
    full_w[(g_idx - 1L) * K + k_idx] <- unname(w)
    B_step <- .mfrm_full_step_basis(spec)
    g <- if (ncol(B_step) == 0L) numeric(0) else drop(crossprod(B_step, full_w))
    if (!length(g) || max(abs(g)) <= 1e-12) {
      fval <- sum(full_w * spec$step_offset)
      has_user_anchor <- FALSE
      if (!is.null(x$constraints$steps)) {
        for ( r_i in seq_along(g_idx) ) {
          sspec <- x$constraints$steps[[g_idx[r_i]]]
          if (!is.null(sspec) && !is.na(sspec$anchors[k_idx[r_i]])) {
            has_user_anchor <- TRUE
          }
        }
      }
      role <- if (has_user_anchor) "fixed_anchor" else "fixed_by_constraint"
      return(list(value_role = role, fixed_value = fval))
    }
    return(list(value_role = "estimated", fixed_value = NA_real_))
  }
  if (identical(qty, "log_slope")) {
    full_w <- numeric(spec$A)
    s_idx <- as.integer(sub("^log_component_slopes\\[([0-9]+)\\]$", "\\1", rows$variable))
    full_w[s_idx] <- unname(w)
    g <- if (spec$S == 0L) numeric(0) else drop(crossprod(spec$slope_basis, full_w))
    if (!length(g) || max(abs(g)) <= 1e-12) {
      return(list(value_role = "fixed_by_constraint", fixed_value = 0))
    }
    return(list(value_role = "estimated", fixed_value = NA_real_))
  }
  if (identical(qty, "slope")) {
    s_idx <- as.integer(sub("^component_slopes\\[([0-9]+)\\]$", "\\1", rows$variable))
    if (identical(scale, "ratio")) {
      full_w <- numeric(spec$A)
      full_w[s_idx] <- unname(w)
      g <- if (spec$S == 0L) numeric(0) else drop(crossprod(spec$slope_basis, full_w))
      if (!length(g) || max(abs(g)) <= 1e-12) {
        return(list(value_role = "fixed_by_constraint", fixed_value = 1))
      }
      return(list(value_role = "estimated", fixed_value = NA_real_))
    }
    row_fixed <- vapply(s_idx, function(idx) {
      spec$S == 0L || all(abs(spec$slope_basis[idx, ]) <= 1e-12)
    }, logical(1))
    if (all(row_fixed)) {
      return(list(value_role = "fixed_by_constraint", fixed_value = sum(w)))
    }
    return(list(value_role = "estimated", fixed_value = NA_real_))
  }
  stop("Unsupported parameter quantity for contrasts: '", qty, "'.", call. = FALSE)
}

.mfrm_evaluate_contrast_specs <- function(x, specs, level = x$level) {
  if (is.null(x$draws)) {
    stop(
      "Posterior contrasts require joint draws (`posterior-draws.rds`). ",
      "Marginal posterior SDs cannot reconstruct parameter covariance.",
      call. = FALSE
    )
  }
  level <- .mfrm_validate_credible_level(level)
  p <- x$parameters
  spec <- x$bundle_spec
  M <- .mfrm_flatten_draws_array(x$draws$array)
  n_iter <- dim(x$draws$array)[1L]
  n_chain <- dim(x$draws$array)[2L]
  helpers <- .mfrm_posterior_helpers()
  alpha_low <- (1 - level) / 2
  alpha_high <- 1 - alpha_low
  global_flag <- identical(x$decision$Status, "sampling_review_required")

  # Verify subspace admissibility once per referenced family before computing contrasts.
  checked_families <- character()
  ensure_family_subspace <- function(qty) {
    if (qty %in% checked_families) return(invisible(NULL))
    if (identical(qty, "location") && spec$L > 0L) {
      .mfrm_verify_subspace_draws(
        M, paste0("locations[", seq_len(spec$L), "]"),
        spec$location_offset, spec$location_basis
      )
    } else if (identical(qty, "step_offset") && spec$G > 0L) {
      K <- spec$C - 1L
      step_names <- unlist(lapply(seq_len(spec$G), function(g) {
        paste0("steps[", g, ",", seq_len(K), "]")
      }), use.names = FALSE)
      .mfrm_verify_subspace_draws(
        M, step_names, spec$step_offset, .mfrm_full_step_basis(spec)
      )
    } else if (qty %in% c("log_slope", "slope") && spec$A > 0L) {
      log_names <- paste0("log_component_slopes[", seq_len(spec$A), "]")
      if (all(log_names %in% colnames(M))) {
        .mfrm_verify_subspace_draws(
          M, log_names, rep(0, spec$A), spec$slope_basis
        )
      }
      if (identical(qty, "slope")) {
        s_names <- paste0("component_slopes[", seq_len(spec$A), "]")
        if (all(c(s_names, log_names) %in% colnames(M))) {
          obs_s <- M[, s_names, drop = FALSE]
          exp_s <- exp(M[, log_names, drop = FALSE])
          if (max(abs(obs_s - exp_s) / pmax(1, abs(obs_s))) > 1e-6) {
            stop(
              "Saved `component_slopes` draws disagree with `exp(log_component_slopes)`; regenerate `posterior-draws.rds`.",
              call. = FALSE
            )
          }
        }
      }
    }
    checked_families <<- c(checked_families, qty)
  }

  n_c <- length(specs)
  c_ids <- paste0("contrast[", seq_len(n_c), "]")
  c_draws <- array(NA_real_, dim = c(n_iter, n_chain, n_c),
                   dimnames = list(NULL, NULL, c_ids))
  rows_out <- vector("list", n_c)

  for (k in seq_len(n_c)) {
    sp <- specs[[k]]
    w <- sp$weights
    p_rows <- p[match(names(w), p$variable), , drop = FALSE]
    if (anyNA(p_rows$variable) || any(p_rows$role != "reported_parameter")) {
      stop("Contrasts may only reference mapped `reported_parameter` variables.", call. = FALSE)
    }
    qtys <- unique(p_rows$quantity)
    if (length(qtys) != 1L) {
      stop(
        "Contrast '", sp$label, "' mixes incompatible parameter quantities (",
        paste(qtys, collapse = ", "), ").",
        call. = FALSE
      )
    }
    qty <- qtys[1L]
    if (qty %in% c("population_mean", "population_sd")) {
      stop("Contrasts are defined across multi-element families, not scalar population summaries.", call. = FALSE)
    }
    dirs <- unique(p_rows$direction)
    if (length(dirs) != 1L) {
      stop(
        "Contrast '", sp$label, "' combines parameters with opposite score directions; ",
        "keep contrasts within compatible facet sign conventions.",
        call. = FALSE
      )
    }
    if (qty %in% c("slope", "log_slope") && length(unique(p_rows$facet)) > 1L) {
      stop(
        "Slope contrasts must remain within a single slope owner so distinct identification scales are not mixed.",
        call. = FALSE
      )
    }
    ensure_family_subspace(qty)

    role_info <- .mfrm_contrast_algebraic_role(x, qty, p_rows, w, sp$scale)
    if (identical(sp$scale, "ratio")) {
      i_num <- names(w)[which(w > 0)]
      i_den <- names(w)[which(w < 0)]
      vec <- M[, i_num] / M[, i_den]
      ref_zero <- 1
    } else {
      vec <- drop(M[, names(w), drop = FALSE] %*% unname(w))
      ref_zero <- 0
    }
    mat <- matrix(vec, nrow = n_iter, ncol = n_chain)
    c_draws[, , k] <- mat

    is_fixed <- role_info$value_role %in% c("fixed_anchor", "fixed_by_constraint")
    if (is_fixed) {
      fv <- role_info$fixed_value
      if (any(abs(vec - fv) > 1e-7 * max(1, abs(fv)))) {
        stop(
          "Contrast '", sp$label, "' disagrees with its algebraic constraint value; regenerate `posterior-draws.rds`.",
          call. = FALSE
        )
      }
      mean_v <- median_v <- fv
      sd_v <- low_v <- high_v <- pgt <- plt <- rhat_v <- ess_b <- ess_t <- mcse_l <- mcse_u <- mcse_frac <- NA_real_
      int_comp <- FALSE
      sr <- x$decision$Status
      ist <- "fixed_value_no_interval"
    } else {
      fv <- NA_real_
      mean_v <- base::mean(vec)
      median_v <- stats::median(vec)
      sd_v <- stats::sd(vec)
      qs <- stats::quantile(vec, probs = c(alpha_low, alpha_high), names = FALSE)
      low_v <- qs[1L]
      high_v <- qs[2L]
      pgt <- base::mean(vec > ref_zero)
      plt <- base::mean(vec < ref_zero)
      rhat_v <- helpers$mfrm_draws_rhat(mat)
      ess_b <- helpers$mfrm_draws_ess_bulk(mat)
      ess_t <- helpers$mfrm_draws_ess_tail(mat)
      mcse_l <- helpers$mfrm_draws_mcse_quantile(mat, alpha_low)
      mcse_u <- helpers$mfrm_draws_mcse_quantile(mat, alpha_high)
      width <- high_v - low_v
      mcse_frac <- if (is.finite(width) & width > 0) max(mcse_l, mcse_u) / width else NA_real_
      int_comp <- is.finite(low_v) && is.finite(high_v)
      row_flag <- global_flag || is.na(rhat_v) || rhat_v >= 1.01 ||
        is.na(ess_b) || ess_b < 100 * x$chains ||
        is.na(ess_t) || ess_t < 100 * x$chains
      sr <- if (row_flag) "sampling_review_required" else "no_sampling_flags_detected"
      ist <- if (!int_comp) {
        "unavailable"
      } else if (row_flag) {
        "computed_sampling_review_required"
      } else {
        "computed_model_review_required"
      }
    }

    facets_u <- unique(p_rows$facet)
    facet_lbl <- if (length(facets_u) == 1L) facets_u else paste(facets_u, collapse = " / ")
    anchored_rows <- p_rows[p_rows$value_role == "fixed_anchor", , drop = FALSE]
    metric_lbl <- if (!is.null(x$population)) {
      "native relative-slope metric"
    } else {
      "fixed N(0,1) ability scale"
    }
    ref_txt <- paste0(
      if (identical(sp$scale, "ratio")) {
        "Shared-calibration posterior slope ratio (reference = 1; "
      } else {
        "Shared-calibration posterior linear contrast (reference = 0; "
      },
      metric_lbl, ").",
      if (nrow(anchored_rows) > 0L) {
        paste0(
          " Conditional on fixed anchor(s): ",
          paste(paste0(anchored_rows$facet, ": ", anchored_rows$level), collapse = ", "),
          "; external anchor uncertainty is not propagated."
        )
      } else {
        ""
      }
    )
    dir_txt <- if (identical(sp$scale, "ratio")) {
      "Values > 1 indicate a steeper response relationship for lhs than rhs (not rater severity)."
    } else if (grepl("lower coded scores", dirs[1L], fixed = TRUE)) {
      "Higher contrast values indicate greater severity/difficulty (lower expected coded scores for positive weights)."
    } else if (grepl("higher coded scores", dirs[1L], fixed = TRUE)) {
      "Higher contrast values indicate higher ability or positive-facet location (higher expected coded scores for positive weights)."
    } else if (identical(qty, "step_offset")) {
      "For (higher transition - lower transition), positive values indicate ordered adjacent step offsets on that draw."
    } else {
      dirs[1L]
    }

    rows_out[[k]] <- data.frame(
      contrast_id = c_ids[k],
      label = sp$label,
      quantity = qty,
      facet = facet_lbl,
      lhs = sp$lhs,
      rhs = sp$rhs,
      scale = sp$scale,
      value_role = role_info$value_role,
      mean = mean_v,
      median = median_v,
      sd = sd_v,
      lower = low_v,
      upper = high_v,
      prob_gt_zero = pgt,
      prob_lt_zero = plt,
      rhat = rhat_v,
      ess_bulk = ess_b,
      ess_tail = ess_t,
      mcse_lower = mcse_l,
      mcse_upper = mcse_u,
      endpoint_mcse_fraction = mcse_frac,
      credible_level = level,
      interval_computed = int_comp,
      sampling_review = sr,
      interval_status = ist,
      fixed_value = fv,
      reference = ref_txt,
      direction = dir_txt,
      stringsAsFactors = FALSE
    )
  }

  ct_df <- do.call(rbind, rows_out)
  rownames(ct_df) <- NULL
  list(
    contrasts = ct_df,
    contrast_draws = list(
      array = c_draws,
      specs = specs,
      level = level
    )
  )
}

.mfrm_posterior_draws_long <- function(x, kind = c("draws", "contrast_draws")) {
  kind <- match.arg(kind)
  if (is.null(x$draws)) {
    stop(
      "Extracting long-format posterior draws requires joint draws (`posterior-draws.rds`).",
      call. = FALSE
    )
  }
  if (identical(kind, "draws")) {
    arr <- x$draws$array
    p <- x$parameters
    n_iter <- dim(arr)[1L]
    n_chain <- dim(arr)[2L]
    n_var <- dim(arr)[3L]
    n_per_var <- n_iter * n_chain
    draw_idx <- seq_len(n_per_var)
    iter_idx <- rep(seq_len(n_iter), times = n_chain)
    chain_idx <- rep(seq_len(n_chain), each = n_iter)
    return(data.frame(
      draw = rep(draw_idx, times = n_var),
      chain = rep(chain_idx, times = n_var),
      iteration = rep(iter_idx, times = n_var),
      variable = rep(p$variable, each = n_per_var),
      quantity = rep(p$quantity, each = n_per_var),
      facet = rep(p$facet, each = n_per_var),
      level = rep(p$level, each = n_per_var),
      transition = rep(p$transition, each = n_per_var),
      value_role = rep(p$value_role, each = n_per_var),
      role = rep(p$role, each = n_per_var),
      value = as.numeric(arr),
      stringsAsFactors = FALSE
    ))
  }
  if (is.null(x$contrasts) || is.null(x$contrast_draws)) {
    stop("No posterior contrasts are attached; supply `contrasts` or call `summary(x, contrasts = ...)` first.", call. = FALSE)
  }
  arr <- x$contrast_draws$array
  ct <- x$contrasts
  n_iter <- dim(arr)[1L]
  n_chain <- dim(arr)[2L]
  n_c <- dim(arr)[3L]
  n_per_c <- n_iter * n_chain
  draw_idx <- seq_len(n_per_c)
  iter_idx <- rep(seq_len(n_iter), times = n_chain)
  chain_idx <- rep(seq_len(n_chain), each = n_iter)
  data.frame(
    draw = rep(draw_idx, times = n_c),
    chain = rep(chain_idx, times = n_c),
    iteration = rep(iter_idx, times = n_c),
    contrast_id = rep(ct$contrast_id, each = n_per_c),
    label = rep(ct$label, each = n_per_c),
    quantity = rep(ct$quantity, each = n_per_c),
    facet = rep(ct$facet, each = n_per_c),
    lhs = rep(ct$lhs, each = n_per_c),
    rhs = rep(ct$rhs, each = n_per_c),
    scale = rep(ct$scale, each = n_per_c),
    value_role = rep(ct$value_role, each = n_per_c),
    value = as.numeric(arr),
    stringsAsFactors = FALSE
  )
}
