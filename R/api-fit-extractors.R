mfrm_extractor_native <- function(object) {
    if (inherits(object, "mfrm_imported_fit") || !inherits(object, c("mfrm_fit", "mfrm_cml_fit", "mfrm_comparison_fit"))) 
        stop("These extractors require a native fit_mfrm() result; use the source model's summary and methods.", 
            call. = FALSE)
}

coef.mfrm_fit <- function(object, type = c("free", "locations", "steps", "slopes", "persons"), ...) {
    rlang::check_dots_empty()
    mfrm_extractor_native(object)
    type <- match.arg(type)
    if (type == "free") {
        stop_if_jml_adjustment(object, "coef(type = 'free')")
        if (!identical(object$config$facet_shrinkage %||% "none", "none")) 
            stop("Penalized coefficients require their model-specific summary; use explicit primary component extraction.", 
                call. = FALSE)
        primary <- c(object$facets$others[["Estimate"]], object$facets$person[["Estimate"]], object$steps[["Estimate"]], 
            object$slopes[["Estimate"]])
        if (any(!is.finite(primary))) 
            stop("Nonfinite primary estimates cannot be replaced with optimizer proxies. Use coef(type = 'locations'), 'persons', 'steps' or 'slopes', and inspect summary().", 
                call. = FALSE)
        values <- object$opt$par
        labels <- if (inherits(object, "mfrm_cml_fit")) 
            names(values)
        else mfrm_checkpoint_parameter_names(build_param_sizes(object$config))
    }
    else {
        tab <- switch(type, locations = object$facets$others, steps = object$steps, slopes = object$slopes, 
            persons = object$facets$person)
        if (!is.data.frame(tab) || !"Estimate" %in% names(tab)) 
            stop("This fit has no saved ", type, " estimates; inspect its model-specific summary.", call. = FALSE)
        keys <- switch(type, locations = c("Facet", "Level"), steps = c("StepFacet", "Step"), slopes = intersect(c("SlopeOwner", 
            "SlopeFacet"), names(tab)), persons = "Person")
        if (!length(keys) || !all(keys %in% names(tab))) 
            stop("Saved coefficient labels are incomplete.", call. = FALSE)
        labels <- do.call(paste, c(lapply(tab[keys], function(x) encodeString(as.character(x), quote = "\"")), 
            sep = ":"))
        values <- tab$Estimate
    }
    if (!is.numeric(values) || length(labels) != length(values) || anyNA(labels) || anyDuplicated(labels) || 
        any(!nzchar(labels))) 
        stop("Saved coefficient coordinates are incomplete or ambiguous.", call. = FALSE)
    stats::setNames(as.numeric(values), labels)
}

coef.mfrm_comparison_fit <- function(object, ...) {
    rlang::check_dots_empty()
    stats::setNames(as.numeric(object$comparisons$Estimate), as.character(object$comparisons$Comparison))
}

vcov.mfrm_fit <- function(object, ...) {
    rlang::check_dots_empty()
    mfrm_extractor_native(object)
    if (!identical(object$config$method, "MML")) 
        stop("Structural covariance requires MML or native CML; JML point estimates do not supply structural-truth Wald inference.", 
            call. = FALSE)
    coefficients <- coef(object)
    facet <- object$config$facet_names[1L]
    ci <- mfrm_facet_intervals(object, facet)
    value <- ci$parameter_covariance
    if (is.null(value) && is.character(ci$unavailable_reason) && length(ci$unavailable_reason) == 1L && 
        !is.na(ci$unavailable_reason) && nzchar(ci$unavailable_reason)) {
        if (8 * as.double(length(coefficients))^2 > getOption("mfrmr.max_information_bytes", 256 * 1024^2)) 
            stop(paste("The requested NA covariance matrix exceeds option mfrmr.max_information_bytes.", 
                ci$unavailable_reason, "Use mfrm_facet_intervals() for target-level results."), call. = FALSE)
        value <- matrix(NA_real_, length(coefficients), length(coefficients))
        attr(value, "unavailable_reason") <- ci$unavailable_reason
    }
    else if (!is.matrix(value) || !identical(dim(value), rep(length(coefficients), 2L)) || any(!is.finite(value)) || 
        (!is.null(ci$checks) && !all(ci$checks$Passed %in% TRUE))) {
        reasons <- ci$checks$Detail[!ci$checks$Passed %in% TRUE]
        stop(paste("Joint covariance is unavailable.", paste(unique(reasons), collapse = " "), "Inspect mfrm_facet_intervals() checks and inference reasons."), 
            call. = FALSE)
    }
    dimnames(value) <- list(names(coefficients), names(coefficients))
    attr(value, "checks") <- ci$checks
    attr(value, "numerical_checks") <- ci$numerical_checks
    attr(value, "information_review") <- ci$information_review
    attr(value, "cautions") <- ci$cautions
    value
}

vcov.mfrm_comparison_fit <- function(object, ...) {
    rlang::check_dots_empty()
    if (!identical(object$config$method, "CML") || !is.matrix(object$covariance)) 
        stop("Comparison-only covariance is available for native CML targets; other comparison-only fits provide descriptive estimates.", 
            call. = FALSE)
    value <- object$covariance
    if (identical(object$optimization$checks$information_status, "unavailable")) {
        attr(value, "unavailable_reason") <- object$optimization$checks$information_reason
        attr(value, "checks") <- object$checks
        attr(value, "cautions") <- object$notes
    }
    value
}

mfrm_coefficient_intervals <- function(object, parm, level) {
    mfrm_extractor_native(object)
    if (mfrm_has_product_slopes(object)) 
        stop("Free-coordinate intervals are not supplied for two-family GPCM; use parm = 'slopes' or parm = 'steps' for separately checked experimental component intervals, or mfrm_facet_intervals() for locations.", 
            call. = FALSE)
    b <- coef(object)
    labels <- names(b)
    if (!length(b) || length(labels) != length(b) || anyNA(labels) || anyDuplicated(labels) || any(!nzchar(labels))) 
        stop("Saved coefficient coordinates are incomplete or ambiguous.", call. = FALSE)
    selected <- seq_along(b)
    if (!is.null(parm)) {
        if (is.object(parm) || !is.null(dim(parm))) 
            stop("`parm` must select coefficient names or integer positions.", call. = FALSE)
        if (is.character(parm)) 
            selected <- match(parm, labels)
        else {
            if (!is.numeric(parm) || is.complex(parm) || any(!is.finite(parm)) || any(parm != floor(parm))) 
                stop("`parm` must select coefficient names or integer positions.", call. = FALSE)
            selected <- parm
        }
        if (!length(selected) || anyNA(selected) || anyDuplicated(selected) || any(selected < 1 | selected > 
            length(b))) 
            stop("`parm` must select distinct existing coefficients; use names(coef(object)). For GPCM slope intervals, use parm = 'slopes'.", 
                call. = FALSE)
    }
    V <- vcov(object)
    if (!is.matrix(V) || !is.numeric(V) || !identical(dim(V), rep(length(b), 2L)) || !setequal(rownames(V), 
        labels) || !setequal(colnames(V), labels) || anyDuplicated(rownames(V)) || anyDuplicated(colnames(V))) 
        stop("Covariance dimensions and names must match the saved coefficient coordinates.", call. = FALSE)
    covariance_notes <- attributes(V)
    covariance_notes <- covariance_notes[intersect(c("checks", "numerical_checks", "information_review", 
        "cautions", "unavailable_reason"), names(covariance_notes))]
    V <- V[labels, labels, drop = FALSE]
    variance <- diag(V)[selected]
    b <- b[selected]
    available <- is.finite(b) & is.finite(variance) & variance > 0
    reason <- rep("Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.", 
        length(b))
    reason[!available] <- "A finite coefficient and positive finite sampling variance are required; no interval is supplied."
    if (length(covariance_notes$unavailable_reason) == 1L && !is.na(covariance_notes$unavailable_reason) && 
        nzchar(covariance_notes$unavailable_reason)) 
        reason[!available] <- paste("Point estimate retained; uncertainty is unavailable:", covariance_notes$unavailable_reason)
    comparison <- inherits(object, "mfrm_comparison_fit")
    if (comparison) {
        flags <- object$comparisons[["FormalInferenceEligible"]]
        allowed <- if (is.logical(flags) && length(flags) == length(labels)) 
            flags[selected] %in% TRUE
        else rep(FALSE, length(selected))
        review <- rep("Saved conditional-target eligibility is unavailable; recreate the comparison fit before interval reporting.", 
            length(selected))
        saved_review <- object$comparisons[["EstimateReason"]]
        if (is.character(saved_review) && length(saved_review) == length(labels)) {
            stated <- !is.na(saved_review[selected]) & nzchar(saved_review[selected])
            if (is.logical(flags) && length(flags) == length(labels)) 
                review[stated] <- saved_review[selected][stated]
        }
        reason[!allowed] <- review[!allowed]
        available <- available & allowed
    }
    se <- sqrt(ifelse(is.finite(variance) & variance >= 0, variance, NA_real_))
    margin <- stats::qnorm((1 - level)/2, lower.tail = FALSE) * se
    out <- cbind(b - margin, b + margin)
    representable <- rowSums(!is.finite(out)) == 0
    reason[available & !representable] <- "Normal interval bounds are not finite on these coefficient coordinates."
    available <- available & representable
    out[!available, ] <- NA_real_
    dimnames(out) <- list(names(b), paste0(format(100 * c((1 - level)/2, (1 + level)/2), trim = TRUE), 
        "%"))
    attr(out, "level") <- level
    attr(out, "target") <- if (comparison) 
        "Saved conditional comparisons"
    else "Free model coordinates, matching coef()"
    attr(out, "method") <- if (object$config$method == "CML") 
        "Conditional-information pointwise Wald"
    else "Joint MML information pointwise Wald"
    attr(out, "diagnostics") <- data.frame(Parameter = names(b), Estimate = unname(b), SE = unname(se), 
        CIEligible = available, Status = ifelse(available, "available", "unavailable"), InferenceReview = reason, 
        row.names = NULL)
    for (key in names(covariance_notes)) if (!is.null(covariance_notes[[key]])) 
        attr(out, key) <- covariance_notes[[key]]
    if (object$config$method == "CML") {
        attr(out, "checks") <- object$checks
        attr(out, "cautions") <- object$notes
    }
    out
}

nobs.mfrm_fit <- function(object, type = c("likelihood", "persons", "ratings"), ...) {
    rlang::check_dots_empty()
    mfrm_extractor_native(object)
    type <- match.arg(type)
    if (type == "likelihood") 
        type <- if (object$config$method %in% c("MML", "CML")) 
            "persons"
        else "ratings"
    data <- object$prep$data
    if (!is.data.frame(data) || !"Person" %in% names(data) || anyNA(data$Person)) 
        stop("The retained response roster is unavailable or incomplete.", call. = FALSE)
    if (type == "persons") 
        length(unique(as.character(data$Person)))
    else nrow(data)
}

logLik.mfrm_fit <- function(object, ...) {
    rlang::check_dots_empty()
    mfrm_extractor_native(object)
    stop_if_jml_adjustment(object, "logLik()")
    if (!identical(object$config$facet_shrinkage %||% "none", "none")) 
        stop("A penalized objective is not exposed as an ordinary log likelihood; use the model-specific summary.", 
            call. = FALSE)
    contract <- mfrm_extract_fit_ic_contract(object)
    if (!isTRUE(contract$StoredICConsistent) || !is.finite(contract$LogLik)) 
        stop("The retained likelihood metadata are missing or inconsistent; inspect the source fit rather than reconstructing a likelihood from legacy summaries.", 
            call. = FALSE)
    eligible <- isTRUE(contract$ICSelectable)
    reason <- switch(as.character(contract$ICStatus), descriptive_jml = "JML retains a joint objective for descriptive use; structural model selection by AIC/BIC is unsupported.", 
        unsupported_product_slopes = "Information criteria are not qualified for two-family GPCM.", suppressed_nonunit_weight = "Nonunit rating weights define a weighted objective; ordinary likelihood information criteria are unavailable.", 
        "The retained likelihood contract does not permit information criteria.")
    if (eligible) {
        check <- mfrm_ic_fit_check(object, contract)
        eligible <- isTRUE(check$eligible)
        reason <- if (eligible) 
            "Current MML likelihood and solution checks permit information criteria; model comparisons require matched sources."
        else check$review
    }
    else if (isTRUE(contract$ICEligible)) 
        reason <- "The retained quadrature grid is not qualified for information-criterion selection."
    basis <- if (identical(object$config$method, "MML")) 
        "marginal"
    else "joint"
    if (!contract$WeightPolicy %in% c("unweighted", "explicit_unit")) 
        basis <- paste0("weighted_", basis, "_objective")
    structure(as.numeric(contract$LogLik), df = if (eligible) 
        as.integer(contract$Npar)
    else NA_integer_, nobs = nobs(object), parameter_count = as.integer(contract$Npar), likelihood_basis = basis, 
        ICEligible = eligible, ICReason = reason, class = "logLik")
}

logLik.mfrm_comparison_fit <- function(object, ...) {
    rlang::check_dots_empty()
    stop("Comparison-only fits do not supply a generic full-model log likelihood or information criteria; use summary().", 
        call. = FALSE)
}

AIC.mfrm_fit <- function(object, ..., k = 2) {
    if (length(list(...))) 
        stop("Use compare_mfrm() for supported model comparisons; conditional and marginal likelihoods must not be mixed.", 
            call. = FALSE)
    if (!is.numeric(k) || is.complex(k) || length(k) != 1L || !is.finite(k)) 
        stop("`k` must be one finite numeric penalty.", call. = FALSE)
    stats::AIC(logLik(object), k = k)
}

BIC.mfrm_fit <- function(object, ...) {
    if (length(list(...))) 
        stop("Use compare_mfrm() for supported model comparisons; conditional and marginal likelihoods must not be mixed.", 
            call. = FALSE)
    stats::BIC(logLik(object))
}
