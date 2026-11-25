mfrm_facet_intervals <- function(fit, facet = NULL, contrasts = NULL, method = c("model", "sandwich", 
    "profile"), clusters = NULL, adjust = FALSE, level = 0.95, scale = c("native", "standardized"), comparison_review = NULL, 
    anchor_covariance = NULL, independent_anchors = FALSE, interaction = NULL, profile_control = list()) {
    if (identical(match.arg(method), "profile")) {
        if (!is.numeric(level) || is.complex(level) || is.object(level) || !is.null(dim(level)) || length(level) != 
            1L || !is.finite(level) || level <= 0 || level >= 1) 
            stop("Supply 0 < level < 1.", call. = FALSE)
        if (!is.null(clusters) || !identical(adjust, FALSE) || match.arg(scale) != "native" || !is.null(comparison_review) || 
            !is.null(anchor_covariance) || !identical(independent_anchors, FALSE) || !is.null(interaction)) 
            stop("Profile intervals accept a native-scale pairwise facet contrast; covariance, cluster, anchor and interaction options are unavailable.", 
                call. = FALSE)
        out <- mfrm_native_profile_intervals(fit, facet, contrasts, unname(level), profile_control)
        out$table <- summary(out)
        return(out)
    }
    if (length(profile_control)) 
        stop("profile_control applies only to method = 'profile'.", call. = FALSE)
    joint <- !is.null(interaction)
    if (joint && (!inherits(fit, "mfrm_fit") || inherits(fit, "mfrm_comparison_fit") || !fit$config$model %in% 
        c("RSM", "PCM") || !identical(fit$config$method, "MML"))) 
        stop("Joint cell intervals require a full native RSM/PCM MML fit.", call. = FALSE)
    if (joint && (!is.null(facet) || !is.null(comparison_review) || match.arg(method) != "model" || match.arg(scale) != 
        "native" || !is.null(anchor_covariance) || !identical(independent_anchors, FALSE))) 
        stop("Use interaction with method = 'model', scale = 'native', and omit facet, comparison_review and anchor-source arguments.", 
            call. = FALSE)
    anchor_request <- mfrmr_anchor_uncertainty_request(fit, anchor_covariance, independent_anchors)
    if (!is.null(anchor_request) && (match.arg(method) != "model" || !is.null(comparison_review))) 
        stop("Anchor-source intervals require method = 'model' without comparison_review.", call. = FALSE)
    if (inherits(fit, "mfrm_comparison_fit") && identical(fit$config$method, "CML")) 
        return(mfrmr_cml_comparison_intervals(fit, facet, contrasts, match.arg(method), clusters, adjust, 
            level, match.arg(scale), comparison_review))
    comparison <- !is.null(comparison_review)
    if (comparison && (!inherits(fit, "mfrm_fit") || !identical(fit$config$method, "MML") || !fit$config$model %in% 
        c("RSM", "PCM"))) 
        stop("Interaction intervals require a full native RSM/PCM MML fit; CML estimates no population SD and comparison-only MML fits have no interval route here.", 
            call. = FALSE)
    if (inherits(fit, "mfrm_cml_fit")) 
        return(mfrmr_cml_facet_intervals(fit, facet, contrasts, match.arg(method), clusters, adjust, 
            level, match.arg(scale)))
    stop_if_jml_adjustment(fit, "mfrm_facet_intervals()")
    joint_main <- !joint && !comparison && length(fit$config$interaction_specs) > 0L
    if (joint_main && (!inherits(fit, "mfrm_fit") || inherits(fit, "mfrm_comparison_fit") || !fit$config$model %in% 
        c("RSM", "PCM") || !identical(fit$config$method, "MML"))) 
        stop("Joint main-effect intervals require a full native RSM/PCM MML fit.", call. = FALSE)
    if (joint_main && (match.arg(method) != "model" || match.arg(scale) != "native" || !is.null(anchor_covariance) || 
        !identical(independent_anchors, FALSE))) 
        stop("Joint main-effect intervals require method = 'model', scale = 'native', and no anchor-source arguments.", 
            call. = FALSE)
    if (joint_main && length(fit$config$interaction_specs) != 1L) 
        stop("Joint main-effect intervals require one fitted two-facet interaction.", call. = FALSE)
    product <- mfrm_has_product_slopes(fit)
    native <- !product && (joint || joint_main || comparison || isTRUE(fit$config$population_spec$active) || 
        identical(fit$config$model, "GPCM"))
    method <- match.arg(method)
    singleton <- !product && !native && identical(method, "model") && inherits(fit, "mfrm_fit") && identical(fit$config$method, 
        "MML") && fit$config$model %in% c("RSM", "PCM") && !mfrm_inference_ready(fit) && (identical(as.character(mfrmr_get_readiness_record(fit)$fit$CategoryState[1]), 
        "weak_information") || length(mfrmr_mml_additive_boundary_evidence(fit$config)) > 0L)
    standardized <- match.arg(scale) == "standardized"
    if (standardized && (method != "model" || (!comparison && is.null(contrasts)))) 
        stop("Standardized intervals require explicit zero-sum contrasts and method = 'model'.", call. = FALSE)
    population_active <- isTRUE(fit$config$population_spec$active)
    population_estimated <- population_active && is.null(fit$config$population_spec$fixed_sd)
    if (standardized && population_active && !identical(fit$config$population_spec$design_columns, "(Intercept)")) 
        stop("Standardized contrasts require an intercept-only normal population; regression residual SD is not marginal population SD.", 
            call. = FALSE)
    if (!product && !native && (!inherits(fit, "mfrm_fit") || !identical(fit$config$method, "MML") || 
        !fit$config$model %in% c("RSM", "PCM") || isTRUE(fit$config$population_spec$active) || mfrmr_adaptive_integration(fit$config) || 
        any(!is.finite(fit$prep$data$Weight)) || any(fit$prep$data$Weight != 1) || (!mfrm_inference_ready(fit) && 
        !singleton))) {
        reason <- if (inherits(fit, "mfrm_fit") && !mfrm_inference_ready(fit)) 
            mfrm_fit_decision_summary(mfrmr_get_readiness_record(fit)$fit)$Why[1L]
        stop("Use an inference-ready RSM/PCM MML fit with unit weights, fixed quadrature and a fixed standard-normal person distribution.", 
            if (length(reason)) 
                paste0(" ", reason), call. = FALSE)
    }
    if (!is.logical(adjust) || length(adjust) != 1L || is.na(adjust) || !is.numeric(level) || is.complex(level) || 
        is.object(level) || !is.null(dim(level)) || length(level) != 1L || !is.finite(level) || level <= 
        0 || level >= 1) {
        stop("Supply a logical `adjust` and 0 < level < 1.", call. = FALSE)
    }
    level <- unname(level)
    if (method == "model" && (!is.null(clusters) || adjust)) {
        stop("`clusters` and `adjust` apply only to method = 'sandwich'.", call. = FALSE)
    }
    if (product && (method != "model" || !inherits(fit, "mfrm_fit") || inherits(fit, "mfrm_imported_fit") || 
        !identical(fit$config$method, "MML"))) {
        stop("Two-family location intervals require native MML and method = 'model'; sandwich intervals are unavailable.", 
            call. = FALSE)
    }
    if (native && method != "model") {
        stop("Native population/one-family GPCM location intervals require method = 'model'; sandwich intervals are unavailable.", 
            call. = FALSE)
    }
    source_interaction <- if (joint_main) 
        names(fit$config$interaction_specs)[1L]
    else interaction
    params <- if (native) 
        mfrm_native_location_source(fit, comparison_review, source_interaction)
    else NULL
    sizes <- build_param_sizes(fit$config)
    if (!native) 
        params <- expand_params(fit$opt$par, sizes, fit$config)
    if (joint) {
        facet <- interaction
        target <- mfrm_joint_interaction_targets(fit, interaction, contrasts)
        estimate <- drop(target$jacobian %*% fit$opt$par)
    }
    else if (comparison) {
        review <- mfrmr_match_comparison_model(fit$prep, fit$config, comparison_review)
        s <- review$specification
        if (!is.null(contrasts) || (!is.null(facet) && !identical(facet, s$facet))) 
            stop("Use the comparison review's contrast weights and facet; omit contrasts and any different facet.", 
                call. = FALSE)
        facet <- paste(s$facet, s$group, sep = ":")
        jacobian <- matrix(0, nrow(review$weights), length(fit$opt$par))
        jacobian[, review$parameter_map$OptimizerIndex] <- review$target_map
        target <- list(contrasts = review$weights, jacobian = jacobian, fixed = rowSums(abs(jacobian)) == 
            0, constant = rep(0, nrow(jacobian)))
        estimate <- drop(jacobian %*% fit$opt$par)
    }
    else {
        target <- mfrm_facet_contrasts(fit, facet, contrasts)
        estimate <- drop(target$contrasts %*% params$facets[[facet]])
        estimate[target$fixed] <- target$constant[target$fixed]
    }
    if (any(!is.finite(estimate))) 
        stop("Contrast estimates must be finite; rescale excessively large coefficients.", call. = FALSE)
    slice <- if (comparison || joint) 
        seq_along(fit$opt$par)
    else build_param_slices(sizes)[[facet]]
    if (standardized) {
        unit_rows <- target$contrasts/apply(abs(target$contrasts), 1L, max)
        if (any(abs(rowSums(unit_rows)) > 64 * .Machine$double.eps * rowSums(abs(unit_rows)))) 
            stop("Standardized contrasts must have zero-sum coefficient rows.", call. = FALSE)
        population_sd <- if (population_active) 
            sqrt(params$population$sigma2)
        else 1
        if (!is.finite(population_sd) || population_sd <= 0) 
            stop("Standardized contrasts require a finite positive population SD.", call. = FALSE)
        native_estimate <- estimate
        estimate <- estimate/population_sd
        target_jacobian <- matrix(0, nrow(target$contrasts), length(fit$opt$par), dimnames = list(rownames(target$contrasts), 
            mfrm_checkpoint_parameter_names(sizes)))
        target_jacobian[, slice] <- target$jacobian/population_sd
        if (population_estimated) 
            target_jacobian[, build_param_slices(sizes)[["log_sigma2"]]] <- -estimate/2
        if (any(!is.finite(estimate)) || any(!is.finite(target_jacobian))) 
            stop("Standardized estimates and derivatives must be finite; rescale excessively large coefficients.", 
                call. = FALSE)
        target$fixed <- rowSums(abs(target_jacobian)) == 0
    }
    information_reason <- NULL
    if (method == "sandwich") 
        clusters <- mfrm_sandwich_clusters(fit$prep$levels$Person, clusters)
    if (product) {
        expected <- build_other_facet_table(fit$config, fit$prep, params)
        keys <- c("Facet", "Level", "Estimate")
        if (!isTRUE(all.equal(fit$facets$others[keys], expected[keys], tolerance = 1e-10, check.attributes = FALSE))) 
            stop("Saved locations must match the fitted two-family parameters.", call. = FALSE)
        inference <- mfrm_gpcm_product_inference(fit)
        information <- inference$information
        model_cov <- inference$covariance
        if (is.null(model_cov)) 
            model_cov <- matrix(NA_real_, length(fit$opt$par), length(fit$opt$par))
    }
    else if (native || singleton) {
        inference <- mfrm_native_location_inference(fit)
        information <- inference$information
        model_cov <- inference$covariance
    }
    else {
        information <- compute_mml_parameter_covariance(fit)
        model_cov <- information$cov
        if (!identical(information$status, "ok") || isTRUE(information$regularized) || !is.matrix(model_cov) || 
            !is.numeric(model_cov) || is.complex(model_cov) || !identical(dim(model_cov), rep(length(fit$opt$par), 
            2L)) || any(!is.finite(model_cov)) || is.null(tryCatch(chol(model_cov), error = function(e) NULL))) {
            information_reason <- paste("Unregularized positive-definite joint covariance is unavailable.", 
                paste(information$detail, collapse = " "), "Point estimates are retained; model and sandwich uncertainty are withheld. Information failure can also limit confidence in point accuracy along weak directions.")
            model_cov <- NULL
        }
    }
    cov <- model_cov
    person_scores <- cluster_scores <- NULL
    nclusters <- rank <- NA_integer_
    factor <- 1
    if (method == "sandwich" && is.null(information_reason)) {
        person_scores <- mfrm_person_likelihood_scores(fit)
        sandwich <- mfrm_cluster_sandwich(model_cov, person_scores, clusters, adjust)
        clusters <- sandwich$clusters
        cluster_scores <- sandwich$cluster_scores
        nclusters <- nrow(cluster_scores)
        rank <- sandwich$rank
        factor <- sandwich$factor
        cov <- sandwich$covariance
    }
    else if (method == "sandwich") {
        nclusters <- length(unique(clusters$Cluster))
        factor <- if (adjust) 
            nclusters/(nclusters - 1)
        else 1
    }
    transform <- function(v) {
        z <- if (is.null(v)) 
            matrix(NA_real_, nrow(target$contrasts), nrow(target$contrasts), dimnames = rep(list(rownames(target$contrasts)), 
                2L))
        else if (standardized) 
            symmetrize_matrix(target_jacobian %*% v %*% t(target_jacobian))
        else symmetrize_matrix(target$jacobian %*% v[slice, slice, drop = FALSE] %*% t(target$jacobian))
        z[target$fixed, ] <- 0
        z[, target$fixed] <- 0
        z
    }
    selected_cov <- transform(cov)
    model_target_cov <- transform(model_cov)
    se <- covariance_diag_se(selected_cov)
    model_se <- covariance_diag_se(model_target_cov)
    status <- rep("available", length(estimate))
    if ((product || native || singleton) && !isTRUE(inference$check$eligible)) 
        status[] <- "numerical_review_failed"
    if (method == "sandwich" && !is.na(rank) && rank < ncol(cluster_scores)) 
        status[] <- "insufficient_cluster_rank"
    status[status != "numerical_review_failed" & (!is.finite(se) | se <= 0)] <- "nonpositive_variance"
    if (!is.null(information_reason)) 
        status[] <- "information_unavailable"
    status[target$fixed] <- "fixed"
    se[!status %in% c("available", "fixed")] <- NA_real_
    critical <- stats::qnorm((1 - level)/2, lower.tail = FALSE)
    margin <- critical * se
    margin[target$fixed] <- NA_real_
    model_margin <- critical * model_se
    model_margin[target$fixed] <- NA_real_
    tab <- data.frame(Target = rownames(target$contrasts), Estimate = estimate, SE = se, Lower = estimate - 
        margin, Upper = estimate + margin, ModelSE = model_se, ModelLower = estimate - model_margin, 
        ModelUpper = estimate + model_margin, Status = status, row.names = NULL)
    tab$CIEligible <- status == "available"
    tab$InferenceReview <- "Pointwise normal approximation under the selected covariance method; numerical availability does not guarantee coverage."
    tab$InferenceReview[status == "fixed"] <- "Constraint-fixed target; SE is zero by construction and no inferential interval is supplied."
    tab$InferenceReview[status == "insufficient_cluster_rank"] <- paste0("Independent cluster scores do not span all free parameters (rank ", 
        rank, " of ", length(fit$opt$par), "). Sandwich intervals are withheld; the point and separate model intervals remain. Review independent sampling units and model dimension; do not split dependent clusters.")
    tab$InferenceReview[status == "nonpositive_variance"] <- "The target variance is nonpositive or nonfinite; the point remains but the selected interval is unavailable. Inspect the covariance and contrast scaling."
    if (!is.null(information_reason)) 
        tab$InferenceReview[status == "information_unavailable"] <- information_reason
    if (native || product || standardized || singleton) {
        invalid <- status == "available" & (!is.finite(tab$Lower) | !is.finite(tab$Upper))
        status[invalid] <- "nonfinite_bounds"
        tab$Status <- status
        tab[!status %in% c("available", "fixed"), c("SE", "Lower", "Upper", "ModelSE", "ModelLower", 
            "ModelUpper")] <- NA_real_
    }
    out <- list(table = tab, covariance = selected_cov, model_covariance = model_target_cov, parameter_covariance = cov, 
        model_parameter_covariance = model_cov, person_scores = person_scores, cluster_scores = cluster_scores, 
        clusters = clusters, contrasts = target$contrasts, settings = list(facet = facet, method = method, 
            level = level, adjust = adjust, adjustment_factor = factor, persons = fit$prep$n_person, 
            clusters = nclusters, cluster_score_rank = rank, free_parameters = length(fit$opt$par), reference = "pointwise normal", 
            quad_points = fit$config$estimation_control$quad_points), fit = fit)
    class(out) <- "mfrm_facet_intervals"
    out$cautions <- unique(c(mfrm_mml_information_caution(information), mfrm_single_person_caution(fit$prep)))
    if (fit$prep$n_person == 1L) 
        out$table$CoverageQualified <- FALSE
    out$information_review <- information$solution_information$inverse_review
    if (!is.null(information_reason)) {
        out$unavailable_reason <- information_reason
        out$checks <- data.frame(Check = "Joint information", Passed = FALSE, Detail = information_reason)
        out$cautions <- unique(c(out$cautions, information_reason))
    }
    if (singleton) {
        out$checks <- inference$checks
        out$numerical_checks <- inference$numerical_checks
        out$comparison_information_review <- inference$comparison_information_review
        out$table$CoverageQualified <- FALSE
        out$table$InferenceReview[status == "available"] <- "Pointwise model-information normal approximation; singleton categories retained after joint-information and finer-quadrature checks. Small-sample coverage is not guaranteed."
        out$table$InferenceReview[status == "numerical_review_failed"] <- inference$check$review
        out$cautions <- unique(c(out$cautions, inference$check$caution))
    }
    if (product) {
        out$source <- mfrm_gpcm_inference_source(fit)
        out$settings$two_family <- TRUE
        out$settings$scale <- "fixed_standard_normal"
        out$settings$location_reference <- if (facet != fit$config$noncenter_facet) 
            "sum_to_zero_across_levels"
        else "uncentered_on_fixed_N01"
        out$settings$integration <- if (mfrmr_adaptive_integration(fit$config)) 
            "adaptive"
        else "fixed"
        out$checks <- inference$checks
        out$numerical_checks <- inference$numerical_checks
        out$score_rank <- inference$score_rank
        out$table$CIEligible <- status == "available"
        out$table$CoverageQualified <- FALSE
        out$table$ScaleReference <- out$settings$location_reference
        out$table$InferenceReview <- inference$check$review
        out$table$InferenceReview[status == "fixed"] <- "Constraint-fixed native target; no inferential interval."
        out$table$InferenceReview[status %in% c("nonpositive_variance", "nonfinite_bounds")] <- "The target requires finite positive variance and finite normal bounds."
        out$cautions <- unique(c(out$cautions, inference$check$caution, "Experimental two-family location intervals: sampling coverage is not qualified. Location differences do not imply uniform differences in expected ratings when slopes or category steps differ."))
    }
    if (native) {
        out$settings$procedure <- "mml_native_location_model_v1"
        out$settings$scale <- "native_ability"
        out$settings$location_reference <- if (isTRUE(fit$config$population_spec$active) && identical(facet, 
            fit$config$noncenter_facet)) 
            "direct_anchor_origin"
        else "sum_to_zero_across_levels"
        out$settings$integration <- if (mfrmr_adaptive_integration(fit$config)) 
            "adaptive"
        else "fixed"
        out$settings$comparison_quad_points <- 2 * out$settings$quad_points - 1
        out$settings$population <- if (!isTRUE(fit$config$population_spec$active)) 
            "fixed_standard_normal"
        else if (identical(fit$config$population_spec$design_columns, "(Intercept)")) 
            "estimated_intercept_normal"
        else "conditional_normal_regression"
        out$settings$slope_owner <- fit$config$slope_facet %||% NA_character_
        out$settings$step_owner <- fit$config$step_facet %||% "shared"
        out$source <- mfrm_native_location_identity(fit)
        out$checks <- inference$checks
        out$numerical_checks <- inference$numerical_checks
        out$comparison_information_review <- inference$comparison_information_review
        out$target_jacobian <- matrix(0, nrow(target$contrasts), length(fit$opt$par), dimnames = list(rownames(target$contrasts), 
            mfrm_checkpoint_parameter_names(sizes)))
        out$target_jacobian[, slice] <- target$jacobian
        out$population <- if (out$settings$population == "conditional_normal_regression") 
            data.frame(Term = fit$config$population_spec$design_columns, Coefficient = unname(params$population$coefficients), 
                ResidualVariance = params$population$sigma2)
        else data.frame(Mean = if (is.null(params$population)) 
            0
        else unname(params$population$coefficients), Variance = params$population$sigma2 %||% 1)
        out$table$CIEligible <- status == "available"
        out$table$ScaleReference <- if (out$settings$location_reference == "direct_anchor_origin") 
            "native ability units; supplied anchor origin"
        else "native ability units; centered facet locations"
        out$table$InferenceReview <- inference$check$review
        out$table$InferenceReview[status == "fixed"] <- "Constraint-fixed native target; no inferential interval."
        out$table$InferenceReview[status %in% c("nonpositive_variance", "nonfinite_bounds")] <- "The target requires finite positive variance and finite normal bounds."
        out$cautions <- unique(c(out$cautions, inference$check$caution, mfrm_gpcm_anchor_note(fit), if (!is.null(fit$config$population_spec$fixed_sd)) "Intervals condition on the supplied population SD; its uncertainty is not propagated.", 
            if (!standardized) "Native location intervals: pointwise Wald inference assumes a correctly specified, identified regular MML model; numerical eligibility does not guarantee finite-sample coverage. Native ability units are not standardized by the fitted population SD; unequal slopes or steps can make expected-rating differences vary with ability."))
    }
    if (standardized) {
        out$settings$scale <- "standardized_population_sd"
        out$settings$transformation <- "population_sd_delta_v1"
        out$settings$population_sd <- population_sd
        out$settings$population_sd_estimated <- population_estimated
        out$settings$location_reference <- "zero_sum_contrast_in_population_sd_units"
        out$target_jacobian <- target_jacobian
        out$table$NativeEstimate <- native_estimate
        out$table$CIEligible <- status == "available"
        out$table$CoverageQualified <- FALSE
        out$table$ScaleReference <- "within-facet zero-sum contrast / population SD"
        if (is.null(out$table$InferenceReview)) 
            out$table$InferenceReview <- ""
        out$table$InferenceReview[status == "available"] <- "Population-SD-standardized pointwise delta-method interval; source numerical checks passed, sampling coverage is unqualified."
        out$table$InferenceReview[status == "fixed"] <- "Constraint-fixed standardized target; no inferential interval."
        out$table$InferenceReview[status %in% c("nonpositive_variance", "nonfinite_bounds")] <- "The standardized target requires finite positive variance and finite normal bounds."
        out$cautions <- unique(c(out$cautions, "Population-SD-standardized contrasts use full joint delta-method uncertainty; sampling coverage is not qualified. Regular inference requires a correctly specified, identified marginal model and a true population SD strictly above zero. A positive fitted SD alone does not establish these conditions; near-zero SD can make the ratio unstable. Quadrature agreement is a numerical diagnostic, not an error bound. Unequal slopes or steps can make expected-rating differences vary with ability."))
    }
    if (comparison) {
        out$settings$procedure <- "mml_interaction_comparison_model_v1"
        out$settings$target <- "facet_by_origin_interaction_contrast"
        out$settings$location_reference <- if (standardized) 
            "interaction_contrast_in_population_sd_units"
        else "interaction_contrast_in_native_ability_units"
        out$comparison_review <- review
        out$table$Group1 <- s$groups[1L]
        out$table$Group2 <- s$groups[2L]
        out$table$ConditionalState <- review$table$ConditionalState
        out$table$MarginalIdentificationState <- review$table$State
        out$table$IdentificationBasis <- review$table$IdentificationBasis
        out$table$IdentificationDetail <- review$table$IdentificationDetail
        out$table$CoverageQualified <- FALSE
        out$table$ScaleReference <- if (standardized) 
            "facet-by-origin interaction contrast / population SD"
        else "facet-by-origin interaction contrast in native ability units"
        out$cautions <- unique(c(out$cautions, "Interaction contrasts use the declared group direction and panel weights. Positive conditional rank and local information do not prove global marginal identification; intervals are model-based asymptotic approximations, not calibrated DFF classifications."))
    }
    if (joint) {
        out$settings$procedure <- "mml_joint_interaction_model_v1"
        out$settings$target <- if (is.null(contrasts)) 
            "joint_interaction_cells"
        else "joint_interaction_contrasts"
        out$settings$location_reference <- "two_way_sum_to_zero_margins"
        out$interaction_cells <- target$cells
        out$table$CoverageQualified <- FALSE
        out$table$ScaleReference <- if (population_active) 
            "additive predictor shift; native ability units"
        else "additive predictor shift; fixed N(0,1) ability units"
        if (is.null(contrasts)) 
            out$table <- cbind(out$table, target$cells[setdiff(names(target$cells), c("Target", "Estimate"))])
        out$cautions <- unique(c(out$cautions, "Jointly fitted interaction effects use zero row and column sums across the declared facet levels. Positive values increase the score predictor relative to the jointly fitted main effects. These are not fixed-baseline estimate_bias() screens or proof of rater unfairness. Intervals are pointwise, not simultaneous; no multiplicity-adjusted decision is supplied. Sparse or missing cells require design and numerical review; finite estimates do not establish coverage."))
    }
    if (joint_main) {
        out$settings$target <- "joint_main_effects"
        out$settings$interaction <- source_interaction
        if (!population_active && identical(facet, fit$config$noncenter_facet)) {
            out$settings$location_reference <- "uncentered_on_fixed_N01"
            out$table$ScaleReference <- "native ability units; uncentered facet on fixed N(0,1)"
        }
        out$table$CoverageQualified <- FALSE
        out$cautions <- unique(c(out$cautions, "Main-effect intervals use full joint covariance, including interaction effects and any estimated population parameters. For an interacting facet, zero-sum interaction margins make main-effect differences equal-weight averages over the other declared facet levels, not cell-count-weighted or criterion-specific differences. They are not differences in average ratings; numerical eligibility does not guarantee coverage."))
    }
    out <- mfrmr_anchor_uncertainty_intervals(out, anchor_request)
    out$table <- summary(out)
    if (length(out$cautions)) {
        out$table$InferenceCaution <- paste(out$cautions, collapse = " ")
        warning(paste(out$cautions, collapse = " "), call. = FALSE)
    }
    out
}

mfrm_facet_contrasts <- function(fit, facet, contrasts) {
    if (!is.character(facet) || length(facet) != 1L || is.na(facet) || !facet %in% fit$config$facet_names) {
        stop("`facet` must name a non-person model facet.", call. = FALSE)
    }
    spec <- fit$config$facet_specs[[facet]]
    labels <- as.character(spec$levels)
    if (is.null(contrasts)) {
        contrasts <- diag(length(labels))
        dimnames(contrasts) <- list(labels, labels)
    }
    if (!is.matrix(contrasts) || !is.numeric(contrasts) || is.complex(contrasts) || !nrow(contrasts) || 
        ncol(contrasts) != length(labels) || any(!is.finite(contrasts)) || is.null(colnames(contrasts)) || 
        anyDuplicated(colnames(contrasts)) || !setequal(colnames(contrasts), labels) || is.null(rownames(contrasts)) || 
        anyNA(rownames(contrasts)) || any(!nzchar(rownames(contrasts))) || anyDuplicated(rownames(contrasts)) || 
        any(rowSums(abs(contrasts)) == 0)) {
        stop("`contrasts` must have distinct target row names, all facet-level column names, and finite nonzero coefficient rows.", 
            call. = FALSE)
    }
    contrasts <- contrasts[, labels, drop = FALSE]
    jac <- contrasts %*% constraint_jacobian(spec)
    list(labels = labels, contrasts = contrasts, jacobian = jac, fixed = if (ncol(jac)) rowSums(abs(jac)) == 
        0 else rep(TRUE, nrow(jac)), constant = drop(contrasts %*% expand_facet_with_constraints(numeric(spec$n_params), 
        spec)))
}

mfrm_person_likelihood_scores <- function(fit) {
    config <- fit$config
    sizes <- build_param_sizes(config)
    params <- expand_params(fit$opt$par, sizes, config)
    idx <- build_indices(fit$prep, step_facet = config$step_facet, interaction_specs = config$interaction_specs)
    quad <- gauss_hermite_normal(config$estimation_control$quad_points)
    bundle <- mfrm_mml_logprob_bundle(idx, config, quad, params, compute_base_eta(idx, params, config), 
        include_probs = TRUE)
    posterior <- mfrm_mml_posterior_bundle(bundle)
    expected <- mfrm_mml_expected_category_bundle(bundle, posterior, include_p_geq = TRUE)
    residual <- idx$score_k - expected$expected_k
    step_residual <- expected$p_geq - outer(idx$score_k, seq_len(config$n_cat - 1L), ">=")
    rows <- split(seq_along(idx$person), factor(idx$person, levels = seq_len(config$n_person)))
    scores <- t(vapply(rows, function(at) {
        facet_scores <- unlist(lapply(config$facet_names, function(facet) {
            expanded <- numeric(length(params$facets[[facet]]))
            sums <- rowsum(matrix(residual[at], ncol = 1), idx$facets[[facet]][at], reorder = FALSE)
            expanded[as.integer(rownames(sums))] <- sums[, 1] * config$facet_signs[[facet]]
            constraint_grad_project(expanded, config$facet_specs[[facet]])
        }))
        sub_idx <- list(interactions = lapply(idx$interactions, `[`, at))
        interaction_scores <- compute_interaction_gradient_free(residual[at], sub_idx, config)
        if (config$model == "RSM") {
            step_scores <- colSums(step_residual[at, , drop = FALSE])
        }
        else {
            step_scores <- matrix(0, nrow(params$steps_mat), ncol(params$steps_mat))
            sums <- rowsum(step_residual[at, , drop = FALSE], idx$step_idx[at], reorder = FALSE)
            step_scores[as.integer(rownames(sums)), ] <- sums
        }
        c(facet_scores, interaction_scores, project_typed_step_gradient(step_scores, config))
    }, numeric(length(fit$opt$par))))
    dimnames(scores) <- list(fit$prep$levels$Person, mfrm_checkpoint_parameter_names(sizes))
    aggregate_gradient <- mfrm_grad_mml(fit$opt$par, idx, config, sizes, quad)
    if (any(!is.finite(scores)) || max(abs(colSums(scores) + aggregate_gradient)) > 1e-08 * max(1, max(colSums(abs(scores))))) {
        stop("Person likelihood scores do not reproduce the fitted objective gradient.", call. = FALSE)
    }
    scores
}

print.mfrm_facet_intervals <- function(x, ...) {
    cat(x$settings$facet, if (identical(x$settings$target, "category_step_offsets")) 
        "step-offset intervals:"
    else "intervals:", if (identical(x$settings$method, "profile")) 
        "profile likelihood\n"
    else paste(x$settings$method, "covariance\n"))
    if (x$settings$method == "sandwich") 
        cat(x$settings$clusters, "declared independent clusters;", x$settings$persons, "persons\n")
    tab <- summary(x)
    print(tab[setdiff(names(tab), "InferenceCaution")], row.names = FALSE)
    for (caution in x$cautions) print_wrapped_line(paste0("Caution: ", caution))
    cat(if (identical(x$settings$method, "profile")) 
        "Connected profile interval; reoptimized center and source estimate are reported separately.\n"
    else "Pointwise normal intervals; changing covariance does not correct biased estimates.\n")
    invisible(x)
}

summary.mfrm_facet_intervals <- function(object, ...) {
    tab <- object$table
    if (identical(object$fit$config$method, "MML") && !inherits(object$fit, "mfrm_comparison_fit")) {
        source <- mfrmr_get_readiness_record(object$fit)$fit
        tab$SourceFitReadiness <- source$FitReadiness
        tab$SourceEstimabilityState <- source$EstimabilityState
        if (is.null(tab$CoverageQualified)) 
            tab$CoverageQualified <- FALSE
    }
    tab
}

confint.mfrm_facet_intervals <- function(object, parm = NULL, level = object$settings$level, ...) {
    rlang::check_dots_empty()
    if (!is.numeric(level) || length(level) != 1L || !is.finite(level) || level != object$settings$level) 
        stop(if (identical(object$settings$target, "category_step_offsets")) 
            "`level` must match the saved level; use confint(fit, parm = 'steps', level = ...) to recalculate."
        else "`level` must match the saved level; use `mfrm_facet_intervals()` to recalculate.", call. = FALSE)
    labels <- object$table$Target
    if (is.null(parm)) 
        parm <- labels
    if (!is.character(parm) || anyNA(parm) || anyDuplicated(parm) || !all(parm %in% labels)) 
        stop("`parm` must contain distinct saved Target names.", call. = FALSE)
    out <- as.matrix(object$table[match(parm, labels), c("Lower", "Upper"), drop = FALSE])
    rownames(out) <- parm
    out
}

vcov.mfrm_facet_intervals <- function(object, ...) object$covariance
