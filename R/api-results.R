mfrm_results_unavailable_error <- function(message, call = NULL) {
    structure(list(message = as.character(message[1] %||% ""), call = call), class = c("mfrmr_results_unavailable_error", 
        "error", "condition"))
}

stop_mfrm_results_unavailable <- function(message) {
    stop(mfrm_results_unavailable_error(message))
}

mfrm_results_native_diagnostics_match <- function(fit, diagnostics) {
    source <- diagnostics$parameter_uncertainty$source
    current <- mfrm_native_location_identity(fit)
    fields <- setdiff(names(current), c("readiness", "optimizer"))
    if (!is.list(source) || !all(fields %in% names(source))) 
        return(FALSE)
    if (!identical(dim(source$source$data), dim(current$source$data))) 
        return(FALSE)
    if (!isTRUE(all.equal(source[fields], current[fields], tolerance = 0, use.names = FALSE))) 
        return(FALSE)
    if (!isTRUE(all.equal(as.data.frame(diagnostics$fit_readiness), as.data.frame(mfrmr_get_readiness_record(fit)$fit), 
        check.attributes = FALSE))) 
        return(FALSE)
    evidence <- logical(0)
    obs <- as.data.frame(diagnostics$obs %||% data.frame(), stringsAsFactors = FALSE)
    fit_data <- as.data.frame(fit$prep$data %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(obs) > 0L || nrow(fit_data) > 0L) {
        identity_columns <- unique(c("Person", as.character(fit$config$facet_names %||% character(0)), 
            "Score", "Weight", "score_k"))
        identity_columns <- intersect(identity_columns, names(fit_data))
        if (!all(identity_columns %in% names(obs))) 
            return(FALSE)
        if (nrow(obs) != nrow(fit_data) || length(identity_columns) == 0L) 
            return(FALSE)
        obs_identity <- obs[, identity_columns, drop = FALSE]
        fit_identity <- fit_data[, identity_columns, drop = FALSE]
        rownames(obs_identity) <- NULL
        rownames(fit_identity) <- NULL
        if (!isTRUE(all.equal(obs_identity, fit_identity, check.attributes = FALSE))) 
            return(FALSE)
        evidence <- c(evidence, TRUE)
    }
    diagnostic_facets <- sort(as.character(diagnostics$facet_names %||% character(0)))
    fit_facets <- sort(as.character(fit$config$facet_names %||% character(0)))
    if (length(diagnostic_facets) > 0L) {
        if (!identical(diagnostic_facets, fit_facets)) 
            return(FALSE)
        evidence <- c(evidence, TRUE)
    }
    measures <- as.data.frame(diagnostics$measures %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(measures) > 0L && all(c("Facet", "Level", "Estimate") %in% names(measures))) {
        person <- as.data.frame(fit$facets$person %||% data.frame(), stringsAsFactors = FALSE)
        facets <- as.data.frame(fit$facets$others %||% data.frame(), stringsAsFactors = FALSE)
        person_measures <- if (nrow(person) > 0L && all(c("Person", "Estimate") %in% names(person))) {
            data.frame(Facet = "Person", Level = as.character(person$Person), Estimate = suppressWarnings(as.numeric(person$Estimate)), 
                stringsAsFactors = FALSE)
        }
        else {
            data.frame(Facet = character(0), Level = character(0), Estimate = numeric(0))
        }
        facet_measures <- if (nrow(facets) > 0L && all(c("Facet", "Level", "Estimate") %in% names(facets))) {
            data.frame(Facet = as.character(facets$Facet), Level = as.character(facets$Level), Estimate = suppressWarnings(as.numeric(facets$Estimate)), 
                stringsAsFactors = FALSE)
        }
        else {
            data.frame(Facet = character(0), Level = character(0), Estimate = numeric(0))
        }
        fit_measures <- rbind(person_measures, facet_measures)
        if (nrow(fit_measures) == 0L) 
            return(FALSE)
        measure_key <- paste(as.character(measures$Facet), as.character(measures$Level), sep = "\r")
        fit_key <- paste(fit_measures$Facet, fit_measures$Level, sep = "\r")
        if (anyNA(measures[c("Facet", "Level")]) || anyDuplicated(measure_key) || anyDuplicated(fit_key)) 
            return(FALSE)
        idx <- match(measure_key, fit_key)
        if (anyNA(idx)) 
            return(FALSE)
        diagnostic_estimate <- suppressWarnings(as.numeric(measures$Estimate))
        fit_estimate <- fit_measures$Estimate[idx]
        if (!isTRUE(all.equal(diagnostic_estimate, fit_estimate, tolerance = 1e-10, check.attributes = FALSE))) 
            return(FALSE)
        evidence <- c(evidence, TRUE)
    }
    length(evidence) > 0L && all(evidence)
}

mfrm_result_fit_identity <- function(fit) {
    source <- mfrm_native_location_identity(fit)
    source[c("readiness", "optimizer")] <- NULL
    source$locations <- fit$facets$others
    source$persons <- fit$facets$person
    list(version = 1L, fingerprint = mfrm_checkpoint_fingerprint(source, canonical = TRUE))
}



mfrm_results_validate_diagnostics_identity <- function(fit, diagnostics, helper = "mfrm_results()") {
    stop_if_product_slopes(fit, "mfrm_results_validate_diagnostics_identity()")
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an mfrm_fit object.", call. = FALSE)
    }
    if (!inherits(diagnostics, "mfrm_diagnostics")) {
        stop("`diagnostics` must be an mfrm_diagnostics object returned by diagnose_mfrm().", call. = FALSE)
    }
    validate_diagnostics_precision(diagnostics)
    if (inherits(fit, "mfrm_imported_fit") || inherits(diagnostics, "mfrm_imported_diagnostics")) {
        matched <- inherits(fit, "mfrm_imported_fit") && inherits(diagnostics, "mfrm_imported_diagnostics") && 
            !is.null(fit$diagnostics) && identical(fit$diagnostics, diagnostics)
        if (!isTRUE(matched)) {
            stop("fit/diagnostics mismatch in `", helper, "`: imported diagnostics must ", "be the diagnostics stored in the matching imported fit.", 
                call. = FALSE)
        }
        return(invisible("imported_identity_match"))
    }
    if (!identical(diagnostics$calculation_version, 2L)) 
        stop("Saved diagnostics predate the current calculation definitions. Recompute diagnose_mfrm(fit, ...); no model refit is needed.", 
            call. = FALSE)
    if (!identical(as.character(diagnostics$fit_readiness$ReadinessContractVersion), mfrmr_readiness_contract_version())) {
        stop("The supplied diagnostics lack the current readiness contract. Recompute them with diagnose_mfrm(fit, ...).", 
            call. = FALSE)
    }
    if (is.null(diagnostics$parameter_uncertainty$source)) {
        stop("These saved diagnostics do not record their fitted calibration. Recompute diagnose_mfrm(fit, ...); no model refit is needed.", 
            call. = FALSE)
    }
    if (!isTRUE(mfrm_results_native_diagnostics_match(fit, diagnostics))) {
        stop("fit/diagnostics mismatch in `", helper, "`: the supplied diagnostics ", "do not match this fitted analysis. Recompute them with diagnose_mfrm(fit, ...).", 
            call. = FALSE)
    }
    invisible("structural_identity_match")
}
