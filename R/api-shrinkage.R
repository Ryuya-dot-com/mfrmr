

apply_empirical_bayes_shrinkage <- function(fit, facet_prior_sd = NULL, shrink_person = FALSE) {
    .mfrm_validate_fit(fit)
    enc <- fit$encoding
    shrink_vec <- function(est, se, tau2_override = NULL, free_mask = NULL, preserve_mean = FALSE) {
        ok <- is.finite(est) & is.finite(se) & (se > 0)
        if (!is.null(free_mask)) ok <- ok & free_mask
        if (sum(ok) < 2L)
            return(list(shrunk = est, shrunk_se = se, tau2 = 0))
        mu <- mean(est[ok])
        tau2 <- if (is.null(tau2_override))
            max(0, stats::var(est[ok]) - mean(se[ok]^2))
        else as.numeric(tau2_override)^2
        b_wt <- ifelse(ok & (tau2 + se^2 > 0), tau2/(tau2 + se^2), 0)
        est_sh <- ifelse(ok, mu + b_wt * (est - mu), est)
        if (isTRUE(preserve_mean)) {
            est_sh[ok] <- est_sh[ok] - (mean(est_sh[ok]) - mu)
        }
        se_sh <- ifelse(ok, sqrt(b_wt * se^2), se)
        list(shrunk = est_sh, shrunk_se = se_sh, tau2 = tau2)
    }
    out <- fit
    base_est <- out$facets$MLEEstimate %||% out$facets$Estimate
    base_se <- out$facets$MLEModelSE %||% out$facets$ModelSE
    out$facets$ShrunkEstimate <- rep(NA_real_, nrow(out$facets))
    out$facets$ShrunkSE <- rep(NA_real_, nrow(out$facets))
    for (fnm in unique(out$facets$Facet)) {
        idx <- which(out$facets$Facet == fnm)
        f_pos <- match(fnm, enc$base_facets)
        free_f <- rep(TRUE, length(idx))
        preserve_m <- FALSE
        if (!is.na(f_pos)) {
            if (enc$facet_dummy[f_pos] == 1L) free_f[] <- FALSE
            if (length(enc$anchor_fixed) >= f_pos && length(enc$anchor_fixed[[f_pos]]) == length(idx)) {
                free_f <- free_f & (enc$anchor_fixed[[f_pos]] == 0L)
            }
            if (length(enc$custom_facet_anchored) >= f_pos && length(enc$custom_facet_anchored[[f_pos]]) == length(idx)) {
                free_f <- free_f & (enc$custom_facet_anchored[[f_pos]] == 0L)
            }
            if (!is.null(enc$explanatory_meta[[fnm]])) free_f[] <- FALSE
            preserve_m <- (enc$facet_noncenter[f_pos] == 0L)
        }
        res <- shrink_vec(base_est[idx], base_se[idx], facet_prior_sd,
                          free_mask = free_f, preserve_mean = preserve_m)
        out$facets$ShrunkEstimate[idx] <- res$shrunk
        out$facets$ShrunkSE[idx] <- res$shrunk_se
    }
    if (isTRUE(shrink_person)) {
        p_est <- out$person$MLEEstimate %||% out$person$Estimate
        p_se <- out$person$MLEModelSE %||% out$person$ModelSE
        pr <- shrink_vec(p_est, p_se, facet_prior_sd)
        out$person$ShrunkEstimate <- pr$shrunk
        out$person$ShrunkSE <- pr$shrunk_se
    }
    return(out)
}
