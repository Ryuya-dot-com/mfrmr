mfrm_has_product_slopes <- function(fit) {
    is.list(fit) && is.list(fit$config) && !is.null(fit$config$gpcm_spec$component_levels)
}

mfrm_gmfrm_point_review <- function(prep, config, opt) {
    d <- prep$data
    config$category_support_audit <- config$category_support_audit %||% audit_mfrm_category_support(prep, 
        config, build_param_sizes(config))
    endpoint_reasons <- mfrmr_mml_additive_boundary_evidence(config)
    endpoint_reasons <- endpoint_reasons[startsWith(endpoint_reasons, "mml_unobserved_")]
    boundary <- data.frame(Facet = character(), Level = character(), Ratings = integer(), ObservedScore = integer(), 
        LocationDirection = character())
    for (facet in config$facet_names) {
        scores <- split(d$Score, d[[facet]], drop = TRUE)
        for (level in names(scores)) {
            y <- scores[[level]]
            if (length(y) && (all(y == 0L) || all(y == config$n_cat - 1L))) {
                boundary <- rbind(boundary, data.frame(Facet = facet, Level = level, Ratings = length(y), 
                  ObservedScore = y[1], LocationDirection = if (y[1] == 0L) 
                    "+Inf"
                  else "-Inf"))
            }
        }
    }
    slopes <- tryCatch(mfrm_gpcm_product_slope_targets(opt$par, config)$components$estimate, error = function(e) numeric())
    numerical <- length(slopes) > 0L && all(is.finite(slopes) & slopes > 0) && identical(opt$convergence, 
        0L) && identical(mfrmr_readiness_numerical_component(opt)$State, "ready") && length(opt$par) > 
        0L && all(is.finite(opt$par)) && length(opt$value) == 1L && is.finite(opt$value)
    absent <- nrow(boundary) > 0L || length(endpoint_reasons) > 0L
    status <- if (absent) 
        "finite_maximum_absent"
    else if (numerical) 
        "finite_numerical_solution"
    else "numerical_unresolved"
    detail <- switch(status, finite_maximum_absent = paste(if (length(endpoint_reasons)) "An unused endpoint category admits a constraint-preserving step/location path." else "A facet level has only lowest or only highest ratings.", 
        "A constraint-preserving path strictly improves the marginal likelihood at finite coordinates; the full unpenalized model has no finite maximum.", 
        "Inspect target-specific limiting estimates separately; retained full-model values are optimizer traces."), 
        finite_numerical_solution = paste("Finite point estimates met the optimizer and gradient checks at the chosen integration rule.", 
            "Integration accuracy and local curvature were not separately qualified. Global optimality and sampling accuracy are not established."), 
        numerical_unresolved = "The finite-parameter, optimizer or gradient checks were not met. Retained values are optimizer traces.")
    if (identical(opt$value_basis, "neutral_boundary_reference")) 
        detail <- paste("An extreme facet level certifies that the full model has no finite maximum.", 
            "Full-model optimization was not run; its retained values are neutral reference values, not estimates.", 
            "Inspect target-specific limiting estimates separately.")
    list(overview = data.frame(Status = status, PrimaryAvailable = identical(status, "finite_numerical_solution"), 
        AvailableSlopeComponents = if (identical(status, "finite_numerical_solution")) length(slopes) else 0L, 
        PrimaryScope = "full_component_set", IntegrationReview = "not_evaluated", LocalMaximumReview = "not_evaluated", 
        BoundaryReview = if (absent) "nonfinite_maximum_certified" else "no_extreme_location_path_found", 
        Detail = detail), boundary = boundary, endpoint_reasons = endpoint_reasons)
}

mfrm_gmfrm_refresh_boundary <- function(fit) {
    mfrm_gpcm_validate_endpoint_limit(fit)
    if (mfrm_has_product_slopes(fit) && !identical(fit$config$gpcm_point_estimation$overview$Status, 
        "finite_maximum_absent") && length(mfrmr_mml_additive_boundary_evidence(fit$config))) 
        fit <- mfrm_gmfrm_apply_point_review(fit)
    fit
}

mfrm_gmfrm_apply_point_review <- function(fit, integration_checked = FALSE) {
    if (!mfrm_has_product_slopes(fit)) 
        stop("Point review requires a two-family GPCM fit.", call. = FALSE)
    review <- mfrm_gmfrm_point_review(fit$prep, fit$config, fit$opt)
    if (isTRUE(integration_checked) && isTRUE(review$overview$PrimaryAvailable)) {
        review$overview$IntegrationReview <- "passed"
        review$overview$Detail <- paste("Finite point estimates passed likelihood, gradient and integration checks.", 
            "Local curvature, global optimality and sampling accuracy are not established; SEs and intervals are checked separately.")
    }
    if (!is.null(fit$point_limit)) {
        review$overview$Detail <- paste(review$overview$Detail, fit$point_limit$overview$Detail)
        review$slope_targets <- fit$point_limit$targets
        review$overview$AvailableSlopeComponents <- sum(is.finite(fit$point_limit$targets$PrimaryEstimate))
        review$overview$PrimaryScope <- "target_specific_likelihood_limit"
    }
    fit$config$gpcm_point_estimation <- review
    fit$readiness <- build_mfrm_readiness_record(fit$prep, fit$data_review, fit$config, fit$opt, fit$slopes)
    fit$slopes <- apply_mfrm_slope_readiness(fit$slopes, fit$readiness)
    fit$facets$person <- apply_mfrm_person_source_readiness(fit$facets$person, fit$readiness)
    fit$summary$BoundaryState <- fit$readiness$fit$BoundaryState
    fit$summary$FitReadiness <- fit$readiness$fit$FitReadiness
    fit$summary$InferenceReady <- fit$readiness$fit$InferenceReady
    fit$summary$ReadinessReasonCodes <- fit$readiness$fit$ReasonCodes
    fit$summary$BoundaryReasonCodes <- fit$readiness$components$ReasonCodes[fit$readiness$components$Component == 
        "boundary"]
    fit$summary$PointEstimateStatus <- review$overview$Status
    fit
}

mfrm_gmfrm_limit_points <- function(fit) {
    boundary <- fit$config$gpcm_point_estimation$boundary
    if (!nrow(boundary)) 
        return(fit)
    cfg <- fit$config
    spec <- fit$gmfrm$specification
    owner <- cfg$slope_facet[2L]
    targets <- data.frame(Facet = fit$slopes$SlopeOwner, Level = fit$slopes$SlopeFacet, PrimaryEstimate = NA_real_, 
        ParameterStatus = "limit_not_evaluated")
    steps <- data.frame(StepFacet = fit$steps$StepFacet, Step = fit$steps$Step, PrimaryEstimate = if (cfg$n_cat == 
        2L) 
        0
    else NA_real_, ParameterStatus = if (cfg$n_cat == 2L) 
        "fixed_by_constraint"
    else "limit_not_evaluated")
    limit <- list(overview = data.frame(Status = "not_evaluated", RemovedRows = 0L, RetainedRows = nrow(fit$prep$data), 
        RetainedPersons = length(fit$prep$levels$Person), NoncenterFacet = owner, Detail = "Target-specific limiting estimates were not evaluated."), 
        targets = targets, step_targets = steps, fit = NULL)
    finish <- function(detail, status = "not_evaluated") {
        limit$overview$Status <- status
        limit$overview$Detail <- detail
        fit$point_limit <- limit
        mfrm_gmfrm_apply_point_review(fit)
    }
    boundary_facet <- unique(boundary$Facet)
    if (length(boundary_facet) != 1L || boundary_facet == cfg$slope_facet[1L]) 
        return(finish(paste("Limiting refits require extreme levels in one facet other than the reference slope family.", 
            "No target is declared unidentified solely because this reduction is unsupported.")))
    affected <- targets$Facet == boundary_facet & targets$Level %in% boundary$Level
    limit$targets$ParameterStatus[affected] <- "unidentified_likelihood_limit"
    if (boundary_facet == cfg$step_facet && cfg$n_cat > 2L) 
        limit$step_targets$ParameterStatus[steps$StepFacet %in% boundary$Level] <- "unidentified_likelihood_limit"
    data <- spec$data
    keep <- !as.character(data[[boundary_facet]]) %in% boundary$Level
    data <- data[keep, , drop = FALSE]
    limit$overview$RemovedRows <- sum(!keep)
    limit$overview$RetainedRows <- nrow(data)
    limit$overview$RetainedPersons <- length(unique(data[[spec$person]]))
    if (length(unique(data[[boundary_facet]])) < 2L || any(vapply(setdiff(cfg$facet_names, boundary_facet), 
        function(f) !setequal(as.character(data[[f]]), fit$prep$levels[[f]]), TRUE))) 
        return(finish("The limiting model loses another facet level or leaves fewer than two levels in the reduced facet; its remaining targets require a separate identification review."))
    problem <- tryCatch(mfrm_gmfrm_problem(data, cfg$n_cat - 1L, gauss_hermite_normal(cfg$estimation_control$quad_points), 
        cfg$slope_facet, spec$person, spec$score, cfg$facet_names, cfg$step_facet, owner, cfg$slope_facet[1L]), 
        error = identity)
    if (inherits(problem, "error")) 
        return(finish(paste("Limiting model:", conditionMessage(problem))))
    remaining <- mfrm_gmfrm_point_review(problem$common$prep, problem$common$config, fit$opt)
    if (nrow(remaining$boundary)) 
        return(finish("Additional extreme levels appear in the limiting data; no recursive reduction was applied."))
    if (length(remaining$endpoint_reasons)) 
        return(finish("Unused endpoint categories leave a nonfinite maximum in the limiting data; no further boundary reduction was applied."))
    start <- problem$start
    shared <- intersect(names(start), names(fit$opt$par))
    start[shared] <- fit$opt$par[shared]
    locations <- fit$facets$others
    shift <- 0
    for (facet in setdiff(cfg$facet_names, owner)) {
        rows <- locations[locations$Facet == facet & locations$Level %in% problem$levels[[facet]], ]
        center <- mean(rows$Estimate)
        shift <- shift + center
        ids <- paste0("location:", facet, ":", rows$Level)
        free <- ids %in% names(start)
        start[ids[free]] <- rows$Estimate[free] - center
    }
    rows <- locations[locations$Facet == owner & locations$Level %in% problem$levels[[owner]], ]
    start[paste0("location:", owner, ":", rows$Level)] <- rows$Estimate + shift
    control <- list(mml_engine = cfg$estimation_control$mml_engine_used, mml_integration = "auto", quad_points = cfg$estimation_control$quad_points, 
        maxit = cfg$estimation_control$maxit)
    if (control$mml_engine == "direct") {
        control$reltol <- fit$gmfrm$controls$reltol
        control$gpcm_mml_start <- list(retained = start, neutral = problem$start)
    }
    else control$em_score_tol <- fit$gmfrm$controls$score_tol
    model <- list(person = spec$person, facets = cfg$facet_names, score = spec$score, rating_min = 0L, 
        rating_max = cfg$n_cat - 1L, category_policy = "preserve", model = "GPCM", method = "MML", slope_facet = cfg$slope_facet, 
        slope_reference = cfg$slope_facet[1L], step_facet = cfg$step_facet, noncenter_facet = owner, 
        gpcm_mml_identification = "fixed_standard_normal")
    candidate <- tryCatch(fit_mfrm(data, spec = model, control = control), error = identity)
    if (inherits(candidate, "error")) {
        limit$failure <- list(message = conditionMessage(candidate), history = candidate$history, last_candidate = candidate$last_candidate)
        return(finish(paste("Limiting refit did not pass point-estimate checks:", conditionMessage(candidate)), 
            "numerical_unresolved"))
    }
    limit$fit <- candidate
    if (!identical(candidate$config$gpcm_point_estimation$overview$IntegrationReview, "passed")) 
        return(finish("The retained limiting fit has no accuracy-qualified points.", "numerical_unresolved"))
    candidate$config$gpcm_limit_source <- list(boundary = boundary, removed_rows = sum(!keep), original_rows = nrow(fit$prep$data))
    candidate$config$gpcm_point_estimation$overview$Detail <- paste(candidate$config$gpcm_point_estimation$overview$Detail, 
        "These are limiting-likelihood point estimates after a data-dependent boundary reduction; ordinary intervals are not qualified.")
    limit$fit <- candidate
    for (facet in unique(targets$Facet)) {
        src <- candidate$slopes[candidate$slopes$SlopeOwner == facet, ]
        dst <- which(targets$Facet == facet & targets$Level %in% src$SlopeFacet)
        limit$targets$PrimaryEstimate[dst] <- src$PrimaryEstimate[match(targets$Level[dst], src$SlopeFacet)]
        limit$targets$ParameterStatus[dst] <- "finite_likelihood_limit"
    }
    if (cfg$n_cat > 2L) 
        for (i in seq_len(nrow(candidate$steps))) {
            src <- candidate$steps[i, ]
            dst <- steps$StepFacet == src$StepFacet & steps$Step == src$Step
            limit$step_targets$PrimaryEstimate[dst] <- src$Estimate
            limit$step_targets$ParameterStatus[dst] <- "finite_likelihood_limit"
        }
    finish(paste("Remaining component slopes were fitted to the limiting likelihood with point-estimate integration checks.", 
        "Any slopes or free steps owned by removed levels are unidentified in this limit.", "Inspect point_limit for step targets, retained data and the location convention; full-model SEs remain unavailable."), 
        "partial_points_available")
}

mfrm_gpcm_endpoint_limit <- function(fit) {
    cfg <- fit$config
    if (!identical(cfg$model, "GPCM") || !identical(cfg$method, "MML") || !is.null(fit$point_limit) || 
        !"mml_unobserved_global_endpoint" %in% mfrmr_mml_additive_boundary_evidence(cfg)) 
        return(fit)
    y <- fit$prep$data$score_k
    K <- cfg$n_cat - 1L
    counts <- tabulate(y + 1L, nbins = K + 1L)
    missing <- which(counts == 0L) - 1L
    owners <- if (mfrm_has_product_slopes(fit)) 
        fit$slopes$SlopeOwner
    else rep(cfg$slope_facet, nrow(fit$slopes))
    limit <- list(overview = data.frame(Status = "not_evaluated", RemovedRows = 0L, RetainedRows = length(y), 
        RetainedPersons = length(fit$prep$levels$Person), NoncenterFacet = cfg$noncenter_facet, Reduction = "global_endpoint", 
        Detail = "Endpoint limiting estimates were not evaluated."), targets = data.frame(Facet = owners, 
        Level = fit$slopes$SlopeFacet, PrimaryEstimate = NA_real_, ParameterStatus = "limit_not_evaluated"), 
        step_targets = data.frame(StepFacet = fit$steps$StepFacet, Step = fit$steps$Step, PrimaryEstimate = NA_real_, 
            ParameterStatus = "different_limiting_parameterization"), fit = NULL)
    finish <- function(detail, status = "not_evaluated") {
        limit$overview$Status <- status
        limit$overview$Detail <- detail
        fit$point_limit <- limit
        if (mfrm_has_product_slopes(fit)) 
            return(mfrm_gmfrm_apply_point_review(fit))
        fit$config$gpcm_point_estimation <- list(overview = data.frame(Status = "finite_maximum_absent", 
            PrimaryAvailable = FALSE, AvailableSlopeComponents = sum(is.finite(limit$targets$PrimaryEstimate)), 
            PrimaryScope = "target_specific_likelihood_limit", IntegrationReview = "not_applicable", 
            LocalMaximumReview = "not_evaluated", BoundaryReview = "nonfinite_maximum_certified", Detail = paste("The full model has no finite maximum.", 
                detail)), slope_targets = limit$targets)
        fit$readiness <- build_mfrm_readiness_record(fit$prep, fit$data_review, fit$config, fit$opt, 
            fit$slopes)
        fit$slopes <- apply_mfrm_slope_readiness(fit$slopes, fit$readiness)
        fit$slopes$PrimaryPopulationSD <- if (!is.null(limit$fit)) 
            if (isTRUE(limit$fit$population$active)) 
                sqrt(limit$fit$population$sigma2)
            else 1
        else NA_real_
        fit$slopes$FixedLatentSDPrimaryEstimate <- fit$slopes$PrimaryEstimate * fit$slopes$PrimaryPopulationSD
        fit$slopes$FixedLatentSDPrimaryBasis <- "limiting_population_sd_times_relative_slope"
        fit$summary$PointEstimateStatus <- "finite_maximum_absent"
        fit
    }
    free <- function(s) all(is.na(s$anchors)) && all(is.na(s$groups))
    if (K < 2L || length(missing) != 1L || !missing %in% c(0L, K) || any(fit$prep$data$Weight != 1) || 
        length(cfg$interaction_specs) || any(cfg$facet_signs[cfg$facet_names] != -1) || !all(vapply(cfg$facet_specs, 
        free, TRUE)) || !all(vapply(cfg$step_specs, free, TRUE)) || length(cfg$dummy_facets) || (isTRUE(fit$population$active) && 
        !identical(fit$population$source, "gpcm_mml_default_identification"))) 
        return(finish("Endpoint refits require exactly one globally unused endpoint, free steps and locations, unit weights, no interactions or dummy facets, and a fixed normal or default intercept-only population."))
    shift <- as.integer(missing == 0L)
    local <- split(y, fit$prep$data[[cfg$step_facet]], drop = TRUE)
    retained <- setdiff(0:K, missing)
    if (any(vapply(local, function(v) !all(retained %in% v), TRUE))) 
        return(finish("Additional owner-specific category gaps remain; no recursive category reduction was applied."))
    map <- fit$prep$score_map
    original <- map$OriginalScore[match((0:K) + fit$prep$rating_min, map$InternalScore)]
    limit$category_map <- data.frame(OriginalScore = original, OriginalCategory = 0:K, ReducedCategory = ifelse(0:K == 
        missing, NA_integer_, 0:K - shift), Status = ifelse(0:K == missing, "zero_probability_limit", 
        "retained"))
    data <- fit$prep$data[c("Person", cfg$facet_names)]
    data$Score <- as.integer(y - shift)
    args <- cfg$replay_inputs
    args[c("package_version", "mml_starts")] <- NULL
    if (is.list(args$gpcm_mml_start)) 
        args$gpcm_mml_start <- "both"
    args$data <- data
    args$person <- "Person"
    args$score <- "Score"
    args$rating_min <- 0L
    args$rating_max <- K - 1L
    args$keep_original <- TRUE
    args$category_policy <- "preserve"
    args$missing_codes <- numeric()
    args$attach_diagnostics <- FALSE
    if (mfrm_has_product_slopes(fit)) 
        args[c("missing_codes", "attach_diagnostics")] <- NULL
    args$mml_integration <- "auto"
    candidate <- tryCatch(do.call(fit_mfrm, args), error = identity)
    if (inherits(candidate, "error")) {
        limit$failure <- list(message = conditionMessage(candidate), history = candidate$history, last_candidate = candidate$last_candidate)
        return(finish(paste("Endpoint limiting refit failed:", conditionMessage(candidate)), "numerical_unresolved"))
    }
    if (!identical(candidate$summary$MMLAccuracyStatus, "criteria_met") || !isTRUE(candidate$summary$Converged) || 
        length(mfrmr_mml_additive_boundary_evidence(candidate$config)) || any(!is.finite(candidate$slopes$Estimate) | 
        candidate$slopes$Estimate <= 0)) 
        return(finish("The endpoint limiting fit did not pass its numerical point-estimate checks.", 
            "numerical_unresolved"))
    candidate$config$gpcm_limit_source <- list(kind = "global_endpoint", category_map = limit$category_map, 
        removed_rows = 0L, original_rows = length(y), original_categories = cfg$n_cat)
    limit$fit <- candidate
    limit$targets$PrimaryEstimate <- candidate$slopes$Estimate
    limit$targets$ParameterStatus <- "finite_likelihood_limit"
    finish(paste("Component slopes use a separately fitted endpoint limiting likelihood; inspect category_map for original score labels.", 
        "Locations, centered steps and the population mean belong to the reduced-category convention and do not replace original coordinates.", 
        "Global optimality and ordinary intervals after this data-dependent reduction are not qualified."), 
        "partial_points_available")
}

mfrm_gpcm_validate_endpoint_limit <- function(fit) {
    limit <- fit$point_limit
    if (!identical(limit$overview$Reduction, "global_endpoint") || is.null(limit$fit)) 
        return(invisible(NULL))
    reduced <- limit$fit
    cfg <- fit$config
    map <- limit$category_map
    refuse <- function() stop("The saved endpoint limiting fit does not match its source ratings, category mapping or slope targets.", 
        call. = FALSE)
    y <- fit$prep$data$score_k
    absent <- which(tabulate(y + 1L, nbins = cfg$n_cat) == 0L) - 1L
    if (length(absent) != 1L || !absent %in% c(0L, cfg$n_cat - 1L) || !is.data.frame(map) || nrow(map) != 
        cfg$n_cat || !identical(map$OriginalCategory, seq_len(cfg$n_cat) - 1L) || !identical(map$OriginalScore, 
        fit$prep$score_map$OriginalScore[match(map$OriginalCategory + fit$prep$rating_min, fit$prep$score_map$InternalScore)]) || 
        !isTRUE(all.equal(map$ReducedCategory, ifelse(map$OriginalCategory == absent, NA_integer_, map$OriginalCategory - 
            as.integer(absent == 0L)), check.attributes = FALSE)) || !identical(reduced$config$gpcm_limit_source$category_map, 
        map) || !identical(reduced$config$n_cat, cfg$n_cat - 1L) || !identical(reduced$prep$data$score_k, 
        as.integer(y - as.integer(absent == 0L)))) 
        refuse()
    for (field in c("facet_names", "slope_facet", "step_facet", "noncenter_facet", "gpcm_mml_identification")) if (!identical(reduced$config[[field]], 
        cfg[[field]])) 
        refuse()
    for (field in c("Person", cfg$facet_names, "Weight")) if (!identical(as.character(fit$prep$data[[field]]), 
        as.character(reduced$prep$data[[field]]))) 
        refuse()
    owner <- reduced$slopes[["SlopeOwner"]] %||% rep(cfg$slope_facet, nrow(reduced$slopes))
    if (!identical(limit$targets$Facet, owner) || !identical(limit$targets$Level, reduced$slopes$SlopeFacet) || 
        !identical(limit$targets$PrimaryEstimate, reduced$slopes$Estimate) || !identical(fit$slopes$PrimaryEstimate, 
        limit$targets$PrimaryEstimate) || !all(is.na(limit$step_targets$PrimaryEstimate))) 
        refuse()
    values <- if (mfrm_has_product_slopes(reduced)) 
        mfrm_gpcm_product_slope_targets(reduced$opt$par, reduced$config)$components$estimate
    else expand_params(reduced$opt$par, build_param_sizes(reduced$config), reduced$config)$slopes
    if (!isTRUE(all.equal(unname(values), unname(reduced$slopes$Estimate), tolerance = 1e-10))) 
        refuse()
    invisible(NULL)
}

stop_if_product_slopes <- function(fit, helper) {
    stop_if_jml_adjustment(fit, helper)
    if (mfrm_has_product_slopes(fit)) {
        stop(new_gpcm_scope_error(paste0("`", helper, "` is not available for two slope families. ", 
            "Use summary(fit) and mfrm_curve_intervals(fit, newdata) for fitted curves without intervals; ", 
            "mfrm_report(type = 'category_curves', fit, newdata = contexts) supplies full-context curves and cumulative thresholds without intervals. ", 
            "confint(fit, parm = 'slopes') separately checks experimental component log-Wald intervals. ", 
            "mfrm_response_diagnostics(fit) supplies descriptive posterior residuals with the fitted integration method. ", 
            "An explicit method = 'profile' call can separately review one named component slope. ", 
            "saved curves can be passed to mfrm_results(fit, include = c('fit', 'plots'), compute = 'never', intervals = curves)."), 
            helper = helper, status = "blocked", area = "Two-family GPCM outputs"))
    }
    invisible(NULL)
}

build_gpcm_product_slope_spec <- function(prep, slope_facets, step_facet) {
    if (length(slope_facets) != 2L || anyDuplicated(slope_facets) || !all(slope_facets %in% prep$facet_names)) {
        stop("Product slopes require two distinct observed facets.", call. = FALSE)
    }
    levels <- prep$levels[slope_facets]
    n <- lengths(levels)
    if (any(n < 2L)) 
        stop("Product slopes require at least two levels per facet.")
    ids <- as.data.frame(unname(lapply(prep$data[slope_facets], as.integer)), check.names = FALSE)
    names(ids) <- slope_facets
    cells <- unique(ids)
    cells <- cells[order(cells[[1]], cells[[2]]), , drop = FALSE]
    rownames(cells) <- NULL
    nr <- nrow(cells)
    first <- which(cells[[1]] < n[1])
    reference <- which(cells[[1]] == n[1])
    design <- Matrix::sparseMatrix(i = c(first, rep(reference, n[1] - 1L), seq_len(nr)), j = c(cells[[1]][first], 
        rep(seq_len(n[1] - 1L), each = length(reference)), n[1] - 1L + cells[[2]]), x = c(rep(1, length(first)), 
        rep(-1, length(reference) * (n[1] - 1L)), rep(1, nr)), dims = c(nr, sum(n) - 1L))
    if (nrow(design) < ncol(design) || as.integer(Matrix::rankMatrix(design, method = "qr")) < ncol(design)) {
        stop("Facet crossings do not identify both slope families.", call. = FALSE)
    }
    list(active = TRUE, slope_facet = slope_facets, step_facet = step_facet, component_levels = levels, 
        cells = cells, log_slope_design = design, n_params = ncol(design), identification = "first_family_sum_zero_log_slopes", 
        scale_reference = "fixed_standard_normal", reduction_reference = "PCM when all slopes equal 1")
}

gpcm_log_slope_design <- function(spec) {
    spec$log_slope_design %||% sum_zero_jacobian(length(spec$levels))
}

mfrm_gpcm_product_metadata <- function(spec) {
    n <- lengths(spec$component_levels)
    data.frame(Owner = rep(names(n), n), Level = unlist(spec$component_levels, use.names = FALSE), ScaleReference = rep(c("geometric_mean_one", 
        "fixed_standard_normal"), n), Identification = rep(c("sum_to_zero_log_slopes", "free_given_first_family_and_population"), 
        n))
}

mfrm_gpcm_slope_roles <- function(config) {
    owners <- as.character(config$slope_facet %||% NA_character_)
    spec <- config$gpcm_spec
    if (is.null(spec$component_levels)) {
        if (length(owners) != 1L) {
            stop("Multiple slope owners require their fitted product specification.", call. = FALSE)
        }
        return(data.frame(SlopeOwner = owners, ScaleReference = "geometric_mean_one", Identification = "sum_to_zero_log_slopes"))
    }
    if (!identical(owners, names(spec$component_levels)) || length(owners) != 2L || !identical(spec$identification, 
        "first_family_sum_zero_log_slopes") || !identical(spec$scale_reference, "fixed_standard_normal") || 
        !identical(config$method, "MML") || isTRUE(config$population_spec$active)) {
        stop("Slope summaries require the fitted owner order and scale constraints.", call. = FALSE)
    }
    roles <- unique(mfrm_gpcm_product_metadata(spec)[c("Owner", "ScaleReference", "Identification")])
    names(roles)[1] <- "SlopeOwner"
    rownames(roles) <- NULL
    roles
}

mfrm_match_slope_table <- function(owners, levels, table) {
    index <- rep(NA_integer_, length(levels))
    if (!length(levels) || !nrow(table)) 
        return(index)
    if (is.null(table[["SlopeOwner"]]) && length(unique(owners)) != 1L) {
        stop("Multiple slope owners require an explicit SlopeOwner column.", call. = FALSE)
    }
    for (owner in unique(owners)) {
        rows <- if (is.null(table[["SlopeOwner"]])) 
            seq_len(nrow(table))
        else which(table[["SlopeOwner"]] == owner)
        if (anyDuplicated(table$SlopeFacet[rows])) {
            stop("Slope levels must be unique within each owner.", call. = FALSE)
        }
        selected <- which(owners == owner)
        index[selected] <- rows[match(levels[selected], table$SlopeFacet[rows])]
    }
    index
}

mfrm_gpcm_product_slope_targets <- function(par, config) {
    spec <- config$gpcm_spec
    if (is.null(spec$log_slope_design) || !identical(config$model, "GPCM") || !identical(config$method, 
        "MML") || isTRUE(config$population_spec$active)) {
        stop("Product-slope targets currently require the fixed-standard-normal MML model.")
    }
    sizes <- build_param_sizes(config)
    if (length(par) != sum(unlist(sizes)) || any(!is.finite(par))) {
        stop("Product-slope targets require the complete finite free-parameter vector.")
    }
    invisible(expand_params(par, sizes, config))
    n <- lengths(spec$component_levels)
    component_design <- as.matrix(Matrix::bdiag(sum_zero_jacobian(n[1]), diag(n[2])))
    metadata <- mfrm_gpcm_product_metadata(spec)
    contexts <- as.data.frame(unname(Map(function(ids, levels) levels[ids], spec$cells, spec$component_levels)), 
        check.names = FALSE)
    names(contexts) <- names(spec$component_levels)
    make_target <- function(design, labels, table, description) {
        jac <- matrix(0, nrow(design), length(par))
        jac[, build_param_slices(sizes)[["log_slopes"]]] <- as.matrix(design)
        value <- as.numeric(jac %*% par)
        list(value = value, estimate = exp(value), jacobian = jac, labels = labels, log_scale = TRUE, 
            metadata = table, scale = "fixed_standard_normal", target = description)
    }
    list(components = make_target(component_design, paste(metadata$Owner, metadata$Level, sep = ":"), 
        metadata, "Facet slope components on the declared fixed population scale"), effective = make_target(spec$log_slope_design, 
        paste0("crossing:", seq_len(nrow(contexts))), contexts, "Effective slope products for observed crossings"))
}

project_gpcm_log_slope_gradient <- function(gradient, spec) {
    if (is.null(spec$log_slope_design)) 
        return(project_sum_zero_gradient(gradient))
    as.numeric(Matrix::crossprod(spec$log_slope_design, gradient))
}

collapse_gpcm_log_slopes <- function(log_slopes, spec) {
    if (is.null(spec$log_slope_design)) 
        return(log_slopes[seq_len(spec$n_params %||% 0L)])
    design <- spec$log_slope_design
    if (length(log_slopes) != nrow(design) || any(!is.finite(log_slopes))) {
        stop("Effective log slopes must match the fitted crossings.", call. = FALSE)
    }
    free <- as.numeric(Matrix::qr.coef(Matrix::qr(design), log_slopes))
    if (max(abs(as.numeric(design %*% free) - log_slopes)) > 1e-10 * max(1, abs(log_slopes))) {
        stop("Effective log slopes do not follow the fitted product structure.", call. = FALSE)
    }
    free
}

mfrm_gmfrm_roles <- function(facets, slope_facets, step_facet, noncenter_facet, slope_reference = slope_facets[1L]) {
    names_ok <- function(x) is.character(x) && length(x) > 0L && !anyNA(x) && all(nzchar(trimws(x))) && 
        !anyDuplicated(x)
    if (!names_ok(facets) || !names_ok(slope_facets) || length(slope_facets) != 2L || !all(slope_facets %in% 
        facets)) 
        stop("Two slope families require exactly two distinct slope_facet names among the declared facets.", 
            call. = FALSE)
    if (!names_ok(slope_reference) || length(slope_reference) != 1L || !slope_reference %in% slope_facets) 
        stop("`slope_reference` must name one of the two slope facets.", call. = FALSE)
    if (!names_ok(step_facet) || length(step_facet) != 1L || !step_facet %in% facets || !names_ok(noncenter_facet) || 
        length(noncenter_facet) != 1L || !noncenter_facet %in% facets) 
        stop("Two-family step_facet and noncenter_facet must each name one declared non-Person facet.", 
            call. = FALSE)
    owners <- c(unname(slope_reference), setdiff(slope_facets, slope_reference))
    list(facets = c(owners, sort(setdiff(facets, owners))), slope_facets = owners, step_facet = unname(step_facet), 
        noncenter_facet = unname(noncenter_facet), slope_reference = unname(slope_reference))
}

mfrm_gmfrm_common_setup <- function(data, max_score, slope_facets = c("Task", "Rater"), person = "Person", 
    score = "Score", facets = slope_facets, step_facet = slope_facets[2L], noncenter_facet = slope_facets[2L], 
    slope_reference = slope_facets[1L]) {
    roles <- mfrm_gmfrm_roles(facets, slope_facets, step_facet, noncenter_facet, slope_reference)
    facets <- roles$facets
    slope_facets <- roles$slope_facets
    data[c(person, facets)] <- lapply(data[c(person, facets)], as.character)
    prep <- prepare_mfrm_data(data, person, facets, score, rating_min = 0, rating_max = max_score, keep_original = TRUE)
    built <- build_estimation_config(prep, "GPCM", "MML", step_facet, slope_facets[1L], weight_col = NULL, 
        facet_signs = setNames(rep(-1, length(facets)), facets), positive_facets = character(), noncenter_facet = noncenter_facet, 
        dummy_facets = character(), anchor_df = NULL, group_anchor_df = NULL)
    config <- built$config
    config$slope_facet <- slope_facets
    config$gpcm_spec <- build_gpcm_product_slope_spec(prep, slope_facets, step_facet)
    identity <- mfrmr_gpcm_model_identity("GPCM", config$gpcm_spec)
    config$gpcm_model_family <- identity$model_family
    config$gpcm_slope_composition <- identity$slope_composition
    config$gpcm_mml_identification <- "fixed_population_first_family_gm1"
    config$gpcm_common_discrimination <- "free_second_family"
    sizes <- build_param_sizes(config)
    idx <- build_indices(prep, step_facet, slope_facets, gpcm_spec = config$gpcm_spec)
    list(prep = prep, config = config, sizes = sizes, idx = idx, parameter_map = mfrmr_mml_optimizer_parameter_map(prep, 
        idx, config, sizes))
}

mfrm_gpcm_product_inference <- function(fit) {
    checks <- data.frame(Check = character(), Passed = logical(), Detail = character())
    out <- list(covariance = NULL, information = NULL, checks = checks, check = list(eligible = FALSE, 
        review = "Two-family inference was not evaluated."))
    record <- function(name, passed, detail) {
        out$checks <<- rbind(out$checks, data.frame(Check = name, Passed = isTRUE(passed), Detail = detail))
        isTRUE(passed)
    }
    refuse <- function() {
        out$check$review <- paste(out$checks$Detail[!out$checks$Passed], collapse = " ")
        out
    }
    if (!is.null(fit$config$gpcm_limit_source)) {
        record("Limiting likelihood", FALSE, "This fit supplies limiting point estimates after a data-dependent boundary reduction; ordinary interval theory has not been qualified.")
        return(refuse())
    }
    config <- fit$config
    adaptive <- mfrmr_adaptive_integration(config)
    if (!record("Scope", mfrm_has_product_slopes(fit) && identical(config$method, "MML") && !isTRUE(config$population_spec$active) && 
        identical(config$posterior_basis, "fixed_standard_normal") && identical(config$estimation_control$mml_engine_used, 
        if (adaptive) 
            "direct"
        else "em") && is.null(config$weight_col) && all(fit$prep$data$Weight == 1) && config$noncenter_facet %in% 
        config$facet_names, "Two-family intervals require unweighted fixed-N(0,1) MML with fixed-grid EM or adaptive direct integration.")) 
        return(refuse())
    specification <- fit$gmfrm$specification
    reference <- tryCatch(do.call(mfrm_gmfrm_common_setup, specification[setdiff(names(specification), 
        "quadrature")]), error = function(e) NULL)
    without_factor_cache <- function(spec) {
        if (inherits(spec$log_slope_design, "dgCMatrix")) 
            spec$log_slope_design@factors <- list()
        spec
    }
    if (!record("Model identity", !is.null(reference) && identical(lapply(reference$prep$data, identity), 
        lapply(fit$prep$data, identity)) && identical(reference$config$facet_specs, config$facet_specs) && 
        identical(without_factor_cache(reference$config$gpcm_spec), without_factor_cache(config$gpcm_spec)) && 
        identical(reference$config$facet_signs, config$facet_signs) && identical(reference$config$interaction_specs, 
        config$interaction_specs) && identical(reference$config$n_cat, config$n_cat), "The saved data, constraints and product specification must match the original fitted model.")) 
        return(refuse())
    roles <- tryCatch(mfrm_gpcm_slope_roles(config), error = function(e) NULL)
    target <- tryCatch(mfrm_gpcm_product_slope_targets(fit$opt$par, config)$components, error = function(e) NULL)
    index <- if (!is.null(target)) 
        tryCatch(mfrm_match_slope_table(target$metadata$Owner, target$metadata$Level, fit$slopes), error = function(e) integer())
    else integer()
    if (!record("Slope identity", !is.null(roles) && !is.null(target) && length(index) == nrow(fit$slopes) && 
        !anyNA(index) && isTRUE(all.equal(target$estimate, unname(fit$slopes$Estimate[index]), tolerance = 1e-10)), 
        "Slope owners, levels, scale constraints and retained estimates must agree.")) 
        return(refuse())
    point <- mfrm_gmfrm_point_review(fit$prep, config, fit$opt)
    if (identical(point$overview$Status, "finite_maximum_absent")) {
        record("Finite maximum", FALSE, point$overview$Detail)
        return(refuse())
    }
    if (adaptive) {
        if (!record("Direct convergence", isTRUE(fit$summary$Converged) && identical(fit$opt$convergence, 
            0L) && identical(fit$opt$optimizer_diagnostics$ConvergenceBasis, "optimizer_gradient") && 
            identical(fit$opt$optimizer_diagnostics$ConvergenceSeverity, "pass"), "Direct adaptive MML must pass its optimizer and gradient convergence checks.")) 
            return(refuse())
    }
    else if (!record("EM convergence", isTRUE(fit$summary$Converged) && identical(fit$opt$optimizer_diagnostics$ConvergenceBasis, 
        "marginal_score_per_person"), "EM must meet its per-Person marginal-score stopping rule.")) 
        return(refuse())
    category <- audit_mfrm_category_support(fit$prep, config, build_param_sizes(config))
    if (!record("Category support", identical(category$readiness$CategoryState, "adequate"), "Category support must be adequate for a local Wald approximation; inspect the declared score ladder.")) 
        return(refuse())
    info <- compute_mml_parameter_covariance(fit)
    out$information <- info
    if (!record("Joint information", identical(info$status, "ok") && !isTRUE(info$regularized) && !is.null(info$cov) && 
        all(is.finite(info$cov)), paste("An unregularized inverse of the full marginal information is required.", 
        info$detail))) 
        return(refuse())
    ev <- info$solution_information$evaluation_summary
    if (!record("Likelihood identity", nrow(ev) == 1L && is.finite(fit$opt$value) && is.finite(ev$ReevaluatedObjective) && 
        abs(ev$ReevaluatedObjective - fit$opt$value) <= 1e-10 * max(1, abs(fit$opt$value)), "The retained likelihood must match reevaluation at the saved data and parameters.")) 
        return(refuse())
    p <- ncol(info$cov)
    n <- length(fit$prep$levels$Person)
    budget <- getOption("mfrmr.max_information_bytes", 256 * 1024^2)
    if (!record("Score workspace", 4 * 8 * as.double(n) * p <= budget, "Person-score derivative workspace must fit within mfrmr.max_information_bytes.")) 
        return(refuse())
    scores <- tryCatch(mfrm_mml_person_scores_numeric(fit), error = function(e) e)
    fine <- tryCatch(mfrm_mml_person_scores_numeric(fit, relative_step = 5e-06), error = function(e) e)
    if (inherits(scores, "error") || inherits(fine, "error")) {
        record("Score derivatives", FALSE, "Person marginal-score derivatives could not be verified.")
        return(refuse())
    }
    column_scale <- sqrt(colSums(scores^2))
    scaled <- sweep(scores, 2, pmax(column_scale, .Machine$double.eps), "/")
    scaled_fine <- sweep(fine, 2, pmax(column_scale, .Machine$double.eps), "/")
    rank <- mfrmr_transformation_rank_ladder(scaled)
    fine_rank <- mfrmr_transformation_rank_ladder(scaled_fine)
    out$score_rank <- rank$rank_ladder
    score_rank <- if (rank$valid) 
        min(rank$rank_ladder$Rank)
    else NA_integer_
    fine_score_rank <- if (fine_rank$valid) 
        min(fine_rank$rank_ladder$Rank)
    else NA_integer_
    rank_deficient <- min(score_rank, fine_score_rank) < p
    derivative_error <- max(abs(scaled - scaled_fine))
    q <- config$estimation_control$quad_points
    out$numerical_checks <- data.frame(QuadraturePoints = q, ComparisonPoints = 2L * q - 1L, Integration = if (adaptive) 
        "adaptive"
    else "fixed", FreeParameters = p, ScoreRank = score_rank, FineScoreRank = fine_score_rank, ScoreRankDeficient = rank_deficient, 
        DerivativeDifference = derivative_error, MaximumMeanScore = NA_real_, CurvatureScaledGradient = NA_real_, 
        InverseResidual = NA_real_, QuadratureScoreShift = NA_real_, QuadratureCovarianceChange = NA_real_)
    if (!record("Score derivative stability", rank$valid && fine_rank$valid && is.finite(derivative_error) && 
        derivative_error <= 1e-06, "Person marginal-score derivatives must be finite and agree within 1e-6 after column scaling at both derivative steps.")) 
        return(refuse())
    gradient <- -colSums(scores)
    scaled_gradient <- sqrt(max(0, drop(crossprod(gradient, info$cov %*% gradient))))
    tol <- if (adaptive) 
        1e-06
    else min(fit$gmfrm$controls$score_tol %||% 1e-06, 1e-06)
    inverse_error <- norm(info$hessian %*% info$cov - diag(p), "I")
    out$numerical_checks$MaximumMeanScore <- max(abs(gradient))/n
    out$numerical_checks$CurvatureScaledGradient <- scaled_gradient
    out$numerical_checks$InverseResidual <- inverse_error
    out$numerical_checks$OptimizationCaution <- scaled_gradient > 1e-04
    if (!record("Stationary local maximum", is.finite(scaled_gradient) && max(abs(gradient))/n <= tol && 
        scaled_gradient <= 0.01 && inverse_error <= 1e-06, paste0("The fresh per-Person score must meet ", 
        if (adaptive) 
            "1e-6"
        else "min(em_score_tol, 1e-6)", ", standardized Newton displacement must be at most 0.01, and inverse residual at most 1e-6. Displacement above 1e-4 retains a warning."))) 
        return(refuse())
    refined_fit <- fit
    refined_fit$config$estimation_control$quad_points <- 2L * q - 1L
    refined <- tryCatch(compute_mml_parameter_covariance(refined_fit), error = function(e) NULL)
    refined_scores <- tryCatch(mfrm_mml_person_scores_numeric(refined_fit), error = function(e) NULL)
    if (!record("Refined quadrature information", !is.null(refined) && identical(refined$status, "ok") && 
        !isTRUE(refined$regularized) && !is.null(refined_scores), "Higher-order quadrature must supply positive unregularized marginal information and finite scores.")) 
        return(refuse())
    root <- chol(info$hessian)
    gradient_change <- -colSums(refined_scores) - gradient
    shift <- sqrt(max(0, drop(crossprod(gradient_change, info$cov %*% gradient_change))))
    change <- norm(root %*% (refined$cov - info$cov) %*% t(root), "2")
    out$numerical_checks$QuadratureScoreShift <- shift
    out$numerical_checks$QuadratureCovarianceChange <- change
    if (!record("Quadrature sensitivity", is.finite(shift) && is.finite(change) && shift <= 0.01 && change <= 
        0.01, "The q versus 2q-1 comparison must be at most 0.01 in standardized score displacement and covariance change; otherwise refit with more quadrature points.")) 
        return(refuse())
    out$covariance <- info$cov
    optimization_caution <- if (scaled_gradient > 1e-04) 
        sprintf("Small optimization residual: standardized Newton displacement is %.3g (above 1e-4, at most 0.01). The intervals retain this local numerical approximation.", 
            scaled_gradient)
    else ""
    rank_caution <- if (rank_deficient) 
        sprintf("Observed Person-score rank is deficient (%d of %d free parameters). These model-based intervals use the observed Hessian, not an empirical score covariance; full-parameter sandwich inference is unavailable and finite-sample coverage is unqualified.", 
            min(score_rank, fine_score_rank), p)
    else ""
    out$check <- list(eligible = TRUE, review = "Experimental local Wald approximation from full joint marginal information; sampling coverage is not qualified.", 
        caution = trimws(paste("Experimental two-family intervals: local numerical checks passed, but global identification, boundary absence and sampling coverage are not established.", 
            optimization_caution, rank_caution, paste(mfrm_mml_information_caution(info), collapse = " "))))
    out
}
