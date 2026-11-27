.mfrm_design_grid <- function(grid, facets) {
  if (!is.data.frame(grid) || !nrow(grid) || anyDuplicated(names(grid)) ||
      !setequal(names(grid), facets) ||
      any(!vapply(grid, function(x) is.numeric(x) && all(is.finite(x) & x > 0 & x == floor(x)), logical(1)))) {
    stop("The D-Study grid must contain one positive integer count per facet and at least one row.", call. = FALSE)
  }
  grid[facets]
}

.mfrm_gstudy_metrics <- function(universe, relative, absolute) {
  status <- function(error) {
    if (!all(is.finite(c(universe, error)))) return("Nonfinite variance")
    if (universe < 0) return("Negative universe variance")
    if (error < 0) return("Negative projected error variance")
    if (universe + error == 0) return("Zero total variance")
    "Available"
  }
  gs <- status(relative); ps <- status(absolute)
  data.frame(UniverseVar = universe, RelErrorVar = relative, AbsErrorVar = absolute,
    RelSEM = if (is.finite(relative) && relative >= 0) sqrt(relative) else NA_real_,
    AbsSEM = if (is.finite(absolute) && absolute >= 0) sqrt(absolute) else NA_real_,
    G = if (gs == "Available") universe / (universe + relative) else NA_real_,
    Phi = if (ps == "Available") universe / (universe + absolute) else NA_real_,
    GStatus = gs, PhiStatus = ps)
}

.mfrm_refresh_gstudy <- function(x) {
  # Recompute observed harmonic denominators and coefficients from saved variance components.
  refresh_rows <- function(d) {
    z <- do.call(rbind, lapply(seq_len(nrow(d)), function(i)
      .mfrm_gstudy_metrics(d$UniverseVar[i], d$RelErrorVar[i], d$AbsErrorVar[i])))
    d[names(z)] <- z
    d
  }
  if (identical(x$method_code, "urgenova")) {
    vc <- x$variance_components
    req_cols <- unique(c(x$person, x$facets, x$scores))
    obs_des <- NULL
    if (is.data.frame(x$data) && all(req_cols %in% names(x$data))) {
      obs_des <- tryCatch(
        .mfrm_henderson_obs_design(x$data, x$person, x$facets, x$scores, x$nesting),
        error = function(e) NULL
      )
      if (!is.null(obs_des) && (!identical(as.integer(obs_des$n_obs), as.integer(x$n_obs)) ||
          !identical(as.integer(obs_des$n_components), nrow(vc)))) {
        obs_des <- NULL
      }
    }
    if (!is.null(obs_des)) {
      x$has_replicates <- obs_des$has_replicates
      x$obs_n_per_facet <- obs_des$obs_n_per_facet
      x$obs_n_total_per_person <- obs_des$obs_n_total_per_person
      x$obs_component_scales <- stats::setNames(obs_des$obs_component_scales, vc$Component)
      x$obs_component_denoms <- stats::setNames(obs_des$obs_component_denoms, vc$Component)
      x$obs_scale_version <- 2L
      x$obs_denominators_unavailable <- FALSE
    } else {
      has_rep <- .mfrm_henderson_has_replicates(x)
      x$has_replicates <- has_rep
      if (identical(x$obs_scale_version, 2L) && !is.null(x$obs_component_scales) &&
          !is.null(x$obs_component_denoms) && length(x$obs_component_scales) == nrow(vc)) {
        x$obs_denominators_unavailable <- FALSE
      } else if (length(x$nesting) > 0L || has_rep || is.null(x$obs_n_per_facet) || length(x$facets) > 1L) {
        x$obs_denominators_unavailable <- TRUE
      } else {
        x$obs_denominators_unavailable <- FALSE
      }
    }

    if (isTRUE(x$obs_denominators_unavailable)) {
      unavail_msg <- "Observed denominators unavailable; rerun mfrm_g_study()"
      for (fc in x$facets) {
        h_col <- paste0("Harmonic_", fc)
        if (h_col %in% names(x$g_study_summary)) x$g_study_summary[[h_col]] <- NA_real_
      }
      z_na <- .mfrm_gstudy_metrics(vc$Estimate[1L], NA_real_, NA_real_)
      z_na$GStatus <- unavail_msg
      z_na$PhiStatus <- unavail_msg
      x$g_study_summary[names(z_na)] <- z_na
      if (!is.null(x$univariate) && nrow(x$univariate) > 0L) {
        for (i in seq_len(nrow(x$univariate))) {
          zi <- .mfrm_gstudy_metrics(x$univariate$UniverseVar[i], NA_real_, NA_real_)
          zi$GStatus <- unavail_msg
          zi$PhiStatus <- unavail_msg
          x$univariate[i, names(zi)] <- zi
        }
      }
    } else {
      scales <- .mfrm_henderson_obs_scales(x)
      eval_v <- function(v_vec) {
        sp <- v_vec[1L]
        s_rel <- sum(v_vec[-1L][vc$ContainsPerson[-1L]] * scales[-1L][vc$ContainsPerson[-1L]])
        s_abs <- sum(v_vec[-1L] * scales[-1L])
        .mfrm_gstudy_metrics(sp, s_rel, s_abs)
      }
      for (fc in x$facets) {
        h_col <- paste0("Harmonic_", fc)
        x$g_study_summary[[h_col]] <- unname(x$obs_n_per_facet[[fc]])
      }
      z_obs <- eval_v(vc$Estimate)
      x$g_study_summary[names(z_obs)] <- z_obs
      if (!is.null(x$vcov_components) && length(x$scores) > 1L) {
        u_rows <- lapply(seq_along(x$scores), function(p_i) {
          sc_nm <- x$scores[p_i]
          v_p <- vapply(x$vcov_components, function(S) S[p_i, p_i], numeric(1))
          if (isTRUE(x$truncate_negative)) v_p <- pmax(0, v_p)
          cbind(data.frame(Score = sc_nm, Weight = unname(x$weights[p_i]), stringsAsFactors = FALSE), eval_v(v_p))
        })
        x$univariate <- do.call(rbind, u_rows)
        rownames(x$univariate) <- NULL
      } else if (!is.null(x$univariate)) {
        x$univariate <- refresh_rows(x$univariate)
      }
    }
    if (is.data.frame(x$d_study) && nrow(x$d_study) > 0L) {
      x$d_study <- mfrm_d_study(x, x$d_study[x$facets])
    }
    return(x)
  }
  x$g_study_summary <- refresh_rows(x$g_study_summary)
  if (!is.null(x$univariate)) x$univariate <- refresh_rows(x$univariate)
  if (is.data.frame(x$d_study) && nrow(x$d_study) > 0L) {
    x$d_study <- mfrm_d_study(x, x$d_study[x$facets])
  }
  x
}

.mfrm_screen_table <- function(table, readiness, columns) {
  table$InferenceStatus <- rep(readiness$status, nrow(table))
  table$InferenceReason <- rep(paste(readiness$reason_codes, collapse = "; "), nrow(table))
  if (!isTRUE(readiness$ready)) for (nm in intersect(columns, names(table))) table[[nm]][] <- NA
  if (isTRUE(readiness$ready) && "pValue" %in% names(table)) {
    unavailable <- !is.finite(table$pValue)
    table$InferenceStatus[unavailable] <- "review_required"
    table$InferenceReason[unavailable] <- "test_statistic_unavailable"
  }
  table
}

.mfrm_diagnostic_data <- function(enc, data) {
  cols <- unique(c(enc$person_col, enc$base_facets, enc$score_col, enc$weight_col))
  if (!is.data.frame(data) || !all(cols %in% names(data)) || nrow(data) != enc$n_obs)
    stop("Diagnostic `data` must contain exactly the retained calibration ratings and weights.", call. = FALSE)
  keys <- function(d) {
    d <- as.data.frame(d[cols], stringsAsFactors = FALSE)
    for (nm in c(enc$person_col, enc$base_facets)) d[[nm]] <- as.character(d[[nm]])
    for (nm in c(enc$score_col, enc$weight_col)) d[[nm]] <- as.numeric(d[[nm]])
    rownames(d) <- NULL
    d
  }
  old <- keys(enc$retained_data); new <- keys(data)
  oi <- do.call(order, unname(as.list(old))); ni <- do.call(order, unname(as.list(new)))
  a <- as.data.frame(old[oi, , drop = FALSE], stringsAsFactors = FALSE)
  b <- as.data.frame(new[ni, , drop = FALSE], stringsAsFactors = FALSE)
  rownames(a) <- rownames(b) <- NULL
  if (!identical(a, b)) stop("Diagnostic `data` must match the retained calibration ratings and weights.", call. = FALSE)
  data <- data[ni[order(oi)], , drop = FALSE]
  rownames(data) <- NULL
  data
}

.mfrm_add_interaction <- function(enc, pair) {
  # Keep the complete encoded likelihood; append only the zero-margin interaction.
  if (any(vapply(enc$interaction_meta, function(im) setequal(c(im$facet_a, im$facet_b), pair), logical(1))))
    stop("This interaction is already in the source model.", call. = FALSE)
  fa <- match(pair[1L], enc$base_facets); fb <- match(pair[2L], enc$base_facets)
  La <- enc$facet_n_levels[fa]; Lb <- enc$facet_n_levels[fb]
  if (min(La, Lb) < 2L) stop("Both interaction facets need at least two levels.", call. = FALSE)
  nm <- paste(pair, collapse = ":")
  if (nm %in% enc$facets) stop("The interaction name conflicts with an existing facet.", call. = FALSE)
  B <- kronecker(rbind(diag(La - 1L), -1), rbind(diag(Lb - 1L), -1))
  levels <- as.vector(t(outer(enc$facet_levels[[fa]], enc$facet_levels[[fb]], paste, sep = ":")))
  idx <- length(enc$facets) + 1L
  enc$facets <- c(enc$facets, nm)
  enc$facet_levels[[nm]] <- levels
  enc$facet_n_levels <- c(enc$facet_n_levels, as.integer(La * Lb))
  enc$facet_mat0 <- cbind(enc$facet_mat0, as.integer(enc$facet_mat0[, fa] * Lb + enc$facet_mat0[, fb]))
  enc$facet_signs <- c(enc$facet_signs, enc$facet_signs[fa])
  for (key in c("facet_dummy", "facet_noncenter")) enc[[key]] <- c(enc[[key]], 0L)
  enc$has_custom_facet_map <- c(enc$has_custom_facet_map, 1L)
  enc$custom_facet_q <- c(enc$custom_facet_q, ncol(B))
  for (key in c("anchor_fixed", "custom_facet_anchored")) enc[[key]][[idx]] <- integer(La * Lb)
  for (key in c("anchor_val", "custom_facet_d0")) enc[[key]][[idx]] <- numeric(La * Lb)
  enc$custom_facet_B[[idx]] <- B
  enc$interaction_meta[[nm]] <- list(name = nm, facet_a = pair[1L], facet_b = pair[2L],
    facet_idx = idx, levels_a = rep(enc$facet_levels[[fa]], each = Lb),
    levels_b = rep(enc$facet_levels[[fb]], times = La), cell_levels = levels, q = ncol(B), B = B)
  enc
}

.mfrm_gstudy_covariance <- function(groups, variance, inverse, block = 64L) {
  # A_s = Z_s diag(1/n_s) Z_s' - 11'/N; Cov(q_s,q_t) = 2 tr(A_s V A_t V).
  # Sparse cross-tabulations and blocks avoid retaining an N by N dense matrix.
  N <- length(groups[[1L]])
  k <- length(groups)
  sizes <- lapply(groups, tabulate)
  Z <- lapply(groups, function(g) Matrix::sparseMatrix(i = seq_len(N), j = g, x = 1))
  counts <- lapply(seq_len(k), function(s) lapply(seq_len(k), function(u) Matrix::crossprod(Z[[s]], Z[[u]])))
  covariance <- matrix(0, k, k)
  for (start in seq.int(1L, N, by = block)) {
    idx <- seq.int(start, min(N, start + block - 1L))
    left <- right <- vector("list", k)
    for (s in seq_len(k)) {
      gs <- groups[[s]]
      L <- R <- matrix(0, N, length(idx))
      for (u in which(variance > 0)) {
        gu <- groups[[u]]
        cu <- counts[[s]][[u]]
        l <- as.matrix(cu[gs, gu[idx], drop = FALSE]) / sizes[[s]][gs]
        l <- sweep(l, 2L, sizes[[u]][gu[idx]] / N, "-")
        r <- t(as.matrix(cu[gs[idx], gu, drop = FALSE]) / sizes[[s]][gs[idx]])
        r <- r - sizes[[u]][gu] / N
        L <- L + variance[u] * l
        R <- R + variance[u] * r
      }
      left[[s]] <- as.vector(L)
      right[[s]] <- as.vector(R)
    }
    covariance <- covariance + 2 * crossprod(do.call(cbind, left), do.call(cbind, right))
  }
  out <- inverse %*% covariance %*% t(inverse)
  (out + t(out)) / 2
}

.mfrm_conditional_location_rank <- function(fit) {
  # Hold slopes and thresholds fixed. Project the exact facet-location design
  # off person contrasts, respecting anchors and custom facet constraints.
  # Fix the common person origin: a population mean used only to choose an
  # origin is not the same as linking distinct panels by distribution assumptions.
  enc <- fit$encoding
  alpha <- fit$alpha_obs
  design <- do.call(cbind, lapply(seq_along(enc$facets), function(f) {
    basis <- .mfrm_facet_basis(enc, f)
    enc$facet_signs[f] * basis[enc$facet_mat0[, f] + 1L, , drop = FALSE]
  }))
  if (!ncol(design)) return(list(rank = 0L, columns = 0L))
  if (!identical(enc$slope_formula, 1L)) design <- alpha * design
  person <- enc$person0 + 1L
  numerator <- rowsum(alpha * design, person, reorder = FALSE)
  denominator <- rowsum(alpha^2, person, reorder = FALSE)[, 1L]
  coefficients <- numerator / denominator
  projected <- design - alpha * coefficients[match(person, as.integer(rownames(coefficients))), , drop = FALSE]
  projected <- rbind(projected, colMeans(coefficients) * sqrt(nrow(design)))
  singular <- svd(projected, nu = 0L, nv = 0L)$d
  list(rank = sum(singular > 1e-10 * max(1, sqrt(sum(design^2)))), columns = ncol(design))
}

.mfrm_readiness <- function(fit) {
  .mfrm_validate_fit(fit)
  reasons <- character()
  if (!is.null(fit$quadrature_check) && !isTRUE(fit$quadrature_check$stable))
    reasons <- c(reasons, "quadrature_sensitivity_not_stable")
  weights <- fit$encoding$weight
  if (any(!is.finite(weights) | weights != 1))
    reasons <- c(reasons, "nonunit_observation_weights_inference_unvalidated")
  conditional_rank <- fit$conditional_location_rank %||% .mfrm_conditional_location_rank(fit)
  if (conditional_rank$rank < conditional_rank$columns)
    reasons <- c(reasons, if (identical(fit$method, "MML")) "population_assumption_linked" else
      "conditional_location_rank_deficient")
  if (!isTRUE(fit$converged)) reasons <- c(reasons, "optimizer_not_converged")
  if (!isTRUE(fit$connectivity$connected)) reasons <- c(reasons, "disconnected_design")
  score_col <- fit$encoding$score_col
  if (!is.null(score_col) && is.factor(fit$encoding$retained_data[[score_col]])) {
    reasons <- c(reasons, "factor_score_input")
  }
  if (identical(fit$method, "MML")) {
    rank_check <- if ("population_location_rank" %in% names(fit)) fit$population_location_rank else
      .mfrm_population_location_rank(fit$encoding)
    if (!is.null(rank_check) && rank_check$rank < rank_check$columns) {
      reasons <- c(reasons, "population_location_rank_deficient")
    }
  }
  V <- fit$xi_covariance_model
  if (length(V) && (any(!is.finite(V)) ||
      inherits(try(chol(V), silent = TRUE), "try-error"))) {
    reasons <- c(reasons, "structural_information_unavailable")
  }
  if (!is.finite(fit$loglik) || any(!is.finite(fit$xi))) reasons <- c(reasons, "nonfinite_calibration")
  boundary <- fit$boundary_audit
  needs_boundary_recheck <- is.null(boundary) ||
    (fit$method %in% c("CML", "JML", "MML") && identical(boundary$status, "not_applicable")) ||
    (identical(fit$method, "MML") && identical(fit$encoding$pop_mode, 1L) && !identical(boundary$audit_version, 2L))
  if (needs_boundary_recheck)
    boundary <- .mfrm_structural_boundary(fit)
  if (isTRUE(boundary$detected)) reasons <- c(reasons, "structural_likelihood_boundary")
  if (boundary$status %in% c("not_checked_lpSolve_unavailable", "solver_unavailable", "information_unavailable"))
    reasons <- c(reasons, "structural_boundary_not_checked")
  step_audit <- fit$step_support_audit %||% .mfrm_step_support_audit(fit$encoding, fit$xi_layout)
  if (isTRUE(step_audit$step_rank_deficient))
    reasons <- c(reasons, "unobserved_step_category")
  list(ready = !length(reasons), status = if (length(reasons)) "review_required" else "ready", reason_codes = reasons)
}

.mfrm_step_support_audit <- function(enc, lay = NULL) {
  if (is.null(enc)) {
    return(list(all_categories_observed = TRUE, step_rank_deficient = FALSE,
                unidentified_step = logical(0), unidentified_group = logical(0),
                unobserved_by_group = list()))
  }
  lay <- lay %||% .mfrm_compute_xi_layout(enc)
  G <- enc$n_step_groups
  K <- enc$n_cat - 1L
  qs <- lay$step_len
  SB <- .mfrm_step_basis(enc, lay)
  pos <- which(is.finite(enc$weight) & enc$weight > 0)
  sg_pos <- enc$step_group0[pos] + 1L
  y_pos <- enc$score0[pos]

  obs_cats <- vector("list", G)
  unobs_cats <- vector("list", G)
  group_active <- logical(G)
  for (g in seq_len(G)) {
    ag <- enc$step_cat_min[g]
    bg <- enc$step_cat_max[g]
    yg <- y_pos[sg_pos == g]
    group_active[g] <- length(yg) > 0L
    u_obs <- sort(unique(yg[yg >= ag & yg <= bg]))
    obs_cats[[g]] <- u_obs
    unobs_cats[[g]] <- setdiff(seq.int(ag, bg), u_obs)
  }
  names(unobs_cats) <- enc$step_owners
  all_obs <- all(group_active) && all(lengths(unobs_cats) == 0L)
  if (all_obs) {
    return(list(
      all_categories_observed = TRUE,
      step_rank_deficient = FALSE,
      unidentified_step = rep(FALSE, G * K),
      unidentified_group = rep(FALSE, G),
      unobserved_by_group = unobs_cats
    ))
  }

  # Cross-check observed within-group category contrasts against step_constraints / category_support
  rows_A <- list()
  for (g in seq_len(G)) {
    oc <- obs_cats[[g]]
    if (length(oc) < 2L) next
    ag <- enc$step_cat_min[g]
    bg <- enc$step_cat_max[g]
    cum_g <- matrix(0.0, K + 1L, qs)
    if (qs > 0L && bg > ag) {
      for (k in seq.int(ag + 1L, bg)) {
        cum_g[k + 1L, ] <- cum_g[k, ] + SB[(g - 1L) * K + k, ]
      }
    }
    k0 <- oc[1L]
    ks <- oc[-1L]
    blk <- matrix(0.0, length(ks), G + qs)
    blk[, g] <- as.double(ks - k0)
    if (qs > 0L) {
      blk[, G + seq_len(qs)] <- -sweep(cum_g[ks + 1L, , drop = FALSE], 2L, cum_g[k0 + 1L, ], "-")
    }
    rows_A[[length(rows_A) + 1L]] <- blk
  }
  n_col <- G + qs
  if (length(rows_A) == 0L) {
    V_null <- diag(1.0, n_col)
  } else {
    A <- do.call(rbind, rows_A)
    sv <- svd(A, nu = 0L, nv = n_col)
    tol <- 1e-10 * max(1.0, sv$d[1L])
    rnk <- sum(sv$d > tol)
    V_null <- if (rnk < n_col) sv$v[, (rnk + 1L):n_col, drop = FALSE] else matrix(0.0, n_col, 0L)
  }
  unid_group <- if (ncol(V_null) > 0L) rowSums(V_null[seq_len(G), , drop = FALSE]^2) > 1e-18 else rep(FALSE, G)
  unid_step <- rep(FALSE, G * K)
  if (qs > 0L && ncol(V_null) > 0L) {
    V_st <- V_null[G + seq_len(qs), , drop = FALSE]
    proj <- SB %*% V_st
    for (g in seq_len(G)) {
      ag <- enc$step_cat_min[g]
      bg <- enc$step_cat_max[g]
      if (bg > ag) {
        idx_g <- (g - 1L) * K + seq.int(ag + 1L, bg)
        unid_step[idx_g] <- rowSums(proj[idx_g, , drop = FALSE]^2) > 1e-18
      }
    }
  }
  list(
    all_categories_observed = FALSE,
    step_rank_deficient = ncol(V_null) > 0L,
    unidentified_step = unid_step,
    unidentified_group = unid_group,
    unobserved_by_group = unobs_cats
  )
}

.mfrm_screen_steps_table <- function(steps_df, enc, lay = NULL, step_audit = NULL) {
  if (is.null(steps_df) || nrow(steps_df) == 0L || is.null(enc)) return(steps_df)
  audit <- step_audit %||% .mfrm_step_support_audit(enc, lay)
  unid <- audit$unidentified_step
  if (length(unid) == nrow(steps_df)) {
    steps_df$Identified <- steps_df$Supported & !unid
    if (any(unid)) {
      for (col in intersect(c("Estimate", "ModelSE", "SandwichSE"), names(steps_df))) {
        steps_df[[col]][unid] <- NA_real_
      }
    }
  }
  steps_df
}

.mfrm_step_basis <- function(enc, layout) {
  if (isTRUE(enc$has_custom_step_map)) return(enc$custom_step_B)
  K <- enc$n_cat - 1L
  B <- matrix(0, enc$n_step_groups * K, layout$step_len)
  offset <- 0L
  for (g in seq_len(enc$n_step_groups)) {
    a <- enc$step_cat_min[g]
    b <- enc$step_cat_max[g]
    q <- b - a - 1L
    if (q > 0L) {
      B[cbind((g - 1L) * K + a + seq_len(q), offset + seq_len(q))] <- 1
      B[(g - 1L) * K + b, offset + seq_len(q)] <- -1
      offset <- offset + q
    }
  }
  B
}

.mfrm_same_likelihood_basis <- function(a, b) {
  if (!identical(a$method, b$method) || !a$method %in% c("MML", "CML")) return(FALSE)
  ea <- a$encoding; eb <- b$encoding
  if (!identical(ea$base_facets, eb$base_facets) ||
      !identical(ea$rating_min, eb$rating_min) || !identical(ea$rating_max, eb$rating_max)) return(FALSE)
  rows <- function(e) {
    facet_values <- lapply(seq_along(e$base_facets), function(f)
      e$facet_levels[[f]][e$facet_mat0[, f] + 1L])
    d <- c(list(e$person_levels[e$person0 + 1L]), facet_values,
      list(e$score0, e$weight, e$step_cat_min[e$step_group0 + 1L],
           e$step_cat_max[e$step_group0 + 1L]))
    order_rows <- do.call(order, d)
    lapply(d, function(column) unname(column[order_rows]))
  }
  controls <- c("quad_points", "adaptive_quad", "xtreme")
  identical(rows(ea), rows(eb)) && identical(a$control[controls], b$control[controls])
}

.mfrm_same_observations <- function(a, b) {
  if (!.mfrm_same_likelihood_basis(a, b)) return(FALSE)
  ea <- a$encoding; eb <- b$encoding
  # Interactions may add a model column, but the observed facets must agree.
  if (!identical(ea$facet_signs[seq_along(ea$base_facets)], eb$facet_signs[seq_along(eb$base_facets)])) return(FALSE)
  if (!identical(ea$pop_X_mat, eb$pop_X_mat) || !identical(ea$pop_col_names, eb$pop_col_names)) return(FALSE)
  if (ea$model_code == 1L && eb$model_code == 1L && !identical(ea$step_facet, eb$step_facet)) return(FALSE)
  if (a$method == "MML" && ea$pop_mode == 0L && eb$pop_mode == 0L && !identical(ea$fixed_sigma, eb$fixed_sigma)) return(FALSE)
  if (ea$n_slope_facets > 0L && eb$n_slope_facets > 0L && ea$slope_formula != eb$slope_formula) return(FALSE)
  TRUE
}

.mfrm_prediction_gradient <- function(fit, newdata, ev, theta, base_eta, sg0, alpha, type, facet_data, pop_X_new = NULL) {
  enc <- fit$encoding; lay <- fit$xi_layout
  n <- length(theta); K <- enc$n_cat - 1L
  alpha <- alpha %||% rep(1, n)
  full <- enc$slope_formula == 0L
  G <- matrix(0, n, length(fit$xi))
  indices <- lapply(seq_along(enc$facets), function(f) {
    if (is.null(newdata)) return(enc$facet_mat0[, f] + 1L)
    if (f <= length(enc$base_facets)) return(match(as.character(newdata[[enc$facets[f]]]), enc$facet_levels[[f]]))
    im <- enc$interaction_meta[[enc$facets[f]]]
    ia <- match(im$facet_a, enc$base_facets); ib <- match(im$facet_b, enc$base_facets)
    (match(as.character(newdata[[im$facet_a]]), enc$facet_levels[[ia]]) - 1L) * enc$facet_n_levels[ib] +
      match(as.character(newdata[[im$facet_b]]), enc$facet_levels[[ib]])
  })
  multiplier <- if (type == "link") rep(1, n) else ev$variance * if (full) alpha else 1
  for (f in which(lay$facet_len > 0L)) {
    B <- .mfrm_facet_basis(enc, f)[indices[[f]], , drop = FALSE]
    if (anyNA(indices[[f]])) {
      fnm <- enc$facets[f]; em <- enc$explanatory_meta[[fnm]]
      ii <- which(is.na(indices[[f]]))
      B[ii, ] <- .mfrm_facet_predict_matrix(em, facet_data, fnm, as.character(newdata[[fnm]][ii]))
    }
    G[, lay$facet_start[f] + seq_len(lay$facet_len[f])] <- B * (enc$facet_signs[f] * multiplier)
  }
  if (!is.null(pop_X_new) && ncol(pop_X_new) > 0L && ncol(G) >= lay$n_xi + ncol(pop_X_new)) {
    pop_mult <- if (type == "link") rep(1, n) else alpha * ev$variance
    G[, lay$n_xi + seq_len(ncol(pop_X_new))] <- pop_X_new * pop_mult
  }
  if (type == "link") return(G)
  centered <- sweep(matrix(rep(0:K, each = n), n, K + 1L), 1L, ev$expected - enc$rating_min, "-")
  weighted <- ev$probs * centered
  step_B <- .mfrm_step_basis(enc, lay)
  if (lay$step_len > 0L) {
    for (g in unique(sg0 + 1L)) {
      ii <- which(sg0 + 1L == g)
      tail_cov <- vapply(seq_len(K), function(j) rowSums(weighted[ii, (j + 1L):(K + 1L), drop = FALSE]), numeric(length(ii)))
      tail_cov <- matrix(tail_cov, nrow = length(ii), ncol = K)
      G[ii, lay$step_start + seq_len(lay$step_len)] <-
        -(tail_cov %*% step_B[(g - 1L) * K + seq_len(K), , drop = FALSE]) * if (full) alpha[ii] else 1
    }
  }
  if (lay$slope_len > 0L) {
    slope_derivative <- if (full) {
      cumulative <- fit$step_cumulative[sg0 + 1L, , drop = FALSE]
      cumulative[!is.finite(cumulative)] <- 0
      alpha * ((theta + base_eta) * ev$variance - rowSums(weighted * cumulative))
    } else alpha * theta * ev$variance
    for (s in which(enc$slope_q > 0L)) {
      f <- enc$slope_facets0[s] + 1L
      if (anyNA(indices[[f]])) stop("Prediction SE requires known slope-facet levels.", call. = FALSE)
      G[, lay$slope_offset[s] + seq_len(enc$slope_q[s])] <- enc$slope_B[[s]][indices[[f]], , drop = FALSE] * slope_derivative
    }
  }
  G
}

.mfrm_structural_boundary <- function(fit) {
  if (identical(fit$method, "CML")) return(.mfrm_cml_boundary(fit))
  enc <- fit$encoding; lay <- fit$xi_layout
  result <- list(detected = FALSE, status = "not_applicable", audit_version = 2L)
  if (!fit$method %in% c("MML", "JML") || !fit$model %in% c("RSM", "PCM", "GPCM")) return(result)
  use_facets <- !isTRUE(fit$control$facet_l2_pen > 0)
  f_cols <- if (use_facets) sum(lay$facet_len) else 0L
  s_cols <- lay$step_len
  pop_mat <- if (identical(fit$method, "MML") && identical(enc$pop_mode, 1L) && ncol(enc$pop_X_mat) > 0L) {
    enc$pop_X_mat[enc$person0 + 1L, , drop = FALSE]
  } else if (identical(fit$method, "JML") && use_facets) {
    matrix(1.0, enc$n_obs, 1L)
  } else {
    matrix(0.0, enc$n_obs, 0L)
  }
  if (identical(fit$model, "GPCM") && identical(enc$slope_formula, 1L) && ncol(pop_mat) > 0L) {
    pop_mat <- pop_mat * fit$alpha_obs
  }
  q <- f_cols + s_cols + ncol(pop_mat)
  if (!q) return(result)
  K <- enc$n_cat - 1L
  B <- matrix(0.0, enc$n_obs, q)
  if (use_facets) {
    for (f in which(lay$facet_len > 0L))
      B[, lay$facet_start[f] + seq_len(lay$facet_len[f])] <- enc$facet_signs[f] * .mfrm_facet_basis(enc, f)[enc$facet_mat0[, f] + 1L, , drop = FALSE]
  }
  if (ncol(pop_mat) > 0L) {
    B[, f_cols + s_cols + seq_len(ncol(pop_mat))] <- pop_mat
  }
  SB <- .mfrm_step_basis(enc, lay)
  D <- lapply(0:K, function(k) {
    ii <- which(enc$weight > 0 & k >= enc$step_cat_min[enc$step_group0 + 1L] & k <= enc$step_cat_max[enc$step_group0 + 1L] & k != enc$score0)
    if (!length(ii)) return(matrix(0.0, 0L, q))
    z <- B[ii, , drop = FALSE] * (enc$score0[ii] - k)
    if (s_cols > 0L) for (g in unique(enc$step_group0[ii] + 1L)) {
      jj <- which(enc$step_group0[ii] + 1L == g)
      cum <- rbind(0, matrix(apply(SB[(g - 1L) * K + seq_len(K), , drop = FALSE], 2L, cumsum), K, s_cols))
      z[jj, f_cols + seq_len(s_cols)] <- sweep(-cum[enc$score0[ii[jj]] + 1L, , drop = FALSE], 2L, cum[k + 1L, ], "+")
    }
    z
  })
  D <- unique(do.call(rbind, D))
  if (!nrow(D)) return(result)
  fit_lp <- lpSolve::lp("max", c(colSums(D), -colSums(D)), rbind(cbind(D, -D), diag(2L * q)),
                        c(rep(">=", nrow(D)), rep("<=", 2L * q)), c(rep(0, nrow(D)), rep(1, 2L * q)))
  result$status <- "not_detected_sufficient_test"
  if (fit_lp$status != 0L) {
    result$status <- "solver_unavailable"
  } else {
    direction <- fit_lp$solution[seq_len(q)] - fit_lp$solution[q + seq_len(q)]
    contrasts <- drop(D %*% direction)
    if (min(contrasts) >= -1e-8 && max(contrasts) > 1e-6 && sum(contrasts) > 1e-6) {
      result <- list(detected = TRUE, status = "no_finite_structural_mle", direction = direction,
                     min_contrast = min(contrasts), max_contrast = max(contrasts), audit_version = 2L)
    }
  }
  result
}
