predict.mfrm_posterior_summary <- function(object, newdata, type = c("ability", "both", "predictive"), 
    conditioning = c("posterior", "plugin_mean"), level = 0.95, cut_scores = NULL, quad_points = 31L, 
    missing = c("fail", "omit"), persons = NULL, allow_calibration_persons = FALSE, repeated_ratings = NULL, 
    keep_person_draws = FALSE, ...) {
    rlang::check_dots_empty()
    .mfrm_validate_posterior(object)
    type <- match.arg(type)
    if (missing(conditioning)) {
        conditioning <- "posterior"
    }
    else {
        if (!is.character(conditioning) || length(conditioning) != 1L || is.na(conditioning)) {
            stop("`conditioning` must be 'posterior' or 'plugin_mean'.", call. = FALSE)
        }
        if (identical(conditioning, "joint")) {
            stop("Joint hierarchical refitting (`conditioning = 'joint'`) cannot be evaluated by `predict()` because updating calibration parameters requires refitting the full model. ", 
                "Combine calibration and new rating rows and run `export_mfrm_model()` instead; use `conditioning = 'posterior'` for fixed-calibration posterior mixture scoring or `conditioning = 'plugin_mean'` for posterior-mean plug-in scoring.", 
                call. = FALSE)
        }
        if (!conditioning %in% c("posterior", "plugin_mean")) {
            stop("`conditioning` must be 'posterior' or 'plugin_mean'.", call. = FALSE)
        }
    }
    level <- .mfrm_validate_credible_level(level)
    cut_scores <- mfrm_validate_cut_scores(cut_scores)
    if (!is.numeric(quad_points) || is.complex(quad_points) || length(quad_points) != 1L || !is.finite(quad_points) || 
        quad_points != floor(quad_points) || quad_points < 7 || quad_points > 121) {
        stop("`quad_points` must be one integer from 7 to 121.", call. = FALSE)
    }
    quad_points <- as.integer(quad_points)
    missing <- match.arg(missing)
    for (flag in c("allow_calibration_persons", "keep_person_draws")) {
        val <- get(flag)
        if (!is.logical(val) || length(val) != 1L || is.na(val)) {
            stop("`", flag, "` must be TRUE or FALSE.", call. = FALSE)
        }
    }
    if (missing(newdata) || is.null(newdata)) {
        cols_hint <- if (!is.null(object$scoring_spec$source_columns)) {
            sc <- object$scoring_spec$source_columns
            paste(c(sc$person, sc$facets, sc$score), collapse = ", ")
        }
        else {
            "Person, facets, Score"
        }
        stop("`newdata` is required because `mfrm_posterior_summary` does not store raw rating rows. ", 
            "Supply a long-format data.frame with columns: ", cols_hint, ".", call. = FALSE)
    }
    cal <- .mfrm_prepare_posterior_calibration_draws(object, conditioning = conditioning)
    scoring_spec <- cal$scoring_spec
    prep <- .mfrm_prepare_posterior_newdata(newdata = newdata, scoring_spec = scoring_spec, missing = missing, 
        persons = persons, allow_calibration_persons = allow_calibration_persons, repeated_ratings = repeated_ratings)
    alpha <- (1 - level)/2
    probs <- c(0.5, alpha, 1 - alpha)
    cuts_num <- if (is.null(cut_scores)) 
        numeric(0)
    else as.numeric(unname(cut_scores))
    score_vals <- as.numeric(scoring_spec$categories$Score)
    need_pred <- type %in% c("both", "predictive")
    check_points <- 2L * quad_points + 1L
    gl_low <- .mfrm_gauss_legendre(quad_points)
    gl_high <- .mfrm_gauss_legendre(check_points)
    low_res <- .mfrm_posterior_person_score_kernel(n_cat = nrow(scoring_spec$categories), loc_draws = cal$loc_draws, 
        cum_step_draws = cal$cum_step_draws, slope_draws = cal$slope_draws, mu_draws = cal$mu_draws, 
        sigma_draws = cal$sigma_draws, row_loc_idx = prep$row_loc_idx, facet_signs = prep$facet_signs, 
        row_owner = prep$row_owner, row_slope_idx = prep$row_slope_idx, row_y = prep$row_y, person_row_starts = prep$person_row_starts, 
        person_rows = prep$person_rows, probs = probs, cut_scores = cuts_num, score_values = score_vals, 
        gl_nodes = gl_low$nodes, gl_weights = gl_low$weights, compute_predictive = need_pred, keep_person_draws = FALSE)
    high_res <- .mfrm_posterior_person_score_kernel(n_cat = nrow(scoring_spec$categories), loc_draws = cal$loc_draws, 
        cum_step_draws = cal$cum_step_draws, slope_draws = cal$slope_draws, mu_draws = cal$mu_draws, 
        sigma_draws = cal$sigma_draws, row_loc_idx = prep$row_loc_idx, facet_signs = prep$facet_signs, 
        row_owner = prep$row_owner, row_slope_idx = prep$row_slope_idx, row_y = prep$row_y, person_row_starts = prep$person_row_starts, 
        person_rows = prep$person_rows, probs = probs, cut_scores = cuts_num, score_values = score_vals, 
        gl_nodes = gl_high$nodes, gl_weights = gl_high$weights, compute_predictive = need_pred, keep_person_draws = keep_person_draws)
    n_person <- length(prep$persons)
    n_draws <- cal$n_draws
    is_posterior <- identical(conditioning, "posterior")
    cal_unc_label <- if (is_posterior) {
        "propagated_posterior_draws"
    }
    else {
        "excluded_plugin_posterior_mean"
    }
    avail_status_label <- if (is_posterior) 
        "available_posterior"
    else "available_conditional"
    sampling_review_status <- as.character(object$decision$Status[1L])
    prior_mean_val <- mean(cal$mu_draws)
    prior_between_var <- mean((cal$mu_draws - prior_mean_val)^2)
    prior_within_var <- mean(cal$sigma_draws^2)
    prior_sd_val <- sqrt(prior_within_var + prior_between_var)
    est_rows <- vector("list", n_person)
    int_diffs <- rep(NA_real_, n_person)
    final_status <- character(n_person)
    final_reason <- character(n_person)
    dec_probs_mat <- high_res$decision_probs
    dec_bsd_mat <- high_res$decision_between_sd
    pred_probs_mat <- high_res$pred_probs
    pred_esd_vec <- high_res$pred_expected_mean_sd
    for (p in seq_len(n_person)) {
        pid <- prep$persons[p]
        cal_member <- pid %in% scoring_spec$calibration_persons
        r_idx <- prep$person_rows[(prep$person_row_starts[p] + 1L):prep$person_row_starts[p + 1L]]
        obs_scores_p <- prep$observed_score[r_idx]
        obs_scores_p <- obs_scores_p[!is.na(obs_scores_p)]
        obs_mean_p <- if (length(obs_scores_p)) 
            mean(obs_scores_p)
        else NA_real_
        sc_low <- low_res$status_code[p]
        sc_high <- high_res$status_code[p]
        if (sc_low == 2L || sc_high == 2L) {
            msg <- if (nzchar(high_res$error_message[p])) {
                high_res$error_message[p]
            }
            else if (nzchar(low_res$error_message[p])) {
                low_res$error_message[p]
            }
            else {
                "Numerical posterior integration failed."
            }
            final_status[p] <- "unavailable"
            final_reason[p] <- msg
            if (ncol(dec_probs_mat) > 0L) {
                dec_probs_mat[p, ] <- NA_real_
                dec_bsd_mat[p, ] <- NA_real_
            }
            if (need_pred) {
                local_slots <- (prep$person_row_starts[p] + 1L):prep$person_row_starts[p + 1L]
                pred_probs_mat[local_slots, ] <- NA_real_
                pred_esd_vec[local_slots] <- NA_real_
            }
            est_rows[[p]] <- data.frame(Person = pid, Observed = high_res$observed_count[p], Omitted = high_res$omitted_count[p], 
                ObservedMean = obs_mean_p, Estimate = NA_real_, Median = NA_real_, SD = NA_real_, WithinSD = NA_real_, 
                BetweenSD = NA_real_, CalibrationVarShare = NA_real_, Lower = NA_real_, Upper = NA_real_, 
                PriorMean = prior_mean_val, PriorSD = prior_sd_val, PersonLogMarginalLikelihood = NA_real_, 
                IntegrationMaxDiff = NA_real_, CalibrationMember = cal_member, CalibrationUncertainty = cal_unc_label, 
                SamplingReview = sampling_review_status, Status = "unavailable", Reason = msg, stringsAsFactors = FALSE)
            next
        }
        vec_low <- c(low_res$mean[p], low_res$within_sd[p], low_res$between_sd[p], low_res$total_sd[p], 
            low_res$log_marginal_lik[p], low_res$quantiles[p, ], low_res$decision_probs[p, ], low_res$decision_between_sd[p, 
                ])
        vec_high <- c(high_res$mean[p], high_res$within_sd[p], high_res$between_sd[p], high_res$total_sd[p], 
            high_res$log_marginal_lik[p], high_res$quantiles[p, ], high_res$decision_probs[p, ], high_res$decision_between_sd[p, 
                ])
        diff_p <- max(abs(vec_high - vec_low))
        if (!is.finite(diff_p) || diff_p > 1e-06) {
            msg <- "Composite Gauss-Legendre integration disagreed across quadrature orders; increase `quad_points` and inspect the response pattern."
            final_status[p] <- "unavailable"
            final_reason[p] <- msg
            if (ncol(dec_probs_mat) > 0L) {
                dec_probs_mat[p, ] <- NA_real_
                dec_bsd_mat[p, ] <- NA_real_
            }
            if (need_pred) {
                local_slots <- (prep$person_row_starts[p] + 1L):prep$person_row_starts[p + 1L]
                pred_probs_mat[local_slots, ] <- NA_real_
                pred_esd_vec[local_slots] <- NA_real_
            }
            est_rows[[p]] <- data.frame(Person = pid, Observed = high_res$observed_count[p], Omitted = high_res$omitted_count[p], 
                ObservedMean = obs_mean_p, Estimate = NA_real_, Median = NA_real_, SD = NA_real_, WithinSD = NA_real_, 
                BetweenSD = NA_real_, CalibrationVarShare = NA_real_, Lower = NA_real_, Upper = NA_real_, 
                PriorMean = prior_mean_val, PriorSD = prior_sd_val, PersonLogMarginalLikelihood = NA_real_, 
                IntegrationMaxDiff = diff_p, CalibrationMember = cal_member, CalibrationUncertainty = cal_unc_label, 
                SamplingReview = sampling_review_status, Status = "unavailable", Reason = msg, stringsAsFactors = FALSE)
            next
        }
        int_diffs[p] <- diff_p
        is_prior_only <- (sc_high == 1L)
        st_p <- if (is_prior_only) 
            "prior_only"
        else avail_status_label
        reasons_p <- character(0)
        if (is_prior_only) {
            reasons_p <- c(reasons_p, "No observed responses for this Person; the estimate, SD and interval describe only the calibration ability prior, not measured individual ability.")
        }
        if (cal_member) {
            reasons_p <- c(reasons_p, "Person ID belonged to the calibration sample (`allow_calibration_persons = TRUE`); calibration draws already conditioned on their source ratings, so out-of-sample log marginal likelihood is withheld.")
        }
        rsn_p <- paste(reasons_p, collapse = " ")
        final_status[p] <- st_p
        final_reason[p] <- rsn_p
        wsd <- high_res$within_sd[p]
        bsd <- if (is_posterior) 
            high_res$between_sd[p]
        else NA_real_
        tsd <- if (is_posterior) 
            high_res$total_sd[p]
        else wsd
        cshare <- if (is_posterior && is.finite(tsd) && tsd > 0) {
            min(1, max(0, (bsd * bsd)/(tsd * tsd)))
        }
        else {
            NA_real_
        }
        log_ml_p <- if (cal_member) 
            NA_real_
        else high_res$log_marginal_lik[p]
        est_rows[[p]] <- data.frame(Person = pid, Observed = high_res$observed_count[p], Omitted = high_res$omitted_count[p], 
            ObservedMean = obs_mean_p, Estimate = high_res$mean[p], Median = high_res$quantiles[p, 1L], 
            SD = tsd, WithinSD = wsd, BetweenSD = bsd, CalibrationVarShare = cshare, Lower = high_res$quantiles[p, 
                2L], Upper = high_res$quantiles[p, 3L], PriorMean = prior_mean_val, PriorSD = prior_sd_val, 
            PersonLogMarginalLikelihood = log_ml_p, IntegrationMaxDiff = diff_p, CalibrationMember = cal_member, 
            CalibrationUncertainty = cal_unc_label, SamplingReview = sampling_review_status, Status = st_p, 
            Reason = rsn_p, stringsAsFactors = FALSE)
    }
    estimates_df <- do.call(rbind, est_rows)
    rownames(estimates_df) <- NULL
    decisions_df <- if (!is.null(cut_scores)) {
        if (!is_posterior && ncol(dec_bsd_mat) > 0L) {
            dec_bsd_mat[] <- NA_real_
        }
        .mfrm_posterior_decision_table(probabilities = dec_probs_mat, between_sd = dec_bsd_mat, persons = prep$persons, 
            cut_scores = cut_scores, prior_mean = prior_mean_val, prior_sd = prior_sd_val, status = final_status, 
            reason = final_reason, uncertainty_label = if (is_posterior) {
                "posterior_marginal_over_calibration_draws"
            }
            else {
                "conditional_on_posterior_mean_calibration"
            })
    }
    else {
        NULL
    }
    predictive_df <- if (need_pred) {
        pred_diff <- apply(abs(high_res$pred_probs - low_res$pred_probs), 1L, max)
        pred_diff <- pmax(pred_diff, abs(high_res$pred_expected_mean_sd - low_res$pred_expected_mean_sd))
        pred_person <- match(prep$person_chr[prep$person_rows], prep$persons)
        pred_bad <- !is.finite(pred_diff) | pred_diff > 1e-06
        pred_bad <- pred_bad | final_status[pred_person] == "unavailable"
        pred_probs_mat[pred_bad, ] <- NA_real_
        pred_esd_vec[pred_bad] <- NA_real_
        tab <- .mfrm_build_posterior_predictive_table(newdata = newdata, prep = prep, scoring_spec = scoring_spec, 
            pred_probs = pred_probs_mat, pred_expected_mean_sd = if (is_posterior) 
                pred_esd_vec
            else rep(NA_real_, length(pred_esd_vec)), person_status = stats::setNames(final_status, prep$persons))
        tab$IntegrationMaxDiff <- pred_diff
        tab$Status <- ifelse(pred_bad, "unavailable", avail_status_label)
        tab$Reason <- ifelse(final_status[pred_person] == "unavailable", final_reason[pred_person], ifelse(pred_bad, 
            "Predictive integration disagreed across quadrature orders; increase `quad_points`. Ability scoring has a separate integration check.", 
            ""))
        tab
    }
    else {
        NULL
    }
    person_draws_df <- if (keep_person_draws) {
        dm <- high_res$draw_mean
        ds <- high_res$draw_sd
        dl <- high_res$draw_log_z
        for (p in which(final_status == "unavailable")) {
            dm[p, ] <- NA_real_
            ds[p, ] <- NA_real_
            dl[p, ] <- NA_real_
        }
        for (p in which(estimates_df$CalibrationMember)) {
            dl[p, ] <- NA_real_
        }
        data.frame(Person = rep(prep$persons, each = n_draws), Draw = rep(seq_len(n_draws), times = n_person), 
            Chain = rep(cal$chain_id, times = n_person), Iteration = rep(cal$iter_id, times = n_person), 
            ConditionalMean = as.numeric(t(dm)), ConditionalSD = as.numeric(t(ds)), LogMarginalLikelihood = as.numeric(t(dl)), 
            stringsAsFactors = FALSE)
    }
    else {
        NULL
    }
    notes <- .mfrm_posterior_scoring_notes(object = object, conditioning = conditioning, has_cuts = !is.null(cut_scores), 
        has_pred = need_pred, any_cal_member = any(estimates_df$CalibrationMember))
    if (need_pred && any(pred_bad)) {
        notes <- c(notes, paste(sum(pred_bad), "predictive rows are unavailable. Inspect predictive$Reason and predictive$IntegrationMaxDiff; ability estimates have a separate precision check."))
    }
    out <- structure(list(estimates = estimates_df, predictive = predictive_df, decisions = decisions_df, 
        person_draws = person_draws_df, person_dispositions = data.frame(Person = estimates_df$Person, 
            Observed = estimates_df$Observed, Omitted = estimates_df$Omitted, CalibrationMember = estimates_df$CalibrationMember, 
            Status = estimates_df$Status, Reason = estimates_df$Reason, stringsAsFactors = FALSE), source = object$source, 
        posterior_decision = object$decision, categories = scoring_spec$categories, data_usage = c(InputRows = nrow(newdata), 
            ScoredRows = length(prep$person_rows), ObservedRows = sum(estimates_df$Observed), OmittedRows = sum(estimates_df$Omitted), 
            Persons = nrow(estimates_df)), omitted_rows = prep$omitted_rows, settings = list(type = type, 
            conditioning = conditioning, level = level, quad_points = quad_points, check_points = check_points, 
            missing = missing, allow_calibration_persons = allow_calibration_persons, repeated_ratings = prep$repeated_ratings, 
            draws_used = n_draws, cut_scores = cut_scores, calibration_uncertainty = is_posterior, new_person_updates_calibration = FALSE, 
            prior_mean = prior_mean_val, prior_sd = prior_sd_val, source_columns = scoring_spec$source_columns, 
            target = if (is_posterior) {
                "New-Person ability posterior marginalized equally over saved calibration draws without updating calibration"
            } else {
                "New-Person ability posterior conditional on marginal posterior-mean calibration (calibration uncertainty excluded)"
            }), notes = notes), class = "mfrm_posterior_scores")
    .mfrm_validate_posterior_scores(out)
    out
}

.mfrm_extract_scoring_spec <- function(bundle) {
    lv <- bundle$levels
    is_person <- lv$Facet == "Person"
    cal_persons <- as.character(lv$Level[is_person])
    other <- lv[!is_person, , drop = FALSE]
    facet_names <- unique(as.character(other$Facet))
    facet_levels <- stats::setNames(lapply(facet_names, function(f) {
        as.character(other$Level[other$Facet == f])
    }), facet_names)
    facet_signs <- stats::setNames(vapply(facet_names, function(f) {
        as.numeric(other$Sign[other$Facet == f][1L])
    }, numeric(1)), facet_names)
    facet_loc_indices <- stats::setNames(lapply(facet_names, function(f) {
        as.integer(other$Index[other$Facet == f])
    }), facet_names)
    step_owners <- as.character(bundle$step_owners)
    step_facet_ambiguous <- FALSE
    if (identical(bundle$model, "RSM")) {
        step_facet <- NULL
    }
    else if (!is.null(bundle$step_facet)) {
        step_facet <- as.character(bundle$step_facet)
    }
    else {
        hits <- facet_names[vapply(facet_names, function(f) {
            identical(facet_levels[[f]], step_owners)
        }, logical(1))]
        if (length(hits) == 1L) {
            step_facet <- hits
        }
        else {
            step_facet <- NULL
            step_facet_ambiguous <- TRUE
        }
    }
    slope_owners <- if (is.null(bundle$slope_levels)) {
        character(0)
    }
    else {
        unique(as.character(bundle$slope_levels$Owner))
    }
    slope_facet <- if (!is.null(bundle$slope_facet)) {
        as.character(bundle$slope_facet)
    }
    else {
        slope_owners
    }
    sc <- bundle$source_columns
    if (is.null(sc)) {
        sc <- list(person = "Person", facets = facet_names, score = "Score", weight = NULL)
    }
    list(model = as.character(bundle$model), schema_version = if (is.null(bundle$population)) 1L else 2L, 
        calibration_persons = cal_persons, facet_names = facet_names, facet_levels = facet_levels, facet_signs = facet_signs, 
        facet_loc_indices = facet_loc_indices, step_facet = step_facet, step_facet_ambiguous = step_facet_ambiguous, 
        step_owners = step_owners, slope_facet = slope_facet, slope_levels = bundle$slope_levels, categories = bundle$categories, 
        source_columns = sc, repeated_ratings = as.character(bundle$repeated_ratings %||% "review"))
}

.mfrm_gauss_legendre <- function(n) {
    n <- as.integer(n)
    if (n < 2L) 
        stop("Gauss-Legendre order must be >= 2.", call. = FALSE)
    m <- (n + 1L)%/%2L
    nodes <- numeric(n)
    weights <- numeric(n)
    dn <- as.double(n)
    scale_init <- 1 - 1/(8 * dn * dn) + 1/(8 * dn * dn * dn)
    for (i in seq_len(m)) {
        z <- -scale_init * cos(pi * (4 * i - 1)/(4 * dn + 2))
        if (n%%2L == 1L && i == m) {
            z <- 0
        }
        dp <- 0
        for (it in seq_len(12L)) {
            p0 <- 1
            p1 <- z
            if (n >= 2L) {
                for (k in 2:n) {
                  dk <- as.double(k)
                  pk <- ((2 * dk - 1) * z * p1 - (dk - 1) * p0)/dk
                  p0 <- p1
                  p1 <- pk
                }
            }
            dp <- dn * (p0 - z * p1)/(1 - z * z)
            dz <- p1/dp
            z <- z - dz
            if (abs(dz) <= 1e-15) 
                break
        }
        if (n%%2L == 1L && i == m) 
            z <- 0
        w <- 2/((1 - z * z) * dp * dp)
        nodes[i] <- z
        nodes[n - i + 1L] <- -z
        weights[i] <- w
        weights[n - i + 1L] <- w
    }
    list(nodes = nodes, weights = weights)
}

.mfrm_build_cum_steps_matrix <- function(step_mat, n_owners, n_cat) {
    n_draws <- nrow(step_mat)
    k_max <- n_cat - 1L
    out <- matrix(0, nrow = n_draws, ncol = n_owners * n_cat)
    for (g in seq_len(n_owners)) {
        base_out <- (g - 1L) * n_cat
        base_in <- (g - 1L) * k_max
        acc <- numeric(n_draws)
        out[, base_out + 1L] <- 0
        for (k in seq_len(k_max)) {
            acc <- acc + step_mat[, base_in + k]
            out[, base_out + k + 1L] <- acc
        }
    }
    out
}

.mfrm_prepare_posterior_calibration_draws <- function(object, conditioning = c("posterior", "plugin_mean")) {
    conditioning <- match.arg(conditioning)
    spec <- object$bundle_spec
    scoring_spec <- object$scoring_spec
    if (is.null(spec) || is.null(scoring_spec)) {
        stop("This `mfrm_posterior_summary` lacks scoring metadata (`bundle_spec` / `scoring_spec`). ", 
            "Reload the bundle directory with the current `read_mfrm_posterior()`.", call. = FALSE)
    }
    if (identical(scoring_spec$model, "GPCM") && length(scoring_spec$slope_facet) > 1L) {
        stop("New-Person posterior scoring (`predict.mfrm_posterior_summary()`) supports ordinary RSM, ordinary PCM, and one-family GPCM bundles only; two-family product-slope GPCM scoring is not supported.", 
            call. = FALSE)
    }
    if (isTRUE(scoring_spec$step_facet_ambiguous)) {
        stop("Step ownership (`step_facet`) could not be disambiguated in this legacy bundle; re-export `model-data.rds` with `export_mfrm_model()`.", 
            call. = FALSE)
    }
    loc_names <- paste0("locations[", seq_len(spec$L), "]")
    k_max <- spec$C - 1L
    step_names <- unlist(lapply(seq_len(spec$G), function(g) {
        paste0("steps[", g, ",", seq_len(k_max), "]")
    }), use.names = FALSE)
    B_step <- .mfrm_full_step_basis(spec)
    if (identical(conditioning, "posterior")) {
        if (is.null(object$draws)) {
            stop("Full calibration-posterior propagation (`conditioning = 'posterior'`) requires joint posterior draws (`posterior-draws.rds`). ", 
                "Regenerate the bundle summary with `Rscript run.R --summarize` and reload via `read_mfrm_posterior()`, or explicitly request `conditioning = 'plugin_mean'` to score conditional on marginal posterior means without calibration-uncertainty propagation.", 
                call. = FALSE)
        }
        arr <- object$draws$array
        n_iter <- dim(arr)[1L]
        n_chain <- dim(arr)[2L]
        M <- .mfrm_flatten_draws_array(arr)
        n_draws <- nrow(M)
        .mfrm_verify_subspace_draws(M, loc_names, spec$location_offset, spec$location_basis)
        .mfrm_verify_subspace_draws(M, step_names, spec$step_offset, B_step)
        loc_draws <- M[, loc_names, drop = FALSE]
        cum_step_draws <- .mfrm_build_cum_steps_matrix(M[, step_names, drop = FALSE], spec$G, spec$C)
        if (identical(scoring_spec$model, "GPCM") && spec$A > 0L) {
            log_names <- paste0("log_component_slopes[", seq_len(spec$A), "]")
            slope_names <- paste0("component_slopes[", seq_len(spec$A), "]")
            .mfrm_verify_subspace_draws(M, log_names, rep(0, spec$A), spec$slope_basis)
            slope_draws <- M[, slope_names, drop = FALSE]
        }
        else {
            slope_draws <- matrix(1, nrow = n_draws, ncol = 1L)
        }
        if (identical(spec$schema_version, 2L)) {
            mu_draws <- as.numeric(M[, "population_mean"])
            sigma_draws <- as.numeric(M[, "population_sd"])
        }
        else {
            mu_draws <- rep(0, n_draws)
            sigma_draws <- rep(1, n_draws)
        }
        chain_id <- rep(seq_len(n_chain), each = n_iter)
        iter_id <- rep(seq_len(n_iter), times = n_chain)
    }
    else {
        p <- object$parameters
        mean_row <- matrix(p$mean, nrow = 1L, dimnames = list(NULL, p$variable))
        .mfrm_verify_subspace_draws(mean_row, loc_names, spec$location_offset, spec$location_basis)
        .mfrm_verify_subspace_draws(mean_row, step_names, spec$step_offset, B_step)
        loc_draws <- mean_row[, loc_names, drop = FALSE]
        cum_step_draws <- .mfrm_build_cum_steps_matrix(mean_row[, step_names, drop = FALSE], spec$G, 
            spec$C)
        if (identical(scoring_spec$model, "GPCM") && spec$A > 0L) {
            log_names <- paste0("log_component_slopes[", seq_len(spec$A), "]")
            .mfrm_verify_subspace_draws(mean_row, log_names, rep(0, spec$A), spec$slope_basis)
            slope_draws <- exp(mean_row[, log_names, drop = FALSE])
        }
        else {
            slope_draws <- matrix(1, nrow = 1L, ncol = 1L)
        }
        if (identical(spec$schema_version, 2L)) {
            mu_draws <- as.numeric(mean_row[, "population_mean"])
            sigma_draws <- as.numeric(mean_row[, "population_sd"])
        }
        else {
            mu_draws <- 0
            sigma_draws <- 1
        }
        n_draws <- 1L
        chain_id <- 1L
        iter_id <- 1L
    }
    if (any(!is.finite(mu_draws)) || any(!is.finite(sigma_draws)) || any(sigma_draws <= 0)) {
        stop("Calibration population parameters must be finite with positive SD.", call. = FALSE)
    }
    list(scoring_spec = scoring_spec, n_draws = n_draws, loc_draws = loc_draws, cum_step_draws = cum_step_draws, 
        slope_draws = slope_draws, mu_draws = mu_draws, sigma_draws = sigma_draws, chain_id = as.integer(chain_id), 
        iter_id = as.integer(iter_id))
}

.mfrm_prepare_posterior_newdata <- function(newdata, scoring_spec, missing = c("fail", "omit"), persons = NULL, 
    allow_calibration_persons = FALSE, repeated_ratings = NULL) {
    missing <- match.arg(missing)
    if (!is.data.frame(newdata) || !nrow(newdata)) {
        stop("`newdata` must be a non-empty data.frame.", call. = FALSE)
    }
    sc <- scoring_spec$source_columns
    person_col <- sc$person %||% "Person"
    facet_cols <- sc$facets %||% scoring_spec$facet_names
    score_col <- sc$score %||% "Score"
    req_cols <- c(person_col, facet_cols, score_col)
    miss_cols <- setdiff(req_cols, names(newdata))
    if (length(miss_cols) > 0L) {
        stop("`newdata` is missing required source column(s): ", paste(miss_cols, collapse = ", "), ".", 
            call. = FALSE)
    }
    if (!identical(length(facet_cols), length(scoring_spec$facet_names))) {
        stop("Source facet columns disagree with the exported calibration facets.", call. = FALSE)
    }
    eff_repeated <- if (is.null(repeated_ratings)) {
        scoring_spec$repeated_ratings
    }
    else {
        if (!is.character(repeated_ratings) || length(repeated_ratings) != 1L || is.na(repeated_ratings) || 
            !repeated_ratings %in% c("review", "independent")) {
            stop("`repeated_ratings` must be NULL, 'review', or 'independent'.", call. = FALSE)
        }
        repeated_ratings
    }
    raw_person <- newdata[[person_col]]
    if (anyNA(raw_person)) {
        stop("`newdata$", person_col, "` cannot contain missing Person IDs.", call. = FALSE)
    }
    person_chr <- trimws(as.character(raw_person))
    if (any(!nzchar(person_chr))) {
        stop("`newdata$", person_col, "` cannot contain blank Person IDs.", call. = FALSE)
    }
    cal_overlap <- unique(person_chr[person_chr %in% scoring_spec$calibration_persons])
    if (length(cal_overlap) > 0L && !isTRUE(allow_calibration_persons)) {
        stop("`newdata` contains calibration Person ID(s) already used to estimate the posterior (", 
            paste(utils::head(cal_overlap, 5L), collapse = ", "), "). Scoring calibration Persons under p(psi | y_cal) double-counts their ratings; supply genuinely new Persons, or set `allow_calibration_persons = TRUE` only for explicit diagnostic comparisons.", 
            call. = FALSE)
    }
    n_rows <- nrow(newdata)
    n_facets <- length(scoring_spec$facet_names)
    row_loc_idx <- matrix(0L, nrow = n_rows, ncol = n_facets)
    facet_level_chr <- vector("list", n_facets)
    names(facet_level_chr) <- scoring_spec$facet_names
    for (f_i in seq_len(n_facets)) {
        f_model <- scoring_spec$facet_names[f_i]
        f_col <- facet_cols[f_i]
        vals_raw <- newdata[[f_col]]
        if (anyNA(vals_raw)) {
            stop("`newdata$", f_col, "` cannot contain missing facet levels.", call. = FALSE)
        }
        vals_chr <- as.character(vals_raw)
        known <- scoring_spec$facet_levels[[f_model]]
        m_idx <- match(vals_chr, known)
        if (anyNA(m_idx)) {
            bad <- unique(vals_chr[is.na(m_idx)])
            stop("Unseen level(s) in `newdata$", f_col, "` not present in the calibration bundle: ", 
                paste(utils::head(bad, 5L), collapse = ", "), ". Fixed-calibration scoring requires known calibrated facet levels.", 
                call. = FALSE)
        }
        row_loc_idx[, f_i] <- scoring_spec$facet_loc_indices[[f_model]][m_idx]
        facet_level_chr[[f_model]] <- vals_chr
    }
    raw_score <- newdata[[score_col]]
    is_miss <- is.na(raw_score)
    if (any(is_miss) && identical(missing, "fail")) {
        stop("Missing scores were supplied in `newdata$", score_col, "`; pass `missing = 'omit'` to omit unobserved rows explicitly.", 
            call. = FALSE)
    }
    obs_score <- rep(NA_real_, n_rows)
    row_y <- rep(-1L, n_rows)
    if (any(!is_miss)) {
        non_miss <- raw_score[!is_miss]
        if (is.logical(non_miss) || is.complex(non_miss)) {
            stop("`newdata$", score_col, "` must contain numeric score categories.", call. = FALSE)
        }
        num_vals <- suppressWarnings(as.numeric(as.character(non_miss)))
        if (anyNA(num_vals) || any(!is.finite(num_vals))) {
            stop("`newdata$", score_col, "` contains non-numeric or non-finite values.", call. = FALSE)
        }
        cat_scores <- as.numeric(scoring_spec$categories$Score)
        cat_match <- match(num_vals, cat_scores)
        if (anyNA(cat_match)) {
            bad_s <- unique(non_miss[is.na(cat_match)])
            stop("`newdata$", score_col, "` contains score category value(s) outside the calibrated ladder (", 
                paste(cat_scores, collapse = ", "), "): ", paste(utils::head(bad_s, 5L), collapse = ", "), 
                ".", call. = FALSE)
        }
        obs_score[!is_miss] <- num_vals
        row_y[!is_miss] <- as.integer(scoring_spec$categories$Category[cat_match]) - 1L
    }
    w_col <- sc$weight
    if (!is.null(w_col) && w_col %in% names(newdata)) {
        w_vals <- newdata[[w_col]][!is_miss]
        if (length(w_vals) && (!is.numeric(w_vals) || anyNA(w_vals) || any(w_vals != 1))) {
            stop("Bayesian calibration scoring requires unit weights (`1`) on all observed rows.", call. = FALSE)
        }
    }
    obs_mask <- which(!is_miss)
    if (length(obs_mask) > 1L && identical(eff_repeated, "review")) {
        cell_df <- data.frame(Person = person_chr[obs_mask], newdata[obs_mask, facet_cols, drop = FALSE], 
            stringsAsFactors = FALSE)
        if (anyDuplicated(cell_df)) {
            stop("Duplicate observed Person-by-facet rating cells were supplied in `newdata` while `repeated_ratings = 'review'`. ", 
                "Deduplicate the rows or set `repeated_ratings = 'independent'` only when conditional independence across repeated ratings is intended.", 
                call. = FALSE)
        }
    }
    row_owner <- if (identical(scoring_spec$model, "RSM")) {
        rep(1L, n_rows)
    }
    else {
        sf <- scoring_spec$step_facet
        match(facet_level_chr[[sf]], scoring_spec$step_owners)
    }
    if (anyNA(row_owner)) {
        stop("Could not map `newdata` rows to calibrated step owners.", call. = FALSE)
    }
    row_slope_idx <- if (identical(scoring_spec$model, "GPCM") && length(scoring_spec$slope_facet) == 
        1L) {
        slf <- scoring_spec$slope_facet
        match(facet_level_chr[[slf]], as.character(scoring_spec$slope_levels$Level))
    }
    else {
        rep(1L, n_rows)
    }
    if (anyNA(row_slope_idx)) {
        stop("Could not map `newdata` rows to calibrated slope levels.", call. = FALSE)
    }
    all_persons <- unique(person_chr)
    if (is.null(persons)) {
        persons_sel <- all_persons
    }
    else {
        if (!is.character(persons) || !length(persons) || anyNA(persons) || anyDuplicated(persons) || 
            !all(persons %in% all_persons)) {
            stop("`persons` must name distinct Person IDs present in `newdata`.", call. = FALSE)
        }
        persons_sel <- persons
    }
    rows_by_p <- lapply(persons_sel, function(pid) which(person_chr == pid))
    lengths_p <- lengths(rows_by_p)
    person_row_starts <- as.integer(c(0L, cumsum(lengths_p)))
    person_rows <- as.integer(unlist(rows_by_p, use.names = FALSE))
    list(persons = persons_sel, person_chr = person_chr, row_loc_idx = row_loc_idx, facet_signs = as.numeric(unname(scoring_spec$facet_signs)), 
        row_owner = as.integer(row_owner), row_slope_idx = as.integer(row_slope_idx), row_y = as.integer(row_y), 
        observed_score = obs_score, omitted_rows = which(is_miss), person_row_starts = person_row_starts, 
        person_rows = person_rows, repeated_ratings = eff_repeated)
}

.mfrm_posterior_person_score_kernel <- function(n_cat, loc_draws, cum_step_draws, slope_draws, mu_draws, 
    sigma_draws, row_loc_idx, facet_signs, row_owner, row_slope_idx, row_y, person_row_starts, person_rows, 
    probs, cut_scores, score_values, gl_nodes, gl_weights, compute_predictive, keep_person_draws) {
    use_cpp <- !isFALSE(getOption("mfrmr.use_cpp11_backend", TRUE))
    if (use_cpp) {
        return(mfrm_cpp_posterior_person_score(n_cat = as.integer(n_cat), loc_draws = loc_draws, cum_step_draws = cum_step_draws, 
            slope_draws = slope_draws, mu_draws = as.double(mu_draws), sigma_draws = as.double(sigma_draws), 
            row_loc_idx = row_loc_idx, facet_signs = as.double(facet_signs), row_owner = as.integer(row_owner), 
            row_slope_idx = as.integer(row_slope_idx), row_y = as.integer(row_y), person_row_starts = as.integer(person_row_starts), 
            person_rows = as.integer(person_rows), probs = as.double(probs), cut_scores = as.double(cut_scores), 
            score_values = as.double(score_values), gl_nodes = as.double(gl_nodes), gl_weights = as.double(gl_weights), 
            compute_predictive = isTRUE(compute_predictive), keep_person_draws = isTRUE(keep_person_draws)))
    }
    .mfrm_posterior_person_score_r(n_cat = as.integer(n_cat), loc_draws = loc_draws, cum_step_draws = cum_step_draws, 
        slope_draws = slope_draws, mu_draws = as.double(mu_draws), sigma_draws = as.double(sigma_draws), 
        row_loc_idx = row_loc_idx, facet_signs = as.double(facet_signs), row_owner = as.integer(row_owner), 
        row_slope_idx = as.integer(row_slope_idx), row_y = as.integer(row_y), person_row_starts = as.integer(person_row_starts), 
        person_rows = as.integer(person_rows), probs = as.double(probs), cut_scores = as.double(cut_scores), 
        score_values = as.double(score_values), gl_nodes = as.double(gl_nodes), gl_weights = as.double(gl_weights), 
        compute_predictive = isTRUE(compute_predictive), keep_person_draws = isTRUE(keep_person_draws))
}

.mfrm_posterior_person_score_r <- function(n_cat, loc_draws, cum_step_draws, slope_draws, mu_draws, sigma_draws, 
    row_loc_idx, facet_signs, row_owner, row_slope_idx, row_y, person_row_starts, person_rows, probs, 
    cut_scores, score_values, gl_nodes, gl_weights, compute_predictive, keep_person_draws) {
    n_draws <- length(mu_draws)
    n_person <- length(person_row_starts) - 1L
    n_facets <- length(facet_signs)
    n_prob <- length(probs)
    k_cut <- length(cut_scores)
    n_dec_cols <- if (k_cut > 0L) 
        2L * k_cut + 1L
    else 0L
    n_gl <- length(gl_nodes)
    n_pred_rows <- if (compute_predictive) 
        length(person_rows)
    else 0L
    k_max <- n_cat - 1L
    k_seq <- 0:k_max
    status_code <- integer(n_person)
    error_message <- character(n_person)
    observed_count <- integer(n_person)
    omitted_count <- integer(n_person)
    out_mean <- rep(NA_real_, n_person)
    out_within_sd <- rep(NA_real_, n_person)
    out_between_sd <- rep(NA_real_, n_person)
    out_total_sd <- rep(NA_real_, n_person)
    out_log_ml <- rep(NA_real_, n_person)
    out_quantiles <- matrix(NA_real_, nrow = n_person, ncol = n_prob)
    out_dec_probs <- matrix(NA_real_, nrow = n_person, ncol = n_dec_cols)
    out_dec_between_sd <- matrix(NA_real_, nrow = n_person, ncol = n_dec_cols)
    out_pred_probs <- matrix(NA_real_, nrow = n_pred_rows, ncol = if (compute_predictive) 
        n_cat
    else 0L)
    out_pred_exp_sd <- rep(NA_real_, n_pred_rows)
    out_draw_mean <- matrix(NA_real_, nrow = if (keep_person_draws) 
        n_person
    else 0L, ncol = if (keep_person_draws) 
        n_draws
    else 0L)
    out_draw_sd <- matrix(NA_real_, nrow = if (keep_person_draws) 
        n_person
    else 0L, ncol = if (keep_person_draws) 
        n_draws
    else 0L)
    out_draw_log_z <- matrix(NA_real_, nrow = if (keep_person_draws) 
        n_person
    else 0L, ncol = if (keep_person_draws) 
        n_draws
    else 0L)
    eval_post_vec <- function(z_vec, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v, need_deriv = FALSE) {
        theta_vec <- mu_m + sig_m * z_vec
        nz <- length(z_vec)
        ll <- numeric(nz)
        sg <- if (need_deriv) 
            numeric(nz)
        else NULL
        si <- if (need_deriv) 
            numeric(nz)
        else NULL
        for (j in seq_along(y_v)) {
            eta <- theta_vec + delta_v[j]
            u_mat <- alpha_v[j] * (outer(eta, k_seq) - matrix(cs_mat[j, ], nrow = nz, ncol = n_cat, byrow = TRUE))
            rmax <- apply(u_mat, 1L, max)
            emat <- exp(u_mat - rmax)
            den <- rowSums(emat)
            ll <- ll + (u_mat[, y_v[j] + 1L] - rmax) - log(den)
            if (need_deriv) {
                pmat <- emat/den
                ek <- as.numeric(pmat %*% k_seq)
                ek2 <- as.numeric(pmat %*% (k_seq * k_seq))
                sg <- sg + alpha_v[j] * (y_v[j] - ek)
                si <- si + (alpha_v[j] * alpha_v[j]) * pmax(0, ek2 - ek * ek)
            }
        }
        lp <- -0.5 * z_vec * z_vec - 0.918938533204673 + ll
        if (!need_deriv) 
            return(lp)
        list(lp = lp, grad = -z_vec + sig_m * sg, neg_hess = 1 + sig_m * sig_m * si)
    }
    gl_panel_post <- function(a, b, h_star, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v) {
        if (!(b > a)) 
            return(0)
        half <- 0.5 * (b - a)
        mid <- 0.5 * (a + b)
        zq <- mid + half * gl_nodes
        lp <- eval_post_vec(zq, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v, need_deriv = FALSE)
        half * sum(gl_weights * exp(lp - h_star))
    }
    gl_panel_stdnorm <- function(a, b) {
        if (!(b > a)) 
            return(0)
        half <- 0.5 * (b - a)
        mid <- 0.5 * (a + b)
        half * sum(gl_weights * stats::dnorm(mid + half * gl_nodes))
    }
    for (p in seq_len(n_person)) {
        r_start <- person_row_starts[p]
        r_end <- person_row_starts[p + 1L]
        n_p_rows <- r_end - r_start
        local_slots <- if (n_p_rows > 0L) 
            (r_start + 1L):r_end
        else integer(0)
        r_indices <- person_rows[local_slots]
        obs_rows_p <- r_indices[row_y[r_indices] >= 0L]
        m_obs <- length(obs_rows_p)
        observed_count[p] <- m_obs
        omitted_count[p] <- n_p_rows - m_obs
        if (n_draws < 1L) {
            status_code[p] <- 2L
            error_message[p] <- "No calibration draws were supplied for scoring."
            next
        }
        draw_mu_p <- numeric(n_draws)
        draw_var_p <- numeric(n_draws)
        draw_log_z_p <- numeric(n_draws)
        dec_draws <- matrix(0, nrow = n_draws, ncol = n_dec_cols)
        pred_prob_acc <- if (compute_predictive && n_p_rows > 0L) 
            matrix(0, nrow = n_p_rows, ncol = n_cat)
        else NULL
        pred_exp_draws <- if (compute_predictive && n_p_rows > 0L) 
            matrix(0, nrow = n_p_rows, ncol = n_draws)
        else NULL
        failed <- FALSE
        fail_msg <- ""
        if (m_obs == 0L) {
            if (any(!is.finite(mu_draws)) || any(!is.finite(sigma_draws)) || any(sigma_draws <= 0)) {
                status_code[p] <- 2L
                error_message[p] <- "Population mean or SD draw is not finite and positive."
                next
            }
            draw_mu_p <- mu_draws
            draw_var_p <- sigma_draws^2
            draw_log_z_p[] <- 0
            if (k_cut > 0L) {
                for (m in seq_len(n_draws)) {
                  mu_m <- mu_draws[m]
                  sig_m <- sigma_draws[m]
                  edges <- c(-Inf, cut_scores, Inf)
                  bands <- numeric(k_cut + 1L)
                  for (b in seq_len(k_cut + 1L)) {
                    ua <- (edges[b] - mu_m)/sig_m
                    ub <- (edges[b + 1L] - mu_m)/sig_m
                    if (ub <= 0) {
                      pb <- stats::pnorm(ub)
                      pa <- if (is.finite(ua)) 
                        stats::pnorm(ua)
                      else 0
                      val <- pb - pa
                      if (is.finite(ua) && val < 0.5 * pb) {
                        val <- gl_panel_stdnorm(max(-12, ua), min(12, ub))
                      }
                    }
                    else if (ua >= 0) {
                      qa <- stats::pnorm(ua, lower.tail = FALSE)
                      qb <- if (is.finite(ub)) 
                        stats::pnorm(ub, lower.tail = FALSE)
                      else 0
                      val <- qa - qb
                      if (is.finite(ub) && val < 0.5 * qa) {
                        val <- gl_panel_stdnorm(max(-12, ua), min(12, ub))
                      }
                    }
                    else {
                      lp <- if (is.finite(ua)) 
                        (0.5 - stats::pnorm(ua))
                      else 0.5
                      rp <- if (is.finite(ub)) 
                        (0.5 - stats::pnorm(ub, lower.tail = FALSE))
                      else 0.5
                      val <- lp + rp
                    }
                    bands[b] <- max(0, min(1, val))
                  }
                  bsum <- sum(bands)
                  if (!is.finite(bsum) || abs(bsum - 1) > 1e-08) {
                    failed <- TRUE
                    fail_msg <- "Prior-only decision probability normalization failed."
                    break
                  }
                  bands <- bands/bsum
                  above <- pmin(1, rev(cumsum(rev(bands[-1L]))))
                  dec_draws[m, ] <- c(above, bands)
                }
                if (failed) {
                  status_code[p] <- 2L
                  error_message[p] <- fail_msg
                  next
                }
            }
            if (compute_predictive && n_p_rows > 0L) {
                panels <- c(-10, -6, -3.5, -1.5, 0, 1.5, 3.5, 6, 10)
                qz <- unlist(lapply(1:8, function(pan) {
                  0.5 * (panels[pan + 1L] + panels[pan]) + 0.5 * (panels[pan + 1L] - panels[pan]) * gl_nodes
                }), use.names = FALSE)
                qu <- unlist(lapply(1:8, function(pan) {
                  half <- 0.5 * (panels[pan + 1L] - panels[pan])
                  mid <- 0.5 * (panels[pan + 1L] + panels[pan])
                  half * gl_weights * stats::dnorm(mid + half * gl_nodes)
                }), use.names = FALSE)
                qw <- qu/sum(qu)
                for (m in seq_len(n_draws)) {
                  theta_q <- mu_draws[m] + sigma_draws[m] * qz
                  for (rl in seq_len(n_p_rows)) {
                    r0 <- r_indices[rl]
                    delta_r <- if (n_facets > 0L) 
                      sum(facet_signs * loc_draws[m, row_loc_idx[r0, ]])
                    else 0
                    alpha_r <- slope_draws[m, row_slope_idx[r0]]
                    cs_r <- cum_step_draws[m, (row_owner[r0] - 1L) * n_cat + seq_len(n_cat)]
                    u_mat <- alpha_r * (outer(theta_q + delta_r, k_seq) - matrix(cs_r, nrow = length(qz), 
                      ncol = n_cat, byrow = TRUE))
                    rmax <- apply(u_mat, 1L, max)
                    emat <- exp(u_mat - rmax)
                    pmat <- emat/rowSums(emat)
                    p_bar_m <- as.numeric(crossprod(qw, pmat))
                    pred_prob_acc[rl, ] <- pred_prob_acc[rl, ] + p_bar_m
                    pred_exp_draws[rl, m] <- sum(p_bar_m * score_values)
                  }
                }
            }
            mean_p <- mean(draw_mu_p)
            within_var <- mean(draw_var_p)
            between_var <- mean((draw_mu_p - mean_p)^2)
            total_sd <- sqrt(within_var + between_var)
            sig_vec <- sqrt(draw_var_p)
            x_min <- min(draw_mu_p - 12 * sig_vec)
            x_max <- max(draw_mu_p + 12 * sig_vec)
            for (qi in seq_len(n_prob)) {
                pr <- probs[qi]
                if (n_draws == 1L) {
                  out_quantiles[p, qi] <- if (pr <= 0.5) {
                    draw_mu_p[1L] + sig_vec[1L] * stats::qnorm(pr)
                  }
                  else {
                    draw_mu_p[1L] - sig_vec[1L] * stats::qnorm(1 - pr)
                  }
                  next
                }
                lo <- x_min
                hi <- x_max
                x <- mean_p + total_sd * stats::qnorm(pr)
                if (!(x > lo && x < hi)) 
                  x <- 0.5 * (lo + hi)
                prev_width <- hi - lo
                tol_err <- min(1e-12, 1e-08 * min(pr, 1 - pr))
                for (it in seq_len(60L)) {
                  zv <- (x - draw_mu_p)/sig_vec
                  tail_v <- if (pr <= 0.5) 
                    mean(stats::pnorm(zv))
                  else mean(stats::pnorm(zv, lower.tail = FALSE))
                  err <- if (pr <= 0.5) 
                    (tail_v - pr)
                  else ((1 - pr) - tail_v)
                  pdf <- mean(stats::dnorm(zv)/sig_vec)
                  if (err < 0 && x > lo) 
                    lo <- x
                  if (err > 0 && x < hi) 
                    hi <- x
                  if (abs(err) <= tol_err || (hi - lo) <= 1e-13 * max(1, abs(x))) 
                    break
                  x_new <- if (pdf > 0) 
                    (x - err/pdf)
                  else 0.5 * (lo + hi)
                  if (!(x_new > lo && x_new < hi) || abs(x_new - x) > 0.5 * prev_width) {
                    x_new <- 0.5 * (lo + hi)
                  }
                  prev_width <- hi - lo
                  x <- x_new
                }
                out_quantiles[p, qi] <- x
            }
            status_code[p] <- 1L
            out_mean[p] <- mean_p
            out_within_sd[p] <- sqrt(within_var)
            out_between_sd[p] <- sqrt(between_var)
            out_total_sd[p] <- total_sd
            out_log_ml[p] <- 0
        }
        else {
            y_v <- row_y[obs_rows_p]
            draw_z_star <- numeric(n_draws)
            draw_d1 <- numeric(n_draws)
            draw_d2 <- numeric(n_draws)
            draw_d3 <- numeric(n_draws)
            draw_h_star <- numeric(n_draws)
            draw_i0 <- numeric(n_draws)
            draw_panel0 <- numeric(n_draws)
            draw_panel1 <- numeric(n_draws)
            draw_panel2 <- numeric(n_draws)
            draw_panel5 <- numeric(n_draws)
            draw_panel6 <- numeric(n_draws)
            draw_panel7 <- numeric(n_draws)
            failed <- FALSE
            fail_msg <- ""
            for (m in seq_len(n_draws)) {
                mu_m <- mu_draws[m]
                sig_m <- sigma_draws[m]
                delta_v <- if (n_facets > 0L) {
                  as.numeric(matrix(loc_draws[m, row_loc_idx[obs_rows_p, , drop = FALSE]], nrow = m_obs) %*% 
                    facet_signs)
                }
                else {
                  numeric(m_obs)
                }
                alpha_v <- as.numeric(slope_draws[m, row_slope_idx[obs_rows_p]])
                if (any(!is.finite(delta_v)) || any(!is.finite(alpha_v)) || any(alpha_v <= 0)) {
                  failed <- TRUE
                  fail_msg <- "Facet location or slope draw is not finite and positive."
                  break
                }
                cs_mat <- t(vapply(obs_rows_p, function(r0) {
                  cum_step_draws[m, (row_owner[r0] - 1L) * n_cat + seq_len(n_cat)]
                }, numeric(n_cat)))
                s1 <- sum(alpha_v * y_v)
                a_sum <- sum(alpha_v)
                a_max <- max(alpha_v)
                z_lo <- sig_m * (s1 - k_max * a_sum)
                z_hi <- sig_m * s1
                z <- if (0 > z_lo && 0 < z_hi) 
                  0
                else 0.5 * (z_lo + z_hi)
                for (it in seq_len(60L)) {
                  ev <- eval_post_vec(z, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v, need_deriv = TRUE)
                  g <- ev$grad[1L]
                  nh <- ev$neg_hess[1L]
                  if (g > 0 && z > z_lo) 
                    z_lo <- z
                  if (g < 0 && z < z_hi) 
                    z_hi <- z
                  if (abs(g) <= 1e-13 || (z_hi - z_lo) <= 1e-14 * max(1, abs(z))) 
                    break
                  z_new <- z + g/nh
                  if (!(z_new > z_lo && z_new < z_hi)) 
                    z_new <- 0.5 * (z_lo + z_hi)
                  z <- z_new
                }
                ev_star <- eval_post_vec(z, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v, need_deriv = TRUE)
                h_val <- ev_star$lp[1L]
                if (!is.finite(h_val) || abs(ev_star$grad[1L]) > 1e-08 || ev_star$neg_hess[1L] < 1) {
                  failed <- TRUE
                  fail_msg <- "Conditional posterior mode optimization did not converge."
                  break
                }
                s_eff <- min(1/sqrt(ev_star$neg_hess[1L]), 1.5/(sig_m * a_max))
                d1 <- max(1e-04, min(1, 2.5 * s_eff))
                d2 <- max(2 * d1, min(2.6, 7 * s_eff))
                d3 <- max(1.6 * d2, min(5.2, 4.5 * sqrt(s_eff)))
                panels <- c(z - 10, z - d3, z - d2, z - d1, z, z + d1, z + d2, z + d3, z + 10)
                qz_list <- vector("list", 8L)
                qu_list <- vector("list", 8L)
                panel_mass <- numeric(8L)
                for (pan in 1:8) {
                  half <- 0.5 * (panels[pan + 1L] - panels[pan])
                  mid <- 0.5 * (panels[pan + 1L] + panels[pan])
                  zq <- mid + half * gl_nodes
                  lpq <- eval_post_vec(zq, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v, need_deriv = FALSE)
                  uq <- half * gl_weights * exp(lpq - h_val)
                  qz_list[[pan]] <- zq
                  qu_list[[pan]] <- uq
                  panel_mass[pan] <- sum(uq)
                }
                qz <- unlist(qz_list, use.names = FALSE)
                qu <- unlist(qu_list, use.names = FALSE)
                i0 <- sum(panel_mass)
                dz_vec <- qz - z
                dz_mean <- sum(dz_vec * qu)/i0
                var_z <- sum((dz_vec * dz_vec) * qu)/i0 - dz_mean * dz_mean
                if (!is.finite(i0) || i0 <= 0 || !is.finite(var_z) || var_z <= 0) {
                  failed <- TRUE
                  fail_msg <- "Conditional posterior moments are non-positive or non-finite."
                  break
                }
                draw_mu_p[m] <- mu_m + sig_m * (z + dz_mean)
                draw_var_p[m] <- sig_m * sig_m * var_z
                draw_log_z_p[m] <- h_val + log(i0)
                draw_z_star[m] <- z
                draw_d1[m] <- d1
                draw_d2[m] <- d2
                draw_d3[m] <- d3
                draw_h_star[m] <- h_val
                draw_i0[m] <- i0
                draw_panel0[m] <- panel_mass[1L]
                draw_panel1[m] <- panel_mass[2L]
                draw_panel2[m] <- panel_mass[3L]
                draw_panel5[m] <- panel_mass[6L]
                draw_panel6[m] <- panel_mass[7L]
                draw_panel7[m] <- panel_mass[8L]
                if (k_cut > 0L) {
                  bands <- numeric(k_cut + 1L)
                  for (b in seq_len(k_cut + 1L)) {
                    za <- if (b == 1L) 
                      panels[1L]
                    else max(panels[1L], min(panels[9L], (cut_scores[b - 1L] - mu_m)/sig_m))
                    zb <- if (b == k_cut + 1L) 
                      panels[9L]
                    else max(panels[1L], min(panels[9L], (cut_scores[b] - mu_m)/sig_m))
                    bm <- 0
                    if (zb > za) {
                      for (pan in 1:8) {
                        sa <- max(za, panels[pan])
                        sb <- min(zb, panels[pan + 1L])
                        if (sb > sa) {
                          if (sa == panels[pan] && sb == panels[pan + 1L]) {
                            bm <- bm + panel_mass[pan]
                          }
                          else {
                            bm <- bm + gl_panel_post(sa, sb, h_val, mu_m, sig_m, delta_v, alpha_v, cs_mat, 
                              y_v)
                          }
                        }
                      }
                    }
                    bands[b] <- max(0, bm/i0)
                  }
                  bsum <- sum(bands)
                  if (!is.finite(bsum) || abs(bsum - 1) > 1e-08) {
                    failed <- TRUE
                    fail_msg <- "Decision probability band partition failed accuracy check."
                    break
                  }
                  bands <- bands/bsum
                  above <- pmin(1, rev(cumsum(rev(bands[-1L]))))
                  dec_draws[m, ] <- c(above, bands)
                }
                if (compute_predictive && n_p_rows > 0L) {
                  qw <- qu/i0
                  theta_q <- mu_m + sig_m * qz
                  for (rl in seq_len(n_p_rows)) {
                    r0 <- r_indices[rl]
                    delta_r <- if (n_facets > 0L) 
                      sum(facet_signs * loc_draws[m, row_loc_idx[r0, ]])
                    else 0
                    alpha_r <- slope_draws[m, row_slope_idx[r0]]
                    cs_r <- cum_step_draws[m, (row_owner[r0] - 1L) * n_cat + seq_len(n_cat)]
                    u_mat <- alpha_r * (outer(theta_q + delta_r, k_seq) - matrix(cs_r, nrow = length(qz), 
                      ncol = n_cat, byrow = TRUE))
                    rmax <- apply(u_mat, 1L, max)
                    emat <- exp(u_mat - rmax)
                    pmat <- emat/rowSums(emat)
                    p_bar_m <- as.numeric(crossprod(qw, pmat))
                    pred_prob_acc[rl, ] <- pred_prob_acc[rl, ] + p_bar_m
                    pred_exp_draws[rl, m] <- sum(p_bar_m * score_values)
                  }
                }
            }
            if (failed) {
                status_code[p] <- 2L
                error_message[p] <- fail_msg
                next
            }
            mean_p <- mean(draw_mu_p)
            within_var <- mean(draw_var_p)
            between_var <- mean((draw_mu_p - mean_p)^2)
            total_sd <- sqrt(within_var + between_var)
            max_lz <- max(draw_log_z_p)
            log_ml <- max_lz + log(mean(exp(draw_log_z_p - max_lz)))
            x_min <- min(mu_draws + sigma_draws * (draw_z_star - 10))
            x_max <- max(mu_draws + sigma_draws * (draw_z_star + 10))
            for (qi in seq_len(n_prob)) {
                pr <- probs[qi]
                lo <- x_min
                hi <- x_max
                x <- mean_p + total_sd * stats::qnorm(pr)
                if (!(x > lo && x < hi)) 
                  x <- 0.5 * (lo + hi)
                prev_width <- hi - lo
                tol_err <- min(1e-12, 1e-08 * min(pr, 1 - pr))
                final_err <- 1
                for (it in seq_len(60L)) {
                  sum_tail <- 0
                  sum_pdf <- 0
                  for (m in seq_len(n_draws)) {
                    mu_m <- mu_draws[m]
                    sig_m <- sigma_draws[m]
                    zs <- draw_z_star[m]
                    zx <- (x - mu_m)/sig_m
                    if (zx <= zs - 10) {
                      if (pr > 0.5) 
                        sum_tail <- sum_tail + 1
                      next
                    }
                    if (zx >= zs + 10) {
                      if (pr <= 0.5) 
                        sum_tail <- sum_tail + 1
                      next
                    }
                    delta_v <- if (n_facets > 0L) {
                      as.numeric(matrix(loc_draws[m, row_loc_idx[obs_rows_p, , drop = FALSE]], nrow = m_obs) %*% 
                        facet_signs)
                    }
                    else {
                      numeric(m_obs)
                    }
                    alpha_v <- as.numeric(slope_draws[m, row_slope_idx[obs_rows_p]])
                    cs_mat <- t(vapply(obs_rows_p, function(r0) {
                      cum_step_draws[m, (row_owner[r0] - 1L) * n_cat + seq_len(n_cat)]
                    }, numeric(n_cat)))
                    d1 <- draw_d1[m]
                    d2 <- draw_d2[m]
                    d3 <- draw_d3[m]
                    hs <- draw_h_star[m]
                    i0 <- draw_i0[m]
                    lp_x <- eval_post_vec(zx, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v, need_deriv = FALSE)
                    sum_pdf <- sum_pdf + exp(lp_x - hs)/(sig_m * i0)
                    if (zx <= zs - d3) {
                      lm <- gl_panel_post(zs - 10, zx, hs, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v)
                      f_m <- min(1, max(0, lm/i0))
                      u_m <- 1 - f_m
                    }
                    else if (zx <= zs - d2) {
                      lm <- draw_panel0[m] + gl_panel_post(zs - d3, zx, hs, mu_m, sig_m, delta_v, alpha_v, 
                        cs_mat, y_v)
                      f_m <- min(1, max(0, lm/i0))
                      u_m <- 1 - f_m
                    }
                    else if (zx <= zs - d1) {
                      lm <- draw_panel0[m] + draw_panel1[m] + gl_panel_post(zs - d2, zx, hs, mu_m, sig_m, 
                        delta_v, alpha_v, cs_mat, y_v)
                      f_m <- min(1, max(0, lm/i0))
                      u_m <- 1 - f_m
                    }
                    else if (zx <= zs) {
                      lm <- draw_panel0[m] + draw_panel1[m] + draw_panel2[m] + gl_panel_post(zs - d1, 
                        zx, hs, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v)
                      f_m <- min(1, max(0, lm/i0))
                      u_m <- 1 - f_m
                    }
                    else if (zx < zs + d1) {
                      rm <- gl_panel_post(zx, zs + d1, hs, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v) + 
                        draw_panel5[m] + draw_panel6[m] + draw_panel7[m]
                      u_m <- min(1, max(0, rm/i0))
                      f_m <- 1 - u_m
                    }
                    else if (zx < zs + d2) {
                      rm <- gl_panel_post(zx, zs + d2, hs, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v) + 
                        draw_panel6[m] + draw_panel7[m]
                      u_m <- min(1, max(0, rm/i0))
                      f_m <- 1 - u_m
                    }
                    else if (zx < zs + d3) {
                      rm <- gl_panel_post(zx, zs + d3, hs, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v) + 
                        draw_panel7[m]
                      u_m <- min(1, max(0, rm/i0))
                      f_m <- 1 - u_m
                    }
                    else {
                      rm <- gl_panel_post(zx, zs + 10, hs, mu_m, sig_m, delta_v, alpha_v, cs_mat, y_v)
                      u_m <- min(1, max(0, rm/i0))
                      f_m <- 1 - u_m
                    }
                    sum_tail <- sum_tail + if (pr <= 0.5) 
                      f_m
                    else u_m
                  }
                  err <- if (pr <= 0.5) 
                    (sum_tail/n_draws - pr)
                  else ((1 - pr) - sum_tail/n_draws)
                  pdf <- sum_pdf/n_draws
                  final_err <- abs(err)
                  if (err < 0 && x > lo) 
                    lo <- x
                  if (err > 0 && x < hi) 
                    hi <- x
                  if (final_err <= tol_err || (hi - lo) <= 1e-13 * max(1, abs(x))) 
                    break
                  x_new <- if (pdf > 0) 
                    (x - err/pdf)
                  else 0.5 * (lo + hi)
                  if (!(x_new > lo && x_new < hi) || abs(x_new - x) > 0.5 * prev_width) {
                    x_new <- 0.5 * (lo + hi)
                  }
                  prev_width <- hi - lo
                  x <- x_new
                }
                if (final_err > 1e-07 && (hi - lo) > 1e-09 * max(1, abs(x))) {
                  failed <- TRUE
                  fail_msg <- "Continuous posterior quantile root-finding did not reach target accuracy."
                  break
                }
                out_quantiles[p, qi] <- x
            }
            if (failed) {
                status_code[p] <- 2L
                error_message[p] <- fail_msg
                next
            }
            status_code[p] <- 0L
            out_mean[p] <- mean_p
            out_within_sd[p] <- sqrt(within_var)
            out_between_sd[p] <- sqrt(between_var)
            out_total_sd[p] <- total_sd
            out_log_ml[p] <- log_ml
        }
        if (n_dec_cols > 0L) {
            dec_mean <- colMeans(dec_draws)
            out_dec_probs[p, ] <- pmin(1, pmax(0, dec_mean))
            out_dec_between_sd[p, ] <- sqrt(colMeans(sweep(dec_draws, 2L, dec_mean, "-")^2))
        }
        if (compute_predictive && n_p_rows > 0L) {
            p_mat <- pred_prob_acc/n_draws
            p_mat <- p_mat/rowSums(p_mat)
            out_pred_probs[local_slots, ] <- p_mat
            mean_exp <- rowMeans(pred_exp_draws)
            out_pred_exp_sd[local_slots] <- sqrt(rowMeans((pred_exp_draws - mean_exp)^2))
        }
        if (keep_person_draws) {
            out_draw_mean[p, ] <- draw_mu_p
            out_draw_sd[p, ] <- sqrt(draw_var_p)
            out_draw_log_z[p, ] <- draw_log_z_p
        }
    }
    list(status_code = status_code, error_message = error_message, observed_count = observed_count, omitted_count = omitted_count, 
        mean = out_mean, within_sd = out_within_sd, between_sd = out_between_sd, total_sd = out_total_sd, 
        log_marginal_lik = out_log_ml, quantiles = out_quantiles, decision_probs = out_dec_probs, decision_between_sd = out_dec_between_sd, 
        pred_probs = out_pred_probs, pred_expected_mean_sd = out_pred_exp_sd, draw_mean = out_draw_mean, 
        draw_sd = out_draw_sd, draw_log_z = out_draw_log_z)
}

.mfrm_posterior_decision_table <- function(probabilities, between_sd, persons, cut_scores, prior_mean, 
    prior_sd, status, reason, uncertainty_label) {
    k <- length(cut_scores)
    n <- length(persons)
    cols <- 2L * k + 1L
    labels <- names(cut_scores) %||% paste0("Cut", seq_len(k))
    data.frame(Person = rep(persons, each = cols), Type = rep(c(rep("above_cut", k), rep("ability_band", 
        k + 1L)), n), Label = rep(c(labels, paste0("Band", seq_len(k + 1L))), n), Lower = rep(c(unname(cut_scores), 
        -Inf, unname(cut_scores)), n), Upper = rep(c(rep(Inf, k), unname(cut_scores), Inf), n), Probability = as.vector(t(probabilities)), 
        ProbabilityBetweenSD = as.vector(t(between_sd)), PriorMean = rep(rep_len(prior_mean, n), each = cols), 
        PriorSD = rep(rep_len(prior_sd, n), each = cols), Status = rep(rep_len(status, n), each = cols), 
        Reason = rep(rep_len(reason, n), each = cols), Uncertainty = rep(uncertainty_label, n * cols), 
        stringsAsFactors = FALSE)
}

.mfrm_build_posterior_predictive_table <- function(newdata, prep, scoring_spec, pred_probs, pred_expected_mean_sd, 
    person_status) {
    sc <- scoring_spec$source_columns
    facet_cols <- sc$facets %||% scoring_spec$facet_names
    r_idx <- prep$person_rows
    score_vals <- as.numeric(scoring_spec$categories$Score)
    exp_score <- as.numeric(pred_probs %*% score_vals)
    exp_score2 <- as.numeric(pred_probs %*% (score_vals * score_vals))
    pred_sd <- sqrt(pmax(0, exp_score2 - exp_score * exp_score))
    obs_s <- prep$observed_score[r_idx]
    residual <- ifelse(is.na(obs_s) | is.na(exp_score), NA_real_, obs_s - exp_score)
    modal_score <- apply(pred_probs, 1L, function(pr) {
        if (anyNA(pr)) 
            NA_real_
        else score_vals[which.max(pr)]
    })
    prob_names <- paste0("Prob_", sub("^-", "neg", chartr(".", "_", as.character(scoring_spec$categories$Score))))
    prob_df <- as.data.frame(pred_probs, stringsAsFactors = FALSE)
    names(prob_df) <- prob_names
    out <- cbind(data.frame(Row = r_idx, Person = prep$person_chr[r_idx], newdata[r_idx, facet_cols, 
        drop = FALSE], ObservedScore = obs_s, ExpectedScore = exp_score, PredictiveSD = pred_sd, ExpectedMeanSD = pred_expected_mean_sd, 
        Residual = residual, ModalScore = as.numeric(modal_score), stringsAsFactors = FALSE), prob_df, 
        data.frame(PersonStatus = unname(person_status[prep$person_chr[r_idx]]), stringsAsFactors = FALSE))
    rownames(out) <- NULL
    out
}

.mfrm_posterior_scoring_notes <- function(object, conditioning, has_cuts, has_pred, any_cal_member) {
    cond_note <- if (identical(conditioning, "posterior")) {
        paste("Conditioning = 'posterior': each new Person's posterior integrates ability continuously within every saved MCMC calibration draw and averages equally across draws (1/M).", 
            "Calibration uncertainty is propagated into SD, [Lower, Upper], decisions and predictive rows without updating calibration parameters from new Person ratings.")
    }
    else {
        paste("Conditioning = 'plugin_mean': scores condition on marginal posterior-mean calibration parameters (exp(mean(log_component_slopes)) for one-family GPCM).", 
            "Calibration-estimation uncertainty is excluded (BetweenSD = NA).")
    }
    var_note <- paste("For posterior mixture scoring, SD^2 = WithinSD^2 + BetweenSD^2 under the 1/M mixture law of total variance;", 
        "Median, Lower and Upper invert the exact continuous mixture CDF.")
    ml_note <- paste("PersonLogMarginalLikelihood integrates over the new-Person normal ability prior within each calibration draw before averaging on the probability scale;", 
        "unlike existing-Person log_lik in predictive-draws.rds, it measures out-of-sample Person marginal likelihood.")
    screen_note <- paste0("Calibration sampling screen (", object$decision$Status[1L], "): ", object$decision$Interpretation[1L], 
        " Bayesian posterior credible intervals depend on the likelihood, priors and fixed anchors, and do not guarantee frequentist coverage.")
    cut_note <- if (has_cuts) {
        "Cut-score probabilities describe Lower < ability <= Upper on the exported ability metric; cut labels do not establish external standard alignment."
    }
    else {
        character(0)
    }
    pred_note <- if (has_pred) {
        "PredictiveSD reflects discrete category variation plus ability and (when conditioning = 'posterior') calibration uncertainty; ExpectedMeanSD summarizes between-draw spread of the conditional expected score."
    }
    else {
        character(0)
    }
    cal_note <- if (any_cal_member) {
        "Warning: one or more scored Persons belonged to the calibration sample (`CalibrationMember = TRUE`); their ratings already informed the saved calibration posterior."
    }
    else {
        character(0)
    }
    c(cond_note, var_note, ml_note, screen_note, cut_note, pred_note, cal_note)
}

.mfrm_validate_posterior_scores <- function(x) {
    fail <- function() {
        stop("Inconsistent `mfrm_posterior_scores` object; recompute scores with `predict(posterior, newdata = ...)`.", 
            call. = FALSE)
    }
    if (!inherits(x, "mfrm_posterior_scores") || !is.list(x) || !is.data.frame(x$estimates) || !nrow(x$estimates) || 
        !is.list(x$settings) || !is.data.frame(x$source) || nrow(x$source) != 1L || !is.data.frame(x$posterior_decision) || 
        nrow(x$posterior_decision) != 1L) {
        fail()
    }
    s <- x$settings
    if (!is.character(s$conditioning) || length(s$conditioning) != 1L || !s$conditioning %in% c("posterior", 
        "plugin_mean") || !is.numeric(s$level) || length(s$level) != 1L || !is.finite(s$level) || s$level <= 
        0 || s$level >= 1 || !identical(s$calibration_uncertainty, identical(s$conditioning, "posterior")) || 
        !identical(s$new_person_updates_calibration, FALSE)) {
        fail()
    }
    est <- x$estimates
    req_cols <- c("Person", "Observed", "Omitted", "ObservedMean", "Estimate", "Median", "SD", "WithinSD", 
        "BetweenSD", "CalibrationVarShare", "Lower", "Upper", "PriorMean", "PriorSD", "PersonLogMarginalLikelihood", 
        "IntegrationMaxDiff", "CalibrationMember", "CalibrationUncertainty", "SamplingReview", "Status", 
        "Reason")
    if (!all(req_cols %in% names(est)) || anyNA(est$Person) || anyDuplicated(est$Person)) {
        fail()
    }
    valid_st <- c("available_posterior", "available_conditional", "prior_only", "unavailable")
    if (anyNA(est$Status) || !all(est$Status %in% valid_st)) 
        fail()
    ok <- est$Status != "unavailable"
    if (any(ok)) {
        e_ok <- est[ok, , drop = FALSE]
        if (any(!is.finite(e_ok$Estimate)) || any(!is.finite(e_ok$Median)) || any(!is.finite(e_ok$SD)) || 
            any(e_ok$SD <= 0) || any(!is.finite(e_ok$WithinSD)) || any(e_ok$WithinSD <= 0) || any(!is.finite(e_ok$Lower)) || 
            any(!is.finite(e_ok$Upper)) || any(e_ok$Lower > e_ok$Median + 1e-10) || any(e_ok$Median > 
            e_ok$Upper + 1e-10) || any(e_ok$SD + 1e-10 < e_ok$WithinSD)) {
            fail()
        }
        if (isTRUE(s$calibration_uncertainty)) {
            if (any(!is.finite(e_ok$BetweenSD)) || any(e_ok$BetweenSD < 0) || any(abs(e_ok$SD^2 - (e_ok$WithinSD^2 + 
                e_ok$BetweenSD^2)) > 1e-08 * pmax(1, e_ok$SD^2))) {
                fail()
            }
        }
        else if (any(!is.na(e_ok$BetweenSD)) || any(!is.na(e_ok$CalibrationVarShare))) {
            fail()
        }
        if (any(!is.na(e_ok$PersonLogMarginalLikelihood[e_ok$CalibrationMember]))) {
            fail()
        }
    }
    unav <- est$Status == "unavailable"
    if (any(unav)) {
        if (any(!is.na(as.matrix(est[unav, c("Estimate", "Median", "SD", "WithinSD", "BetweenSD", "Lower", 
            "Upper"), drop = FALSE])))) {
            fail()
        }
    }
    if (!is.null(x$decisions)) {
        cuts <- mfrm_validate_cut_scores(s$cut_scores)
        if (is.null(cuts) || !is.data.frame(x$decisions)) 
            fail()
        k <- length(cuts)
        cols <- 2L * k + 1L
        if (nrow(x$decisions) != nrow(est) * cols) 
            fail()
        for (p_id in est$Person) {
            d_p <- x$decisions[x$decisions$Person == p_id, , drop = FALSE]
            st_p <- est$Status[est$Person == p_id]
            if (st_p == "unavailable") {
                if (!all(is.na(d_p$Probability))) 
                  fail()
            }
            else {
                pr <- d_p$Probability
                if (any(!is.finite(pr)) || any(pr < 0 | pr > 1)) 
                  fail()
                bands <- pr[(k + 1L):cols]
                if (abs(sum(bands) - 1) > 1e-08 || max(abs(pr[seq_len(k)] - rev(cumsum(rev(bands[-1L]))))) > 
                  1e-08) {
                  fail()
                }
            }
        }
    }
    if (!is.null(x$predictive)) {
        pr_df <- x$predictive
        if (!is.data.frame(pr_df) || !all(c("Row", "Person", "ExpectedScore", "PredictiveSD") %in% names(pr_df))) {
            fail()
        }
        p_cols <- grep("^Prob_", names(pr_df), value = TRUE)
        if (length(p_cols) != nrow(x$categories)) 
            fail()
        if ("Status" %in% names(pr_df)) {
            if (!all(c("Reason", "IntegrationMaxDiff") %in% names(pr_df)) || anyNA(pr_df$Status) || !all(pr_df$Status %in% 
                c("available_posterior", "available_conditional", "unavailable"))) 
                fail()
            ok_rows <- pr_df$Status != "unavailable"
            if (any(ok_rows & pr_df$PersonStatus == "unavailable") || any(!is.finite(pr_df$IntegrationMaxDiff[ok_rows])) || 
                any(pr_df$IntegrationMaxDiff[ok_rows] > 1e-06)) 
                fail()
            withheld <- c(p_cols, "ExpectedScore", "PredictiveSD", "ExpectedMeanSD", "Residual", "ModalScore")
            if (any(!is.na(as.matrix(pr_df[!ok_rows, withheld, drop = FALSE])))) 
                fail()
        }
        else {
            ok_rows <- pr_df$PersonStatus != "unavailable"
        }
        if (any(ok_rows)) {
            pmat <- as.matrix(pr_df[ok_rows, p_cols, drop = FALSE])
            if (any(!is.finite(pmat)) || any(pmat < -1e-12 | pmat > 1 + 1e-12) || max(abs(rowSums(pmat) - 
                1)) > 1e-07) {
                fail()
            }
        }
    }
    invisible(x)
}
