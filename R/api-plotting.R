as.data.frame.mfrm_fit <- function(x, row.names = NULL, optional = FALSE, ...) {
    if (mfrm_has_jml_adjustment(x)) {
        rlang::check_dots_empty()
        person <- x$facets$person
        person$Facet <- "Person"
        person$Level <- person$Person
        person$Person <- person$SE <- NULL
        out <- as.data.frame(dplyr::bind_rows(person, x$facets$others), row.names = row.names, optional = optional)
        attr(out, "estimation_note") <- .mfrmr_const_mfrm_jml_note
        return(out)
    }
    person_extreme <- if ("Extreme" %in% names(x$facets$person)) {
        as.character(x$facets$person$Extreme)
    }
    else {
        rep(NA_character_, nrow(x$facets$person))
    }
    person_df <- data.frame(Facet = "Person", Level = as.character(x$facets$person$Person), Estimate = x$facets$person$Estimate, 
        Extreme = person_extreme, stringsAsFactors = FALSE)
    facet_df <- as.data.frame(x$facets$others[, c("Facet", "Level", "Estimate")], stringsAsFactors = FALSE)
    facet_df$Level <- as.character(facet_df$Level)
    facet_df$Extreme <- NA_character_
    rbind(person_df, facet_df)
}

print.mfrm_fit <- function(x, ...) {
    if (mfrm_has_jml_adjustment(x)) {
        print(summary(x))
        return(invisible(x))
    }
    if (is.list(x) && !is.null(x$summary) && nrow(x$summary) > 0) {
        ov <- round_numeric_df(as.data.frame(x$summary), digits = 3L)[1, , drop = FALSE]
        fit_summary <- tryCatch(summary(x), error = function(e) NULL)
        scale_contract <- tryCatch(mfrm_fit_scale_contract(x), error = function(e) tibble::tibble())
        cat("mfrm_fit object\n")
        print_wrapped_line(sprintf("Model: %s | Method: %s",
            .mfrm_model_label(as.character(ov$Model %||% NA_character_), x$config$slope_facet),
            ov$Method %||%
            NA_character_))
        print_wrapped_line(sprintf("N: %s | Persons: %s | Facets: %s | Categories: %s", ov$N %||% NA, 
            ov$Persons %||% NA, ov$Facets %||% NA, ov$Categories %||% NA))
        decision_available <- !is.null(fit_summary) && nrow(fit_summary$decision %||% data.frame()) == 
            1L
        if (decision_available) {
            print_fit_decision_section(fit_summary$decision)
        }
        if (!is.null(fit_summary)) {
            print_wrapped_line(fit_summary$estimation_note %||% character(0))
            mml_contract_lines <- mfrm_mml_integration_console_lines(fit_summary)
            if (length(mml_contract_lines) > 0L) {
                print_wrapped_line(mml_contract_lines)
            }
        }
        if (nrow(scale_contract) > 0L) {
            population_sd <- as.numeric(scale_contract$PopulationSD[1])
            population_text <- if (is.finite(population_sd)) {
                paste0(" | Population SD: ", formatC(population_sd, digits = 3L, format = "fg"))
            }
            else {
                ""
            }
            print_wrapped_line(sprintf("Scale: %s | Discrimination: %s%s", switch(as.character(scale_contract$CoordinateBasis[1]), 
                joint_person_coordinate_scale = "jointly estimated Person measures", fixed_standard_normal = "fixed standard-normal population", 
                estimated_population_scale = "estimated population", estimated_population_mean_fixed_sd = "estimated population mean, fixed SD", 
                "see fitted scale settings"), if (identical(scale_contract$SlopeBasis[1], "owner_specific_product_discrimination")) 
                "product of facet slopes; first family geometric mean 1, second family free"
            else if (identical(as.character(scale_contract$Model[1]), "GPCM")) 
                "relative slopes with geometric mean 1"
            else "fixed at 1", population_text))
            if (identical(as.character(scale_contract$Model[1]), "GPCM")) {
                print_wrapped_line(mfrm_gpcm_console_lines(scale_contract))
            }
        }
        ic_lines <- mfrm_ic_console_lines(x$summary, digits = 3L)
        if (length(ic_lines) > 0L) {
            print_wrapped_line(ic_lines)
        }
        if ("Converged" %in% names(ov) && "ConvergenceStatus" %in% names(ov)) {
            convergence <- mfrm_convergence_state(x)
            status_label <- switch(convergence$status, converged = "No further numerical review indicated", 
                converged_gradient_review = "Terminal gradient needs review", reviewable_warning = "Optimizer warning needs review", 
                iteration_limit = "Iteration limit reached", optimizer_warning = "Optimizer warning", 
                unknown = "Status unavailable", convergence$status)
            print_wrapped_line(sprintf("Optimizer returned code 0: %s | Convergence review: %s", ifelse(convergence$code_converged, 
                "Yes", "No"), status_label))
            if (!decision_available) {
                print_wrapped_line("Formal inference: not established; the interpretation decision is unavailable.")
            }
        }
        if (isTRUE(x$config$attached_diagnostics)) {
            attached_cols <- as.character(x$config$attached_diagnostics_cols %||% character(0))
            if (length(attached_cols) > 0L) {
                print_wrapped_line(sprintf("Attached diagnostics: %s", paste(attached_cols, collapse = ", ")))
            }
            else {
                cat("  Attached diagnostics: yes (per-element fit columns merged)\n")
            }
        }
        if (!decision_available) {
            if (!is.null(fit_summary) && nrow(fit_summary$status %||% data.frame()) > 0) {
                first_status <- fit_summary$status[1, , drop = FALSE]
                print_wrapped_line(sprintf("Summary status: %s", first_status$Value[1] %||% NA_character_))
            }
            if (!is.null(fit_summary) && length(fit_summary$key_warnings) > 0 && !summary_lines_are_default(fit_summary$key_warnings, 
                "No immediate warnings from fit-level summary checks.")) {
                print_wrapped_line(paste0("Key warning: ", fit_summary$key_warnings[1]))
            }
            if (!is.null(fit_summary) && length(fit_summary$next_actions) > 0) {
                print_wrapped_line(paste0("Next: ", fit_summary$next_actions[1]))
            }
            else {
                cat("  Next: use `summary(x)` for details.\n")
            }
        }
        cat("  Use `summary(x)` for the full fit summary.\n")
    }
    else {
        cat("mfrm_fit object (empty summary)\n")
    }
    invisible(x)
}
