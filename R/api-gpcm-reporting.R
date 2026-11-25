mfrm_gpcm_boundary_guidance <- function(fit) {
    fit <- mfrm_gmfrm_refresh_boundary(fit)
    if ((!mfrm_has_product_slopes(fit) && is.null(fit$point_limit)) || !identical(fit$config$gpcm_point_estimation$overview$Status, 
        "finite_maximum_absent")) 
        return(NULL)
    skipped <- identical(fit$opt$value_basis, "neutral_boundary_reference")
    limit <- fit$point_limit$overview
    partial <- identical(limit$Status, "partial_points_available") && inherits(fit$point_limit$fit, "mfrm_fit")
    issue <- paste("The full model has no finite maximum.", if (skipped) 
        "Full-model optimization was deliberately not run; its stored values are neutral references."
    else "Full-model optimizer values are traces, regardless of numerical convergence.")
    limit_issue <- if (partial) {
        "Only targets marked finite_likelihood_limit have estimated limiting values; unidentified targets and fixed steps retain their separate status."
    }
    else if (identical(limit$Status, "numerical_unresolved")) {
        "The separate limiting refit failed its numerical checks; limiting estimates remain unavailable."
    }
    else "Limiting estimates were not evaluated for this reduction; this does not establish that every target is unidentified."
    actions <- c("Read summary(fit)$point_estimation, fit$config$gpcm_point_estimation$boundary and summary(fit)$point_targets / step_targets for the boundary and target-specific status.", 
        if (partial) paste("Use mfrm_curve_intervals(fit$point_limit$fit, newdata) only for retained rating contexts, without intervals.", 
            "Keep the limiting fit's location reference and data basis explicit.") else "Inspect fit$point_limit$overview and any fit$point_limit$failure for the reduction's restriction or numerical failure; no qualified limiting curves are supplied.", 
        "Full-model and ordinary limiting-fit intervals are unavailable. Increasing full-model iterations or changing starting values cannot restore a finite maximum.")
    list(skipped = skipped, partial = partial, issue = issue, limit_issue = limit_issue, actions = actions, 
        limit_status = limit$Status %||% "not_evaluated")
}

mfrm_gpcm_boundary_summary <- function(out, fit) {
    boundary <- mfrm_gpcm_boundary_guidance(fit)
    if (is.null(boundary)) 
        return(out)
    out$next_actions <- boundary$actions
    out$decision$Interpretation <- if (boundary$partial) 
        "Use only the recorded limiting estimates"
    else "No finite full-model estimate; limiting estimates unavailable"
    out$decision$FormalInference <- "No"
    out$decision$Why <- paste(boundary$issue, boundary$limit_issue, "Full-model formal inference remains unavailable.")
    out$decision$NextAction <- boundary$actions[1L]
    out
}

mfrm_gpcm_product_point_tables <- function(fit) {
    fit <- mfrm_gmfrm_refresh_boundary(fit)
    point <- fit$config$gpcm_point_estimation
    overview <- point$overview %||% data.frame(Status = "legacy_not_reviewed", PrimaryAvailable = FALSE, 
        IntegrationReview = "not_recorded", LocalMaximumReview = "not_recorded", BoundaryReview = "not_recorded", 
        Detail = "This saved fit predates the point-estimate review. Its numerical values are retained without upgrading their status.")
    tables <- list(fitted_slopes = data.frame(Facet = fit$slopes[["SlopeOwner"]] %||% rep(fit$config$slope_facet, 
        nrow(fit$slopes)), Level = fit$slopes$SlopeFacet, FittedSlope = fit$slopes$OptimizerEstimate, 
        Interval = "See attached slope-interval tables, if requested"), fitted_locations = data.frame(Facet = fit$facets$others$Facet, 
        Level = fit$facets$others$Level, FittedLocation = fit$facets$others$Estimate, Constraint = ifelse(fit$facets$others$Facet != 
            fit$config$noncenter_facet, "Sum to zero across levels", "Uncentered; fixed N(0,1) ability"), 
        Interval = "See attached location-interval tables, if requested"), fitted_steps = data.frame(StepOwner = fit$config$step_facet, 
        StepLevel = fit$steps$StepFacet, Step = fit$steps$Step, FittedStep = fit$steps$Estimate, Interval = "See attached step-interval tables, if requested"))
    for (name in names(tables)) tables[[name]]$PointEstimateStatus <- overview$Status
    if (identical(overview$Status, "finite_maximum_absent")) 
        for (name in names(tables)) {
            tables[[name]]$Interval <- "Unavailable: no finite full-model maximum"
            tables[[name]]$ValueBasis <- "optimizer_trace"
        }
    if (identical(fit$opt$value_basis, "neutral_boundary_reference")) 
        for (name in names(tables)) tables[[name]]$ValueBasis <- "neutral_boundary_reference"
    tables$fitted_slopes$PrimaryEstimate <- fit$slopes$PrimaryEstimate
    tables$fitted_slopes$ParameterStatus <- fit$slopes$ParameterStatus
    tables$point_estimation <- overview
    support <- mfrm_facet_rating_support(fit)
    if (!is.null(fit$point_limit$fit)) {
        reduced_support <- mfrm_facet_rating_support(fit$point_limit$fit)
        for (name in c("table", "crossings", "categories")) support[[name]] <- dplyr::bind_rows(support[[name]], 
            reduced_support[[name]])
        support$notes <- unique(c(support$notes, reduced_support$notes))
    }
    tables$rating_support <- support$table
    tables$rating_crossings <- support$crossings
    tables$rating_categories <- support$categories
    tables$rating_support_notes <- data.frame(Note = support$notes)
    if (!is.null(fit$point_limit)) {
        tables$point_limit <- fit$point_limit$overview
        tables$point_targets <- fit$point_limit$targets
        if (!is.null(fit$point_limit$step_targets)) 
            tables$step_targets <- fit$point_limit$step_targets
        if (!is.null(fit$point_limit$category_map)) 
            tables$category_map <- fit$point_limit$category_map
        reduced <- fit$point_limit$fit
        if (!is.null(reduced)) {
            basis <- if (identical(fit$point_limit$overview$Reduction, "global_endpoint")) 
                "reduced_category_convention"
            else "limiting_likelihood"
            tables$limit_locations <- data.frame(reduced$facets$others[c("Facet", "Level", "Estimate")], 
                NoncenterFacet = reduced$config$noncenter_facet, Basis = basis)
            tables$limit_steps <- data.frame(reduced$steps[c("StepFacet", "Step", "Estimate")], Basis = basis)
            if (isTRUE(reduced$population$active)) 
                tables$limit_population <- data.frame(Mean = unname(reduced$population$coefficients[1]), 
                  SD = sqrt(reduced$population$sigma2), Basis = basis)
        }
    }
    if (nrow(point$boundary %||% data.frame())) 
        tables$point_boundary <- point$boundary
    tables
}
