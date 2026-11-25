.mfrm_expected_correlation_moments <- function(x, e, v, w, eligible = rep(TRUE, length(x))) {
    n <- sum(w)
    out <- data.frame(PTMEAExpected = NA_real_, PTMEAExpectedAsymptotic = NA_real_, PTMEAExpectedN = n, 
        PTMEAExpectedFactor = if (is.finite(n) && n >= 2) 
            (n - 2)/n
        else NA_real_, PTMEAExpectedStatus = "unavailable", PTMEAExpectedReason = "Incomplete conditional moments or invalid weights.")
    if (!length(x) || any(!is.finite(w) | w < 0) || !is.finite(n) || n <= 0) 
        return(out)
    keep <- w > 0
    x <- x[keep]
    e <- e[keep]
    v <- v[keep]
    w <- w[keep]
    eligible <- eligible[keep]
    if (any(!is.finite(x) | !is.finite(e) | !is.finite(v) | v < 0)) 
        return(out)
    if (anyNA(eligible) || !all(eligible)) {
        out$PTMEAExpectedReason <- "The scope includes unanchored extreme main effects or nonfinite primary Person estimates."
        return(out)
    }
    w <- w/n
    x <- x - x[1L]
    e <- e - e[1L]
    x <- x - sum(w * x)
    e <- e - sum(w * e)
    vx <- sum(w * x * x)
    ve <- sum(w * e * e)
    cv <- sum(w * x * e)
    vm <- sum(w * v)
    if (!all(is.finite(c(vx, ve, cv, vm))) || vx <= 0) {
        out$PTMEAExpectedReason <- "The oriented predictor is constant or its moments are nonfinite."
        return(out)
    }
    ratio <- function(factor) {
        denom <- sqrt(vx) * sqrt(ve + factor * vm)
        if (!is.finite(denom) || denom <= 0) 
            return(NA_real_)
        rho <- cv/denom
        if (!is.finite(rho) || abs(rho) > 1 + 1e-10) 
            return(NA_real_)
        max(-1, min(1, rho))
    }
    out$PTMEAExpectedAsymptotic <- ratio(1)
    if (n < 2) {
        out$PTMEAExpectedStatus <- "insufficient_frequency"
        out$PTMEAExpectedReason <- "Frequency count below two; the finite-count correction is unavailable."
        return(out)
    }
    out$PTMEAExpected <- ratio(out$PTMEAExpectedFactor)
    if (is.finite(out$PTMEAExpected)) {
        out$PTMEAExpectedStatus <- "available_conditional"
        out$PTMEAExpectedReason <- "Conditional finite-count reporting approximation; not an exact sample-correlation expectation or inferential test."
    }
    else {
        out$PTMEAExpectedReason <- "The corrected denominator is zero or nonfinite."
    }
    out
}

.mfrm_expected_ptmea <- function(res, obs, facet_cols) {
    eligible <- rep(TRUE, nrow(obs))
    extreme <- .mfrm_unanchored_extremes(res, obs)
    for (f in names(extreme)) eligible <- eligible & !as.character(obs[[f]]) %in% extreme[[f]]
    primary <- res$facets$person$Estimate[match(as.character(obs$Person), as.character(res$facets$person$Person))]
    eligible <- eligible & is.finite(primary)
    w <- get_weights(obs)
    variance <- obs[["ConditionalVariance"]] %||% obs$Var
    purrr::map_dfr(facet_cols, function(f) {
        parts <- split(seq_len(nrow(obs)), as.character(obs[[f]]))
        purrr::map_dfr(names(parts), function(level) {
            rows <- parts[[level]]
            dplyr::bind_cols(tibble(Facet = f, Level = level), .mfrm_expected_correlation_moments(obs$MeasureSum[rows], 
                obs$Expected[rows], variance[rows], w[rows], eligible[rows]))
        })
    })
}
