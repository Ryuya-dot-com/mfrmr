
mfrm_fair_reference_score_fit <- function(fit) .mfrm_validate_fit(fit)


mfrm_fair_reference_plan <- function(fit, plan) {
    mfrm_fair_reference_score_fit(fit)
    facets <- fit$encoding$base_facets
    levels <- stats::setNames(fit$encoding$facet_levels, fit$encoding$facets)
    if (any(c("Weight", "NormalizedWeight") %in% facets))
        stop("The reference plan reserves the column names 'Weight' and 'NormalizedWeight'.", call. = FALSE)
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

mfrm_fair_reference_scores <- function(fit, plan, level = NULL) {
    .mfrm_validate_fit(fit)
    ready <- .mfrm_readiness(fit)$ready
    eval_plan <- function(theta) .mfrm_reference_expected(fit, plan, theta)
    score <- if (ready)
        eval_plan(fit$person$Estimate)
    else rep(NA_real_, nrow(fit$person))
    out <- data.frame(Person = fit$person$Person, Estimate = score, Status = ifelse(is.finite(score), paste0(tolower(fit$score_method),
        "_plug_in_estimate"), "unavailable_calibration"), Target = "common_plan_expected_average", Units = "original_score",
        Uncertainty = "not_computed", stringsAsFactors = FALSE)
    if (!is.null(level)) {
        out$Lower <- out$Upper <- NA_real_
        if (ready) {
            ci <- confint(fit, component = "person", level = level)
            out$Lower <- eval_plan(ci[, 1L])
            out$Upper <- eval_plan(ci[, 2L])
        }
        out$Level <- level
        basis <- if (identical(fit$score_method, "EAP"))
            "conditional_normal_posterior_approximation"
        else "conditional_normal_ability_interval"
        out$Uncertainty <- ifelse(is.finite(out$Lower) & is.finite(out$Upper), basis, "unavailable")
    }
    return(out)
}

.mfrm_reference_expected <- function(fit, plan, theta) {
    nd <- plan[fit$encoding$base_facets]
    out <- rep(NA_real_, length(theta))
    ok <- which(is.finite(theta))
    batch <- max(1L, as.integer(50000/nrow(plan)))
    starts <- if (length(ok))
        seq.int(1L, length(ok), by = batch)
    else integer()
    for (start in starts) {
        ids <- ok[seq.int(start, min(length(ok), start + batch - 1L))]
        block <- nd[rep(seq_len(nrow(plan)), length(ids)), , drop = FALSE]
        attr(block, ".mfrm_theta") <- rep(theta[ids], each = nrow(plan))
        score <- matrix(predict(fit, block, type = "response"), nrow = nrow(plan))
        out[ids] <- drop(crossprod(plan$NormalizedWeight, score))
    }
    out
}

.mfrm_person_fair_curve <- function(fit, facet_estimates = fit$facets$Estimate) {
  enc <- fit$encoding
  sc <- fit$step_cumulative
  # Fair(M) neutralizes facet locations, uses the geometric reference slope,
  # and averages expected scores over each person's weighted step-group mix.
  base <- sum(vapply(enc$facets, function(fc) {
    values <- if (fc %in% enc$base_facets) facet_estimates[fit$facets$Facet == fc] else
      fit$interactions$Estimate[fit$interactions$Interaction == fc]
    values <- values[is.finite(values)]
    enc$facet_signs[match(fc, enc$facets)] * if (length(values)) mean(values) else 0
  }, numeric(1)))
  valid_alpha <- is.finite(fit$alpha_obs) & fit$alpha_obs > 0 & enc$weight > 0
  alpha <- if (any(valid_alpha)) exp(stats::weighted.mean(log(fit$alpha_obs[valid_alpha]), enc$weight[valid_alpha])) else 1
  function(theta, mix) {
    active <- which(mix > 0)
    sum(vapply(active, function(g) {
      k <- seq.int(enc$step_cat_min[g], enc$step_cat_max[g])
      cum <- sc[g, k + 1L]
      lin <- if (enc$slope_formula == 1L) alpha * theta + base else alpha * (theta + base)
      lp <- (k - min(k)) * lin - if (enc$slope_formula == 1L) cum else alpha * cum
      p <- exp(lp - max(lp)); p <- p / sum(p)
      mix[g] * (fit$rating_min + sum(k * p))
    }, numeric(1)))
  }
}
