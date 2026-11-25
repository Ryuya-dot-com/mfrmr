mfrm_fit_response_values <- function(object, type, residual = FALSE) {
    if (inherits(object, c("mfrm_cml_fit", "mfrm_comparison_fit"))) 
        stop("CML/comparison-only fits do not supply primary Person estimates for plug-in rating predictions; use their documented conditional summaries.", 
            call. = FALSE)
    mfrm_extractor_native(object)
    if (mfrm_has_jml_adjustment(object) || mfrm_has_product_slopes(object)) 
        stop("Use mfrm_response_diagnostics() for supported corrected-JML or two-family response calculations; their probability definitions differ from ordinary plug-in extraction.", 
            call. = FALSE)
    cfg <- object$config
    prep <- object$prep
    if (!cfg$method %in% c("MML", "JML") || !cfg$model %in% c("RSM", "PCM", "GPCM") || !identical(cfg$facet_shrinkage %||% 
        "none", "none")) 
        stop("Plug-in rating extraction requires an ordinary unpenalized MML or JML fit.", call. = FALSE)
    structural <- c(object$facets$others[["Estimate"]], object$steps[["Estimate"]], object$slopes[["Estimate"]])
    if (any(!is.finite(structural)) || any(!is.finite(object$opt$par))) 
        stop("Finite structural calibration is required; nonfinite primary estimates cannot be replaced by optimizer proxies.", 
            call. = FALSE)
    if (cfg$model == "GPCM" && (!length(object$slopes[["Estimate"]]) || any(object$slopes[["Estimate"]] <= 
        0))) 
        stop("GPCM plug-in responses require strictly positive primary slopes; joint slope/ability boundary limits are not supplied.", 
            call. = FALSE)
    theta <- mfrm_saved_person_estimates(object)
    idx <- build_indices(prep, step_facet = cfg$step_facet, slope_facet = cfg$slope_facet, interaction_specs = cfg$interaction_specs)
    params <- expand_params(object$opt$par, build_param_sizes(cfg), cfg)
    finite_theta <- theta
    finite_theta[!is.finite(finite_theta)] <- 0
    eta <- compute_eta(idx, params, cfg, theta_override = finite_theta)
    p <- compute_response_probability_bundle(cfg, idx, params, eta)$probs
    row_theta <- theta[idx$person]
    boundary <- cfg$method == "JML" & is.infinite(row_theta)
    unavailable <- !is.finite(row_theta) & !boundary
    p[unavailable, ] <- NA_real_
    if (any(boundary)) {
        p[boundary, ] <- 0
        p[cbind(which(boundary), ifelse(row_theta[boundary] > 0, ncol(p), 1L))] <- 1
    }
    valid <- rowSums(!is.finite(p) | p < 0 | p > 1) == 0 & abs(rowSums(p) - 1) <= 1e-10
    valid[is.na(valid)] <- FALSE
    p[!valid, ] <- NA_real_
    categories <- prep$rating_min + seq_len(ncol(p)) - 1L
    mu <- drop(p %*% categories)
    variance <- mfrm_category_variance(p, categories, mu)
    raw <- prep$data$Score - mu
    pearson <- rep(NA_real_, length(mu))
    positive <- valid & is.finite(variance) & variance > 0
    pearson[positive] <- raw[positive]/sqrt(variance[positive])
    pearson[!is.finite(pearson)] <- NA_real_
    diagnostics <- data.frame(Row = seq_along(mu), ProbabilityAvailable = valid, PearsonAvailable = is.finite(pearson), 
        Variance = variance, Status = ifelse(valid, "available_plugin", "unavailable"), Reason = ifelse(valid, 
            "Conditional point calculation; calibration and Person uncertainty are excluded.", "Conditional probabilities are unavailable at the saved primary estimates."))
    diagnostics$Reason[unavailable] <- "A finite primary Person estimate is unavailable; no optimizer or display proxy was substituted."
    zero <- valid & is.finite(variance) & variance == 0
    diagnostics$Status[zero] <- "zero_variance"
    diagnostics$Reason[zero] <- "Conditional variance is zero; the mean and raw residual remain available, but the Pearson residual is undefined."
    diagnostics$Reason[boundary] <- paste("Limiting probabilities at an infinite JML Person estimate.", 
        diagnostics$Reason[boundary])
    ids <- as.character(seq_along(mu))
    dimnames(p) <- list(ids, as.character(categories))
    out <- if (residual) 
        if (type == "pearson") 
            pearson
        else raw
    else if (type == "prob") 
        p
    else mu
    if (!is.matrix(out)) 
        names(out) <- ids
    rows <- data.frame(Row = seq_along(mu), InputRow = NA_integer_)
    n_input <- prep$row_retention$Rows[match("input_selected_columns", prep$row_retention$Stage)]
    omitted <- prep$omitted_input_rows %||% integer()
    if (length(n_input) == 1L && is.finite(n_input) && n_input >= nrow(rows) && is.numeric(omitted) && 
        !is.complex(omitted) && !anyNA(omitted) && !anyDuplicated(omitted) && all(omitted >= 1 & omitted <= 
        n_input & omitted == floor(omitted)) && n_input - length(omitted) == nrow(rows)) 
        rows$InputRow <- setdiff(seq_len(n_input), omitted)
    attr(out, "rows") <- rows
    attr(out, "identifiers") <- as.data.frame(prep$data[c("Person", cfg$facet_names)])
    attr(out, "score_map") <- prep$score_map
    attr(out, "diagnostics") <- diagnostics
    attr(out, "settings") <- list(target = "Conditional plug-in source ratings", quantity = if (residual) if (type == 
        "pearson") "Pearson residual" else "raw residual" else if (type == "prob") "category probabilities" else "expected rating", 
        person_basis = if (cfg$method == "MML") "saved EAP" else "primary JML estimate, including boundary limits", 
        score_scale = "modeled categories", calibration_uncertainty = FALSE, limitation = "Same-data descriptive values; no convergence, goodness-of-fit, forecast or coverage guarantee.")
    attr(out, "source_readiness") <- mfrmr_get_readiness_record(object)$fit
    out
}

fitted.mfrm_fit <- function(object, type = c("response", "prob"), ...) {
    rlang::check_dots_empty()
    mfrm_fit_response_values(object, match.arg(type))
}

residuals.mfrm_fit <- function(object, type = c("response", "pearson"), ...) {
    rlang::check_dots_empty()
    mfrm_fit_response_values(object, match.arg(type), residual = TRUE)
}

predict.mfrm_fit <- function(object, newdata = NULL,
    type = c("response", "prob", "probs", "link", "fair", "wle", "eap"),
    person_data = NULL, facet_data = NULL, se.fit = FALSE, ...) {
    type <- match.arg(type)
    if (is.null(newdata) && type %in% c("response", "prob") && !isTRUE(se.fit)) {
        rlang::check_dots_empty()
        return(fitted(object, type = type))
    }
    if (identical(type, "prob")) type <- "probs"
    if (identical(type, "fair")) {
        ft <- fair_average_table(object)
        p_df <- ft$raw_by_facet$Person
        return(stats::setNames(p_df$FairM, p_df$Level))
    }
    if (identical(type, "wle") && is.null(newdata)) {
        w_df <- score_mfrm_wle(object)
        return(data.frame(Person = w_df$Person, Estimate = w_df$WLE, SE = w_df$WLE_SE, stringsAsFactors = FALSE))
    }
    if (identical(type, "eap")) {
        if (!is.null(newdata)) stop("EAP scoring of new ratings is unavailable. Omit `newdata` for fitted EAP scores.", call. = FALSE)
        p_tbl <- object$facets$person
        return(data.frame(Person = p_tbl$Person, Estimate = p_tbl$Estimate, SE = p_tbl$SD %||% NA_real_, stringsAsFactors = FALSE))
    }
    st <- .mfrm_as_fast_state(object)
    enc <- st$enc
    if (is.null(newdata)) {
        th_row <- st$theta[enc$person0 + 1L]
        base_eta <- numeric(enc$n_obs)
        for (f in seq_along(enc$base_facets)) {
            base_eta <- base_eta + enc$facet_signs[f] * st$beta_list[[f]][enc$facet_mat0[, f] + 1L]
        }
        eta_vec <- th_row + base_eta
        sg0 <- enc$step_group0
    } else {
        if (!is.data.frame(newdata) || nrow(newdata) == 0L) {
            stop("`newdata` must be a non-empty data.frame.", call. = FALSE)
        }
        miss_f <- setdiff(enc$base_facets, names(newdata))
        if (length(miss_f) > 0L) {
            stop("`newdata` is missing facet column(s): ", paste(miss_f, collapse = ", "), ".", call. = FALSE)
        }
        N_new <- nrow(newdata)
        base_eta <- numeric(N_new)
        for (f in seq_along(enc$base_facets)) {
            fnm <- enc$base_facets[f]
            m_old <- match(as.character(newdata[[fnm]]), enc$facet_levels[[f]])
            if (anyNA(m_old)) {
                stop("Unknown level(s) in `newdata[['", fnm, "']]`.", call. = FALSE)
            }
            base_eta <- base_eta + enc$facet_signs[f] * st$beta_list[[f]][m_old]
        }
        sg0 <- if (enc$model_code == 1L) {
            m_sg <- match(as.character(newdata[[enc$step_facet]]), enc$step_owners)
            if (anyNA(m_sg)) stop("Unknown step_facet level in `newdata`.", call. = FALSE)
            as.integer(m_sg - 1L)
        } else {
            integer(N_new)
        }
        if (identical(type, "wle")) {
            scoring <- .mfrm_wle_newdata(newdata, enc, sg0)
            ans <- mfrm_cpp_fast_wle(
                as.integer(length(scoring$levels)), as.integer(enc$n_cat),
                scoring$person0, scoring$score0, rep(1.0, N_new), as.double(base_eta),
                st$step_cum, sg0, enc$step_cat_min, enc$step_cat_max
            )
            return(data.frame(Person = scoring$levels, Estimate = ans$theta, SE = ans$se, stringsAsFactors = FALSE))
        }
        if ("theta" %in% names(newdata)) {
            th_row <- as.numeric(newdata$theta)
        } else if (enc$person_col %in% names(newdata)) {
            m_p <- match(as.character(newdata[[enc$person_col]]), enc$person_levels)
            th_row <- ifelse(is.na(m_p), 0.0, st$theta[m_p])
        } else {
            th_row <- rep(0.0, N_new)
        }
        eta_vec <- th_row + base_eta
    }
    ev <- .mfrm_eval_row_predictions(eta_vec, st$step_cum, sg0, enc$step_cat_min, enc$step_cat_max, enc$rating_min)
    if (identical(type, "probs")) return(ev$probs)
    if (identical(type, "link")) return(ev$eta)
    ev$expected
}
