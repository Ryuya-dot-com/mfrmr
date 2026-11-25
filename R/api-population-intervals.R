mfrm_population_intervals <- function(object, level = 0.95, contrasts = NULL, anchor_covariance = NULL, 
    independent_anchors = FALSE) {
    if (inherits(object, "mfrm_facet_intervals") && !is.null(object$anchor_uncertainty)) {
        if (!is.null(anchor_covariance) || !identical(independent_anchors, FALSE)) 
            stop("Saved anchor-source intervals already contain the covariance and independence declaration; omit both arguments when reusing them.", 
                call. = FALSE)
        mfrmr_anchor_uncertainty_validate_saved(object)
        request <- object$anchor_uncertainty
        object$parameter_covariance <- request$conditional_parameter_covariance
    }
    else {
        fit <- if (inherits(object, "mfrm_facet_intervals")) 
            object$fit
        else object
        request <- mfrmr_anchor_uncertainty_request(fit, anchor_covariance, independent_anchors)
    }
    mfrm_population_intervals_impl(object, level, contrasts, anchor_request = request)
}

mfrm_population_intervals_impl <- function(object, level, contrasts, covariance = NULL, anchor_request = NULL) {
    if (!is.numeric(level) || is.complex(level) || is.object(level) || !is.null(dim(level)) || length(level) != 
        1L || !is.finite(level) || level <= 0 || level >= 1) 
        stop("Supply 0 < level < 1.", call. = FALSE)
    level <- unname(level)
    reuse <- inherits(object, "mfrm_facet_intervals")
    fit <- if (reuse) 
        object$fit
    else object
    stop_if_jml_adjustment(fit, "mfrm_population_intervals()")
    if (!inherits(fit, "mfrm_fit") || inherits(fit, "mfrm_imported_fit") || !fit$config$model %in% c("RSM", 
        "PCM") || !isTRUE(fit$config$population_spec$active)) 
        stop("Supply a native RSM/PCM fit with an estimated normal population.", call. = FALSE)
    params <- mfrm_native_location_source(fit)
    identity <- mfrm_native_location_identity(fit)
    columns <- fit$config$population_spec$design_columns
    if (!is.null(contrasts)) {
        if (!is.matrix(contrasts) || !is.numeric(contrasts) || is.complex(contrasts) || !nrow(contrasts) || 
            ncol(contrasts) != length(columns) || any(!is.finite(contrasts)) || is.null(colnames(contrasts)) || 
            anyDuplicated(colnames(contrasts)) || !setequal(colnames(contrasts), columns) || is.null(rownames(contrasts)) || 
            anyNA(rownames(contrasts)) || any(!nzchar(trimws(rownames(contrasts)))) || anyDuplicated(rownames(contrasts)) || 
            any(rowSums(abs(contrasts)) == 0)) 
            stop("`contrasts` must have distinct target row names, all fitted coefficient column names, and finite nonzero rows.", 
                call. = FALSE)
        contrasts <- contrasts[, columns, drop = FALSE]
    }
    if (reuse) {
        if (!identical(object$settings$procedure, "mml_native_location_model_v1") || !identical(identity, 
            object$source) || !is.data.frame(object$checks) || !nrow(object$checks)) 
            stop("Saved native-location inference must match its source fit and qualification metadata.", 
                call. = FALSE)
        eligible <- all(object$checks$Passed %in% TRUE) && !is.null(object$parameter_covariance)
        required <- c("Identification and boundary", "Category support", "Joint information", "Local solution", 
            "Full gradient", "Stationarity and inverse", "Comparison information", "Quadrature comparison")
        if (eligible && (!identical(object$checks$Check, required) || !is.data.frame(object$numerical_checks) || 
            nrow(object$numerical_checks) != 1L || !all(c("CurvatureScaledGradient", "InverseResidual", 
            "ComparisonInverseResidual", "QuadratureScoreShift", "QuadratureCovarianceChange") %in% names(object$numerical_checks)))) 
            stop("Saved native-location inference needs its complete numerical qualification record.", 
                call. = FALSE)
        inference <- list(covariance = if (eligible) object$parameter_covariance else NULL, checks = object$checks, 
            numerical_checks = object$numerical_checks, comparison_information_review = object$comparison_information_review, 
            check = list(eligible = eligible, review = paste(object$checks$Detail[!object$checks$Passed], 
                collapse = " "), caution = object$cautions[!startsWith(object$cautions, "Experimental native location intervals:") & 
                !startsWith(object$cautions, "Native location intervals:") & !startsWith(object$cautions, 
                "Population-SD-standardized contrasts use ")]))
        inference <- mfrm_native_location_boundary_candidate(fit, inference)
        information_review <- object$information_review
    }
    else {
        inference <- if (is.null(covariance)) 
            mfrm_native_location_inference(fit)
        else mfrm_native_location_inference(fit, covariance = covariance)
        information_review <- inference$information$solution_information$inverse_review
    }
    sizes <- build_param_sizes(fit$config)
    slices <- build_param_slices(sizes)
    fixed_variance <- !is.null(fit$config$population_spec$fixed_sd)
    at <- c(slices[["beta"]], slices[["log_sigma2"]])
    working <- c(unname(params$population$coefficients), log(params$population$sigma2))
    targets <- c(paste0("beta:", columns), "log_residual_variance")
    V <- inference$covariance
    if (!is.null(V) && (!is.matrix(V) || !identical(dim(V), rep(length(fit$opt$par), 2L)) || any(!is.finite(V)) || 
        !isTRUE(all.equal(V, t(V))) || is.null(tryCatch(chol(V), error = function(e) NULL)))) 
        stop("Saved joint covariance must be finite, positive definite and match all free coordinates.", 
            call. = FALSE)
    covariance <- if (is.null(V)) 
        matrix(NA_real_, length(at), length(at))
    else V[at, at, drop = FALSE]
    covariance_targets <- if (fixed_variance) 
        head(targets, -1L)
    else targets
    dimnames(covariance) <- list(covariance_targets, covariance_targets)
    se <- covariance_diag_se(covariance)
    if (fixed_variance) 
        se <- c(se, NA_real_)
    terms <- columns
    types <- rep("coefficient", length(columns))
    contrast_covariance <- NULL
    if (!is.null(contrasts)) {
        beta_at <- seq_along(columns)
        contrast_covariance <- contrasts %*% covariance[beta_at, beta_at, drop = FALSE] %*% t(contrasts)
        working <- c(working[beta_at], drop(contrasts %*% working[beta_at]), tail(working, 1L))
        se <- c(se[beta_at], covariance_diag_se(contrast_covariance), tail(se, 1L))
        targets <- c(targets[beta_at], paste0("contrast:", rownames(contrasts)), tail(targets, 1L))
        terms <- c(terms, rownames(contrasts))
        types <- c(types, rep("coefficient_contrast", nrow(contrasts)))
    }
    status <- rep(if (isTRUE(inference$check$eligible)) "available" else "numerical_review_failed", length(working))
    status[status == "available" & (!is.finite(se) | se <= 0)] <- "nonpositive_variance"
    if (fixed_variance) 
        status[length(status)] <- "fixed"
    se[status != "available"] <- NA_real_
    margin <- stats::qnorm((1 - level)/2, lower.tail = FALSE) * se
    working_lower <- working - margin
    working_upper <- working + margin
    lower <- working_lower
    upper <- working_upper
    estimate <- working
    natural_se <- se
    last <- length(working)
    estimate[last] <- params$population$sigma2
    lower[last] <- exp(lower[last])
    upper[last] <- exp(upper[last])
    natural_se[last] <- estimate[last] * se[last]
    valid <- is.finite(working_lower) & is.finite(working_upper) & is.finite(se)
    natural_status <- rep("finite", length(working))
    if (valid[last] && (lower[last] == 0 || !is.finite(upper[last]) || !is.finite(natural_se[last]))) 
        natural_status[last] <- "outside_floating_point_range"
    status[status == "available" & !valid] <- "nonfinite_bounds"
    unavailable <- status != "available"
    se[unavailable] <- natural_se[unavailable] <- lower[unavailable] <- upper[unavailable] <- NA_real_
    working_lower[unavailable] <- working_upper[unavailable] <- NA_real_
    natural_status[unavailable] <- "unavailable"
    if (fixed_variance) 
        natural_status[last] <- "finite"
    review <- if (isTRUE(inference$check$eligible)) 
        "Experimental population normal/log-variance intervals; numerical checks passed, sampling coverage unqualified."
    else inference$check$review
    table <- data.frame(Target = targets, Type = c(types, "residual_variance"), Term = c(terms, "Residual variance"), 
        Estimate = estimate, SE = natural_se, Lower = lower, Upper = upper, WorkingEstimate = working, 
        WorkingSE = se, WorkingLower = working_lower, WorkingUpper = working_upper, WorkingScale = c(rep("coefficient", 
            length(terms)), "log_residual_variance"), NaturalScaleStatus = natural_status, Status = status, 
        CIEligible = !unavailable, InferenceReview = review, row.names = NULL)
    table$InferenceReview[status %in% c("nonpositive_variance", "nonfinite_bounds")] <- "Finite positive uncertainty and finite bounds on the coefficient/log-variance scale are required."
    table$InferenceReview[status == "fixed"] <- "Residual variance is fixed by population_sd; no estimated variance uncertainty or inferential interval is supplied."
    caution <- "Experimental pointwise population intervals: sampling coverage is unqualified and method qualification is incomplete. Residual variance is conditional on the fitted predictors; these intervals do not include population misspecification or dependence."
    out <- list(table = table, covariance = covariance, parameter_covariance = V, checks = inference$checks, 
        numerical_checks = inference$numerical_checks, information_review = information_review, comparison_information_review = inference$comparison_information_review, 
        settings = list(procedure = "mml_normal_population_model_v1", method = "model", level = level, 
            model = fit$config$model, population = "conditional_normal", quad_points = fit$config$estimation_control$quad_points, 
            integration = fit$config$estimation_control$mml_integration %||% "fixed", inference_reused = reuse, 
            adjustment = "pointwise"), source = identity, fit = fit, cautions = unique(c(caution, inference$check$caution)))
    if (fixed_variance) {
        out$settings$population_sd <- fit$config$population_spec$fixed_sd
        out$settings$population_sd_estimated <- FALSE
        out$cautions <- c(out$cautions, "Population coefficient intervals condition on the supplied population SD; its uncertainty is not propagated.")
    }
    anchor_note <- mfrm_gpcm_anchor_note(fit)
    if (!is.null(anchor_note)) 
        out$cautions <- c(out$cautions, anchor_note)
    if (!is.null(contrasts)) {
        out$contrasts <- contrasts
        out$contrast_covariance <- contrast_covariance
        out$cautions <- c(out$cautions, "Contrasts use the fitted population coding and describe conditional population means, not individual ability differences or causal effects.")
    }
    class(out) <- "mfrm_population_intervals"
    out <- mfrmr_anchor_uncertainty_intervals(out, anchor_request)
    warning(paste(out$cautions, collapse = " "), call. = FALSE)
    out
}

print.mfrm_population_intervals <- function(x, ...) {
    cat("Conditional-normal population intervals\n")
    print(x$table, row.names = FALSE)
    for (caution in x$cautions) print_wrapped_line(paste0("Caution: ", caution))
    invisible(x)
}
