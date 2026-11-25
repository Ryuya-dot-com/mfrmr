mfrmr_jml_gpcm_slope_empty_group_table <- .mfrmr_empty_table(c(SlopeFacet = "character", Level = "character", 
    SlopeIndex = "integer", LogSlopeEstimate = "double", SlopeEstimate = "double", EffectiveObservations = "integer", 
    EffectiveWeight = "double", MaxCompatible = "logical", MinCompatible = "logical", MaxSupportMargin = "double", 
    MinSupportMargin = "double", StrictMaxRows = "integer", StrictMinRows = "integer", CurrentLogLikelihood = "double", 
    HighBoundaryLogLikelihood = "double", LowBoundaryLogLikelihood = "double"))

mfrmr_jml_gpcm_slope_empty_target_table <- .mfrmr_empty_table(c(ParameterId = "character", ParameterClass = "character", 
    Facet = "character", Level = "character", OptimizerLogEstimate = "double", OptimizerSlopeEstimate = "double", 
    PositiveBoundaryPath = "logical", NegativeBoundaryPath = "logical", CandidateStatus = "character", 
    EvaluationState = "character", ReasonCodes = "character"))

mfrmr_jml_gpcm_slope_empty_pair_table <- .mfrmr_empty_table(c(PairId = "character", PositiveLevel = "character", 
    NegativeLevel = "character", PositiveIndex = "integer", NegativeIndex = "integer", MaxSupportMargin = "double", 
    MinSupportMargin = "double", StrictRows = "integer", DirectionSum = "double", CurrentLogLikelihood = "double", 
    BoundaryLogLikelihood = "double", BoundaryImprovement = "double", Certified = "logical"))

mfrmr_jml_gpcm_slope_empty_loading_table <- .mfrmr_empty_table(c(PairId = "character", CoordinateType = "character", 
    OptimizerIndex = "integer", Coordinate = "character", Level = "character", Loading = "double"))

mfrmr_jml_gpcm_slope_targets <- function(levels, slope_facet, log_slopes, slopes, positive = NULL, negative = NULL, 
    evaluation_state = "not_evaluated", reason = "not_evaluated") {
    levels <- as.character(levels)
    n_levels <- length(levels)
    if (n_levels == 0L) 
        return(mfrmr_jml_gpcm_slope_empty_target_table)
    positive <- as.logical(positive %||% rep(NA, n_levels))
    negative <- as.logical(negative %||% rep(NA, n_levels))
    candidate <- rep("not_evaluated", n_levels)
    evaluated <- !is.na(positive) & !is.na(negative)
    candidate[evaluated & positive & negative] <- "boundary_path_both"
    candidate[evaluated & positive & !negative] <- "boundary_path_high"
    candidate[evaluated & !positive & negative] <- "boundary_path_low"
    candidate[evaluated & !positive & !negative] <- "none_certified_in_slope_only_paths"
    data.frame(ParameterId = paste0("Slope:", slope_facet, ":", levels), ParameterClass = rep("log_slope", 
        n_levels), Facet = rep(as.character(slope_facet), n_levels), Level = levels, OptimizerLogEstimate = as.numeric(log_slopes), 
        OptimizerSlopeEstimate = as.numeric(slopes), PositiveBoundaryPath = positive, NegativeBoundaryPath = negative, 
        CandidateStatus = candidate, EvaluationState = rep(evaluation_state, n_levels), ReasonCodes = rep(reason, 
            n_levels), stringsAsFactors = FALSE)
}

mfrmr_gpcm_slope_direction_loadings <- function(certified_rows, certificates, levels, n_levels, sizes, 
    empty_loadings) {
    loading_rows <- list()
    loading_cursor <- 0L
    slices <- build_param_slices(sizes)
    optimizer_indices <- as.integer(slices[["log_slopes"]] %||% integer(0))
    for (certificate_index in certified_rows) {
        certificate <- certificates[certificate_index, , drop = FALSE]
        expanded_direction <- rep(0, n_levels)
        expanded_direction[certificate$PositiveIndex] <- 1
        expanded_direction[certificate$NegativeIndex] <- -1
        expanded_keep <- which(expanded_direction != 0)
        loading_cursor <- loading_cursor + 1L
        loading_rows[[loading_cursor]] <- data.frame(PairId = certificate$PairId, CoordinateType = "expanded_log_slope", 
            OptimizerIndex = rep(NA_integer_, length(expanded_keep)), Coordinate = paste0("expanded_log_slope:", 
                levels[expanded_keep]), Level = levels[expanded_keep], Loading = expanded_direction[expanded_keep], 
            stringsAsFactors = FALSE)
        free_direction <- expanded_direction[seq_len(n_levels - 1L)]
        free_keep <- which(free_direction != 0)
        if (length(free_keep) > 0L) {
            loading_cursor <- loading_cursor + 1L
            loading_rows[[loading_cursor]] <- data.frame(PairId = certificate$PairId, CoordinateType = "optimizer_log_slope", 
                OptimizerIndex = optimizer_indices[free_keep], Coordinate = paste0("log_slopes:", levels[free_keep]), 
                Level = levels[free_keep], Loading = free_direction[free_keep], stringsAsFactors = FALSE)
        }
    }
    if (length(loading_rows) == 0L) {
        empty_loadings
    }
    else {
        do.call(rbind, loading_rows)
    }
}

audit_mfrm_jml_gpcm_slope_boundary <- function(prep, idx, config, sizes, par, max_observations = 50000L, 
    max_utility_elements = 2e+06, max_slope_levels = 100L, max_direction_pairs = 10000L, support_tolerance = sqrt(.Machine$double.eps), 
    likelihood_tolerance = 1e-08) {
    method <- as.character(config$method %||% NA_character_)
    model <- as.character(config$model %||% NA_character_)
    slope_facet <- as.character(config$slope_facet %||% NA_character_)
    empty_groups <- mfrmr_jml_gpcm_slope_empty_group_table
    empty_targets <- mfrmr_jml_gpcm_slope_empty_target_table
    empty_pairs <- mfrmr_jml_gpcm_slope_empty_pair_table
    empty_loadings <- mfrmr_jml_gpcm_slope_empty_loading_table
    finish <- function(state, complete, scope_complete, detail, target_status = empty_targets, group_support = empty_groups, 
        certificates = empty_pairs, direction_loadings = empty_loadings, dimensions = data.frame(), retained_log_likelihood = NA_real_, 
        optimizer_log_likelihood = NA_real_, likelihood_difference = NA_real_) {
        list(contract_version = mfrmr_readiness_contract_version(), method = method, model = model, scope = paste("JML GPCM constant log-slope rays with retained additive", 
            "coordinates fixed"), state = state, complete = isTRUE(complete), scope_complete = isTRUE(scope_complete), 
            structural_identification_complete = FALSE, target_status = target_status, group_support = group_support, 
            certificates = certificates, direction_loadings = direction_loadings, dimensions = dimensions, 
            retained_log_likelihood = as.numeric(retained_log_likelihood), optimizer_log_likelihood = as.numeric(optimizer_log_likelihood), 
            likelihood_difference = as.numeric(likelihood_difference), detail = detail, limitations = paste("The certificate holds the retained Person, facet, interaction, and", 
                "step coordinates fixed and evaluates constant sum-zero log-slope", "rays only. A none-certified result does not establish finite GPCM", 
                "slopes, a global finite maximum, or nonlinear structural", "identification because additive coordinates may move jointly.", 
                "Certified directions can type parameter-level boundary values, but", "they do not license standard errors, confidence intervals, a finite", 
                "joint-GPCM claim, or ordinary external numerical comparisons."))
    }
    if (!identical(model, "GPCM")) {
        return(finish("not_applicable_model", TRUE, FALSE, "The log-slope boundary-path audit applies only to GPCM."))
    }
    if (!identical(method, "JML")) {
        return(finish("not_applicable_mml", TRUE, FALSE, paste("MML integrates Person coordinates; this conditional retained-Person", 
            "JML path is not reinterpreted as a marginal-likelihood certificate.")))
    }
    levels <- as.character(config$gpcm_spec$levels %||% character(0))
    n_levels <- length(levels)
    n_obs <- length(idx$score_k %||% integer(0))
    n_categories <- as.integer(config$n_cat %||% 0L)
    n_pairs <- as.double(n_levels) * as.double(max(n_levels - 1L, 0L))
    utility_elements <- as.double(n_obs) * as.double(n_categories)
    dimensions <- data.frame(Observations = as.integer(n_obs), EffectiveObservations = NA_integer_, Categories = as.integer(n_categories), 
        SlopeLevels = as.integer(n_levels), FreeLogSlopes = max(as.integer(n_levels - 1L), 0L), OrderedDirectionPairs = as.double(n_pairs), 
        UtilityElements = as.double(utility_elements), CertifiedPairs = NA_integer_, stringsAsFactors = FALSE)
    control_values <- list(max_observations = max_observations, max_utility_elements = max_utility_elements, 
        max_slope_levels = max_slope_levels, max_direction_pairs = max_direction_pairs, support_tolerance = support_tolerance, 
        likelihood_tolerance = likelihood_tolerance)
    valid_controls <- all(vapply(control_values, function(value) {
        length(value) == 1L && !is.na(value) && is.finite(value) && value >= 0
    }, logical(1)))
    if (!valid_controls) {
        return(finish("not_evaluated_control", FALSE, FALSE, "Slope-path execution limits and tolerances must be finite nonnegative scalars.", 
            dimensions = dimensions))
    }
    free_dimension <- sum(vapply(sizes, as.integer, integer(1)))
    params <- tryCatch({
        if (is.null(par) || length(par) != free_dimension || any(!is.finite(par))) {
            stop("The retained optimizer vector is unavailable or malformed.")
        }
        expand_params(par, sizes, config)
    }, error = function(e) e)
    if (inherits(params, "error") || length(params$slopes) != n_levels || length(params$log_slopes) != 
        n_levels || any(!is.finite(params$slopes)) || any(params$slopes <= 0)) {
        return(finish("not_evaluated_mapping", FALSE, FALSE, if (inherits(params, "error")) {
            paste0("GPCM slope expansion failed: ", conditionMessage(params))
        } else {
            "Expanded GPCM slope coordinates did not match the declared levels."
        }, dimensions = dimensions))
    }
    targets_not_evaluated <- mfrmr_jml_gpcm_slope_targets(levels, slope_facet, params$log_slopes, params$slopes)
    if (n_levels <= 1L || as.integer(sizes[["log_slopes"]] %||% 0L) == 0L) {
        targets <- mfrmr_jml_gpcm_slope_targets(levels, slope_facet, params$log_slopes, params$slopes, 
            positive = rep(FALSE, n_levels), negative = rep(FALSE, n_levels), evaluation_state = "evaluated", 
            reason = "no_free_log_slope_coordinate")
        if (nrow(targets) > 0L) 
            targets$CandidateStatus <- "fixed_unit_slope"
        dimensions$EffectiveObservations <- as.integer(n_obs)
        dimensions$CertifiedPairs <- 0L
        return(finish("no_free_log_slope_coordinates", TRUE, TRUE, "The GPCM reduction has no free relative log-slope coordinate.", 
            target_status = targets, dimensions = dimensions))
    }
    if (n_obs > as.double(max_observations) || utility_elements > as.double(max_utility_elements) || 
        n_levels > as.double(max_slope_levels) || n_pairs > as.double(max_direction_pairs)) {
        targets_not_evaluated$CandidateStatus <- "not_evaluated_size_limit"
        targets_not_evaluated$ReasonCodes <- "bounded_slope_path_size_limit"
        return(finish("not_evaluated_size_limit", FALSE, FALSE, paste0("The slope-path audit exceeded its execution limit (", 
            n_obs, " observations; ", n_categories, " categories; ", n_levels, " slope levels; ", format(n_pairs, 
                scientific = FALSE), " ordered direction pairs; ", format(utility_elements, scientific = FALSE), 
            " utility elements)."), target_status = targets_not_evaluated, dimensions = dimensions))
    }
    score_k <- suppressWarnings(as.integer(idx$score_k))
    slope_index <- suppressWarnings(as.integer(idx$slope_idx))
    weight <- as.numeric(idx$weight %||% rep(1, n_obs))
    valid_observation_map <- length(score_k) == n_obs && length(slope_index) == n_obs && length(weight) == 
        n_obs && !anyNA(score_k) && !anyNA(slope_index) && !anyNA(weight) && all(score_k >= 0L & score_k < 
        n_categories) && all(slope_index >= 1L & slope_index <= n_levels) && all(is.finite(weight)) && 
        all(weight >= 0)
    if (!valid_observation_map || n_obs < 1L || n_categories < 2L) {
        return(finish("not_evaluated_design", FALSE, FALSE, "The retained score, slope-index, weight, or category map was malformed.", 
            target_status = targets_not_evaluated, dimensions = dimensions))
    }
    effective <- weight > 0
    dimensions$EffectiveObservations <- sum(effective)
    if (!any(effective)) {
        return(finish("not_evaluated_no_positive_weight", FALSE, FALSE, "No retained observation had positive likelihood weight.", 
            target_status = targets_not_evaluated, dimensions = dimensions))
    }
    built <- tryCatch(mfrmr_gpcm_response_kernel_design(prep, idx, config, sizes, par), error = function(e) e)
    if (inherits(built, "error") || built$observation_rows != n_obs || built$transitions != n_categories - 
        1L) {
        return(finish("not_evaluated_design", FALSE, FALSE, if (inherits(built, "error")) {
            paste0("GPCM retained utility construction failed: ", conditionMessage(built))
        } else {
            "GPCM retained utility dimensions did not match the response map."
        }, target_status = targets_not_evaluated, dimensions = dimensions))
    }
    adjacent_base <- matrix(as.numeric(built$eta_minus_step), nrow = n_obs, ncol = n_categories - 1L)
    utilities <- matrix(0, nrow = n_obs, ncol = n_categories)
    for (category in seq_len(n_categories - 1L)) {
        utilities[, category + 1L] <- utilities[, category] + adjacent_base[, category]
    }
    slope_observation <- as.numeric(params$slopes[slope_index])
    scaled_utilities <- utilities * matrix(slope_observation, nrow = n_obs, ncol = n_categories)
    if (any(!is.finite(utilities)) || any(!is.finite(scaled_utilities))) {
        return(finish("not_evaluated_numerical", FALSE, FALSE, "Retained GPCM category utilities were non-finite.", 
            target_status = targets_not_evaluated, dimensions = dimensions))
    }
    row_max_scaled <- apply(scaled_utilities, 1L, max)
    log_denominator <- row_max_scaled + log(rowSums(exp(scaled_utilities - matrix(row_max_scaled, nrow = n_obs, 
        ncol = n_categories))))
    observed_scaled <- scaled_utilities[cbind(seq_len(n_obs), score_k + 1L)]
    row_log_likelihood <- weight * (observed_scaled - log_denominator)
    retained_log_likelihood <- sum(row_log_likelihood)
    optimizer_log_likelihood <- tryCatch(-mfrm_loglik_jml(par, idx, config, sizes), error = function(e) NA_real_)
    likelihood_difference <- retained_log_likelihood - optimizer_log_likelihood
    likelihood_scale <- max(1, abs(retained_log_likelihood), abs(optimizer_log_likelihood))
    if (!is.finite(retained_log_likelihood) || !is.finite(optimizer_log_likelihood) || !is.finite(likelihood_difference) || 
        abs(likelihood_difference) > likelihood_tolerance * likelihood_scale) {
        return(finish("not_evaluated_likelihood_mismatch", FALSE, FALSE, paste("The independently reconstructed retained-utility likelihood did not", 
            "match the optimizer objective within tolerance."), target_status = targets_not_evaluated, 
            dimensions = dimensions, retained_log_likelihood = retained_log_likelihood, optimizer_log_likelihood = optimizer_log_likelihood, 
            likelihood_difference = likelihood_difference))
    }
    row_max_utility <- apply(utilities, 1L, max)
    row_min_utility <- apply(utilities, 1L, min)
    observed_utility <- utilities[cbind(seq_len(n_obs), score_k + 1L)]
    max_margin <- observed_utility - row_max_utility
    min_margin <- row_min_utility - observed_utility
    utility_span <- row_max_utility - row_min_utility
    max_compatible_row <- max_margin == 0
    min_compatible_row <- min_margin == 0
    max_ties <- rowSums(utilities == matrix(row_max_utility, nrow = n_obs, ncol = n_categories))
    high_boundary_row <- ifelse(max_compatible_row, -log(max_ties), -Inf)
    low_boundary_row <- rep(-log(n_categories), n_obs)
    group_rows <- lapply(seq_len(n_levels), function(group) {
        rows <- which(effective & slope_index == group)
        has_rows <- length(rows) > 0L
        max_compatible <- has_rows && all(max_compatible_row[rows])
        min_compatible <- has_rows && all(min_compatible_row[rows])
        data.frame(SlopeFacet = slope_facet, Level = levels[group], SlopeIndex = as.integer(group), LogSlopeEstimate = as.numeric(params$log_slopes[group]), 
            SlopeEstimate = as.numeric(params$slopes[group]), EffectiveObservations = as.integer(length(rows)), 
            EffectiveWeight = if (has_rows) 
                sum(weight[rows])
            else 0, MaxCompatible = max_compatible, MinCompatible = min_compatible, MaxSupportMargin = if (has_rows) 
                min(max_margin[rows])
            else NA_real_, MinSupportMargin = if (has_rows) 
                min(min_margin[rows])
            else NA_real_, StrictMaxRows = if (max_compatible) {
                as.integer(sum(utility_span[rows] > support_tolerance))
            }
            else {
                0L
            }, StrictMinRows = if (min_compatible) {
                as.integer(sum(utility_span[rows] > support_tolerance))
            }
            else {
                0L
            }, CurrentLogLikelihood = if (has_rows) {
                sum(row_log_likelihood[rows])
            }
            else {
                0
            }, HighBoundaryLogLikelihood = if (has_rows) {
                sum(weight[rows] * high_boundary_row[rows])
            }
            else {
                NA_real_
            }, LowBoundaryLogLikelihood = if (has_rows) {
                sum(weight[rows] * low_boundary_row[rows])
            }
            else {
                NA_real_
            }, stringsAsFactors = FALSE)
    })
    group_support <- do.call(rbind, group_rows)
    pair_grid <- expand.grid(PositiveIndex = seq_len(n_levels), NegativeIndex = seq_len(n_levels), KEEP.OUT.ATTRS = FALSE, 
        stringsAsFactors = FALSE)
    pair_grid <- pair_grid[pair_grid$PositiveIndex != pair_grid$NegativeIndex, , drop = FALSE]
    rownames(pair_grid) <- NULL
    pair_rows <- lapply(seq_len(nrow(pair_grid)), function(pair_index) {
        positive_index <- pair_grid$PositiveIndex[pair_index]
        negative_index <- pair_grid$NegativeIndex[pair_index]
        positive_group <- group_support[positive_index, , drop = FALSE]
        negative_group <- group_support[negative_index, , drop = FALSE]
        strict_rows <- positive_group$StrictMaxRows + negative_group$StrictMinRows
        boundary_log_likelihood <- retained_log_likelihood - positive_group$CurrentLogLikelihood - negative_group$CurrentLogLikelihood + 
            positive_group$HighBoundaryLogLikelihood + negative_group$LowBoundaryLogLikelihood
        improvement <- boundary_log_likelihood - retained_log_likelihood
        certified <- isTRUE(positive_group$MaxCompatible) && isTRUE(negative_group$MinCompatible) && 
            strict_rows > 0L && is.finite(boundary_log_likelihood) && is.finite(improvement) && improvement >= 
            -likelihood_tolerance * likelihood_scale
        data.frame(PairId = sprintf("SP%05d", pair_index), PositiveLevel = levels[positive_index], NegativeLevel = levels[negative_index], 
            PositiveIndex = as.integer(positive_index), NegativeIndex = as.integer(negative_index), MaxSupportMargin = positive_group$MaxSupportMargin, 
            MinSupportMargin = negative_group$MinSupportMargin, StrictRows = as.integer(strict_rows), 
            DirectionSum = 0, CurrentLogLikelihood = retained_log_likelihood, BoundaryLogLikelihood = boundary_log_likelihood, 
            BoundaryImprovement = improvement, Certified = isTRUE(certified), stringsAsFactors = FALSE)
    })
    certificates <- if (length(pair_rows) == 0L) {
        empty_pairs
    }
    else {
        do.call(rbind, pair_rows)
    }
    certified_rows <- which(certificates$Certified)
    dimensions$CertifiedPairs <- as.integer(length(certified_rows))
    positive <- seq_len(n_levels) %in% certificates$PositiveIndex[certified_rows]
    negative <- seq_len(n_levels) %in% certificates$NegativeIndex[certified_rows]
    targets <- mfrmr_jml_gpcm_slope_targets(levels, slope_facet, params$log_slopes, params$slopes, positive = positive, 
        negative = negative, evaluation_state = "evaluated", reason = "no_monotone_pair_certified_at_retained_additive_point")
    targets$ReasonCodes[positive | negative] <- "certified_monotone_slope_only_boundary_path"
    targets$ReasonCodes[group_support$EffectiveObservations == 0L] <- "no_positive_weight_observations"
    direction_loadings <- mfrmr_gpcm_slope_direction_loadings(certified_rows = certified_rows, certificates = certificates, 
        levels = levels, n_levels = n_levels, sizes = sizes, empty_loadings = empty_loadings)
    any_certified <- length(certified_rows) > 0L
    finish(state = if (any_certified) {
        "certified_monotone_boundary_path"
    }
    else {
        "none_certified"
    }, complete = TRUE, scope_complete = TRUE, detail = if (any_certified) {
        paste0("Certified ", length(certified_rows), " of ", nrow(certificates), " ordered slope-level pairs as nondecreasing constant sum-zero", 
            " log-slope boundary paths at the retained additive coordinates.")
    }
    else {
        paste0("No monotone constant sum-zero log-slope boundary path was certified", " among ", nrow(certificates), 
            " ordered slope-level pairs at the retained additive coordinates.")
    }, target_status = targets, group_support = group_support, certificates = certificates, direction_loadings = direction_loadings, 
        dimensions = dimensions, retained_log_likelihood = retained_log_likelihood, optimizer_log_likelihood = optimizer_log_likelihood, 
        likelihood_difference = likelihood_difference)
}
