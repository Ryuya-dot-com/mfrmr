functioning_label_for_facet <- function(facet) {
    facet_lower <- tolower(as.character(facet)[1])
    if (facet_lower %in% c("rater", "raters")) {
        return("DRF")
    }
    if (facet_lower %in% c("prompt", "prompts", "task", "tasks")) {
        return("DPF")
    }
    if (facet_lower %in% c("item", "items", "criterion", "criteria")) {
        return("DIF")
    }
    "DFF"
}

welch_satterthwaite_df <- function(components, dfs) {
    components <- suppressWarnings(as.numeric(components))
    dfs <- suppressWarnings(as.numeric(dfs))
    if (!length(components) || length(components) != length(dfs)) 
        return(NA_real_)
    ok <- is.finite(components) & components > 0 & is.finite(dfs) & dfs > 0
    if (!all(ok)) {
        return(NA_real_)
    }
    components <- components/max(components)
    num <- sum(components)^2
    den <- sum(components^2/dfs)
    if (!is.finite(den) || den <= 0) {
        return(NA_real_)
    }
    num/den
}

resolve_dff_subgroup_precision <- function(sub_fit, sub_diag = NULL, diagnostics_error = NULL) {
    precision_profile <- as.data.frame(sub_diag$precision_profile %||% data.frame(), stringsAsFactors = FALSE)
    method <- resolve_public_mfrm_method(summary_method = sub_fit$summary$Method[1] %||% NA_character_, 
        method_input = sub_fit$config$method_input %||% NA_character_, method_used = sub_fit$config$method %||% 
            NA_character_)
    converged <- if (nrow(precision_profile) > 0 && "InferenceReady" %in% names(precision_profile)) {
        isTRUE(precision_profile$InferenceReady[1])
    }
    else {
        mfrm_inference_ready(sub_fit)
    }
    precision_tier <- if (!is.null(diagnostics_error) && nzchar(diagnostics_error)) {
        "diagnostics_unavailable"
    }
    else if (nrow(precision_profile) > 0 && "PrecisionTier" %in% names(precision_profile)) {
        as.character(precision_profile$PrecisionTier[1] %||% NA_character_)
    }
    else if (identical(method, "MML")) {
        "hybrid"
    }
    else {
        "exploratory"
    }
    supports_formal <- if (nrow(precision_profile) > 0 && "SupportsFormalInference" %in% names(precision_profile)) {
        isTRUE(precision_profile$SupportsFormalInference[1])
    }
    else {
        FALSE
    }
    list(method = method, converged = converged, precision_tier = precision_tier, supports_formal = supports_formal)
}

annotate_dff_table <- function(tbl, method) {
    if (nrow(tbl) == 0) {
        tbl$Interpretation <- character(0)
        tbl$EffectMetric <- character(0)
        tbl$ContrastBasis <- character(0)
        tbl$SEBasis <- character(0)
        tbl$StatisticLabel <- character(0)
        tbl$ProbabilityMetric <- character(0)
        tbl$DFBasis <- character(0)
        tbl$ClassificationSystem <- character(0)
        tbl$Classification <- character(0)
        tbl$ETS <- character(0)
        tbl$ETS_Eligible <- logical(0)
        tbl$ConditionalRefitScreenEligible <- logical(0)
        tbl$FormalInferenceEligible <- logical(0)
        tbl$SupportsFormalInference <- logical(0)
        tbl$ReportingUse <- character(0)
        tbl$PrimaryReportingEligible <- logical(0)
        return(tbl)
    }
    if (identical(method, "refit")) {
        linked <- if ("ContrastComparable" %in% names(tbl)) {
            as.logical(tbl$ContrastComparable)
        }
        else {
            rep(TRUE, nrow(tbl))
        }
        conditional <- if ("ConditionalRefitScreenEligible" %in% names(tbl)) {
            as.logical(tbl$ConditionalRefitScreenEligible)
        }
        else {
            rep(FALSE, nrow(tbl))
        }
        tbl$ContrastBasis <- ifelse(linked, "linked subgroup facet-measure difference", "descriptive subgroup facet-measure difference")
        tbl$SEBasis <- ifelse(conditional, paste0("conditional independent-subgroup plug-in SE; baseline-anchor ", 
            "uncertainty and cross-refit covariance omitted"), ifelse(linked, "not reported without complete conditional-screen inputs", 
            "not reported without common-scale linking"))
        tbl$StatisticLabel <- ifelse(conditional, "conditional plug-in Welch t screen", ifelse(linked, 
            "linked descriptive contrast", "descriptive contrast"))
        tbl$ProbabilityMetric <- ifelse(conditional, "conditional plug-in Welch tail area (screening only)", 
            "not reported")
        tbl$DFBasis <- ifelse(conditional, "Welch-Satterthwaite plug-in approximation; not a validated joint-refit df", 
            "not reported")
        tbl$EffectMetric <- ifelse(linked, "linked_descriptive_logit_difference", "descriptive_refit_difference")
        tbl$ClassificationSystem <- "descriptive"
        tbl$Classification <- dplyr::case_when(linked %in% TRUE & is.finite(tbl$Contrast) ~ "Linked contrast (screening only)", 
            linked %in% FALSE & is.finite(tbl$Contrast) ~ "Unclassified (insufficient linking)", TRUE ~ 
                "Unavailable")
        tbl$ETS <- NA_character_
        tbl$ETS_Eligible <- FALSE
        tbl$FormalInferenceEligible <- FALSE
        tbl$SupportsFormalInference <- FALSE
        tbl$PrimaryReportingEligible <- FALSE
        tbl$ReportingUse <- dplyr::case_when(!is.finite(tbl$Contrast) ~ "unavailable", conditional ~ 
            "screening_only_conditional_plugin", linked %in% TRUE ~ "screening_only_linked_descriptive", 
            TRUE ~ "screening_only")
        if (all(c("Fixed1", "Fixed2") %in% names(tbl))) {
            fixed <- tbl$Fixed1 %in% TRUE | tbl$Fixed2 %in% TRUE
            if (all(c("Estimate1", "Estimate2") %in% names(tbl))) {
                fixed <- fixed & is.finite(tbl$Estimate1) & is.finite(tbl$Estimate2)
            }
            tbl$Classification[fixed] <- "Fixed target; no comparison"
            tbl$ContrastBasis[fixed] <- "Target fixed by constraints in at least one subgroup"
            tbl$SEBasis[fixed] <- "Not applicable to fixed targets"
            tbl$StatisticLabel[fixed] <- "No differential-functioning comparison"
            tbl$EffectMetric[fixed] <- "not_applicable"
            tbl$ReportingUse[fixed] <- "not_applicable_fixed_target"
        }
        return(tbl)
    }
    for (field in c("SE", "t", "df", "p_value", "p_adjusted")) {
        tbl[[field]] <- rep(NA_real_, nrow(tbl))
    }
    tbl$ContrastBasis <- "group difference in mean observed-minus-expected residuals"
    tbl$SEBasis <- "not reported: residual-contrast uncertainty is not established"
    tbl$StatisticLabel <- "residual mean difference"
    tbl$ProbabilityMetric <- "not reported"
    tbl$DFBasis <- "not applicable"
    tbl$EffectMetric <- "mean_obs_minus_exp_difference"
    tbl$ClassificationSystem <- "descriptive"
    tbl$Classification <- ifelse(is.finite(tbl$Contrast), "Residual contrast", "Unavailable")
    tbl$Interpretation <- "Residual differences do not isolate differential functioning; no test or confidence interval is provided."
    tbl$ETS <- NA_character_
    tbl$ETS_Eligible <- FALSE
    tbl$FormalInferenceEligible <- FALSE
    tbl$SupportsFormalInference <- FALSE
    tbl$PrimaryReportingEligible <- FALSE
    tbl$ReportingUse <- "descriptive"
    tbl
}

validate_dff_residual_output <- function(x) {
    cfg <- x$config %||% list()
    residual <- identical(cfg$method, "residual") || "abs_t_warn" %in% names(cfg)
    if (residual && !identical(cfg$residual_output_version, 3L)) {
        stop("This saved result uses earlier residual inference or observation matching. Recompute it with analyze_dff() or dif_interaction_table() using the fitted model; no model refit is needed.", 
            call. = FALSE)
    }
    if (identical(cfg$method, "refit") && !identical(cfg$refit_output_version, 1L)) {
        stop("This saved refit result predates subgroup availability and cell-count checks. Rerun analyze_dff(method = 'refit') from the baseline fit and original data to recompute subgroup estimates; regenerate exported tables and figures.", 
            call. = FALSE)
    }
    invisible(x)
}

build_dff_summary <- function(tbl, method) {
    if (identical(method, "refit")) {
        out <- tibble(Classification = c("Linked contrast (screening only)", "Unclassified (insufficient linking)"), 
            Count = c(sum(tbl$Classification == "Linked contrast (screening only)", na.rm = TRUE), sum(tbl$Classification == 
                "Unclassified (insufficient linking)", na.rm = TRUE)))
        if (any(tbl$Classification == "Fixed target; no comparison", na.rm = TRUE)) {
            out <- dplyr::bind_rows(out, tibble(Classification = "Fixed target; no comparison", Count = sum(tbl$Classification == 
                "Fixed target; no comparison", na.rm = TRUE)))
        }
        if (any(tbl$Classification == "Unavailable", na.rm = TRUE)) {
            out <- dplyr::bind_rows(out, tibble(Classification = "Unavailable", Count = sum(tbl$Classification == 
                "Unavailable", na.rm = TRUE)))
        }
        return(out)
    }
    tibble(Classification = c("Residual contrast", "Unavailable"), Count = c(sum(is.finite(tbl$Contrast)), 
        sum(!is.finite(tbl$Contrast))))
}

resolve_dff_refit_controls <- function(fit) {
    if (!is.null(fit$config$step_constraint_map)) {
        stop("DFF subgroup refits do not support `step_constraints`. Use method = 'residual' for screening.", 
            call. = FALSE)
    }
    replay <- fit$config$replay_inputs %||% list()
    control <- fit$config$estimation_control %||% list()
    if (is.list(replay$mml_starts)) 
        stop("Named starting coordinates cannot be reused after subgroup linking changes the free coordinates. Use numeric `mml_starts` offsets or fit the subgroup models explicitly.", 
            call. = FALSE)
    population_active <- isTRUE(fit$config$population_active) || isTRUE(fit$config$population_spec$active) || 
        !is.null(replay$population_formula)
    auto_gpcm_population <- population_active && identical(as.character(fit$population$source %||% ""), 
        "gpcm_mml_default_identification") && identical(as.character(fit$config$model %||% ""), "GPCM") && 
        identical(as.character(fit$config$method %||% ""), "MML")
    if (population_active && !auto_gpcm_population) {
        stop("`analyze_dff(method = \"refit\")` cannot currently reproduce an active ", "latent-regression population model within subgroup fits without changing ", 
            "the fitted population contract. Use `method = \"residual\"` for screening, ", "or fit and link a prespecified subgroup population model outside ", 
            "`analyze_dff()`.", call. = FALSE)
    }
    interaction_terms <- unique(c(as.character(fit$config$facet_interactions %||% character(0)), names(fit$config$interaction_specs %||% 
        list())))
    interaction_terms <- interaction_terms[!is.na(interaction_terms) & nzchar(interaction_terms)]
    if (length(interaction_terms) > 0L) {
        stop("`analyze_dff(method = \"refit\")` cannot currently reproduce fitted ", "facet interactions and anchor their subgroup interaction coordinates on ", 
            "a common scale. Use `method = \"residual\"` for screening, or refit and ", "link the interaction model explicitly outside `analyze_dff()`.", 
            call. = FALSE)
    }
    anchor_tables <- tryCatch(extract_anchor_tables(fit$config), error = function(e) list(groups = data.frame()))
    group_anchors <- as.data.frame(replay$group_anchors %||% anchor_tables$groups %||% data.frame(), 
        stringsAsFactors = FALSE)
    if (nrow(group_anchors) > 0L) {
        stop("`analyze_dff(method = \"refit\")` cannot currently preserve a baseline ", "group-anchor constraint while constructing its separate subgroup-linking ", 
            "anchors. Use `method = \"residual\"` for screening, or specify and audit ", "the subgroup linking model outside `analyze_dff()`.", 
            call. = FALSE)
    }
    rating_min <- suppressWarnings(as.numeric(fit$config$rating_min %||% fit$prep$rating_min %||% NA_real_)[1])
    rating_max <- suppressWarnings(as.numeric(fit$config$rating_max %||% fit$prep$rating_max %||% NA_real_)[1])
    if (!is.finite(rating_min) || !is.finite(rating_max) || rating_min >= rating_max) {
        stop("`analyze_dff(method = \"refit\")` requires the baseline fit's resolved ", "finite `rating_min` and `rating_max` so subgroup fits cannot redefine the ", 
            "observed score scale. Refit the baseline model with the current mfrmr ", "version or use `method = \"residual\"`.", 
            call. = FALSE)
    }
    list(model = fit$config$model %||% fit$summary$Model[1] %||% "RSM", method = fit$config$method %||% 
        fit$summary$Method[1] %||% "JML", step_facet = fit$config$step_facet %||% NULL, slope_facet = fit$config$slope_facet %||% 
        NULL, gpcm_mml_identification = as.character(replay$gpcm_mml_identification %||% fit$config$gpcm_mml_identification %||% 
        if (identical(as.character(fit$config$model %||% ""), "GPCM") && identical(as.character(fit$config$method %||% 
            ""), "MML") && !population_active) {
            "fixed_standard_normal"
        } else {
            "free_population"
        })[1], rating_min = rating_min, rating_max = rating_max, weight = fit$config$weight_col %||% 
        NULL, keep_original = isTRUE(replay$keep_original %||% fit$config$keep_original), repeated_ratings = replay$repeated_ratings %||% 
        fit$config$repeated_ratings %||% "review", missing_codes = replay$missing_codes %||% NULL, noncenter_facet = fit$config$noncenter_facet %||% 
        "Person", centering_scope = fit$config$centering_scope %||% "remainder", dummy_facets = fit$config$dummy_facets %||% 
        NULL, positive_facets = fit$config$positive_facets %||% NULL, min_obs_per_element = as.numeric(replay$min_obs_per_element %||% 
        30), min_obs_per_category = as.numeric(replay$min_obs_per_category %||% 10), quad_points = as.integer(replay$quad_points %||% 
        control$quad_points %||% 31L), mml_integration = as.character(control$mml_integration %||% "fixed"), 
        mml_starts = replay$mml_starts, maxit = as.integer(replay$maxit %||% control$maxit %||% 400L), 
        reltol = as.numeric(replay$reltol %||% control$reltol %||% 1e-09), optimizer = as.character(replay$optimizer %||% 
            control$optimizer_requested %||% "auto")[1], mml_engine = as.character(replay$mml_engine %||% 
            control$mml_engine_requested %||% "direct")[1], identity_contract = "baseline_response_and_estimation_controls_v1")
}

build_dff_linking_setup <- function(fit, facet, facet_names) {
    linking_facets <- setdiff(as.character(facet_names), as.character(facet))
    anchor_tbl <- if (length(linking_facets) > 0) {
        make_anchor_table(fit, facets = linking_facets, include_person = FALSE, readiness_policy = "review")
    }
    else {
        tibble::tibble(Facet = character(0), Level = character(0), Anchor = numeric(0))
    }
    original <- extract_anchor_tables(fit$config)$anchors
    if (nrow(original) > 0L) {
        retained <- original[!original$Facet %in% linking_facets, c("Facet", "Level", "Anchor"), drop = FALSE]
        anchor_tbl <- dplyr::bind_rows(anchor_tbl, retained)
    }
    anchor_review_obj <- anchor_review(fit, required = FALSE) %||% list()
    min_common_anchors <- anchor_review_obj$thresholds$min_common_anchors %||% 5L
    list(linking_facets = linking_facets, anchor_tbl = tibble::as_tibble(anchor_tbl), min_common_anchors = as.integer(min_common_anchors))
}

summarize_dff_group_linkage <- function(sub_fit, linking_setup) {
    if (length(linking_setup$linking_facets) == 0 || nrow(linking_setup$anchor_tbl) == 0) {
        return(list(status = "unlinked", ets_eligible = FALSE, anchored_levels = 0L, detail = "No non-target linking facets were available for anchored subgroup refits."))
    }
    review <- anchor_review(sub_fit, required = FALSE) %||% list()
    facet_summary <- as.data.frame(review$facet_summary %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(facet_summary) == 0 || !"Facet" %in% names(facet_summary)) {
        return(list(status = "weak_link", ets_eligible = FALSE, anchored_levels = NA_integer_, detail = "Linking anchors were requested, but subgroup anchor coverage could not be reviewed."))
    }
    link_tbl <- facet_summary[facet_summary$Facet %in% linking_setup$linking_facets, , drop = FALSE]
    if (nrow(link_tbl) == 0) {
        return(list(status = "unlinked", ets_eligible = FALSE, anchored_levels = 0L, detail = "None of the requested linking facets were present in the subgroup data."))
    }
    anchored_levels <- if ("AnchoredLevels" %in% names(link_tbl)) {
        suppressWarnings(as.numeric(link_tbl$AnchoredLevels))
    }
    else {
        rep(NA_real_, nrow(link_tbl))
    }
    anchored_levels[!is.finite(anchored_levels)] <- 0
    total_anchored <- sum(anchored_levels, na.rm = TRUE)
    strong_link <- is.finite(total_anchored) && total_anchored >= linking_setup$min_common_anchors
    weak_link <- any(anchored_levels > 0)
    status <- if (strong_link) {
        "linked"
    }
    else if (weak_link) {
        "weak_link"
    }
    else {
        "unlinked"
    }
    detail <- paste0("Linking facets: ", paste0(link_tbl$Facet, "=", anchored_levels, collapse = ", "), 
        " anchored level(s); threshold=", linking_setup$min_common_anchors, ".")
    list(status = status, ets_eligible = identical(status, "linked"), anchored_levels = as.integer(total_anchored), 
        detail = detail)
}

extract_dff_group_estimates <- function(sub_fit, sub_diag, facet, fallback_levels, n_obs, linking_setup, 
    linkage, diagnostics_error = NULL, linking_review_note = NA_character_) {
    precision_meta <- resolve_dff_subgroup_precision(sub_fit, sub_diag = sub_diag, diagnostics_error = diagnostics_error)
    link_detail <- linkage$detail
    if (!is.null(diagnostics_error) && nzchar(diagnostics_error)) {
        diag_note <- paste0("Subgroup diagnostics failed: ", diagnostics_error)
        link_detail <- if (!is.null(link_detail) && nzchar(link_detail)) {
            paste(link_detail, diag_note)
        }
        else {
            diag_note
        }
    }
    if (!is.null(sub_diag) && !is.null(sub_diag$measures)) {
        sub_measures <- tibble::as_tibble(sub_diag$measures)
        sub_est <- select(filter(sub_measures, .data$Facet == facet), "Level", "Estimate", "SE")
    }
    else if (!is.null(sub_fit) && !is.null(sub_fit$facets$others)) {
        sub_others <- tibble::as_tibble(sub_fit$facets$others)
        sub_est <- mutate(select(filter(sub_others, .data$Facet == facet), "Level", "Estimate"), SE = NA_real_)
    }
    else {
        sub_est <- tibble(Level = fallback_levels, Estimate = NA_real_, SE = NA_real_)
    }
    if (nrow(sub_est) == 0) {
        sub_est <- tibble(Level = fallback_levels, Estimate = NA_real_, SE = NA_real_)
    }
    sub_est <- dplyr::left_join(tibble(Level = as.character(fallback_levels)), sub_est, by = "Level")
    used <- sub_fit$prep$data
    counts <- summarise(group_by(used, .data[[facet]]), N = n(), NPersons = n_distinct(.data$Person), 
        .groups = "drop")
    names(counts)[1] <- "Level"
    counts$Level <- as.character(counts$Level)
    sub_est <- dplyr::left_join(sub_est, counts, by = "Level")
    sub_est$N <- dplyr::coalesce(sub_est$N, 0L)
    sub_est$NPersons <- dplyr::coalesce(sub_est$NPersons, 0L)
    absent <- sub_est$N == 0L
    sub_est$Estimate[absent] <- sub_est$SE[absent] <- NA_real_
    sub_est$Facet <- facet
    sub_est <- apply_fixed_measure_precision(sub_est, sub_fit$config)
    sub_est$Facet <- NULL
    sub_est$Fixed[absent] <- FALSE
    mutate(sub_est, N_Subgroup = as.integer(nrow(used)), N_Input = as.integer(n_obs), EstimateStatus = ifelse(is.finite(.data$Estimate), 
        "available", "unavailable"), EstimateReason = ifelse(absent, "Target level absent from retained subgroup responses.", 
        ifelse(is.finite(.data$Estimate), NA_character_, "Subgroup estimate unavailable.")), LinkingFacets = if (length(linking_setup$linking_facets) > 
        0) {
        paste(linking_setup$linking_facets, collapse = ", ")
    }
    else {
        NA_character_
    }, LinkingThreshold = as.integer(linking_setup$min_common_anchors), LinkingStatus = linkage$status, 
        LinkingAnchoredLevels = linkage$anchored_levels, LinkingDetail = link_detail, LinkingReview = linking_review_note, 
        LinkComparable = isTRUE(linkage$ets_eligible), Converged = isTRUE(precision_meta$converged), 
        PrecisionTier = precision_meta$precision_tier, SupportsFormalInference = isTRUE(precision_meta$supports_formal), 
        SubgroupMethod = precision_meta$method, DiagnosticsStatus = if (!is.null(diagnostics_error) && 
            nzchar(diagnostics_error)) 
            "failed"
        else "available", DiagnosticsDetail = if (!is.null(diagnostics_error) && nzchar(diagnostics_error)) 
            diagnostics_error
        else NA_character_, ETS_Eligible = FALSE)
}

analyze_dff <- function(fit, diagnostics = NULL, facet, group, data = NULL, focal = NULL,
    method = c("mml_lrt", "cml_lrt", "raju_welch", "mh", "logistic", "residual", "refit"),
    df_method = c("facets", "classical"), min_obs = 10, p_adjust = "holm",
    threads = 1L, comparison_review = NULL) {
    if (missing(facet) && !missing(diagnostics) && is.character(diagnostics) && length(diagnostics) == 1L) {
        # Allow positional call analyze_dff(fit, "Rater", "Group", ...) without `diagnostics`!
        if (!missing(group) && (is.data.frame(group) || is.null(group))) {
            orig_group <- facet
            facet <- diagnostics
            diagnostics <- NULL
            data <- group
            group <- orig_group
        } else if (missing(group)) {
            stop("Supply both `facet` and `group` column names to `analyze_dff()`.", call. = FALSE)
        }
    }
    method <- match.arg(method)
    if (inherits(fit, "mfrm_fast_fit") || method %in% c("mml_lrt", "cml_lrt", "raju_welch", "mh", "logistic")) {
        cpp_m <- if (method %in% c("residual", "refit")) "raju_welch" else method
        return(.mfrm_analyze_dff_fast(
            fit = fit, facet = facet, group = group, data = data, focal = focal,
            method = cpp_m, df_method = df_method[1L], min_obs = min_obs,
            p_adjust = p_adjust, threads = threads
        ))
    }
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an `mfrm_fit` object.", call. = FALSE)
    }
    if (identical(method, "refit") && missing(diagnostics)) {
        stop("`diagnostics` is required for analyze_dff(method = \"refit\"). ", "Call `diagnose_mfrm(fit)` first and pass the result as the ", 
            "second argument, or use `method = \"residual\"` for the ", "diagnostics-free screening path.", 
            call. = FALSE)
    }
    if (!is.character(facet) || length(facet) != 1) {
        stop("`facet` must be a single character string.", call. = FALSE)
    }
    if (!is.character(group) || length(group) != 1) {
        stop("`group` must be a single character string naming a column in the ", "original data.", call. = FALSE)
    }
    min_obs <- .validate_dff_count_arg(min_obs, "min_obs")
    p_adjust <- .validate_p_adjust_method(p_adjust)
    orig_data <- if (!is.null(data)) 
        data
    else fit$prep$data
    if (is.null(orig_data) || !is.data.frame(orig_data)) {
        stop("No data available. Pass the original data via the `data` argument.", call. = FALSE)
    }
    if (!group %in% names(orig_data)) {
        stop("`group` column '", group, "' not found in the data. ", "Available columns: ", paste(names(orig_data), 
            collapse = ", "), call. = FALSE)
    }
    facet_names <- fit$config$facet_cols
    if (is.null(facet_names)) 
        facet_names <- fit$prep$facet_names
    if (!facet %in% facet_names) {
        stop("`facet` '", facet, "' is not one of the model facets: ", paste(facet_names, collapse = ", "), 
            ".", call. = FALSE)
    }
    group_info <- .sanitize_dff_group_data(orig_data, group, "DFF analysis")
    orig_data <- group_info$data
    group_vals <- group_info$values
    group_levels <- group_info$levels
    if (length(group_levels) < 2) {
        stop("Grouping variable '", group, "' must have at least 2 levels. ", "Found ", length(group_levels), 
            " after removing missing or empty ", "group values.", call. = FALSE)
    }
    focal <- .validate_dff_focal(focal, group_levels)
    comparison_review <- mfrmr_bind_comparison_review(comparison_review, fit, group_info$input_data, 
        facet, group, focal)
    if (method == "residual") {
        out <- .analyze_dif_residual(fit = fit, facet = facet, group = group, data = data, orig_data = group_info$input_data, 
            facet_names = facet_names, group_levels = group_levels, focal = focal, min_obs = min_obs, 
            p_adjust = p_adjust)
    }
    else {
        out <- .analyze_dif_refit(fit = fit, diagnostics = diagnostics, facet = facet, group = group, 
            orig_data = orig_data, facet_names = facet_names, group_vals = group_vals, group_levels = group_levels, 
            focal = focal, min_obs = min_obs, p_adjust = p_adjust)
    }
    if (!is.null(comparison_review)) 
        out$comparison_review <- comparison_review
    out
}

.validate_dff_count_arg <- function(x, arg) {
    if (!is.numeric(x) || length(x) != 1L || is.na(x) || !is.finite(x) || x < 1 || abs(x - round(x)) > 
        sqrt(.Machine$double.eps)) {
        stop("`", arg, "` must be a single positive integer.", call. = FALSE)
    }
    as.integer(round(x))
}

.validate_p_adjust_method <- function(p_adjust) {
    if (length(p_adjust) != 1L || is.na(p_adjust)) {
        stop("`p_adjust` must be one of: ", paste(stats::p.adjust.methods, collapse = ", "), ".", call. = FALSE)
    }
    p_adjust <- as.character(p_adjust)
    if (!p_adjust %in% stats::p.adjust.methods) {
        stop("`p_adjust` must be one of: ", paste(stats::p.adjust.methods, collapse = ", "), ".", call. = FALSE)
    }
    p_adjust
}

.sanitize_dff_group_data <- function(orig_data, group, context) {
    input_data <- orig_data
    group_vals <- trimws(as.character(orig_data[[group]]))
    valid_group <- !is.na(group_vals) & nzchar(group_vals)
    if (!any(valid_group)) {
        stop("`group` column '", group, "' has no non-missing, non-empty values after trimming.", call. = FALSE)
    }
    if (any(!valid_group)) {
        message("Dropped ", sum(!valid_group), " row(s) with missing or empty `", group, "` values before ", 
            context, ".")
        orig_data <- orig_data[valid_group, , drop = FALSE]
        group_vals <- group_vals[valid_group]
    }
    orig_data[[group]] <- group_vals
    list(data = orig_data, input_data = input_data, values = group_vals, levels = sort(unique(group_vals)))
}

.validate_dff_focal <- function(focal, group_levels) {
    if (is.null(focal)) 
        return(NULL)
    if (!is.character(focal) || length(focal) < 1L || anyNA(focal)) {
        stop("`focal` must be a character vector of observed group levels.", call. = FALSE)
    }
    focal <- unique(trimws(focal))
    if (any(!nzchar(focal))) {
        stop("`focal` must be a character vector of observed group levels.", call. = FALSE)
    }
    unknown <- setdiff(focal, group_levels)
    if (length(unknown) > 0L) {
        stop("`focal` contains level(s) not found in `group`: ", paste(unknown, collapse = ", "), ". Observed group levels: ", 
            paste(group_levels, collapse = ", "), ".", call. = FALSE)
    }
    if (length(setdiff(group_levels, focal)) == 0L) {
        stop("`focal` cannot include every observed group level; at least one ", "reference group is required.", 
            call. = FALSE)
    }
    focal
}

.analyze_dif_residual <- function(fit, facet, group, data, orig_data, facet_names, group_levels, focal, 
    min_obs, p_adjust) {
    matched <- .dff_match_observations(fit, orig_data, group, normalized = is.null(data))
    obs_work <- matched$data
    cell_table <- mutate(summarise(group_by(obs_work, .data[[facet]], .data$.group_var), N = n(), NPersons = n_distinct(.data$Person), 
        ObsScore = sum(.data$Observed, na.rm = TRUE), ExpScore = sum(.data$Expected, na.rm = TRUE), ObsExpAvg = mean(.data$Observed - 
            .data$Expected, na.rm = TRUE), Var_sum = sum(.data$Var, na.rm = TRUE), .groups = "drop"), 
        sparse = .data$N < min_obs, StdResidual = ifelse(.data$sparse | .data$Var_sum <= 0, NA_real_, 
            (.data$ObsScore - .data$ExpScore)/sqrt(.data$Var_sum)), t = NA_real_, df = NA_real_, p_value = NA_real_, 
        FormalInferenceEligible = FALSE, ReportingUse = "descriptive", Interpretation = "Observed-minus-expected scores; scaled residuals are descriptive and are not t statistics.")
    names(cell_table)[names(cell_table) == facet] <- "Level"
    names(cell_table)[names(cell_table) == ".group_var"] <- "GroupValue"
    method_label <- resolve_public_mfrm_method(summary_method = fit$summary$Method[1] %||% NA_character_, 
        method_input = fit$config$method_input %||% NA_character_, method_used = fit$config$method %||% 
            NA_character_)
    if (!is.null(focal)) {
        pairs <- expand_grid(Group1 = setdiff(group_levels, focal), Group2 = focal)
    }
    else {
        pairs <- as_tibble(as.data.frame(t(combn(group_levels, 2)), stringsAsFactors = FALSE))
        names(pairs) <- c("Group1", "Group2")
    }
    facet_levels <- unique(cell_table$Level)
    dif_rows <- list()
    for (i in seq_len(nrow(pairs))) {
        g1 <- pairs$Group1[i]
        g2 <- pairs$Group2[i]
        for (lev in facet_levels) {
            c1 <- filter(cell_table, .data$Level == lev, .data$GroupValue == g1)
            c2 <- filter(cell_table, .data$Level == lev, .data$GroupValue == g2)
            n1 <- if (nrow(c1) > 0) 
                c1$N[1]
            else 0L
            n2 <- if (nrow(c2) > 0) 
                c2$N[1]
            else 0L
            is_sparse <- (n1 < min_obs) || (n2 < min_obs)
            avg1 <- if (nrow(c1) > 0 && !is_sparse) 
                c1$ObsExpAvg[1]
            else NA_real_
            avg2 <- if (nrow(c2) > 0 && !is_sparse) 
                c2$ObsExpAvg[1]
            else NA_real_
            contrast <- if (is.finite(avg1) && is.finite(avg2)) 
                avg1 - avg2
            else NA_real_
            abs_diff <- abs(contrast)
            direction <- if (!is.finite(contrast)) 
                NA_character_
            else if (contrast > 0) {
                "higher_residual_in_group1"
            }
            else if (contrast < 0) 
                "lower_residual_in_group1"
            else "equal_residuals"
            dif_rows[[length(dif_rows) + 1]] <- tibble(Level = lev, Group1 = g1, Group2 = g2, Contrast = contrast, 
                ContrastDirection = direction, SE = NA_real_, t = NA_real_, df = NA_real_, p_value = NA_real_, 
                AbsDiff = abs_diff, Method = "residual", N_Group1 = as.integer(n1), N_Group2 = as.integer(n2), 
                NPersons_Group1 = if (nrow(c1)) 
                  c1$NPersons[1]
                else 0L, NPersons_Group2 = if (nrow(c2)) 
                  c2$NPersons[1]
                else 0L, sparse = is_sparse, ContrastComparable = FALSE, FormalInferenceEligible = FALSE, 
                PrimaryReportingEligible = FALSE, InferenceTier = "descriptive", ComparisonMethod = method_label, 
                ScaleLinkStatus = "not_applicable", ReportingUse = "descriptive")
        }
    }
    dif_table <- bind_rows(dif_rows)
    dif_table <- annotate_dff_table(dif_table, method = "residual")
    dif_summary <- build_dff_summary(dif_table, method = "residual")
    functioning_label <- functioning_label_for_facet(facet)
    out <- list(dif_table = dif_table, cell_table = cell_table, cases = matched$cases, summary = dif_summary, 
        group_fits = NULL, gpcm_boundary = gpcm_capability_boundary_table(fit, helper = "analyze_dff()", 
            area = "Differential facet functioning screening under GPCM"), config = list(facet = facet, 
            group = group, method = "residual", residual_output_version = 3L, min_obs = min_obs, p_adjust = p_adjust, 
            focal = focal, group_levels = group_levels, functioning_label = functioning_label))
    class(out) <- c("mfrm_dff", "mfrm_dif", class(out))
    out
}

.analyze_dif_refit <- function(fit, diagnostics, facet, group, orig_data, facet_names, group_vals, group_levels, 
    focal, min_obs, p_adjust) {
    mfrm_results_validate_diagnostics_identity(fit, diagnostics, helper = "analyze_dff(method = 'refit')")
    measures <- tibble::as_tibble(diagnostics$measures)
    facet_estimates <- select(filter(measures, .data$Facet == facet), "Facet", "Level", "Estimate", "SE")
    facet_estimates <- apply_fixed_measure_precision(facet_estimates, fit$config)
    facet_estimates$Facet <- NULL
    person_col <- fit$config$person_col %||% "Person"
    score_col <- fit$config$score_col %||% "Score"
    refit_controls <- resolve_dff_refit_controls(fit)
    linking_setup <- build_dff_linking_setup(fit, facet = facet, facet_names = facet_names)
    baseline_precision_meta <- resolve_dff_subgroup_precision(fit, diagnostics)
    group_fits <- list()
    group_persons <- list()
    for (g in group_levels) {
        idx <- group_vals == g
        sub_data <- orig_data[idx, , drop = FALSE]
        if (nrow(sub_data) < 5) {
            group_fits[[g]] <- mutate(facet_estimates, Estimate = NA_real_, SE = NA_real_, Fixed = FALSE, 
                N = NA_integer_, NPersons = NA_integer_, N_Subgroup = NA_integer_, N_Input = as.integer(nrow(sub_data)), 
                EstimateStatus = "unavailable", EstimateReason = "Subgroup had fewer than 5 input observations; refit was skipped.", 
                LinkingFacets = if (length(linking_setup$linking_facets) > 0) {
                  paste(linking_setup$linking_facets, collapse = ", ")
                }
                else {
                  NA_character_
                }, LinkingThreshold = as.integer(linking_setup$min_common_anchors), LinkingStatus = "insufficient_data", 
                LinkingAnchoredLevels = 0L, LinkingDetail = "Subgroup had fewer than 5 observations; anchored refit was skipped.", 
                LinkComparable = FALSE, Converged = FALSE, PrecisionTier = NA_character_, SupportsFormalInference = FALSE, 
                SubgroupMethod = refit_controls$method, ETS_Eligible = FALSE)
            next
        }
        fit_args <- list(data = sub_data, person = person_col, facets = facet_names, score = score_col, 
            rating_min = refit_controls$rating_min, rating_max = refit_controls$rating_max, weight = refit_controls$weight, 
            keep_original = refit_controls$keep_original, repeated_ratings = refit_controls$repeated_ratings, 
            missing_codes = refit_controls$missing_codes, method = refit_controls$method, model = refit_controls$model, 
            step_facet = refit_controls$step_facet, slope_facet = refit_controls$slope_facet, gpcm_mml_identification = refit_controls$gpcm_mml_identification, 
            anchors = if (nrow(linking_setup$anchor_tbl) > 0) linking_setup$anchor_tbl else NULL, noncenter_facet = refit_controls$noncenter_facet, 
            centering_scope = refit_controls$centering_scope, dummy_facets = refit_controls$dummy_facets, 
            positive_facets = refit_controls$positive_facets, anchor_policy = "silent", min_common_anchors = linking_setup$min_common_anchors, 
            min_obs_per_element = refit_controls$min_obs_per_element, min_obs_per_category = refit_controls$min_obs_per_category, 
            quad_points = refit_controls$quad_points, maxit = refit_controls$maxit, reltol = refit_controls$reltol, 
            optimizer = refit_controls$optimizer, mml_engine = refit_controls$mml_engine, mml_starts = refit_controls$mml_starts, 
            mml_integration = refit_controls$mml_integration)
        linking_review_msgs <- character(0)
        sub_fit <- tryCatch(withCallingHandlers(do.call(fit_mfrm, fit_args), message = function(m) {
            msg <- conditionMessage(m)
            if (grepl("Anchor review", msg, fixed = TRUE) || grepl("anchor_policy", msg, fixed = TRUE)) {
                linking_review_msgs <<- c(linking_review_msgs, msg)
            }
            invokeRestart("muffleMessage")
        }, warning = function(w) {
            invokeRestart("muffleWarning")
        }), error = function(e) structure(list(message = conditionMessage(e)), class = "mfrm_dff_fit_error"))
        linking_review_text <- if (length(linking_review_msgs) > 0L) {
            paste(unique(linking_review_msgs), collapse = " | ")
        }
        else {
            NA_character_
        }
        if (inherits(sub_fit, "mfrm_dff_fit_error")) {
            group_fits[[g]] <- mutate(facet_estimates, Estimate = NA_real_, SE = NA_real_, Fixed = FALSE, 
                N = NA_integer_, NPersons = NA_integer_, N_Subgroup = NA_integer_, N_Input = as.integer(nrow(sub_data)), 
                EstimateStatus = "unavailable", EstimateReason = paste0("Subgroup refit failed: ", sub_fit$message), 
                LinkingFacets = if (length(linking_setup$linking_facets) > 0) {
                  paste(linking_setup$linking_facets, collapse = ", ")
                }
                else {
                  NA_character_
                }, LinkingThreshold = as.integer(linking_setup$min_common_anchors), LinkingStatus = if (nrow(linking_setup$anchor_tbl) > 
                  0) 
                  "failed"
                else "unlinked", LinkingAnchoredLevels = NA_integer_, LinkingDetail = sub_fit$message %||% 
                  "Anchored subgroup refit failed.", LinkingReview = linking_review_text, LinkComparable = FALSE, 
                Converged = FALSE, PrecisionTier = NA_character_, SupportsFormalInference = FALSE, SubgroupMethod = refit_controls$method, 
                ETS_Eligible = FALSE)
        }
        else {
            group_persons[[g]] <- unique(as.character(sub_fit$prep$data$Person))
            linkage <- summarize_dff_group_linkage(sub_fit, linking_setup = linking_setup)
            sub_diag_error <- NULL
            sub_diag <- tryCatch(suppressWarnings(diagnose_mfrm(sub_fit, residual_pca = "none")), error = function(e) {
                sub_diag_error <<- conditionMessage(e)
                NULL
            })
            group_fits[[g]] <- extract_dff_group_estimates(sub_fit = sub_fit, sub_diag = sub_diag, facet = facet, 
                fallback_levels = facet_estimates$Level, n_obs = sum(idx), linking_setup = linking_setup, 
                linkage = linkage, diagnostics_error = sub_diag_error, linking_review_note = linking_review_text)
        }
    }
    if (!is.null(focal)) {
        pairs <- expand_grid(Group1 = setdiff(group_levels, focal), Group2 = focal)
    }
    else {
        pairs <- as_tibble(as.data.frame(t(combn(group_levels, 2)), stringsAsFactors = FALSE))
        names(pairs) <- c("Group1", "Group2")
    }
    dif_rows <- list()
    for (i in seq_len(nrow(pairs))) {
        g1 <- pairs$Group1[i]
        g2 <- pairs$Group2[i]
        est1 <- group_fits[[g1]]
        est2 <- group_fits[[g2]]
        overlap <- if (g1 %in% names(group_persons) && g2 %in% names(group_persons)) {
            length(intersect(group_persons[[g1]], group_persons[[g2]]))
        }
        else NA_integer_
        merged <- merge(est1, est2, by = "Level", suffixes = c("_1", "_2"))
        for (j in seq_len(nrow(merged))) {
            e1 <- merged$Estimate_1[j]
            e2 <- merged$Estimate_2[j]
            se1 <- merged$SE_1[j]
            se2 <- merged$SE_2[j]
            n1 <- merged$N_1[j]
            n2 <- merged$N_2[j]
            fixed1 <- isTRUE(merged$Fixed_1[j])
            fixed2 <- isTRUE(merged$Fixed_2[j])
            fixed_comparison <- (fixed1 || fixed2) && is.finite(e1) && is.finite(e2)
            link_comparable <- isTRUE(merged$LinkComparable_1[j]) && isTRUE(merged$LinkComparable_2[j])
            subgroup_formal <- isTRUE(merged$SupportsFormalInference_1[j]) && isTRUE(merged$SupportsFormalInference_2[j])
            subgroup_converged <- isTRUE(merged$Converged_1[j]) && isTRUE(merged$Converged_2[j])
            comparison_method <- dplyr::coalesce(merged$SubgroupMethod_1[j], merged$SubgroupMethod_2[j], 
                baseline_precision_meta$method)
            inference_tier <- dplyr::case_when(all(c(merged$PrecisionTier_1[j], merged$PrecisionTier_2[j]) == 
                "model_based") ~ "model_based", any(c(merged$PrecisionTier_1[j], merged$PrecisionTier_2[j]) == 
                "exploratory") ~ "exploratory", any(c(merged$PrecisionTier_1[j], merged$PrecisionTier_2[j]) == 
                "hybrid") ~ "hybrid", TRUE ~ NA_character_)
            scale_link_status <- dplyr::case_when(any(c(merged$LinkingStatus_1[j], merged$LinkingStatus_2[j]) == 
                "failed") ~ "failed", any(c(merged$LinkingStatus_1[j], merged$LinkingStatus_2[j]) == 
                "insufficient_data") ~ "insufficient_data", link_comparable ~ "linked", any(c(merged$LinkingStatus_1[j], 
                merged$LinkingStatus_2[j]) == "weak_link") ~ "weak_link", any(c(merged$LinkingStatus_1[j], 
                merged$LinkingStatus_2[j]) == "unlinked") ~ "unlinked", TRUE ~ "unlinked")
            is_sparse <- if (is.finite(n1) && is.finite(n2)) {
                (n1 < min_obs) || (n2 < min_obs)
            }
            else NA
            points_available <- is.finite(e1) && is.finite(e2) && is.finite(e1 - e2)
            se_scale <- max(se1, se2)
            se_diff <- if (is.finite(se1) && is.finite(se2) && se1 > 0 && se2 > 0) {
                se_scale * sqrt((se1/se_scale)^2 + (se2/se_scale)^2)
            }
            else NA_real_
            complete_precision <- points_available && is.finite(se_diff) && se_diff > 0 && is.finite((e1 - 
                e2)/se_diff) && is.finite(n1) && is.finite(n2) && n1 > 1 && n2 > 1
            conditional_screen_eligible <- link_comparable && subgroup_formal && subgroup_converged && 
                isTRUE(baseline_precision_meta$supports_formal) && isTRUE(baseline_precision_meta$converged) && 
                identical(comparison_method, "MML") && isFALSE(is_sparse) && !fixed_comparison && complete_precision && 
                isTRUE(overlap == 0L)
            comparison_reason <- if (fixed_comparison) {
                "Target fixed by constraints in at least one subgroup."
            }
            else if (!points_available) {
                reasons <- c(merged$EstimateReason_1[j], merged$EstimateReason_2[j])
                reasons <- unique(reasons[!is.na(reasons) & nzchar(reasons)])
                if (length(reasons)) 
                  paste(reasons, collapse = " | ")
                else "Nonfinite subgroup location or difference."
            }
            else NA_character_
            screen_reason <- if (fixed_comparison || !points_available) {
                comparison_reason
            }
            else if (!complete_precision) {
                "Finite positive subgroup SEs, a representable standardized difference and at least two retained responses per cell are required."
            }
            else if (isTRUE(overlap > 0L)) {
                "Subgroups contain shared Persons; cross-refit covariance is unavailable."
            }
            else if (!isFALSE(is_sparse)) {
                "Target-by-group cell is sparse or its retained count is unavailable."
            }
            else if (!conditional_screen_eligible) {
                "Linking, baseline/subgroup readiness or model-based MML precision requirements are not met."
            }
            else NA_character_
            formal_eligible <- FALSE
            reporting_use <- dplyr::case_when(conditional_screen_eligible ~ "screening_only_conditional_plugin", 
                link_comparable ~ "screening_only_linked_descriptive", TRUE ~ "screening_only")
            contrast <- if (fixed_comparison || !points_available) 
                NA_real_
            else e1 - e2
            if (!conditional_screen_eligible) 
                se_diff <- NA_real_
            t_val <- if (is.finite(se_diff) && se_diff > 0) 
                contrast/se_diff
            else NA_real_
            df_welch <- if (conditional_screen_eligible && is.finite(se1) && is.finite(se2) && se1 > 
                0 && se2 > 0) {
                welch_satterthwaite_df(c((se1/se_scale)^2, (se2/se_scale)^2), c(n1 - 1, n2 - 1))
            }
            else {
                NA_real_
            }
            p_val <- if (is.finite(t_val) && is.finite(df_welch) && df_welch > 0) {
                2 * stats::pt(abs(t_val), df = df_welch, lower.tail = FALSE)
            }
            else {
                NA_real_
            }
            abs_diff <- abs(contrast)
            direction <- if (is.finite(contrast)) {
                if (contrast > 0) 
                  "larger_location_in_group1"
                else if (contrast < 0) {
                  "smaller_location_in_group1"
                }
                else "equal_locations"
            }
            else {
                NA_character_
            }
            dif_rows[[length(dif_rows) + 1]] <- tibble(Level = merged$Level[j], Group1 = g1, Group2 = g2, 
                Estimate1 = e1, Estimate2 = e2, Fixed1 = fixed1, Fixed2 = fixed2, Contrast = contrast, 
                ContrastDirection = direction, ComparisonStatus = if (fixed_comparison) 
                  "fixed_target"
                else if (points_available) 
                  "available"
                else "unavailable", ComparisonReason = comparison_reason, ConditionalScreenReason = screen_reason, 
                SE = se_diff, t = t_val, df = df_welch, p_value = p_val, AbsDiff = abs_diff, Method = "refit", 
                N_Group1 = as.integer(n1), N_Group2 = as.integer(n2), NPersons_Group1 = merged$NPersons_1[j], 
                NPersons_Group2 = merged$NPersons_2[j], N_Subgroup1 = merged$N_Subgroup_1[j], N_Subgroup2 = merged$N_Subgroup_2[j], 
                NPersons_Overlap = as.integer(overlap), sparse = is_sparse, ContrastComparable = link_comparable, 
                ConditionalRefitScreenEligible = conditional_screen_eligible, FormalInferenceEligible = formal_eligible, 
                PrimaryReportingEligible = formal_eligible, SupportsFormalInference = formal_eligible, 
                InferenceTier = inference_tier, ComparisonMethod = comparison_method, ReportingUse = reporting_use, 
                ETS_Eligible = FALSE, ScaleLinkStatus = scale_link_status, BaselineMethod = baseline_precision_meta$method, 
                BaselineConverged = isTRUE(baseline_precision_meta$converged), BaselinePrecisionTier = baseline_precision_meta$precision_tier, 
                BaselineSupportsFormalInference = isTRUE(baseline_precision_meta$supports_formal), SubgroupConverged1 = isTRUE(merged$Converged_1[j]), 
                SubgroupConverged2 = isTRUE(merged$Converged_2[j]), LinkingFacets = merged$LinkingFacets_1[j] %||% 
                  merged$LinkingFacets_2[j], LinkingThreshold = merged$LinkingThreshold_1[j] %||% merged$LinkingThreshold_2[j], 
                LinkingStatus1 = merged$LinkingStatus_1[j], LinkingStatus2 = merged$LinkingStatus_2[j], 
                LinkingAnchoredLevels1 = merged$LinkingAnchoredLevels_1[j], LinkingAnchoredLevels2 = merged$LinkingAnchoredLevels_2[j], 
                LinkingDetail1 = merged$LinkingDetail_1[j], LinkingDetail2 = merged$LinkingDetail_2[j])
        }
    }
    dif_table <- bind_rows(dif_rows)
    if (nrow(dif_table) > 0 && any(is.finite(dif_table$p_value))) {
        dif_table$p_adjusted <- stats::p.adjust(dif_table$p_value, method = p_adjust, n = nrow(dif_table))
    }
    else {
        dif_table$p_adjusted <- NA_real_
    }
    dif_table <- annotate_dff_table(dif_table, method = "refit")
    dif_summary <- build_dff_summary(dif_table, method = "refit")
    functioning_label <- functioning_label_for_facet(facet)
    out <- list(dif_table = dif_table, cell_table = NULL, summary = dif_summary, group_fits = group_fits, 
        gpcm_boundary = gpcm_capability_boundary_table(fit, helper = "analyze_dff()", area = "Differential facet functioning screening under GPCM"), 
        config = list(facet = facet, group = group, method = "refit", refit_output_version = 1L, min_obs = min_obs, 
            p_adjust = p_adjust, focal = focal, group_levels = group_levels, linking_facets = linking_setup$linking_facets, 
            linking_threshold = linking_setup$min_common_anchors, refit_identity_contract = refit_controls$identity_contract, 
            refit_anchor_policy = "preserve_baseline_direct_anchors", refit_rating_range = c(refit_controls$rating_min, 
                refit_controls$rating_max), refit_slope_facet = refit_controls$slope_facet, refit_optimizer = refit_controls$optimizer, 
            refit_mml_engine = refit_controls$mml_engine, refit_mml_integration = refit_controls$mml_integration, 
            functioning_label = functioning_label))
    class(out) <- c("mfrm_dff", "mfrm_dif", class(out))
    out
}

summary.mfrm_dif <- function(object, ...) {
    validate_dff_residual_output(object)
    out <- list(dif_table = object$dif_table, cell_table = object$cell_table, cases = object$cases, comparison_review = object$comparison_review, 
        summary = object$summary, gpcm_boundary = object$gpcm_boundary %||% data.frame(), config = object$config)
    class(out) <- "summary.mfrm_dif"
    out
}

summary.mfrm_dff <- function(object, ...) {
    if (is.list(object) && !is.null(object$table) && is.data.frame(object$table)) {
        tbl <- object$table
        flagged <- if ("Flagged" %in% names(tbl)) tbl[!is.na(tbl$Flagged) & tbl$Flagged, , drop = FALSE] else tbl[FALSE, , drop = FALSE]
        ov <- data.frame(
            Method = as.character(object$method %||% "mml_lrt"),
            Facet = as.character(object$facet %||% ""),
            Group = as.character(object$group %||% ""),
            Reference = as.character(object$reference %||% ""),
            Focal = as.character(object$focal %||% ""),
            ElementsTested = sum(is.finite(tbl$pValue)),
            ElementsUnavailable = sum(!is.finite(tbl$pValue)),
            Flagged = if (all(is.na(tbl$Flagged))) NA_integer_ else nrow(flagged),
            MaxAbsContrast = if (nrow(tbl) > 0L && any(is.finite(tbl$Contrast))) max(abs(tbl$Contrast), na.rm = TRUE) else NA_real_,
            stringsAsFactors = FALSE
        )
        return(structure(
            list(overview = ov, summary = ov, dif_table = tbl, table = tbl, flagged = flagged, fast_dff = TRUE),
            class = "summary.mfrm_dff"
        ))
    }
    out <- summary.mfrm_dif(object, ...)
    class(out) <- c("summary.mfrm_dff", class(out))
    out
}

print.summary.mfrm_dif <- function(x, ...) {
    validate_dff_residual_output(x)
    label <- x$config$functioning_label %||% "DFF"
    cat(if (identical(x$config$method, "residual")) 
        "--- Group residual comparisons ---\n"
    else paste0("--- ", label, " Analysis ---\n"))
    cat("Method:", x$config$method %||% "refit", "\n")
    cat("Facet:", x$config$facet, " | Group:", x$config$group, "\n")
    cat("Groups:", paste(x$config$group_levels, collapse = ", "), "\n")
    if (identical(x$config$method, "refit")) {
        link_txt <- if (!is.null(x$config$linking_facets) && length(x$config$linking_facets) > 0) {
            paste(x$config$linking_facets, collapse = ", ")
        }
        else {
            "none"
        }
        cat("Linking facets:", link_txt)
        if (!is.null(x$config$linking_threshold)) {
            cat(" | Anchor threshold:", x$config$linking_threshold)
        }
        cat("\n")
    }
    if (!is.null(x$config$min_obs)) {
        cat("Min observations per cell:", x$config$min_obs, "\n")
    }
    cat("\n")
    if (nrow(x$dif_table) > 0) {
        show_cols <- intersect(c("Level", "Group1", "Group2", "Contrast", "SE", "t", "p_adjusted", "Classification", 
            "ETS", "N_Group1", "N_Group2", "sparse"), names(x$dif_table))
        if (identical(x$config$method, "residual")) {
            show_cols <- intersect(c("Level", "Group1", "Group2", "Contrast", "N_Group1", "N_Group2", 
                "sparse"), names(x$dif_table))
        }
        print_tbl <- select(x$dif_table, all_of(show_cols))
        print(as.data.frame(print_tbl), row.names = FALSE, digits = 3)
    }
    else {
        cat("No differential-functioning contrasts computed.\n")
    }
    if (identical(x$config$method, "refit")) {
        cat("\nRefit Classification Summary:\n")
    }
    else {
        cat("\nResidual differences do not isolate differential functioning; no test or confidence interval is provided.\n\nAvailable comparisons:\n")
    }
    print(as.data.frame(x$summary), row.names = FALSE)
    mfrmr_print_comparison_review(x$comparison_review)
    .print_dff_gpcm_boundary(x$gpcm_boundary)
    invisible(x)
}

print.summary.mfrm_dff <- function(x, ...) {
    if (isTRUE(x$fast_dff)) {
        ov <- x$overview
        cat(sprintf("Differential Facet Functioning Summary [%s | Facet: %s | Group: %s (%s vs %s)]\n",
                    ov$Method, ov$Facet, ov$Group, ov$Reference, ov$Focal))
        cat(sprintf("  Elements tested: %d | Unavailable: %d | Flagged (pAdj < 0.05): %d | Max |Contrast|: %.4f\n\n",
                    ov$ElementsTested, ov$ElementsUnavailable %||% 0L, ov$Flagged, ov$MaxAbsContrast))
        if (nrow(x$table) > 0L) {
            disp <- x$table
            nc <- vapply(disp, is.numeric, logical(1))
            disp[nc] <- lapply(disp[nc], round, 4)
            print(disp, row.names = FALSE)
        }
        return(invisible(x))
    }
    print.summary.mfrm_dif(x, ...)
    invisible(x)
}

print.mfrm_dif <- function(x, ...) {
    .print_dif_overview(x, label = "DIF")
    invisible(x)
}

.print_dif_overview <- function(x, label) {
    validate_dff_residual_output(x)
    cfg <- x$config %||% list()
    method <- cfg$method %||% "refit"
    facet <- cfg$facet %||% NA_character_
    group <- cfg$group %||% NA_character_
    groups <- cfg$group_levels %||% character(0)
    tbl <- x$dif_table
    n_rows <- if (is.data.frame(tbl)) 
        nrow(tbl)
    else 0L
    cat(if (identical(method, "residual")) 
        "Group residual comparisons\n"
    else sprintf("mfrm_%s (%s)\n", tolower(label), label))
    cat(sprintf("  Method: %s | Facet: %s | Group: %s\n", method, facet, group))
    if (length(groups) > 0L) {
        cat(sprintf("  Group levels: %s\n", paste(groups, collapse = ", ")))
    }
    if (n_rows > 0L) {
        cat(sprintf("  Contrasts: %d row(s)", n_rows))
        cat("\n")
    }
    else {
        cat("  Contrasts: 0 row(s)\n")
    }
    boundary <- x$gpcm_boundary %||% data.frame()
    if (is.data.frame(boundary) && nrow(boundary) > 0L) {
        cat("  GPCM: differences use the fitted category slopes and expected scores.\n")
    }
    if (identical(method, "residual")) 
        cat("  Residual differences do not isolate differential functioning; no test or confidence interval is provided.\n")
    cat("  Use `summary()` for the contrast table.\n")
    invisible(NULL)
}

.print_dff_gpcm_boundary <- function(boundary) {
    if (is.null(boundary) || !is.data.frame(boundary) || nrow(boundary) == 0L) {
        return(invisible(NULL))
    }
    cat("\nGPCM: these summaries use the fitted category slopes and expected scores.\n")
    invisible(NULL)
}




information_build_step_structure <- function(fit, model) {
    steps <- tibble::as_tibble(fit$steps %||% tibble::tibble())
    if (nrow(steps) == 0 || !"Estimate" %in% names(steps)) {
        stop("Step/threshold estimates are required for information computation.", call. = FALSE)
    }
    if (identical(model, "RSM")) {
        step_est <- suppressWarnings(as.numeric(steps$Estimate))
        if (length(step_est) == 0 || any(!is.finite(step_est))) {
            stop("RSM step estimates must be finite numeric values.", call. = FALSE)
        }
        return(list(kind = "common", categories = 0:length(step_est), step_facet = NULL, step_levels = NULL, 
            compute = function(eta) category_prob_rsm(eta, c(0, cumsum(step_est)))))
    }
    if (!identical(model, "PCM") && !identical(model, "GPCM")) {
        stop("`compute_information()` currently supports only ordered-category ", "`model = \"RSM\"`, `model = \"PCM\"`, and bounded ", 
            "`model = \"GPCM\"` fits.", call. = FALSE)
    }
    step_facet <- as.character(fit$config$step_facet %||% NA_character_)
    if (!nzchar(step_facet)) {
        stop("PCM information requires a valid `step_facet` in `fit$config`.", call. = FALSE)
    }
    if (!"StepFacet" %in% names(steps)) {
        stop("PCM step estimates must include a `StepFacet` column.", call. = FALSE)
    }
    if (!"StepIndex" %in% names(steps)) {
        if (!"Step" %in% names(steps)) {
            stop("PCM step estimates must include either `StepIndex` or `Step`.", call. = FALSE)
        }
        steps$StepIndex <- suppressWarnings(as.integer(gsub("[^0-9]+", "", as.character(steps$Step))))
    }
    steps <- dplyr::arrange(dplyr::transmute(steps, StepFacet = as.character(.data$StepFacet), StepIndex = suppressWarnings(as.integer(.data$StepIndex)), 
        Estimate = suppressWarnings(as.numeric(.data$Estimate))), .data$StepFacet, .data$StepIndex)
    if (any(is.na(steps$StepFacet) | !nzchar(steps$StepFacet))) {
        stop("PCM `StepFacet` labels must be non-empty strings.", call. = FALSE)
    }
    if (any(!is.finite(steps$StepIndex)) || any(steps$StepIndex < 1L)) {
        stop("PCM `StepIndex` values must be positive integers.", call. = FALSE)
    }
    if (any(!is.finite(steps$Estimate))) {
        stop("PCM step estimates must be finite numeric values.", call. = FALSE)
    }
    step_counts <- dplyr::count(steps, .data$StepFacet, name = "n_steps")
    if (length(unique(step_counts$n_steps)) != 1L) {
        stop("Each PCM `StepFacet` level must supply the same number of thresholds.", call. = FALSE)
    }
    n_steps <- unique(step_counts$n_steps)
    expected_index <- seq_len(n_steps)
    bad_order <- dplyr::summarize(dplyr::group_by(steps, .data$StepFacet), ok = identical(sort(unique(.data$StepIndex)), 
        expected_index), .groups = "drop")
    if (any(!bad_order$ok)) {
        stop("PCM step estimates must provide contiguous `StepIndex` values starting at 1 for each `StepFacet` level.", 
            call. = FALSE)
    }
    step_levels <- as.character(fit$prep$levels[[step_facet]] %||% character())
    observed_levels <- unique(as.character(steps$StepFacet))
    if (length(step_levels) == 0L) {
        step_levels <- observed_levels
    }
    else {
        step_levels <- c(step_levels, setdiff(observed_levels, step_levels))
    }
    step_mat <- matrix(NA_real_, nrow = length(step_levels), ncol = n_steps)
    rownames(step_mat) <- step_levels
    for (i in seq_len(nrow(steps))) {
        row_idx <- match(steps$StepFacet[i], step_levels)
        col_idx <- steps$StepIndex[i]
        step_mat[row_idx, col_idx] <- steps$Estimate[i]
    }
    if (any(!is.finite(step_mat))) {
        stop("PCM step estimates did not cover all expected `StepFacet` / `StepIndex` combinations.", 
            call. = FALSE)
    }
    step_cum_mat <- t(apply(step_mat, 1, function(x) c(0, cumsum(x))))
    if (identical(model, "PCM")) {
        return(list(kind = "step_facet_specific", categories = 0:n_steps, step_facet = step_facet, step_levels = step_levels, 
            slope_facet = NULL, slope_levels = NULL, slopes = NULL, compute = function(eta, step_idx) {
                category_prob_pcm(eta = eta, step_cum_mat = step_cum_mat, criterion_idx = step_idx)
            }))
    }
    slope_facet <- as.character(fit$config$slope_facet %||% NA_character_)
    if (!nzchar(slope_facet)) {
        stop("GPCM information requires a valid `slope_facet` in `fit$config`.", call. = FALSE)
    }
    slope_tbl <- tibble::as_tibble(fit$slopes %||% tibble::tibble())
    if (nrow(slope_tbl) == 0 || !all(c("SlopeFacet", "Estimate") %in% names(slope_tbl))) {
        stop("GPCM information requires a `fit$slopes` table with `SlopeFacet` and `Estimate` columns.", 
            call. = FALSE)
    }
    slope_tbl <- dplyr::transmute(slope_tbl, SlopeFacet = as.character(.data$SlopeFacet), Estimate = suppressWarnings(as.numeric(.data$Estimate)))
    if (any(is.na(slope_tbl$SlopeFacet) | !nzchar(slope_tbl$SlopeFacet))) {
        stop("GPCM `SlopeFacet` labels must be non-empty strings.", call. = FALSE)
    }
    if (any(!is.finite(slope_tbl$Estimate)) || any(slope_tbl$Estimate <= 0)) {
        stop("GPCM slopes must be finite and strictly positive for information computation.", call. = FALSE)
    }
    slope_levels <- as.character(fit$prep$levels[[slope_facet]] %||% character())
    observed_slope_levels <- unique(as.character(slope_tbl$SlopeFacet))
    if (length(slope_levels) == 0L) {
        slope_levels <- observed_slope_levels
    }
    else {
        slope_levels <- c(slope_levels, setdiff(observed_slope_levels, slope_levels))
    }
    slope_vals <- rep(NA_real_, length(slope_levels))
    names(slope_vals) <- slope_levels
    slope_vals[slope_tbl$SlopeFacet] <- slope_tbl$Estimate
    if (any(!is.finite(slope_vals))) {
        stop("GPCM slopes did not cover all expected `SlopeFacet` levels.", call. = FALSE)
    }
    list(kind = "step_and_slope_specific", categories = 0:n_steps, step_facet = step_facet, step_levels = step_levels, 
        slope_facet = slope_facet, slope_levels = slope_levels, slopes = unname(slope_vals), compute = function(eta, 
            step_idx, slope_idx) {
            category_prob_gpcm(eta = eta, step_cum_mat = step_cum_mat, criterion_idx = step_idx, slopes = unname(slope_vals), 
                slope_idx = slope_idx)
        })
}

compute_information <- function(fit, theta_range = c(-6, 6), theta_points = 201L, rating_plan = NULL, 
    exposure_basis = c("observed_total", "per_person_average")) {
    if (inherits(fit, "mfrm_fast_fit")) {
        return(.mfrm_information_fast_fit(fit, theta_range = theta_range, theta_points = theta_points))
    }
    stop_if_product_slopes(fit, "compute_information()")
    exposure_basis_supplied <- !missing(exposure_basis)
    exposure_basis <- match.arg(exposure_basis)
    if (!is.null(rating_plan) && exposure_basis_supplied && !identical(exposure_basis, "observed_total")) {
        stop("`exposure_basis` applies only when `rating_plan = NULL`; an explicit `rating_plan` already defines one Person's rating counts.", 
            call. = FALSE)
    }
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an `mfrm_fit` object.", call. = FALSE)
    }
    model <- as.character(fit$config$model %||% NA_character_)
    theta_grid <- seq(theta_range[1], theta_range[2], length.out = theta_points)
    step_structure <- information_build_step_structure(fit, model)
    categories <- step_structure$categories
    facet_tbl <- tibble::as_tibble(fit$facets$others)
    if (nrow(facet_tbl) == 0) {
        stop("Facet estimates are required for information computation.", call. = FALSE)
    }
    obs_df <- as.data.frame(fit$prep$data %||% NULL, stringsAsFactors = FALSE)
    if (nrow(obs_df) == 0) {
        stop("Prepared observation data are required for information computation.", call. = FALSE)
    }
    facet_names <- as.character(fit$config$facet_names %||% unique(as.character(facet_tbl$Facet)))
    facet_names <- facet_names[facet_names %in% names(obs_df)]
    if (length(facet_names) == 0) {
        stop("Facet columns were not found in the prepared response data.", call. = FALSE)
    }
    facet_signs <- fit$config$facet_signs %||% stats::setNames(rep(-1, length(facet_names)), facet_names)
    facet_signs <- facet_signs[facet_names]
    facet_signs[!is.finite(facet_signs)] <- -1
    if (!is.null(rating_plan)) {
        if (inherits(fit, "mfrm_imported_fit") || !identical(fit$config$method, "MML") || !isTRUE(fit$summary$Converged) || 
            length(fit$config$interaction_specs) || !is.null(fit$config$gpcm_limit_source)) 
            stop("Rating plans require a converged native additive MML fit, without a limiting-model reduction.", 
                call. = FALSE)
        if (length(mfrmr_mml_additive_boundary_evidence(fit$config))) 
            stop("The source model has no finite maximum; optimizer traces cannot qualify a rating plan.", 
                call. = FALSE)
        if (any(facet_names %in% c("Count", "ObservedContext")) || !is.data.frame(rating_plan) || !nrow(rating_plan) || 
            anyDuplicated(names(rating_plan)) || !setequal(names(rating_plan), c(facet_names, "Count"))) 
            stop("`rating_plan` must contain every non-Person facet and Count, with no other columns; Count and ObservedContext are reserved.", 
                call. = FALSE)
        rating_plan <- as.data.frame(rating_plan[c(facet_names, "Count")], stringsAsFactors = FALSE)
        n <- rating_plan$Count
        if (!is.numeric(n) || is.complex(n) || !is.null(dim(n)) || any(!is.finite(n) | n <= 0 | n != 
            floor(n)) || !is.finite(sum(n))) 
            stop("Rating-plan Count must be positive finite integers, not estimation weights.", call. = FALSE)
        for (facet in facet_names) {
            z <- rating_plan[[facet]]
            if ((!is.atomic(z) && !is.factor(z)) || !is.null(dim(z)) || anyNA(z) || any(!as.character(z) %in% 
                as.character(fit$prep$levels[[facet]]))) 
                stop("Unknown or missing rating-plan level in facet ", facet, ".", call. = FALSE)
            rating_plan[[facet]] <- as.character(z)
        }
        if (anyDuplicated(rating_plan[facet_names])) 
            stop("Repeated rating-plan contexts must be combined in Count.", call. = FALSE)
        observed_weight <- obs_df$Weight %||% rep(1, nrow(obs_df))
        observed <- unique(as.data.frame(lapply(obs_df[is.finite(observed_weight) & observed_weight > 
            0, facet_names, drop = FALSE], as.character), check.names = FALSE))
        rating_plan$ObservedContext <- vapply(seq_len(nrow(rating_plan)), function(i) any(Reduce(`&`, 
            lapply(facet_names, function(f) observed[[f]] == rating_plan[[f]][i]))), TRUE)
        obs_df <- rating_plan[facet_names]
        obs_df$Weight <- rating_plan$Count
    }
    compute_cell_info <- function(offset, step_idx = NULL, slope_idx = NULL) {
        eta <- theta_grid + offset
        probs <- if (identical(step_structure$kind, "common")) {
            step_structure$compute(eta)
        }
        else if (identical(step_structure$kind, "step_facet_specific")) {
            step_structure$compute(eta, rep(step_idx, length(eta)))
        }
        else {
            step_structure$compute(eta, rep(step_idx, length(eta)), rep(slope_idx, length(eta)))
        }
        variance <- mfrm_category_variance(probs, categories)
        if (identical(step_structure$kind, "step_and_slope_specific")) {
            variance <- variance * (step_structure$slopes[slope_idx]^2)
        }
        variance
    }
    facet_tbl <- facet_tbl[is.finite(facet_tbl$Estimate), , drop = FALSE]
    if (nrow(facet_tbl) == 0) {
        stop("Facet estimates are required for information computation.", call. = FALSE)
    }
    obs_weights <- suppressWarnings(as.numeric(obs_df$Weight %||% rep(1, nrow(obs_df))))
    obs_weights[!is.finite(obs_weights)] <- 0
    n_active_persons <- NA_integer_
    if (is.null(rating_plan) && identical(exposure_basis, "per_person_average")) {
        if (!"Person" %in% names(obs_df)) {
            stop("`Person` column is required in prepared data for `exposure_basis = \"per_person_average\"`.", 
                call. = FALSE)
        }
        active_persons <- unique(as.character(obs_df$Person[obs_weights > 0]))
        active_persons <- active_persons[!is.na(active_persons) & nzchar(active_persons)]
        n_active_persons <- length(active_persons)
        if (n_active_persons == 0L) {
            stop("No positive-weight Person observations were available for `exposure_basis = \"per_person_average\"`.", 
                call. = FALSE)
        }
    }
    design_cells <- obs_df[, facet_names, drop = FALSE]
    design_cells$Exposure <- obs_weights
    design_cells <- dplyr::summarize(dplyr::group_by(design_cells, dplyr::across(dplyr::all_of(facet_names))), 
        Exposure = sum(.data$Exposure, na.rm = TRUE), .groups = "drop")
    design_cells <- as.data.frame(design_cells, stringsAsFactors = FALSE)
    if (is.null(rating_plan) && identical(exposure_basis, "per_person_average")) {
        design_cells$Exposure <- design_cells$Exposure/n_active_persons
    }
    est_key <- paste(facet_tbl$Facet, facet_tbl$Level, sep = "||")
    est_lookup <- stats::setNames(facet_tbl$Estimate, est_key)
    cell_offset <- numeric(nrow(design_cells))
    cell_ok <- design_cells$Exposure > 0
    for (facet in facet_names) {
        keys <- paste(facet, design_cells[[facet]], sep = "||")
        est_vals <- suppressWarnings(as.numeric(est_lookup[keys]))
        sign_val <- suppressWarnings(as.numeric(facet_signs[[facet]]))
        if (!is.finite(sign_val)) 
            sign_val <- -1
        cell_ok <- cell_ok & is.finite(est_vals)
        cell_offset <- cell_offset + sign_val * est_vals
    }
    cell_step_idx <- NULL
    cell_slope_idx <- NULL
    if (identical(step_structure$kind, "step_facet_specific") || identical(step_structure$kind, "step_and_slope_specific")) {
        step_facet <- step_structure$step_facet
        if (!step_facet %in% names(design_cells)) {
            stop("Step facet column was not found in the observed design cells.", call. = FALSE)
        }
        cell_step_idx <- match(as.character(design_cells[[step_facet]]), step_structure$step_levels)
        cell_ok <- cell_ok & is.finite(cell_step_idx)
    }
    if (identical(step_structure$kind, "step_and_slope_specific")) {
        slope_facet <- step_structure$slope_facet
        if (!slope_facet %in% names(design_cells)) {
            stop("GPCM slope facet column was not found in the observed design cells.", call. = FALSE)
        }
        cell_slope_idx <- match(as.character(design_cells[[slope_facet]]), step_structure$slope_levels)
        cell_ok <- cell_ok & is.finite(cell_slope_idx)
    }
    if (!is.null(rating_plan) && !all(cell_ok)) 
        stop("Every planned context must have finite fitted locations, thresholds and slopes.", call. = FALSE)
    design_cells <- design_cells[cell_ok, , drop = FALSE]
    cell_offset <- cell_offset[cell_ok]
    if (!is.null(cell_step_idx)) {
        cell_step_idx <- cell_step_idx[cell_ok]
    }
    if (!is.null(cell_slope_idx)) {
        cell_slope_idx <- cell_slope_idx[cell_ok]
    }
    if (nrow(design_cells) == 0) {
        stop("No valid observed design cells were available for information computation.", call. = FALSE)
    }
    if (is.null(cell_step_idx)) {
        info_mat <- vapply(cell_offset, compute_cell_info, numeric(length(theta_grid)))
    }
    else if (is.null(cell_slope_idx)) {
        info_mat <- vapply(seq_along(cell_offset), function(i) compute_cell_info(cell_offset[i], cell_step_idx[i]), 
            numeric(length(theta_grid)))
    }
    else {
        info_mat <- vapply(seq_along(cell_offset), function(i) compute_cell_info(cell_offset[i], cell_step_idx[i], 
            cell_slope_idx[i]), numeric(length(theta_grid)))
    }
    if (!is.matrix(info_mat)) {
        info_mat <- matrix(info_mat, ncol = 1)
    }
    weighted_info_mat <- sweep(info_mat, 2, design_cells$Exposure, `*`)
    if (!is.null(rating_plan) && (any(!is.finite(weighted_info_mat)) || any(!is.finite(rowSums(weighted_info_mat))))) 
        stop("The planned information is not finite; check the calibration and rating counts.", call. = FALSE)
    total_info <- rowSums(weighted_info_mat)
    iif_rows <- lapply(seq_len(nrow(facet_tbl)), function(i) {
        facet_i <- as.character(facet_tbl$Facet[i])
        level_i <- as.character(facet_tbl$Level[i])
        mask <- as.character(design_cells[[facet_i]]) == level_i
        tibble(Theta = theta_grid, Facet = facet_i, Level = level_i, Information = if (any(mask)) 
            rowSums(weighted_info_mat[, mask, drop = FALSE])
        else 0, Exposure = if (any(mask)) 
            sum(design_cells$Exposure[mask], na.rm = TRUE)
        else 0)
    })
    iif <- dplyr::bind_rows(iif_rows)
    tif <- tibble(Theta = theta_grid, Information = total_info, SE = ifelse(total_info > 0, 1/sqrt(total_info), 
        NA_real_))
    conditional_sem <- tibble(Theta = theta_grid, ConditionalSEM = tif$SE, Information = tif$Information)
    information_long <- dplyr::bind_rows(tibble(PlotType = "tif", Metric = "Information", Series = "Information", 
        Theta = theta_grid, Value = tif$Information, ValueName = "Information", DisplayedByDefault = TRUE), 
        tibble(PlotType = "conditional_sem", Metric = "Conditional SEM", Series = "Conditional SEM", 
            Theta = theta_grid, Value = tif$SE, ValueName = "ConditionalSEM", DisplayedByDefault = TRUE))
    finite_info <- is.finite(tif$Information)
    finite_sem <- is.finite(tif$SE)
    summary_tbl <- tibble(ThetaAtMaxInformation = if (any(finite_info)) 
        tif$Theta[which.max(ifelse(finite_info, tif$Information, -Inf))]
    else NA_real_, MaxInformation = if (any(finite_info)) 
        max(tif$Information[finite_info], na.rm = TRUE)
    else NA_real_, ThetaAtMinConditionalSEM = if (any(finite_sem)) 
        tif$Theta[which.min(ifelse(finite_sem, tif$SE, Inf))]
    else NA_real_, MinConditionalSEM = if (any(finite_sem)) 
        min(tif$SE[finite_sem], na.rm = TRUE)
    else NA_real_, ThetaPoints = length(theta_grid), ThetaMin = min(theta_grid, na.rm = TRUE), ThetaMax = max(theta_grid, 
        na.rm = TRUE))
    out <- list(tif = tif, conditional_sem = conditional_sem, information_long = information_long, iif = iif, 
        summary = summary_tbl, theta_range = theta_range)
    if (!is.null(rating_plan)) {
        out$rating_plan <- rating_plan
        slope_status <- mfrmr_readiness_gpcm_slope_parameters(fit$config, fit$slopes)
        working_slopes <- identical(model, "GPCM") && (nrow(slope_status) == 0L || any(!is.finite(slope_status$PrimaryEstimate)))
        out$settings <- data.frame(Basis = "per_person_rating_plan", RatingsPerPerson = sum(rating_plan$Count), 
            Calibration = "fixed", ParameterBasis = if (working_slopes) 
                "working_GPCM_coordinates"
            else "reported_estimates", BoundaryState = as.character(mfrmr_get_readiness_record(fit)$fit$BoundaryState))
        out$notes <- data.frame(Type = "Interpretation", Text = c("Information sums the specified ratings for one Person, conditional on the fitted calibration and independent responses given ability.", 
            "Count means independent rating occasions; repeating an existing response or correlated ratings does not add this amount of information.", 
            "The inverse square root is a conditional information-based SEM, not an EAP posterior SD or a finite-sample confidence interval. Calibration uncertainty is not propagated.", 
            "Only fitted facet levels are supported. An unobserved crossing is a model-based extrapolation; curve availability does not certify identification, model fit or a future population.", 
            "Compare plans on the same calibration and ability scale. This is not a G/Phi coefficient or a guarantee of an optimal allocation."))
        if (working_slopes) 
            out$notes <- rbind(out$notes, data.frame(Type = "Interpretation", Text = "GPCM curves use working optimizer coordinates because primary slope estimates are unavailable. Treat the comparison as conditional exploration, not an endorsed assessment plan."))
    }
    else if (identical(exposure_basis, "per_person_average")) {
        out$settings <- data.frame(Basis = "per_person_observed_average", ActivePersons = n_active_persons, 
            MeanRatingsPerPerson = sum(design_cells$Exposure), Calibration = "fixed", stringsAsFactors = FALSE)
        out$notes <- data.frame(Type = "Interpretation", Text = c("Information weights each observed context by its mean exposure per active Person (total observed weight divided by active Person count), placing ConditionalSEM on a typical single-Person scale.", 
            "ConditionalSEM = 1 / sqrt(Information) assumes conditionally independent ratings at fixed calibration; it is not an EAP posterior SD and does not propagate calibration uncertainty."), 
            stringsAsFactors = FALSE)
    }
    class(out) <- c("mfrm_information", class(out))
    out
}

measure_se_table <- function(fit, include_person = FALSE, diagnostics = NULL) {
    if (is.null(diagnostics)) {
        if (is.null(fit)) {
            stop("`fit` or `diagnostics` must be supplied to `measure_se_table()`.", call. = FALSE)
        }
        diagnostics <- diagnose_mfrm(fit)
    }
    measures <- tibble::as_tibble(diagnostics$measures)
    if (!isTRUE(include_person)) {
        measures <- dplyr::filter(measures, .data$Facet != "Person")
    }
    dplyr::distinct(dplyr::transmute(measures, Facet = as.character(.data$Facet), Level = as.character(.data$Level), 
        SE = as.numeric(.data$SE)))
}

.validate_linking_threshold <- function(x, arg) {
    if (!is.numeric(x) || length(x) != 1L || is.na(x) || x < 0) {
        stop("`", arg, "` must be one non-negative number (Inf disables the threshold).", call. = FALSE)
    }
    as.numeric(x)
}

.linking_difference_se <- function(a, b) {
    scale <- pmax(a, b)
    valid <- is.finite(a) & is.finite(b) & a >= 0 & b >= 0
    out <- rep(NA_real_, length(scale))
    out[valid & scale == 0] <- 0
    use <- valid & scale > 0
    out[use] <- scale[use] * sqrt((a[use]/scale[use])^2 + (b[use]/scale[use])^2)
    out[!is.finite(out)] <- NA_real_
    out
}


compute_equating_offset <- function(diffs, se_from = NULL, se_to = NULL, drift_threshold = NULL) {
    diffs <- as.numeric(diffs)
    if (!is.null(drift_threshold)) {
        drift_threshold <- .validate_linking_threshold(drift_threshold, "drift_threshold")
    }
    se_from <- if (is.null(se_from)) 
        rep(NA_real_, length(diffs))
    else as.numeric(se_from)
    se_to <- if (is.null(se_to)) 
        rep(NA_real_, length(diffs))
    else as.numeric(se_to)
    if (length(se_from) != length(diffs) || length(se_to) != length(diffs)) {
        stop("Differences and paired SEs must have the same length.", call. = FALSE)
    }
    ok <- is.finite(diffs)
    if (!any(ok)) {
        return(list(offset_prelim = NA_real_, offset = NA_real_, residual = rep(NA_real_, length(diffs)), 
            retained = rep(FALSE, length(diffs)), n_retained = 0L, weighting = "none", contributing = rep(FALSE, 
                length(diffs)), screening_fallback = FALSE, status = if (length(diffs)) "no_finite_differences" else "no_common", 
            reason = "No finite common-element differences are available."))
    }
    weight_ok <- ok & is.finite(se_from) & is.finite(se_to) & se_from > 0 & se_to > 0
    log_weights <- rep(NA_real_, length(diffs))
    high <- pmax(se_from[weight_ok], se_to[weight_ok])
    low <- pmin(se_from[weight_ok], se_to[weight_ok])
    log_weights[weight_ok] <- -2 * log(high) - log1p((low/high)^2)
    average <- function(retained) {
        weighted <- retained & weight_ok
        if (!any(weighted)) 
            return(mean(diffs[retained]))
        d <- diffs[weighted]
        if (all(d == d[1L])) 
            return(d[1L])
        lw <- log_weights[weighted]
        lw <- lw - max(lw)
        weights <- exp(lw)
        if (all(weights > 0)) {
            scale <- max(abs(d))
            center <- stats::weighted.mean(d/scale, weights)
            value <- center * scale
            if (value == 0 && center != 0) 
                return(NA_real_)
            return(max(min(d), min(max(d), value)))
        }
        lw <- lw - log(sum(weights))
        nonzero <- d != 0
        if (!any(nonzero)) 
            return(0)
        terms <- log(abs(d[nonzero])) + lw[nonzero]
        shift <- max(terms)
        total <- sum(sign(d[nonzero]) * exp(terms - shift))
        if (total == 0) 
            return(0)
        value <- sign(total) * exp(shift + log(abs(total)))
        if (value == 0) 
            return(NA_real_)
        max(min(d), min(max(d), value))
    }
    offset_prelim <- average(ok)
    if (!is.finite(offset_prelim)) {
        return(list(offset_prelim = offset_prelim, offset = NA_real_, residual = rep(NA_real_, length(diffs)), 
            retained = rep(FALSE, length(diffs)), n_retained = 0L, weighting = "none", contributing = rep(FALSE, 
                length(diffs)), screening_fallback = FALSE, status = "numerical_failure", reason = "The preliminary offset is not numerically representable."))
    }
    residual_prelim <- diffs - offset_prelim
    retained <- ok
    if (!is.null(drift_threshold) && is.finite(drift_threshold)) {
        retained <- retained & is.finite(residual_prelim) & abs(residual_prelim) <= drift_threshold
    }
    screening_fallback <- !any(retained)
    if (screening_fallback) {
        retained <- ok
    }
    weight_retained <- retained & weight_ok
    offset <- average(retained)
    residual <- diffs - offset
    residual[!is.finite(residual)] <- NA_real_
    list(offset_prelim = offset_prelim, offset = offset, residual = residual, retained = retained, n_retained = sum(retained, 
        na.rm = TRUE), weighting = if (any(weight_retained)) "inverse_variance" else "unweighted", contributing = if (any(weight_retained)) {
        weight_retained
    } else retained, screening_fallback = screening_fallback, status = if (is.finite(offset)) "computed" else "numerical_failure", 
        reason = if (!is.finite(offset)) {
            "The final offset is not numerically representable."
        } else if (screening_fallback) {
            "No row passed preliminary screening; all finite differences were used."
        } else NA_character_)
}

.summarise_link_support <- function(common_tbl, retained = NULL, guideline = 5L) {
    if (is.null(common_tbl) || nrow(common_tbl) == 0) {
        return(tibble::tibble(Facet = character(), N_Common = integer(), N_Retained = integer(), GuidelineMinCommon = integer(), 
            LinkSupportAdequate = logical()))
    }
    base_tbl <- tibble::as_tibble(common_tbl)[, c("Facet", "Level")]
    retained <- if (is.null(retained)) 
        rep(TRUE, nrow(base_tbl))
    else as.logical(retained)
    if (length(retained) != nrow(base_tbl)) {
        retained <- rep(FALSE, nrow(base_tbl))
    }
    common_counts <- dplyr::count(base_tbl, .data$Facet, name = "N_Common")
    retained_counts <- dplyr::count(base_tbl[retained, , drop = FALSE], .data$Facet, name = "N_Retained")
    dplyr::mutate(dplyr::left_join(common_counts, retained_counts, by = "Facet"), N_Retained = dplyr::coalesce(.data$N_Retained, 
        0L), GuidelineMinCommon = as.integer(guideline), LinkSupportAdequate = .data$N_Retained >= .data$GuidelineMinCommon)
}

.compute_drift <- function(fit, anchor_tbl, diagnostics = NULL, baseline_diagnostics = NULL) {
    new_est <- make_anchor_table(fit, include_person = FALSE, readiness_policy = "review")
    joined <- dplyr::inner_join(dplyr::rename(anchor_tbl, Baseline = "Anchor"), dplyr::rename(new_est, 
        New = "Anchor"), by = c("Facet", "Level"))
    if (nrow(joined) == 0) {
        return(tibble::tibble(Facet = character(), Level = character(), Baseline = numeric(), New = numeric(), 
            Drift = numeric(), SE_Baseline = numeric(), SE_New = numeric(), SE_Diff = numeric(), Drift_SE_Ratio = numeric(), 
            Flag = logical()))
    }
    baseline_se <- measure_se_table(fit = NULL, include_person = FALSE, diagnostics = baseline_diagnostics)
    new_se <- measure_se_table(fit, include_person = FALSE, diagnostics = diagnostics)
    joined <- dplyr::left_join(dplyr::left_join(joined, dplyr::rename(baseline_se, SE_Baseline = "SE"), 
        by = c("Facet", "Level")), dplyr::rename(new_se, SE_New = "SE"), by = c("Facet", "Level"))
    dplyr::arrange(dplyr::mutate(joined, Drift = .data$New - .data$Baseline, SE_Diff = .linking_difference_se(.data$SE_Baseline, 
        .data$SE_New), Drift_SE_Ratio = ifelse(is.na(.data$SE_Diff) | .data$SE_Diff == 0, NA_real_, abs(.data$Drift)/.data$SE_Diff), 
        Flag = abs(.data$Drift) > 0.5 | (!is.na(.data$Drift_SE_Ratio) & .data$Drift_SE_Ratio > 2)), dplyr::desc(abs(.data$Drift)))
}

anchor_to_baseline <- function(new_data, baseline_fit, person, facets, score, anchor_facets = NULL, include_person = FALSE, 
    weight = NULL, model = NULL, method = NULL, anchor_policy = "warn", mml_integration = NULL, centering_scope = NULL, 
    ...) {
    if (inherits(baseline_fit, "mfrm_fast_fit")) {
        if (is.null(model)) model <- baseline_fit$model
        if (is.null(method)) method <- baseline_fit$method
        anchor_tbl <- as.data.frame(make_anchor_table(baseline_fit, facets = anchor_facets, include_person = include_person))
        new_fit <- fit_mfrm(
            new_data, person = person, facets = facets, score = score, weight = weight,
            model = model, method = method, anchors = anchor_tbl, fast = TRUE, ...
        )
        unanc_fit <- fit_mfrm(
            new_data, person = person, facets = facets, score = score, weight = weight,
            model = model, method = method, fast = TRUE, warn_connectivity = FALSE, ...
        )
        m_idx <- match(paste0(anchor_tbl$Facet, ":", anchor_tbl$Level),
                       paste0(unanc_fit$facets$Facet, ":", unanc_fit$facets$Level))
        ok <- which(!is.na(m_idx))
        drift_df <- data.frame(
            Facet = anchor_tbl$Facet[ok],
            Level = anchor_tbl$Level[ok],
            Baseline = anchor_tbl$Anchor[ok],
            NewFree = unanc_fit$facets$Estimate[m_idx[ok]],
            SE_New = unanc_fit$facets$ModelSE[m_idx[ok]],
            stringsAsFactors = FALSE
        )
        drift_df$Drift <- drift_df$NewFree - drift_df$Baseline
        drift_df$SE_Diff <- drift_df$SE_New
        drift_df$Drift_SE_Ratio <- ifelse(drift_df$SE_Diff > 0, abs(drift_df$Drift) / drift_df$SE_Diff, NA_real_)
        drift_df$Flag <- abs(drift_df$Drift) > 0.5 | (!is.na(drift_df$Drift_SE_Ratio) & drift_df$Drift_SE_Ratio > 2.0)
        return(structure(
            list(fit = new_fit, diagnostics = diagnose_mfrm(new_fit), baseline_anchors = anchor_tbl, drift = drift_df),
            class = c("mfrm_anchored_fit", "list")
        ))
    }
    stopifnot(inherits(baseline_fit, "mfrm_fit"))
    if (is.null(model)) 
        model <- baseline_fit$config$model
    if (is.null(method)) 
        method <- baseline_fit$config$method
    if (is.null(centering_scope)) {
        centering_scope <- baseline_fit$config$centering_scope %||% "remainder"
    }
    if (is.null(mml_integration)) {
        mml_integration <- if (identical(toupper(method), "MML")) {
            baseline_fit$config$estimation_control$mml_integration %||% "fixed"
        }
        else "fixed"
    }
    anchor_tbl <- make_anchor_table(baseline_fit, facets = anchor_facets, include_person = include_person)
    if (nrow(anchor_tbl) == 0) {
        stop("No anchors could be extracted from the baseline fit.", call. = FALSE)
    }
    new_fit <- fit_mfrm(new_data, person = person, facets = facets, score = score, weight = weight, model = model, 
        method = method, anchors = anchor_tbl, anchor_policy = anchor_policy, mml_integration = mml_integration, 
        centering_scope = centering_scope, ...)
    baseline_diag <- diagnose_mfrm(baseline_fit)
    new_diag <- diagnose_mfrm(new_fit)
    drift <- .compute_drift(new_fit, anchor_tbl, diagnostics = new_diag, baseline_diagnostics = baseline_diag)
    out <- list(fit = new_fit, diagnostics = new_diag, baseline_anchors = anchor_tbl, drift = drift)
    class(out) <- c("mfrm_anchored_fit", "list")
    out
}

summary.mfrm_anchored_fit <- function(object, ...) {
    drift <- object$drift
    n_anchored <- nrow(object$baseline_anchors)
    n_common <- nrow(drift)
    n_flagged <- sum(drift$Flag, na.rm = TRUE)
    is_fast <- inherits(object$fit, "mfrm_fast_fit")
    out <- list(n_anchored = n_anchored, n_common = n_common, n_flagged = n_flagged, drift_summary = if (n_common > 
        0) {
        dplyr::summarise(dplyr::group_by(drift, .data$Facet), N = dplyr::n(), Mean_Drift = mean(abs(.data$Drift)), 
            Max_Drift = max(abs(.data$Drift)), N_Flagged = sum(.data$Flag, na.rm = TRUE), .groups = "drop")
    } else {
        tibble::tibble()
    }, flagged = dplyr::filter(drift, .data$Flag),
        converged = if (is_fast) isTRUE(object$fit$converged) else mfrm_inference_ready(object$fit),
        optimizer_code_zero = if (is_fast) isTRUE(object$fit$converged) else mfrm_convergence_state(object$fit)$code_converged, 
        convergence_status = if (is_fast) (if (isTRUE(object$fit$converged)) "converged" else "not_converged") else mfrm_convergence_state(object$fit)$status)
    class(out) <- "summary.mfrm_anchored_fit"
    out
}

detect_anchor_drift <- function(fits, facets = NULL, drift_threshold = 0.5, flag_se_ratio = 2, reference = 1L, 
    include_person = FALSE) {
    stopifnot(is.list(fits), length(fits) >= 2)
    if (any(vapply(fits, inherits, logical(1), "mfrm_fast_fit"))) {
        if (is.null(names(fits))) names(fits) <- paste0("Wave", seq_along(fits))
        ref_idx <- if (is.character(reference)) match(reference, names(fits)) else as.integer(reference)
        ref_f <- fits[[ref_idx]]
        ref_tbl <- ref_f$facets[, c("Facet", "Level", "Estimate", "ModelSE"), drop = FALSE]
        if (!is.null(facets)) ref_tbl <- ref_tbl[ref_tbl$Facet %in% facets, , drop = FALSE]
        rows <- list()
        for (w in setdiff(seq_along(fits), ref_idx)) {
            wf <- fits[[w]]$facets
            m <- match(paste0(ref_tbl$Facet, ":", ref_tbl$Level), paste0(wf$Facet, ":", wf$Level))
            ok <- which(!is.na(m))
            if (length(ok) == 0L) next
            d_val <- wf$Estimate[m[ok]] - ref_tbl$Estimate[ok]
            se_d <- sqrt(ref_tbl$ModelSE[ok]^2 + wf$ModelSE[m[ok]]^2)
            z_val <- ifelse(se_d > 0, d_val / se_d, NA_real_)
            rows[[length(rows) + 1L]] <- data.frame(
                Reference = names(fits)[ref_idx], Wave = names(fits)[w],
                Facet = ref_tbl$Facet[ok], Level = ref_tbl$Level[ok],
                EstRef = ref_tbl$Estimate[ok], EstWave = wf$Estimate[m[ok]],
                Drift = d_val, SE = se_d, z = z_val,
                pValue = 2 * stats::pnorm(-abs(z_val)),
                Flagged = abs(d_val) > drift_threshold | (!is.na(z_val) & abs(z_val) > flag_se_ratio),
                stringsAsFactors = FALSE
            )
        }
        tbl <- if (length(rows) > 0L) do.call(rbind, rows) else data.frame()
        return(structure(list(table = tbl, reference = names(fits)[ref_idx]), class = c("mfrm_anchor_drift", "mfrm_comparison")))
    }
    for (f in fits) stopifnot(inherits(f, "mfrm_fit"))
    if (is.null(names(fits))) 
        names(fits) <- paste0("Wave", seq_along(fits))
    drift_threshold <- .validate_linking_threshold(drift_threshold, "drift_threshold")
    flag_se_ratio <- .validate_linking_threshold(flag_se_ratio, "flag_se_ratio")
    valid_reference <- length(reference) == 1L && !is.na(reference) && ((is.character(reference) && sum(names(fits) == 
        reference) == 1L) || (is.numeric(reference) && is.finite(reference) && reference == floor(reference) && 
        reference >= 1 && reference <= length(fits)))
    if (!valid_reference) 
        stop("`reference` must identify one fit by a unique name or integer index.", call. = FALSE)
    ref_idx <- if (is.character(reference)) 
        match(reference, names(fits))
    else as.integer(reference)
    est_list <- lapply(fits, function(f) {
        make_anchor_table(f, facets = facets, include_person = include_person, readiness_policy = "review")
    })
    se_list <- lapply(fits, function(f) {
        measure_se_table(f, include_person = include_person)
    })
    ref_est <- est_list[[ref_idx]]
    wave_names <- names(fits)
    support_guideline <- 5L
    drift_rows <- list()
    support_rows <- list()
    for (i in seq_along(fits)) {
        if (i == ref_idx) 
            next
        wave_est <- est_list[[i]]
        ref_se <- se_list[[ref_idx]]
        wave_se <- se_list[[i]]
        joined <- dplyr::inner_join(dplyr::rename(ref_est, Ref_Est = "Anchor"), dplyr::rename(wave_est, 
            Wave_Est = "Anchor"), by = c("Facet", "Level"))
        if (nrow(joined) > 0) {
            joined <- dplyr::left_join(dplyr::left_join(joined, dplyr::rename(ref_se, SE_Ref = "SE"), 
                by = c("Facet", "Level")), dplyr::rename(wave_se, SE_Wave = "SE"), by = c("Facet", "Level"))
            offset_info <- compute_equating_offset(diffs = joined$Wave_Est - joined$Ref_Est, se_from = joined$SE_Ref, 
                se_to = joined$SE_Wave, drift_threshold = drift_threshold)
            support_tbl <- dplyr::mutate(.summarise_link_support(joined[, c("Facet", "Level"), drop = FALSE], 
                retained = offset_info$retained, guideline = support_guideline), Reference = wave_names[ref_idx], 
                Wave = wave_names[i], .before = 1)
            support_rows <- c(support_rows, list(support_tbl))
            link_support_ok <- nrow(support_tbl) > 0 && all(support_tbl$LinkSupportAdequate)
            if (!link_support_ok) {
                weak_rows <- support_tbl[!support_tbl$LinkSupportAdequate, , drop = FALSE]
                weak_detail <- if ("CommonElements" %in% names(weak_rows)) {
                  paste0(weak_rows$Facet, " (", weak_rows$CommonElements, "/", support_guideline, ")")
                }
                else {
                  as.character(weak_rows$Facet)
                }
                warning(sprintf("Thin linking support between '%s' and '%s': fewer than %d retained common elements in %s.", 
                  wave_names[ref_idx], wave_names[i], support_guideline, paste(weak_detail, collapse = ", ")), 
                  call. = FALSE)
            }
            joined <- dplyr::mutate(joined, Reference = wave_names[ref_idx], Wave = wave_names[i], LinkOffset = offset_info$offset, 
                OffsetStatus = offset_info$status, OffsetReason = offset_info$reason, ScreeningFallback = offset_info$screening_fallback, 
                N_Contributing = sum(offset_info$contributing), Contributing = offset_info$contributing, 
                Retained = offset_info$retained, Drift = offset_info$residual, SE = .linking_difference_se(.data$SE_Ref, 
                  .data$SE_Wave), Drift_SE_Ratio = ifelse(is.na(.data$SE) | .data$SE == 0, NA_real_, 
                  abs(.data$Drift)/.data$SE), SERatioStatus = dplyr::case_when(!is.finite(.data$Drift) ~ 
                  "drift_unavailable", !is.finite(.data$SE) | .data$SE <= 0 ~ "paired_se_unavailable", 
                  !is.finite(.data$Drift_SE_Ratio) ~ "ratio_unrepresentable", TRUE ~ "available"), Drift_SE_Ratio = ifelse(is.finite(.data$Drift_SE_Ratio), 
                  .data$Drift_SE_Ratio, NA_real_), FlagBasis = ifelse(!is.finite(.data$Drift), "unavailable", 
                  ifelse(is.finite(.data$Drift_SE_Ratio), "magnitude_and_se_ratio", "magnitude_only")), 
                LinkSupportAdequate = link_support_ok, Flag = abs(.data$Drift) > drift_threshold | (!is.na(.data$Drift_SE_Ratio) & 
                  .data$Drift_SE_Ratio > flag_se_ratio))
            drift_rows <- c(drift_rows, list(joined))
        }
    }
    drift_table <- if (length(drift_rows) > 0) {
        dplyr::arrange(dplyr::select(dplyr::bind_rows(drift_rows), "Facet", "Level", "Reference", "Wave", 
            "Ref_Est", "Wave_Est", "LinkOffset", "Drift", "SE_Ref", "SE_Wave", "SE", "Drift_SE_Ratio", 
            "LinkSupportAdequate", "Flag", "OffsetStatus", "OffsetReason", "ScreeningFallback", "N_Contributing", 
            "Contributing", "Retained", "SERatioStatus", "FlagBasis"), dplyr::desc(abs(.data$Drift)))
    }
    else {
        tibble::tibble(Facet = character(), Level = character(), Reference = character(), Wave = character(), 
            Ref_Est = numeric(), Wave_Est = numeric(), LinkOffset = numeric(), Drift = numeric(), SE_Ref = numeric(), 
            SE_Wave = numeric(), SE = numeric(), Drift_SE_Ratio = numeric(), LinkSupportAdequate = logical(), 
            Flag = logical(), OffsetStatus = character(), OffsetReason = character(), ScreeningFallback = logical(), 
            N_Contributing = integer(), Contributing = logical(), Retained = logical(), SERatioStatus = character(), 
            FlagBasis = character())
    }
    drift_summary <- if (nrow(drift_table) > 0) {
        dplyr::summarise(dplyr::group_by(drift_table, .data$Facet, .data$Wave), N = dplyr::n(), Mean_Drift = mean(abs(.data$Drift)), 
            Max_Drift = max(abs(.data$Drift)), N_Flagged = if (anyNA(.data$Flag)) 
                NA_integer_
            else sum(.data$Flag), N_FlaggedAvailable = sum(.data$Flag, na.rm = TRUE), N_Unavailable = sum(is.na(.data$Flag)), 
            .groups = "drop")
    }
    else {
        tibble::tibble()
    }
    common_counts <- tibble::tibble(Wave1 = character(), Wave2 = character(), N_Common = integer())
    for (i in seq_along(fits)) {
        for (j in seq_along(fits)) {
            if (j <= i) 
                next
            n_common <- nrow(dplyr::inner_join(est_list[[i]], est_list[[j]], by = c("Facet", "Level")))
            common_counts <- dplyr::bind_rows(common_counts, tibble::tibble(Wave1 = wave_names[i], Wave2 = wave_names[j], 
                N_Common = as.integer(n_common)))
        }
    }
    common_vs_reference <- if (length(fits) >= 2L) {
        ref_table <- do.call(rbind, lapply(seq_along(fits), function(i) {
            if (i == ref_idx) 
                return(NULL)
            n_common <- nrow(dplyr::inner_join(est_list[[ref_idx]], est_list[[i]], by = c("Facet", "Level")))
            data.frame(Reference = wave_names[ref_idx], Wave = wave_names[i], N_Common = as.integer(n_common), 
                stringsAsFactors = FALSE)
        }))
        if (is.null(ref_table)) {
            data.frame(Reference = character(0), Wave = character(0), N_Common = integer(0), stringsAsFactors = FALSE)
        }
        else {
            ref_table
        }
    }
    else {
        data.frame(Reference = character(0), Wave = character(0), N_Common = integer(0), stringsAsFactors = FALSE)
    }
    n_common_all_waves <- if (length(est_list) >= 2L) {
        shared <- Reduce(function(a, b) dplyr::inner_join(a, b, by = c("Facet", "Level")), lapply(est_list, 
            function(e) e[, c("Facet", "Level")]))
        as.integer(nrow(shared))
    }
    else NA_integer_
    out <- list(drift_table = drift_table, summary = drift_summary, common_elements = common_counts, 
        common_vs_reference = common_vs_reference, n_common_all_waves = n_common_all_waves, common_by_facet = if (length(support_rows) > 
            0) dplyr::bind_rows(support_rows) else tibble::tibble(), config = list(reference = wave_names[ref_idx], 
            calculation_version = 2L, method = "screened_common_element_alignment", intended_use = "review_screen", 
            models = unique(stats::na.omit(vapply(fits, function(f) {
                as.character(f$config$model %||% f$summary$Model[1] %||% NA_character_)
            }, character(1)))), drift_threshold = drift_threshold, min_common_per_facet = support_guideline, 
            flag_se_ratio = flag_se_ratio, facets = facets, waves = wave_names))
    class(out) <- c("mfrm_anchor_drift", "list")
    out
}

summary.mfrm_anchor_drift <- function(object, ...) {
    dt <- object$drift_table
    out <- list(n_comparisons = nrow(dt), n_flagged = if (anyNA(dt$Flag)) NA_integer_ else sum(dt$Flag), 
        n_flagged_available = sum(dt$Flag, na.rm = TRUE), n_unavailable = sum(is.na(dt$Flag)), summary = object$summary, 
        common_elements = object$common_elements, common_by_facet = object$common_by_facet, flagged = dplyr::filter(dt, 
            .data$Flag), config = object$config)
    class(out) <- "summary.mfrm_anchor_drift"
    out
}












