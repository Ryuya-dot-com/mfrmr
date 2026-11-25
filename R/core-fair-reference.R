mfrm_fair_reference_fit <- function(fit) {
    if ((!inherits(fit, "mfrm_fit") && !mfrm_is_jeffreys_fit(fit)) || inherits(fit, "mfrm_imported_fit") || 
        mfrm_extended_fit(fit) || mfrm_has_jml_adjustment(fit) || !identical(fit$config$method, "JML") || 
        !fit$config$model %in% c("RSM", "PCM") || length(fit$config$interaction_specs) || !identical(fit$config$facet_shrinkage %||% 
        "none", "none")) 
        stop("Common-plan score intervals require native additive RSM/PCM ordinary or explicit Jeffreys JML without shrinkage.", 
            call. = FALSE)
}

mfrm_fair_reference_score_fit <- function(fit) {
    if (inherits(fit, "mfrm_fast_fit")) return(invisible(NULL))
    if ((!inherits(fit, "mfrm_fit") && !mfrm_is_jeffreys_fit(fit)) || inherits(fit, "mfrm_imported_fit") || 
        mfrm_extended_fit(fit) || mfrm_has_jml_adjustment(fit) || !isTRUE(fit$config$method %in% c("JML", 
        "MML")) || !isTRUE(fit$config$model %in% c("RSM", "PCM")) || length(fit$config$interaction_specs) || 
        !identical(fit$config$facet_shrinkage %||% "none", "none")) 
        stop("Common-plan scores require native additive RSM/PCM MML or ordinary/Jeffreys JML without shrinkage.", 
            call. = FALSE)
}

mfrm_fair_fit_identity <- function(fit) {
    if (!mfrm_is_jeffreys_fit(fit)) 
        return(prediction_fit_identity(fit))
    mfrm_checkpoint_fingerprint(list(estimator = fit$config$estimator, class = class(fit), config = fit$config, 
        prep = fit$prep, opt = fit$opt, facets = fit$facets, steps = fit$steps, probabilities = fit$probabilities), 
        canonical = TRUE)
}

mfrm_fair_reference_plan <- function(fit, plan) {
    mfrm_fair_reference_score_fit(fit)
    facets <- if (inherits(fit, "mfrm_fast_fit")) fit$encoding$base_facets else fit$config$facet_names
    levels <- if (inherits(fit, "mfrm_fast_fit")) stats::setNames(fit$encoding$facet_levels, fit$encoding$facets) else fit$config$facet_levels
    if ("Weight" %in% facets) 
        stop("The reference plan reserves the column name 'Weight'.", call. = FALSE)
    if (!is.data.frame(plan) || !nrow(plan) || anyDuplicated(names(plan)) || !setequal(setdiff(names(plan), 
        "Weight"), facets)) 
        stop("`reference_plan` must contain every fitted facet and optional Weight only.", call. = FALSE)
    out <- as.data.frame(plan[facets], stringsAsFactors = FALSE)
    for (f in facets) {
        x <- plan[[f]]
        if (!(is.character(x) || is.factor(x) || is.numeric(x)) || !is.null(dim(x)) || anyNA(x) || any(!as.character(x) %in% 
            levels[[f]])) 
            stop("Unknown or invalid reference-plan level in facet `", f, "`.", call. = FALSE)
        out[[f]] <- as.character(x)
    }
    if (anyDuplicated(out)) 
        stop("Use weights for duplicate reference-plan cells.", call. = FALSE)
    w <- plan$Weight %||% rep(1, nrow(out))
    if (!is.numeric(w) || !is.null(dim(w)) || any(!is.finite(w)) || any(w <= 0)) 
        stop("Reference-plan weights must be finite and positive.", call. = FALSE)
    out$Weight <- w
    out$NormalizedWeight <- (w/max(w))/sum(w/max(w))
    out
}

mfrm_fair_reference_kernel <- function(fit, plan, par = fit$opt$par) {
    cfg <- fit$config
    pa <- expand_params(par, build_param_sizes(cfg), cfg)
    idx <- list(score_k = rep(0L, nrow(plan)), facets = lapply(cfg$facet_names, function(f) match(plan[[f]], 
        cfg$facet_levels[[f]])), interactions = list())
    names(idx$facets) <- cfg$facet_names
    if (anyNA(unlist(idx$facets))) 
        stop("Reference plan contains unknown fitted levels.", call. = FALSE)
    offsets <- compute_base_eta(idx, pa, cfg)
    steps <- if (cfg$model == "RSM") 
        matrix(pa$steps, nrow(plan), cfg$n_cat - 1L, byrow = TRUE)
    else pa$steps_mat[idx$facets[[cfg$step_facet]], , drop = FALSE]
    cumulative <- t(vapply(seq_len(nrow(plan)), function(j) c(0, cumsum(steps[j, ])), numeric(cfg$n_cat)))
    list(offsets = offsets, cumulative = cumulative)
}

mfrm_fair_eval_plan_score <- function(theta_vec, kernel, weights, rating_min) {
    cat_vals <- seq_len(ncol(kernel$cumulative)) - 1L
    vapply(theta_vec, function(t) {
        if (is.na(t)) 
            return(NA_real_)
        if (is.infinite(t)) 
            return(if (t > 0) rating_min + max(cat_vals) else rating_min)
        pr <- mfrm_jml_probability_bundle(t + kernel$offsets, rep(0L, length(kernel$offsets)), "PCM", 
            kernel$cumulative, criterion_idx = seq_along(kernel$offsets))$probs
        sum(weights * drop(pr %*% cat_vals)) + rating_min
    }, 0)
}

mfrm_fair_reference_scores <- function(fit, plan) {
    if (inherits(fit, "mfrm_fast_fit")) {
        ready <- .mfrm_fast_readiness(fit)$ready
        score <- vapply(fit$person$Estimate, function(theta) {
            if (!ready || !is.finite(theta)) return(NA_real_)
            nd <- plan[fit$encoding$base_facets]
            nd$theta <- theta
            sum(plan$NormalizedWeight * predict(fit, nd, type = "response"))
        }, numeric(1))
        return(data.frame(Person = fit$person$Person, Estimate = score,
            Status = ifelse(is.finite(score), paste0(tolower(fit$score_method), "_plug_in_estimate"), "unavailable_calibration"),
            Target = "common_plan_expected_average", Units = "original_score", Uncertainty = "not_computed",
            stringsAsFactors = FALSE))
    }
    mfrm_fair_reference_score_fit(fit)
    p <- fit$facets$person
    theta <- p$PrimaryEstimate %||% p$Estimate
    if (identical(fit$config$method, "MML")) {
        cfg <- fit$config
        mml_boundary <- mfrmr_mml_population_boundary(fit$prep, cfg)
        invalid_mml <- !is.null(mml_boundary) || !identical(as.integer(fit$opt$convergence), 0L) || any(!is.finite(fit$opt$par))
        if (invalid_mml) {
            n_p <- nrow(p)
            return(data.frame(Person = as.character(p$Person), Estimate = rep(NA_real_, n_p), PosteriorExpectedScore = rep(NA_real_, 
                n_p), PosteriorScoreSD = rep(NA_real_, n_p), Status = rep("unavailable_calibration", 
                n_p), Target = rep("common_plan_expected_average", n_p), Units = rep("internal_score", 
                n_p), Uncertainty = rep("unavailable", n_p), stringsAsFactors = FALSE))
        }
        kernel <- mfrm_fair_reference_kernel(fit, plan)
        score <- mfrm_fair_eval_plan_score(theta, kernel, plan$NormalizedWeight, fit$prep$rating_min)
        q_pts <- as.integer(cfg$estimation_control$quad_points %||% 31L)
        quad <- gauss_hermite_normal(q_pts)
        idx_obs <- build_indices(fit$prep, cfg$step_facet, cfg$slope_facet, cfg$interaction_specs)
        pa <- expand_params(fit$opt$par, build_param_sizes(cfg), cfg)
        lp_bundle <- mfrm_mml_logprob_bundle(idx = idx_obs, config = cfg, quad = quad, params = pa, base_eta = compute_base_eta(idx_obs, 
            pa, cfg))
        p_bundle <- mfrm_mml_person_bundle(log_prob_mat = lp_bundle$log_prob_mat, person_int = lp_bundle$person_int, 
            quad_basis = lp_bundle$quad_basis, include_posterior = TRUE)
        n_person <- nrow(lp_bundle$quad_basis$nodes)
        person_ids <- as.integer(p_bundle$person_ids)
        nodes_mat <- lp_bundle$quad_basis$nodes[person_ids, , drop = FALSE]
        unique_nodes <- sort(unique(as.numeric(nodes_mat)))
        unique_scores <- mfrm_fair_eval_plan_score(unique_nodes, kernel, plan$NormalizedWeight, fit$prep$rating_min)
        score_grid <- matrix(unique_scores[match(as.numeric(nodes_mat), unique_nodes)], nrow = nrow(nodes_mat), 
            ncol = ncol(nodes_mat))
        post_mean <- rowSums(score_grid * p_bundle$posterior)
        post_var <- pmax(0, rowSums((score_grid - post_mean)^2 * p_bundle$posterior))
        post_mean_aligned <- rep(NA_real_, n_person)
        post_sd_aligned <- rep(NA_real_, n_person)
        post_mean_aligned[person_ids] <- post_mean
        post_sd_aligned[person_ids] <- sqrt(post_var)
        person_pos <- match(as.character(p$Person), as.character(fit$prep$levels$Person))
        post_mean_out <- post_mean_aligned[person_pos]
        post_sd_out <- post_sd_aligned[person_pos]
        return(data.frame(Person = as.character(p$Person), Estimate = unname(score), PosteriorExpectedScore = unname(post_mean_out), 
            PosteriorScoreSD = unname(post_sd_out), Status = ifelse(!is.finite(score), "unavailable_calibration", 
                "eap_plug_in_estimate"), Target = "common_plan_expected_average", Units = "internal_score", 
            Uncertainty = "conditional_posterior_quadrature_excludes_calibration_se", stringsAsFactors = FALSE))
    }
    kernel <- mfrm_fair_reference_kernel(fit, plan)
    score <- mfrm_fair_eval_plan_score(theta, kernel, plan$NormalizedWeight, fit$prep$rating_min)
    joint <- fit$config$boundary_audit$joint_additive
    structural <- joint$target_status
    invalid <- !mfrm_is_jeffreys_fit(fit) && (!isTRUE(joint$complete) || any(structural$ParameterClass != 
        "person" & structural$CandidateStatus %in% c("unbounded_low", "unbounded_high", "unbounded_both")))
    if (invalid) 
        score[] <- NA_real_
    data.frame(Person = as.character(p$Person), Estimate = unname(score), Status = ifelse(!is.finite(score), 
        "unavailable_calibration", ifelse(is.finite(theta), "point_estimate", "boundary_limit")), Target = "common_plan_expected_average", 
        Units = "internal_score", Uncertainty = "not_computed", stringsAsFactors = FALSE)
}

mfrm_fair_refit_check <- function(fit, gradient_tol) {
    mfrm_fair_reference_fit(fit)
    cfg <- fit$config
    if (!identical(as.integer(fit$opt$convergence), 0L)) 
        stop("Optimizer did not converge.", call. = FALSE)
    audit <- cfg$estimability_audit
    if (!isTRUE(audit$complete) || length(audit$zero_coordinates) || nrow(audit$null_blocks)) 
        stop("Additive identification is unresolved or deficient.", call. = FALSE)
    if (mfrm_is_jeffreys_fit(fit)) {
        d <- mfrm_fair_jeffreys_design(fit)
        objective <- mfrm_fair_jeffreys_objective(d$category, d$offset, d$y)
        z <- objective$evaluate(fit$opt$par, TRUE)
        grad <- if (length(z$gradient)) 
            max(abs(z$gradient))
        else 0
        if (!is.finite(grad) || grad > gradient_tol || any(z$probabilities <= 0 | z$probabilities >= 
            1)) 
            stop("Jeffreys penalized stationarity/interior check failed.", call. = FALSE)
        return(list(max_gradient = grad, nll = z$nll, penalized_objective = z$value, information_logdet = z$logdet, 
            solve_residual = z$solve_residual, estimator = "jeffreys_canonical_joint"))
    }
    joint <- cfg$boundary_audit$joint_additive
    if (!isTRUE(joint$complete)) 
        stop("Joint boundary audit is incomplete.", call. = FALSE)
    tab <- joint$target_status
    if (any(tab$ParameterClass != "person" & tab$CandidateStatus %in% c("unbounded_low", "unbounded_high", 
        "unbounded_both"))) 
        stop("Structural calibration has a certified recession direction.", call. = FALSE)
    idx <- build_indices(fit$prep, cfg$step_facet, cfg$slope_facet, cfg$interaction_specs)
    sizes <- build_param_sizes(cfg)
    g <- mfrm_grad_jml(fit$opt$par, idx, cfg, sizes)
    grad <- if (length(g)) 
        max(abs(g))
    else 0
    nll <- mfrm_loglik_jml(fit$opt$par, idx, cfg, sizes)
    if (!is.finite(nll) || !is.finite(grad) || grad > gradient_tol) 
        stop("JML stationarity check failed (maximum absolute gradient = ", signif(grad, 5), ").", call. = FALSE)
    list(max_gradient = grad, nll = nll)
}

mfrm_fair_anchor_values <- function(fit, anchors) {
    person <- fit$facets$person
    other <- fit$facets$others
    tab <- rbind(data.frame(Facet = "Person", Level = person$Person, Estimate = person$PrimaryEstimate %||% 
        person$Estimate), as.data.frame(other[c("Facet", "Level", "Estimate")]))
    values <- vapply(seq_len(nrow(anchors)), function(i) {
        j <- which(tab$Facet == anchors$Facet[i] & tab$Level == anchors$Level[i])
        if (length(j) == 1L) 
            tab$Estimate[j]
        else NA_real_
    }, 0)
    if (any(!is.finite(values))) 
        stop("An estimated anchor is missing or nonfinite in the calibration fit.", call. = FALSE)
    values
}

mfrm_fair_response_map <- function(source, generator, map, label) {
    n <- nrow(source$prep$data)
    if (!is.numeric(map) || length(map) != n || any(!is.finite(map)) || any(map != floor(map)) || any(map < 
        1 | map > nrow(generator$prep$data)) || anyDuplicated(map)) 
        stop(label, " must identify one distinct generating row per prepared source row.", call. = FALSE)
    columns <- c("Person", source$config$facet_names)
    a <- source$prep$data[columns]
    b <- generator$prep$data[map, columns, drop = FALSE]
    if (!all(vapply(columns, function(f) identical(as.character(a[[f]]), as.character(b[[f]])), TRUE)) || 
        !identical(as.numeric(source$prep$data$Score), as.numeric(generator$prep$data$Score[map]))) 
        stop(label, " does not match the prepared Person, facet and observed-score rows.", call. = FALSE)
    as.integer(map)
}

mfrm_fair_refit <- function(source, scores, anchors = source$config$replay_inputs$anchors) {
    args <- source$config$replay_inputs
    dat <- as.data.frame(source$prep$data[c("Person", source$config$facet_names)])
    names(dat)[1] <- args$person
    dat[[args$score]] <- scores
    if (!is.null(args$weight)) 
        dat[[args$weight]] <- 1
    args$package_version <- NULL
    args$data <- dat
    args$anchors <- anchors
    args$attach_diagnostics <- FALSE
    args$rating_min <- source$prep$rating_min
    args$rating_max <- source$prep$rating_max
    fit <- do.call(fit_mfrm, args)
    if (!identical(source$prep$levels, fit$prep$levels) || !identical(build_param_sizes(source$config), 
        build_param_sizes(fit$config)) || !isTRUE(all.equal(source$prep$score_map, fit$prep$score_map, 
        check.attributes = FALSE))) 
        stop("Refitting changed parameter identities or category support.", call. = FALSE)
    fit
}

mfrm_fair_generator_probs <- function(fit) {
    cfg <- fit$config
    pa <- expand_params(fit$opt$par, build_param_sizes(cfg), cfg)
    p <- fit$facets$person
    theta <- p$PrimaryEstimate %||% p$Estimate
    if (any(!is.finite(theta))) 
        stop("The generating fit needs finite primary estimates for every Person.", call. = FALSE)
    idx <- build_indices(fit$prep, cfg$step_facet, cfg$slope_facet, cfg$interaction_specs)
    eta <- theta[match(as.character(fit$prep$data$Person), p$Person)] + compute_base_eta(idx, pa, cfg)
    if (cfg$model == "RSM") 
        category_prob_rsm(eta, c(0, cumsum(pa$steps)))
    else category_prob_pcm(eta, t(apply(pa$steps_mat, 1L, function(s) c(0, cumsum(s)))), idx$step_idx)
}

mfrm_fair_bootstrap_bounds <- function(estimate, truth, draws, level) {
    roots <- sweep(draws, 2L, truth, "-")
    missing <- !is.finite(roots)
    low <- high <- roots
    low[missing] <- -Inf
    high[missing] <- Inf
    tail <- (1 - level)/2
    lower <- estimate - apply(high, 2L, stats::quantile, probs = 1 - tail, type = 1, names = FALSE)
    upper <- estimate - apply(low, 2L, stats::quantile, probs = tail, type = 1, names = FALSE)
    list(lower = lower, upper = upper, available = colSums(!missing), roots = roots)
}

mfrm_fair_bootstrap_mc <- function(estimate, roots, level, mc_level) {
    n <- nrow(roots)
    p <- c((1 + level)/2, (1 - level)/2)
    error <- (1 - mc_level)/4
    lower_rank <- stats::qbinom(error, n, p)
    upper_rank <- stats::qbinom(1 - error, n, p) + 1
    targets <- colnames(roots) %||% as.character(seq_len(ncol(roots)))
    rows <- lapply(seq_len(ncol(roots)), function(j) {
        x <- roots[, j]
        missing <- !is.finite(x)
        lo <- hi <- x
        lo[missing] <- -Inf
        hi[missing] <- Inf
        lo <- c(-Inf, sort(lo), Inf)
        hi <- c(-Inf, sort(hi), Inf)
        data.frame(Target = targets[j], Endpoint = c("lower", "upper"), Probability = p, RankLower = lower_rank, 
            RankUpper = upper_rank, Lower = estimate[j] - hi[upper_rank + 1], Upper = estimate[j] - lo[lower_rank + 
                1], MCLevel = mc_level, Planned = n, Unresolved = sum(missing), RankLimited = lower_rank == 
                0 | upper_rank == n + 1, row.names = NULL)
    })
    do.call(rbind, rows)
}

mfrm_count_monotone_inversions <- function(x, y, tol = 1e-10) {
    ok <- is.finite(x) & is.finite(y)
    n <- sum(ok)
    if (n < 2L) 
        return(0L)
    x <- x[ok]
    y <- y[ok]
    ord <- order(x, y)
    x <- x[ord]
    y <- y[ord]
    ptr <- 0L
    prefix_max <- -Inf
    inverted <- 0L
    for (b in seq_len(n)) {
        while (ptr + 1L < b && x[ptr + 1L] < x[b] - tol) {
            ptr <- ptr + 1L
            if (y[ptr] > prefix_max) 
                prefix_max <- y[ptr]
        }
        if (ptr > 0L && prefix_max > y[b] + tol) 
            inverted <- inverted + 1L
    }
    inverted
}

mfrm_audit_pcm_fair_exposure <- function(fit, diagnostics, raw_tbls, totalscore = TRUE) {
    cfg <- fit$config %||% list()
    if (!identical(cfg$model, "PCM") || is.null(cfg$step_facet) || !is.list(raw_tbls) || !length(raw_tbls)) {
        return(NULL)
    }
    obs <- diagnostics$obs
    step_facet <- as.character(cfg$step_facet)
    step_levels <- as.character(fit$prep$levels[[step_facet]] %||% character(0))
    if (!is.data.frame(obs) || !nrow(obs) || !length(step_levels) || !step_facet %in% names(obs)) {
        return(NULL)
    }
    all_facets <- c("Person", cfg$facet_names)
    score_source <- obs
    if (!isTRUE(totalscore) && all(c(all_facets, "Observed") %in% names(obs))) {
        rmin <- fit$prep$rating_min
        rmax <- fit$prep$rating_max
        extreme_levels <- lapply(all_facets, function(fct) {
            grp <- split(obs$Observed, as.character(obs[[fct]]))
            names(grp)[vapply(grp, function(v) {
                v <- v[is.finite(v)]
                length(v) > 0L && (all(v == rmin) || all(v == rmax))
            }, logical(1))]
        })
        names(extreme_levels) <- all_facets
    }
    else {
        extreme_levels <- NULL
    }
    target_facets <- setdiff(names(raw_tbls), step_facet)
    if (!length(target_facets)) 
        return(NULL)
    w_all <- get_weights(obs)
    rows <- lapply(target_facets, function(fct) {
        tbl <- raw_tbls[[fct]]
        if (!is.data.frame(tbl) || !nrow(tbl) || !fct %in% names(obs)) {
            return(NULL)
        }
        use_mask <- rep(TRUE, nrow(obs))
        if (!is.null(extreme_levels)) {
            for (other in setdiff(all_facets, fct)) {
                if (length(extreme_levels[[other]]) > 0L) {
                  use_mask <- use_mask & !(as.character(obs[[other]]) %in% extreme_levels[[other]])
                }
            }
        }
        obs_sub <- obs[use_mask, , drop = FALSE]
        w_sub <- w_all[use_mask]
        step_idx <- match(as.character(obs_sub[[step_facet]]), step_levels)
        lvl_chr <- as.character(obs_sub[[fct]])
        prof_mat <- vapply(as.character(tbl$Level), function(lv) {
            idx <- which(lvl_chr == lv & !is.na(step_idx) & is.finite(w_sub) & w_sub > 0)
            if (!length(idx)) 
                return(rep(NA_real_, length(step_levels)))
            sums <- vapply(seq_along(step_levels), function(k) sum(w_sub[idx[step_idx[idx] == k]]), numeric(1))
            tot <- sum(sums)
            if (tot <= 0) 
                rep(NA_real_, length(step_levels))
            else sums/tot
        }, numeric(length(step_levels)))
        if (!is.matrix(prof_mat)) 
            prof_mat <- matrix(prof_mat, nrow = length(step_levels))
        prof_mat <- t(prof_mat)
        valid_prof <- rowSums(!is.finite(prof_mat)) == 0L
        hetero <- if (sum(valid_prof) >= 2L) {
            p_ok <- prof_mat[valid_prof, , drop = FALSE]
            max(abs(sweep(p_ok, 2L, p_ok[1L, ], "-"))) > 1e-10
        }
        else {
            FALSE
        }
        sign_f <- if (identical(fct, "Person")) 
            1
        else as.numeric(cfg$facet_signs[[fct]] %||% -1)
        eta_dir <- sign_f * suppressWarnings(as.numeric(tbl$PrimaryMeasure %||% tbl$Measure))
        inv_m <- if ("FairM" %in% names(tbl)) 
            mfrm_count_monotone_inversions(eta_dir, as.numeric(tbl$FairM))
        else 0L
        inv_z <- if ("FairZ" %in% names(tbl)) 
            mfrm_count_monotone_inversions(eta_dir, as.numeric(tbl$FairZ))
        else 0L
        data.frame(Facet = fct, StepFacet = step_facet, LevelsEvaluated = sum(valid_prof), HeterogeneousStepExposure = hetero, 
            FairMNonMonotoneElements = as.integer(inv_m), FairZNonMonotoneElements = as.integer(inv_z), 
            stringsAsFactors = FALSE)
    })
    rows <- Filter(Negate(is.null), rows)
    if (!length(rows)) 
        return(NULL)
    do.call(rbind, rows)
}
