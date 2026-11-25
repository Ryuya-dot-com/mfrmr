summary.mfrm_imported_fit <- function(object, ...) object

print.mfrm_bundle <- function(x, ...) {
    cat(sprintf("<%s>\n", class(x)[1L]))
    if (is.data.frame(x$table)) 
        print(utils::head(x$table, 20L), row.names = FALSE)
    else if (is.data.frame(x$stacked)) 
        print(utils::head(x$stacked, 20L), row.names = FALSE)
    invisible(x)
}


summary.mfrm_bundle <- function(object, ...) object

print_bundle_section <- function(title, table, digits = 3, round_numeric = TRUE) {
    if (is.null(table) || !is.data.frame(table) || nrow(table) == 0) 
        return(invisible(NULL))
    cat("\n", title, "\n", sep = "")
    if (isTRUE(round_numeric)) {
        print(round_numeric_df(as.data.frame(table), digits = digits), row.names = FALSE)
    }
    else {
        print(as.data.frame(table), row.names = FALSE)
    }
    invisible(NULL)
}

collect_mfrm_population_caveats <- function(population_overview = NULL, population_design = NULL, population_coefficients = NULL) {
    out <- empty_mfrm_caveats
    population_overview <- as.data.frame(population_overview %||% data.frame(), stringsAsFactors = FALSE)
    population_design <- as.data.frame(population_design %||% data.frame(), stringsAsFactors = FALSE)
    population_coefficients <- as.data.frame(population_coefficients %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(population_overview) == 0L || !"PopulationModel" %in% names(population_overview) || !isTRUE(population_overview$PopulationModel[1])) {
        return(out)
    }
    add_caveat <- function(severity, condition, details, message, action) {
        out <<- rbind(out, data.frame(Area = "population_model", Severity = severity, Condition = condition, 
            Categories = "", CategoryType = "", Message = message, RecommendedAction = action, Details = details, 
            stringsAsFactors = FALSE))
        invisible(NULL)
    }
    omitted_persons <- suppressWarnings(as.integer(population_overview$OmittedPersons[1] %||% 0L))
    omitted_rows <- suppressWarnings(as.integer(population_overview$OmittedRows[1] %||% NA_integer_))
    if (is.finite(omitted_persons) && omitted_persons > 0L) {
        add_caveat(severity = "warning", condition = "population_complete_case_omission", details = paste0("OmittedPersons=", 
            omitted_persons, "; OmittedRows=", omitted_rows), message = paste0("Latent-regression fit omitted ", 
            omitted_persons, " person(s) and ", if (is.finite(omitted_rows)) 
                omitted_rows
            else NA_integer_, " response row(s) under the population-data policy."), action = "Document the complete-case policy and verify that omitted persons do not change the intended estimation population.")
    }
    if (nrow(population_design) > 0L && all(c("Column", "IsIntercept", "ZeroVariance") %in% names(population_design))) {
        is_intercept <- as.logical(population_design$IsIntercept %||% FALSE)
        zero_variance <- as.logical(population_design$ZeroVariance %||% FALSE)
        flagged <- population_design$Column[zero_variance & !is_intercept]
        flagged <- flagged[!is.na(flagged) & nzchar(as.character(flagged))]
        if (length(flagged) > 0L) {
            add_caveat(severity = "warning", condition = "population_design_zero_variance", details = paste(as.character(flagged), 
                collapse = ", "), message = paste0("Latent-regression design matrix contains non-intercept zero-variance column(s): ", 
                paste(as.character(flagged), collapse = ", "), "."), action = "Remove or recode zero-variance background variables before interpreting population-model coefficients.")
        }
    }
    if (nrow(population_design) > 0L && all(c("Column", "Complete") %in% names(population_design))) {
        incomplete <- population_design$Column[!as.logical(population_design$Complete %||% TRUE)]
        incomplete <- incomplete[!is.na(incomplete) & nzchar(as.character(incomplete))]
        if (length(incomplete) > 0L) {
            add_caveat(severity = "warning", condition = "population_design_incomplete", details = paste(as.character(incomplete), 
                collapse = ", "), message = paste0("Latent-regression design matrix still has incomplete column(s): ", 
                paste(as.character(incomplete), collapse = ", "), "."), action = "Review `population_policy`, person-level background data, and complete-case filtering before reporting the population model.")
        }
    }
    residual_variance <- suppressWarnings(as.numeric(population_overview$ResidualVariance[1] %||% NA_real_))
    if (!is.finite(residual_variance) || residual_variance <= 0) {
        add_caveat(severity = "warning", condition = "population_residual_variance_unstable", details = paste0("ResidualVariance=", 
            residual_variance), message = "Latent-regression residual variance is non-finite or non-positive.", 
            action = "Review population-model convergence and covariate design before using population-model posterior scoring.")
    }
    if (nrow(population_coefficients) == 0L) {
        add_caveat(severity = "warning", condition = "population_coefficients_missing", details = "", 
            message = "Population model is marked active but no population coefficients are available in the summary.", 
            action = "Inspect `fit$population$coefficients` before reporting latent-regression effects.")
    }
    out
}

format_population_coding_value <- function(x) {
    if (is.null(x) || length(x) == 0L) 
        return("")
    if (is.function(x)) 
        return("<function>")
    if (is.matrix(x) || is.data.frame(x)) {
        return(paste0(class(x)[1], "[", nrow(x), "x", ncol(x), "]"))
    }
    vals <- as.character(x)
    vals <- vals[!is.na(vals) & nzchar(vals)]
    if (length(vals) == 0L) 
        return("")
    paste(vals, collapse = ", ")
}

population_coding_summary_table <- function(population) {
    population <- population %||% list()
    xlevels <- population$xlevels %||% list()
    contrasts <- population$contrasts %||% list()
    if (is.null(xlevels)) 
        xlevels <- list()
    if (!is.list(xlevels)) {
        xlevel_names <- names(xlevels)
        xlevels <- as.list(xlevels)
        names(xlevels) <- xlevel_names
    }
    if (is.null(contrasts)) 
        contrasts <- list()
    if (!is.list(contrasts)) {
        contrast_names <- names(contrasts)
        contrasts <- as.list(contrasts)
        names(contrasts) <- contrast_names
    }
    xlevel_names <- names(xlevels) %||% character(0)
    contrast_names <- names(contrasts) %||% character(0)
    vars <- unique(c(xlevel_names[nzchar(xlevel_names)], contrast_names[nzchar(contrast_names)]))
    if (length(vars) == 0L) {
        return(tibble::tibble(Variable = character(0), LevelCount = integer(0), Levels = character(0), 
            Contrast = character(0), EncodedColumns = character(0), CodingNote = character(0)))
    }
    design_columns <- as.character(population$design_columns %||% character(0))
    if (length(design_columns) == 0L && !is.null(population$design_matrix)) {
        design_columns <- as.character(colnames(population$design_matrix) %||% character(0))
    }
    design_columns <- design_columns[!is.na(design_columns) & nzchar(design_columns)]
    encoded_columns <- vapply(vars, function(var) {
        cols <- design_columns[design_columns == var | startsWith(design_columns, var)]
        paste(cols, collapse = ", ")
    }, character(1))
    level_text <- vapply(vars, function(var) format_population_coding_value(xlevels[[var]]), character(1))
    level_count <- vapply(vars, function(var) length(xlevels[[var]] %||% character(0)), integer(1))
    contrast_text <- vapply(vars, function(var) format_population_coding_value(contrasts[[var]]), character(1))
    has_xlevels <- nzchar(level_text)
    has_contrasts <- nzchar(contrast_text)
    tibble::tibble(Variable = as.character(vars), LevelCount = as.integer(level_count), Levels = level_text, 
        Contrast = contrast_text, EncodedColumns = encoded_columns, CodingNote = dplyr::case_when(has_xlevels & 
            has_contrasts ~ "stored levels and contrast", has_xlevels ~ "stored levels", has_contrasts ~ 
            "stored contrast", TRUE ~ "not recorded"))
}

summary.mfrm_diagnostics <- function(object, digits = 3, top_n = 10, detail = c("brief", "full"), include_person = FALSE, 
    ..., lower = NULL, upper = NULL) {
    if (!is.list(object) || is.null(object$obs)) {
        stop("`object` must be output from diagnose_mfrm().")
    }
    validate_diagnostics_precision(object)
    validate_marginal_coverage(object$marginal_fit)
    digits <- max(0L, as.integer(digits))
    top_n <- max(1L, as.integer(top_n))
    detail <- match.arg(detail)
    include_person <- isTRUE(include_person)
    obs_tbl <- tibble::as_tibble(object$obs)
    fit_tbl <- tibble::as_tibble(object$fit %||% tibble::tibble())
    misfit_thresholds <- mfrm_misfit_thresholds(lower, upper)
    fit_screening <- fit_screening_summary(fit_tbl, misfit_thresholds)
    reliability_tbl <- tibble::as_tibble(object$reliability %||% tibble::tibble())
    precision_profile_tbl <- tibble::as_tibble(object$precision_profile %||% tibble::tibble())
    precision_review_tbl <- tibble::as_tibble(precision_review(object, required = FALSE) %||% tibble::tibble())
    overall_fit <- tibble::as_tibble(object$overall_fit %||% tibble::tibble())
    subset_summary <- tibble::as_tibble(object$subsets$summary %||% tibble::tibble())
    approximation_tbl <- tibble::as_tibble(object$approximation_notes %||% tibble::tibble())
    diagnostic_basis_tbl <- tibble::as_tibble(object$diagnostic_basis %||% tibble::tibble())
    fit_standardization_tbl <- tibble::as_tibble(object$fit_standardization %||% tibble::tibble())
    marginal_fit_tbl <- tibble::as_tibble(object$marginal_fit$summary %||% tibble::tibble())
    marginal_coverage <- object$marginal_fit$coverage %||% data.frame()
    marginal_step_summary <- tibble::as_tibble(object$marginal_fit$step_or_scale$summary_stats %||% tibble::tibble())
    marginal_facet_summary <- tibble::as_tibble(object$marginal_fit$facet_level$summary_stats %||% tibble::tibble())
    marginal_top_cells <- tibble::as_tibble(object$marginal_fit$top_cells %||% tibble::tibble())
    marginal_pairwise_tbl <- tibble::as_tibble(object$marginal_fit$pairwise$facet_summary %||% tibble::tibble())
    marginal_top_pairs_src <- tibble::as_tibble(object$marginal_fit$pairwise$top_pairs %||% tibble::tibble())
    marginal_guidance_tbl <- tibble::as_tibble(object$marginal_fit$guidance %||% tibble::tibble())
    interrater_summary_tbl <- tibble::as_tibble(object$interrater$summary %||% tibble::tibble())
    facets_chisq_tbl <- tibble::as_tibble(object$facets_chisq %||% tibble::tibble())
    marginal_available <- isTRUE(object$marginal_fit$available)
    marginal_pairwise_available <- isTRUE(object$marginal_fit$pairwise$available)
    fair_average_tbl <- tibble::as_tibble(object$fair_average$stacked %||% tibble::tibble())
    fair_average_status <- as.character(object$fair_average$status %||% if (nrow(fair_average_tbl) > 
        0L) "embedded_available" else "not_available")[1L]
    diagnostic_mode <- as.character(object$diagnostic_mode %||% "legacy")
    fit_readiness_tbl <- tibble::as_tibble(mfrmr_get_readiness_record(object)$fit)
    fit_readiness_components_tbl <- tibble::as_tibble(object$fit_readiness_components %||% data.frame())
    fit_readiness_parameters_tbl <- tibble::as_tibble(object$fit_readiness_parameters %||% data.frame())
    fit_readiness_known <- nrow(fit_readiness_tbl) == 1L && all(c("FitReadiness", "InferenceReady") %in% 
        names(fit_readiness_tbl))
    source_fit_state <- if (fit_readiness_known) {
        as.character(fit_readiness_tbl$FitReadiness[1])
    }
    else {
        "not_available"
    }
    source_inference_ready <- fit_readiness_known && isTRUE(fit_readiness_tbl$InferenceReady[1])
    if (!source_inference_ready && nrow(precision_profile_tbl) > 0L && !inherits(object, "mfrm_imported_diagnostics")) {
        precision_profile_tbl$InferenceReady <- FALSE
        precision_profile_tbl$SupportsFormalInference <- FALSE
        precision_profile_tbl$RecommendedUse <- "Diagnostic review only; ordinary inference is unavailable under the fit-readiness contract."
        precision_profile_tbl$CIBasis <- "Diagnostic normal bands only"
        precision_profile_tbl$ReliabilityBasis <- "Descriptive variance decomposition only"
    }
    source_fit_label <- switch(source_fit_state, ready = "ready; fit-readiness requirements satisfied, with formal precision evaluated separately", 
        ready_with_exclusions = "ready with exclusions; review parameter eligibility", review = "review required; formal inference is not ready", 
        blocked = "blocked; formal inference is not ready", legacy_unknown = "legacy readiness unknown; refit or re-audit required", 
        "readiness not available")
    n_obs <- nrow(obs_tbl)
    n_person <- if ("Person" %in% names(obs_tbl)) 
        dplyr::n_distinct(obs_tbl$Person)
    else NA_integer_
    n_cat <- if ("Observed" %in% names(obs_tbl)) 
        dplyr::n_distinct(obs_tbl$Observed)
    else NA_integer_
    n_subsets <- if ("Subset" %in% names(subset_summary)) 
        dplyr::n_distinct(subset_summary$Subset)
    else 0L
    overview <- tibble::tibble(Observations = n_obs, Persons = n_person, Facets = length(object$facet_names %||% 
        character(0)), Categories = n_cat, Subsets = n_subsets, ResidualPCA = as.character(object$residual_pca_mode %||% 
        "none"), DiagnosticMode = diagnostic_mode, Method = resolve_public_mfrm_method(summary_method = precision_profile_tbl$Method[1] %||% 
        NA_character_), PrecisionTier = as.character(precision_profile_tbl$PrecisionTier[1] %||% NA_character_), 
        MarginalFit = if (marginal_available && any(marginal_coverage$Unclassified > 0L)) 
            "partly_classified"
        else if (marginal_available) 
            "available"
        else "not_available", FairAverage = fair_average_status)
    reliability_overview <- tibble::tibble()
    keep_rel <- c("Facet", "Levels", "EstimateAvailable", "SEAvailable", "ModelSEAvailable", "RealSEAvailable", 
        "Separation", "Strata", "Reliability", "RealSeparation", "RealStrata", "RealReliability", "MeanInfit", 
        "MeanOutfit", "ModelSeparation", "ModelReliability", "ModelStrata", "ReliabilityBasis", "ReliabilityUse", 
        "SupportsFormalInference", "SourceSupportsFormalInference", "ModelSummaryNote", "RealSummaryNote", 
        "SummaryNote")
    if (nrow(reliability_tbl) > 0) {
        keep <- intersect(keep_rel, names(reliability_tbl))
        reliability_overview <- dplyr::arrange(dplyr::select(reliability_tbl, dplyr::all_of(keep)), .data$Facet)
    }
    top_fit <- tibble::tibble()
    fit_need <- c("Facet", "Level", "Infit", "Outfit", "InfitZSTD", "OutfitZSTD")
    if (nrow(fit_tbl) > 0 && all(fit_need %in% names(fit_tbl))) {
        top_keep <- intersect(c("Facet", "Level", "Infit", "Outfit", "InfitZSTD", "OutfitZSTD", "DF_Infit", 
            "DF_Outfit", "InfitZSTD_FACETS", "OutfitZSTD_FACETS", "DF_Infit_FACETS", "DF_Outfit_FACETS"), 
            names(fit_tbl))
        top_fit <- dplyr::select(dplyr::slice_head(dplyr::arrange(dplyr::filter(dplyr::mutate(fit_tbl, 
            AbsZ = fit_screening$max_abs_z), is.finite(.data$AbsZ)), dplyr::desc(.data$AbsZ)), n = top_n), 
            dplyr::all_of(top_keep), "AbsZ")
    }
    misfit_lower <- as.numeric(misfit_thresholds["lower"])
    misfit_upper <- as.numeric(misfit_thresholds["upper"])
    misfit_flagged <- tibble::tibble()
    if (nrow(fit_tbl) > 0 && all(c("Facet", "Level", "Infit", "Outfit") %in% names(fit_tbl))) {
        misfit_flagged <- dplyr::filter(fit_tbl, fit_screening$flags$MeanSquare %in% TRUE)
    }
    category_usage <- tibble::tibble()
    if (nrow(obs_tbl) > 0 && all(c("Person", "Observed") %in% names(obs_tbl))) {
        person_measure <- if (!is.null(object$measures) && all(c("Facet", "Level", "Estimate") %in% names(object$measures))) {
            m <- as.data.frame(object$measures, stringsAsFactors = FALSE)
            m <- m[m$Facet == "Person", c("Level", "Estimate"), drop = FALSE]
            stats::setNames(suppressWarnings(as.numeric(m$Estimate)), m$Level)
        }
        else {
            numeric(0)
        }
        obs_local <- obs_tbl
        if (length(person_measure) > 0L) {
            obs_local$.PersonMeasure <- as.numeric(person_measure[as.character(obs_local$Person)])
        }
        else {
            obs_local$.PersonMeasure <- NA_real_
        }
        category_usage <- dplyr::arrange(dplyr::summarize(dplyr::group_by(obs_local, Category = .data$Observed), 
            Count = dplyr::n(), AvgMeasure = mean(.data$.PersonMeasure, na.rm = TRUE), .groups = "drop"), 
            .data$Category)
        if (nrow(category_usage) > 1) {
            avg <- category_usage$AvgMeasure
            category_usage$Disordering <- ifelse(is.finite(avg) & c(FALSE, diff(avg) < 0), "AvgMeasure decreases vs previous category", 
                "")
        }
        else if (nrow(category_usage) == 1L) {
            category_usage$Disordering <- ""
        }
    }
    top_marginal_cells <- tibble::tibble()
    if (nrow(marginal_top_cells) > 0) {
        keep_marginal <- intersect(c("CellType", "StepFacet", "Facet", "Level", "Category", "ObservedCount", 
            "ExpectedCount", "PropDiff", "StdResidual", "AbsStdResidual"), names(marginal_top_cells))
        top_marginal_cells <- dplyr::select(dplyr::slice_head(marginal_top_cells, n = top_n), dplyr::all_of(keep_marginal))
    }
    top_marginal_pairs <- tibble::tibble()
    if (nrow(marginal_top_pairs_src) > 0) {
        keep_pairwise <- intersect(c("Facet", "Level1", "Level2", "LevelPairCount", "AvailableContextPairs", 
            "UnavailableContextPairs", "OpportunityWeight", "ExactAgreement", "ExpectedExactAgreement", 
            "ExactGap", "ExactStdResidual", "AdjacentAgreement", "ExpectedAdjacentAgreement", "AdjacentGap", 
            "AdjacentStdResidual", "Flagged"), names(marginal_top_pairs_src))
        top_marginal_pairs <- dplyr::select(dplyr::slice_head(marginal_top_pairs_src, n = top_n), dplyr::all_of(keep_pairwise))
    }
    unexpected_n <- suppressWarnings(as.integer(object$unexpected$summary$UnexpectedN[1] %||% NA_integer_))
    displacement_flagged <- suppressWarnings(as.integer(object$displacement$summary$FlaggedLevels[1] %||% 
        NA_integer_))
    interaction_n <- if (!is.null(object$interactions)) 
        nrow(object$interactions)
    else NA_integer_
    interrater_pairs <- suppressWarnings(as.integer(object$interrater$summary$Pairs[1] %||% NA_integer_))
    marginal_flagged_groups <- if (marginal_available) {
        marginal_flag_coverage(c(marginal_step_summary$Flagged, marginal_facet_summary$Flagged), "Groups")$Flagged
    }
    else {
        NA_integer_
    }
    marginal_flagged_pairs <- if (marginal_pairwise_available) {
        marginal_flag_coverage(object$marginal_fit$pairwise$pair_stats$Flagged, "Level pairs")$Flagged
    }
    else {
        NA_integer_
    }
    flags <- tibble::tibble(Metric = c("Unexpected responses", "Flagged displacement levels", "Interaction rows", 
        "Inter-rater pairs", "Marginal fit flagged groups", "Marginal pairwise flagged level pairs"), 
        Count = c(unexpected_n, displacement_flagged, interaction_n, interrater_pairs, marginal_flagged_groups, 
            marginal_flagged_pairs))
    precision_tier <- as.character(precision_profile_tbl$PrecisionTier[1] %||% NA_character_)
    strict_path_status <- if (marginal_available) {
        if (any(marginal_coverage$Unclassified > 0L)) 
            "partly_classified"
        else "available"
    }
    else if (identical(diagnostic_mode, "legacy")) {
        "not_requested"
    }
    else {
        "requested_not_available"
    }
    primary_screen <- dplyr::case_when(identical(diagnostic_mode, "both") && marginal_available ~ "Review marginal classification coverage alongside the available residual diagnostics.", 
        identical(diagnostic_mode, "marginal_fit") && marginal_available ~ "Review category and pairwise residuals together with their classification coverage.", 
        identical(diagnostic_mode, "legacy") ~ "Legacy residual diagnostics only; no strict marginal screen was requested.", 
        TRUE ~ "Requested strict marginal fit is not available for this run; fall back to the legacy path with caution.")
    key_warnings <- character(0)
    if (fit_readiness_known && !source_inference_ready) {
        key_warnings <- c(key_warnings, paste0("Source fit review: ", source_fit_label, ". Ordinary inference is unavailable; diagnostic outputs require review."))
    }
    else if (!fit_readiness_known) {
        key_warnings <- c(key_warnings, "Source-fit readiness is unavailable; do not use diagnostics to infer that the fit satisfied its numerical and identification criteria.")
    }
    if (nrow(precision_review_tbl) > 0 && "Status" %in% names(precision_review_tbl)) {
        flagged_checks <- dplyr::filter(precision_review_tbl, .data$Status %in% c("review", "warn"))
        if (nrow(flagged_checks) > 0) {
            key_warnings <- c(key_warnings, paste0("Precision review flagged ", nrow(flagged_checks), 
                " review/warn checks."))
        }
    }
    if (isTRUE(n_subsets > 1L)) {
        key_warnings <- c(key_warnings, "Multiple disconnected subsets were detected.")
    }
    if (isTRUE(!is.na(unexpected_n) && unexpected_n > 0L)) {
        key_warnings <- c(key_warnings, paste0("Unexpected responses flagged: ", unexpected_n, "."))
    }
    if (isTRUE(!is.na(displacement_flagged) && displacement_flagged > 0L)) {
        key_warnings <- c(key_warnings, paste0("Flagged displacement levels: ", displacement_flagged, 
            "."))
    }
    if (nrow(misfit_flagged) > 0) {
        person_misfit <- if ("Facet" %in% names(misfit_flagged)) {
            sum(as.character(misfit_flagged$Facet) == "Person", na.rm = TRUE)
        }
        else {
            0L
        }
        warning_rows <- if (!include_person && "Facet" %in% names(misfit_flagged)) {
            misfit_flagged[as.character(misfit_flagged$Facet) != "Person", , drop = FALSE]
        }
        else {
            misfit_flagged
        }
        worst <- dplyr::slice_head(dplyr::arrange(dplyr::mutate(warning_rows, UnderfitPriority = (is.finite(.data$Infit) & 
            .data$Infit > misfit_upper) | (is.finite(.data$Outfit) & .data$Outfit > misfit_upper), WorstMnSq = pmax(ifelse(is.finite(.data$Outfit), 
            abs(log(pmax(.data$Outfit, 1e-06))), 0), ifelse(is.finite(.data$Infit), abs(log(pmax(.data$Infit, 
            1e-06))), 0), na.rm = TRUE)), dplyr::desc(.data$UnderfitPriority), dplyr::desc(.data$WorstMnSq)), 
            n = 3L)
        msgs <- if (nrow(worst) > 0L) 
            vapply(seq_len(nrow(worst)), function(i) {
                sprintf("MnSq follow-up: %s:%s (Infit=%s, Outfit=%s; outside the configured %s-%s screening band).", 
                  worst$Facet[i], worst$Level[i], format_fit_mnsq(worst$Infit[i], misfit_thresholds), 
                  format_fit_mnsq(worst$Outfit[i], misfit_thresholds), format_fit_bound(misfit_lower), 
                  format_fit_bound(misfit_upper))
            }, character(1))
        else character(0)
        key_warnings <- c(key_warnings, sprintf("MnSq screening flagged %d element(s) outside the configured %s-%s band.", 
            nrow(misfit_flagged), format_fit_bound(misfit_lower), format_fit_bound(misfit_upper)), if (!include_person && 
            person_misfit > 0L) {
            paste0("Person-level fit warnings: ", person_misfit, " row(s); identifiers suppressed. Use `include_person = TRUE` only under appropriate privacy controls.")
        } else {
            character(0)
        }, msgs)
    }
    if (isTRUE(marginal_available) && isTRUE(!is.na(marginal_flagged_groups) && marginal_flagged_groups > 
        0L)) {
        key_warnings <- c(key_warnings, paste0("Strict marginal fit flagged ", marginal_flagged_groups, 
            " group-level summaries."))
    }
    if (isTRUE(marginal_pairwise_available) && isTRUE(!is.na(marginal_flagged_pairs) && marginal_flagged_pairs > 
        0L)) {
        key_warnings <- c(key_warnings, paste0("Strict pairwise local dependence flagged ", marginal_flagged_pairs, 
            " level pairs."))
    }
    if (!marginal_available && !identical(diagnostic_mode, "legacy") && nrow(marginal_fit_tbl) > 0 && 
        "Reason" %in% names(marginal_fit_tbl)) {
        key_warnings <- c(key_warnings, as.character(marginal_fit_tbl$Reason[1]))
    }
    if (nrow(marginal_coverage) && any(marginal_coverage$Unclassified > 0L)) {
        key_warnings <- c("Some marginal classifications are unavailable; inspect the coverage counts before interpreting flags.", 
            key_warnings)
    }
    incomplete_screens <- which(fit_screening$counts$IncompleteStatistics > 0L | fit_screening$counts$Elements == 
        0L)
    if (length(incomplete_screens)) {
        key_warnings <- c(vapply(incomplete_screens, function(i) {
            fit_screening_note(fit_screening$counts[i, ])
        }, character(1)), key_warnings)
    }
    key_warnings <- clean_summary_lines(key_warnings, max_n = 5L)
    if (length(key_warnings) == 0) {
        key_warnings <- "No immediate warnings from diagnostics summary."
    }
    next_actions <- c("Inspect `diagnostic_basis` before comparing legacy residual evidence with strict marginal evidence.")
    if (!source_inference_ready) {
        next_actions <- c("Inspect `summary(fit)$readiness` and resolve the source-fit readiness issues before interpreting diagnostic magnitudes substantively.", 
            next_actions)
    }
    if (!identical(as.character(precision_profile_tbl$Method[1] %||% NA_character_), "MML")) {
        next_actions <- c(next_actions, "MML provides marginal diagnostics; review the resulting fit and uncertainty assumptions before using its SEs or intervals.")
    }
    if (marginal_available) {
        next_actions <- c(next_actions, "Review `top_marginal_cells` and `rating_scale_table(..., diagnostics = diag)` for first-order strict marginal follow-up.")
    }
    if (marginal_pairwise_available) {
        next_actions <- c(next_actions, "Review `top_marginal_pairs` for pairwise local-dependence follow-up.")
    }
    if (isTRUE(!is.na(unexpected_n) && unexpected_n > 0L) || isTRUE(!is.na(displacement_flagged) && displacement_flagged > 
        0L)) {
        next_actions <- c(next_actions, "Use `unexpected_response_table()` / `plot(x, type = \"unexpected\")` and `displacement_table()` / `plot(x, type = \"displacement\")` for case-level follow-up.")
    }
    if (!identical(as.character(object$residual_pca_mode %||% "none"), "none")) {
        next_actions <- c(next_actions, "Use `analyze_residual_pca()` if residual structure needs deeper follow-up.")
    }
    next_actions <- clean_summary_lines(next_actions, max_n = 4L)
    decision <- mfrm_fit_decision_summary(fit_readiness_tbl, next_action = next_actions[1L] %||% NA_character_, 
        supports_formal_inference = if (nrow(precision_profile_tbl) > 0L) {
            isTRUE(precision_profile_tbl$SupportsFormalInference[1L])
        }
        else {
            NA
        }, precision_tier = as.character(precision_profile_tbl$PrecisionTier[1L] %||% NA_character_))
    overall_status <- dplyr::case_when(any(key_warnings != "No immediate warnings from diagnostics summary.") ~ 
        "follow_up_needed", identical(precision_tier, "exploratory") ~ "exploratory_screen_only", TRUE ~ 
        "no_major_screening_flags")
    status <- make_summary_block(`Overall status` = overall_status, `Source fit readiness` = source_fit_label, 
        `Diagnostic path` = diagnostic_mode, `Strict marginal fit` = strict_path_status, `Precision tier` = precision_tier, 
        `Primary screen` = primary_screen)
    reporting_map <- tibble::tibble(Area = c("Overall fit / reliability", "Precision basis / inferential caveats", 
        "Strict marginal fit", "Fair averages / adjusted-score review", "Residual PCA / local structure", 
        "Unexpected responses / displacement", "Connectivity / subsets", "Manuscript checklist / export"), 
        CoveredHere = c("yes", "yes", if (marginal_available) "yes" else if (identical(diagnostic_mode, 
            "legacy")) "no" else "requested_not_available", if (identical(fair_average_status, "available_direct_only")) {
            "direct_only"
        } else if (identical(fair_average_status, "embedded_available")) {
            "yes"
        } else {
            "no"
        }, "partial", "partial", "partial", "no"), CompanionOutput = c("summary(diagnostics)", "summary(diagnostics)", 
            if (marginal_available) {
                "diagnostics$marginal_fit / rating_scale_table(..., diagnostics = diagnostics)"
            } else {
                "diagnose_mfrm(..., diagnostic_mode = \"both\")"
            }, if (identical(fair_average_status, "available_direct_only")) {
                as.character(object$fair_average$direct_route %||% "fair_average_table(fit, diagnostics = diagnostics)")
            } else {
                "diagnostics$fair_average / fair_average_table(fit, diagnostics = diagnostics)"
            }, "analyze_residual_pca() / diagnostics$pca details", "unexpected_response_table() / displacement_table() / interaction tables", 
            "subset_connectivity_report() / measurable_summary_table()", "mfrm_report(fit, type = 'checklist') / summary(build_apa_outputs(...))"))
    notes <- character(0)
    if (nrow(precision_profile_tbl) > 0 && identical(as.character(precision_profile_tbl$PrecisionTier[1]), 
        "exploratory")) {
        notes <- c(notes, mfrm_precision_reporting_note("JML", "exploratory", FALSE))
    }
    if (nrow(precision_profile_tbl) > 0 && identical(as.character(precision_profile_tbl$PrecisionTier[1]), 
        "hybrid")) {
        notes <- c(notes, mfrm_precision_reporting_note("MML", "hybrid", isTRUE(precision_profile_tbl$InferenceReady[1])))
    }
    if (isTRUE(fair_average_status %in% c("no_finite_mle", "boundary_check_unavailable"))) 
        notes <- c(notes, object$fair_average$reason)
    if (identical(fair_average_status, "available_direct_only")) {
        notes <- c(notes, paste0("The embedded fair-average dashboard panel is disabled for GPCM; ", 
            "use `fair_average_table(fit, diagnostics = diagnostics)` for the ", "supported slope-aware element-conditional table."))
    }
    if (isTRUE(n_subsets > 1L)) {
        notes <- c(notes, "Multiple disconnected subsets were detected.")
    }
    if (isTRUE(!is.na(unexpected_n) && unexpected_n > 0L)) {
        notes <- c(notes, "Unexpected responses were flagged under current thresholds.")
    }
    if (nrow(approximation_tbl) > 0) {
        notes <- c(notes, "SE/ModelSE, CI, and reliability conventions depend on the estimation path; see diagnostics$approximation_notes for MML-vs-JML details.")
    }
    if (nrow(reliability_tbl) > 0) {
        notes <- c(notes, "Use `diagnostics$reliability` for facet-level separation/reliability. Use `diagnostics$interrater` only for observed agreement across matched rater contexts.")
    }
    if (nrow(precision_review_tbl) > 0 && "Status" %in% names(precision_review_tbl)) {
        flagged_checks <- dplyr::filter(precision_review_tbl, .data$Status %in% c("review", "warn"))
        if (nrow(flagged_checks) > 0) {
            notes <- c(notes, paste0("Precision review flagged ", nrow(flagged_checks), " review/warn checks."))
        }
    }
    if (nrow(interrater_summary_tbl) == 0) {
        notes <- c(notes, "No inter-rater agreement block was produced for this run. Facet-level reliability summarizes separation/precision, not observed rater agreement.")
    }
    if (marginal_available) {
        notes <- c(notes, "Strict marginal fit was computed from latent-integrated first-order category counts.")
        if (marginal_pairwise_available) {
            notes <- c(notes, "Strict pairwise local-dependence checks were computed from posterior-integrated expected exact and adjacent agreement and should be read as exploratory screening summaries.")
        }
        notes <- c(notes, "Posterior predictive checks were not computed; use a separate posterior-predictive workflow if required.")
        if (identical(diagnostic_mode, "both")) {
            notes <- c(notes, "Legacy residual diagnostics and strict marginal diagnostics target different quantities; do not compare their residual magnitudes directly.")
        }
    }
    else if (!identical(diagnostic_mode, "legacy") && nrow(marginal_fit_tbl) > 0 && "Reason" %in% names(marginal_fit_tbl)) {
        notes <- c(notes, as.character(marginal_fit_tbl$Reason[1]))
    }
    if (length(notes) == 0) {
        notes <- "No immediate warnings from diagnostics summary."
    }
    facets_chisq_overview <- tibble::tibble()
    if (nrow(facets_chisq_tbl) > 0) {
        keep_chi <- intersect(c("Facet", "Levels", "MeanMeasure", "SD", "FixedChiSq", "FixedDF", "FixedProb", 
            "RandomChiSq", "RandomDF", "RandomProb"), names(facets_chisq_tbl))
        facets_chisq_overview <- dplyr::select(facets_chisq_tbl, dplyr::all_of(keep_chi))
    }
    interrater_overview <- tibble::tibble()
    if (nrow(interrater_summary_tbl) > 0) {
        keep_ir <- intersect(c("RaterFacet", "Raters", "Pairs", "OpportunityCount", "ExactAgreement", 
            "ExpectedExactAgreement", "AgreementMinusExpected", "AdjacentAgreement", "MeanAbsDiff", "MeanCorr", 
            "RaterSeparation", "RaterReliability"), names(interrater_summary_tbl))
        interrater_overview <- dplyr::select(interrater_summary_tbl, dplyr::all_of(keep_ir))
    }
    out <- list(overview = overview, decision = decision, status = status, fit_readiness = fit_readiness_tbl, 
        fit_readiness_components = fit_readiness_components_tbl, fit_readiness_parameters = fit_readiness_parameters_tbl, 
        key_warnings = key_warnings, next_actions = next_actions, diagnostic_basis = diagnostic_basis_tbl, 
        fit_standardization = fit_standardization_tbl, overall_fit = overall_fit, precision_profile = precision_profile_tbl, 
        precision_review = precision_review_tbl, reliability = reliability_overview, facets_chisq = facets_chisq_overview, 
        interrater = interrater_overview, misfit_flagged = misfit_flagged, fit_screening = fit_screening$counts, 
        misfit_thresholds = c(lower = misfit_lower, upper = misfit_upper), category_usage = category_usage, 
        top_fit = top_fit, marginal_fit = marginal_fit_tbl, marginal_coverage = marginal_coverage, top_marginal_cells = top_marginal_cells, 
        marginal_pairwise = marginal_pairwise_tbl, top_marginal_pairs = top_marginal_pairs, marginal_guidance = marginal_guidance_tbl, 
        reporting_map = reporting_map, flags = flags, notes = notes, digits = digits, detail = detail, 
        include_person = include_person)
    class(out) <- "summary.mfrm_diagnostics"
    out
}

print.summary.mfrm_diagnostics <- function(x, ...) {
    if (!is.data.frame(x$fit_screening) || ("Available" %in% names(x$marginal_fit) && isTRUE(x$marginal_fit$Available[1]) && 
        is.null(x$marginal_coverage))) {
        stop("Recreate this diagnostic summary with summary(diagnostics) to retain fit-screening coverage; no model refit is needed.", 
            call. = FALSE)
    }
    if (!is.null(x$imported_source)) {
        cat("Imported measurement diagnostics: ", x$imported_source, "\n", sep = "")
        for (note in x$notes) print_wrapped_line(note)
        if (nrow(x$reliability)) {
            columns <- intersect(c("Facet", "Levels", "EstimateAvailable", "SEAvailable", "Separation", 
                "Reliability"), names(x$reliability))
            print(as.data.frame(x$reliability[columns]), row.names = FALSE)
        }
        cat("Source fit statistics and classification counts remain in the summary tables.\n")
        return(invisible(x))
    }
    digits <- as.integer(x$digits %||% 3L)
    if (!is.finite(digits)) 
        digits <- 3L
    detail <- as.character(x$detail %||% "brief")
    include_person <- isTRUE(x$include_person)
    display_value <- function(value) {
        value <- as.character(value %||% "")
        labels <- c(follow_up_needed = "Follow-up needed", exploratory_screen_only = "Exploratory screening only", 
            no_major_screening_flags = "No major screening flags", model_based = "Model-based precision", 
            hybrid = "Mixed model-based and fallback precision", exploratory = "Exploratory precision", 
            approximate_summary = "Approximate summary", review_before_reporting = "Review before reporting", 
            screening_only = "Screening only", available = "Available", embedded_available = "Available in diagnostics", 
            available_direct_only = "Available via direct table only", not_available = "Not available", 
            partly_classified = "Computed; some classifications unavailable", not_requested = "Not requested", 
            requested_not_available = "Requested but not available", available_but_not_requested = "Available but not requested", 
            not_available_for_run = "Not available for this analysis", both = "Legacy and strict marginal", 
            legacy = "Legacy residual diagnostics", marginal_fit = "Strict marginal diagnostics")
        hit <- unname(labels[value])
        ifelse(is.na(hit), value, hit)
    }
    reliability_print <- as.data.frame(x$reliability %||% data.frame(), stringsAsFactors = FALSE)
    if ("ReliabilityUse" %in% names(reliability_print)) {
        reliability_print$ReliabilityUse <- display_value(reliability_print$ReliabilityUse)
    }
    key_warning_lines <- if (summary_lines_are_default(x$key_warnings, "No immediate warnings from diagnostics summary.")) {
        "None."
    }
    else {
        x$key_warnings
    }
    cat("Many-Facet Measurement Diagnostics Summary\n")
    if (!is.null(x$overview) && nrow(x$overview) > 0) {
        ov <- round_numeric_df(as.data.frame(x$overview), digits = digits)[1, , drop = FALSE]
        cat(sprintf("  Observations: %s | Persons: %s | Facets: %s | Categories: %s | Subsets: %s\n", 
            ov$Observations, ov$Persons, ov$Facets, ov$Categories, ov$Subsets))
        cat(sprintf("  Residual PCA mode: %s\n", ov$ResidualPCA))
        if ("Method" %in% names(ov) && "PrecisionTier" %in% names(ov)) {
            cat(sprintf("  Method: %s | Precision basis: %s\n", ov$Method, display_value(ov$PrecisionTier)))
        }
        if ("DiagnosticMode" %in% names(ov) && "MarginalFit" %in% names(ov)) {
            cat(sprintf("  Diagnostic mode: %s\n", display_value(ov$DiagnosticMode)))
            cat(sprintf("  Strict marginal fit: %s\n", display_value(ov$MarginalFit)))
        }
        if ("FairAverage" %in% names(ov)) {
            cat(sprintf("  Fair average: %s\n", display_value(ov$FairAverage)))
        }
    }
    print_fit_decision_section(x$decision)
    if (!is.null(x$status) && nrow(x$status) > 0) {
        print_bullet_section("Status", paste0(sub("^Precision tier$", "Precision basis", x$status$Item), 
            ": ", display_value(x$status$Value)))
    }
    print_bullet_section("Key warnings", key_warning_lines)
    print_bullet_section("Next actions", x$next_actions)
    print_bullet_section("Element-fit screening", vapply(seq_len(nrow(x$fit_screening)), function(i) {
        fit_screening_note(x$fit_screening[i, ])
    }, character(1)))
    print_wrapped_line("Mean-square bands and ZSTD cutoffs are descriptive review rules, without calibrated individual or multiple-element error rates. Rankings use complete paired statistics.")
    print_bullet_section("Marginal classification coverage", marginal_coverage_notes(x$marginal_coverage))
    if (isTRUE(x$marginal_fit$Available[1])) {
        print_wrapped_line("Expected counts condition on the same responses through Person posteriors, with fitted calibration fixed. Residual scales omit cross-response covariance and calibration uncertainty; cutoffs are descriptive review rules.")
    }
    if (!is.null(x$overall_fit) && nrow(x$overall_fit) > 0) {
        cat("\nOverall fit\n")
        overall_fit <- as.data.frame(x$overall_fit)
        print(round_numeric_df(overall_fit[, setdiff(names(overall_fit), "FitReason"), drop = FALSE], 
            digits = digits), row.names = FALSE)
        for (reason in unique(overall_fit$FitReason)) print_wrapped_line(reason)
    }
    if (!is.null(x$reliability) && nrow(x$reliability) > 0L) {
        print_wrapped_line(paste(.mfrmr_const_mfrm_separation_interpretation, "Fit-adjusted values are not confidence bounds; MML Person EAP reliability depends on the assumed population prior.", 
            "Counts show finite estimates and their available SEs; indices are withheld when those SEs are incomplete."))
    }
    if (identical(detail, "brief")) {
        print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_diagnostics_01"]])
        if (!is.null(x$reliability) && nrow(x$reliability) > 0) {
            cat("\nFacet precision and spread\n")
            print(round_numeric_df(reliability_print, digits = digits), row.names = FALSE)
        }
        top_fit_print <- as.data.frame(x$top_fit %||% data.frame(), stringsAsFactors = FALSE)
        if (!include_person && nrow(top_fit_print) > 0L && "Facet" %in% names(top_fit_print)) {
            top_fit_print <- top_fit_print[as.character(top_fit_print$Facet) != "Person", , drop = FALSE]
        }
        if (nrow(top_fit_print) > 0L) {
            cat("\nHighest-priority non-person fit rows\n")
            print(round_numeric_df(utils::head(top_fit_print, 5L), digits = digits), row.names = FALSE)
        }
        print_bullet_section("Further detail", "Additional tables remain in the structured summary; use `detail = \"full\"` to print them.")
        return(invisible(x))
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_diagnostics_02"]], digits = digits)
    if (!is.null(x$diagnostic_basis) && nrow(x$diagnostic_basis) > 0) {
        cat("\nDiagnostic basis guide\n")
        basis <- as.data.frame(x$diagnostic_basis)
        guide <- data.frame(Statistics = basis$PrimaryStatistics, Availability = display_value(basis$Status), 
            Note = basis$InterpretationNote)
        print(guide, row.names = FALSE)
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_diagnostics_03"]], digits = digits)
    precision_review_tbl <- precision_review(x, required = FALSE)
    if (!is.null(precision_review_tbl) && nrow(precision_review_tbl) > 0) {
        flagged_checks <- as.data.frame(precision_review_tbl)
        if ("Status" %in% names(flagged_checks)) {
            flagged_checks <- flagged_checks[flagged_checks$Status %in% c("review", "warn"), , drop = FALSE]
        }
        if (nrow(flagged_checks) > 0) {
            cat("\nPrecision review checks\n")
            print(flagged_checks, row.names = FALSE)
        }
    }
    if (!is.null(x$reliability) && nrow(x$reliability) > 0) {
        cat("\nFacet precision and spread\n")
        print(round_numeric_df(reliability_print, digits = digits), row.names = FALSE)
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_diagnostics_04"]], digits = digits)
    top_fit_print <- as.data.frame(x$top_fit %||% data.frame(), stringsAsFactors = FALSE)
    if (!include_person && nrow(top_fit_print) > 0L && "Facet" %in% names(top_fit_print)) {
        top_fit_print <- top_fit_print[as.character(top_fit_print$Facet) != "Person", , drop = FALSE]
    }
    if (nrow(top_fit_print) > 0) {
        cat("\nLargest |ZSTD| rows\n")
        print(round_numeric_df(top_fit_print, digits = digits), row.names = FALSE)
    }
    misfit_print <- as.data.frame(x$misfit_flagged %||% data.frame(), stringsAsFactors = FALSE)
    person_misfit_n <- 0L
    if (!include_person && nrow(misfit_print) > 0L && "Facet" %in% names(misfit_print)) {
        person_misfit_n <- sum(as.character(misfit_print$Facet) == "Person", na.rm = TRUE)
        misfit_print <- misfit_print[as.character(misfit_print$Facet) != "Person", , drop = FALSE]
    }
    if (person_misfit_n > 0L) {
        cat(sprintf("\nPerson-level fit warnings: %d row(s); identifiers suppressed. Use `include_person = TRUE` only under appropriate privacy controls.\n", 
            person_misfit_n))
    }
    if (nrow(misfit_print) > 0) {
        thr <- x$misfit_thresholds %||% c(lower = 0.5, upper = 1.5)
        cat(sprintf("\nMnSq follow-up (outside configured %s-%s band; %d element(s))\n", format_fit_bound(thr["lower"]), 
            format_fit_bound(thr["upper"]), nrow(misfit_print)))
        keep_show <- intersect(c("Facet", "Level", "Infit", "InfitZSTD", "Outfit", "OutfitZSTD"), names(misfit_print))
        print(round_numeric_df(misfit_print[, keep_show, drop = FALSE], digits = digits), row.names = FALSE)
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_diagnostics_05"]], digits = digits)
    if (!is.null(x$marginal_fit) && nrow(x$marginal_fit) > 0) {
        cat("\nStrict marginal fit\n")
        keep <- intersect(c("Method", "Model", "ObservationCount", "CategoryCount", "OverallRMSD", "OverallMaxAbsStdResidual", 
            "Reason"), names(x$marginal_fit))
        print(round_numeric_df(as.data.frame(x$marginal_fit)[, keep, drop = FALSE], digits = digits), 
            row.names = FALSE)
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_diagnostics_06"]], digits = digits)
    if (!is.null(x$marginal_pairwise) && nrow(x$marginal_pairwise) > 0) {
        cat("\nStrict pairwise local dependence\n")
        keep <- intersect(c("Facet", "LevelPairs", "ContextPairs", "AvailableContextPairs", "UnavailableContextPairs", 
            "ClassifiedLevelPairs", "UnclassifiedLevelPairs", "FlaggedLevelPairs"), names(x$marginal_pairwise))
        print(round_numeric_df(as.data.frame(x$marginal_pairwise)[, keep, drop = FALSE], digits = digits), 
            row.names = FALSE)
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_diagnostics_07"]], digits = digits)
    if (!is.null(x$marginal_guidance) && nrow(x$marginal_guidance) > 0) {
        cat("\nStrict marginal guidance\n")
        for (line in unique(x$marginal_guidance$InterpretationNote)) print_wrapped_line(line)
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_diagnostics_08"]])
    if (length(x$notes) > 0 && !summary_lines_are_default(x$notes, "No immediate warnings from diagnostics summary.")) {
        cat("\nNotes\n")
        for (line in x$notes) cat(" - ", line, "\n", sep = "")
    }
    invisible(x)
}

summary.mfrm_bias <- function(object, digits = 3, top_n = 10, p_cut = 0.05, ...) {
    if (!is.list(object) || is.null(object$table) || nrow(object$table) == 0) {
        stop("`object` must be non-empty output from estimate_bias().")
    }
    if (any(c("BiasSize", "Interaction") %in% names(object$table))) {
        digits <- max(0L, as.integer(digits))
        top_n <- max(1L, as.integer(top_n))
        p_cut <- max(0, min(1, as.numeric(p_cut[1L])))
        bt <- object$table
        b_vals <- if ("BiasSize" %in% names(bt)) bt$BiasSize else bt$Estimate
        p_vals <- bt$pValue
        p_adj <- if ("pAdj" %in% names(bt)) bt$pAdj else stats::p.adjust(p_vals, method = "holm")
        pair_lbl <- if ("Pair" %in% names(bt)) paste(unique(bt$Pair), collapse = ", ") else paste(unique(bt$Interaction), collapse = ", ")
        overview <- tibble::tibble(
            FacetPair = pair_lbl,
            InteractionOrder = 2L,
            InteractionMode = object$method %||% "local",
            Cells = nrow(bt),
            Points = sum(is.finite(b_vals)),
            ScreenAvailable = sum(is.finite(p_vals)),
            ScreenUnavailable = sum(!is.finite(p_vals)),
            MeanAbsBias = mean(abs(b_vals), na.rm = TRUE),
            MaxAbsBias = max(abs(b_vals), na.rm = TRUE),
            ScreenPositive = if (all(is.na(p_vals))) NA_integer_ else sum(p_vals <= p_cut, na.rm = TRUE),
            ScreeningCut = p_cut,
            BonferroniScreenPositive = if (all(is.na(p_vals))) NA_integer_ else sum(stats::p.adjust(p_vals, method = "bonferroni") <= p_cut, na.rm = TRUE),
            HolmScreenPositive = if (all(is.na(p_adj))) NA_integer_ else sum(p_adj <= p_cut, na.rm = TRUE)
        )
        ord_idx <- order(-abs(b_vals))
        top_rows <- tibble::as_tibble(bt[utils::head(ord_idx, top_n), , drop = FALSE])
        out <- list(
            overview = overview,
            summary = object$summary %||% tibble::tibble(),
            pairwise = utils::head(object$pairwise %||% data.frame(), top_n),
            lrt = object$lrt,
            chi_sq = tibble::tibble(),
            final_iteration = tibble::tibble(),
            top_rows = top_rows,
            notes = c(if (!is.null(object$test_label)) paste("Pairwise contrast test:", object$test_label) else "Joint interaction parameterization.",
              if (!is.null(object$readiness)) paste("Numerical inference:", object$readiness$status, paste(object$readiness$reason_codes, collapse = "; "))),
            digits = digits
        )
        class(out) <- "summary.mfrm_bias"
        return(out)
    }
    digits <- max(0L, as.integer(digits))
    top_n <- max(1L, as.integer(top_n))
    p_cut <- max(0, min(1, as.numeric(p_cut[1])))
    bias_tbl <- tibble::as_tibble(object$table)
    chi_tbl <- tibble::as_tibble(object$chi_sq %||% tibble::tibble())
    iter_tbl <- tibble::as_tibble(object$iteration %||% tibble::tibble())
    spec <- extract_bias_facet_spec(object)
    interaction_facets <- if (!is.null(spec)) 
        spec$facets
    else unique(c(as.character(object$facet_a[1] %||% NA_character_), as.character(object$facet_b[1] %||% 
        NA_character_)))
    interaction_facets <- interaction_facets[!is.na(interaction_facets) & nzchar(interaction_facets)]
    if (length(interaction_facets) == 0) 
        interaction_facets <- c("Unknown")
    interaction_label <- paste(interaction_facets, collapse = " x ")
    interaction_order <- length(interaction_facets)
    interaction_mode <- ifelse(interaction_order > 2, "higher_order", "pairwise")
    abs_bias <- abs(suppressWarnings(as.numeric(bias_tbl$`Bias Size`)))
    p_vals <- suppressWarnings(as.numeric(bias_tbl$Prob.))
    screen_n <- sum(is.finite(p_vals))
    sig_n <- if (screen_n) 
        sum(p_vals <= p_cut, na.rm = TRUE)
    else NA_integer_
    lr_p_vals <- if ("LR Prob." %in% names(bias_tbl)) {
        suppressWarnings(as.numeric(bias_tbl$`LR Prob.`))
    }
    else {
        numeric(0)
    }
    lr_sig_n <- if (any(is.finite(lr_p_vals))) 
        sum(lr_p_vals <= p_cut, na.rm = TRUE)
    else NA_integer_
    finite_p <- p_vals[is.finite(p_vals)]
    bonferroni_n <- if (length(finite_p) > 0L) {
        sum(p.adjust(finite_p, method = "bonferroni", n = nrow(bias_tbl)) <= p_cut)
    }
    else NA_integer_
    holm_n <- if (length(finite_p) > 0L) {
        sum(p.adjust(finite_p, method = "holm", n = nrow(bias_tbl)) <= p_cut)
    }
    else NA_integer_
    overview <- tibble::tibble(FacetPair = interaction_label, InteractionOrder = interaction_order, InteractionMode = interaction_mode, 
        Cells = nrow(bias_tbl), Points = sum(is.finite(abs_bias)), ScreenAvailable = screen_n, ScreenUnavailable = nrow(bias_tbl) - 
            screen_n, MeanAbsBias = if (any(is.finite(abs_bias))) 
            mean(abs_bias[is.finite(abs_bias)])
        else NA_real_, MaxAbsBias = if (any(is.finite(abs_bias))) 
            max(abs_bias[is.finite(abs_bias)])
        else NA_real_, ScreenPositive = sig_n, ScreeningCut = p_cut, BonferroniScreenPositive = bonferroni_n, 
        HolmScreenPositive = holm_n, SupportsFormalInference = FALSE, FormalInferenceEligible = FALSE, 
        PrimaryReportingEligible = FALSE, ClassificationSystem = "screening", ReportingUse = "screening_only", 
        Significant = sig_n, SignificantCut = p_cut, BonferroniSignificant = bonferroni_n, HolmSignificant = holm_n)
    if (length(lr_p_vals)) {
        overview$LRScreenPositive <- lr_sig_n
    }
    final_iteration <- tibble::tibble()
    if (nrow(iter_tbl) > 0) {
        final_iteration <- dplyr::slice_tail(iter_tbl, n = 1)
    }
    top_rows <- tibble::tibble()
    level_cols <- if (!is.null(spec)) {
        spec$level_cols
    }
    else if (all(c("FacetA_Level", "FacetB_Level") %in% names(bias_tbl))) {
        c("FacetA_Level", "FacetB_Level")
    }
    else {
        character(0)
    }
    base_keep <- c(level_cols, "Bias Size", "S.E.", "t", "Prob.", "Obs-Exp Average")
    likelihood_keep <- intersect(c("LR ChiSq", "LR Prob.", "Profile CI Lower", "Profile CI Upper", "Profile CI Status"), 
        names(bias_tbl))
    keep <- c(base_keep, likelihood_keep, intersect(c("d.f.", "DFUnrounded", "ProbabilityReference", 
        "ProbabilityStatus", "ProbabilityReason", "BiasStatus", "ScreenStatus", "ScreenReason", "FitStatus", 
        "FitReason"), names(bias_tbl)))
    if (all(base_keep %in% names(bias_tbl))) {
        top_rows <- dplyr::select(dplyr::slice_head(dplyr::arrange(dplyr::mutate(bias_tbl, AbsT = abs(.data$t)), 
            dplyr::desc(.data$AbsT)), n = top_n), dplyr::all_of(c(keep, "AbsT")))
        if (length(level_cols) == length(interaction_facets)) {
            names(top_rows)[seq_along(level_cols)] <- interaction_facets
            top_rows <- dplyr::mutate(top_rows, Pair = do.call(paste, c(top_rows[interaction_facets], 
                sep = " | ")), .before = 1)
        }
    }
    notes <- character(0)
    if (!all(c("BiasStatus", "ScreenStatus", "FitStatus") %in% names(bias_tbl))) 
        notes <- c(notes, "This saved table predates the boundary and complete-cell information/fit checks. Recompute estimate_bias() from the saved fit and matching diagnostics; these values have not been recalculated.")
    if (screen_n < nrow(bias_tbl)) 
        notes <- c(notes, if (all(c("ProbabilityStatus", "ProbabilityReason") %in% names(bias_tbl))) "Some cell screening tail areas are unavailable. Missing results are not negative screens; inspect ProbabilityStatus and ProbabilityReason." else "Some cell screening tail areas are unavailable. Missing results are not negative screens; inspect ScreenStatus and ScreenReason.")
    if ("BiasStatus" %in% names(bias_tbl) && any(bias_tbl$BiasStatus == "extreme_adjusted", na.rm = TRUE)) 
        notes <- c(notes, "Extreme cells use a corrected total for finite reporting values and conditional SEs. PrimaryBias retains the infinite cell MLE. These extrapolated tail areas, summaries and pairwise contrasts are not regular-MLE inference or fairness decisions.")
    notes <- c(notes, paste("Conditional plug-in screening holds calibration and Person estimates fixed.", 
        "Bonferroni/Holm summaries retain all reported cells in this pair's family;", "they do not establish formal family-wise error control or collection-wide multiplicity control."))
    if (nrow(iter_tbl) > 0) {
        tail_row <- iter_tbl[nrow(iter_tbl), , drop = FALSE]
        tail_cells <- suppressWarnings(as.numeric(tail_row$BiasCells[1]))
        if (is.finite(tail_cells) && tail_cells > 0) {
            notes <- c(notes, "Bias iteration may not have fully stabilized (BiasCells > 0 at final step).")
        }
    }
    if (interaction_order > 2) {
        notes <- c(notes, "Higher-order interaction mode is active; pairwise contrasts should be interpreted from dedicated 2-way runs.")
    }
    if (isTRUE(object$mixed_sign)) {
        notes <- c(notes, as.character(object$direction_note %||% "Selected interaction facets mix score orientations; use neutral higher/lower-than-expected wording."))
    }
    if (length(notes) == 0) {
        notes <- "No immediate warnings from bias summary."
    }
    out <- list(overview = overview, chi_sq = chi_tbl, final_iteration = final_iteration, top_rows = top_rows, 
        notes = notes, digits = digits)
    class(out) <- "summary.mfrm_bias"
    out
}

print.summary.mfrm_bias <- function(x, ...) {
    digits <- as.integer(x$digits %||% 3L)
    if (!is.finite(digits)) 
        digits <- 3L
    cat("Many-Facet Measurement Bias Summary\n")
    if (!is.null(x$overview) && nrow(x$overview) > 0) {
        ov <- round_numeric_df(as.data.frame(x$overview), digits = digits)[1, , drop = FALSE]
        cat(sprintf("  Interaction facets: %s | Cells: %s\n", ov$FacetPair, ov$Cells))
        if ("InteractionOrder" %in% names(ov) && "InteractionMode" %in% names(ov)) {
            cat(sprintf("  Order: %s | Mode: %s\n", ov$InteractionOrder, ov$InteractionMode))
        }
        cat(sprintf("  Mean |Bias|: %s | Max |Bias|: %s | Screen-positive (p <= %.3f): %s\n", ov$MeanAbsBias, 
            ov$MaxAbsBias, as.numeric(ov$ScreeningCut), ov$ScreenPositive))
        if ("LRScreenPositive" %in% names(ov)) {
            cat(sprintf("  GPCM profile-LR screen-positive (p <= %.3f): %s\n", as.numeric(ov$ScreeningCut), 
                ov$LRScreenPositive))
        }
        if (all(c("BonferroniScreenPositive", "HolmScreenPositive") %in% names(ov))) {
            cat(sprintf("  Bonferroni screen-positive: %s | Holm screen-positive: %s (cut = %.3f, m = %s)\n", 
                ov$BonferroniScreenPositive, ov$HolmScreenPositive, as.numeric(ov$ScreeningCut), ov$Cells))
        }
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_bias_01"]], digits = digits)
    if (length(x$notes) > 0) {
        cat("\nNotes\n")
        for (line in x$notes) cat(" - ", line, "\n", sep = "")
    }
    invisible(x)
}

summary.mfrm_fit <- function(object, digits = 3, top_n = 5, ..., profile = c("fit", "facets", "reporting"), 
    detail = NULL, diagnostics = NULL, compute = c("auto", "never"), include_person = FALSE, comparison_review = NULL) {
    object <- mfrm_gmfrm_refresh_boundary(object)
    if (mfrm_has_jml_adjustment(object)) {
        rlang::check_dots_empty()
        if (!is.null(comparison_review)) 
            stop_if_jml_adjustment(object, "Interaction comparisons")
        if (!is.null(diagnostics)) 
            stop_if_jml_adjustment(object, "Attaching ordinary diagnostics")
        match.arg(profile)
        match.arg(compute)
        if (!is.null(detail)) 
            match.arg(detail, c("brief", "full"))
        return(mfrm_jml_summary(object, digits, include_person))
    }
    profile <- match.arg(tolower(as.character(profile[1])), c("fit", "facets", "reporting"))
    if (is.null(detail) || length(detail) == 0L) {
        detail <- if (identical(profile, "fit")) 
            "full"
        else "brief"
    }
    else {
        detail <- match.arg(tolower(as.character(detail[1])), c("brief", "full"))
    }
    compute <- match.arg(tolower(as.character(compute[1])), c("auto", "never"))
    if (!is.logical(include_person) || length(include_person) != 1L || is.na(include_person)) {
        stop("`include_person` must be TRUE or FALSE.", call. = FALSE)
    }
    include_person <- isTRUE(include_person)
    if (!is.null(diagnostics)) {
        mfrm_results_validate_diagnostics_identity(object, diagnostics, helper = "summary.mfrm_fit()")
    }
    out <- mfrm_fit_summary_core(object, digits = digits, top_n = top_n)
    if (!is.null(comparison_review)) {
        out$interaction_comparisons <- interaction_effect_table(object, comparison_review)
    }
    mfrm_fit_summary_workflow(out = out, fit = object, profile = profile, detail = detail, diagnostics = diagnostics, 
        compute = compute, include_person = include_person)
}

mfrm_summary_facet_support_boundaries <- function(object) {
    boundary_levels <- as.data.frame(object$data_review$boundary_levels %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(boundary_levels) == 0L) 
        return(tibble::tibble())
    keep <- intersect(c("Facet", "Level", "ConstantScore", "BoundaryConstant", "Observations", "WeightedN", 
        "DistinctScores", "MinScore", "MaxScore"), names(boundary_levels))
    if (!all(c("Facet", "Level") %in% keep)) 
        return(tibble::tibble())
    tibble::as_tibble(boundary_levels[, keep, drop = FALSE])
}

mfrm_summary_facet_recession_review <- function(object) {
    audits <- object$config$boundary_audit %||% list()
    audit_names <- c("structural_additive", "joint_additive")
    scope_labels <- c(structural_additive = "structural_fixed_person", joint_additive = "joint_person_structural")
    rows <- lapply(audit_names, function(audit_name) {
        audit <- audits[[audit_name]] %||% list()
        targets <- as.data.frame(audit$target_status %||% data.frame(), stringsAsFactors = FALSE)
        required <- c("ParameterId", "ParameterClass", "Facet", "Level", "OptimizerEstimate", "CandidateStatus", 
            "EvaluationState", "ReasonCodes")
        if (nrow(targets) == 0L || !all(required %in% names(targets))) {
            return(data.frame())
        }
        keep <- as.character(targets$ParameterClass) == "facet" & as.character(targets$CandidateStatus) %in% 
            c("unbounded_low", "unbounded_high", "unbounded_both") & startsWith(as.character(targets$EvaluationState), 
            "evaluated")
        targets <- targets[keep, , drop = FALSE]
        if (nrow(targets) == 0L) 
            return(data.frame())
        data.frame(ParameterId = as.character(targets$ParameterId), Facet = as.character(targets$Facet), 
            Level = as.character(targets$Level), BoundaryStatus = as.character(targets$CandidateStatus), 
            OptimizerEstimate = suppressWarnings(as.numeric(targets$OptimizerEstimate)), AuditScope = unname(scope_labels[[audit_name]]), 
            AuditComplete = isTRUE(audit$complete), StatusBasis = "certified_in_audited_additive_subspace", 
            ReasonCodes = as.character(targets$ReasonCodes), stringsAsFactors = FALSE)
    })
    out <- dplyr::bind_rows(rows)
    if (nrow(out) == 0L) 
        return(tibble::tibble())
    tibble::as_tibble(dplyr::select(dplyr::distinct(dplyr::arrange(dplyr::mutate(out, AuditPriority = match(.data$AuditScope, 
        c("structural_fixed_person", "joint_person_structural"))), .data$AuditPriority, .data$Facet, 
        .data$Level), .data$ParameterId, .keep_all = TRUE), -"AuditPriority", -"ParameterId"))
}

mfrm_gpcm_mml_inference_evidence <- function(object) {
    config <- object$config %||% list()
    model <- toupper(as.character(config$model %||% object$summary$Model[1] %||% "")[1])
    method <- toupper(as.character(config$method %||% object$summary$Method[1] %||% "")[1])
    if (!identical(model, "GPCM") || !identical(method, "MML")) {
        return(tibble::tibble())
    }
    estimability <- object$data_review$estimability %||% config$estimability_audit %||% list()
    local <- estimability$nonlinear_local_estimability %||% list()
    information <- estimability$fitted_information %||% list()
    boundary <- config$boundary_audit$gpcm_slope_boundary %||% list()
    point <- config$gpcm_point_estimation$overview
    product_point <- mfrm_has_product_slopes(object) && !is.null(point)
    if (product_point) {
        boundary <- list(state = point$BoundaryReview, complete = TRUE, scope_complete = FALSE, detail = if (identical(point$Status, 
            "finite_maximum_absent")) point$Detail else "No all-low or all-high facet level was found. Other joint and slope boundary paths have not been classified.")
    }
    readiness <- as.data.frame(mfrmr_get_readiness_record(object)$fit, stringsAsFactors = FALSE)
    optimizer <- object$opt$optimizer_diagnostics %||% list()
    eigenvalues <- as.data.frame(information$eigenvalue_summary %||% data.frame(), stringsAsFactors = FALSE)
    minimum_eigenvalue <- if (nrow(eigenvalues) > 0L && "Smallest" %in% names(eigenvalues)) {
        as.numeric(eigenvalues$Smallest[1])
    }
    else {
        NA_real_
    }
    maximum_eigenvalue <- if (nrow(eigenvalues) > 0L && "Largest" %in% names(eigenvalues)) {
        as.numeric(eigenvalues$Largest[1])
    }
    else {
        NA_real_
    }
    condition_number <- if (is.finite(minimum_eigenvalue) && minimum_eigenvalue > 0 && is.finite(maximum_eigenvalue)) {
        maximum_eigenvalue/minimum_eigenvalue
    }
    else {
        NA_real_
    }
    rank_ladder <- as.data.frame(information$rank_ladder %||% data.frame(), stringsAsFactors = FALSE)
    free_dimension <- as.integer(information$free_dimension %||% NA_integer_)
    positive_definite <- identical(as.character(information$status %||% ""), "evaluated_diagnostic_only") && 
        is.finite(minimum_eigenvalue) && minimum_eigenvalue > 0 && nrow(rank_ladder) > 0L && all(c("PositiveRank", 
        "NegativeCount", "NearZeroCount") %in% names(rank_ladder)) && all(as.integer(rank_ladder$PositiveRank) == 
        free_dimension) && all(as.integer(rank_ladder$NegativeCount) == 0L) && all(as.integer(rank_ladder$NearZeroCount) == 
        0L)
    optimizer_severity <- as.character(optimizer$ConvergenceSeverity %||% "not_evaluated")[1]
    optimizer_state <- if (identical(optimizer_severity, "pass")) {
        "stationary_candidate"
    }
    else {
        paste0("optimizer_", tolower(optimizer_severity))
    }
    local_state <- as.character(local$state %||% "not_evaluated")[1]
    curvature_state <- if (positive_definite) {
        "locally_positive_definite_at_recorded_tolerances"
    }
    else {
        as.character(information$status %||% "not_evaluated")[1]
    }
    boundary_state <- as.character(boundary$state %||% "not_evaluated")[1]
    readiness_state <- if (nrow(readiness) == 1L) {
        as.character(readiness$FitReadiness[1])
    }
    else {
        "not_evaluated"
    }
    readiness_reasons <- if (nrow(readiness) == 1L && "ReasonCodes" %in% names(readiness)) {
        as.character(readiness$ReasonCodes[1])
    }
    else {
        "readiness_record_unavailable"
    }
    if (length(readiness_reasons) != 1L || is.na(readiness_reasons) || !nzchar(readiness_reasons)) {
        readiness_reasons <- "none_recorded"
    }
    tibble::tibble(EvidenceArea = c("optimizer_stationarity", "local_estimability", "observed_information_curvature", 
        if (product_point) "facet_location_boundary_screen" else "slope_boundary_screen", "fit_readiness"), 
        State = c(optimizer_state, local_state, curvature_state, boundary_state, readiness_state), Complete = c(identical(optimizer_severity, 
            "pass"), isTRUE(local$local_first_order_classified), identical(as.character(information$status %||% 
            ""), "evaluated_diagnostic_only"), isTRUE(boundary$complete) && isTRUE(boundary$scope_complete), 
            nrow(readiness) == 1L), Rank = c(NA_integer_, as.integer(local$local_rank %||% NA_integer_), 
            if (positive_definite) free_dimension else NA_integer_, NA_integer_, NA_integer_), Dimension = c(NA_integer_, 
            as.integer(local$free_dimension %||% NA_integer_), free_dimension, NA_integer_, NA_integer_), 
        MinimumEigenvalue = c(NA_real_, NA_real_, minimum_eigenvalue, NA_real_, NA_real_), MaximumEigenvalue = c(NA_real_, 
            NA_real_, maximum_eigenvalue, NA_real_, NA_real_), ConditionNumber = c(NA_real_, NA_real_, 
            condition_number, NA_real_, NA_real_), Interpretation = c("Necessary numerical condition; not an inference decision.", 
            "Supportive retained-point local rank; not global identification.", if (mfrm_has_product_slopes(object)) {
                "Recorded curvature is numerical evidence only. Inspect the saved checks from separately requested experimental confint(fit, parm = 'slopes') slope intervals."
            } else paste("Diagnostic local curvature only; inspect Optimizer*SE in", "diagnose_mfrm(fit)$parameter_uncertainty."), 
            if (startsWith(boundary_state, "none_certified")) {
                paste("No audited path was certified; this is inconclusive and does not", "prove an interior finite maximum.")
            } else {
                as.character(boundary$detail %||% "Boundary status was not resolved.")
            }, paste0("Formal decision; reasons: ", readiness_reasons, ".")))
}

mfrm_fit_scale_contract <- function(object) {
    config <- object$config %||% list()
    population <- object$population %||% list()
    summary_row <- as.data.frame(object$summary %||% data.frame(), stringsAsFactors = FALSE)
    summary_model <- if (nrow(summary_row) > 0L && "Model" %in% names(summary_row)) {
        summary_row$Model[1]
    }
    else {
        NA_character_
    }
    summary_method <- if (nrow(summary_row) > 0L && "Method" %in% names(summary_row)) {
        summary_row$Method[1]
    }
    else {
        NA_character_
    }
    model <- toupper(as.character(config$model %||% summary_model)[1])
    method <- public_mfrm_method_label(as.character(config$method %||% summary_method)[1])
    population_active <- isTRUE(population$active)
    population_sd <- if (population_active) {
        sqrt(suppressWarnings(as.numeric(population$sigma2 %||% NA_real_)[1]))
    }
    else if (identical(method, "MML")) {
        1
    }
    else {
        NA_real_
    }
    if (!is.finite(population_sd) || population_sd <= 0) {
        population_sd <- NA_real_
    }
    coordinate_basis <- if (identical(method, "MML") && population_active && !is.null(population$fixed_sd)) {
        "estimated_population_mean_fixed_sd"
    }
    else if (identical(method, "MML") && population_active) {
        "estimated_population_scale"
    }
    else if (identical(method, "MML")) {
        "fixed_standard_normal"
    }
    else {
        "joint_person_coordinate_scale"
    }
    product_slopes <- identical(model, "GPCM") && !is.null(config$gpcm_spec$component_levels)
    if (product_slopes) {
        mfrm_gpcm_slope_roles(config)
        if (population_active) 
            stop("Product-slope summaries require the fitted fixed population scale.", call. = FALSE)
    }
    slope_basis <- if (product_slopes) {
        "owner_specific_product_discrimination"
    }
    else if (identical(model, "GPCM")) {
        "geometric_mean_one_relative_discrimination"
    }
    else {
        "unit_discrimination"
    }
    estimator_family <- if (!identical(model, "GPCM")) {
        "not_applicable"
    }
    else if (identical(method, "JML")) {
        "unpenalized_identified_jml"
    }
    else {
        "marginal_maximum_likelihood"
    }
    extreme_person_policy <- if (!identical(model, "GPCM")) {
        "not_applicable"
    }
    else if (identical(method, "JML")) {
        "extended_real_primary_when_certified"
    }
    else {
        "posterior_eap_under_population_model"
    }
    gpcm_identity <- mfrmr_gpcm_model_identity(model, config$gpcm_spec)
    out <- tibble::tibble(Model = model, Method = method, CoordinateBasis = coordinate_basis, PopulationSD = population_sd, 
        SlopeBasis = slope_basis, GpcmModelFamily = as.character(if (product_slopes) gpcm_identity$model_family else config$gpcm_model_family %||% 
            gpcm_identity$model_family), GpcmSlopeAction = as.character(config$gpcm_slope_action %||% 
            gpcm_identity$slope_action), GpcmSlopeComposition = as.character(if (product_slopes) gpcm_identity$slope_composition else config$gpcm_slope_composition %||% 
            gpcm_identity$slope_composition), GpcmLatentDimensionCount = as.integer(config$gpcm_latent_dimension_count %||% 
            gpcm_identity$latent_dimension_count), GpcmMmlIdentification = as.character(if (product_slopes) "fixed_population_first_family_gm1" else config$gpcm_mml_identification %||% 
            "not_applicable"), GpcmEstimatorFamily = as.character(config$gpcm_estimator_family %||% estimator_family), 
        GpcmStatisticalPenalty = as.character(config$gpcm_statistical_penalty %||% if (identical(model, 
            "GPCM")) "none" else "not_applicable"), GpcmFiniteParameterBox = if (identical(model, "GPCM")) {
            isTRUE(config$gpcm_finite_parameter_box)
        }
        else {
            NA
        }, GpcmExtremePersonPolicy = as.character(config$gpcm_extreme_person_policy %||% extreme_person_policy), 
        FixedLatentSDSlopeField = if (identical(model, "GPCM") && identical(method, "MML")) {
            if (product_slopes) 
                "OptimizerEstimate"
            else "FixedLatentSDOptimizerEstimate"
        }
        else {
            NA_character_
        })
    out
}

mfrm_fit_slope_overview <- function(config, slopes) {
    if (!nrow(slopes) || !"Estimate" %in% names(slopes)) 
        return(tibble::tibble())
    roles <- mfrm_gpcm_slope_roles(config)
    product <- !is.null(config$gpcm_spec$component_levels)
    if (product) {
        metadata <- mfrm_gpcm_product_metadata(config$gpcm_spec)
        index <- mfrm_match_slope_table(metadata$Owner, metadata$Level, slopes)
        if (anyNA(index) || nrow(slopes) != length(index)) {
            stop("Slope summaries require every fitted owner and level exactly once.", call. = FALSE)
        }
        slopes <- slopes[index, , drop = FALSE]
    }
    rows <- lapply(seq_len(nrow(roles)), function(i) {
        slope_tbl <- if (product) 
            slopes[slopes$SlopeOwner == roles$SlopeOwner[i], , drop = FALSE]
        else slopes
        optimizer_slope <- if ("OptimizerEstimate" %in% names(slope_tbl)) {
            as.numeric(slope_tbl$OptimizerEstimate)
        }
        else {
            as.numeric(slope_tbl$Estimate)
        }
        primary_slope <- if ("PrimaryEstimate" %in% names(slope_tbl)) {
            as.numeric(slope_tbl$PrimaryEstimate)
        }
        else {
            as.numeric(slope_tbl$Estimate)
        }
        slope_range_value <- function(x, fun) {
            x <- x[is.finite(x)]
            if (length(x) == 0L) 
                return(NA_real_)
            fun(x)
        }
        slope_geometric_mean <- function(x) {
            x <- x[is.finite(x) & x > 0]
            if (length(x) == 0L) 
                return(NA_real_)
            exp(mean(log(x)))
        }
        parameter_status <- if ("ParameterStatus" %in% names(slope_tbl)) {
            paste(sort(unique(as.character(slope_tbl$ParameterStatus))), collapse = ",")
        }
        else {
            "legacy_unknown"
        }
        primary_ready <- length(primary_slope) > 0L && all(is.finite(primary_slope) & primary_slope > 
            0)
        value_basis <- if (primary_ready) {
            if (product && parameter_status %in% c("finite_numerical_solution", "finite_local_solution", 
                "finite_likelihood_limit")) 
                parameter_status
            else "primary"
        }
        else if (product && any(slope_tbl$ParameterStatus %in% "finite_likelihood_limit")) {
            "partial_likelihood_limit"
        }
        else if (identical(config$estimation_control$optimization_status, "not_run_boundary")) {
            "neutral_boundary_reference"
        }
        else if ("OptimizerEstimate" %in% names(slope_tbl)) {
            "optimizer_trace"
        }
        else {
            "legacy_estimate"
        }
        out <- tibble::tibble(SlopeOwner = roles$SlopeOwner[i], StepOwner = as.character(config$step_facet %||% 
            NA_character_)[1], OwnerInterpretation = "model_conditional_discrimination_not_rater_consistency", 
            Slopes = nrow(slope_tbl), ValueBasis = value_basis, ParameterStatus = parameter_status, PrimaryReady = primary_ready, 
            PrimaryFinite = sum(is.finite(primary_slope)), Min = slope_range_value(primary_slope, min), 
            Max = slope_range_value(primary_slope, max), GeometricMean = slope_geometric_mean(primary_slope), 
            Positive = if (primary_ready) 
                TRUE
            else NA, OptimizerMin = slope_range_value(optimizer_slope, min), OptimizerMax = slope_range_value(optimizer_slope, 
                max), OptimizerGeometricMean = slope_geometric_mean(optimizer_slope), OptimizerPositive = all(is.finite(optimizer_slope) & 
                optimizer_slope > 0), PopulationSD = if ("PopulationSD" %in% names(slope_tbl)) {
                as.numeric(slope_tbl$PopulationSD[1])
            }
            else {
                NA_real_
            }, FixedLatentSDOptimizerGeometricMean = if ("FixedLatentSDOptimizerEstimate" %in% names(slope_tbl)) {
                slope_geometric_mean(slope_tbl$FixedLatentSDOptimizerEstimate)
            }
            else {
                NA_real_
            }, FixedLatentSDBasis = if ("FixedLatentSDBasis" %in% names(slope_tbl)) {
                as.character(slope_tbl$FixedLatentSDBasis[1])
            }
            else {
                "not_available"
            }, SEEligible = if ("SEEligible" %in% names(slope_tbl)) {
                sum(as.logical(slope_tbl$SEEligible), na.rm = TRUE)
            }
            else {
                NA_integer_
            }, CIEligible = if ("CIEligible" %in% names(slope_tbl)) {
                sum(as.logical(slope_tbl$CIEligible), na.rm = TRUE)
            }
            else {
                NA_integer_
            }, ComparisonEligible = if ("ComparisonEligibility" %in% names(slope_tbl)) {
                sum(as.character(slope_tbl$ComparisonEligibility) == "eligible", na.rm = TRUE)
            }
            else {
                NA_integer_
            })
        if (product) {
            out$ScaleReference <- roles$ScaleReference[i]
            out$Identification <- roles$Identification[i]
        }
        out
    })
    dplyr::bind_rows(rows)
}

mfrm_fit_summary_core <- function(object, digits = 3, top_n = 5) {
    if (inherits(object, "mfrm_imported_fit")) {
        return(summary.mfrm_imported_fit(object, digits = digits))
    }
    if (is.null(object$summary) || nrow(object$summary) == 0) {
        stop("`object` does not contain fit summary information.")
    }
    digits <- max(0L, as.integer(digits))
    top_n <- max(1L, as.integer(top_n))
    config <- object$config %||% list()
    overview <- tibble::as_tibble(object$summary)
    if (identical(object$opt$value_basis, "neutral_boundary_reference")) {
        d <- mfrm_gmfrm_not_run_diagnostics(object$opt$optimizer_diagnostics)
        for (field in intersect(names(d), names(overview))) overview[[field]] <- d[[field]]
        record <- mfrmr_get_readiness_record(object)$fit
        for (field in intersect(names(record), names(overview))) overview[[field]] <- record[[field]]
    }
    if ("Method" %in% names(overview)) {
        overview$Method <- public_mfrm_method_label(overview$Method)
    }
    if (!"MethodUsed" %in% names(overview)) {
        overview$MethodUsed <- public_mfrm_method_label(config$method %||% NA_character_)
    }
    else {
        missing_used <- is.na(overview$MethodUsed) | !nzchar(trimws(as.character(overview$MethodUsed)))
        overview$MethodUsed[missing_used] <- as.character(config$method %||% NA_character_)
        overview$MethodUsed <- public_mfrm_method_label(overview$MethodUsed)
    }
    prep <- object$prep %||% list()
    data_review <- object$data_review %||% list()
    population_raw <- object$population %||% list()
    person_raw <- object$facets$person
    if (is.null(person_raw)) 
        person_raw <- tibble::tibble()
    other_raw <- object$facets$others
    if (is.null(other_raw)) 
        other_raw <- tibble::tibble()
    step_raw <- object$steps
    if (is.null(step_raw)) 
        step_raw <- tibble::tibble()
    slope_raw <- object$slopes
    if (is.null(slope_raw)) 
        slope_raw <- tibble::tibble()
    interaction_raw <- object$interactions$effects
    if (is.null(interaction_raw)) 
        interaction_raw <- tibble::tibble()
    person_tbl <- tibble::as_tibble(person_raw)
    other_tbl <- tibble::as_tibble(other_raw)
    step_tbl <- tibble::as_tibble(step_raw)
    slope_tbl <- tibble::as_tibble(slope_raw)
    interaction_tbl <- tibble::as_tibble(interaction_raw)
    scale_contract <- mfrm_fit_scale_contract(object)
    population_coding <- population_coding_summary_table(population_raw)
    population_coding_variables <- if (nrow(population_coding) > 0L) {
        paste(population_coding$Variable, collapse = ", ")
    }
    else {
        ""
    }
    population_contrast_variables <- if (nrow(population_coding) > 0L) {
        paste(population_coding$Variable[nzchar(population_coding$Contrast)], collapse = ", ")
    }
    else {
        ""
    }
    population_overview <- tibble::tibble(PopulationModel = isTRUE(population_raw$active), PosteriorBasis = as.character(population_raw$posterior_basis %||% 
        "legacy_mml"), Source = as.character(population_raw$source %||% "none"), IdentificationRole = as.character(population_raw$identification_role %||% 
        "not_applicable"), Formula = if (!is.null(population_raw$formula)) 
        paste(deparse(population_raw$formula), collapse = " ")
    else NA_character_, PersonRows = if (!is.null(population_raw$person_table)) 
        nrow(as.data.frame(population_raw$person_table, stringsAsFactors = FALSE))
    else NA_integer_, DesignColumns = if (!is.null(population_raw$design_matrix)) 
        ncol(population_raw$design_matrix)
    else NA_integer_, CodingVariables = population_coding_variables, ContrastVariables = population_contrast_variables, 
        Policy = as.character(population_raw$policy %||% NA_character_), EstimationConverged = isTRUE(population_raw$estimation_converged %||% 
            object$summary$Converged[1] %||% FALSE), InferenceReady = isTRUE(population_raw$inference_ready %||% 
            object$summary$InferenceReady[1] %||% FALSE), LegacyConvergedBasis = as.character(population_raw$converged_basis %||% 
            "legacy_unspecified"), ResidualVariance = as.numeric(population_raw$sigma2 %||% NA_real_), 
        ResidualVarianceStatus = if (!isTRUE(population_raw$active)) 
            "not_estimated"
        else if (is.null(population_raw$fixed_sd)) 
            "estimated"
        else "fixed", OmittedPersons = length(population_raw$omitted_persons %||% character(0)), OmittedRows = as.integer(population_raw$response_rows_omitted %||% 
            NA_integer_))
    population_coefficients <- tibble::tibble()
    if (isTRUE(population_raw$active) && length(population_raw$coefficients %||% numeric(0)) > 0) {
        coeff <- as.numeric(population_raw$coefficients)
        coeff_names <- names(population_raw$coefficients)
        if (is.null(coeff_names) || length(coeff_names) != length(coeff)) {
            coeff_names <- paste0("beta_", seq_along(coeff))
        }
        population_coefficients <- tibble::tibble(Term = as.character(coeff_names), Estimate = coeff)
    }
    population_design <- tibble::tibble()
    if (isTRUE(population_raw$active) && !is.null(population_raw$design_matrix)) {
        design_matrix <- as.matrix(population_raw$design_matrix)
        storage.mode(design_matrix) <- "double"
        if (ncol(design_matrix) > 0L) {
            design_columns <- colnames(design_matrix)
            if (is.null(design_columns) || length(design_columns) != ncol(design_matrix)) {
                design_columns <- paste0("X", seq_len(ncol(design_matrix)))
            }
            col_finite <- function(j) {
                vals <- as.numeric(design_matrix[, j])
                vals[is.finite(vals)]
            }
            col_stat <- function(j, fn) {
                vals <- col_finite(j)
                if (length(vals) == 0L) 
                  return(NA_real_)
                fn(vals)
            }
            col_sd <- function(j) {
                vals <- col_finite(j)
                if (length(vals) <= 1L) 
                  return(0)
                stats::sd(vals)
            }
            col_seq <- seq_len(ncol(design_matrix))
            non_missing <- vapply(col_seq, function(j) length(col_finite(j)), integer(1))
            sd_values <- vapply(col_seq, col_sd, numeric(1))
            population_design <- tibble::tibble(Column = as.character(design_columns), IsIntercept = as.character(design_columns) == 
                "(Intercept)", PersonRows = nrow(design_matrix), NonMissing = non_missing, Complete = non_missing == 
                nrow(design_matrix), Mean = vapply(col_seq, col_stat, numeric(1), fn = mean), SD = sd_values, 
                Min = vapply(col_seq, col_stat, numeric(1), fn = min), Max = vapply(col_seq, col_stat, 
                  numeric(1), fn = max), ZeroVariance = non_missing <= 1L | sd_values <= sqrt(.Machine$double.eps))
        }
    }
    facet_overview <- tibble::tibble()
    if (nrow(other_tbl) > 0 && all(c("Facet", "Estimate") %in% names(other_tbl))) {
        facet_overview <- dplyr::arrange(dplyr::summarise(dplyr::group_by(other_tbl, .data$Facet), Levels = dplyr::n(), 
            MeanEstimate = mean(.data$Estimate, na.rm = TRUE), SDEstimate = stats::sd(.data$Estimate, 
                na.rm = TRUE), MinEstimate = min(.data$Estimate, na.rm = TRUE), MaxEstimate = max(.data$Estimate, 
                na.rm = TRUE), Span = .data$MaxEstimate - .data$MinEstimate, .groups = "drop"), .data$Facet)
    }
    person_distribution_excluded <- rep(FALSE, nrow(person_tbl))
    if (nrow(person_tbl) > 0L && all(c("SourceFitReadiness", "ReasonCodes") %in% names(person_tbl))) {
        person_distribution_excluded <- as.character(person_tbl$SourceFitReadiness) == "blocked" & grepl("(^|;)mml_extreme_response_prior_regularized($|;)", 
            as.character(person_tbl$ReasonCodes))
    }
    person_distribution_tbl <- person_tbl[!person_distribution_excluded, , drop = FALSE]
    person_distribution_excluded_n <- sum(person_distribution_excluded)
    person_overview <- tibble::tibble()
    if (nrow(person_tbl) > 0 && "Estimate" %in% names(person_tbl)) {
        distribution_estimates <- as.numeric(person_distribution_tbl$Estimate)
        distribution_estimates <- distribution_estimates[is.finite(distribution_estimates)]
        distribution_value <- function(fun) {
            if (length(distribution_estimates) == 0L) 
                return(NA_real_)
            fun(distribution_estimates)
        }
        distribution_use <- if (person_distribution_excluded_n > 0L) {
            "review_only_blocked_extreme_eap_excluded"
        }
        else if ("SourceInferenceReady" %in% names(person_tbl) && all(person_tbl$SourceInferenceReady %in% 
            TRUE)) {
            "source_fit_ready"
        }
        else {
            "review_only_source_fit_not_ready"
        }
        person_overview <- tibble::tibble(Persons = nrow(person_tbl), DistributionN = length(distribution_estimates), 
            ReviewExcludedExtremeEAPs = person_distribution_excluded_n, EstimateUse = distribution_use, 
            Mean = distribution_value(mean), SD = if (length(distribution_estimates) > 1L) {
                stats::sd(distribution_estimates)
            }
            else {
                NA_real_
            }, Median = distribution_value(stats::median), Min = distribution_value(min), Max = distribution_value(max), 
            Span = if (length(distribution_estimates) > 0L) {
                max(distribution_estimates) - min(distribution_estimates)
            }
            else {
                NA_real_
            })
        if ("SD" %in% names(person_tbl)) {
            posterior_sd <- as.numeric(person_distribution_tbl$SD)
            posterior_sd <- posterior_sd[is.finite(posterior_sd)]
            person_overview$MeanPosteriorSD <- if (length(posterior_sd) > 0L) {
                mean(posterior_sd)
            }
            else {
                NA_real_
            }
        }
    }
    targeting_overview <- tibble::tibble()
    if (nrow(person_overview) > 0 && nrow(facet_overview) > 0) {
        person_mean <- as.numeric(person_overview$Mean[1])
        person_sd <- as.numeric(person_overview$SD[1])
        targeting_overview <- dplyr::transmute(facet_overview, Facet = .data$Facet, PersonMean = person_mean, 
            FacetMean = .data$MeanEstimate, Targeting = person_mean - .data$MeanEstimate, PersonSD = person_sd, 
            FacetSD = .data$SDEstimate, SpreadRatio = person_sd/dplyr::na_if(.data$SDEstimate, 0))
    }
    step_overview <- tibble::tibble()
    if (nrow(step_tbl) > 0 && all(c("Step", "Estimate") %in% names(step_tbl))) {
        summarize_step_ladder <- function(tbl, step_facet = NULL) {
            ord <- order(step_index_from_label(tbl$Step))
            step_vals <- suppressWarnings(as.numeric(tbl$Estimate[ord]))
            finite_vals <- step_vals[is.finite(step_vals)]
            monotonic <- if (length(finite_vals) <= 1L) {
                TRUE
            }
            else {
                all(diff(finite_vals) >= -sqrt(.Machine$double.eps))
            }
            out <- tibble::tibble(Steps = nrow(tbl), Min = if (length(finite_vals) > 0L) 
                min(finite_vals)
            else NA_real_, Max = if (length(finite_vals) > 0L) 
                max(finite_vals)
            else NA_real_, Span = if (length(finite_vals) > 0L) {
                max(finite_vals) - min(finite_vals)
            }
            else {
                NA_real_
            }, Monotonic = monotonic)
            if (!is.null(step_facet)) {
                out <- dplyr::mutate(out, StepFacet = as.character(step_facet), .before = 1L)
            }
            out
        }
        step_model <- toupper(as.character(config$model %||% overview$Model[1] %||% "RSM")[1])
        facet_specific_steps <- step_model %in% c("PCM", "GPCM") && "StepFacet" %in% names(step_tbl)
        if (facet_specific_steps) {
            step_facets <- unique(as.character(step_tbl$StepFacet))
            step_overview <- dplyr::bind_rows(lapply(step_facets, function(step_facet) {
                summarize_step_ladder(step_tbl[as.character(step_tbl$StepFacet) == step_facet, , drop = FALSE], 
                  step_facet = step_facet)
            }))
        }
        else {
            step_overview <- summarize_step_ladder(step_tbl)
        }
    }
    slope_overview <- mfrm_fit_slope_overview(config, slope_tbl)
    inference_evidence <- mfrm_gpcm_mml_inference_evidence(object)
    interaction_overview <- tibble::tibble()
    if (nrow(interaction_tbl) > 0 && all(c("Interaction", "Estimate", "N", "Sparse") %in% names(interaction_tbl))) {
        interaction_overview <- dplyr::summarise(dplyr::group_by(interaction_tbl, .data$Interaction), 
            Cells = dplyr::n(), SparseCells = sum(.data$Sparse, na.rm = TRUE), MinN = suppressWarnings(min(.data$N, 
                na.rm = TRUE)), MaxAbsEstimate = max(abs(.data$Estimate), na.rm = TRUE), .groups = "drop")
    }
    settings_overview <- tibble::tibble(StepFacet = as.character(config$step_facet %||% NA_character_), 
        StepFacetSource = as.character(config$step_facet_source %||% "unknown"), StepFacetNote = as.character(config$step_facet_note %||% 
            ""), SlopeFacet = as.character(config$slope_facet %||% NA_character_), GpcmMmlIdentification = as.character(config$gpcm_mml_identification %||% 
            "not_recorded"), GpcmMmlInitialization = as.character(config$estimation_control$gpcm_mml_start %||% 
            if (mfrm_has_product_slopes(object) && mfrmr_adaptive_integration(config)) "neutral (legacy)" else "not_applicable"), 
        GpcmMmlSelectedStart = as.character(object$opt$mml_initialization$selected %||% NA_character_), 
        GpcmCommonDiscrimination = as.character(config$gpcm_common_discrimination %||% "not_recorded"), 
        GpcmModelFamily = as.character(scale_contract$GpcmModelFamily[1]), GpcmSlopeAction = as.character(scale_contract$GpcmSlopeAction[1]), 
        GpcmSlopeComposition = as.character(scale_contract$GpcmSlopeComposition[1]), GpcmLatentDimensionCount = as.integer(scale_contract$GpcmLatentDimensionCount[1]), 
        GpcmEstimatorFamily = as.character(scale_contract$GpcmEstimatorFamily[1]), GpcmStatisticalPenalty = as.character(scale_contract$GpcmStatisticalPenalty[1]), 
        GpcmFiniteParameterBox = scale_contract$GpcmFiniteParameterBox[1], GpcmExtremePersonPolicy = as.character(scale_contract$GpcmExtremePersonPolicy[1]), 
        NoncenterFacet = as.character(config$noncenter_facet %||% "Person"), CenteringScope = mfrm_centering_scope(config), 
        WeightColumn = as.character(config$weight_col %||% NA_character_), QuadPoints = as.integer(config$estimation_control$quad_points %||% 
            NA_integer_), MMLIntegration = if (identical(config$method, "MML")) {
            as.character(config$estimation_control$mml_integration %||% "fixed")
        }
        else "not_applicable_jml", MMLAccuracyStatus = config$mml_accuracy$status %||% "not_requested", 
        RatingMin = as.numeric(config$rating_min %||% prep$rating_min %||% NA_real_), RatingMax = as.numeric(config$rating_max %||% 
            prep$rating_max %||% NA_real_), RatingRangeSource = as.character(config$rating_range_source %||% 
            prep$rating_range_source %||% "unknown"), RatingMinSource = as.character(config$rating_min_source %||% 
            prep$rating_min_source %||% "unknown"), RatingMaxSource = as.character(config$rating_max_source %||% 
            prep$rating_max_source %||% "unknown"), DummyFacets = if (length(config$dummy_facets %||% 
            character(0)) > 0L) {
            paste(sort(as.character(config$dummy_facets)), collapse = ", ")
        }
        else {
            ""
        }, PositiveFacets = if (length(config$positive_facets %||% character(0)) > 0L) {
            paste(sort(as.character(config$positive_facets)), collapse = ", ")
        }
        else {
            ""
        }, FacetInteractions = if (length(config$facet_interactions %||% character(0)) > 0L) {
            paste(as.character(config$facet_interactions), collapse = ", ")
        }
        else {
            ""
        }, UnusedScoreCategories = "", UnusedScoreCategoryCount = 0L, UnusedScoreCategoryType = "none", 
        !!!mfrm_category_settings(prep, config))
    score_category_profile <- score_category_support_profile(prep = prep)
    score_category_caveats <- collect_mfrm_caveats(fit = object)
    population_caveats <- collect_mfrm_population_caveats(population_overview = population_overview, 
        population_design = population_design, population_coefficients = population_coefficients)
    fit_caveats <- dplyr::bind_rows(score_category_caveats, population_caveats)
    unused_rows <- if (nrow(score_category_profile) > 0 && "ZeroCount" %in% names(score_category_profile)) {
        score_category_profile[as.logical(score_category_profile$ZeroCount), , drop = FALSE]
    }
    else {
        data.frame()
    }
    unused_score_categories <- sort(unique(as.integer(unused_rows$Category %||% integer(0))))
    unused_score_categories <- unused_score_categories[is.finite(unused_score_categories)]
    unused_score_category_type <- "none"
    if (nrow(unused_rows) > 0L && "UnusedCategoryType" %in% names(unused_rows)) {
        internal_unused <- unused_rows$UnusedCategoryType == "internal"
        unused_score_category_type <- dplyr::case_when(any(internal_unused) && any(!internal_unused) ~ 
            "mixed", any(internal_unused) ~ "internal", TRUE ~ "boundary")
        settings_overview$UnusedScoreCategories[] <- paste(unused_score_categories, collapse = ", ")
        settings_overview$UnusedScoreCategoryCount[] <- length(unused_score_categories)
        settings_overview$UnusedScoreCategoryType[] <- unused_score_category_type
    }
    reporting_map <- tibble::tibble(Area = c("Model identification / convergence", "Data structure / missingness", 
        "Reliability / fit / residual PCA", "Category functioning", "Bias / DIF / interaction checks", 
        "Draft reporting / checklist"), CoveredHere = c("yes", "no", "no", "partial", "no", "no"), CompanionOutput = c("summary(fit)", 
        "summary(describe_mfrm_data(...))", "summary(diagnose_mfrm(fit))", "rating_scale_table() / mfrm_report(fit, type = 'category_structure') / mfrm_report(fit, type = 'category_curves')", 
        "summary(estimate_bias(...)) / analyze_dff() / related bundle summaries", "mfrm_report(fit, type = 'checklist') / summary(build_apa_outputs(...))"))
    facet_extremes <- tibble::tibble()
    if (nrow(other_tbl) > 0 && all(c("Facet", "Level", "Estimate") %in% names(other_tbl))) {
        facet_extremes <- dplyr::select(dplyr::slice_head(dplyr::arrange(dplyr::mutate(other_tbl, AbsEstimate = abs(.data$Estimate)), 
            dplyr::desc(.data$AbsEstimate)), n = top_n), "Facet", "Level", "Estimate")
    }
    facet_support_boundaries <- mfrm_summary_facet_support_boundaries(object)
    facet_recession_review <- mfrm_summary_facet_recession_review(object)
    person_high <- tibble::tibble()
    person_low <- tibble::tibble()
    if (nrow(person_tbl) > 0 && all(c("Person", "Estimate") %in% names(person_tbl))) {
        person_high <- dplyr::slice_head(dplyr::arrange(person_tbl, dplyr::desc(.data$Estimate)), n = top_n)
        person_low <- dplyr::slice_head(dplyr::arrange(person_tbl, .data$Estimate), n = top_n)
    }
    notes <- character(0)
    convergence_severity_note <- as.character(overview$ConvergenceSeverity[1] %||% NA_character_)
    if (identical(convergence_severity_note, "review") && identical(as.character(overview$ConvergenceStatus[1] %||% 
        ""), "converged_gradient_review")) {
        notes <- c(notes, "The optimizer returned code 0, but the terminal gradient exceeded the review tolerance; confirm stability before reporting.")
    }
    else if ("Converged" %in% names(overview) && !isTRUE(overview$Converged[1])) {
        status <- as.character(overview$ConvergenceStatus[1] %||% NA_character_)
        if (identical(status, "not_run_boundary")) {
            notes <- c(notes, "Full-model optimization was deliberately not run because no finite maximum exists; inspect the separately recorded limiting estimates.")
        }
        else if (identical(status, "iteration_limit")) {
            notes <- c(notes, "The iteration ceiling was reached before numerical readiness; estimates are review-only and must not be used to select a preferred result.")
        }
        else if (identical(status, "reviewable_warning")) {
            notes <- c(notes, "Optimizer returned a nonzero code, but the terminal gradient was already small; treat the fit as reviewable rather than an immediate hard failure.")
        }
        else {
            notes <- c(notes, "Optimization did not converge; interpret parameter estimates cautiously.")
        }
    }
    if (person_distribution_excluded_n > 0L) {
        notes <- c(notes, paste0("Person distribution and targeting summaries omit ", person_distribution_excluded_n, 
            " prior-regularized extreme EAP(s) from the blocked source fit; ", "the exact review-only values remain in the highest/lowest Person tables."))
    }
    if (identical(as.character(overview$Method[1] %||% NA_character_), "MML")) {
        engine_requested <- as.character(overview$MMLEngineRequested[1] %||% NA_character_)
        engine_used <- as.character(overview$MMLEngineUsed[1] %||% NA_character_)
        if (!is.na(engine_requested) && !is.na(engine_used) && !identical(engine_requested, engine_used)) {
            notes <- c(notes, paste0("Requested mml_engine = '", engine_requested, "' was not available for this fit; the run used '", 
                engine_used, "' instead."))
        }
    }
    if (nrow(population_overview) > 0 && !isTRUE(population_overview$PopulationModel[1])) {
        fit_method <- as.character(overview$Method[1] %||% NA_character_)
        if (identical(fit_method, "MML")) {
            notes <- c(notes, "No population model was requested; MML used an unconditional normal person distribution.")
        }
    }
    else if (nrow(population_overview) > 0 && isTRUE(population_overview$PopulationModel[1])) {
        notes <- c(notes, "Population-model coefficients and residual variance describe the conditional normal prior used in the latent-regression MML branch.")
        if (nrow(population_coding) > 0L) {
            notes <- c(notes, "Categorical population-model coding is stored in `population_coding`; reuse those fitted levels and contrasts when scoring new persons.")
        }
    }
    if (nrow(step_overview) > 0 && any(step_overview$Monotonic == FALSE, na.rm = TRUE)) {
        notes <- c(notes, "Step estimates are not monotonic; verify category functioning.")
    }
    fit_caveat_messages <- if (nrow(fit_caveats) > 0 && "Message" %in% names(fit_caveats)) {
        as.character(fit_caveats$Message)
    }
    else {
        character(0)
    }
    if (length(fit_caveat_messages) > 0L) {
        notes <- c(notes, fit_caveat_messages)
    }
    if (nrow(slope_overview) > 0) {
        notes <- c(notes, if (!is.null(config$gpcm_spec$component_levels)) paste("GPCM slopes multiply across the two declared facets. Only the first", 
            "family has geometric mean one; the second is free on the fixed", "standard-normal ability scale. A second-family slope of one is not", 
            "the average of that family. Read point_estimation and the target-specific", "status separately from interval eligibility; optimizer traces do not supply inference.") else paste("GPCM discriminations use positive log-slope identification with", 
            "geometric-mean-one scaling; primary summaries remain missing until", "parameter readiness is established, while finite optimizer traces", 
            "are labelled separately. The configured slope owner identifies", "model-conditional discrimination and must not be relabelled as", 
            "rater consistency."))
    }
    if (nrow(interaction_overview) > 0) {
        notes <- c(notes, "Facet interactions are model-estimated fixed effects with zero marginal sums; interpret them as deviations from the additive main-effects MFRM.")
    }
    if (nrow(facet_support_boundaries) > 0L) {
        notes <- c(notes, paste("Observed boundary-constant facet levels are support/separation warnings;", 
            "a finite optimizer or MML estimate does not by itself establish", "regularization or an interior maximum for that facet parameter."))
    }
    if (nrow(facet_recession_review) > 0L && any(facet_recession_review$AuditScope == "joint_person_structural")) {
        notes <- c(notes, paste("Certified joint JML facet directions are relative, jointly identified", 
            "recession directions. Under sum-to-zero coding, compensating levels", "can be flagged and must not be read as independent extreme-response levels."))
    }
    if (length(notes) == 0) {
        notes <- "No immediate warnings from fit-level summary checks."
    }
    method_label <- as.character(overview$Method[1] %||% NA_character_)
    model_label <- as.character(overview$Model[1] %||% NA_character_)
    convergence_status <- as.character(overview$ConvergenceStatus[1] %||% NA_character_)
    convergence_severity <- as.character(overview$ConvergenceSeverity[1] %||% NA_character_)
    converged <- isTRUE(overview$Converged[1])
    engine_requested <- as.character(overview$MMLEngineRequested[1] %||% NA_character_)
    engine_used <- as.character(overview$MMLEngineUsed[1] %||% NA_character_)
    stored_readiness <- as.data.frame(mfrmr_get_readiness_record(object)$fit, stringsAsFactors = FALSE)
    has_stored_readiness <- nrow(stored_readiness) == 1L && "ReadinessContractVersion" %in% names(stored_readiness) && 
        identical(as.character(stored_readiness$ReadinessContractVersion[1]), mfrmr_readiness_contract_version())
    stored_value <- function(field, default = NA_character_) {
        if (has_stored_readiness && field %in% names(stored_readiness)) {
            stored_readiness[[field]][1]
        }
        else {
            default
        }
    }
    fit_readiness_state <- as.character(stored_value("FitReadiness", "legacy_unknown"))
    review_status <- as.data.frame(data_review$status %||% data.frame(), stringsAsFactors = FALSE)
    domain_status <- function(domain, default = "not_assessed") {
        if (nrow(review_status) == 0L || !all(c("Domain", "Status") %in% names(review_status))) 
            return(default)
        value <- review_status$Status[match(domain, review_status$Domain)]
        if (length(value) == 0L || is.na(value[1L]) || !nzchar(value[1L])) {
            default
        }
        else {
            as.character(value[1L])
        }
    }
    data_status <- if (has_stored_readiness) {
        switch(as.character(stored_value("InputState", "legacy_unknown")), pass = "pass", review = "review", 
            blocked = "blocked", legacy_unknown = "legacy_unknown", "not_assessed")
    }
    else {
        domain_status("Data")
    }
    design_status <- domain_status("Design")
    stability_status <- domain_status("Stability")
    numerical_status <- if (has_stored_readiness) {
        switch(as.character(stored_value("NumericalState", "legacy_unknown")), ready = "pass", review = "review", 
            failed = "fail", not_run = "not_run", legacy_unknown = "legacy_unknown", "not_assessed")
    }
    else {
        dplyr::case_when(identical(convergence_severity, "pass") && converged ~ "pass", identical(convergence_severity, 
            "review") ~ "review", TRUE ~ "fail")
    }
    reporting_readiness <- dplyr::case_when(identical(fit_readiness_state, "blocked") ~ "blocked_by_fit_readiness", 
        identical(fit_readiness_state, "legacy_unknown") && has_stored_readiness ~ "legacy_reaudit_or_refit_required", 
        startsWith(design_status, "hold_") ~ "hold_for_design_review", startsWith(stability_status, "hold_") ~ 
            "hold_for_stability_review", startsWith(design_status, "review_") ~ "review_design_before_reporting", 
        fit_readiness_state %in% c("review", "ready_with_exclusions") ~ "review_before_reporting", !identical(numerical_status, 
            "pass") ~ "review_before_reporting", !identical(data_status, "pass") ~ "review_data_before_reporting", 
        identical(method_label, "MML") ~ "ready_for_diagnostics_and_reporting_follow_up", TRUE ~ "exploratory_fit_ready_for_diagnostics")
    overall_status <- dplyr::case_when(identical(fit_readiness_state, "blocked") ~ "fit_blocked", identical(fit_readiness_state, 
        "review") ~ "review_required", identical(fit_readiness_state, "ready_with_exclusions") ~ "usable_with_exclusions", 
        identical(fit_readiness_state, "legacy_unknown") && has_stored_readiness ~ "legacy_review_required", 
        startsWith(design_status, "hold_") || startsWith(stability_status, "hold_") ~ "review_required", 
        identical(numerical_status, "review") ~ "reviewable_fit", identical(numerical_status, "fail") ~ 
            "fit_needs_review", startsWith(design_status, "review_") || !identical(data_status, "pass") ~ 
            "review_required", TRUE ~ "usable_fit")
    convergence_display <- switch(convergence_status, converged = "converged", converged_gradient_review = "optimizer stopped; terminal gradient needs review", 
        reviewable_warning = "optimizer warning with a small terminal gradient", iteration_limit = "iteration limit reached", 
        optimizer_warning = "optimizer warning", unknown = "unknown convergence status", convergence_status)
    convergence_line <- if (isTRUE(is.finite(overview$TerminalGradientSupNorm[1] %||% NA_real_))) {
        gradient_display <- trimws(formatC(as.numeric(overview$TerminalGradientSupNorm[1]), format = "g", 
            digits = max(3L, digits)))
        paste0(convergence_display, " (severity: ", convergence_severity, ", sup-norm: ", gradient_display, 
            ")")
    }
    else {
        paste0(convergence_status, " (severity: ", convergence_severity, ")")
    }
    engine_line <- if (identical(method_label, "MML") && !is.na(engine_used)) {
        if (!is.na(engine_requested) && !identical(engine_requested, engine_used)) {
            paste0(engine_used, " (requested ", engine_requested, ")")
        }
        else {
            engine_used
        }
    }
    else if (!is.na(method_label)) {
        method_label
    }
    else {
        NA_character_
    }
    status <- make_summary_block(`Overall status` = overall_status, Convergence = convergence_line, `Estimation path` = paste(model_label, 
        "/", engine_line), `Reporting readiness` = reporting_readiness)
    readiness <- data.frame(Domain = c("Fit", "Numerical", "Data", "Design", "Stability", "Diagnostics", 
        "Reporting"), Status = c(fit_readiness_state, numerical_status, data_status, design_status, stability_status, 
        "not_assessed", reporting_readiness), Detail = c(if (has_stored_readiness) {
        reasons <- as.character(stored_value("ReasonCodes", ""))
        if (nzchar(reasons)) {
            paste0("Stored readiness reasons: ", reasons, ".")
        } else {
            "All stored fit-readiness components passed."
        }
    } else {
        "No current stored fit-readiness contract is available."
    }, as.character(overview$ConvergenceDetail[1] %||% ""), if (identical(data_status, "pass")) {
        "No preparation warning or review row was retained."
    } else {
        "Review row retention, missing-code recoding, duplicate cells, and preparation notes."
    }, if (startsWith(design_status, "hold_")) {
        paste0("The observed multi-facet graph contains ", data_review$overall_connectivity$components %||% 
            NA_integer_, " disconnected subsets.")
    } else if (identical(design_status, "review_disconnected_with_anchors")) {
        paste0("The observed multi-facet graph is disconnected; supplied anchors ", "require an explicit linking and identification justification ", 
            "before cross-subset comparisons.")
    } else if (identical(design_status, "pass_linked")) {
        paste0("The observed graph satisfies the connectivity requirement; review ", "the remaining design and identification assumptions separately.")
    } else {
        "Observed multi-facet connectivity was not fully assessed."
    }, if (startsWith(stability_status, "hold_")) {
        "Boundary-constant or single-level facet support requires review."
    } else {
        "No boundary-constant non-person facet level was detected."
    }, "Diagnostics have not yet been incorporated into this fit-only status.", "Reporting status is the strictest applicable upstream workflow state."), 
        stringsAsFactors = FALSE)
    row_retention <- as.data.frame(prep$row_retention %||% data.frame(), stringsAsFactors = FALSE)
    preparation_notes <- as.data.frame(prep$preparation_notes %||% data.frame(), stringsAsFactors = FALSE)
    preparation_review_messages <- if (nrow(preparation_notes) > 0L && all(c("Severity", "Message") %in% 
        names(preparation_notes))) {
        preparation_notes$Message[tolower(as.character(preparation_notes$Severity)) %in% c("review", 
            "warning", "error")]
    }
    else {
        character(0)
    }
    key_warnings <- clean_summary_lines(c(fit_caveat_messages, preparation_review_messages, notes), max_n = 4L)
    next_actions <- c("After reviewing convergence, run `review <- summary(fit, profile = \"facets\", detail = \"brief\")` for the comprehensive measurement review; FACETS software is not required.", 
        "Then draw the complete native Wright map with `plot(fit, type = \"wright\", show_ci = TRUE, top_n = Inf, preset = \"publication\")`.")
    if (!identical(numerical_status, "pass")) {
        numerical_action <- if (identical(convergence_status, "iteration_limit")) {
            paste("Do not interpret or select estimates from this iteration-limited fit.", "Refit the same data, model, method, anchors, optimizer, tolerance, and quadrature rule", 
                "with the next ceiling in a prespecified `maxit` sequence; accept a result only after the Numerical criteria are satisfied.")
        }
        else {
            "Inspect `fit$opt$optimizer_polish$Stages` before changing controls; compare the retained objective, terminal gradient, and maximum parameter change, and keep the fit on review if bounded polishing did not satisfy the numerical-readiness criteria."
        }
        next_actions <- c(numerical_action, next_actions)
    }
    if (startsWith(design_status, "hold_") || startsWith(design_status, "review_")) {
        next_actions <- c("Resolve or justify the multi-facet connectivity state in `fit$data_review$overall_connectivity` before making common-scale or cross-subset claims.", 
            next_actions)
    }
    if (startsWith(stability_status, "hold_")) {
        next_actions <- c("Review `fit$data_review$boundary_levels` and facet support before interpreting separated or boundary-constant estimates.", 
            next_actions)
    }
    if (!identical(method_label, "MML")) {
        next_actions <- c(next_actions, "MML provides marginal diagnostics; review the resulting fit and uncertainty assumptions before using its SEs or intervals.")
    }
    if (nrow(population_overview) > 0 && isTRUE(population_overview$PopulationModel[1])) {
        next_actions <- c(next_actions, "Inspect `summary(fit)$population_coefficients` and `summary(fit)$population_coding` before reporting latent-regression effects.", 
            "For new persons, use `predict_mfrm_units(..., person_data = ...)` or `sample_mfrm_plausible_values(..., person_data = ...)` so scoring reuses the fitted population-model coding.", 
            "Report population coefficients as conditional-normal latent-regression parameters, not as a post hoc regression on EAP/MLE scores.")
    }
    if (identical(model_label, "GPCM")) {
        next_actions <- c(if (identical(method_label, "MML") && identical(numerical_status, "pass") && 
            !mfrm_inference_ready(object)) {
            paste("The optimizer already satisfied its numerical-readiness criteria; inspect", "`summary(fit)$inference_evidence` and", 
                "`diagnose_mfrm(fit)$parameter_uncertainty` before changing", "optimizer controls. Optimizer*SE remains diagnostic until", 
                "parameter readiness is established.")
        }, next_actions, "Use `compute_information()` / `plot(x)` for reporting-oriented precision follow-up.")
    }
    if (nrow(interaction_overview) > 0) {
        next_actions <- c(next_actions, "Inspect `interaction_effect_table(fit)` and compare the additive and interaction fits on the same likelihood basis before reporting interaction claims.")
    }
    next_actions <- c(next_actions, "Reuse `review$results$diagnostics`; call `diagnose_mfrm()` again only for residual PCA or other custom settings.", 
        "Use `mfrm_report(type = 'checklist', fit, diagnostics = review$results$diagnostics)` for reporting readiness.")
    next_actions <- clean_summary_lines(next_actions, max_n = 6L)
    if (!is.null(config$gpcm_spec$component_levels)) {
        next_actions <- c("Review numerical convergence separately from parameter and interval readiness.", 
            "Read each slope facet on its stated reference scale; retain unavailable primary estimates.", 
            "Use mfrm_curve_intervals(fit, newdata) for provisional response curves without intervals; ordinary diagnostics and Wright/Pathway plots are not available.", 
            "Separately request confint(fit, parm = 'slopes') / confint(fit, parm = 'steps') or mfrm_facet_intervals(fit, facet) for experimental component intervals. CIEligible records numerical availability; CoverageQualified = FALSE means coverage is unestablished, not zero.", 
            "Person posterior SDs condition on the fitted calibration and N(0,1) prior; they exclude calibration uncertainty and are not structural SEs. See help('mfrmr_gpcm_scope') for target-specific uncertainty.")
        reporting_map$CompanionOutput <- "Two-family diagnostics are not available"
        reporting_map$CompanionOutput[reporting_map$Area == "Model identification / convergence"] <- "Stored model and per-facet slope summaries"
    }
    decision <- mfrm_fit_decision_summary(stored_readiness, next_action = next_actions[1L] %||% NA_character_)
    attached_diagnostics_flag <- isTRUE(config$attached_diagnostics)
    attached_diagnostics_cols <- as.character(config$attached_diagnostics_cols %||% character(0))
    product_points <- if (mfrm_has_product_slopes(object) || !is.null(object$point_limit)) 
        mfrm_gpcm_product_point_tables(object)
    else list()
    out <- list(overview = overview, status = status, readiness = readiness, decision = decision, estimation_note = if (identical(method_label, 
        "JML") && !inherits(object, "mfrm_imported_fit")) paste("JML uses observed scores without an extreme-score adjustment or finite-item bias correction.", 
        "Independently free Person measures are infinite for all-minimum/all-maximum responses; finite optimizer values are computational traces.", 
        "JML SEs and normal bands remain exploratory.") else if (identical(method_label, "MML") && model_label %in% 
        c("RSM", "PCM", "GPCM") && identical(stored_value("BoundaryState"), "nonfinite_maximum")) paste("The full model has no finite maximum. Finite fitted structural coordinates are optimizer values,", 
        "not ordinary maximum-likelihood estimates. Person EAPs can remain finite under the assumed population distribution.") else character(0), 
        data_review = data_review, key_warnings = key_warnings, next_actions = next_actions, population_overview = population_overview, 
        population_design = population_design, population_coefficients = population_coefficients, population_coding = population_coding, 
        facet_overview = facet_overview, person_overview = person_overview, targeting = targeting_overview, 
        step_overview = step_overview, slope_overview = slope_overview, point_estimation = product_points$point_estimation %||% 
            data.frame(), rating_support = product_points$rating_support %||% data.frame(), rating_crossings = product_points$rating_crossings %||% 
            data.frame(), rating_categories = product_points$rating_categories %||% data.frame(), rating_support_notes = product_points$rating_support_notes %||% 
            data.frame(), point_targets = object$point_limit$targets %||% data.frame(), step_targets = object$point_limit$step_targets %||% 
            data.frame(), point_limit = object$point_limit$overview %||% data.frame(), inference_evidence = inference_evidence, 
        interaction_overview = interaction_overview, settings_overview = settings_overview, attached_diagnostics = attached_diagnostics_flag, 
        attached_diagnostics_cols = attached_diagnostics_cols, row_retention = row_retention, preparation_notes = preparation_notes, 
        reporting_map = reporting_map, caveats = fit_caveats, facet_extremes = facet_extremes, facet_support_boundaries = facet_support_boundaries, 
        facet_recession_review = facet_recession_review, person_high = person_high, person_low = person_low, 
        notes = notes, digits = digits)
    if (!is.null(object$opt$start_review)) {
        out$starting_values <- object$opt$start_review$table
        out$starting_value_notes <- object$opt$start_review$notes
    }
    out$numerical_review <- .mfrm_numerical_review(object)
    if (!identical(numerical_status, "pass")) 
        out$next_actions <- c("Read summary(fit)$numerical_review for separate optimization, curvature, starting-value, integration and reproducible-refit actions.", 
            out$next_actions)
    class(out) <- "summary.mfrm_fit"
    if (!is.null(object$point_limit$category_map)) 
        out$category_map <- object$point_limit$category_map
    mfrm_gpcm_boundary_summary(out, object)
}

mfrm_fit_summary_workflow <- function(object, ...) list()

round_numeric_df <- function(df, digits = 3L) {
    if (!is.data.frame(df) || nrow(df) == 0) 
        return(df)
    out <- df
    numeric_cols <- vapply(out, is.numeric, logical(1))
    out[numeric_cols] <- lapply(out[numeric_cols], round, digits = digits)
    out
}

clean_summary_lines <- function(lines, max_n = Inf) {
    if (length(lines) == 0) 
        return(character(0))
    lines <- trimws(as.character(lines))
    lines <- lines[!is.na(lines) & nzchar(lines)]
    lines <- unique(lines)
    if (is.finite(max_n) && length(lines) > max_n) {
        lines <- lines[seq_len(max_n)]
    }
    lines
}

make_summary_block <- function(...) {
    vals <- list(...)
    keys <- names(vals)
    if (is.null(keys)) {
        keys <- rep.int("", length(vals))
    }
    keep <- vapply(vals, function(x) {
        if (length(x) == 0) 
            return(FALSE)
        if (all(is.na(x))) 
            return(FALSE)
        if (is.character(x)) 
            return(any(nzchar(trimws(x))))
        TRUE
    }, logical(1))
    if (!any(keep)) {
        return(tibble::tibble(Item = character(0), Value = character(0)))
    }
    tibble::tibble(Item = keys[keep], Value = vapply(vals[keep], function(x) paste(x, collapse = " "), 
        character(1)))
}

mfrm_fit_decision_summary <- function(readiness, next_action = NA_character_, supports_formal_inference = NA, 
    precision_tier = NA_character_) {
    readiness <- as.data.frame(readiness %||% data.frame(), stringsAsFactors = FALSE)
    required <- c("InputState", "EstimabilityState", "CategoryState", "BoundaryState", "NumericalState", 
        "FitReadiness", "InferenceReady")
    if (nrow(readiness) != 1L || !all(required %in% names(readiness)) || !identical(as.character(readiness$ReadinessContractVersion), 
        mfrmr_readiness_contract_version())) {
        return(data.frame(Interpretation = "Re-audit or refit before interpretation", FormalInference = "No", 
            FitReadiness = "legacy_unknown", Why = "A current fit-readiness record is unavailable.", 
            NextAction = as.character(next_action)[1L], stringsAsFactors = FALSE))
    }
    value <- function(field) as.character(readiness[[field]][1L])
    fit_state <- value("FitReadiness")
    precision_known <- length(supports_formal_inference) == 1L && !is.na(supports_formal_inference)
    precision_supported <- precision_known && isTRUE(supports_formal_inference)
    fit_gate_ready <- isTRUE(readiness$InferenceReady[1L])
    formal_supported <- fit_gate_ready && precision_supported
    precision_tier <- as.character(precision_tier)[1L]
    interpretation <- switch(fit_state, ready = if (formal_supported) {
        "Ready for formal inference"
    } else if (precision_known) {
        "Fit-readiness requirements satisfied; formal inference is not supported"
    } else {
        "Fit-readiness requirements satisfied; formal precision review required"
    }, ready_with_exclusions = "Usable only with the recorded exclusions", review = "Review before reporting or inference", 
        blocked = "Do not interpret this fit", legacy_unknown = "Re-audit or refit before interpretation", 
        "Review before reporting or inference")
    reasons <- c(if ("nonunit_observation_weights_inference_unvalidated" %in% mfrmr_readiness_split_codes(readiness$ReasonCodes)) "Ordinary inference for non-unit observation weights is not validated", 
        if (value("InputState") == "review") "Input preparation requires review", if (value("InputState") == 
            "blocked") "The retained input is blocked", if (value("EstimabilityState") == "not_evaluated") "Identifiability evidence is incomplete", 
        if (value("EstimabilityState") == "weak_information") "The design provides weak information", 
        if (value("EstimabilityState") == "structurally_unidentified") "The model is structurally unidentified", 
        if (value("EstimabilityState") == "population_assumption_linked") "Identification depends on the population model", 
        if (value("CategoryState") == "weak_information") "One or more categories provide weak information", 
        if (value("CategoryState") == "unsupported_coordinate") "One or more category parameters are unsupported", 
        if (value("CategoryState") == "not_evaluated") "Category support is incomplete", if (value("BoundaryState") == 
            "has_exclusions") "One or more boundary parameters are excluded", if (value("BoundaryState") == 
            "not_evaluated") "Boundary evidence is incomplete", if (value("NumericalState") == "review") "Numerical convergence requires review", 
        if (value("BoundaryState") == "nonfinite_maximum") "The full model has no finite maximum", if (value("NumericalState") == 
            "not_run") "Numerical optimization was not run", if (value("NumericalState") == "failed") "Numerical convergence failed", 
        if (fit_gate_ready && !precision_known) "Formal precision support has not been evaluated", if (fit_gate_ready && 
            precision_known && !precision_supported) paste0("The available uncertainty estimates do not support formal inference", 
            if (!is.na(precision_tier) && nzchar(precision_tier)) {
                paste0(" (precision summary: ", precision_tier, ")")
            } else {
                ""
            }), if (fit_state == "legacy_unknown") "The saved fit needs an updated assessment of estimation and uncertainty")
    reasons <- unique(reasons[!is.na(reasons) & nzchar(reasons)])
    if (!length(reasons)) {
        reasons <- if (identical(fit_state, "ready")) {
            "All stored fit-readiness components passed."
        }
        else {
            "Review the stored readiness components before interpretation."
        }
    }
    else {
        reasons <- paste0(paste(reasons, collapse = "; "), ".")
    }
    if (any(c("mml_gpcm_slope_boundary_not_evaluated", "jml_gpcm_joint_boundary_not_evaluated", "jml_gpcm_joint_boundary_candidate") %in% 
        mfrmr_readiness_split_codes(readiness$ReasonCodes))) {
        reasons <- paste(reasons, "For GPCM MML, confint(fit, parm = 'slopes') separately checks approximate relative-slope intervals.", 
            "This does not certify global boundary absence or authorize other parameter intervals.", 
            "MML information-criterion comparison and matched PCM/GPCM tests have separate checks;", 
            "inspect ICComparable and the LRT status from compare_mfrm().")
    }
    mfrm_display_fit_decision(data.frame(Interpretation = interpretation, FormalInference = if (formal_supported) 
        "Yes"
    else "No", FitReadiness = fit_state, Why = paste(reasons, "These checks assess numerical readiness and the requested precision method under the specified model; they do not establish model adequacy or finite-sample coverage for this design."), 
        NextAction = as.character(next_action)[1L], stringsAsFactors = FALSE))
}

summary_lines_are_default <- function(lines, default_line) {
    lines <- clean_summary_lines(lines)
    length(lines) == 1L && identical(lines, default_line)
}

mfrm_decision_display_text <- function(text) {
    text <- as.character(text)
    replacements <- c(`Read the compact results summary.` = "Review fit_readiness$EstimabilityState and check eligibility in the requested interval table.", 
        `The precision contract does not support formal inference` = "The available uncertainty estimates do not support formal inference", 
        `the precision contract does not support` = "the available uncertainty estimates do not support", 
        `The stored readiness contract is not current` = "The saved fit needs an updated assessment of estimation and uncertainty")
    for (old in names(replacements)) {
        text <- gsub(old, replacements[[old]], text, fixed = TRUE)
    }
    labels <- c(model_based = "model-based precision", hybrid = "mixed model-based and fallback precision", 
        exploratory = "exploratory precision")
    for (prefix in c("tier", "precision summary")) {
        for (level in names(labels)) {
            text <- gsub(paste0("(", prefix, ": ", level, ")"), paste0("(", labels[[level]], ")"), text, 
                fixed = TRUE)
        }
    }
    gsub("\\((tier|precision summary): [^)]*\\)", "(precision assumptions require review)", text)
}

mfrm_display_fit_decision <- function(decision) {
    decision <- as.data.frame(decision %||% data.frame(), stringsAsFactors = FALSE)
    for (field in intersect(c("Why", "NextAction"), names(decision))) {
        decision[[field]] <- mfrm_decision_display_text(decision[[field]])
    }
    decision
}

print_fit_decision_section <- function(decision) {
    decision <- mfrm_display_fit_decision(decision)
    required <- c("Interpretation", "FormalInference", "FitReadiness", "Why", "NextAction")
    if (nrow(decision) != 1L || !all(required %in% names(decision))) {
        return(invisible(NULL))
    }
    why <- as.character(decision$Why[1L])
    print_bullet_section("Decision", c(paste0("Interpretation: ", decision$Interpretation[1L]), paste0("Formal inference: ", 
        decision$FormalInference[1L]), paste0("Why: ", why), if (!is.na(decision$NextAction[1L]) && nzchar(decision$NextAction[1L])) {
        paste0("Next: ", decision$NextAction[1L])
    }))
    invisible(NULL)
}

mfrm_mml_integration_console_lines <- function(summary_object) {
    overview <- as.data.frame(summary_object$overview %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(overview) == 0L || !identical(as.character(overview$Method[1] %||% ""), "MML")) {
        return(character(0))
    }
    settings <- as.data.frame(summary_object$settings_overview %||% data.frame(), stringsAsFactors = FALSE)
    population <- as.data.frame(summary_object$population_overview %||% data.frame(), stringsAsFactors = FALSE)
    engine_used <- as.character(overview$MMLEngineUsed[1] %||% "unknown")
    engine_requested <- as.character(overview$MMLEngineRequested[1] %||% engine_used)
    quad_points <- suppressWarnings(as.integer(settings$QuadPoints[1] %||% overview$ICQuadraturePoints[1] %||% 
        NA_integer_))
    integration <- paste0("MML engine: ", engine_used, " (requested: ", engine_requested, ") | ", "Integration: ", 
        if (identical(as.character(settings$MMLIntegration[1] %||% overview$MMLIntegration[1]), "adaptive")) {
            "adaptive Gauss-Hermite"
        }
        else "fixed non-adaptive Gauss-Hermite", ", q=", if (is.finite(quad_points)) 
            quad_points
        else "unknown", " | latent dimensions=1")
    population_text <- if (isTRUE(population$PopulationModel[1] %||% FALSE)) {
        formula <- gsub("[[:space:]]+", "", as.character(population$Formula[1] %||% ""))
        if (identical(formula, "~1")) {
            "Population identification: estimated N(beta0,sigma^2)"
        }
        else {
            "Population identification: estimated N(X beta,sigma^2)"
        }
    }
    else {
        "Population identification: fixed N(0,1)"
    }
    scale_text <- if (identical(settings$GpcmSlopeComposition[1], "two_owner_product_first_gm1")) {
        "product slopes: first family geometric mean=1; second family free"
    }
    else if (identical(as.character(overview$Model[1] %||% ""), "GPCM")) {
        "relative slopes: geometric mean=1"
    }
    else {
        "discrimination=1"
    }
    accuracy <- if (identical(settings$MMLAccuracyStatus[1], "criteria_met")) {
        "Automatic integration checks: criteria met; inference readiness is assessed separately."
    }
    else character()
    c(integration, accuracy, paste(population_text, scale_text, sep = " | "))
}

mfrm_console_width <- function() {
    width <- getOption("width", 80L)
    if (length(width) != 1L || !is.numeric(width) || is.na(width) || !is.finite(width)) {
        width <- 80L
    }
    min(100L, max(50L, as.integer(width)))
}

print_wrapped_line <- function(line, prefix = "  ") {
    line <- as.character(line)
    line <- line[!is.na(line) & nzchar(line)]
    if (!length(line)) 
        return(invisible(NULL))
    console_width <- mfrm_console_width()
    content_width <- max(30L, console_width - nchar(prefix))
    split_overlong <- function(value) {
        pieces <- character(0)
        remaining <- value
        while (nzchar(remaining)) {
            piece <- strtrim(remaining, content_width)
            if (!nzchar(piece)) 
                piece <- substr(remaining, 1L, 1L)
            pieces <- c(pieces, piece)
            remaining <- substring(remaining, nchar(piece, type = "chars") + 1L)
        }
        pieces
    }
    for (value in line) {
        wrapped <- strwrap(value, width = content_width)
        if (!length(wrapped)) 
            next
        wrapped <- unlist(lapply(wrapped, function(part) {
            if (nchar(part, type = "width") > content_width) {
                split_overlong(part)
            }
            else {
                part
            }
        }), use.names = FALSE)
        for (part in wrapped) cat(prefix, part, "\n", sep = "")
    }
    invisible(NULL)
}

print_bullet_section <- function(title, lines, prefix = " - ") {
    lines <- clean_summary_lines(lines)
    if (length(lines) == 0) 
        return(invisible(NULL))
    cat("\n", title, "\n", sep = "")
    console_width <- mfrm_console_width()
    content_width <- max(30L, console_width - nchar(prefix))
    continuation <- paste(rep(" ", nchar(prefix)), collapse = "")
    for (line in lines) {
        wrapped <- strwrap(line, width = content_width)
        if (length(wrapped) == 0L) 
            next
        cat(prefix, wrapped[1], "\n", sep = "")
        if (length(wrapped) > 1L) {
            for (part in wrapped[-1L]) cat(continuation, part, "\n", sep = "")
        }
    }
    invisible(NULL)
}

summary_note_display_table <- function(notes, preparation = FALSE) {
    notes <- as.data.frame(notes %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(notes) == 0L) 
        return(notes)
    keep <- intersect(if (preparation) 
        c("Stage", "Severity", "Condition", "Count", "Affected", "RecommendedAction")
    else c("Area", "Severity", "Condition", "Categories", "Message", "RecommendedAction"), names(notes))
    if (length(keep) == 0L) 
        return(notes)
    notes[, keep, drop = FALSE]
}

print_note_section <- function(notes, title = "Caveats", preparation = FALSE) {
    notes <- summary_note_display_table(notes, preparation = preparation)
    if (nrow(notes) == 0L) 
        return(invisible(NULL))
    cat("\n", title, "\n", sep = "")
    print(notes, row.names = FALSE)
    invisible(NULL)
}

mfrm_fit_display_status <- function(value) {
    labels <- c(ready = "Checks passed", pass = "Checks passed", available = "Available", ready_with_exclusions = "Use only with recorded exclusions", 
        review = "Review required", review_only = "Exploratory review only", blocked = "Do not interpret", 
        failed = "Failed", fail = "Failed", legacy_unknown = "Not established", not_assessed = "Not assessed", 
        not_evaluated = "Not assessed", not_available = "Unavailable", not_requested = "Not requested", 
        not_computed = "Not computed", error = "Computation failed", not_applicable = "Not applicable", 
        pass_linked = "Connectivity checked", review_before_reporting = "Review before reporting", ready_for_diagnostics_and_reporting_follow_up = "Ready for diagnostic review", 
        ready_for_diagnostic_interpretation = "Diagnostic interpretation available", review_disconnected_with_anchors = "Disconnected design; justify anchor linking", 
        hold_for_design_review = "Resolve design restrictions first", hold_for_stability_review = "Resolve boundary restrictions first", 
        stationary_candidate = "Numerical stationarity checked", optimizer_review = "Numerical convergence requires review", 
        optimizer_failed = "Numerical convergence failed", optimizer_not_evaluated = "Numerical convergence not assessed", 
        locally_positive_definite_at_recorded_tolerances = "Locally positive curvature at tested tolerances", 
        locally_full_rank_sufficient = "Full local rank at the retained point", locally_first_order_rank_deficient = "Local first-order rank deficient", 
        indeterminate_tolerance_sensitive = "Rank depends on numerical tolerance", not_evaluated_adaptive_quadrature = "Boundary check unavailable for adaptive integration", 
        source_fit_ready = "Subject to the fit's interpretation decision", review_only_source_fit_not_ready = "Exploratory; source fit requires review", 
        review_only_blocked_extreme_eap_excluded = "Exploratory; unsupported extreme scores excluded", 
        primary = "Reported estimates", optimizer_trace = "Optimizer traces only", finite_numerical_solution = "Point estimates at the chosen integration rule", 
        finite_local_solution = "Point estimates with local numerical checks", legacy_estimate = "Older estimates; interpretation requires review", 
        unbounded_low = "Unbounded below", unbounded_high = "Unbounded above", unbounded_both = "Unbounded in both directions", 
        structural_fixed_person = "Facet parameters with Person measures held fixed", joint_person_structural = "Person and facet parameters jointly")
    out <- unname(labels[as.character(value)])
    out[is.na(out)] <- "Review the stored result before interpretation"
    out
}

mfrm_fit_display_person_overview <- function(table) {
    table <- as.data.frame(table)
    if ("EstimateUse" %in% names(table)) {
        table$Interpretation <- mfrm_fit_display_status(table$EstimateUse)
        table$EstimateUse <- NULL
    }
    table
}

mfrm_gpcm_console_lines <- function(settings) {
    estimator <- switch(as.character(settings$GpcmEstimatorFamily[1]), marginal_maximum_likelihood = "marginal maximum likelihood", 
        unpenalized_identified_jml = "unpenalized joint maximum likelihood", "not established; inspect the stored fitting settings")
    penalty <- if (identical(settings$GpcmStatisticalPenalty[1], "none")) 
        "none"
    else "inspect the stored fitting settings"
    finite_box <- if (is.na(settings$GpcmFiniteParameterBox[1] %||% NA)) 
        "not recorded"
    else if (isTRUE(settings$GpcmFiniteParameterBox[1])) 
        "yes"
    else "no"
    c(sprintf("GPCM estimator: %s | Statistical penalty: %s | Finite parameter box: %s", estimator, penalty, 
        finite_box), if (identical(settings$GpcmSlopeAction[1], "complete_adjacent_predictor")) {
        "GPCM slopes multiply the complete adjacent-category predictor, including thresholds; they describe model-conditional discrimination, not rater consistency."
    } else "The recorded slope action requires review before interpreting discrimination.")
}

print.summary.mfrm_fit <- function(x, ...) {
    if (isTRUE(x$jml_adjustment)) 
        return(mfrm_jml_print_summary(x))
    digits <- x$digits
    if (is.null(digits) || !is.finite(digits)) 
        digits <- 3L
    profile <- as.character(x$profile %||% "fit")
    detail <- as.character(x$detail %||% "full")
    include_person <- isTRUE(x$include_person)
    overview_raw <- as.data.frame(x$overview)
    overview <- round_numeric_df(overview_raw, digits = digits)
    key_warning_lines <- if (summary_lines_are_default(x$key_warnings, "No immediate warnings from fit-level summary checks.")) {
        "None."
    }
    else {
        x$key_warnings
    }
    if (identical(detail, "brief")) {
        person_specific <- grepl("(^|[^[:alnum:]_])Person\\s*[:=]|Facet\\s*[:=]?\\s*Person([^[:alnum:]_]|$)", 
            key_warning_lines, ignore.case = TRUE)
        if (any(person_specific, na.rm = TRUE)) {
            person_warning_n <- sum(person_specific, na.rm = TRUE)
            key_warning_lines <- c(key_warning_lines[!person_specific], sprintf(paste("%d person-level diagnostic warning(s) are present; identifiers are suppressed", 
                "in the brief console view. Inspect the structured diagnostic tables", "only under appropriate privacy controls."), 
                person_warning_n))
        }
    }
    cat("Many-Facet Measurement Model Summary\n")
    if (nrow(x$rating_support %||% data.frame())) 
        print_wrapped_line("Rating design: $rating_support separates persons from rating rows; $rating_crossings and $rating_categories describe allocation and category use. DataBasis separates full-model and limiting-fit data. Counts do not establish precision.")
    if (nrow(x$starting_values %||% data.frame())) {
        cat("\nStarting-value review (same model and integration rule)\n")
        columns <- c("Start", "LogLikLoss", "TerminalGradientSupNorm", "NumericalStatus", "Selected")
        print(round_numeric_df(x$starting_values[columns], digits), row.names = FALSE)
        print_wrapped_line("Inspect $starting_values for warnings/failures and $starting_value_notes for scope. Agreement does not certify a global optimum or valid inference.")
    }
    if (nrow(x$interaction_comparisons %||% data.frame()) > 0L) {
        cat("\nRequested joint-fit interaction comparisons\n")
        columns <- c("Comparison", "Group1", "Group2", "Estimate", "EstimateStatus", "State")
        print(round_numeric_df(as.data.frame(x$interaction_comparisons[columns]), digits = digits), row.names = FALSE)
        print_wrapped_line("Descriptive contrasts only; no formal uncertainty. Review `$interaction_comparisons` and its attributes for unavailable values, assumptions and numerical checks.")
    }
    if (nrow(overview) > 0) {
        ov <- overview[1, , drop = FALSE]
        print_wrapped_line(sprintf("Model: %s | Method: %s | N: %s | Persons: %s | Facets: %s | Categories: %s", 
            ov$Model, ov$Method, ov$N, ov$Persons, ov$Facets, ov$Categories))
        print_fit_decision_section(x$decision)
        print_wrapped_line(x$estimation_note %||% character(0))
        if (isTRUE(x$attached_diagnostics)) {
            attached_cols <- as.character(x$attached_diagnostics_cols %||% character(0))
            if (length(attached_cols) > 0L) {
                print_wrapped_line(sprintf("Attached diagnostics: %s", paste(attached_cols, collapse = ", ")))
            }
            else {
                cat("  Attached diagnostics: yes\n")
            }
        }
        used_public <- public_mfrm_method_label(ov$MethodUsed %||% NA_character_)
        if (!is.na(ov$MethodUsed %||% NA_character_) && nzchar(as.character(ov$MethodUsed %||% "")) && 
            !identical(as.character(used_public), as.character(ov$Method))) {
            print_wrapped_line(paste0("Resolved estimator: ", used_public))
        }
        mml_contract_lines <- mfrm_mml_integration_console_lines(x)
        if (length(mml_contract_lines) > 0L) {
            print_wrapped_line(mml_contract_lines)
        }
        if (identical(as.character(ov$Method %||% NA_character_), "MML") && !is.na(ov$MMLEngineUsed %||% 
            NA_character_)) {
            if (is.finite(ov$EMIterations %||% NA_real_)) {
                print_wrapped_line(sprintf("EM iterations: %s | EM converged: %s | Last relative change: %s", 
                  ov$EMIterations %||% NA, ifelse(isTRUE(ov$EMConverged), "Yes", "No"), ov$EMRelativeChange %||% 
                    NA_real_))
            }
        }
        settings <- as.data.frame(x$settings_overview %||% data.frame())
        if (nrow(settings) > 0L && "CenteringScope" %in% names(settings)) {
            print_wrapped_line(switch(settings$CenteringScope[1], facet = "Centering: whole declared facet, including anchors and group totals.", 
                remainder = "Centering: legacy ungrouped, unanchored remainder.", anchor_origin = "Centering: direct or group anchors set their facet's origin; no additional zero sum is imposed on that facet.", 
                "Centering convention: not recorded."))
        }
        if (identical(as.character(ov$Model %||% NA_character_), "GPCM") && nrow(settings) > 0L && "GpcmEstimatorFamily" %in% 
            names(settings)) {
            print_wrapped_line(mfrm_gpcm_console_lines(settings))
        }
        if (identical(detail, "brief")) {
            ic_lines <- mfrm_ic_console_lines(overview_raw, digits = digits)
            if (length(ic_lines) > 0L) {
                print_wrapped_line(ic_lines)
            }
        }
    }
    if (!identical(profile, "fit")) {
        boundary <- as.character(x$provenance$OrganizationBoundary[1] %||% "FACETS-style organization; not numerical equivalence.")
        cat("\nWorkflow profile: ", profile, "\n", sep = "")
        print_wrapped_line(boundary)
    }
    if (nrow(x$required_visual %||% data.frame()) > 0L) {
        cat("\nVisual workflow (in order)\n")
        visual <- as.data.frame(x$required_visual, stringsAsFactors = FALSE)
        keep <- intersect(c("Priority", "Visual", "Required", "Available", "InterpretationStatus"), names(visual))
        visual <- visual[, keep, drop = FALSE]
        if ("InterpretationStatus" %in% names(visual)) {
            visual$Interpretation <- mfrm_fit_display_status(visual$InterpretationStatus)
            visual$InterpretationStatus <- NULL
        }
        print(visual, row.names = FALSE)
        cat("  Plot commands are stored in `$required_visual$Route`.\n")
    }
    if (nrow(x$status %||% data.frame()) > 0) {
        cat("\nStatus\n")
        for (i in seq_len(nrow(x$status))) {
            value <- as.character(x$status$Value[i])
            value <- switch(value, usable_fit = "Fit completed; review diagnostics before reporting", 
                reviewable_fit = "Fit completed, but numerical convergence requires review", fit_needs_review = "Fit requires numerical review before interpretation", 
                review_required = "Fit completed, but data, design, stability, or diagnostics require review", 
                review_before_reporting = "Resolve stored readiness reviews before reporting", hold_for_design_review = "Reporting is on hold until disconnected-design comparability is resolved", 
                hold_for_stability_review = "Reporting is on hold until boundary/separation stability is resolved", 
                review_design_before_reporting = "Review the design-linking justification before reporting", 
                review_data_before_reporting = "Review retained data-preparation issues before reporting", 
                review_diagnostics_before_reporting = "Review diagnostic findings before reporting", 
                ready_for_diagnostics_and_reporting_follow_up = "Fit completed; diagnostics and reporting review can proceed", 
                exploratory_fit_ready_for_diagnostics = "Fit available for diagnostic review; inferential strength depends on the estimator and convergence evidence", 
                value)
            value <- gsub("sup-norm", "maximum absolute gradient", value, fixed = TRUE)
            status_line <- paste0(x$status$Item[i], ": ", value)
            wrapped <- strwrap(status_line, width = max(30L, mfrm_console_width() - 3L))
            cat(" - ", wrapped[1], "\n", sep = "")
            if (length(wrapped) > 1L) {
                for (part in wrapped[-1L]) cat("   ", part, "\n", sep = "")
            }
        }
    }
    if (nrow(x$readiness %||% data.frame()) > 0L) {
        cat("\nWorkflow readiness\n")
        readiness <- as.data.frame(x$readiness, stringsAsFactors = FALSE)
        keep <- intersect(c("Domain", "Status"), names(readiness))
        readiness$Status <- mfrm_fit_display_status(readiness$Status)
        print(readiness[, keep, drop = FALSE], row.names = FALSE)
    }
    print_bullet_section("Key warnings", key_warning_lines)
    print_bullet_section("Next actions", x$next_actions)
    print_note_section(notes = x$caveats, preparation = FALSE)
    if (nrow(x$row_retention %||% data.frame()) > 0L && "DroppedRows" %in% names(x$row_retention) && 
        any(suppressWarnings(as.numeric(x$row_retention$DroppedRows)) > 0, na.rm = TRUE)) {
        cat("\nRow retention\n")
        print(round_numeric_df(as.data.frame(x$row_retention), digits = digits), row.names = FALSE)
    }
    if (identical(detail, "brief")) {
        preparation_notes <- summary_note_display_table(notes = x$preparation_notes, preparation = TRUE)
        preparation_notes$Affected <- NULL
        if (nrow(preparation_notes) > 0L) {
            cat("\nData preparation notes (identifiers suppressed)\n")
            print(preparation_notes, row.names = FALSE)
        }
    }
    else {
        print_note_section(notes = x$preparation_notes, title = "Data preparation notes", preparation = TRUE)
    }
    if (nrow(x$facet_support_boundaries %||% data.frame()) > 0L) {
        cat("\nObserved boundary-constant facet support\n")
        print(round_numeric_df(as.data.frame(x$facet_support_boundaries), digits = digits), row.names = FALSE)
        cat("  Data-support warning only; it is not by itself an infinite-parameter certificate.\n")
    }
    if (nrow(x$facet_recession_review %||% data.frame()) > 0L) {
        cat("\nCertified JML facet recession directions\n")
        recession <- as.data.frame(x$facet_recession_review, stringsAsFactors = FALSE)
        keep <- intersect(c("Facet", "Level", "BoundaryStatus", "OptimizerEstimate", "AuditScope", "AuditComplete"), 
            names(recession))
        recession$BoundaryStatus <- mfrm_fit_display_status(recession$BoundaryStatus)
        recession$AuditScope <- mfrm_fit_display_status(recession$AuditScope)
        print(round_numeric_df(recession[, keep, drop = FALSE], digits = digits), row.names = FALSE)
        cat(paste("  Joint-scope rows are relative directions under identification;", "finite optimizer values are numerical traces, not finite JML maxima.\n"))
    }
    if (identical(detail, "brief")) {
        print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_fit_01"]], digits = digits)
        if (nrow(x$person_overview %||% data.frame()) > 0L) {
            cat("\nPerson measure distribution (aggregate; no identifiers)\n")
            print(round_numeric_df(mfrm_fit_display_person_overview(x$person_overview), digits = digits), 
                row.names = FALSE)
        }
        print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_fit_02"]], digits = digits)
        if (inherits(x$results, "mfrm_results") && inherits(x$results$diagnostics, "mfrm_diagnostics")) {
            diagnostics <- x$results$diagnostics
            overall_fit <- as.data.frame(diagnostics$overall_fit %||% data.frame(), stringsAsFactors = FALSE)
            if (nrow(overall_fit) > 0L) {
                keep <- intersect(c("Infit", "Outfit", "InfitZSTD", "OutfitZSTD", "InfitZSTD_FACETS", 
                  "OutfitZSTD_FACETS", "DF_Infit", "DF_Outfit", "DF_Infit_FACETS", "DF_Outfit_FACETS"), 
                  names(overall_fit))
                cat("\nOverall fit first screen\n")
                print(round_numeric_df(overall_fit[, keep, drop = FALSE], digits = digits), row.names = FALSE)
            }
            reliability <- as.data.frame(diagnostics$reliability %||% data.frame(), stringsAsFactors = FALSE)
            if (nrow(reliability) > 0L) {
                if ("PrecisionTier" %in% names(reliability)) {
                  labels <- c(model_based = "Model-based", hybrid = "Mixed precision", exploratory = "Exploratory")
                  value <- unname(labels[as.character(reliability$PrecisionTier)])
                  value[is.na(value)] <- "Requires review"
                  reliability$PrecisionTier <- value
                }
                keep <- intersect(c("Facet", "Levels", "PrecisionTier", "Reliability", "RealReliability", 
                  "Separation", "Strata", "MeanInfit", "MeanOutfit"), names(reliability))
                cat("\nReliability and separation first screen\n")
                print(round_numeric_df(reliability[, keep, drop = FALSE], digits = digits), row.names = FALSE)
            }
            facets_chisq <- as.data.frame(diagnostics$facets_chisq %||% data.frame(), stringsAsFactors = FALSE)
            if (nrow(facets_chisq) > 0L) {
                keep <- intersect(c("Facet", "Levels", "FixedChiSq", "FixedDF", "FixedProb", "RandomChiSq", 
                  "RandomDF", "RandomProb"), names(facets_chisq))
                cat("\nFacet chi-square first screen\n")
                print(round_numeric_df(facets_chisq[, keep, drop = FALSE], digits = digits), row.names = FALSE)
            }
            rating <- x$results$components$rating_scale %||% NULL
            rating_summary <- as.data.frame(rating$summary %||% data.frame(), stringsAsFactors = FALSE)
            if (nrow(rating_summary) > 0L) {
                keep <- intersect(c("Categories", "UsedCategories", "UnusedScoreCategories", "WeaklyIdentifiedThresholds", 
                  "MinCategoryCount", "MeanCategoryInfit", "MeanCategoryOutfit", "AvailableCategoryCounts", 
                  "UnavailableCategoryCounts", "ThresholdMonotonic", "AvailableThresholdComparisons", 
                  "UnavailableThresholdComparisons", "ThresholdOrderNotApplicable", "MarginalFitAvailable", 
                  "MarginalFlaggedCategories"), names(rating_summary))
                cat("\nRating-scale first screen\n")
                print(round_numeric_df(rating_summary[, keep, drop = FALSE], digits = digits), row.names = FALSE)
            }
            thresholds <- as.data.frame(rating$threshold_table %||% data.frame(), stringsAsFactors = FALSE)
            if (nrow(thresholds) > 0L) {
                if (all(c("LowerCategory", "UpperCategory") %in% names(thresholds))) {
                  thresholds$Transition <- paste0(as.character(thresholds$LowerCategory), " -> ", as.character(thresholds$UpperCategory))
                }
                keep <- intersect(c("StepFacet", "Step", "Transition", "LowerCategory", "UpperCategory", 
                  "Estimate", "GapFromPrev", "ThresholdMonotonic", "WeaklyIdentified", "ThresholdCaveat"), 
                  names(thresholds))
                cat("\nLabeled step transitions (first rows)\n")
                print(round_numeric_df(utils::head(thresholds[, keep, drop = FALSE], 8L), digits = digits), 
                  row.names = FALSE)
            }
        }
        section_status <- as.data.frame(x$section_status %||% data.frame(), stringsAsFactors = FALSE)
        if (nrow(section_status) > 0L && all(c("Section", "Status") %in% names(section_status))) {
            boundaries <- section_status[section_status$Status %in% "not_computed_by_summary", , drop = FALSE]
            if (nrow(boundaries) > 0L) {
                cat("\nAnalyses intentionally not run by summary\n")
                boundary_display <- boundaries
                boundary_display$Section <- c(bias_dif = "Bias / DIF", residual_pca = "Residual PCA", 
                  linking_drift = "Linking / anchor drift")[as.character(boundary_display$Section)]
                boundary_display$Status <- "Not run automatically"
                keep <- intersect(c("Section", "Status", "Detail"), names(boundary_display))
                print(boundary_display[, keep, drop = FALSE], row.names = FALSE)
            }
            review <- section_status[!section_status$Status %in% c("ok", "available", "not_computed_by_summary"), 
                , drop = FALSE]
            review <- review[!review$Section %in% c("fit_readiness", "plot_interpretation", "reporting_readiness"), 
                , drop = FALSE]
            if (nrow(review) > 0L) {
                cat("\nSection availability requiring attention\n")
                review$Section <- tools::toTitleCase(gsub("_", " ", review$Section, fixed = TRUE))
                review$Status <- mfrm_fit_display_status(review$Status)
                keep <- intersect(c("Section", "Status", "Detail"), names(review))
                print(review[, keep, drop = FALSE], row.names = FALSE)
            }
        }
        cat("\nStructured result access\n")
        if (inherits(x$results, "mfrm_results")) {
            cat(" - `$analysis`: compact triage, table index, and plot map.\n")
            cat(" - `$results$tables`: full structured tables (not printed here).\n")
            cat(sprintf(" - Re-run `summary(fit, profile = \"%s\", detail = \"full\")` only when more fit-level detail is needed.\n", 
                profile))
        }
        else {
            cat(" - Use `summary(fit, profile = \"facets\")` for the comprehensive measurement review; FACETS software is not required.\n")
            cat(" - Use `summary(fit, detail = \"full\")` for legacy fit-level detail.\n")
        }
        return(invisible(x))
    }
    if (nrow(overview) > 0) {
        ov <- overview[1, , drop = FALSE]
        raw_ov <- overview_raw[1, , drop = FALSE]
        full_status <- switch(as.character(raw_ov$ConvergenceStatus %||% NA_character_), converged = "converged", 
            converged_gradient_review = "terminal gradient needs review", reviewable_warning = "optimizer warning; small terminal gradient", 
            iteration_limit = "iteration limit reached", optimizer_warning = "optimizer warning", unknown = "unknown", 
            as.character(raw_ov$ConvergenceStatus %||% NA_character_))
        cat("\nFit overview\n")
        ic_lines <- mfrm_ic_console_lines(raw_ov, digits = digits)
        if (length(ic_lines) > 0L) {
            cat(paste0("  ", ic_lines, "\n"), sep = "")
        }
        cat(sprintf("  Optimizer code 0: %s | Status: %s | Fn evals: %s | Gr evals: %s\n", if (is.na(raw_ov$ConvergenceCode %||% 
            NA)) 
            "Not recorded"
        else if (raw_ov$ConvergenceCode == 0) 
            "Yes"
        else "No", full_status, ov$FunctionEvaluations %||% ov$Iterations %||% NA, ov$GradientEvaluations %||% 
            NA))
        if (is.finite(raw_ov$TerminalGradientSupNorm %||% NA_real_)) {
            format_gradient <- function(value) {
                value <- as.numeric(value %||% NA_real_)
                if (!is.finite(value)) 
                  return("NA")
                trimws(formatC(value, format = "g", digits = max(3L, digits)))
            }
            cat(sprintf("  Terminal gradient: maximum absolute = %s | RMS = %s | Review tolerance = %s\n", 
                format_gradient(raw_ov$TerminalGradientSupNorm), format_gradient(raw_ov$TerminalGradientRMS), 
                format_gradient(raw_ov$GradientReviewTolerance)))
        }
        if (!is.na(ov$ConvergenceDetail %||% NA_character_) && nzchar(ov$ConvergenceDetail %||% "")) {
            cat(sprintf("  Optimization note: %s\n", ov$ConvergenceDetail))
        }
    }
    if (nrow(x$population_overview) > 0) {
        cat("\nPopulation basis\n")
        population <- as.data.frame(x$population_overview)
        if (identical(as.character(overview$Method[1]), "JML")) {
            print_wrapped_line("JML estimates Person measures jointly with calibration parameters; it does not estimate a normal population distribution.")
        }
        else if (isTRUE(population$PopulationModel[1])) {
            print_wrapped_line(if (identical(population$ResidualVarianceStatus[1], "fixed")) 
                "Conditional normal Person distribution with estimated coefficients and fixed residual variance. Posterior Person scoring conditions on the fitted calibration and population parameters."
            else "Estimated conditional normal Person distribution. Population coefficients and residual variance are point estimates; their uncertainty is not included in posterior Person scoring.")
            keep <- intersect(c("Formula", "PersonRows", "DesignColumns", "ResidualVariance", "ResidualVarianceStatus", 
                "OmittedPersons", "OmittedRows"), names(population))
            print(round_numeric_df(population[keep], digits = digits), row.names = FALSE)
        }
        else {
            print_wrapped_line("MML calibration uses a fixed standard normal Person distribution, N(0,1).")
        }
    }
    if (nrow(x$inference_evidence %||% data.frame()) > 0L) {
        cat("\nGPCM-MML inference evidence\n")
        evidence <- as.data.frame(x$inference_evidence, stringsAsFactors = FALSE)
        areas <- c(optimizer_stationarity = "Numerical stationarity", local_estimability = "Local identification", 
            observed_information_curvature = "Local curvature", slope_boundary_screen = "Slope boundaries", 
            fit_readiness = "Fit interpretation")
        evidence$EvidenceArea <- unname(areas[evidence$EvidenceArea])
        evidence$EvidenceArea[is.na(evidence$EvidenceArea)] <- "Additional diagnostic check"
        evidence$State <- mfrm_fit_display_status(evidence$State)
        keep <- intersect(c("EvidenceArea", "State", "Complete", "Rank", "Dimension", "MinimumEigenvalue", 
            "MaximumEigenvalue", "ConditionNumber"), names(evidence))
        print(round_numeric_df(evidence[, keep, drop = FALSE], digits = digits), row.names = FALSE)
        cat(paste("  Local rank and curvature are supportive evidence only; the", "slope-boundary row remains inconclusive unless its audit establishes", 
            "a boundary conclusion. See `$inference_evidence$Interpretation`.\n"))
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_fit_03"]], digits = digits)
    if (nrow(x$person_overview) > 0) {
        cat("\nPerson measure distribution\n")
        print(round_numeric_df(mfrm_fit_display_person_overview(x$person_overview), digits = digits), 
            row.names = FALSE)
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_fit_04"]], digits = digits)
    if (nrow(x$slope_overview %||% data.frame()) > 0) {
        cat("\nSlope point estimates and numerical status\n")
        slopes <- as.data.frame(x$slope_overview)
        slopes <- slopes[setdiff(names(slopes), c("OwnerInterpretation", "ParameterStatus", "PrimaryReady", 
            "FixedLatentSDBasis", "Identification"))]
        if ("ScaleReference" %in% names(slopes)) {
            slopes$ScaleReference <- ifelse(slopes$ScaleReference == "geometric_mean_one", "Within-facet geometric mean 1", 
                ifelse(slopes$ScaleReference == "fixed_standard_normal", "Fixed standard-normal ability scale", 
                  "Reference not recorded"))
        }
        if ("ValueBasis" %in% names(slopes)) 
            slopes$ValueBasis <- mfrm_fit_display_status(slopes$ValueBasis)
        print(round_numeric_df(slopes, digits = digits), row.names = FALSE)
        if (nrow(x$point_estimation %||% data.frame())) 
            print_wrapped_line(x$point_estimation$Detail)
        if (identical(x$point_estimation$Status, "finite_maximum_absent")) {
            print_wrapped_line("Each slope facet retains its own scale reference. The full model has no finite maximum. Inspect point_targets and step_targets for available limiting estimates; full-model and ordinary limiting-fit intervals are unavailable.")
        }
        else if (nrow(x$slope_overview) > 1L) {
            print_wrapped_line("Each row describes one slope facet and its own scale reference. Use confint(fit, parm = 'slopes') for separately checked experimental component-slope intervals. These summaries do not qualify intervals, global identification or model comparisons; sampling coverage remains unestablished.")
        }
        else {
            print_wrapped_line("Use confint(fit, parm = 'slopes') or diagnose_mfrm(fit) for separately checked MML relative-slope intervals. Their CIEligible decision does not certify global boundary absence. Use confint(fit, parm = 'slopes', scale = 'standardized') for intervals on population-SD times slope, including estimated-scale uncertainty. With covariates, this is the residual population SD.")
        }
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_fit_05"]], digits = digits)
    if (nrow(x$settings_overview %||% data.frame()) > 0) {
        cat("\nEstimation settings\n")
        settings <- as.data.frame(x$settings_overview)
        keep <- intersect(c("StepFacet", "SlopeFacet", "NoncenterFacet", "WeightColumn", "RatingMin", 
            "RatingMax", "CategoryPolicy", "ScoreRecoded", "DummyFacets", "PositiveFacets", "FacetInteractions", 
            "UnusedScoreCategories", "UnusedScoreCategoryCount"), names(settings))
        print(round_numeric_df(settings[keep], digits = digits), row.names = FALSE)
        print_wrapped_line(settings$StepFacetNote %||% character(0))
        print_wrapped_line("Full fitting settings are retained in `$settings_overview`.")
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_fit_06"]], digits = digits)
    show_person_extremes <- isTRUE(include_person)
    if (isTRUE(show_person_extremes) && nrow(x$person_high) > 0) {
        cat("\nHighest person measures\n")
        print(round_numeric_df(as.data.frame(x$person_high), digits = digits), row.names = FALSE)
    }
    if (isTRUE(show_person_extremes) && nrow(x$person_low) > 0) {
        cat("\nLowest person measures\n")
        print(round_numeric_df(as.data.frame(x$person_low), digits = digits), row.names = FALSE)
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_fit_07"]])
    if (length(x$notes) > 0 && !summary_lines_are_default(x$notes, "No immediate warnings from fit-level summary checks.")) {
        cat("\nNotes\n")
        for (line in x$notes) cat(" - ", line, "\n", sep = "")
    }
    invisible(x)
}
