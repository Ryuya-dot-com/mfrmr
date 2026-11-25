mfrm_has_jml_adjustment <- function(fit) {
    is.list(fit) && isTRUE(fit$config$jml_adjustment)
}

mfrm_jml_point_label <- function(status) switch(status, consistent_roots = "Starting values led to the same local solution", 
    root_with_unresolved_starts = "A local solution was found; other starting values remain unresolved", 
    multiple_roots = "Different local solutions were found; none selected", "No supported local solution was found")

mfrm_jml_covariance_reason <- function(result) {
    if (!isTRUE(result$point$available)) 
        return(mfrm_jml_point_label(result$point$status))
    result$covariance$reason
}

stop_if_jml_adjustment <- function(fit, helper) {
    if (mfrm_has_jml_adjustment(fit)) 
        stop("`", helper, "` is not available for corrected JML. Use summary(), plot(), mfrm_results() and mfrm_report() for its saved estimates and uncertainty interpretation.", 
            call. = FALSE)
    invisible(NULL)
}

mfrm_fit_adjusted_jml <- function(args, supplied) {
    if (!identical(args$model, "GPCM") || !identical(args$method, "JML") || is.null(args$step_facet) || 
        length(args$step_facet) != 1L || !args$step_facet %in% args$facets || (!is.null(args$slope_facet) && 
        !identical(args$slope_facet, args$step_facet))) 
        stop("Corrected JML requires model = 'GPCM', method = 'JML', an explicit step_facet, and the same slope_facet (or NULL).", 
            call. = FALSE)
    allowed <- c("data", "person", "facets", "score", "rating_min", "rating_max", "keep_original", "category_policy", 
        "model", "method", "step_facet", "slope_facet", "maxit", "jml_correction_order", "jml_correction_sampling", 
        "repeated_ratings")
    bad <- setdiff(supplied, allowed)
    if (length(bad)) 
        stop("These arguments are not supported by corrected JML: ", paste(bad, collapse = ", "), ". This route uses observed unit-weight ratings, centered fixed facets, no anchors/interactions, and its recorded equation-solving tolerances.", 
            call. = FALSE)
    args$jml_correction_sampling <- match.arg(args$jml_correction_sampling, c("fixed_rosters", "random_rosters"))
    if (is.null(args$rating_min) || is.null(args$rating_max)) 
        stop("Declare rating_min and rating_max for corrected JML so unobserved score categories are preserved.", 
            call. = FALSE)
    selected <- c(args$person, args$facets, args$score)
    if (!all(selected %in% names(args$data)) || anyNA(args$data[selected])) 
        stop("Corrected JML requires observed Person/facet IDs and scores; do not supply missing or unassigned ratings as observations.", 
            call. = FALSE)
    if (any(vapply(args$data[c(args$person, args$facets)], function(x) any(!nzchar(as.character(x)) | 
        as.character(x) != trimws(as.character(x))), logical(1)))) 
        stop("Corrected-JML IDs must be nonempty and have no surrounding whitespace.", call. = FALSE)
    if (!is.numeric(args$data[[args$score]]) || is.complex(args$data[[args$score]]) || any(!is.finite(args$data[[args$score]]))) 
        stop("Corrected JML requires finite numeric observed scores.", call. = FALSE)
    prep <- prepare_mfrm_data(args$data, args$person, args$facets, args$score, rating_min = args$rating_min, 
        rating_max = args$rating_max, keep_original = args$keep_original, repeated_ratings = args$repeated_ratings %||% 
            "review")
    if (!identical(as.numeric(prep$data$Score), as.numeric(args$data[[args$score]])) || prep$rating_min != 
        args$rating_min || prep$rating_max != args$rating_max) 
        stop("Corrected JML preserves the declared category ladder. Use category_policy = 'preserve'; do not collapse categories implicitly.", 
            call. = FALSE)
    problem <- mfrm_jml_adjustment_problem(prep$data, "Person", args$facets, "score_k", args$step_facet, 
        prep$rating_max - prep$rating_min)
    result <- mfrm_jml_adjustment_fit(problem, args$jml_correction_order, maxit = args$maxit, sampling = args$jml_correction_sampling)
    result$covariance$reason <- mfrm_jml_covariance_reason(result)
    display <- result
    if (!isTRUE(result$point$available)) {
        display$point$available <- TRUE
        display$point$beta <- rep(NA_real_, nrow(problem$parameters))
        display$point$theta <- rep(NA_real_, length(problem$persons))
    }
    tables <- mfrm_jml_adjustment_tables(display)
    prep$levels <- c(list(Person = problem$persons), problem$levels[args$facets])
    for (f in c("Person", args$facets)) prep$data[[f]] <- factor(as.character(prep$data[[f]]), levels = prep$levels[[f]])
    label_table <- function(tab) {
        tab$Estimator <- "Profile-score-adjusted JML"
        tab$PointStatus <- mfrm_jml_point_label(result$point$status)
        if ("CovarianceStatus" %in% names(tab)) 
            tab$CovarianceStatus <- if (result$covariance$available) 
                "Available for the adjusted-equation root"
            else "Unavailable"
        tab
    }
    tables$facets <- lapply(tables$facets, label_table)
    tables$steps <- label_table(tables$steps)
    tables$slopes <- label_table(tables$slopes)
    replay <- args[intersect(allowed, names(args))]
    replay$data <- NULL
    replay$package_version <- as.character(utils::packageVersion("mfrmr"))
    config <- list(model = "GPCM", method = "JML", method_input = "JML", jml_adjustment = TRUE, facet_names = args$facets, 
        facet_levels = problem$levels[args$facets], step_facet = args$step_facet, slope_facet = args$step_facet, 
        n_cat = prep$rating_max - prep$rating_min + 1L, n_person = length(problem$persons), rating_min = prep$rating_min, 
        rating_max = prep$rating_max, source_columns = list(person = args$person, facets = args$facets, 
            score = args$score, weight = NULL), replay_inputs = replay, attached_diagnostics = FALSE, 
        repeated_ratings = prep$repeated_ratings, gpcm_estimator_family = "profile_score_adjusted_jml", 
        estimation_control = list(maxit = args$maxit, jml_correction = result$policy))
    summary <- data.frame(Model = "GPCM", Method = "Corrected JML", MethodUsed = "JML", CorrectionOrder = result$estimator$order, 
        N = nrow(prep$data), Persons = length(problem$persons), Facets = length(args$facets), Categories = config$n_cat, 
        Converged = isTRUE(result$point$available), InferenceReady = FALSE, LogLik = NA_real_, Deviance = NA_real_, 
        AIC = NA_real_, BIC = NA_real_, SABIC = NA_real_, ICEligible = FALSE, ICSelectable = FALSE, PointStatus = mfrm_jml_point_label(result$point$status), 
        CovarianceAvailable = result$covariance$available, CovarianceReason = result$covariance$reason)
    structure(c(tables, list(summary = summary, config = config, prep = prep, population = list(active = FALSE), 
        jml_adjustment = result, interactions = list(effects = data.frame(), specs = list()), opt = list(convergence = if (result$point$available) 0L else 1L, 
            message = result$point$status, value = NA_real_, par = NULL))), class = c("mfrm_fit", "list"))
}

mfrm_jml_summary <- function(fit, digits = 3, include_person = FALSE) {
    if (!is.numeric(digits) || length(digits) != 1L || !is.finite(digits) || digits != floor(digits) || 
        digits < 0 || digits > 15) 
        stop("`digits` must be an integer from 0 to 15.", call. = FALSE)
    if (!is.logical(include_person) || length(include_person) != 1L || is.na(include_person)) 
        stop("`include_person` must be TRUE or FALSE.", call. = FALSE)
    z <- fit$jml_adjustment
    state <- mfrm_jml_point_label(z$point$status)
    covariance_reason <- mfrm_jml_covariance_reason(z)
    fit$summary$CovarianceReason <- covariance_reason
    decision <- data.frame(Interpretation = state, FormalInference = "Not established", Why = "Numerical solution and statistical bias are separate questions.", 
        NextAction = "Inspect the estimates, correction order and uncertainty basis before interpretation.")
    attempts <- do.call(rbind, lapply(z$attempts, function(a) data.frame(Start = a$start, Method = a$settings$method, 
        Stage = a$stage, RootAvailable = a$available, EquationResidual = a$residual, RemainingNewtonStep = a$newton_step, 
        Reason = a$reason, Error = a$error %||% "")))
    tables <- list(overview = fit$summary, interpretation = decision, locations = fit$facets$others, 
        steps = fit$steps, slopes = fit$slopes, uncertainty = data.frame(Available = z$covariance$available, 
            Sampling = if (z$estimator$sampling == "fixed_rosters") "Fixed assignment counts" else "Random assignment rosters", 
            RepeatedSampling = if (z$estimator$sampling == "fixed_rosters") "New independent Persons within each assignment pattern; pattern counts fixed" else "New independent Persons and their assignment patterns from the same joint population", 
            AbilityDistribution = "Unspecified and allowed to differ between assignment patterns", SamePersonReassessment = "Not estimated: holding each Person's ability fixed defines a different variance", 
            Target = z$estimator$target, Reason = covariance_reason), interpretation_notes = data.frame(Note = .mfrmr_const_mfrm_jml_note))
    if (include_person) 
        tables$persons <- fit$facets$person
    structure(list(jml_adjustment = TRUE, overview = fit$summary, decision = decision, tables = tables, 
        attempts = attempts, digits = digits, estimation_note = .mfrmr_const_mfrm_jml_note), class = "summary.mfrm_fit")
}

mfrm_jml_print_summary <- function(x) {
    cat("Corrected JML summary (experimental)\n")
    cat("GPCM | Correction order:", x$overview$CorrectionOrder, "| Persons:", x$overview$Persons, "| Ratings:", 
        x$overview$N, "\n")
    print_wrapped_line(x$decision$Interpretation)
    print_wrapped_line(x$estimation_note)
    if (!is.null(x$tables$uncertainty$RepeatedSampling)) 
        print_wrapped_line(paste("RootSE sampling:", x$tables$uncertainty$RepeatedSampling))
    cat("\nRelative discrimination\n")
    print(round_numeric_df(x$tables$slopes[, c("SlopeFacet", "Estimate", "LogRootSE", "RootSE")], x$digits), 
        row.names = FALSE)
    if (!isTRUE(x$overview$CovarianceAvailable)) 
        print_wrapped_line(paste("RootSE unavailable:", x$overview$CovarianceReason))
    cat("\nUse $tables for estimates and $attempts for the numerical record.\n")
    invisible(x)
}
