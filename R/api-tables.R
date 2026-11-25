


fair_average_table <- function(fit, diagnostics = NULL, facets = NULL, totalscore = TRUE, umean = 0, 
    uscale = 1, udecimals = 2, reference = c("both", "mean", "zero"), label_style = c("both", "native", 
        "legacy"), omit_unobserved = FALSE, xtreme = 0, fair_se = FALSE, ci_level = 0.95, xtreme_method = c("display", 
        "facets"), reference_plan = NULL) {
    if (inherits(fit, "mfrm_fast_fit")) {
        if (isTRUE(fair_se) && is.null(reference_plan))
            stop("Fair-average intervals are not implemented without a reference_plan; measure SEs are not fair-score SEs.", call. = FALSE)
        if (isTRUE(fair_se) && (length(ci_level) != 1L || !is.numeric(ci_level) ||
            !is.finite(ci_level) || ci_level <= 0 || ci_level >= 1))
            stop("ci_level must be between 0 and 1.", call. = FALSE)
        p_raw <- data.frame(
            Facet = "Person", Level = fit$person$Person,
            ObsCount = fit$person$ObsCount, ObsAvg = fit$person$ObsAvg,
            ExpAvg = fit$person$ExpAvg, FairM = fit$person$FairM, FairZ = fit$person$FairZ,
            Measure = umean + uscale * fit$person$Estimate, SE = uscale * fit$person$ModelSE,
            stringsAsFactors = FALSE
        )
        by_f <- list(Person = p_raw)
        for (fnm in unique(fit$facets$Facet)) {
            sub <- fit$facets[fit$facets$Facet == fnm, ]
            by_f[[fnm]] <- data.frame(
                Facet = fnm, Level = sub$Level,
                ObsCount = sub$ObsCount, ObsAvg = sub$ObsAvg,
                ExpAvg = sub$ExpAvg, FairM = sub$FairM, FairZ = sub$FairZ,
                Measure = umean + uscale * sub$Estimate, SE = uscale * sub$ModelSE,
                stringsAsFactors = FALSE
            )
        }
        if (!is.null(facets)) by_f <- by_f[intersect(as.character(facets), names(by_f))]
        stacked <- do.call(rbind, by_f)
        rownames(stacked) <- NULL
        bundle <- list(stacked = stacked, raw_by_facet = by_f)
        if (!is.null(reference_plan)) {
            plan <- mfrm_fair_reference_plan(fit, reference_plan)
            bundle$reference_scores <- mfrm_fair_reference_scores(fit, plan, if (isTRUE(fair_se)) ci_level)
            bundle$reference_plan <- plan
            bundle$reference_fit <- fit
            bundle$settings <- list(reference_target = "common_plan_expected_average", score_method = fit$score_method)
        }
        return(structure(bundle, class = c("mfrm_fair_average", "mfrm_bundle")))
    }
    if (mfrm_is_jeffreys_fit(fit)) {
        supplied <- names(as.list(match.call())[-1L])
        if (any(!supplied %in% c("fit", "reference_plan")) || is.null(reference_plan)) 
            stop("Jeffreys fits support fair_average_table(fit, reference_plan = ...); ordinary FairM/FairZ and diagnostic controls are unavailable.", 
                call. = FALSE)
        plan <- mfrm_fair_reference_plan(fit, reference_plan)
        return(as_mfrm_bundle(list(reference_scores = mfrm_fair_reference_scores(fit, plan), reference_plan = plan, 
            reference_fit = fit, reference_identity = mfrm_fair_fit_identity(fit), settings = list(reference_target = "common_plan_expected_average", 
                estimator = "jeffreys_canonical_joint"), notes = fit$notes), "mfrm_fair_average"))
    }
    reference <- match.arg(reference)
    label_style <- match.arg(label_style)
    xtreme_method <- match.arg(xtreme_method)
    if (!is.numeric(ci_level) || length(ci_level) != 1L || !is.finite(ci_level) || ci_level <= 0 || ci_level >= 
        1) {
        stop("`ci_level` must be a single number in (0, 1).", call. = FALSE)
    }
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an mfrm_fit object from fit_mfrm().")
    }
    fit_model <- as.character(fit$config$model %||% fit$summary$Model[1] %||% NA_character_)
    if (identical(xtreme_method, "facets") && (!identical(fit$config$method, "JML") || !fit_model %in% 
        c("RSM", "PCM") || length(fit$config$interaction_specs))) 
        stop("FACETS total-score extrapolation requires ordinary additive RSM/PCM JML.", call. = FALSE)
    if (identical(xtreme_method, "facets") && any(fit$config$anchor_summary$GroupAnchors > 0)) 
        stop("FACETS total-score extrapolation does not support group-mean anchors.", call. = FALSE)
    if (!is.numeric(xtreme) || length(xtreme) != 1L || !is.finite(xtreme) || xtreme < 0 || xtreme >= 
        fit$prep$rating_max - fit$prep$rating_min) 
        stop("`xtreme` must be finite, nonnegative and less than the score range.", call. = FALSE)
    if (is.null(diagnostics)) {
        diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
    }
    if (is.null(diagnostics$obs) || is.null(diagnostics$measures)) {
        stop("`diagnostics` must include both `obs` and `measures`.")
    }
    mfrm_results_validate_diagnostics_identity(fit, diagnostics, helper = "fair_average_table()")
    bundle <- calc_fair_average_bundle(res = fit, diagnostics = diagnostics, facets = facets, totalscore = totalscore, 
        umean = umean, uscale = uscale, udecimals = udecimals, reference = reference, label_style = label_style, 
        omit_unobserved = omit_unobserved, xtreme = xtreme, xtreme_method = xtreme_method, fair_se = fair_se, 
        ci_level = ci_level)
    if (isTRUE(bundle$status %in% c("no_finite_mle", "boundary_check_unavailable"))) 
        stop_mfrm_results_unavailable(bundle$reason)
    bundle$settings <- list(facets = if (is.null(facets)) NULL else as.character(facets), totalscore = totalscore, 
        umean = umean, uscale = uscale, udecimals = udecimals, reference = reference, label_style = label_style, 
        omit_unobserved = omit_unobserved, xtreme = xtreme, xtreme_method = xtreme_method, fair_se = isTRUE(fair_se), 
        ci_level = ci_level, rating_min = fit$prep$rating_min, rating_max = fit$prep$rating_max, score_map = fit$prep$score_map, 
        model = fit_model, method = if (identical(fit_model, "GPCM")) "GPCM-slope-aware" else "PCM/RSM")
    if (identical(fit_model, "GPCM")) {
        bundle$caveat <- paste0("GPCM fair-averages use the slope-aware element-conditional ", "construction: each slope-facet element row uses that element's ", 
            "own discrimination, while non-slope-facet rows (persons, raters, ", "...) use the geometric-mean-one slope from the GPCM identification ", 
            "convention. This is an identification-based reporting convention, ", "not FACETS score-side equivalence. Standard errors on the ", 
            "fair-average value are opt-in: ", "the SE / Model S.E. / Real S.E. columns are scaled ", 
            "facet-measure SEs, not fair-average SEs. Use `fair_se = TRUE` ", "to request structural delta-method fair-average SEs for non-person ", 
            "rows when the MML observed-information Hessian is available. ", "See `mfrmr_output_guide(\"gpcm_capabilities\")` for the current support contract.")
    }
    pcm_audit <- mfrm_audit_pcm_fair_exposure(fit = fit, diagnostics = diagnostics, raw_tbls = bundle$raw_by_facet, 
        totalscore = totalscore)
    if (!is.null(pcm_audit)) {
        bundle$pcm_exposure_audit <- pcm_audit
        if (any(pcm_audit$HeterogeneousStepExposure)) {
            inv_facets <- pcm_audit$Facet[pcm_audit$FairMNonMonotoneElements > 0L | pcm_audit$FairZNonMonotoneElements > 
                0L]
            bundle$notes <- c(bundle$notes %||% character(0), paste0("PCM FairM/FairZ follow the FACETS convention of averaging expectations across each element's administered `", 
                fit$config$step_facet, "` exposure; elements in ", paste(pcm_audit$Facet[pcm_audit$HeterogeneousStepExposure], 
                  collapse = ", "), " received unequal step-scale mixtures", if (length(inv_facets)) {
                  paste0(" (producing measure-vs-fair rank inversions in ", paste(inv_facets, collapse = ", "), 
                    ")")
                } else {
                  ""
                }, ". Supply `reference_plan` to `fair_average_table()` for strictly monotone common-plan comparisons."))
        }
    }
    if (!is.null(reference_plan)) {
        plan <- mfrm_fair_reference_plan(fit, reference_plan)
        bundle$reference_scores <- mfrm_fair_reference_scores(fit, plan)
        bundle$reference_plan <- plan
        bundle$reference_fit <- fit
        bundle$reference_identity <- mfrm_fair_fit_identity(fit)
        bundle$settings$reference_target <- "common_plan_expected_average"
    }
    as_mfrm_bundle(bundle, "mfrm_fair_average")
}






as_mfrm_bundle <- function(x, class_name) {
    if (!is.list(x)) 
        return(x)
    class(x) <- unique(c(class_name, "mfrm_bundle", class(x)))
    x
}


score_category_support_profile <- function(prep = NULL, score_distribution = NULL) {
    support <- integer(0)
    observed <- integer(0)
    unused <- integer(0)
    if (!is.null(prep)) {
        rating_min <- suppressWarnings(as.integer(prep$rating_min %||% NA_integer_))
        rating_max <- suppressWarnings(as.integer(prep$rating_max %||% NA_integer_))
        if (is.finite(rating_min) && is.finite(rating_max) && rating_min <= rating_max) {
            support <- seq(rating_min, rating_max)
        }
        prep_data <- as.data.frame(prep$data %||% data.frame(), stringsAsFactors = FALSE)
        if (nrow(prep_data) > 0 && "Score" %in% names(prep_data)) {
            observed <- sort(unique(suppressWarnings(as.integer(prep_data$Score))))
            observed <- observed[is.finite(observed)]
        }
        unused <- sort(unique(suppressWarnings(as.integer(prep$unused_score_categories %||% integer(0)))))
        unused <- unused[is.finite(unused)]
    }
    score_distribution <- as.data.frame(score_distribution %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(score_distribution) > 0) {
        category_col <- if ("Category" %in% names(score_distribution)) {
            "Category"
        }
        else if ("Score" %in% names(score_distribution)) {
            "Score"
        }
        else {
            NA_character_
        }
        if (!is.na(category_col)) {
            dist_categories <- suppressWarnings(as.integer(score_distribution[[category_col]]))
            dist_categories <- dist_categories[is.finite(dist_categories)]
            support <- sort(unique(c(support, dist_categories)))
            raw_n <- suppressWarnings(as.numeric(score_distribution$RawN %||% score_distribution$Count %||% 
                NA_real_))
            weighted_n <- suppressWarnings(as.numeric(score_distribution$WeightedN %||% raw_n))
            zero_mask <- (is.finite(raw_n) & raw_n <= 0) | (is.finite(weighted_n) & weighted_n <= 0)
            if (length(zero_mask) == nrow(score_distribution)) {
                zero_categories <- suppressWarnings(as.integer(score_distribution[[category_col]][zero_mask]))
                zero_categories <- zero_categories[is.finite(zero_categories)]
                unused <- sort(unique(c(unused, zero_categories)))
                positive_categories <- suppressWarnings(as.integer(score_distribution[[category_col]][!zero_mask]))
                positive_categories <- positive_categories[is.finite(positive_categories)]
                observed <- sort(unique(c(observed, positive_categories)))
            }
        }
    }
    if (length(support) == 0L) {
        support <- sort(unique(c(observed, unused)))
    }
    support <- support[is.finite(support)]
    if (length(support) == 0L) {
        return(tibble::tibble(Category = integer(0), ZeroCount = logical(0), UnusedCategoryType = character(0), 
            WeaklyIdentified = logical(0), CategoryCaveat = character(0)))
    }
    if (length(observed) == 0L && length(unused) > 0L) {
        observed <- setdiff(support, unused)
    }
    observed_min <- suppressWarnings(min(observed, na.rm = TRUE))
    observed_max <- suppressWarnings(max(observed, na.rm = TRUE))
    zero_count <- support %in% unused
    internal <- if (is.finite(observed_min) && is.finite(observed_max)) {
        support > observed_min & support < observed_max
    }
    else {
        rep(FALSE, length(support))
    }
    unused_type <- ifelse(zero_count & internal, "internal", ifelse(zero_count, "boundary", "none"))
    caveat <- dplyr::case_when(unused_type == "internal" ~ "Zero-count intermediate category; adjacent thresholds are weakly identified.", 
        unused_type == "boundary" ~ "Zero-count boundary category; document the retained support and avoid overinterpreting adjacent thresholds.", 
        TRUE ~ "")
    tibble::tibble(Category = support, ZeroCount = zero_count, UnusedCategoryType = unused_type, WeaklyIdentified = zero_count, 
        CategoryCaveat = caveat)
}

empty_mfrm_caveats <- .mfrmr_empty_table(c(Area = "character", Severity = "character", Condition = "character", 
    Categories = "character", CategoryType = "character", Message = "character", RecommendedAction = "character", 
    Details = "character"))

collect_mfrm_caveats <- function(fit = NULL, prep = NULL, score_distribution = NULL, include_recode = TRUE, 
    context = c("fit", "data")) {
    context <- match.arg(context)
    if (!is.null(fit) && is.null(prep)) {
        prep <- fit$prep %||% NULL
    }
    profile <- score_category_support_profile(prep = prep, score_distribution = score_distribution)
    out <- empty_mfrm_caveats
    support_phrase <- if (identical(context, "data")) 
        "prepared score support"
    else "fitted score support"
    add_caveat <- function(severity, condition, categories, category_type, message, action) {
        out <<- rbind(out, data.frame(Area = "score_categories", Severity = severity, Condition = condition, 
            Categories = paste(as.character(categories), collapse = ", "), CategoryType = category_type, 
            Message = message, RecommendedAction = action, Details = "", stringsAsFactors = FALSE))
        invisible(NULL)
    }
    zero_rows <- if (nrow(profile) > 0 && "ZeroCount" %in% names(profile)) {
        profile[as.logical(profile$ZeroCount), , drop = FALSE]
    }
    else {
        profile[0, , drop = FALSE]
    }
    if (nrow(zero_rows) > 0) {
        internal <- zero_rows$Category[zero_rows$UnusedCategoryType == "internal"]
        boundary <- zero_rows$Category[zero_rows$UnusedCategoryType == "boundary"]
        if (length(internal) > 0L) {
            internal_text <- paste(as.character(internal), collapse = ", ")
            add_caveat(severity = "warning", condition = "zero_count_intermediate_score_category", categories = internal, 
                category_type = "internal", message = paste0("Unused intermediate score categories retained in the ", 
                  support_phrase, ": ", internal_text, ". Under the current sum-zero step parameterization, a zero-count internal category creates an unsupported adjacent-step recession direction in its fitted ladder. New fits stop before optimization; legacy or descriptive objects must not present the adjacent steps as finite identified estimates."), 
                action = "Collect observations in the internal category, revise the score support or response model, or separate the affected ladder before fitting.")
        }
        if (length(boundary) > 0L) {
            boundary_text <- paste(as.character(boundary), collapse = ", ")
            add_caveat(severity = "review", condition = "zero_count_boundary_score_category", categories = boundary, 
                category_type = "boundary", message = paste0("Unused boundary score categories retained in the ", 
                  support_phrase, ": ", boundary_text, ". Document the zero-count category and avoid overinterpreting adjacent threshold estimates."), 
                action = "Document the intended score support and verify `rating_min` / `rating_max` before reporting category functioning.")
        }
    }
    if (isTRUE(include_recode) && !is.null(prep)) {
        score_map <- as.data.frame(prep$score_map %||% data.frame(), stringsAsFactors = FALSE)
        if (nrow(score_map) > 0L && all(c("OriginalScore", "InternalScore") %in% names(score_map)) && 
            any(as.character(score_map$OriginalScore) != as.character(score_map$InternalScore))) {
            add_caveat(severity = "info", condition = "score_categories_recoded", categories = sort(unique(as.character(score_map$OriginalScore))), 
                category_type = "recoded", message = "Observed score categories were internally recoded; inspect `fit$prep$score_map` before interpreting category labels.", 
                action = "Use `fit$prep$score_map` when connecting internal category estimates back to original score labels.")
        }
        if (nrow(score_map) > 0L && "OriginalScore" %in% names(score_map)) {
            original_scores <- sort(unique(suppressWarnings(as.integer(score_map$OriginalScore))))
            original_scores <- original_scores[is.finite(original_scores)]
            if (length(original_scores) >= 2L) {
                original_support <- seq(min(original_scores), max(original_scores))
                missing_original <- setdiff(original_support, original_scores)
                retained_zero <- suppressWarnings(as.integer(zero_rows$Category %||% integer(0)))
                retained_zero <- retained_zero[is.finite(retained_zero)]
                missing_not_retained <- setdiff(missing_original, retained_zero)
                if (length(missing_not_retained) > 0L) {
                  add_caveat(severity = "warning", condition = "original_score_gap_before_recoding", 
                    categories = missing_not_retained, category_type = "original_gap", message = paste0("Original score labels skip category ", 
                      paste(missing_not_retained, collapse = ", "), " before the fitted internal scale is formed. If the intended scale includes ", 
                      if (length(missing_not_retained) == 1L) 
                        "this category"
                      else "these categories", ", refit with `rating_min`, `rating_max`, and `keep_original = TRUE` so zero-frequency categories remain visible in category-functioning output."), 
                    action = "Check the declared rating scale; retain intended zero-count intermediate categories when threshold functioning is part of the analysis.")
                }
            }
        }
    }
    out
}





bias_person_screen_note <- function(fit = NULL) {
    source_person <- as.character(fit$config$source_columns$person %||% "Person")[1]
    source_note <- if (!is.na(source_person) && nzchar(source_person) && !identical(source_person, "Person")) {
        paste0(" In this fit, canonical `Person` denotes the source person column `", source_person, 
            "`.")
    }
    else {
        ""
    }
    paste0("A Person-involving bias result is a cellwise conditional plug-in ", "likelihood screen: fitted JML person measures or MML EAP scores, facet ", 
        "effects, and step parameters are held fixed.", source_note, " It is not a jointly fitted Person x facet interaction from ", 
        "`fit_mfrm(facet_interactions = ...)`, and it does not support formal ", "inference or a cell-level fairness decision. Sparse cells can be ", 
        "especially unstable; inspect `ObsN`, `Observd Count`, and `d.f.`, and ", "use `bias_count_table(..., min_count_warn = 10)` before interpreting ", 
        "individual cells.")
}

warn_bias_person_screen <- function(fit, helper = "estimate_bias()") {
    rlang::warn(paste0("`", helper, "` included `Person`. ", bias_person_screen_note(fit)), class = "mfrmr_person_bias_screen_warning")
}

estimate_bias <- function(fit, diagnostics = NULL, facet_a = NULL, facet_b = NULL, interaction_facets = NULL, 
    method = c("local", "joint"), df_method = c("facets", "classical"), p_adjust = "holm",
    max_abs = 10, omit_extreme = TRUE, max_iter = 4, tol = 0.001, xtreme = 0) {
    if (inherits(fit, "mfrm_fast_fit") ||
        missing(diagnostics) || is.null(diagnostics) ||
        identical(interaction_facets, "all") ||
        identical(method[1L], "joint") ||
        !missing(df_method)) {
        return(.mfrm_estimate_bias_cpp(
            fit = fit,
            facet_a = facet_a,
            facet_b = facet_b,
            interaction_facets = interaction_facets,
            method = method[1L],
            df_method = df_method[1L],
            p_adjust = p_adjust
        ))
    }
    stop_if_product_slopes(fit, "estimate_bias()")
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an mfrm_fit object from fit_mfrm(). ", "Got: ", paste(class(fit), collapse = "/"), 
            ".", call. = FALSE)
    }
    if (missing(diagnostics)) {
        stop("`diagnostics` is required. Call diagnose_mfrm(fit) first and ", "pass the result as the second argument: ", 
            "estimate_bias(fit, diagnose_mfrm(fit), facet_a = ..., facet_b = ...).", call. = FALSE)
    }
    if (!is.list(diagnostics) || is.null(diagnostics$obs)) {
        stop("`diagnostics` must be the output of diagnose_mfrm(). ", "Run: diagnostics <- diagnose_mfrm(fit)", 
            call. = FALSE)
    }
    fit_model <- as.character(fit$config$model %||% fit$summary$Model[1] %||% NA_character_)
    if (!is.numeric(xtreme) || length(xtreme) != 1L || !is.finite(xtreme) || xtreme < 0 || xtreme >= 
        fit$prep$rating_max - fit$prep$rating_min) 
        stop("`xtreme` must be finite, nonnegative and less than the score range.", call. = FALSE)
    if (xtreme > 0 && (!identical(fit$config$method, "JML") || !fit_model %in% c("RSM", "PCM") || length(fit$config$interaction_specs))) 
        stop("Extreme bias extrapolation requires ordinary additive RSM/PCM JML.", call. = FALSE)
    if (xtreme > 0 && any(fit$config$anchor_summary$GroupAnchors > 0)) 
        stop("Extreme bias extrapolation does not support group-mean anchors.", call. = FALSE)
    mfrm_results_validate_diagnostics_identity(fit, diagnostics, helper = "estimate_bias()")
    if (is.null(interaction_facets)) {
        if (is.null(facet_a) || is.null(facet_b)) {
            stop("Provide either `interaction_facets` (length >= 2) ", "or both `facet_a` and `facet_b`.", 
                call. = FALSE)
        }
        interaction_facets <- c(as.character(facet_a[1]), as.character(facet_b[1]))
    }
    interaction_facets <- as.character(interaction_facets)
    interaction_facets <- interaction_facets[!is.na(interaction_facets) & nzchar(interaction_facets)]
    interaction_facets <- unique(interaction_facets)
    if (length(interaction_facets) < 2) {
        stop("`interaction_facets` must contain at least two facet names.")
    }
    if (is.null(facet_a) && length(interaction_facets) >= 1) 
        facet_a <- interaction_facets[1]
    if (is.null(facet_b) && length(interaction_facets) >= 2) 
        facet_b <- interaction_facets[2]
    known_facets <- unique(c("Person", as.character(fit$config$facet_names %||% character())))
    unknown <- setdiff(as.character(interaction_facets), known_facets)
    if (length(unknown) > 0L) {
        stop("`facet_a` / `facet_b` / `interaction_facets` refer to facets ", "that are not part of this fit. Unknown: ", 
            paste(shQuote(unknown), collapse = ", "), ". Available facets: ", paste(shQuote(known_facets), 
                collapse = ", "), ".", call. = FALSE)
    }
    person_interaction <- "Person" %in% interaction_facets
    if (isTRUE(person_interaction)) {
        warn_bias_person_screen(fit, helper = "estimate_bias()")
    }
    out <- estimate_bias_interaction(res = fit, diagnostics = diagnostics, facet_a = facet_a, facet_b = facet_b, 
        interaction_facets = interaction_facets, max_abs = max_abs, omit_extreme = omit_extreme, max_iter = max_iter, 
        tol = tol, xtreme = xtreme)
    if (is.list(out) && length(out) > 0) {
        class(out) <- c("mfrm_bias", class(out))
        out$fit_identity <- mfrm_result_fit_identity(fit)
        out$xtreme <- xtreme
        out$person_interaction <- person_interaction
        out$person_source_column <- as.character(fit$config$source_columns$person %||% "Person")[1]
        out$person_interaction_note <- if (isTRUE(person_interaction)) {
            bias_person_screen_note(fit)
        }
        else {
            ""
        }
        if (identical(fit_model, "GPCM")) {
            out$method <- "GPCM-slope-aware"
            out$caveat <- paste0("GPCM bias estimates use the slope-aware GPCM kernel: the bias ", "parameter is the additive shift on the linear predictor that ", 
                "maximises the GPCM log-likelihood for the interaction cell. ", "For GPCM rows, `LR ChiSq`, `LR Prob.`, and profile-CI columns ", 
                "compare that fitted shift with zero by conditional profile ", "likelihood. All reported bias quantities still hold theta, steps, ", 
                "slopes, and other facet estimates fixed, so use them for screening ", "and follow-up review rather than as standalone fairness claims.")
        }
    }
    out
}
