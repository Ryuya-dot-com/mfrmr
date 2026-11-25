resolve_prediction_facets <- function(fit, facets = NULL) {
    fit_facets <- as.character(fit$config$facet_names %||% character(0))
    if (length(fit_facets) == 0) {
        stop("`fit` does not contain any calibrated facet names.", call. = FALSE)
    }
    if (is.null(facets) && mfrm_has_product_slopes(fit)) 
        facets <- setNames(fit_facets, fit_facets)
    facets <- facets %||% (fit$config$source_columns$facets %||% fit_facets)
    if (!is.character(facets) || length(facets) != length(fit_facets)) {
        stop("`facets` must be a character vector naming one column per calibrated facet: ", paste(fit_facets, 
            collapse = ", "), ".", call. = FALSE)
    }
    if (!is.null(names(facets)) && any(nzchar(names(facets)))) {
        if (!setequal(names(facets), fit_facets)) {
            stop("Named `facets` must use the calibrated facet names: ", paste(fit_facets, collapse = ", "), 
                ".", call. = FALSE)
        }
        facets <- facets[fit_facets]
    }
    else {
        names(facets) <- fit_facets
    }
    if (any(!nzchar(unname(facets)))) {
        stop("`facets` contains an empty column name.", call. = FALSE)
    }
    facets
}




prediction_fit_identity <- function(fit) {
    pop <- fit$population %||% list()
    spec <- fit$config$population_spec %||% list()
    active <- isTRUE(pop$active) || identical(fit$config$posterior_basis, "population_model")
    terms <- if (active) 
        prediction_population_terms(fit)
    else NULL
    if (!is.null(terms)) 
        attr(terms, ".Environment") <- NULL
    list(calibration = mfrm_result_fit_identity(fit), scoring = mfrm_checkpoint_fingerprint(list(posterior_basis = fit$config$posterior_basis, 
        terms = terms, xlevels = pop$xlevels %||% spec$xlevels, contrasts = pop$contrasts %||% spec$contrasts, 
        design_columns = pop$design_columns %||% names(pop$coefficients), source_columns = fit$config$source_columns, 
        readiness = mfrmr_get_readiness_record(fit), numerical = fit$opt$optimizer_diagnostics, repeated_ratings = fit$config$repeated_ratings, 
        preparation_notes = fit$prep$preparation_notes %||% fit$data_review$preparation_notes, estimability = fit$config$estimability_audit, 
        data_estimability = fit$data_review$estimability, boundary = fit$config$boundary_audit, adjustment = fit$jml_adjustment[c("estimator", 
            "point", "policy")]), canonical = TRUE))
}

prediction_population_terms <- function(fit) {
    pop <- fit$population %||% list()
    spec <- fit$config$population_spec %||% list()
    stored <- pop$terms %||% spec$terms
    if (!is.null(stored)) 
        return(stored)
    formula <- pop$formula %||% fit$config$population_formula
    terms <- stats::terms(formula)
    variables <- as.list(attr(terms, "variables"))[-1L]
    if (!any(vapply(variables, is.call, logical(1)))) 
        return(terms)
    training <- pop$person_table_replay %||% pop$person_table
    person_id <- pop$person_id %||% spec$person_id
    if (!is.data.frame(training) || length(person_id) != 1L || !person_id %in% names(training)) {
        stop("Transformed population predictors require fitted terms or retained training person data. Refit the calibration before scoring.", 
            call. = FALSE)
    }
    rebuilt <- prepare_mfrm_population_scaffold(data = training, person = person_id, population_formula = formula, 
        person_data = training, person_id = person_id, population_policy = pop$policy %||% "error", population_xlevels = pop$xlevels %||% 
            spec$xlevels, population_contrasts = pop$contrasts %||% spec$contrasts, require_full_rank = FALSE)
    design <- pop$design_matrix %||% spec$design_matrix
    if (is.null(design) || !identical(colnames(rebuilt$design_matrix), colnames(design)) || !isTRUE(all.equal(unname(rebuilt$design_matrix), 
        unname(design), tolerance = 1e-12))) {
        stop("Retained person data do not reproduce the fitted population training design. Refit the calibration before scoring.", 
            call. = FALSE)
    }
    rebuilt$terms
}





prediction_local_calibration_review <- function(fit, covariance = NULL) {
    out <- list(eligible = FALSE, basis = "local_mml_and_integration_v1", review = "Local calibration checks were not completed.")
    tryCatch({
        if (isTRUE(fit$config$population_spec$active) && !identical(fit$config$population_spec$design_columns, 
            "(Intercept)")) 
            mfrm_native_location_source(fit)
        check <- mfrm_ic_fit_check(fit, mfrm_extract_fit_ic_contract(fit), information = if (is.null(covariance)) 
            NULL
        else tryCatch({
            info <- covariance(fit)
            info$solution_information %||% list(status = "unavailable", detail = info$detail)
        }, error = function(e) list(status = "unavailable", detail = conditionMessage(e))))
        out$review <- check$review
        out$caution <- check$caution %||% character(0)
        if (!isTRUE(check$eligible)) 
            return(out)
        cfg <- fit$config
        order <- as.integer(cfg$estimation_control$quad_points)
        higher <- max(order + 10L, 2L * order - 1L)
        if (inherits(tryCatch(gauss_hermite_normal(higher), error = identity), "error")) {
            higher <- order + 10L
        }
        sizes <- build_param_sizes(cfg)
        idx <- build_indices(fit$prep, cfg$step_facet, cfg$slope_facet, cfg$interaction_specs)
        evaluate <- function(q) {
            cfg$estimation_control$quad_points <- q
            evaluator <- make_mfrm_direct_evaluator("MML", make_param_cache(sizes, cfg, idx, is_mml = TRUE), 
                idx, cfg, sizes, gauss_hermite_normal(q))
            list(value = evaluator$value(fit$opt$par), gradient = evaluator$gradient(fit$opt$par))
        }
        original <- evaluate(order)
        refined <- evaluate(higher)
        out$integration <- data.frame(OriginalOrder = order, ComparisonOrder = higher, NLLChange = abs(original$value - 
            refined$value), GradientChange = max(abs(original$gradient - refined$gradient)), ComparisonGradient = max(abs(refined$gradient)))
        out$eligible <- all(is.finite(unlist(out$integration))) && out$integration$NLLChange <= 1e-05 && 
            out$integration$GradientChange <= 1e-04 && out$integration$ComparisonGradient <= 1e-04
        if (!out$eligible) 
            out$review <- paste("Calibration integration changes exceed the scoring review tolerance.", 
                "Refit with more quadrature points and inspect mml_quadrature_sensitivity().")
        out
    }, error = function(e) {
        out$review <- paste("Local calibration checks are unavailable:", conditionMessage(e))
        out
    })
}

prediction_jml_calibration_review <- function(fit) {
    out <- list(eligible = FALSE, basis = "local_jml_and_curvature_v1", review = "Local joint-likelihood checks were not completed.")
    tryCatch({
        cfg <- fit$config
        if (!identical(cfg$model, "GPCM") || !identical(cfg$method, "JML") || !identical(cfg$slope_facet, 
            cfg$step_facet) || length(cfg$interaction_specs) || nrow(mfrmr_calibration_extract_anchors(fit)) || 
            any(!is.na(cfg$theta_spec$anchors)) || length(cfg$theta_spec$group_values) || isTRUE(cfg$population_spec$active) || 
            anyNA(fit$prep$data$Weight) || any(fit$prep$data$Weight != 1)) 
            stop("Conditional GPCM JML scoring requires shared owners, unit weights, no anchors/interactions and no fitted population model.")
        audit <- cfg$boundary_audit
        person_status <- audit$parameter_status
        if (!is.data.frame(person_status) || !nrow(person_status) || !"ParameterStatus" %in% names(person_status)) 
            stop("The source must retain its Person boundary audit.")
        slope_status <- mfrmr_readiness_gpcm_slope_parameters(cfg)$ParameterStatus
        states <- vapply(audit[c("structural_additive", "joint_additive", "gpcm_slope_boundary", "gpcm_joint_boundary")], 
            function(x) as.character(x$state %||% "missing"), character(1))
        if (any(states == "missing")) 
            stop("The source must retain its additive and slope boundary audits.")
        if (any(grepl("^unbounded", c(person_status$ParameterStatus, slope_status))) || any(startsWith(states, 
            "certified_"))) 
            stop("A retained Person, additive or slope boundary certificate prevents automatic conditional scoring; finite optimizer traces do not replace it.")
        sizes <- build_param_sizes(cfg)
        idx <- build_indices(fit$prep, cfg$step_facet, cfg$slope_facet, cfg$interaction_specs)
        evaluator <- make_mfrm_direct_evaluator("JML", make_param_cache(sizes, cfg, idx, is_mml = FALSE), 
            idx, cfg, sizes)
        par <- fit$opt$par
        objective_difference <- abs(evaluator$value(par) - fit$opt$value)
        gradient <- evaluator$gradient(par)
        if (length(objective_difference) != 1L || !is.finite(objective_difference) || objective_difference > 
            1e-06 || !length(gradient) || any(!is.finite(gradient)) || max(abs(gradient)) > 1e-04) 
            stop("The joint objective must agree within 1e-6 and its maximum absolute gradient must be <= 1e-4.")
        information <- optimHess(par, evaluator$value, evaluator$gradient)
        if (!identical(dim(information), rep(length(par), 2L)) || any(!is.finite(information))) 
            stop("Joint JML curvature is unavailable.")
        chol(information)
        condition <- rcond(information)
        if (!is.finite(condition) || condition <= 1e-10) 
            stop("Joint JML curvature is numerically singular.")
        out$checks <- list(objective_difference = objective_difference, max_abs_gradient = max(abs(gradient)), 
            dimension = as.integer(length(par)), positive_definite = TRUE, reciprocal_condition = condition, 
            known_boundary_absent = TRUE)
        out$eligible <- TRUE
        out$review <- "Fresh joint-likelihood and unregularized full-curvature checks passed for conditional scoring."
        out$caution <- "Local JML checks do not establish a unique global maximum, complete the global boundary audit or qualify formal slope intervals."
        out
    }, error = function(e) {
        out$review <- paste("Local JML calibration checks are unavailable:", conditionMessage(e))
        out
    })
}

prediction_gmfrm_source_identity <- function(fit, legacy = FALSE) {
    paste0(if (legacy) 
        "gmfrm_scoring_source_v1:"
    else "gmfrm_scoring_source_v2:", mfrm_checkpoint_fingerprint(list(source = mfrm_gpcm_inference_source(fit), 
        config = fit$config, specification = fit$gmfrm, score_map = fit$prep$score_map, source_columns = fit$prep$source_columns, 
        locations = fit$facets$others, steps = fit$steps, slopes = fit$slopes, converged = fit$summary$Converged, 
        numerical = fit$opt$optimizer_diagnostics, readiness = mfrmr_get_readiness_record(fit)), canonical = !legacy))
}


prediction_gmfrm_scoring_readiness <- function(fit, comparison_order = NULL) {
    input <- mfrm_gmfrm_response_input(fit, operation = "new-Person scoring")
    cfg <- input$config
    record <- mfrmr_get_readiness_record(fit)$fit
    field <- function(name) if (is.data.frame(record) && nrow(record) == 1L && name %in% names(record)) 
        as.character(record[[name]])
    else "missing"
    eligible <- identical(field("ReadinessContractVersion"), mfrmr_readiness_contract_version()) && field("InputState") == 
        "pass" && field("CategoryState") == "adequate" && field("NumericalState") == "ready" && field("EstimabilityState") %in% 
        c("identified", "not_evaluated") && field("BoundaryState") %in% c("finite", "not_applicable", 
        "not_evaluated") && !isTRUE(cfg$estimability_audit$nonlinear_local_estimability$local_first_order_rank_deficient)
    local <- list(eligible = FALSE, basis = "two_family_point_calibration_v1", review = "The source readiness record requires review.", 
        caution = "Two-family scoring is experimental. Numerical checks do not establish a global maximum, complete identification or boundary audits, or validate future-population scores.")
    if (isTRUE(eligible)) 
        local <- tryCatch({
            q <- as.integer(cfg$estimation_control$quad_points)
            higher <- comparison_order %||% max(q + 10L, 2L * q - 1L)
            if (is.null(comparison_order) && inherits(tryCatch(gauss_hermite_normal(higher), error = identity), 
                "error")) 
                higher <- q + 10L
            n <- length(input$prep$levels$Person)
            if (mfrmr_adaptive_integration(cfg)) {
                refined <- mfrmr_make_adaptive_mml_evaluator(input$indices, cfg, build_param_sizes(cfg), 
                  higher)(fit$opt$par)
                value <- refined$value
                gradient <- refined$gradient/n
            }
            else {
                specification <- fit$gmfrm$specification
                specification$quadrature <- gauss_hermite_normal(higher)
                refined <- do.call(mfrm_gmfrm_problem, specification)$marginal(fit$opt$par)
                value <- -refined$logLik
                gradient <- refined$gradient
            }
            local$integration <- data.frame(OriginalOrder = q, ComparisonOrder = higher, NLLChangePerPerson = abs(value - 
                fit$opt$value)/n, ComparisonMeanGradient = max(abs(gradient)))
            local$eligible <- all(is.finite(unlist(local$integration))) && local$integration$NLLChangePerPerson <= 
                1e-06 && local$integration$ComparisonMeanGradient <= 1e-06
            local$review <- if (local$eligible) {
                "Saved two-family calibration identity and convergence passed; finer-rule NLL change and maximum absolute gradient per Person are at most 1e-6."
            }
            else "The two-family calibration needs finer integration or further optimization; numerical source scoring checks did not pass."
            local
        }, error = function(e) {
            local$review <- paste("Two-family source integration checks are unavailable:", conditionMessage(e))
            local
        })
    local$source_identity <- prediction_gmfrm_source_identity(fit)
    state <- mfrm_convergence_state(fit)
    list(ready = isTRUE(local$eligible), status = if (isTRUE(local$eligible)) "conditional" else "review_only", 
        policy_basis = "two_family_conditional_eap_v1", local_calibration_review = local, parameter_ready = TRUE, 
        reason_codes = if (isTRUE(local$eligible)) character(0) else "local_calibration_check_failed", 
        source_audit_states = c(identification = field("EstimabilityState"), boundary = field("BoundaryState"), 
            numerical = field("NumericalState")), fit_readiness = state$fit_readiness, inference_ready = isTRUE(state$inference_ready), 
        readiness_contract_version = field("ReadinessContractVersion"))
}

prediction_source_scoring_readiness <- function(fit, covariance = NULL) {
    if (mfrm_has_product_slopes(fit)) 
        return(prediction_gmfrm_scoring_readiness(fit))
    state <- mfrm_convergence_state(fit)
    record <- mfrmr_get_readiness_record(fit)
    readiness <- as.data.frame(record$fit %||% data.frame(), stringsAsFactors = FALSE)
    value <- function(field, default = "") {
        if (nrow(readiness) == 1L && field %in% names(readiness)) {
            as.character(readiness[[field]][1])
        }
        else {
            as.character(default)
        }
    }
    contract_ready <- nrow(readiness) == 1L && identical(value("ReadinessContractVersion"), mfrmr_readiness_contract_version())
    input_state <- value("InputState", "legacy_unknown")
    preparation_notes <- as.data.frame(fit$prep$preparation_notes %||% fit$data_review$preparation_notes %||% 
        data.frame(), stringsAsFactors = FALSE)
    review_conditions <- if (nrow(preparation_notes) > 0L && all(c("Condition", "Severity") %in% names(preparation_notes))) {
        review_rows <- tolower(as.character(preparation_notes$Severity)) %in% c("review", "warning", 
            "warn", "error")
        unique(as.character(preparation_notes$Condition[review_rows]))
    }
    else {
        character(0)
    }
    review_conditions <- review_conditions[!is.na(review_conditions) & nzchar(trimws(review_conditions))]
    input_ready <- identical(input_state, "pass") || (identical(input_state, "review") && length(review_conditions) > 
        0L && all(review_conditions %in% "score_categories_recoded"))
    population_active <- isTRUE(fit$config$population_spec$active) || isTRUE(fit$config$population_active) || 
        isTRUE(fit$population$active) || identical(fit$config$posterior_basis, "population_model")
    estimability_state <- value("EstimabilityState", "legacy_unknown")
    estimability_ready <- estimability_state %in% c("identified", "population_assumption_linked")
    category_state <- value("CategoryState", "legacy_unknown")
    category_ready <- category_state %in% c("adequate", "not_applicable")
    boundary_state <- value("BoundaryState", "legacy_unknown")
    boundary_ready <- boundary_state %in% c("finite", "not_applicable")
    numerical_state <- value("NumericalState", "legacy_unknown")
    numerical_ready <- identical(numerical_state, "ready")
    sizes <- tryCatch(build_param_sizes(fit$config), error = function(e) NULL)
    par <- fit$opt$par %||% NULL
    parameter_ready <- is.numeric(par) && length(par) > 0L && all(is.finite(par)) && !is.null(sizes) && 
        length(par) == sum(as.integer(unlist(sizes, use.names = FALSE)))
    expanded <- if (parameter_ready) 
        tryCatch(expand_params(par, sizes, fit$config), error = function(e) NULL)
    else NULL
    parameter_ready <- parameter_ready && !is.null(expanded) && all(is.finite(unlist(expanded, use.names = FALSE)))
    pop <- materialize_population_spec(fit$config, expanded)
    if (population_active) 
        parameter_ready <- parameter_ready && isTRUE(pop$active) && length(pop$sigma2) == 1L && is.finite(pop$sigma2) && 
            pop$sigma2 > 0 && length(pop$coefficients) > 0L && all(is.finite(pop$coefficients)) && identical(fit$population$fixed_sd, 
            pop$fixed_sd) && isTRUE(all.equal(fit$population$sigma2, pop$sigma2, tolerance = 1e-10)) && 
            isTRUE(all.equal(as.numeric(fit$population$coefficients), as.numeric(pop$coefficients), tolerance = 1e-10)) && 
            identical(as.character(fit$population$design_columns), names(pop$coefficients))
    rank_deficient <- isTRUE(fit$config$estimability_audit$nonlinear_local_estimability$local_first_order_rank_deficient) || 
        isTRUE(fit$data_review$estimability$nonlinear_local_estimability$local_first_order_rank_deficient)
    if (rank_deficient) 
        estimability_ready <- FALSE
    ready <- !population_active && contract_ready && input_ready && estimability_ready && category_ready && 
        boundary_ready && numerical_ready && parameter_ready
    local <- NULL
    normal_intercept <- !population_active || (is.matrix(pop$design_matrix) && ncol(pop$design_matrix) == 
        1L && all(is.finite(pop$design_matrix)) && all(pop$design_matrix == 1))
    normal_scoring <- normal_intercept || (population_active && fit$config$model %in% c("RSM", "PCM"))
    if (!isTRUE(ready) && identical(fit$config$method, "MML") && (population_active || identical(fit$config$model, 
        "GPCM")) && contract_ready && input_ready && category_ready && numerical_ready && parameter_ready && 
        !rank_deficient && normal_scoring && estimability_state %in% c("identified", "population_assumption_linked", 
        "not_evaluated") && boundary_state %in% c("finite", "not_applicable", "not_evaluated")) {
        local <- prediction_local_calibration_review(fit, covariance = covariance)
        ready <- isTRUE(local$eligible)
    }
    if (!isTRUE(ready) && identical(fit$config$method, "JML") && identical(fit$config$model, "GPCM") && 
        !population_active && contract_ready && input_ready && category_ready && numerical_ready && parameter_ready && 
        !rank_deficient && estimability_state %in% c("identified", "not_evaluated") && boundary_state %in% 
        c("finite", "not_applicable", "not_evaluated")) {
        local <- prediction_jml_calibration_review(fit)
        ready <- isTRUE(local$eligible)
    }
    reason_codes <- character(0)
    if (population_active) {
        if (!isTRUE(local$eligible)) 
            reason_codes <- c(reason_codes, if (normal_scoring) "population_calibration_requires_review" else "population_scoring_scope_requires_review")
    }
    if (!contract_ready) {
        reason_codes <- c(reason_codes, "readiness_contract_not_current")
    }
    if (!input_ready) {
        reason_codes <- c(reason_codes, paste0("input_not_scoring_ready:", input_state))
    }
    if (!estimability_ready) {
        reason_codes <- c(reason_codes, paste0("estimability_not_scoring_ready:", estimability_state))
    }
    if (!category_ready) {
        reason_codes <- c(reason_codes, paste0("category_not_scoring_ready:", category_state))
    }
    if (!boundary_ready) {
        reason_codes <- c(reason_codes, paste0("boundary_not_scoring_ready:", boundary_state))
    }
    if (!numerical_ready) {
        reason_codes <- c(reason_codes, paste0("numerical_not_scoring_ready:", numerical_state))
    }
    if (!parameter_ready) {
        reason_codes <- c(reason_codes, "calibration_parameter_layout_invalid")
    }
    if (rank_deficient) 
        reason_codes <- c(reason_codes, "calibration_rank_deficient")
    if (!is.null(local) && !isTRUE(local$eligible)) 
        reason_codes <- c(reason_codes, "local_calibration_check_failed")
    list(ready = isTRUE(ready), status = if (!parameter_ready) "unavailable" else if (isTRUE(local$eligible)) "conditional" else if (isTRUE(ready)) "ready" else "review_only", 
        policy_basis = "conditional_scoring_checks_v3", local_calibration_review = local, parameter_ready = isTRUE(parameter_ready), 
        reason_codes = if (isTRUE(ready)) character(0) else unique(reason_codes), source_audit_states = c(identification = estimability_state, 
            boundary = boundary_state, numerical = numerical_state), fit_readiness = as.character(state$fit_readiness %||% 
            "unknown"), inference_ready = isTRUE(state$inference_ready), readiness_contract_version = as.character(state$readiness_contract_version %||% 
            ""))
}












