mfrmr_gmfrm_accuracy_control <- function(control = NULL) {
    defaults <- list(max_points = 241L, loglik_tol = 1e-07, posterior_tol = 1e-06)
    if (!is.null(control)) {
        if (!is.list(control) || (length(control) && (is.null(names(control)) || anyNA(names(control)) || 
            anyDuplicated(names(control)) || any(!names(control) %in% names(defaults))))) 
            stop("Two-family `mml_accuracy_control` accepts max_points, loglik_tol and posterior_tol; point-estimate checks are separate from covariance qualification.", 
                call. = FALSE)
        defaults[names(control)] <- control
    }
    mfrmr_mml_accuracy_orders(defaults$max_points, offset = -1L)
    for (name in c("loglik_tol", "posterior_tol")) {
        value <- defaults[[name]]
        if (!is.numeric(value) || is.complex(value) || length(value) != 1L || !is.finite(value) || value <= 
            0) 
            stop("`", name, "` must be a finite positive scalar.", call. = FALSE)
    }
    defaults
}

mfrmr_gmfrm_rule_moments <- function(fit, order, setup) {
    if (mfrmr_adaptive_integration(fit$config)) {
        return(mfrmr_make_adaptive_mml_evaluator(setup$idx, fit$config, setup$sizes, order, include_person_summaries = TRUE)(fit$opt$par)$per_person)
    }
    params <- expand_params(fit$opt$par, setup$sizes, fit$config)
    quad <- gauss_hermite_normal(order)
    bundle <- mfrm_mml_logprob_bundle(setup$idx, fit$config, quad, params, compute_base_eta(setup$idx, 
        params, fit$config), include_probs = TRUE, include_linear_part = TRUE)
    posterior <- mfrm_mml_posterior_bundle(bundle)$person_bundle
    center <- as.vector(posterior$posterior %*% quad$nodes)
    data.frame(PersonIndex = posterior$person_ids, LogMarginal = posterior$log_marginal, EAP = center, 
        PosteriorSD = sqrt(rowSums(posterior$posterior * (rep(quad$nodes, each = nrow(posterior$posterior)) - 
            center)^2)))
}

mfrmr_gmfrm_accuracy_check <- function(fit, control) {
    q <- fit$config$estimation_control$quad_points
    point <- prediction_gmfrm_scoring_readiness(fit, comparison_order = 2L * q - 1L)$local_calibration_review
    checks <- data.frame(Check = "Point calibration", Passed = isTRUE(point$eligible), Detail = point$review)
    result <- list(passed = FALSE, retry = !is.null(point$integration), checks = checks, numerical_checks = point$integration, 
        per_person = NULL, metrics = c(MaxLogMarginalDifference = NA_real_, MaxEAPDifference = NA_real_, 
            MaxPosteriorSDDifference = NA_real_), detail = point$review)
    if (is.null(point$integration)) 
        return(result)
    setup <- do.call(mfrm_gmfrm_common_setup, fit$gmfrm$specification[setdiff(names(fit$gmfrm$specification), 
        "quadrature")])
    low <- mfrmr_gmfrm_rule_moments(fit, q, setup)
    high <- mfrmr_gmfrm_rule_moments(fit, 2L * q - 1L, setup)
    low <- low[order(low$PersonIndex), ]
    high <- high[order(high$PersonIndex), ]
    if (!identical(low$PersonIndex, high$PersonIndex) || !identical(low$PersonIndex, seq_along(fit$prep$levels$Person))) 
        stop("Incomplete Person alignment in two-family integration checks.", call. = FALSE)
    difference <- abs(low[-1L] - high[-1L])
    if (any(!is.finite(as.matrix(difference)))) 
        stop("Non-finite two-family integration checks.", call. = FALSE)
    names(difference) <- c("LogMarginalDifference", "EAPDifference", "PosteriorSDDifference")
    result$per_person <- data.frame(Person = fit$prep$levels$Person, difference)
    result$metrics[] <- vapply(difference, max, 0)
    moments_pass <- result$metrics[1] <= control$loglik_tol && max(result$metrics[-1]) <= control$posterior_tol
    result$checks <- rbind(checks, data.frame(Check = "Person integration", Passed = isTRUE(moments_pass), 
        Detail = "Compare per-Person log likelihood, EAP and posterior SD at q and 2q-1 points."))
    result$passed <- isTRUE(point$eligible) && moments_pass
    result$retry <- !result$passed
    result$detail <- if (result$passed) 
        "Point-estimate integration and score checks passed; curvature and intervals require separate checks."
    else paste(if (!isTRUE(point$eligible)) 
        point$review
    else "", if (!moments_pass) 
        "Person likelihood or posterior moments require a finer rule."
    else "")
    result
}

mfrm_fit_product_slopes_auto <- function(args, supplied) {
    control <- args$mml_accuracy_control
    orders <- mfrmr_mml_accuracy_orders(control$max_points, args$quad_points, -1L)
    resolved <- if (args$mml_engine == "em") 
        "fixed"
    else "adaptive"
    history <- list()
    last_candidate <- NULL
    fail <- function(detail) {
        stop(structure(list(message = paste0("MML numerical accuracy was not established: ", detail, 
            " Inspect history, control and last_candidate; no accuracy-qualified fit was returned."), 
            call = NULL, history = do.call(rbind, history), control = control, provenance_version = 2L, 
            last_candidate = last_candidate, last_attempt = history[[length(history)]], parameter_source = if (is.null(last_candidate)) "unavailable" else "optimizer_candidate", 
            last_parameters = if (is.null(last_candidate)) NULL else last_candidate$parameters, last_integration = if (is.null(last_candidate)) NA_character_ else resolved, 
            last_quad_points = if (is.null(last_candidate)) NA_integer_ else last_candidate$diagnostics$QuadPoints), 
            class = c("mfrmr_mml_accuracy_error", "error", "condition")))
    }
    stage_args <- args
    stage_args$mml_integration <- resolved
    stage_args$mml_accuracy_control <- NULL
    stage_supplied <- setdiff(supplied, "mml_accuracy_control")
    for (stage in seq_along(orders)) {
        q <- orders[stage]
        stage_args$quad_points <- q
        mfrmr_fit_progress(sprintf("Automatic stage %d/%d: fitting q=%d, reference=%d", stage, length(orders), 
            q, 2L * q - 1L))
        row <- data.frame(Stage = stage, Integration = resolved, QuadPoints = q, ReferencePoints = 2L * 
            q - 1L, LogLik = NA_real_, MaxLogMarginalDifference = NA_real_, MaxEAPDifference = NA_real_, 
            MaxPosteriorSDDifference = NA_real_, Status = "unavailable", FailurePhase = "", Detail = "", 
            stringsAsFactors = FALSE)
        fit <- tryCatch(mfrm_fit_product_slopes(stage_args, stage_supplied), error = identity)
        if (inherits(fit, "error")) {
            row$FailurePhase <- "optimization"
            row$Detail <- conditionMessage(fit)
            history[[stage]] <- row
            fail(row$Detail)
        }
        if (identical(fit$summary$PointEstimateStatus, "finite_maximum_absent")) {
            fit$config$mml_accuracy <- list(status = "full_maximum_absent", scope = "Full-model accuracy is unavailable; inspect point_limit for target-specific estimates.")
            fit$config$estimation_control$mml_integration_requested <- "auto"
            fit$config$estimation_control$quad_points_requested <- as.integer(args$quad_points)
            fit$config$replay_inputs$mml_integration <- "auto"
            fit$config$replay_inputs$mml_accuracy_control <- control
            fit$summary$MMLAccuracyStatus <- "full_maximum_absent"
            return(fit)
        }
        row$LogLik <- -fit$opt$value
        mfrmr_fit_progress(sprintf("Automatic stage %d/%d: point-estimate integration checks, q=%d/%d", 
            stage, length(orders), q, 2L * q - 1L))
        checked <- tryCatch(mfrmr_gmfrm_accuracy_check(fit, control), error = identity)
        if (inherits(checked, "error")) {
            row$FailurePhase <- "accuracy_check"
            row$Detail <- conditionMessage(checked)
        }
        else {
            row[names(checked$metrics)] <- as.list(checked$metrics)
            row$Status <- if (checked$passed) 
                "criteria_met"
            else if (checked$retry) 
                "refinement_required"
            else "check_refused"
            row$Detail <- checked$detail
        }
        history[[stage]] <- row
        sizes <- build_param_sizes(fit$config)
        last_candidate <- list(parameters = fit$opt$par, parameter_names = mfrm_checkpoint_parameter_names(sizes), 
            parameter_sizes = sizes, config = fit$config, diagnostics = row, accuracy = if (inherits(checked, 
                "error")) NULL else list(checks = checked$checks, numerical_checks = checked$numerical_checks, 
                per_person = checked$per_person))
        if (inherits(checked, "error")) 
            fail(row$Detail)
        if (checked$passed) {
            fit$config$mml_accuracy <- list(status = "criteria_met", control = control, history = do.call(rbind, 
                history), per_person = checked$per_person, checks = checked$checks, numerical_checks = checked$numerical_checks, 
                scope = "two_family_point_integration_and_score; curvature_and_coverage_unqualified")
            fit$config$estimation_control$mml_integration_requested <- "auto"
            fit$config$estimation_control$quad_points_requested <- as.integer(args$quad_points)
            fit$config$replay_inputs$mml_integration <- "auto"
            fit$config$replay_inputs$mml_accuracy_control <- control
            fit$config$replay_inputs$quad_points <- as.integer(args$quad_points)
            fit$summary$MMLAccuracyStatus <- "criteria_met"
            fit <- mfrm_gmfrm_apply_point_review(fit, integration_checked = TRUE)
            return(fit)
        }
        if (!checked$retry) 
            fail(row$Detail)
    }
    fail("max_points was exhausted before all numerical criteria were met.")
}
