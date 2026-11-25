shrinkage_interpretation <- function() {
    "Descriptive zero-centered adjustment; plug-in SEs/bands omit prior-variance uncertainty and cross-level covariance. Zero SE after full pooling is not perfect precision."
}

validate_shrinkage_output <- function(fit) {
    report <- fit$shrinkage_report
    if (is.data.frame(report) && nrow(report) > 0L && (!all(c("Interpretation", "CalculationVersion") %in% 
        names(report)) || !all(report$CalculationVersion %in% 2L))) {
        stop("Reapply apply_empirical_bayes_shrinkage() with the original prior settings to refresh this saved report, then regenerate plots and exports; no MFRM refit is needed. Use shrink_person = FALSE unless the fit uses ordinary JML.", 
            call. = FALSE)
    }
    invisible(TRUE)
}

.compute_facet_shrinkage <- function(estimates, ses, method = c("empirical_bayes"), prior_sd = NULL, 
    min_levels = 3L) {
    method <- match.arg(method)
    if (!is.null(prior_sd) && (!is.numeric(prior_sd) || length(prior_sd) != 1L || !is.finite(prior_sd) || 
        prior_sd < 0 || !is.finite(prior_sd^2) || (prior_sd > 0 && prior_sd^2 == 0))) {
        stop("`facet_prior_sd` must be NULL or a non-negative finite scalar whose square is representable (positive when the SD is positive).", 
            call. = FALSE)
    }
    estimates <- as.numeric(estimates)
    ses <- as.numeric(ses)
    if (length(estimates) != length(ses)) {
        stop("`estimates` and `ses` must have the same length.", call. = FALSE)
    }
    K <- length(estimates)
    out_template <- list(shrunk_estimates = rep(NA_real_, K), shrunk_ses = rep(NA_real_, K), shrinkage_factors = rep(NA_real_, 
        K), retained_weights = rep(NA_real_, K), tau2 = NA_real_, mean_se2 = NA_real_, n_levels = K, 
        n_levels_used = 0L, method = method, prior_sd_source = if (is.null(prior_sd)) "empirical" else "user", 
        note = NA_character_)
    valid <- is.finite(estimates) & is.finite(ses) & ses > 0
    K_use <- sum(valid)
    out_template$n_levels_used <- K_use
    if (K_use < min_levels) {
        out_template$note <- paste0("Fewer than ", min_levels, " valid levels; shrinkage not applied.")
        out_template$shrunk_estimates <- estimates
        out_template$shrunk_ses <- ses
        out_template$shrinkage_factors <- ifelse(valid, 0, NA_real_)
        out_template$retained_weights <- ifelse(valid, 1, NA_real_)
        return(out_template)
    }
    mean_square <- function(x) {
        scale <- max(abs(x))
        if (scale == 0) 
            return(0)
        value <- (scale * sqrt(mean((x/scale)^2)))^2
        if (value == 0) 
            NA_real_
        else value
    }
    mean_se2 <- mean_square(ses[valid])
    raw_var <- mean_square(estimates[valid])
    if (!is.null(prior_sd)) {
        tau2 <- as.numeric(prior_sd)^2
        out_template$prior_sd_source <- "user"
    }
    else {
        tau2 <- max(0, raw_var - mean_se2)
        out_template$prior_sd_source <- "empirical"
    }
    B <- rep(NA_real_, K)
    retained <- rep(NA_real_, K)
    shrunk_est <- estimates
    shrunk_se <- ses
    if (!is.finite(tau2)) {
        tau2 <- NA_real_
        out_template$note <- "Moment variance is outside numerical range; shrinkage not applied. Original estimates and SEs are retained."
    }
    else if (tau2 > 0) {
        tau <- sqrt(tau2)
        se <- ses[valid]
        ratio <- pmin(tau, se)/pmax(tau, se)
        denominator <- sqrt(1 + ratio^2)
        retained_root <- ifelse(se <= tau, 1/denominator, ratio/denominator)
        B[valid] <- ifelse(se <= tau, ratio^2/(1 + ratio^2), 1/(1 + ratio^2))
        retained[valid] <- retained_root^2
        shrunk_est[valid] <- (estimates[valid] * retained_root) * retained_root
        shrunk_se[valid] <- pmin(tau, se)/denominator
    }
    else {
        B[valid] <- 1
        retained[valid] <- 0
        shrunk_est[valid] <- 0
        shrunk_se[valid] <- 0
        out_template$note <- paste0("The selected prior variance is zero; eligible levels are fully pooled at zero. ", 
            "Zero plug-in SE does not establish perfect precision.")
    }
    if (!is.finite(mean_se2)) {
        mean_se2 <- NA_real_
        out_template$note <- paste(stats::na.omit(c(out_template$note, "Mean squared SE is outside numerical range and is unavailable.")), 
            collapse = " ")
    }
    out_template$shrunk_estimates <- shrunk_est
    out_template$shrunk_ses <- shrunk_se
    out_template$shrinkage_factors <- B
    out_template$retained_weights <- retained
    out_template$tau2 <- tau2
    out_template$mean_se2 <- mean_se2
    out_template$n_levels_used <- K_use
    out_template
}

.apply_shrinkage_to_fit <- function(fit, method = c("empirical_bayes", "laplace"), facet_prior_sd = NULL, 
    shrink_person = FALSE) {
    method <- match.arg(method)
    if (!inherits(fit, "mfrm_fit")) {
        stop("`.apply_shrinkage_to_fit()` requires an mfrm_fit.", call. = FALSE)
    }
    if (!is.logical(shrink_person) || length(shrink_person) != 1L || is.na(shrink_person)) {
        stop("`shrink_person` must be a single logical value.", call. = FALSE)
    }
    if (isTRUE(shrink_person) && (!identical(fit$config$method, "JML") || mfrm_has_jml_adjustment(fit))) {
        stop("`shrink_person = TRUE` requires ordinary JML estimates with sampling SEs. EAP posterior SDs are not sampling SEs. Use shrink_person = FALSE to adjust non-Person facets while retaining the original Person estimates.", 
            call. = FALSE)
    }
    fit$config$facet_shrinkage <- as.character(method)
    fit$config$facet_prior_sd <- facet_prior_sd
    fit$config$shrinkage_settings <- list(facet_prior_sd = facet_prior_sd, shrink_person = shrink_person, 
        applied_after_fit = FALSE)
    person <- fit$facets$person
    if (is.data.frame(person)) {
        person[intersect(c("ShrunkEstimate", "ShrunkSE", "ShrinkageFactor"), names(person))] <- NULL
        fit$facets$person <- person
    }
    others <- fit$facets$others
    if (is.null(others) || nrow(others) == 0L) {
        fit$shrinkage_report <- data.frame(Facet = character(0), NLevels = integer(0), NLevelsUsed = integer(0), 
            Tau2 = numeric(0), MeanSE2 = numeric(0), MeanShrinkage = numeric(0), EffectiveDF = numeric(0), 
            Method = character(0), PriorSource = character(0), Note = character(0), stringsAsFactors = FALSE)
        return(fit)
    }
    others <- as.data.frame(others, stringsAsFactors = FALSE)
    others$ShrunkEstimate <- NA_real_
    others$ShrunkSE <- NA_real_
    others$ShrinkageFactor <- NA_real_
    se_col <- if ("ModelSE" %in% names(others)) {
        "ModelSE"
    }
    else if ("SE" %in% names(others)) {
        "SE"
    }
    else {
        NA_character_
    }
    if (is.na(se_col)) {
        measures <- tryCatch(suppressMessages(suppressWarnings(diagnose_mfrm(fit, residual_pca = "none")))$measures, 
            error = function(e) NULL)
        if (is.null(measures) || !all(c("Facet", "Level", "ModelSE") %in% names(measures))) {
            stop("Shrinkage requires per-level standard errors. ", "Run diagnose_mfrm(fit) and stash SE on fit$facets$others ", 
                "before calling, or use the default fit_mfrm(..., ", "facet_shrinkage = ...) path.", 
                call. = FALSE)
        }
        measures <- as.data.frame(measures, stringsAsFactors = FALSE)
        measures$Level <- as.character(measures$Level)
        others$Level <- as.character(others$Level)
        others <- merge(others, measures[, c("Facet", "Level", "ModelSE")], by = c("Facet", "Level"), 
            all.x = TRUE, sort = FALSE)
        se_col <- "ModelSE"
    }
    facets <- unique(as.character(others$Facet))
    report_rows <- list()
    for (f in facets) {
        idx <- which(as.character(others$Facet) == f)
        if (length(idx) == 0L) 
            next
        res <- .compute_facet_shrinkage(estimates = others$Estimate[idx], ses = others[[se_col]][idx], 
            method = if (identical(method, "laplace")) 
                "empirical_bayes"
            else method, prior_sd = facet_prior_sd, min_levels = 3L)
        others$ShrunkEstimate[idx] <- res$shrunk_estimates
        others$ShrunkSE[idx] <- res$shrunk_ses
        others$ShrinkageFactor[idx] <- res$shrinkage_factors
        effective_df <- if (any(is.finite(res$retained_weights))) {
            sum(res$retained_weights[is.finite(res$retained_weights)])
        }
        else NA_real_
        report_rows[[f]] <- data.frame(Facet = f, NLevels = res$n_levels, NLevelsUsed = res$n_levels_used, 
            Tau2 = res$tau2, MeanSE2 = res$mean_se2, MeanShrinkage = if (any(is.finite(res$shrinkage_factors))) {
                mean(res$shrinkage_factors[is.finite(res$shrinkage_factors)])
            }
            else NA_real_, EffectiveDF = effective_df, Method = res$method, PriorSource = res$prior_sd_source, 
            Note = res$note %||% NA_character_, stringsAsFactors = FALSE)
    }
    fit$facets$others <- others
    fit$shrinkage_report <- do.call(rbind, report_rows)
    rownames(fit$shrinkage_report) <- NULL
    if (isTRUE(shrink_person)) {
        person <- fit$facets$person
        if (!is.null(person) && "Estimate" %in% names(person) && "SE" %in% names(person)) {
            res_p <- .compute_facet_shrinkage(estimates = person$Estimate, ses = person$SE, method = "empirical_bayes", 
                prior_sd = NULL, min_levels = 3L)
            person$ShrunkEstimate <- res_p$shrunk_estimates
            person$ShrunkSE <- res_p$shrunk_ses
            person$ShrinkageFactor <- res_p$shrinkage_factors
            fit$facets$person <- person
            person_report <- data.frame(Facet = "Person", NLevels = res_p$n_levels, NLevelsUsed = res_p$n_levels_used, 
                Tau2 = res_p$tau2, MeanSE2 = res_p$mean_se2, MeanShrinkage = if (any(is.finite(res_p$shrinkage_factors))) {
                  mean(res_p$shrinkage_factors[is.finite(res_p$shrinkage_factors)])
                }
                else NA_real_, EffectiveDF = if (any(is.finite(res_p$retained_weights))) {
                  sum(res_p$retained_weights[is.finite(res_p$retained_weights)])
                }
                else NA_real_, Method = res_p$method, PriorSource = res_p$prior_sd_source, Note = res_p$note %||% 
                  NA_character_, stringsAsFactors = FALSE)
            fit$shrinkage_report <- rbind(fit$shrinkage_report, person_report)
            rownames(fit$shrinkage_report) <- NULL
        }
    }
    fit$shrinkage_report$SupportsFormalInference <- FALSE
    fit$shrinkage_report$Interpretation <- shrinkage_interpretation()
    fit$shrinkage_report$CalculationVersion <- 2L
    if (!is.null(fit$summary) && nrow(fit$summary) > 0L) {
        fit$summary$FacetShrinkage <- as.character(method)
        fit$summary$FacetShrinkageTau2Mean <- if (nrow(fit$shrinkage_report) > 0L) {
            tau <- fit$shrinkage_report$Tau2
            if (any(is.finite(tau))) 
                mean(tau[is.finite(tau)])
            else NA_real_
        }
        else NA_real_
    }
    fit
}

apply_empirical_bayes_shrinkage <- function(fit, facet_prior_sd = NULL, shrink_person = FALSE) {
    if (inherits(fit, "mfrm_fast_fit")) {
        shrink_vec <- function(est, se, tau2_override = NULL) {
            ok <- is.finite(est) & is.finite(se) & (se > 0)
            if (sum(ok) < 2L) return(list(shrunk = est, shrunk_se = se, tau2 = 0.0))
            mu <- mean(est[ok])
            tau2 <- if (is.null(tau2_override)) max(0.0, stats::var(est[ok]) - mean(se[ok]^2)) else as.numeric(tau2_override)^2
            b_wt <- ifelse(ok & (tau2 + se^2 > 0), tau2 / (tau2 + se^2), 0.0)
            est_sh <- ifelse(ok, mu + b_wt * (est - mu), est)
            se_sh <- ifelse(ok, sqrt(b_wt * se^2), se)
            list(shrunk = est_sh, shrunk_se = se_sh, tau2 = tau2)
        }
        out <- fit
        out$facets$ShrunkEstimate <- rep(NA_real_, nrow(out$facets))
        out$facets$ShrunkSE <- rep(NA_real_, nrow(out$facets))
        for (fnm in unique(out$facets$Facet)) {
            idx <- which(out$facets$Facet == fnm)
            res <- shrink_vec(out$facets$Estimate[idx], out$facets$ModelSE[idx], facet_prior_sd)
            out$facets$ShrunkEstimate[idx] <- res$shrunk
            out$facets$ShrunkSE[idx] <- res$shrunk_se
        }
        if (isTRUE(shrink_person)) {
            pr <- shrink_vec(out$person$Estimate, out$person$ModelSE, facet_prior_sd)
            out$person$ShrunkEstimate <- pr$shrunk
            out$person$ShrunkSE <- pr$shrunk_se
        }
        return(out)
    }
    stop_if_product_slopes(fit, "apply_empirical_bayes_shrinkage()")
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an mfrm_fit from fit_mfrm().", call. = FALSE)
    }
    fit <- .apply_shrinkage_to_fit(fit = fit, method = "empirical_bayes", facet_prior_sd = facet_prior_sd, 
        shrink_person = shrink_person)
    fit$config$shrinkage_settings$applied_after_fit <- TRUE
    fit
}

shrinkage_report <- function(fit) {
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an mfrm_fit from fit_mfrm().", call. = FALSE)
    }
    validate_shrinkage_output(fit)
    rep_tbl <- fit$shrinkage_report
    if (is.null(rep_tbl) || !is.data.frame(rep_tbl) || nrow(rep_tbl) == 0L) {
        message("No shrinkage applied; ", "call fit_mfrm(..., facet_shrinkage = 'empirical_bayes') or ", 
            "apply_empirical_bayes_shrinkage(fit) first.")
        return(NULL)
    }
    rep_tbl
}
