mfrmr_gt_boundary_status <- function(fit_lmer, lmer_warnings = character(0), lmer_messages = character(0), 
    tolerance = 1e-04) {
    singular_fit <- tryCatch(isTRUE(lme4::isSingular(fit_lmer, tol = tolerance)), error = function(e) NA)
    boundary_text <- c(lmer_warnings, lmer_messages)
    boundary_message <- any(grepl("boundary|singular", boundary_text, ignore.case = TRUE))
    opt <- fit_lmer@optinfo
    convergence_review <- length(lmer_warnings) > 0L || any(unlist(opt$conv$opt) != 0, na.rm = TRUE) || 
        length(opt$conv$lme4$messages) > 0L
    status <- if (isTRUE(singular_fit) || isTRUE(boundary_message)) {
        "boundary_or_singular_fit"
    }
    else if (is.na(singular_fit)) {
        "singularity_check_unavailable"
    }
    else if (convergence_review) {
        "convergence_review"
    }
    else {
        "identified"
    }
    note <- switch(status, boundary_or_singular_fit = paste("The lme4 random-effects fit is singular or on a boundary;", 
        "zero variance estimates are retained. This is distinct from whether", "the design separates variance components; inspect component_identification.", 
        "Point coefficients do not establish uncertainty or decision accuracy."), singularity_check_unavailable = paste("The lme4 singularity check was unavailable;", 
        "treat G/D-study coefficients as caveated until the fitted", "random-effects structure is reviewed."), 
        convergence_review = "The mixed-model fit has unresolved convergence warnings; review its numerical stability before using G/D projections.", 
        "No lme4 boundary or singular fit was detected.")
    list(identification_status = status, identification_note = note, boundary_fit = identical(status, 
        "boundary_or_singular_fit"), singular_fit = singular_fit, singular_tolerance = tolerance, boundary_message = boundary_message)
}

mfrmr_gt_classify_coef <- function(value, identification_status = "identified") {
    if (!identical(as.character(identification_status)[1L], "identified")) {
        return(ifelse(is.finite(value), "identification_warning", "unavailable"))
    }
    dplyr::case_when(!is.finite(value) ~ "unavailable", value >= 0.8 ~ "at_or_above_0.80_reference", 
        value >= 0.7 ~ "at_or_above_0.70_reference", TRUE ~ "below_0.70_reference")
}

validate_gtheory_output <- function(x) {
    version <- if (inherits(x, "mfrm_generalizability")) 
        x$design$calculation_version
    else attr(x, "calculation_version")
    if (!identical(version, 2L)) {
        stop(paste("This saved G/D result used earlier variance handling.", "Recreate mfrm_generalizability(fit) and any mfrm_d_study() results;", 
            "the MFRM fit need not be re-estimated."), call. = FALSE)
    }
    invisible(TRUE)
}

gtheory_scaling_label <- function(x) {
    labels <- c(highest_order = "Divide residual by all facet counts", single_condition = "Divide residual by smallest facet count", 
        none = "Keep residual unchanged", sensitivity = "Compare three residual assumptions")
    ifelse(x %in% names(labels), unname(labels[x]), x)
}

print_gtheory_data_usage <- function(usage) {
    if (is.null(usage)) {
        cat("  Input-row accounting is unavailable for this saved result.\n")
    }
    else {
        counts <- usage$counts
        cat("  G-study rows:", counts[["InputRows"]], "input;", counts[["UsedRows"]], "used;", counts[["ExcludedRows"]], 
            "excluded.\n")
        if (identical(usage$source, "Stored fitted rows")) {
            cat("  Counts start from stored fitted rows; earlier MFRM filtering is not included.\n")
        }
        if (counts[["ExcludedRows"]] > 0L) {
            cat("  Incomplete rows were explicitly omitted; no missing values were imputed.\n")
        }
    }
}

mfrm_generalizability <- function(fit, data = NULL, object_facet = "Person", random_facets = NULL, reml = TRUE, 
    missing = c("error", "omit")) {
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
    }
    if (!requireNamespace("lme4", quietly = TRUE)) {
        stop("`mfrm_generalizability()` requires the `lme4` package ", "(in Suggests). Install it and retry.", 
            call. = FALSE)
    }
    missing <- match.arg(missing)
    if (!is.logical(reml) || length(reml) != 1L || is.na(reml)) {
        stop("`reml` must be TRUE or FALSE.", call. = FALSE)
    }
    data_source <- if (is.null(data)) 
        "Stored fitted rows"
    else "Supplied data"
    if (is.null(data)) {
        data <- as.data.frame(fit$prep$data %||% data.frame(), stringsAsFactors = FALSE)
    }
    if (!is.data.frame(data) || nrow(data) == 0L || anyNA(names(data)) || anyDuplicated(names(data)) || 
        any(!nzchar(names(data)))) {
        stop("`data` must be a nonempty data frame with unique, nonmissing column names.", call. = FALSE)
    }
    data <- as.data.frame(data)
    facet_names <- as.character(fit$config$facet_names %||% character(0))
    if (is.null(random_facets)) {
        random_facets <- setdiff(c("Person", facet_names), object_facet)
    }
    random_facets <- as.character(random_facets)
    if (!is.character(object_facet) || length(object_facet) != 1L || is.na(object_facet) || anyNA(random_facets) || 
        anyDuplicated(c(object_facet, random_facets)) || any(!nzchar(c(object_facet, random_facets)))) {
        stop("The object facet and random facets must be distinct, non-missing names.", call. = FALSE)
    }
    if (length(random_facets) == 0L) {
        stop("At least one other facet is required as a random ", "condition of measurement.", call. = FALSE)
    }
    if (any(c(object_facet, random_facets) %in% c("Score", "Residual"))) {
        stop("`Score` and `Residual` are reserved and cannot be facet names.", call. = FALSE)
    }
    needed_cols <- c(object_facet, random_facets, "Score")
    missing_cols <- setdiff(needed_cols, names(data))
    if (length(missing_cols) > 0L) {
        stop("Data frame is missing required columns: ", paste(missing_cols, collapse = ", "), ".", call. = FALSE)
    }
    prepared <- mfrm_prepare_variance_data(data, c(object_facet, random_facets), "Score", needed_cols, 
        missing, source = data_source, gstudy = TRUE)
    data <- prepared$data
    data_usage <- prepared$data_usage
    random_terms <- c(object_facet, random_facets)
    formula_str <- paste0("Score ~ 1 + ", paste0("(1 | ", vapply(random_terms, function(name) deparse1(as.name(name), 
        backtick = TRUE), character(1)), ")", collapse = " + "))
    formula <- stats::as.formula(formula_str)
    lmer_warnings <- character(0)
    lmer_messages <- character(0)
    fit_lmer <- tryCatch(withCallingHandlers(lme4::lmer(formula, data = data, REML = reml, na.action = stats::na.fail), 
        warning = function(w) {
            lmer_warnings <<- c(lmer_warnings, conditionMessage(w))
            invokeRestart("muffleWarning")
        }, message = function(m) {
            lmer_messages <<- c(lmer_messages, conditionMessage(m))
            invokeRestart("muffleMessage")
        }), error = function(e) e)
    if (inherits(fit_lmer, "error")) {
        stop("lme4::lmer failed: ", conditionMessage(fit_lmer), call. = FALSE)
    }
    boundary_status <- mfrmr_gt_boundary_status(fit_lmer, lmer_warnings = lmer_warnings, lmer_messages = lmer_messages)
    vc <- as.data.frame(lme4::VarCorr(fit_lmer))
    vc <- vc[is.na(vc$var2), c("grp", "vcov")]
    variance_scale <- max(vc$vcov)
    scaled_variances <- if (is.finite(variance_scale) && variance_scale > 0) 
        vc$vcov/variance_scale
    else rep(NA_real_, nrow(vc))
    var_components <- data.frame(Source = as.character(vc$grp), Variance = as.numeric(vc$vcov), ProportionVariance = scaled_variances/sum(scaled_variances), 
        stringsAsFactors = FALSE)
    geometry <- .mfrmr_gt_geometry(data, random_terms, reml)
    var_components$Identified <- vapply(var_components$Source, function(source) {
        w <- stats::setNames(rep(0, length(geometry$scale)), names(geometry$scale))
        w[source] <- 1
        .mfrmr_gt_estimable(w, geometry)
    }, logical(1))
    fit_status <- boundary_status$identification_status
    if (geometry$rank < geometry$components) {
        boundary_status$identification_status <- "components_not_identified"
        boundary_status$identification_note <- paste("The observed assignments do not separate all variance components.", 
            "Retained component allocations are fitted candidates; only identified", "error sums and coefficients are reported. Review component_identification.", 
            boundary_status$identification_note)
    }
    v <- stats::setNames(var_components$Variance, var_components$Source)
    baseline <- .mfrmr_gt_projection(v, object_facet, random_facets, as.data.frame(as.list(stats::setNames(rep(1, 
        length(random_facets)), random_facets))), "highest_order", geometry)
    out <- list(variance_components = var_components, coefficients = data.frame(G = baseline$G, Phi = baseline$Phi, 
        GReason = baseline$GReason, PhiReason = baseline$PhiReason, GStatus = mfrmr_gt_classify_coef(baseline$G, 
            boundary_status$identification_status), PhiStatus = mfrmr_gt_classify_coef(baseline$Phi, 
            boundary_status$identification_status), IdentificationStatus = boundary_status$identification_status, 
        ComponentIdentificationChecked = TRUE, InputRows = data_usage$counts[["InputRows"]], UsedRows = data_usage$counts[["UsedRows"]], 
        ExcludedRows = data_usage$counts[["ExcludedRows"]], GStudyDataSource = data_usage$source, stringsAsFactors = FALSE), 
        data_usage = data_usage, design = list(calculation_version = 2L, object_facet = object_facet, 
            random_facets = random_facets, observed_levels = stats::setNames(vapply(c(object_facet, random_facets), 
                function(col) {
                  dplyr::n_distinct(stats::model.frame(fit_lmer)[[col]])
                }, integer(1)), c(object_facet, random_facets)), formula = format(formula), estimand_scale = "observed_numeric_score", 
            reml = isTRUE(reml), lmer_warnings = lmer_warnings, lmer_messages = lmer_messages, identification_status = boundary_status$identification_status, 
            identification_note = boundary_status$identification_note, boundary_fit = boundary_status$boundary_fit, 
            singular_fit = boundary_status$singular_fit, singular_tolerance = boundary_status$singular_tolerance, 
            boundary_message = boundary_status$boundary_message, fit_status = fit_status, component_identification = geometry))
    class(out) <- c("mfrm_generalizability", "list")
    out
}

mfrm_d_study.mfrm_generalizability <- function(x, design_grid = NULL, residual_scaling = c("highest_order", 
    "single_condition", "none", "sensitivity"), ...) {
    rlang::check_dots_empty()
    residual_scaling <- match.arg(residual_scaling)
    if (!inherits(x, "mfrm_generalizability")) {
        stop("`x` must be output from mfrm_generalizability() or an mfrm_fit object.", call. = FALSE)
    }
    validate_gtheory_output(x)
    random_facets <- as.character(x$design$random_facets %||% character(0))
    if (length(random_facets) == 0L) {
        stop("No random measurement facets are available for D-study projection.", call. = FALSE)
    }
    observed_levels <- x$design$observed_levels %||% NULL
    if (is.null(design_grid)) {
        if (is.null(observed_levels)) {
            stop("`design_grid` is required because observed facet counts are unavailable.", call. = FALSE)
        }
        design_grid <- as.list(observed_levels[random_facets])
    }
    design_grid <- mfrm_d_study_count_columns(design_grid, random_facets, paste0("n_", random_facets))
    count_cols <- names(design_grid)
    counts <- as.data.frame(lapply(count_cols, function(col) suppressWarnings(as.numeric(as.character(design_grid[[col]])))), 
        stringsAsFactors = FALSE)
    names(counts) <- paste0("n_", random_facets)
    counts_matrix <- as.matrix(counts)
    if (any(!is.finite(counts_matrix) | counts_matrix <= 0 | counts_matrix != floor(counts_matrix))) {
        stop("All D-study facet counts must be positive finite integers.", call. = FALSE)
    }
    scaling_levels <- if (identical(residual_scaling, "sensitivity")) {
        c("highest_order", "single_condition", "none")
    }
    else {
        residual_scaling
    }
    if (length(scaling_levels) > 1L) {
        row_index <- rep(seq_len(nrow(counts)), each = length(scaling_levels))
        counts <- counts[row_index, , drop = FALSE]
        scaling_col <- rep(scaling_levels, times = length(unique(row_index)))
    }
    else {
        scaling_col <- rep(scaling_levels, nrow(counts))
    }
    vc <- as.data.frame(x$variance_components, stringsAsFactors = FALSE)
    if (anyDuplicated(vc$Source)) 
        stop("Variance-component sources must be unique.", call. = FALSE)
    v <- stats::setNames(suppressWarnings(as.numeric(vc$Variance)), as.character(vc$Source))
    v[!is.finite(v) | v < 0] <- NA_real_
    projection <- .mfrmr_gt_projection(v, x$design$object_facet, random_facets, counts, scaling_col, 
        x$design$component_identification)
    identification_status <- as.character(x$design$identification_status %||% "review_required")[1L]
    if (is.na(identification_status) || !nzchar(identification_status)) {
        identification_status <- "review_required"
    }
    identification_note <- as.character(x$design$identification_note %||% "")[1L]
    boundary_fit <- isTRUE(x$design$boundary_fit)
    classify_coef <- function(value) {
        mfrmr_gt_classify_coef(value, identification_status)
    }
    out <- cbind(data.frame(Scenario = seq_len(nrow(counts)), counts, stringsAsFactors = FALSE, check.names = FALSE), 
        data.frame(ResidualScaling = scaling_col, projection, GStatus = classify_coef(projection$G), 
            PhiStatus = classify_coef(projection$Phi), IdentificationStatus = rep(identification_status, 
                nrow(counts)), BoundaryFit = rep(boundary_fit, nrow(counts)), IdentificationNote = rep(identification_note, 
                nrow(counts)), ComponentIdentificationChecked = !is.null(x$design$component_identification), 
            InputRows = x$data_usage$counts[["InputRows"]] %||% NA_integer_, UsedRows = x$data_usage$counts[["UsedRows"]] %||% 
                NA_integer_, ExcludedRows = x$data_usage$counts[["ExcludedRows"]] %||% NA_integer_, GStudyDataSource = x$data_usage$source %||% 
                NA_character_, stringsAsFactors = FALSE))
    attr(out, "object_facet") <- x$design$object_facet
    attr(out, "calculation_version") <- 2L
    attr(out, "random_facets") <- random_facets
    attr(out, "residual_scaling") <- residual_scaling
    attr(out, "source") <- "mfrm_generalizability"
    attr(out, "source_design") <- x$design
    attr(out, "source_components") <- x$variance_components
    attr(out, "estimand_scale") <- x$design$estimand_scale %||% "observed_numeric_score"
    attr(out, "identification_status") <- identification_status
    attr(out, "identification_note") <- identification_note
    attr(out, "boundary_fit") <- boundary_fit
    attr(out, "data_usage") <- x$data_usage
    attr(out, "component_identification") <- x$design$component_identification
    class(out) <- c("mfrm_d_study", "data.frame")
    out
}

`[.mfrm_d_study` <- function(x, ...) {
    out <- NextMethod("[")
    if (is.data.frame(out)) {
        metadata <- setdiff(names(attributes(x)), c("names", "row.names", "class"))
        for (name in metadata) attr(out, name) <- attr(x, name, exact = TRUE)
    }
    out
}

print.mfrm_d_study <- function(x, ...) {
    validate_gtheory_output(x)
    cat("mfrmr D-study projection\n")
    cat("  Object of measurement:", attr(x, "object_facet") %||% NA_character_, "\n")
    cat("  Random facets:", paste(attr(x, "random_facets") %||% character(0), collapse = ", "), "\n\n")
    cat("  Estimand scale: observed numeric score\n")
    print_gtheory_data_usage(attr(x, "data_usage", exact = TRUE))
    cat("  Residual assumption:", gtheory_scaling_label(attr(x, "residual_scaling") %||% unique(x$ResidualScaling)), 
        "\n\n")
    if (!identical(attr(x, "identification_status") %||% "identified", "identified")) {
        cat("  Model fit requires review.\n")
        note <- attr(x, "identification_note") %||% ""
        if (nzchar(note)) {
            cat("  Note:", note, "\n")
        }
        cat("\n")
    }
    shown <- as.data.frame(x)
    if ("ResidualScaling" %in% names(shown)) {
        shown$ResidualScaling <- gtheory_scaling_label(shown$ResidualScaling)
    }
    shown <- shown[, setdiff(names(shown), c("GStatus", "PhiStatus", "IdentificationStatus", "BoundaryFit", 
        "IdentificationNote", "InputRows", "UsedRows", "ExcludedRows", "GStudyDataSource", "ComponentIdentificationChecked", 
        grep("Reason$", names(shown), value = TRUE))), drop = FALSE]
    print.data.frame(shown, row.names = FALSE, ...)
    if (any(vapply(x[grep("Reason$", names(x), value = TRUE)], function(z) any(nzchar(z)), logical(1)))) 
        print_wrapped_line("Some quantities are unavailable or exceed numerical range; inspect the returned ...Reason columns.")
    if (!isTRUE(all(x$ComponentIdentificationChecked))) 
        print_wrapped_line("Component separation was not checked for this saved source. Recreate the G-study from the original ratings to check it.")
    print_wrapped_line("Observed-score planning projections hold estimated variance components fixed. They do not establish cut-score accuracy or an adequate rating design.")
    cat("\n  Note: 0.70 and 0.80 are reference guides, not universal decision rules.\n")
    invisible(x)
}

print.mfrm_generalizability <- function(x, ...) {
    validate_gtheory_output(x)
    cat("Generalizability-theory decomposition\n")
    cat(sprintf("  Object of measurement: %s\n", x$design$object_facet))
    cat(sprintf("  Random facets: %s\n", paste(x$design$random_facets, collapse = ", ")))
    cat("  Estimand scale: observed numeric score\n")
    print_gtheory_data_usage(x$data_usage)
    print_wrapped_line("This main-effects model does not separate person-by-facet interactions. G/Phi are point summaries; uncertainty in estimated variance components is omitted.")
    cat("\nVariance components\n")
    print(x$variance_components, row.names = FALSE, digits = 4)
    if (!is.null(x$design$component_identification)) 
        cat("  Component kernel rank:", x$design$component_identification$rank, "of", x$design$component_identification$components, 
            "\n")
    cat(sprintf("\nG (relative): %.3f | Phi (absolute): %.3f\n", as.numeric(x$coefficients$G), as.numeric(x$coefficients$Phi)))
    for (metric in c("G", "Phi")) {
        reason <- x$coefficients[[paste0(metric, "Reason")]]
        if (length(reason) && nzchar(reason)) 
            cat(" ", metric, "unavailable:", reason, "\n")
    }
    if (!identical(x$design$identification_status %||% "identified", "identified")) {
        cat("\nModel fit requires review.\n")
        cat(x$design$identification_note, "\n")
    }
    if (length(x$design$lmer_warnings) > 0L) {
        cat(sprintf("\n%d lme4 warning(s) suppressed; results may be unstable.\n", length(x$design$lmer_warnings)))
    }
    if (length(x$design$lmer_messages) > 0L) {
        cat(sprintf("\n%d lme4 message(s) suppressed; review boundary/convergence diagnostics.\n", length(x$design$lmer_messages)))
    }
    invisible(x)
}
