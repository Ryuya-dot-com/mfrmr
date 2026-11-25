.mfrm_validate_diagnostic_fit <- function(fit) {
    stop_if_product_slopes(fit, "diagnose_mfrm()")
    if (inherits(fit, "mfrm_drift")) {
        stop("Ordinary time-invariant diagnose_mfrm() indices do not apply to dynamic `mfrm_drift` fits. Inspect `summary(fit)`, `fit$checks`, `confint(fit)`, and `plot(fit)`.", 
            call. = FALSE)
    }
    if (inherits(fit, c("mfrm_testlet", "mfrm_random_rater"))) {
        stop("Use mfrm_response_diagnostics() for descriptive testlet/shared-rater posterior predictive residuals. Ordinary diagnose_mfrm() indices are unsupported; numerical checks are not model-fit diagnostics.", 
            call. = FALSE)
    }
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an mfrm_fit object from fit_mfrm(). ", "Got: ", paste(class(fit), collapse = "/"), 
            ".", call. = FALSE)
    }
    if (inherits(fit, "mfrm_imported_fit")) {
        stop("Native response-level diagnostics require a fit_mfrm() result. For imported fit statistics, re-import the source fit with compute_fit = TRUE.", 
            call. = FALSE)
    }
    fit$config$method <- public_mfrm_method_label(fit$config$method)
    fit
}

.mfrm_fit_spec_keys <- function() {
    c("person", "facets", "score", "weight", "rating_min", "rating_max", "category_policy", "keep_original", 
        "missing_codes", "repeated_ratings", "model", "method", "step_facet", "step_constraints", "category_support",
        "facet_formulas", "facet_data", "slope_facet", "slope_reference", "slope_type",
        "gpcm_mml_identification", "anchors", "group_anchors", "anchor_policy", "min_common_anchors", 
        "min_obs_per_element", "min_obs_per_category", "noncenter_facet", "centering_scope", "positive_facets", 
        "dummy_facets", "facet_interactions", "min_obs_per_interaction", "interaction_policy", "population_formula", 
        "person_data", "person_id", "population_policy", "population_sd")
}

.mfrm_fit_control_keys <- function() {
    c("quad_points", "mml_engine", "mml_integration", "mml_accuracy_control", "mml_starts", "gpcm_mml_start", 
        "em_score_tol", "checkpoint", "maxit", "reltol", "optimizer", "progress", "jml_penalty", "jml_correction_order", 
        "jml_correction_sampling", "facet_shrinkage", "facet_prior_sd", "slope_prior_sd", "shrink_person", "attach_diagnostics", 
        "fit_scope", "comparison_review", "fast", "person_score", "xtreme", "whexact", "bias_facets", "warn_connectivity")
}

.mfrm_fit_canonical_defaults <- function() {
    list(data = NULL, person = NULL, facets = NULL, score = NULL, rating_min = NULL, rating_max = NULL, 
        weight = NULL, keep_original = FALSE, missing_codes = NULL, model = c("RSM", "PCM", "GPCM"), 
        method = c("MML", "JML", "JMLE", "JML_jeffreys", "CML"), step_facet = NULL, step_constraints = NULL,
        category_support = NULL, facet_formulas = NULL, facet_data = NULL, slope_facet = NULL,
        slope_type = c("full_predictor", "ability_only"),
        facet_interactions = NULL, min_obs_per_interaction = 10, interaction_policy = c("warn", "error", 
            "silent"), anchors = NULL, group_anchors = NULL, noncenter_facet = "Person", dummy_facets = NULL, 
        positive_facets = NULL, anchor_policy = c("warn", "error", "silent"), min_common_anchors = 5L, 
        min_obs_per_element = 30, min_obs_per_category = 10, quad_points = 31, maxit = 400, reltol = 1e-09, 
        optimizer = c("auto", "BFGS", "L-BFGS-B"), mml_engine = c("direct", "em", "hybrid"), population_formula = NULL, 
        person_data = NULL, person_id = NULL, population_policy = c("error", "omit"), facet_shrinkage = c("none", 
            "empirical_bayes", "laplace"), facet_prior_sd = NULL, slope_prior_sd = NULL, shrink_person = FALSE, attach_diagnostics = FALSE, 
        checkpoint = NULL, gpcm_mml_identification = c("free_population", "fixed_standard_normal", "unconstrained_slopes"), mml_integration = c("fixed", 
            "adaptive", "auto"), category_policy = NULL, em_score_tol = NULL, jml_correction_order = NULL, 
        jml_correction_sampling = c("fixed_rosters", "random_rosters"), gpcm_mml_start = NULL, repeated_ratings = c("review", 
            "independent"), centering_scope = c("facet", "remainder", "anchor_origin"), fit_scope = c("full", 
            "comparisons"), comparison_review = NULL, mml_accuracy_control = NULL, population_sd = NULL, 
        jml_penalty = c("none", "jeffreys"), progress = FALSE, mml_starts = NULL, slope_reference = NULL,
        fast = TRUE, person_score = "auto", xtreme = 0, whexact = FALSE, bias_facets = NULL, warn_connectivity = TRUE)
}

.mfrm_fit_canonical_names <- function() {
    names(.mfrm_fit_canonical_defaults())
}

.mfrm_argument_hint <- function(bad_names) {
    canonical <- setdiff(.mfrm_fit_canonical_names(), "data")
    spec_keys <- .mfrm_fit_spec_keys()
    hints <- character(0)
    for (nm in bad_names) {
        if (!nzchar(nm)) 
            next
        d <- utils::adist(nm, canonical, ignore.case = TRUE)[1L, ]
        best_i <- which.min(d)
        if (length(best_i) == 1L && is.finite(d[best_i]) && d[best_i] <= 3) {
            cand <- canonical[best_i]
            bucket <- if (cand %in% spec_keys) 
                "`spec = list(...)`"
            else "`control = list(...)`"
            hints <- c(hints, sprintf("Did you mean `%s` (in %s)?", cand, bucket))
        }
    }
    if (length(hints)) 
        paste0(" ", paste(unique(hints), collapse = " "))
    else ""
}

.mfrm_validate_spec_list <- function(spec, caller = "fit_mfrm()") {
    if (is.null(spec)) 
        return(list())
    if (!is.list(spec) || is.data.frame(spec)) {
        stop("`spec` in ", caller, " must be NULL or a named list of measurement-model specification settings.", 
            call. = FALSE)
    }
    if (!length(spec)) 
        return(list())
    nm <- names(spec)
    if (is.null(nm) || anyNA(nm) || any(!nzchar(nm)) || anyDuplicated(nm)) {
        stop("`spec` in ", caller, " must have unique non-empty names.", call. = FALSE)
    }
    extra <- setdiff(nm, .mfrm_fit_spec_keys())
    if (length(extra) > 0L) {
        in_ctrl <- intersect(extra, .mfrm_fit_control_keys())
        if (length(in_ctrl) > 0L) {
            stop("`spec` in ", caller, " contains estimation/numerical control entries (", paste(in_ctrl, 
                collapse = ", "), "); pass them in `control = list(...)` instead of `spec`.", call. = FALSE)
        }
        stop("Unsupported or unknown entries in `spec`: ", paste(extra, collapse = ", "), ".", .mfrm_argument_hint(extra), 
            call. = FALSE)
    }
    if (!identical(caller, "fit_mfrm()") && !is.null(spec$step_constraints)) {
        stop(caller, " does not support `step_constraints`. Use fit_mfrm().", call. = FALSE)
    }
    spec
}

.mfrm_validate_control_list <- function(control, caller = "fit_mfrm()") {
    if (is.null(control)) 
        return(list())
    if (!is.list(control) || is.data.frame(control)) {
        stop("`control` in ", caller, " must be a named list of estimation/numerical control settings.", 
            call. = FALSE)
    }
    if (!length(control)) 
        return(list())
    nm <- names(control)
    if (is.null(nm) || anyNA(nm) || any(!nzchar(nm)) || anyDuplicated(nm)) {
        stop("`control` in ", caller, " must have unique non-empty names.", call. = FALSE)
    }
    extra <- setdiff(nm, .mfrm_fit_control_keys())
    if (length(extra) > 0L) {
        in_spec <- intersect(extra, .mfrm_fit_spec_keys())
        if (length(in_spec) > 0L) {
            stop("`control` in ", caller, " contains model/data specification entries (", paste(in_spec, 
                collapse = ", "), "); pass them as top-level arguments or in `spec = list(...)` instead of `control`.", 
                call. = FALSE)
        }
        stop("Unsupported or unknown entries in `control`: ", paste(extra, collapse = ", "), ".", .mfrm_argument_hint(extra), 
            call. = FALSE)
    }
    control
}

fit_mfrm <- function(data, person = NULL, facets = NULL, score = NULL, model = c("RSM", "PCM", "GPCM"), 
    method = c("MML", "JML", "JMLE", "JML_jeffreys", "CML"), step_facet = NULL, slope_facet = NULL, rating_min = NULL, 
    rating_max = NULL, weight = NULL, anchors = NULL, group_anchors = NULL, population_formula = NULL, 
    person_data = NULL, facet_interactions = NULL, step_constraints = NULL, category_support = NULL,
    facet_formulas = NULL, facet_data = NULL, person_score = c("auto", "EAP", "WLE"),
    fast = TRUE, warn_connectivity = TRUE, spec = NULL, control = list(), ...) {
    mc <- match.call(expand.dots = FALSE)
    formal_supplied <- setdiff(names(as.list(mc)[-1L]), c("...", "spec", "control"))
    spec_list <- .mfrm_validate_spec_list(spec, "fit_mfrm()")
    ctrl_list <- .mfrm_validate_control_list(control, "fit_mfrm()")
    core_formal_names <- c("data", "person", "facets", "score", "model", "method", "step_facet", "slope_facet", 
        "rating_min", "rating_max", "weight", "anchors", "group_anchors", "population_formula", "person_data", 
        "facet_interactions", "step_constraints", "category_support", "facet_formulas", "facet_data",
        "person_score", "fast", "warn_connectivity")
    legacy_allowed <- setdiff(.mfrm_fit_canonical_names(), core_formal_names)
    dot_len <- ...length()
    dots <- if (dot_len > 0L) {
        dot_nms <- ...names()
        if (is.null(dot_nms) || length(dot_nms) != dot_len || anyNA(dot_nms) || any(!nzchar(dot_nms))) {
            stop("Unnamed extra arguments in `...` are not supported in `fit_mfrm()`. ", "Supply core arguments by name, or pass advanced settings via `spec = list(...)` or `control = list(...)`.", 
                call. = FALSE)
        }
        if (anyDuplicated(dot_nms)) {
            stop("Duplicate argument(s) in `...`: ", paste(unique(dot_nms[duplicated(dot_nms)]), collapse = ", "), 
                ".", call. = FALSE)
        }
        bad_dots <- setdiff(dot_nms, legacy_allowed)
        if (length(bad_dots) > 0L) {
            stop("Unknown argument(s) in `fit_mfrm()`: ", paste(bad_dots, collapse = ", "), ".", .mfrm_argument_hint(bad_dots), 
                call. = FALSE)
        }
        list(...)
    }
    else {
        list()
    }
    dup_spec_dots <- intersect(names(spec_list), names(dots))
    if (length(dup_spec_dots) > 0L) {
        stop("Duplicate specification in both `spec` and `...`: ", paste(dup_spec_dots, collapse = ", "), 
            ". Specify each setting in one place.", call. = FALSE)
    }
    dup_ctrl_dots <- intersect(names(ctrl_list), names(dots))
    if (length(dup_ctrl_dots) > 0L) {
        stop("Duplicate specification in both `control` and `...`: ", paste(dup_ctrl_dots, collapse = ", "), 
            ". Specify each control setting in one place.", call. = FALSE)
    }
    resolved <- .mfrm_fit_canonical_defaults()
    if (length(spec_list) > 0L) 
        resolved[names(spec_list)] <- spec_list
    if (length(ctrl_list) > 0L) 
        resolved[names(ctrl_list)] <- ctrl_list
    if (length(dots) > 0L) 
        resolved[names(dots)] <- dots
    for (nm in setdiff(formal_supplied, "data")) {
        resolved[nm] <- list(get(nm, envir = environment(), inherits = FALSE))
    }
    person <- resolved$person
    facets <- resolved$facets
    score <- resolved$score
    rating_min <- resolved$rating_min
    rating_max <- resolved$rating_max
    weight <- resolved$weight
    keep_original <- resolved$keep_original
    missing_codes <- resolved$missing_codes
    model <- resolved$model
    method <- resolved$method
    step_facet <- resolved$step_facet
    step_constraints <- resolved$step_constraints
    slope_facet <- resolved$slope_facet
    slope_reference <- resolved$slope_reference
    slope_type <- resolved$slope_type
    facet_interactions <- resolved$facet_interactions
    min_obs_per_interaction <- resolved$min_obs_per_interaction
    interaction_policy <- resolved$interaction_policy
    anchors <- resolved$anchors
    group_anchors <- resolved$group_anchors
    noncenter_facet <- resolved$noncenter_facet
    dummy_facets <- resolved$dummy_facets
    positive_facets <- resolved$positive_facets
    anchor_policy <- resolved$anchor_policy
    min_common_anchors <- resolved$min_common_anchors
    min_obs_per_element <- resolved$min_obs_per_element
    min_obs_per_category <- resolved$min_obs_per_category
    quad_points <- resolved$quad_points
    maxit <- resolved$maxit
    reltol <- resolved$reltol
    optimizer <- resolved$optimizer
    mml_engine <- resolved$mml_engine
    population_formula <- resolved$population_formula
    person_data <- resolved$person_data
    person_id <- resolved$person_id
    population_policy <- resolved$population_policy
    facet_shrinkage <- resolved$facet_shrinkage
    facet_prior_sd <- resolved$facet_prior_sd
    slope_prior_sd <- resolved$slope_prior_sd
    shrink_person <- resolved$shrink_person
    attach_diagnostics <- resolved$attach_diagnostics
    checkpoint <- resolved$checkpoint
    gpcm_mml_identification <- resolved$gpcm_mml_identification[1L]
    mml_integration <- resolved$mml_integration
    category_policy <- resolved$category_policy
    em_score_tol <- resolved$em_score_tol
    jml_correction_order <- resolved$jml_correction_order
    jml_correction_sampling <- resolved$jml_correction_sampling
    gpcm_mml_start <- resolved$gpcm_mml_start
    repeated_ratings <- resolved$repeated_ratings
    centering_scope <- resolved$centering_scope
    fit_scope <- resolved$fit_scope
    comparison_review <- resolved$comparison_review
    mml_accuracy_control <- resolved$mml_accuracy_control
    population_sd <- resolved$population_sd
    jml_penalty <- resolved$jml_penalty
    progress <- resolved$progress
    mml_starts <- resolved$mml_starts
    category_support <- resolved$category_support
    facet_formulas <- resolved$facet_formulas
    facet_data <- resolved$facet_data
    fast <- resolved$fast
    person_score <- resolved$person_score
    xtreme <- resolved$xtreme
    whexact <- resolved$whexact
    bias_facets <- resolved$bias_facets
    warn_connectivity <- resolved$warn_connectivity
    supplied_canonical <- unique(c(formal_supplied, names(spec_list), names(ctrl_list), names(dots)))

    # Canonical unified C++ fast engine by default (`fast = TRUE`); fall back to legacy R path
    # only when `fast = FALSE` or legacy-only internal controls are explicitly supplied
    model_head <- toupper(as.character(model[1L]))
    method_head <- as.character(method[1L])
    method <- method_head
    ps_head <- as.character(person_score[1L])
    needs_legacy_only <- !is.null(mml_accuracy_control) ||
        !is.null(mml_starts) ||
        !is.null(gpcm_mml_start) ||
        !is.null(jml_correction_order) ||
        !is.null(checkpoint) ||
        isTRUE(attach_diagnostics) ||
        isTRUE(shrink_person) ||
        identical(centering_scope[1L], "anchor_origin") ||
        !identical(fit_scope[1L], "full")
    use_cpp_fast <- (isTRUE(fast) && !needs_legacy_only) ||
        identical(method_head, "JML_jeffreys") ||
        !identical(ps_head, "auto") ||
        !is.null(category_support) ||
        !is.null(facet_formulas) ||
        !is.null(bias_facets)
    if (use_cpp_fast) {
        if (!model_head %in% c("RSM", "PCM", "GPCM")) {
            stop("`model` must be one of `'RSM'`, `'PCM'`, or `'GPCM'`.", call. = FALSE)
        }
        if (!is.null(missing_codes) && !isFALSE(missing_codes)) {
            defaults <- isTRUE(missing_codes) || identical(tolower(as.character(missing_codes)), "default")
            data <- recode_missing_codes(data, columns = if (defaults) score else c(person, facets, score),
                codes = if (defaults) c("99", "999", "-1", "N", "NA", "n/a", ".", "") else missing_codes)
        }
        return(fit_mfrm_fast(
            data = data,
            person = person,
            facets = facets,
            score = score,
            model = model_head,
            method = method_head,
            step_facet = step_facet,
            slope_facet = slope_facet,
            slope_reference = slope_reference,
            slope_type = slope_type[1L],
            gpcm_mml_identification = gpcm_mml_identification[1L],
            person_score = ps_head,
            rating_min = rating_min,
            rating_max = rating_max,
            weight = weight,
            anchors = anchors,
            group_anchors = group_anchors,
            dummy_facets = dummy_facets,
            noncenter_facet = noncenter_facet,
            positive_facets = positive_facets,
            centering_scope = if (centering_scope[1L] %in% c("remainder", "facet")) centering_scope[1L] else "remainder",
            population_formula = population_formula,
            person_data = person_data,
            person_id = person_id,
            population_sd = if (is.null(population_sd)) 1.0 else population_sd,
            step_constraints = step_constraints,
            category_support = category_support,
            facet_formulas = facet_formulas,
            facet_data = facet_data,
            facet_interactions = facet_interactions,
            facet_shrinkage = facet_shrinkage[1L],
            facet_prior_sd = facet_prior_sd,
            slope_prior_sd = slope_prior_sd,
            quad_points = quad_points,
            mml_integration = if (mml_integration[1L] == "adaptive") "adaptive" else "fixed",
            xtreme = xtreme,
            jml_penalty = jml_penalty[1L],
            whexact = whexact,
            bias_facets = bias_facets,
            warn_connectivity = warn_connectivity,
            maxit = maxit,
            reltol = reltol
        ))
    }

    # Pre-estimation connectivity check and warning on canonical path
    if (isTRUE(warn_connectivity) && model_head %in% c("RSM", "PCM") &&
        is.data.frame(data) && !is.null(person) && !is.null(facets) && !is.null(score) &&
        is.null(group_anchors) && is.null(population_formula)) {
        conn_chk <- tryCatch(
            check_mfrm_connectivity(
                data = data, person = person, facets = facets, score = score,
                model = model_head, step_facet = step_facet,
                rating_min = rating_min, rating_max = rating_max,
                anchors = anchors, dummy_facets = dummy_facets
            ),
            error = function(e) NULL
        )
        if (!is.null(conn_chk) && !isTRUE(conn_chk$connected)) {
            .mfrm_emit_connectivity_warning(
                list(connected = FALSE, n_subsets = conn_chk$n_subsets, interior_categories_supported = TRUE),
                warn_connectivity = TRUE
            )
        }
    }

    close_progress <- mfrmr_start_fit_progress(progress)
    on.exit(close_progress(), add = TRUE)
    supplied_arguments <- setdiff(supplied_canonical, "progress")
    if (is.null(mml_starts)) 
        supplied_arguments <- setdiff(supplied_arguments, "mml_starts")
    fit_scope <- match.arg(fit_scope, c("full", "comparisons"))
    if (fit_scope == "full" && !is.null(comparison_review)) 
        stop("Use fit_scope = 'comparisons' to fit a comparison review, or extract comparisons from a full fit with interaction_effect_table().", 
            call. = FALSE)
    centering_scope <- match.arg(centering_scope, c("facet", "remainder", "anchor_origin"))
    repeated_ratings <- match.arg(repeated_ratings, c("review", "independent"))
    keep_original <- resolve_mfrm_category_policy(keep_original, category_policy, "keep_original" %in% 
        supplied_canonical, rating_min, rating_max)
    prior_announce_opt <- getOption("mfrmr._rating_range_announced")
    options(mfrmr._rating_range_announced = FALSE)
    on.exit(options(mfrmr._rating_range_announced = prior_announce_opt), add = TRUE)
    prior_prep_message_opt <- getOption("mfrmr._preparation_messages_announced")
    options(mfrmr._preparation_messages_announced = FALSE)
    on.exit(options(mfrmr._preparation_messages_announced = prior_prep_message_opt), add = TRUE)
    prior_score_recode_opt <- getOption("mfrmr._score_recode_announced")
    options(mfrmr._score_recode_announced = FALSE)
    on.exit(options(mfrmr._score_recode_announced = prior_score_recode_opt), add = TRUE)
    prior_duplicate_warning_opt <- getOption("mfrmr._duplicate_warning_announced")
    options(mfrmr._duplicate_warning_announced = FALSE)
    on.exit(options(mfrmr._duplicate_warning_announced = prior_duplicate_warning_opt), add = TRUE)
    if (!is.data.frame(data)) {
        stop("`data` must be a data.frame. Got: ", class(data)[1], ". ", "Convert with as.data.frame() if needed.", 
            call. = FALSE)
    }
    if (nrow(data) == 0) {
        stop("`data` has zero rows. ", "Supply a data.frame with at least one observation.", call. = FALSE)
    }
    if (!is.character(person) || length(person) != 1 || !nzchar(person)) {
        stop("`person` must be a single non-empty character string ", "naming the person column.", call. = FALSE)
    }
    if (!is.character(facets) || length(facets) == 0) {
        stop("`facets` must be a character vector of one or more facet column names.", call. = FALSE)
    }
    if (!is.character(score) || length(score) != 1 || !nzchar(score)) {
        stop("`score` must be a single non-empty character string ", "naming the score column.", call. = FALSE)
    }
    if (!is.null(weight) && (!is.character(weight) || length(weight) != 1)) {
        stop("`weight` must be NULL or a single character string ", "naming the weight column.", call. = FALSE)
    }
    integer_tolerance <- sqrt(.Machine$double.eps)
    if (!is.numeric(maxit) || length(maxit) != 1 || !is.finite(maxit) || maxit < 1 || abs(maxit - round(maxit)) > 
        integer_tolerance) {
        stop("`maxit` must be a finite positive integer. Got: ", deparse(maxit), ".", call. = FALSE)
    }
    if (!is.numeric(reltol) || length(reltol) != 1 || !is.finite(reltol) || reltol <= 0) {
        stop("`reltol` must be a finite positive number. Got: ", deparse(reltol), ".", call. = FALSE)
    }
    if (!is.numeric(quad_points) || length(quad_points) != 1 || !is.finite(quad_points) || quad_points < 
        1 || abs(quad_points - round(quad_points)) > integer_tolerance) {
        stop("`quad_points` must be a finite positive integer. Got: ", deparse(quad_points), ".", call. = FALSE)
    }
    if (!is.logical(attach_diagnostics) || length(attach_diagnostics) != 1L || is.na(attach_diagnostics)) {
        stop("`attach_diagnostics` must be a single logical value (TRUE or FALSE).", call. = FALSE)
    }
    if (!is.null(person_id) && (!is.character(person_id) || length(person_id) != 1 || !nzchar(person_id))) {
        stop("`person_id` must be NULL or a single non-empty character string naming the person column in `person_data`.", 
            call. = FALSE)
    }
    if (!is.null(slope_facet) && (!is.character(slope_facet) || !length(slope_facet) || anyNA(slope_facet) || 
        any(!nzchar(slope_facet)))) {
        stop("`slope_facet` must be NULL or non-empty character strings naming facet columns.", call. = FALSE)
    }
    model <- toupper(match.arg(model, c("RSM", "PCM", "GPCM")))
    method_input <- public_mfrm_method_label(toupper(match.arg(method, c("MML", "JML", "JMLE", "CML"))))
    method <- method_input
    if (identical(centering_scope, "anchor_origin") && (!identical(method, "JML") || !model %in% c("RSM", 
        "PCM") || length(facet_interactions) > 0L || fit_scope != "full")) {
        stop("`centering_scope = 'anchor_origin'` requires ordinary additive RSM/PCM JML with fit_scope = 'full'.", 
            call. = FALSE)
    }
    optimizer <- normalize_mfrm_optimizer(match.arg(optimizer, c("auto", "BFGS", "L-BFGS-B")))
    mml_engine <- tolower(match.arg(mml_engine, c("direct", "em", "hybrid")))
    mml_integration <- match.arg(mml_integration, c("fixed", "adaptive", "auto"))
    if (!is.null(step_constraints) && (!model %in% c("RSM", "PCM") || method != "MML" || mml_engine != 
        "direct" || fit_scope != "full" || !is.null(comparison_review) || length(facet_interactions) || 
        !identical(facet_shrinkage[1L], "none"))) {
        stop("`step_constraints` requires a full, additive, direct RSM/PCM MML fit without interactions or shrinkage.", 
            call. = FALSE)
    }
    jml_penalty <- match.arg(jml_penalty, c("none", "jeffreys"))
    if (!is.null(population_sd)) {
        if (!is.numeric(population_sd) || is.complex(population_sd) || length(population_sd) != 1L || 
            !is.finite(population_sd) || population_sd <= 0 || !is.finite(population_sd^2) || population_sd^2 <= 
            0) 
            stop("`population_sd` must be NULL or one positive finite number with a representable positive variance.", 
                call. = FALSE)
        if (!model %in% c("RSM", "PCM") || method != "MML" || mml_engine != "direct" || is.null(population_formula) || 
            fit_scope != "full" || length(facet_interactions)) 
            stop("`population_sd` requires a population_formula with full direct RSM/PCM MML and no interactions.", 
                call. = FALSE)
        population_sd <- as.numeric(population_sd)
    }
    if (identical(mml_integration, "auto")) {
        product_auto <- identical(model, "GPCM") && length(slope_facet) == 2L && is.null(jml_correction_order) && 
            identical(jml_penalty, "none")
        if (!identical(method, "MML") || !is.null(checkpoint) || fit_scope != "full" || (!product_auto && 
            (!identical(mml_engine, "direct") || length(slope_facet) > 1L)) || (product_auto && !mml_engine %in% 
            c("em", "direct"))) {
            stop("`mml_integration = 'auto'` requires ordinary full MML with the direct engine, or two-family GPCM with the em/direct engine, and no checkpoint.", 
                call. = FALSE)
        }
        mml_accuracy_control <- if (product_auto) 
            mfrmr_gmfrm_accuracy_control(mml_accuracy_control)
        else mfrmr_mml_accuracy_control(mml_accuracy_control)
        if (!is.null(mml_accuracy_control$max_points)) {
            maximum_initial <- if (product_auto) 
                floor((mml_accuracy_control$max_points + 1)/2)
            else mml_accuracy_control$max_points
            if ("quad_points" %in% supplied_arguments && quad_points > maximum_initial) 
                stop("`quad_points` exceeds the initial order allowed by `max_points`, including reference checks.", 
                  call. = FALSE)
            quad_points <- min(quad_points, maximum_initial)
        }
    }
    else if (!is.null(mml_accuracy_control)) {
        stop("`mml_accuracy_control` requires `mml_integration = 'auto'`.", call. = FALSE)
    }
    if (identical(mml_integration, "adaptive") && (!identical(method, "MML") || !identical(mml_engine, 
        "direct") || !is.null(checkpoint))) {
        stop("`mml_integration = 'adaptive'` requires MML with the direct engine and no checkpoint.", 
            call. = FALSE)
    }
    if (!is.null(mml_starts) && (method != "MML" || fit_scope != "full" || length(slope_facet) > 1L || 
        !is.null(jml_correction_order) || jml_penalty != "none" || !is.null(checkpoint) || mml_integration == 
        "auto")) 
        stop("`mml_starts` requires ordinary full MML, fixed/adaptive integration and no checkpoint; two-family GPCM uses gpcm_mml_start.", 
            call. = FALSE)
    gpcm_mml_identification <- match.arg(gpcm_mml_identification, c("free_population", "fixed_standard_normal"))
    interaction_policy <- tolower(match.arg(interaction_policy, c("warn", "error", "silent")))
    anchor_policy <- tolower(match.arg(anchor_policy, c("warn", "error", "silent")))
    population_policy <- tolower(match.arg(population_policy, c("error", "omit")))
    facet_shrinkage <- match.arg(facet_shrinkage, c("none", "empirical_bayes", "laplace"))
    if (jml_penalty != "none") {
        arguments <- mget(.mfrm_fit_canonical_names(), envir = environment(), inherits = FALSE)
        return(mfrm_fit_jeffreys(arguments, supplied_arguments))
    }
    if (!is.null(facet_prior_sd)) {
        if (!is.numeric(facet_prior_sd) || length(facet_prior_sd) != 1L || !is.finite(facet_prior_sd) || 
            facet_prior_sd < 0 || !is.finite(facet_prior_sd^2) || (facet_prior_sd > 0 && facet_prior_sd^2 == 
            0)) {
            stop("`facet_prior_sd` must be NULL or a non-negative finite scalar whose square is representable (positive when the SD is positive).", 
                call. = FALSE)
        }
    }
    if (!is.logical(shrink_person) || length(shrink_person) != 1L || is.na(shrink_person)) {
        stop("`shrink_person` must be a single logical value.", call. = FALSE)
    }
    if (!identical(facet_shrinkage, "none") && isTRUE(shrink_person) && (!identical(method, "JML") || 
        !is.null(jml_correction_order))) {
        stop("`shrink_person = TRUE` requires ordinary JML estimates with sampling SEs. EAP posterior SDs are not sampling SEs. Use shrink_person = FALSE to retain the original Person estimates.", 
            call. = FALSE)
    }
    if (method == "CML" && fit_scope == "full") {
        arguments <- mget(.mfrm_fit_canonical_names(), envir = environment(), inherits = FALSE)
        return(mfrmr_fit_cml(arguments, supplied_arguments))
    }
    if (fit_scope == "comparisons") {
        arguments <- mget(.mfrm_fit_canonical_names(), envir = environment(), inherits = FALSE)
        return(mfrmr_fit_comparisons(arguments, supplied_arguments))
    }
    supplied_arguments <- setdiff(supplied_arguments, c("fit_scope", "comparison_review"))
    if (!is.null(gpcm_mml_start) && !(length(slope_facet) == 2L && identical(model, "GPCM") && identical(method_input, 
        "MML") && identical(mml_engine, "direct") && mml_integration %in% c("adaptive", "auto") && is.null(jml_correction_order))) 
        stop("`gpcm_mml_start` applies only to two-family adaptive direct MML.", call. = FALSE)
    if (!is.null(slope_reference) && (!identical(model, "GPCM") || !identical(method, "MML") || length(slope_facet) != 
        2L)) 
        stop("`slope_reference` applies only to two-family GPCM MML.", call. = FALSE)
    if (!is.null(jml_correction_order)) {
        arguments <- mget(.mfrm_fit_canonical_names(), envir = environment(), inherits = FALSE)
        return(mfrm_fit_adjusted_jml(arguments, supplied_arguments))
    }
    if ("jml_correction_sampling" %in% supplied_canonical) 
        stop("`jml_correction_sampling` requires an explicit `jml_correction_order`.", call. = FALSE)
    if (length(slope_facet) > 1L) {
        arguments <- mget(.mfrm_fit_canonical_names(), envir = environment(), inherits = FALSE)
        if (identical(mml_integration, "auto")) 
            return(mfrm_gpcm_endpoint_limit(mfrm_fit_product_slopes_auto(arguments, supplied_arguments)))
        return(mfrm_gpcm_endpoint_limit(mfrm_fit_product_slopes(arguments, supplied_arguments)))
    }
    if (!is.null(em_score_tol)) {
        stop("`em_score_tol` applies only to the two-family GPCM MML-EM route.", call. = FALSE)
    }
    gpcm_mml_active <- identical(model, "GPCM") && identical(method_input, "MML")
    if (gpcm_mml_active && identical(gpcm_mml_identification, "fixed_standard_normal") && !is.null(population_formula)) {
        stop("`gpcm_mml_identification = \"fixed_standard_normal\"` requires ", "`population_formula = NULL`. Use `\"free_population\"` when estimating ", 
            "a GPCM population model.", call. = FALSE)
    }
    auto_gpcm_population <- gpcm_mml_active && identical(gpcm_mml_identification, "free_population") && 
        is.null(population_formula)
    effective_population_formula <- population_formula
    effective_person_data <- person_data
    effective_person_id <- person_id
    population_scaffold_data <- data
    estimation_person_ids <- as.character(data[[person]])
    if (auto_gpcm_population) {
        auto_in <- prepare_mfrm_auto_gpcm_scaffold_inputs(data, person, missing_codes)
        estimation_person_ids <- auto_in$estimation_person_ids
        population_scaffold_data <- auto_in$scaffold_data
        effective_population_formula <- auto_in$population_formula
        effective_person_data <- auto_in$person_data
        effective_person_id <- auto_in$person_id
    }
    population <- prepare_mfrm_population_scaffold(data = population_scaffold_data, person = person, 
        population_formula = effective_population_formula, person_data = effective_person_data, person_id = effective_person_id, 
        population_policy = population_policy)
    population <- annotate_mfrm_population_scaffold(population = population, data = data, scaffold_data = population_scaffold_data, 
        gpcm_mml_active = gpcm_mml_active, auto_gpcm_population = auto_gpcm_population, population_sd = population_sd)
    if (isTRUE(population$active)) {
        if (!identical(method_input, "MML")) {
            stop("Latent-regression estimation requires `method = 'MML'`. ", "The requested population model is not available with JML.", 
                call. = FALSE)
        }
        if (!identical(as.character(noncenter_facet[1]), "Person")) {
            if (auto_gpcm_population) {
                stop("Default GPCM MML identification estimates an intercept-only ", "population model and therefore requires `noncenter_facet = \"Person\"`. ", 
                  "Use the default centering, or request ", "`gpcm_mml_identification = \"fixed_standard_normal\"` only when ", 
                  "the legacy restricted likelihood is intended.", call. = FALSE)
            }
            if (!model %in% c("RSM", "PCM") || !identical(population$design_columns, "(Intercept)") || 
                any(population$design_matrix != 1) || length(dummy_facets) || length(facet_interactions) || 
                !identical(mml_engine, "direct") || (!is.null(group_anchors) && NROW(group_anchors) > 
                0L)) 
                stop("Latent-regression identification requires `noncenter_facet = \"Person\"`, or an intercept-only direct RSM/PCM population with a direct anchor on the noncentered facet, without interactions, groups or dummy facets.", 
                  call. = FALSE)
            population$identification_role <- if (is.null(population_sd)) 
                "direct_anchor_origin_estimated_population_sd"
            else "direct_anchor_origin_fixed_population_sd"
        }
    }
    estimation_data <- data
    if (isTRUE(population$active) && !auto_gpcm_population && length(population$included_persons) > 0) {
        estimation_mask <- estimation_person_ids %in% population$included_persons
        estimation_data <- data[estimation_mask, , drop = FALSE]
    }
    prep <- prepare_mfrm_data(data = estimation_data, person_col = person, facet_cols = facets, score_col = score, 
        rating_min = rating_min, rating_max = rating_max, weight_col = weight, keep_original = keep_original, 
        missing_codes = missing_codes, repeated_ratings = repeated_ratings, allow_single_person = TRUE)
    anchor_bundle <- review_mfrm_prepared_anchors(prep = prep, anchors = anchors, group_anchors = group_anchors, 
        min_common_anchors = min_common_anchors, min_obs_per_element = min_obs_per_element, min_obs_per_category = min_obs_per_category, 
        noncenter_facet = noncenter_facet, dummy_facets = dummy_facets, centering_scope = centering_scope)
    anchor_review <- anchor_bundle$anchor_review
    enforce_mfrm_anchor_review_policy(anchor_review, anchor_policy)
    anchors <- anchor_review$anchors
    group_anchors <- anchor_review$group_anchors
    fit <- mfrm_estimate(data = estimation_data, person_col = person, facet_cols = facets, score_col = score, 
        rating_min = rating_min, rating_max = rating_max, weight_col = weight, keep_original = keep_original, 
        missing_codes = missing_codes, model = model, method = method, step_facet = step_facet, slope_facet = slope_facet, 
        facet_interactions = facet_interactions, min_obs_per_interaction = min_obs_per_interaction, interaction_policy = interaction_policy, 
        anchor_df = anchors, group_anchor_df = group_anchors, noncenter_facet = noncenter_facet, dummy_facets = dummy_facets, 
        positive_facets = positive_facets, population = population, quad_points = quad_points, maxit = maxit, 
        reltol = reltol, optimizer = optimizer, mml_engine = mml_engine, mml_integration = mml_integration, 
        mml_accuracy_control = mml_accuracy_control, mml_starts = mml_starts, checkpoint = checkpoint, 
        repeated_ratings = repeated_ratings, centering_scope = centering_scope, prep = prep, anchor_review = anchor_review, 
        constraint_specs = anchor_bundle$constraint_specs, step_constraints = step_constraints)
    fit$config$anchor_review <- anchor_review
    fit$config$method_input <- method_input
    fit$population <- finalize_mfrm_population_fit(fit, population)
    fit$config$population_spec <- compact_population_spec(fit$population, fit$prep$levels$Person)
    fit$config$population_active <- isTRUE(population$active)
    fit$config$posterior_basis <- as.character(fit$population$posterior_basis %||% "legacy_mml")
    fit$config$population_policy <- fit$population$policy %||% NULL
    fit$config$gpcm_mml_identification_requested <- as.character(gpcm_mml_identification)
    fit$config$gpcm_mml_identification <- if (gpcm_mml_active) {
        as.character(gpcm_mml_identification)
    }
    else if (identical(model, "GPCM") && identical(method_input, "JML")) {
        "not_applicable_jml"
    }
    else {
        "not_applicable"
    }
    fit$config$gpcm_common_discrimination <- if (gpcm_mml_active && identical(gpcm_mml_identification, 
        "free_population")) {
        "estimated_via_population_sd"
    }
    else if (gpcm_mml_active) {
        "fixed_to_one_legacy_restriction"
    }
    else {
        "not_applicable"
    }
    fit$config$gpcm_estimator_family <- if (!identical(model, "GPCM")) {
        "not_applicable"
    }
    else if (identical(method_input, "JML")) {
        "unpenalized_identified_jml"
    }
    else {
        "marginal_maximum_likelihood"
    }
    gpcm_identity <- mfrmr_gpcm_model_identity(model)
    fit$config$gpcm_model_family <- gpcm_identity$model_family
    fit$config$gpcm_slope_action <- gpcm_identity$slope_action
    fit$config$gpcm_slope_composition <- gpcm_identity$slope_composition
    fit$config$gpcm_latent_dimension_count <- gpcm_identity$latent_dimension_count
    fit$config$gpcm_statistical_penalty <- if (identical(model, "GPCM")) {
        "none"
    }
    else {
        "not_applicable"
    }
    fit$config$gpcm_finite_parameter_box <- if (identical(model, "GPCM")) {
        FALSE
    }
    else {
        NA
    }
    fit$config$gpcm_extreme_person_policy <- if (!identical(model, "GPCM")) {
        "not_applicable"
    }
    else if (identical(method_input, "JML")) {
        "extended_real_primary_when_certified"
    }
    else {
        "posterior_eap_under_population_model"
    }
    fit$config$population_formula <- if (!is.null(fit$population$formula)) {
        paste(deparse(fit$population$formula), collapse = " ")
    }
    else {
        NULL
    }
    if (identical(model, "GPCM") && identical(method_input, "MML") && nrow(fit$slopes %||% data.frame()) > 
        0L) {
        fitted_population_sd <- if (isTRUE(fit$population$active)) {
            sqrt(as.numeric(fit$population$sigma2 %||% NA_real_)[1])
        }
        else {
            1
        }
        optimizer_relative <- as.numeric(fit$slopes$OptimizerEstimate %||% fit$slopes$Estimate)
        primary_relative <- as.numeric(fit$slopes$PrimaryEstimate %||% rep(NA_real_, nrow(fit$slopes)))
        fit$slopes$PopulationSD <- rep(fitted_population_sd, nrow(fit$slopes))
        fit$slopes$FixedLatentSDOptimizerEstimate <- fitted_population_sd * optimizer_relative
        fit$slopes$FixedLatentSDPrimaryEstimate <- fitted_population_sd * primary_relative
        fit$slopes$FixedLatentSDBasis <- if (isTRUE(fit$population$active)) {
            "population_sd_times_relative_slope"
        }
        else {
            "legacy_unit_population_sd_times_relative_slope"
        }
    }
    class(fit) <- c("mfrm_fit", class(fit))
    if (!identical(facet_shrinkage, "none")) {
        fit <- .apply_shrinkage_to_fit(fit = fit, method = facet_shrinkage, facet_prior_sd = facet_prior_sd, 
            shrink_person = isTRUE(shrink_person))
    }
    else {
        fit$config$facet_shrinkage <- "none"
        fit$config$facet_prior_sd <- NULL
    }
    fit$config$replay_inputs <- list(person = as.character(person), facets = as.character(facets), score = as.character(score), 
        weight = if (is.null(weight)) NULL else as.character(weight), rating_min = rating_min, rating_max = rating_max, 
        keep_original = isTRUE(keep_original), missing_codes = missing_codes, model = as.character(model), 
        method = as.character(method_input), step_facet = if (is.null(step_facet)) NULL else as.character(step_facet), 
        slope_facet = if (is.null(slope_facet)) NULL else as.character(slope_facet), gpcm_mml_identification = as.character(gpcm_mml_identification), 
        facet_interactions = facet_interactions, min_obs_per_interaction = as.numeric(min_obs_per_interaction), 
        interaction_policy = as.character(interaction_policy), anchors = anchors, group_anchors = group_anchors, 
        noncenter_facet = as.character(noncenter_facet), centering_scope = centering_scope, dummy_facets = if (length(dummy_facets) > 
            0L) as.character(dummy_facets) else NULL, positive_facets = if (length(positive_facets) > 
            0L) as.character(positive_facets) else NULL, anchor_policy = as.character(anchor_policy), 
        min_common_anchors = as.integer(min_common_anchors), min_obs_per_element = as.numeric(min_obs_per_element), 
        min_obs_per_category = as.numeric(min_obs_per_category), quad_points = as.integer(quad_points), 
        maxit = as.integer(maxit), reltol = as.numeric(reltol), optimizer = as.character(optimizer), 
        mml_engine = as.character(mml_engine), mml_integration = mml_integration, mml_accuracy_control = mml_accuracy_control, 
        population_formula = population_formula, population_sd = population_sd, person_id = if (is.null(person_id)) NULL else as.character(person_id), 
        population_policy = as.character(population_policy), facet_shrinkage = as.character(facet_shrinkage), 
        facet_prior_sd = facet_prior_sd, shrink_person = isTRUE(shrink_person), attach_diagnostics = isTRUE(attach_diagnostics), 
        repeated_ratings = repeated_ratings, package_version = as.character(utils::packageVersion("mfrmr")))
    if (!is.null(mml_starts)) 
        fit$config$replay_inputs$mml_starts <- mml_starts
    if (!is.null(step_constraints)) 
        fit$config$replay_inputs$step_constraints <- step_constraints
    fit <- mfrm_gpcm_endpoint_limit(fit)
    if (isTRUE(attach_diagnostics)) {
        fit <- attach_diagnostics_to_fit(fit)
    }
    else {
        fit$config$attached_diagnostics <- FALSE
    }
    fit
}

interaction_effect_table <- function(fit, comparison_review = NULL) {
    if (inherits(fit, "mfrm_comparison_fit")) {
        if (!is.null(comparison_review)) 
            stop("A comparison fit retains its declared targets; omit comparison_review when extracting it.", 
                call. = FALSE)
        return(fit$comparisons)
    }
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an mfrm_fit object returned by fit_mfrm().", call. = FALSE)
    }
    if (!is.null(comparison_review)) {
        return(mfrmr_fitted_comparison_table(fit, comparison_review))
    }
    tbl <- fit$interactions$effects
    if (is.null(tbl)) {
        return(tibble::tibble())
    }
    tibble::as_tibble(tbl)
}

attach_diagnostics_to_fit <- function(fit) {
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an mfrm_fit.", call. = FALSE)
    }
    others <- fit$facets$others
    person <- fit$facets$person
    if ((is.null(others) || nrow(others) == 0L) && (is.null(person) || nrow(person) == 0L)) {
        fit$config$attached_diagnostics <- TRUE
        return(fit)
    }
    diag <- tryCatch(suppressMessages(suppressWarnings(diagnose_mfrm(fit, residual_pca = "none"))), error = function(e) NULL)
    if (is.null(diag) || is.null(diag$measures)) {
        fit$config$attached_diagnostics <- FALSE
        fit$config$attached_diagnostics_note <- "diagnose_mfrm() did not return a measures table; attach skipped."
        return(fit)
    }
    structural_uncertainty <- diag$parameter_uncertainty %||% list()
    m <- as.data.frame(diag$measures, stringsAsFactors = FALSE)
    merge_cols <- intersect(c("ModelSE", "Infit", "Outfit", "InfitZSTD", "OutfitZSTD", "PTMEA", "PtMeaCorr", 
        "InferenceReady", "SupportsFormalInference", "SEUse", "CIEligible", "CIUse", "CIBasis", "CILabel"), 
        names(m))
    if (length(merge_cols) == 0L) {
        fit$config$attached_diagnostics <- FALSE
        return(fit)
    }
    keep <- c("Facet", "Level", merge_cols)
    m <- m[, keep, drop = FALSE]
    m$Facet <- as.character(m$Facet)
    m$Level <- as.character(m$Level)
    if ("ModelSE" %in% names(m)) {
        names(m)[names(m) == "ModelSE"] <- "SE"
    }
    if ("PTMEA" %in% names(m)) {
        names(m)[names(m) == "PTMEA"] <- "PtMeaCorr"
    }
    attached_cols <- setdiff(names(m), c("Facet", "Level"))
    if (!is.null(others) && nrow(others) > 0L) {
        others$Facet <- as.character(others$Facet)
        others$Level <- as.character(others$Level)
        others_m <- m[m$Facet != "Person", , drop = FALSE]
        others[, intersect(attached_cols, names(others))] <- NULL
        others <- merge(others, others_m, by = c("Facet", "Level"), all.x = TRUE, sort = FALSE)
        fit$facets$others <- others
    }
    if (!is.null(person) && nrow(person) > 0L) {
        person_df <- as.data.frame(person, stringsAsFactors = FALSE)
        person_df$Person <- as.character(person_df$Person)
        person_m <- m[m$Facet == "Person", , drop = FALSE]
        if (nrow(person_m) > 0L) {
            person_m$Person <- as.character(person_m$Level)
            person_m <- person_m[, c("Person", attached_cols), drop = FALSE]
            person_attach_cols <- attached_cols
            if ("SE" %in% person_attach_cols && "SE" %in% names(person_df) && any(is.finite(suppressWarnings(as.numeric(person_df$SE))))) {
                person_attach_cols <- setdiff(person_attach_cols, "SE")
                person_m$SE <- NULL
            }
            person_df[, intersect(person_attach_cols, names(person_df))] <- NULL
            person_df <- merge(person_df, person_m, by = "Person", all.x = TRUE, sort = FALSE)
            fit$facets$person <- tibble::as_tibble(person_df)
        }
    }
    step_unc <- as.data.frame(structural_uncertainty$steps %||% data.frame(), stringsAsFactors = FALSE)
    if (!is.null(fit$steps) && nrow(fit$steps) > 0L && nrow(step_unc) > 0L) {
        step_keys <- intersect(c("StepFacet", "Step"), names(fit$steps))
        if (!"StepFacet" %in% names(fit$steps) && "Step" %in% names(fit$steps)) {
            step_keys <- "Step"
        }
        if (length(step_keys) > 0L && all(step_keys %in% names(step_unc))) {
            attach_step_cols <- setdiff(names(step_unc), c(step_keys, "Estimate"))
            if (length(attach_step_cols) > 0L) {
                step_df <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
                step_df[, intersect(attach_step_cols, names(step_df))] <- NULL
                fit$steps <- merge(step_df, step_unc[, c(step_keys, attach_step_cols), drop = FALSE], 
                  by = step_keys, all.x = TRUE, sort = FALSE)
            }
        }
    }
    slope_unc <- as.data.frame(structural_uncertainty$slopes %||% data.frame(), stringsAsFactors = FALSE)
    if (!is.null(fit$slopes) && nrow(fit$slopes) > 0L && nrow(slope_unc) > 0L && "SlopeFacet" %in% names(fit$slopes) && 
        "SlopeFacet" %in% names(slope_unc)) {
        attach_slope_cols <- setdiff(names(slope_unc), c("SlopeFacet", "LogEstimate", "Estimate"))
        if (length(attach_slope_cols) > 0L) {
            slope_df <- as.data.frame(fit$slopes, stringsAsFactors = FALSE)
            slope_df[, intersect(attach_slope_cols, names(slope_df))] <- NULL
            fit$slopes <- merge(slope_df, slope_unc[, c("SlopeFacet", attach_slope_cols), drop = FALSE], 
                by = "SlopeFacet", all.x = TRUE, sort = FALSE)
        }
    }
    if (!is.null(fit$readiness$parameters)) {
        fit$readiness$parameters <- mfrm_update_slope_readiness_parameters(fit$readiness$parameters, 
            slope_unc)
    }
    fit$config$attached_diagnostics <- TRUE
    fit$config$attached_diagnostics_cols <- attached_cols
    fit
}

finalize_mfrm_population_fit <- function(fit, population) {
    pop <- population %||% list()
    if (!isTRUE(pop$active)) {
        return(pop)
    }
    sizes <- build_param_sizes(fit$config)
    params <- expand_params(fit$opt$par, sizes, fit$config)
    coeff <- as.numeric(params$population$coefficients %||% numeric(0))
    coeff_names <- names(params$population$coefficients %||% NULL)
    if (!is.null(coeff_names) && length(coeff_names) == length(coeff)) {
        names(coeff) <- coeff_names
    }
    notes <- as.character(pop$notes %||% character(0))
    notes <- c(notes, "Latent-regression parameters were estimated under the MML population-model branch.")
    pop$coefficients <- coeff
    pop$sigma2 <- as.numeric(params$population$sigma2[1] %||% NA_real_)
    convergence <- mfrm_convergence_state(fit)
    pop$estimation_converged <- isTRUE(convergence$code_converged)
    pop$inference_ready <- isTRUE(convergence$inference_ready)
    pop$converged <- pop$inference_ready
    pop$converged_basis <- "legacy_alias_of_inference_ready"
    pop$logLik_component <- as.numeric(fit$summary$LogLik[1] %||% NA_real_)
    pop$posterior_basis <- "population_model"
    pop$design_columns <- pop$design_columns %||% names(coeff)
    pop$notes <- unique(notes)
    pop
}

prepare_mfrm_population_scaffold <- function(data, person, population_formula = NULL, person_data = NULL, 
    person_id = NULL, population_policy = c("error", "omit"), population_xlevels = NULL, population_contrasts = NULL, 
    require_full_rank = TRUE, population_terms = NULL) {
    if (is.null(population_formula)) {
        return(list(active = FALSE, formula = NULL, person_id = if (is.null(person_id)) person else person_id, 
            person_table = NULL, person_table_replay = NULL, person_table_replay_scope = NULL, design_matrix = NULL, 
            design_columns = NULL, xlevels = NULL, contrasts = NULL, coefficients = NULL, sigma2 = NULL, 
            converged = FALSE, posterior_basis = "legacy_mml", policy = NULL, included_persons = character(0), 
            omitted_persons = character(0), response_rows_retained = nrow(data), response_rows_omitted = 0L, 
            notes = "No population model was requested; this fit uses an unconditional normal person distribution."))
    }
    population_policy <- match.arg(population_policy)
    if (inherits(population_formula, "terms")) {
        population_contrasts <- population_contrasts %||% attr(population_formula, "mfrm_population_contrasts", 
            exact = TRUE)
        population_xlevels <- population_xlevels %||% attr(population_formula, "mfrm_population_xlevels", 
            exact = TRUE)
    }
    population_formula <- tryCatch(stats::as.formula(population_formula), error = function(e) {
        stop("`population_formula` must be coercible to a one-sided formula such as `~ grade + ses`. ", 
            "Original error: ", conditionMessage(e), call. = FALSE)
    })
    if (length(population_formula) != 2L) {
        stop("`population_formula` must be a one-sided formula such as `~ grade + ses`.", call. = FALSE)
    }
    if (!is.data.frame(person_data)) {
        stop("`person_data` must be a data.frame with one row per person when `population_formula` is supplied.", 
            call. = FALSE)
    }
    if (is.null(person_id)) {
        if (!person %in% names(person_data)) {
            stop("`person_data` must contain the person column `", person, "` or you must supply `person_id` explicitly when `population_formula` is used.", 
                call. = FALSE)
        }
        person_id <- person
    }
    if (!person_id %in% names(person_data)) {
        stop("`person_id = '", person_id, "'` is not a column in `person_data`.", call. = FALSE)
    }
    observed_persons <- unique(as.character(data[[person]]))
    person_tbl <- as.data.frame(person_data, stringsAsFactors = FALSE)
    person_tbl[[person_id]] <- as.character(person_tbl[[person_id]])
    if (anyNA(person_tbl[[person_id]]) || any(!nzchar(person_tbl[[person_id]]))) {
        stop("`person_data` contains missing or empty person IDs in column `", person_id, "`.", call. = FALSE)
    }
    dup_ids <- unique(person_tbl[[person_id]][duplicated(person_tbl[[person_id]])])
    if (length(dup_ids) > 0) {
        preview <- paste(utils::head(dup_ids, 5), collapse = ", ")
        stop("`person_data` must contain one unique row per person. Duplicate IDs detected in `", person_id, 
            "`: ", preview, if (length(dup_ids) > 5) 
                ", ..."
            else ".", call. = FALSE)
    }
    missing_persons <- setdiff(observed_persons, person_tbl[[person_id]])
    if (length(missing_persons) > 0) {
        preview <- paste(utils::head(missing_persons, 5), collapse = ", ")
        stop("`person_data` is missing ", length(missing_persons), " person(s) observed in `data`: ", 
            preview, if (length(missing_persons) > 5) 
                ", ..."
            else ".", call. = FALSE)
    }
    keep_idx <- match(observed_persons, person_tbl[[person_id]])
    person_tbl <- person_tbl[keep_idx, , drop = FALSE]
    rownames(person_tbl) <- NULL
    person_tbl_replay <- person_tbl
    model_frame_args <- list(formula = population_terms %||% population_formula, data = person_tbl, na.action = stats::na.pass)
    if (!is.null(population_xlevels)) {
        model_frame_args$xlev <- population_xlevels
    }
    mf <- tryCatch(do.call(stats::model.frame, model_frame_args), error = function(e) {
        stop("Could not build the latent-regression model frame from `person_data`. ", "Original error: ", 
            conditionMessage(e), call. = FALSE)
    })
    mf_names <- names(mf)
    if (length(mf_names) > 0) {
        unsupported <- mf_names[vapply(mf[mf_names], function(x) is.list(x) || is.data.frame(x), logical(1))]
        if (length(unsupported) > 0) {
            stop("Variables referenced in `population_formula` must be atomic columns usable by stats::model.matrix(). ", 
                "Numeric, logical, factor, ordered factor, and character predictors are supported; unsupported columns: ", 
                paste(unsupported, collapse = ", "), ".", call. = FALSE)
        }
    }
    complete_mask <- if (ncol(mf) == 0) 
        rep(TRUE, nrow(person_tbl))
    else stats::complete.cases(mf)
    omitted_persons <- person_tbl[[person_id]][!complete_mask]
    if (length(omitted_persons) > 0 && identical(population_policy, "error")) {
        preview <- paste(utils::head(omitted_persons, 5), collapse = ", ")
        stop("`person_data` contains missing covariate values for persons referenced by `population_formula`. ", 
            "Use `population_policy = 'omit'` to fit the complete-case analysis set instead. Affected IDs: ", 
            preview, if (length(omitted_persons) > 5) 
                ", ..."
            else ".", call. = FALSE)
    }
    if (length(omitted_persons) > 0) {
        person_tbl <- person_tbl[complete_mask, , drop = FALSE]
        mf <- mf[complete_mask, , drop = FALSE]
        rownames(person_tbl) <- NULL
        rownames(mf) <- NULL
    }
    if (nrow(person_tbl) == 0) {
        stop("No persons remain in `person_data` after applying the latent-regression covariate policy.", 
            call. = FALSE)
    }
    included_persons <- as.character(person_tbl[[person_id]])
    response_keep <- as.character(data[[person]]) %in% included_persons
    response_rows_retained <- sum(response_keep)
    response_rows_omitted <- sum(!response_keep)
    terms_obj <- attr(mf, "terms") %||% stats::terms(population_formula)
    mm <- tryCatch(stats::model.matrix(terms_obj, data = mf, contrasts.arg = population_contrasts), error = function(e) {
        stop("Could not build the latent-regression design matrix from `person_data`. ", "Original error: ", 
            conditionMessage(e), call. = FALSE)
    })
    xlevels <- tryCatch(stats::.getXlevels(terms_obj, mf), error = function(e) NULL)
    mm_contrasts <- attr(mm, "contrasts", exact = TRUE)
    qr_mm <- qr(mm)
    if (isTRUE(require_full_rank) && qr_mm$rank < ncol(mm)) {
        stop("The latent-regression design matrix is rank-deficient. ", "Adjust `population_formula` or the coding of `person_data` before fitting.", 
            call. = FALSE)
    }
    mm_rcond <- tryCatch(suppressWarnings(rcond(mm)), error = function(e) NA_real_)
    if (isTRUE(require_full_rank) && is.finite(mm_rcond) && mm_rcond < 1e-08) {
        warning(sprintf(paste0("Latent-regression design matrix is near-singular (rcond = %.1e). ", "Estimated coefficients may be unstable; consider dropping ", 
            "redundant covariates or rescaling `person_data`."), mm_rcond), call. = FALSE)
    }
    notes <- c("Latent-regression covariates are active.", "Person-level covariates and their design matrix were prepared for MML estimation.")
    if (length(omitted_persons) > 0) {
        notes <- c(notes, paste0("Complete-case preparation retained ", nrow(person_tbl), " person(s) and omitted ", 
            length(omitted_persons), " person(s) under `population_policy = 'omit'`."))
    }
    if (response_rows_omitted > 0) {
        notes <- c(notes, paste0("For latent-regression estimation, ", response_rows_omitted, " response row(s) would be excluded because their persons lack complete background data."))
    }
    list(active = TRUE, formula = population_formula, terms = terms_obj, person_id = person_id, person_table = person_tbl, 
        person_table_replay = person_tbl_replay, person_table_replay_scope = "observed_person_subset_pre_omit", 
        design_matrix = mm, design_columns = colnames(mm), xlevels = xlevels, contrasts = mm_contrasts, 
        coefficients = NULL, sigma2 = NULL, converged = FALSE, posterior_basis = "population_model", 
        policy = population_policy, included_persons = included_persons, omitted_persons = as.character(omitted_persons), 
        response_rows_retained = as.integer(response_rows_retained), response_rows_omitted = as.integer(response_rows_omitted), 
        notes = notes)
}

format_anchor_review_message <- function(anchor_review) {
    if (is.null(anchor_review$issue_counts) || nrow(anchor_review$issue_counts) == 0) {
        return("Anchor review detected no issues.")
    }
    nonzero <- dplyr::filter(anchor_review$issue_counts, .data$N > 0)
    if (nrow(nonzero) == 0) {
        return("Anchor review detected no issues.")
    }
    labels <- paste0(nonzero$Issue, "=", nonzero$N)
    paste0("Anchor review detected ", sum(nonzero$N), " issue row(s): ", paste(labels, collapse = "; "), 
        ". Invalid rows, if any, were removed; duplicate keys keep the last row.", if (any(nonzero$Issue == 
            "overlap_anchor_group")) 
            " Overlapping direct and group anchors retain both constraints."
        else "")
}

normalize_expected_mfrm_design <- function(expected_design, person, facets) {
    if (is.null(expected_design)) 
        return(NULL)
    if (!is.data.frame(expected_design)) {
        stop("`expected_design` must be a data.frame.", call. = FALSE)
    }
    required <- c(person, facets)
    missing_cols <- setdiff(required, names(expected_design))
    if (length(missing_cols) > 0L) {
        stop("`expected_design` is missing required column(s): ", paste(missing_cols, collapse = ", "), 
            ".", call. = FALSE)
    }
    if (nrow(expected_design) == 0L) {
        stop("`expected_design` must contain at least one planned rating cell.", call. = FALSE)
    }
    out <- as.data.frame(expected_design[, required, drop = FALSE], stringsAsFactors = FALSE)
    names(out)[1L] <- "Person"
    out[] <- lapply(out, function(x) trimws(as.character(x)))
    invalid <- vapply(out, function(x) any(is.na(x) | !nzchar(x)), logical(1))
    if (any(invalid)) {
        stop("`expected_design` contains missing or blank IDs in: ", paste(names(out)[invalid], collapse = ", "), 
            ".", call. = FALSE)
    }
    duplicate_rows <- duplicated(out) | duplicated(out, fromLast = TRUE)
    if (any(duplicate_rows)) {
        stop("`expected_design` must contain one row per planned Person x ", paste(facets, collapse = " x "), 
            " cell; duplicate planned cells were found.", call. = FALSE)
    }
    out
}

audit_mfrm_expected_design <- function(df, expected_design, facets) {
    key_cols <- c("Person", facets)
    observed <- unique(as.data.frame(df[, key_cols, drop = FALSE], stringsAsFactors = FALSE))
    empty_cells <- observed[0, , drop = FALSE]
    if (is.null(expected_design)) {
        level_coverage <- purrr::map_dfr(facets, function(facet) {
            tibble::tibble(Facet = facet, ExpectedLevels = NA_integer_, ObservedLevels = dplyr::n_distinct(observed[[facet]]), 
                ExpectedOnlyLevels = NA_integer_, UnexpectedLevels = NA_integer_)
        })
        return(list(summary = data.frame(Status = "not_declared", ExpectedCells = NA_integer_, ObservedCells = nrow(observed), 
            MatchedCells = NA_integer_, MissingExpectedCells = NA_integer_, UnexpectedObservedCells = NA_integer_, 
            CoverageRate = NA_real_, ExpectedOnlyPersons = NA_integer_, UnexpectedPersons = NA_integer_, 
            stringsAsFactors = FALSE), missing_expected_cells = empty_cells, unexpected_observed_cells = empty_cells, 
            level_coverage = as.data.frame(level_coverage, stringsAsFactors = FALSE), settings = list(declared = FALSE, 
                key = key_cols, note = paste0("Structural missingness was not assessed because `expected_design` was not supplied. ", 
                  "Absent rows cannot be distinguished from cells that were never assigned."))))
    }
    matched <- dplyr::semi_join(expected_design, observed, by = key_cols)
    missing_expected <- dplyr::anti_join(expected_design, observed, by = key_cols)
    unexpected_observed <- dplyr::anti_join(observed, expected_design, by = key_cols)
    level_coverage <- purrr::map_dfr(facets, function(facet) {
        expected_levels <- unique(expected_design[[facet]])
        observed_levels <- unique(observed[[facet]])
        tibble::tibble(Facet = facet, ExpectedLevels = length(expected_levels), ObservedLevels = length(observed_levels), 
            ExpectedOnlyLevels = length(setdiff(expected_levels, observed_levels)), UnexpectedLevels = length(setdiff(observed_levels, 
                expected_levels)))
    })
    list(summary = data.frame(Status = "declared", ExpectedCells = nrow(expected_design), ObservedCells = nrow(observed), 
        MatchedCells = nrow(matched), MissingExpectedCells = nrow(missing_expected), UnexpectedObservedCells = nrow(unexpected_observed), 
        CoverageRate = nrow(matched)/nrow(expected_design), ExpectedOnlyPersons = length(setdiff(expected_design$Person, 
            observed$Person)), UnexpectedPersons = length(setdiff(observed$Person, expected_design$Person)), 
        stringsAsFactors = FALSE), missing_expected_cells = as.data.frame(missing_expected, stringsAsFactors = FALSE), 
        unexpected_observed_cells = as.data.frame(unexpected_observed, stringsAsFactors = FALSE), level_coverage = as.data.frame(level_coverage, 
            stringsAsFactors = FALSE), settings = list(declared = TRUE, key = key_cols, note = "Observed unique cells were compared with the explicitly declared assignment roster."))
}

summarize_duplicate_mfrm_cells <- function(df, facets) {
    key_cols <- c("Person", facets)
    detail <- as.data.frame(dplyr::arrange(dplyr::filter(dplyr::summarise(dplyr::group_by(df, dplyr::across(dplyr::all_of(key_cols))), 
        Observations = dplyr::n(), WeightedN = sum(.data$Weight, na.rm = TRUE), .groups = "drop"), .data$Observations > 
        1L), dplyr::desc(.data$Observations)), stringsAsFactors = FALSE)
    list(summary = data.frame(DuplicateCells = nrow(detail), RowsInDuplicateCells = if (nrow(detail) > 
        0L) sum(detail$Observations) else 0L, ExtraRows = if (nrow(detail) > 0L) sum(detail$Observations - 
        1L) else 0L, HasDuplicates = nrow(detail) > 0L, stringsAsFactors = FALSE), detail = detail)
}

mfrm_bipartite_components <- function(cells, facet, basis, include_persons = FALSE) {
    edges <- unique(as.data.frame(cells[, c("Person", facet), drop = FALSE], stringsAsFactors = FALSE))
    edges$Person <- as.character(edges$Person)
    edges[[facet]] <- as.character(edges[[facet]])
    persons_to_levels <- split(edges[[facet]], edges$Person)
    levels_to_persons <- split(edges$Person, edges[[facet]])
    unseen <- unique(edges$Person)
    components <- list()
    while (length(unseen) > 0L) {
        component_persons <- unseen[1L]
        component_levels <- character(0)
        repeat {
            next_levels <- unique(unname(unlist(persons_to_levels[component_persons], use.names = FALSE)))
            next_persons <- unique(unname(unlist(levels_to_persons[next_levels], use.names = FALSE)))
            expanded_persons <- union(component_persons, next_persons)
            expanded_levels <- union(component_levels, next_levels)
            if (setequal(expanded_persons, component_persons) && setequal(expanded_levels, component_levels)) 
                break
            component_persons <- expanded_persons
            component_levels <- expanded_levels
        }
        component_edges <- sum(edges$Person %in% component_persons & edges[[facet]] %in% component_levels)
        components[[length(components) + 1L]] <- data.frame(Basis = basis, Facet = facet, Component = length(components) + 
            1L, Persons = length(component_persons), FacetLevels = length(component_levels), Edges = component_edges, 
            LevelLabels = paste(sort(component_levels), collapse = ", "), PersonLabels = if (isTRUE(include_persons)) {
                paste(sort(component_persons), collapse = ", ")
            }
            else {
                ""
            }, stringsAsFactors = FALSE)
        unseen <- setdiff(unseen, component_persons)
    }
    component_table <- do.call(rbind, components)
    largest_index <- which.max(component_table$Persons)
    summary <- data.frame(Basis = basis, Facet = facet, PersonNodes = length(unique(edges$Person)), FacetLevelNodes = length(unique(edges[[facet]])), 
        Edges = nrow(edges), Components = nrow(component_table), LargestComponentPersons = component_table$Persons[largest_index], 
        LargestComponentLevels = component_table$FacetLevels[largest_index], LargestComponentPercent = 100 * 
            component_table$Persons[largest_index]/length(unique(edges$Person)), Connected = nrow(component_table) == 
            1L, stringsAsFactors = FALSE)
    list(summary = summary, components = component_table)
}

audit_mfrm_connectivity <- function(df, expected_design, facets, include_persons = FALSE) {
    bases <- list(observed = df)
    if (!is.null(expected_design)) 
        bases$declared_expected <- expected_design
    audits <- unlist(lapply(names(bases), function(basis) {
        lapply(facets, function(facet) {
            mfrm_bipartite_components(bases[[basis]], facet, basis, include_persons = include_persons)
        })
    }), recursive = FALSE)
    list(summary = do.call(rbind, lapply(audits, `[[`, "summary")), components = do.call(rbind, lapply(audits, 
        `[[`, "components")))
}

summarize_linkage_by_facet <- function(df, facet, min_linking_persons = 2L) {
    by_level <- dplyr::summarize(dplyr::group_by(df, .data[[facet]]), PersonsPerLevel = dplyr::n_distinct(.data$Person), 
        Observations = dplyr::n(), WeightedN = sum(.data$Weight, na.rm = TRUE), .groups = "drop")
    by_person <- dplyr::summarize(dplyr::group_by(df, .data$Person), LevelsPerPerson = dplyr::n_distinct(.data[[facet]]), 
        .groups = "drop")
    tibble::tibble(Facet = facet, Levels = nrow(by_level), Persons = nrow(by_person), MinPersonsPerLevel = min(by_level$PersonsPerLevel, 
        na.rm = TRUE), MedianPersonsPerLevel = stats::median(by_level$PersonsPerLevel, na.rm = TRUE), 
        MinLevelsPerPerson = min(by_person$LevelsPerPerson, na.rm = TRUE), MedianLevelsPerPerson = stats::median(by_person$LevelsPerPerson, 
            na.rm = TRUE), LinkingPersons = sum(by_person$LevelsPerPerson > 1L), LinkingPersonRate = mean(by_person$LevelsPerPerson > 
            1L), SingleLevelPersons = sum(by_person$LevelsPerPerson == 1L), SparseLevels = sum(by_level$PersonsPerLevel < 
            min_linking_persons), SparseLevelThreshold = min_linking_persons)
}

canonical_compare_interaction_terms <- function(x) {
    x <- as.character(x %||% character(0))
    if (length(x) == 0L) 
        return(character(0))
    out <- vapply(strsplit(x, ":", fixed = TRUE), function(parts) {
        paste(sort(parts), collapse = ":")
    }, character(1))
    sort(unique(out))
}

normalize_compare_signature <- function(fit) {
    cfg <- fit$config %||% list()
    anchor_tables <- extract_anchor_tables(cfg)
    anchor_tbl <- as.data.frame(anchor_tables$anchors %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(anchor_tbl) > 0) {
        anchor_tbl <- anchor_tbl[, intersect(c("Facet", "Level", "Anchor"), names(anchor_tbl)), drop = FALSE]
        anchor_tbl <- anchor_tbl[do.call(order, c(anchor_tbl[intersect(c("Facet", "Level"), names(anchor_tbl))], 
            na.last = TRUE)), , drop = FALSE]
    }
    group_tbl <- as.data.frame(anchor_tables$groups %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(group_tbl) > 0) {
        group_tbl <- group_tbl[, intersect(c("Facet", "Level", "Group", "GroupValue"), names(group_tbl)), 
            drop = FALSE]
        group_tbl <- group_tbl[do.call(order, c(group_tbl[intersect(c("Facet", "Level", "Group"), names(group_tbl))], 
            na.last = TRUE)), , drop = FALSE]
    }
    signature <- list(model = as.character(cfg$model %||% NA_character_), method = public_mfrm_method_label(cfg$method), 
        person = as.character(cfg$person_col %||% NA_character_), facets = sort(as.character(cfg$facet_cols %||% 
            fit$prep$facet_names %||% character(0))), score = as.character(cfg$score_col %||% NA_character_), 
        rating_min = suppressWarnings(as.numeric(cfg$rating_min %||% fit$prep$rating_min %||% NA_real_)), 
        rating_max = suppressWarnings(as.numeric(cfg$rating_max %||% fit$prep$rating_max %||% NA_real_)), 
        score_map = cfg$score_map %||% fit$prep$score_map %||% NULL, weight = as.character(cfg$weight_col %||% 
            NA_character_), step_facet = as.character(cfg$step_facet %||% NA_character_), slope_facet = as.character(cfg$slope_facet %||% 
            NA_character_), facet_interactions = canonical_compare_interaction_terms(cfg$facet_interactions), 
        noncenter_facet = as.character(cfg$noncenter_facet %||% "Person"), centering_scope = cfg$centering_scope %||% 
            "remainder", dummy_facets = sort(as.character(cfg$dummy_facets %||% character(0))), positive_facets = sort(as.character(cfg$positive_facets %||% 
            character(0))), anchors = anchor_tbl, group_anchors = group_tbl)
    if (nrow(anchor_tbl) + nrow(group_tbl) == 0L || identical(signature$centering_scope, "remainder")) {
        signature$centering_scope <- NULL
    }
    signature
}

same_signature_component <- function(x, y) {
    if (is.data.frame(x) || is.data.frame(y)) {
        return(identical(as.data.frame(x %||% data.frame(), stringsAsFactors = FALSE), as.data.frame(y %||% 
            data.frame(), stringsAsFactors = FALSE)))
    }
    identical(x, y)
}

mfrm_population_design <- function(fit) {
    pop <- fit$config$population_spec %||% list()
    if (!isTRUE(pop$active)) 
        return(list(active = FALSE))
    persons <- as.character(fit$prep$levels$Person %||% character(0))
    design <- pop$design_matrix
    columns <- pop$design_columns
    lookup <- pop$person_lookup
    if (!is.matrix(design) || !is.numeric(design) || ncol(design) == 0L || length(persons) == 0L || anyNA(persons) || 
        anyDuplicated(persons) || !is.character(columns) || length(columns) != ncol(design) || anyNA(columns) || 
        anyDuplicated(columns) || !is.numeric(lookup) || length(lookup) != length(persons) || any(!is.finite(lookup)) || 
        any(lookup != floor(lookup)) || any(lookup < 1L | lookup > nrow(design))) 
        return(NULL)
    design <- design[lookup[order(persons, method = "radix")], order(columns, method = "radix"), drop = FALSE]
    if (any(!is.finite(design))) 
        return(NULL)
    out <- list(active = TRUE, persons = sort(persons, method = "radix"), columns = sort(columns, method = "radix"), 
        design = matrix(as.numeric(design), nrow = length(persons)))
    if (!is.null(pop$fixed_sd)) 
        out$fixed_sd <- pop$fixed_sd
    out
}

audit_compare_mfrm_nesting <- function(fits, labels) {
    if (length(fits) != 2L) {
        return(list(eligible = FALSE, reason = "Likelihood-ratio tests are only reviewed for two-model comparisons.", 
            simpler = NA_character_, complex = NA_character_, relation = "unsupported"))
    }
    sigs <- lapply(fits, normalize_compare_signature)
    lbls <- as.character(labels)
    same_components <- c(person = same_signature_component(sigs[[1]]$person, sigs[[2]]$person), facets = same_signature_component(sigs[[1]]$facets, 
        sigs[[2]]$facets), score = same_signature_component(sigs[[1]]$score, sigs[[2]]$score), rating_min = same_signature_component(sigs[[1]]$rating_min, 
        sigs[[2]]$rating_min), rating_max = same_signature_component(sigs[[1]]$rating_max, sigs[[2]]$rating_max), 
        score_map = same_signature_component(sigs[[1]]$score_map, sigs[[2]]$score_map), weight = same_signature_component(sigs[[1]]$weight, 
            sigs[[2]]$weight), noncenter_facet = same_signature_component(sigs[[1]]$noncenter_facet, 
            sigs[[2]]$noncenter_facet), centering_scope = same_signature_component(sigs[[1]]$centering_scope, 
            sigs[[2]]$centering_scope), dummy_facets = same_signature_component(sigs[[1]]$dummy_facets, 
            sigs[[2]]$dummy_facets), positive_facets = same_signature_component(sigs[[1]]$positive_facets, 
            sigs[[2]]$positive_facets), anchors = same_signature_component(sigs[[1]]$anchors, sigs[[2]]$anchors), 
        group_anchors = same_signature_component(sigs[[1]]$group_anchors, sigs[[2]]$group_anchors))
    if (!all(same_components)) {
        mismatch <- names(same_components)[!same_components]
        return(list(eligible = FALSE, reason = paste0("Models differ in structural comparison settings: ", 
            paste(mismatch, collapse = ", "), "."), simpler = NA_character_, complex = NA_character_, 
            relation = "unsupported"))
    }
    population_designs <- lapply(fits, mfrm_population_design)
    if (any(vapply(population_designs, is.null, logical(1))) || !identical(population_designs[[1]], population_designs[[2]])) {
        return(list(eligible = FALSE, reason = paste("A shared population model could not be verified.", 
            "Automatic nesting requires the same fixed population or the same", "estimated-normal population design (declared columns and values", 
            "aligned by Person). Changed or unavailable designs require separate review."), simpler = NA_character_, 
            complex = NA_character_, relation = "population_model_unverified"))
    }
    model_pair <- toupper(c(sigs[[1]]$model, sigs[[2]]$model))
    interaction_sets <- lapply(sigs, function(sig) {
        sort(unique(as.character(sig$facet_interactions %||% character(0))))
    })
    if (any(vapply(fits, function(fit) !is.null(fit$config$step_constraint_map), logical(1)))) {
        return(audit_mfrm_step_constraints_nesting(fits = fits, sigs = sigs, labels = lbls, interaction_sets = interaction_sets))
    }
    if (identical(model_pair[1], model_pair[2])) {
        same_family_components <- c(step_facet = same_signature_component(sigs[[1]]$step_facet, sigs[[2]]$step_facet), 
            slope_facet = same_signature_component(sigs[[1]]$slope_facet, sigs[[2]]$slope_facet))
        if (!all(same_family_components)) {
            mismatch <- names(same_family_components)[!same_family_components]
            return(list(eligible = FALSE, reason = paste0("Same-family fits differ in structural model settings: ", 
                paste(mismatch, collapse = ", "), "."), simpler = NA_character_, complex = NA_character_, 
                relation = "same_model"))
        }
        int_1 <- interaction_sets[[1]]
        int_2 <- interaction_sets[[2]]
        first_in_second <- all(int_1 %in% int_2)
        second_in_first <- all(int_2 %in% int_1)
        if (length(int_1) < length(int_2) && first_in_second) {
            added <- setdiff(int_2, int_1)
            return(list(eligible = TRUE, reason = paste0("Supported nesting review passed: shared model family and constraints; ", 
                "the complex fit adds fixed facet interaction term(s): ", paste(added, collapse = ", "), 
                "."), simpler = lbls[1], complex = lbls[2], relation = "facet_interaction_extension"))
        }
        if (length(int_2) < length(int_1) && second_in_first) {
            added <- setdiff(int_1, int_2)
            return(list(eligible = TRUE, reason = paste0("Supported nesting review passed: shared model family and constraints; ", 
                "the complex fit adds fixed facet interaction term(s): ", paste(added, collapse = ", "), 
                "."), simpler = lbls[2], complex = lbls[1], relation = "facet_interaction_extension"))
        }
        if (!identical(int_1, int_2)) {
            return(list(eligible = FALSE, reason = "Both fits use the same model family, but their fixed facet-interaction sets are not nested.", 
                simpler = NA_character_, complex = NA_character_, relation = "same_model"))
        }
        return(list(eligible = FALSE, reason = "Both fits use the same model family, so there is no supported nested restriction to test.", 
            simpler = lbls[1], complex = lbls[2], relation = "same_model"))
    }
    if (setequal(model_pair, c("RSM", "PCM"))) {
        idx_simple <- which(model_pair == "RSM")[1]
        idx_complex <- which(model_pair == "PCM")[1]
        step_facet <- sigs[[idx_complex]]$step_facet
        missing_interactions <- setdiff(interaction_sets[[idx_simple]], interaction_sets[[idx_complex]])
        if (length(missing_interactions)) {
            return(list(eligible = FALSE, reason = paste0("RSM interaction terms are absent from the PCM: ", 
                paste(missing_interactions, collapse = ", "), ". Freeing category steps does not preserve these interaction effects."), 
                simpler = NA_character_, complex = NA_character_, relation = "RSM_PCM_interactions_not_nested"))
        }
        if (!is.na(step_facet) && nzchar(step_facet)) {
            return(list(eligible = TRUE, reason = paste0("Supported nesting review passed: shared design/constraints with RSM nested inside PCM on step facet '", 
                step_facet, "'."), simpler = lbls[idx_simple], complex = lbls[idx_complex], relation = "RSM_in_PCM"))
        }
    }
    if (setequal(model_pair, c("PCM", "GPCM"))) {
        idx_pcm <- which(model_pair == "PCM")[1]
        idx_gpcm <- which(model_pair == "GPCM")[1]
        pcm_step <- sigs[[idx_pcm]]$step_facet
        gpcm_step <- sigs[[idx_gpcm]]$step_facet
        gpcm_slope <- sigs[[idx_gpcm]]$slope_facet
        aligned_owner <- !is.na(pcm_step) && nzchar(pcm_step) && identical(pcm_step, gpcm_step) && !is.na(gpcm_slope) && 
            nzchar(gpcm_slope)
        review <- list(eligible = FALSE, reason = paste("PCM and GPCM must share an explicit step owner and GPCM must name its slope owner,", 
            "so even the unit-slope response-kernel reduction is not established."), simpler = if (aligned_owner) lbls[idx_pcm] else NA_character_, 
            complex = if (aligned_owner) lbls[idx_gpcm] else NA_character_, relation = "PCM_GPCM_owner_mismatch")
        if (!aligned_owner) 
            return(review)
        review$relation <- "PCM_GPCM_restriction_unverified"
        pcm <- fits[[idx_pcm]]$config
        gpcm <- fits[[idx_gpcm]]$config
        if (!identical(pcm$method, "MML") || !identical(gpcm$method, "MML")) {
            review$reason <- "The PCM/GPCM chi-square approximation requires MML fits; JML is not supported."
            return(review)
        }
        shared <- c("facet_names", "facet_levels", "facet_signs", "facet_specs", "step_specs")
        if (!identical(interaction_sets[[1]], interaction_sets[[2]]) || !all(vapply(shared, function(nm) {
            !is.null(pcm[[nm]]) && identical(pcm[[nm]], gpcm[[nm]])
        }, logical(1))) || !identical(pcm$interaction_specs, gpcm$interaction_specs)) {
            review$reason <- "PCM/GPCM testing requires identical facet constraints, step constraints and fixed interactions."
            return(review)
        }
        spec <- gpcm$gpcm_spec
        levels <- gpcm$facet_levels[[gpcm_slope]]
        sizes <- tryCatch(lapply(list(pcm, gpcm), build_param_sizes), error = function(e) NULL)
        restrictions <- length(levels) - 1L
        if (is.null(sizes) || restrictions < 1L || !isTRUE(spec$active) || !identical(spec$levels, levels) || 
            !identical(spec$slope_facet, gpcm_slope) || !identical(spec$step_facet, gpcm_step) || !identical(spec$identification, 
            "sum_to_zero_log_slopes") || !identical(spec$scale_reference, "geometric_mean_one") || !identical(as.integer(sizes[[2]][["log_slopes"]]), 
            restrictions) || !identical(sizes[[1]], sizes[[2]][names(sizes[[2]]) != "log_slopes"])) {
            review$reason <- "The G-1 free relative-slope restrictions and otherwise identical free-parameter blocks could not be verified."
            return(review)
        }
        review$eligible <- TRUE
        review$relation <- "PCM_in_GPCM"
        review$df <- restrictions
        review$reason <- paste0("PCM is the unit-slope response-kernel reduction on facet '", pcm_step, 
            "' with slopes on facet '", gpcm_slope, "', a shared population model and ", restrictions, 
            " independent log-slope restrictions. Unit slopes are interior; the", " reference is an ordinary asymptotic chi-square distribution. Numerical", 
            " solution and likelihood-comparison checks are required separately.")
        return(review)
    }
    list(eligible = FALSE, reason = paste0("Automatic nesting review supports RSM nested inside PCM, aligned PCM inside GPCM, ", 
        "or same-family fixed facet-interaction extensions under shared design ", "and constraints."), 
        simpler = NA_character_, complex = NA_character_, relation = "unsupported")
}

resolve_mfrm_category_policy <- function(keep_original, category_policy, keep_original_supplied, rating_min, 
    rating_max) {
    if (!is.logical(keep_original) || length(keep_original) != 1L || is.na(keep_original)) {
        stop("`keep_original` must be a single logical value (TRUE or FALSE).", call. = FALSE)
    }
    if (is.null(category_policy)) {
        if (!keep_original_supplied && (!is.null(rating_min) || !is.null(rating_max))) 
            return(TRUE)
        return(keep_original)
    }
    if (!is.character(category_policy) || length(category_policy) != 1L || is.na(category_policy)) {
        stop("`category_policy` must be NULL, 'collapse' or 'preserve'.", call. = FALSE)
    }
    category_policy <- match.arg(category_policy, c("collapse", "preserve"))
    preserve <- identical(category_policy, "preserve")
    if (keep_original_supplied && keep_original != preserve) {
        stop("`category_policy` and `keep_original` conflict; supply one choice or matching values.", 
            call. = FALSE)
    }
    preserve
}

describe_mfrm_data <- function(data, person = NULL, facets = NULL, score = NULL, weight = NULL, rating_min = NULL, 
    rating_max = NULL, keep_original = FALSE, missing_codes = NULL, include_person_facet = FALSE, include_agreement = TRUE, 
    rater_facet = NULL, context_facets = NULL, agreement_top_n = NULL, expected_design = NULL, min_linking_persons = 2L, 
    category_policy = NULL, repeated_ratings = c("review", "independent"), comparisons = NULL, spec = NULL) {
    mc <- match.call(expand.dots = FALSE)
    formal_supplied <- setdiff(names(as.list(mc)[-1L]), "spec")
    spec_list <- .mfrm_validate_spec_list(spec, "describe_mfrm_data()")
    desc_spec_keys <- c("person", "facets", "score", "weight", "rating_min", "rating_max", "keep_original", 
        "missing_codes", "category_policy", "repeated_ratings")
    for (nm in intersect(names(spec_list), desc_spec_keys)) {
        if (!nm %in% formal_supplied) {
            assign(nm, spec_list[[nm]], envir = environment())
        }
    }
    if ("keep_original" %in% formal_supplied && !"category_policy" %in% formal_supplied) {
        category_policy <- NULL
    }
    keep_original_supplied <- ("keep_original" %in% formal_supplied) || ("keep_original" %in% names(spec_list) && 
        !"category_policy" %in% formal_supplied)
    if (!is.character(person) || length(person) != 1L || is.na(person) || !nzchar(person)) {
        stop("`person` must be a single non-empty character string naming the person column.", call. = FALSE)
    }
    if (!is.character(facets) || length(facets) == 0L || anyNA(facets) || any(!nzchar(facets))) {
        stop("`facets` must be a character vector of one or more facet column names.", call. = FALSE)
    }
    if (!is.character(score) || length(score) != 1L || is.na(score) || !nzchar(score)) {
        stop("`score` must be a single non-empty character string naming the score column.", call. = FALSE)
    }
    repeated_ratings <- match.arg(repeated_ratings, c("review", "independent"))
    keep_original <- resolve_mfrm_category_policy(keep_original, category_policy, keep_original_supplied, 
        rating_min, rating_max)
    if (!is.numeric(min_linking_persons) || length(min_linking_persons) != 1L || !is.finite(min_linking_persons) || 
        min_linking_persons < 1L || abs(min_linking_persons - round(min_linking_persons)) > 1e-08) {
        stop("`min_linking_persons` must be a positive integer.", call. = FALSE)
    }
    min_linking_persons <- as.integer(round(min_linking_persons))
    expected_design_normalized <- normalize_expected_mfrm_design(expected_design = expected_design, person = person, 
        facets = facets)
    prep <- prepare_mfrm_data(data = data, person_col = person, facet_cols = facets, score_col = score, 
        rating_min = rating_min, rating_max = rating_max, weight_col = weight, keep_original = keep_original, 
        missing_codes = missing_codes, repeated_ratings = repeated_ratings, allow_single_person = TRUE)
    df <- dplyr::mutate(prep$data, Person = as.character(.data$Person), dplyr::across(dplyr::all_of(prep$facet_names), 
        as.character))
    selected_cols <- unique(c(person, facets, score, if (!is.null(weight)) weight))
    missing_by_column <- tibble::tibble(Column = selected_cols, Missing = vapply(selected_cols, function(col) sum(is.na(data[[col]])), 
        integer(1)))
    score_desc <- psych::describe(df$Score, fast = TRUE)
    weight_desc <- psych::describe(df$Weight, fast = TRUE)
    total_weight <- sum(df$Weight, na.rm = TRUE)
    observed_score_distribution <- dplyr::arrange(dplyr::summarize(dplyr::group_by(df, .data$Score), 
        RawN = dplyr::n(), WeightedN = sum(.data$Weight, na.rm = TRUE), Percent = ifelse(total_weight > 
            0, 100 * .data$WeightedN/total_weight, NA_real_), .groups = "drop"), .data$Score)
    score_distribution <- dplyr::mutate(dplyr::left_join(tibble::tibble(Score = seq(prep$rating_min, 
        prep$rating_max)), observed_score_distribution, by = "Score"), RawN = tidyr::replace_na(.data$RawN, 
        0L), WeightedN = tidyr::replace_na(.data$WeightedN, 0), Percent = tidyr::replace_na(.data$Percent, 
        0))
    score_distribution <- mfrm_original_score_labels(score_distribution, prep$score_map)
    report_facets <- prep$facet_names
    if (isTRUE(include_person_facet)) {
        report_facets <- c("Person", report_facets)
    }
    facet_level_summary <- purrr::map_dfr(report_facets, function(facet) {
        dplyr::mutate(dplyr::rename(dplyr::summarize(dplyr::group_by(df, .data[[facet]]), RawN = dplyr::n(), 
            WeightedN = sum(.data$Weight, na.rm = TRUE), MeanScore = weighted_mean(.data$Score, .data$Weight), 
            SDScore = stats::sd(.data$Score, na.rm = TRUE), MinScore = min(.data$Score, na.rm = TRUE), 
            MaxScore = max(.data$Score, na.rm = TRUE), .groups = "drop"), Level = dplyr::all_of(facet)), 
            Facet = facet, Level = as.character(.data$Level), .before = 1)
    })
    linkage_summary <- if (length(prep$facet_names) == 0) {
        tibble::tibble()
    }
    else {
        purrr::map_dfr(prep$facet_names, function(facet) {
            summarize_linkage_by_facet(df, facet, min_linking_persons = min_linking_persons)
        })
    }
    structural_missingness <- audit_mfrm_expected_design(df = df, expected_design = expected_design_normalized, 
        facets = prep$facet_names)
    connectivity <- audit_mfrm_connectivity(df = df, expected_design = expected_design_normalized, facets = prep$facet_names, 
        include_persons = include_person_facet)
    duplicate_cells <- summarize_duplicate_mfrm_cells(df, prep$facet_names)
    agreement_bundle <- list(summary = data.frame(), pairs = data.frame(), settings = list(included = FALSE, 
        status = if (isTRUE(include_agreement)) "not_computed" else "not_requested", rater_facet = NA_character_, 
        context_facets = character(0), expected_exact_from_model = FALSE, top_n = if (is.null(agreement_top_n)) NA_integer_ else max(1L, 
            as.integer(agreement_top_n)), note = if (isTRUE(include_agreement)) {
            "No rater-like facet was detected. Set `rater_facet` explicitly to request facet-agreement summaries."
        } else {
            "Agreement summaries were not requested."
        }))
    if (isTRUE(include_agreement) && length(prep$facet_names) > 0) {
        known_facets <- c("Person", prep$facet_names)
        if (is.null(rater_facet) || !nzchar(as.character(rater_facet[1]))) {
            rater_facet <- infer_default_rater_facet(prep$facet_names, fallback_first = FALSE)
        }
        else {
            rater_facet <- as.character(rater_facet[1])
        }
        if (is.null(rater_facet)) {
            rater_facet <- NULL
        }
        else if (!rater_facet %in% known_facets) {
            stop("`rater_facet` must match one of: ", paste(known_facets, collapse = ", "))
        }
        if (!is.null(rater_facet) && identical(rater_facet, "Person")) {
            stop("`rater_facet = 'Person'` is not supported. Use a non-person facet.")
        }
        if (!is.null(rater_facet) && is.null(context_facets)) {
            facet_cols <- known_facets
            resolved_context <- setdiff(facet_cols, rater_facet)
        }
        else if (!is.null(rater_facet)) {
            context_facets <- unique(as.character(context_facets))
            unknown <- setdiff(context_facets, known_facets)
            if (length(unknown) > 0) {
                stop("Unknown `context_facets`: ", paste(unknown, collapse = ", "))
            }
            resolved_context <- setdiff(context_facets, rater_facet)
            if (length(resolved_context) == 0) {
                stop("`context_facets` must include at least one facet different from `rater_facet`.")
            }
            facet_cols <- c(rater_facet, resolved_context)
        }
        if (!is.null(rater_facet)) {
            obs_agreement <- dplyr::rename(dplyr::select(df, dplyr::all_of(unique(c("Person", prep$facet_names, 
                "Score", "Weight")))), Observed = "Score")
            agreement <- calc_interrater_agreement(obs_df = obs_agreement, facet_cols = facet_cols, rater_facet = rater_facet, 
                res = NULL)
            agreement_pairs <- as.data.frame(agreement$pairs, stringsAsFactors = FALSE)
            if (!is.null(agreement_top_n) && nrow(agreement_pairs) > 0) {
                agreement_pairs <- dplyr::slice_head(agreement_pairs, n = max(1L, as.integer(agreement_top_n)))
            }
            agreement_bundle <- list(summary = as.data.frame(agreement$summary, stringsAsFactors = FALSE), 
                pairs = agreement_pairs, settings = list(included = TRUE, status = "computed", rater_facet = rater_facet, 
                  context_facets = resolved_context, expected_exact_from_model = FALSE, top_n = if (is.null(agreement_top_n)) NA_integer_ else max(1L, 
                    as.integer(agreement_top_n)), note = "Observed-score agreement was computed for the selected scorer facet."))
        }
    }
    overview <- tibble::tibble(Observations = nrow(df), TotalWeight = total_weight, Persons = length(prep$levels$Person), 
        Facets = length(prep$facet_names), Categories = prep$rating_max - prep$rating_min + 1, RatingMin = prep$rating_min, 
        RatingMax = prep$rating_max, RatingRangeSource = prep$rating_range_source %||% "unknown", RatingMinSource = prep$rating_min_source %||% 
            "unknown", RatingMaxSource = prep$rating_max_source %||% "unknown", OriginalRatingMin = prep$original_rating_min, 
        OriginalRatingMax = prep$original_rating_max, !!!mfrm_category_settings(prep))
    facet_crosstabs <- list()
    if (length(prep$facet_names) >= 2L) {
        for (i in seq_len(length(prep$facet_names) - 1L)) {
            for (j in seq(i + 1L, length(prep$facet_names))) {
                a <- prep$facet_names[i]
                b <- prep$facet_names[j]
                ctab <- dplyr::mutate(dplyr::count(df, LevelA = as.character(.data[[a]]), LevelB = as.character(.data[[b]]), 
                  name = "N"), FacetA = a, FacetB = b)
                facet_crosstabs[[paste(a, b, sep = "__")]] <- as.data.frame(ctab, stringsAsFactors = FALSE)
            }
        }
    }
    n_total <- nrow(data)
    missing_rate_summary <- data.frame(Column = missing_by_column$Column, Missing = as.integer(missing_by_column$Missing), 
        NonMissing = n_total - as.integer(missing_by_column$Missing), MissingRate = ifelse(rep(n_total > 
            0, nrow(missing_by_column)), missing_by_column$Missing/n_total, NA_real_), stringsAsFactors = FALSE)
    out <- list(overview = overview, comparison_review = mfrmr_build_comparison_review(prep, comparisons), 
        missing_by_column = missing_by_column, missing_rate_summary = missing_rate_summary, score_descriptives = score_desc, 
        weight_descriptives = weight_desc, score_distribution = score_distribution, facet_level_summary = facet_level_summary, 
        facet_crosstabs = facet_crosstabs, linkage_summary = linkage_summary, structural_missingness = structural_missingness, 
        design_connectivity = as.data.frame(connectivity$summary, stringsAsFactors = FALSE), design_components = as.data.frame(connectivity$components, 
            stringsAsFactors = FALSE), repeated_ratings = prep$repeated_ratings, duplicate_cell_summary = duplicate_cells$summary, 
        duplicate_cell_detail = duplicate_cells$detail, agreement = agreement_bundle, row_retention = as.data.frame(prep$row_retention %||% 
            data.frame(), stringsAsFactors = FALSE), preparation_notes = as.data.frame(prep$preparation_notes %||% 
            data.frame(), stringsAsFactors = FALSE), missing_recoding = if (is.data.frame(prep$missing_recoding)) {
            as.data.frame(prep$missing_recoding, stringsAsFactors = FALSE)
        } else {
            prep$missing_recoding
        }, score_support = list(keep_original = prep$keep_original, data = data.frame(Score = sort(unique(df$Score))), 
            rating_min = prep$rating_min, rating_max = prep$rating_max, original_rating_min = prep$original_rating_min, 
            original_rating_max = prep$original_rating_max, rating_range_source = prep$rating_range_source %||% 
                "unknown", rating_min_source = prep$rating_min_source %||% "unknown", rating_max_source = prep$rating_max_source %||% 
                "unknown", unused_score_categories = prep$unused_score_categories, score_map = prep$score_map))
    class(out) <- c("mfrm_data_description", class(out))
    out
}

recode_missing_codes <- function(data, columns = NULL, codes = c("99", "999", "-1", "N", "NA", "n/a", 
    ".", ""), numeric_codes = TRUE, verbose = FALSE) {
    if (!is.data.frame(data)) 
        stop("`data` must be a data.frame.", call. = FALSE)
    if (is.null(columns)) 
        columns <- names(data)
    bad_cols <- setdiff(columns, names(data))
    if (length(bad_cols) > 0L) {
        stop("Unknown column(s): ", paste(bad_cols, collapse = ", "), call. = FALSE)
    }
    codes <- as.character(codes)
    num_codes <- if (isTRUE(numeric_codes)) {
        suppressWarnings(as.numeric(codes))
    }
    else {
        numeric(0)
    }
    num_codes <- num_codes[is.finite(num_codes)]
    counts <- integer(length(columns))
    names(counts) <- columns
    for (col in columns) {
        x <- data[[col]]
        if (is.character(x)) {
            hit <- trimws(x) %in% codes
        }
        else if (is.numeric(x)) {
            hit <- x %in% num_codes
        }
        else {
            hit <- trimws(as.character(x)) %in% codes
        }
        n_hit <- sum(hit, na.rm = TRUE)
        counts[col] <- as.integer(n_hit)
        if (n_hit > 0L) {
            data[[col]][hit] <- NA
        }
    }
    attr(data, "mfrm_missing_recoding") <- data.frame(Column = columns, Replaced = as.integer(counts), 
        stringsAsFactors = FALSE)
    if (isTRUE(verbose)) {
        total <- sum(counts, na.rm = TRUE)
        message(sprintf("recode_missing_codes(): replaced %d cell(s) across %d column(s).", total, sum(counts > 
            0L, na.rm = TRUE)))
    }
    data
}

print.mfrm_data_description <- function(x, ...) {
    cat("mfrm data description\n")
    mfrmr_print_comparison_review(x$comparison_review)
    if (!is.null(x$overview) && nrow(x$overview) > 0) {
        print(x$overview, row.names = FALSE)
    }
    structural <- as.data.frame(x$structural_missingness$summary %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(structural) > 0L) {
        cat("\nPlanned assignment coverage\n")
        print(structural, row.names = FALSE)
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.mfrm_data_description_01"]])
    if (!is.null(x$agreement$summary) && nrow(x$agreement$summary) > 0) {
        agreement_facet <- as.character(x$agreement$settings$rater_facet %||% "selected facet")
        cat("\nObserved agreement by ", agreement_facet, "\n", sep = "")
        print(x$agreement$summary, row.names = FALSE)
    }
    invisible(x)
}

collect_mfrm_design_caveats <- function(object) {
    out <- empty_mfrm_caveats
    add_caveat <- function(area, severity, condition, facets, message, action, details = "") {
        out <<- rbind(out, data.frame(Area = area, Severity = severity, Condition = condition, Categories = paste(as.character(facets), 
            collapse = ", "), CategoryType = "design", Message = message, RecommendedAction = action, 
            Details = details, stringsAsFactors = FALSE))
        invisible(NULL)
    }
    structural <- as.data.frame(object$structural_missingness$summary %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(structural) > 0L && identical(as.character(structural$Status[1L]), "declared")) {
        missing_n <- suppressWarnings(as.integer(structural$MissingExpectedCells[1L]))
        unexpected_n <- suppressWarnings(as.integer(structural$UnexpectedObservedCells[1L]))
        if (is.finite(missing_n) && missing_n > 0L) {
            add_caveat(area = "structural_missingness", severity = "review", condition = "planned_cells_not_observed", 
                facets = object$structural_missingness$settings$key %||% character(0), message = paste0(missing_n, 
                  " planned rating cell(s) in `expected_design` were not observed."), action = "Inspect the returned object's `structural_missingness$missing_expected_cells` table and document whether each absence was planned, unavailable, or lost.")
        }
        if (is.finite(unexpected_n) && unexpected_n > 0L) {
            add_caveat(area = "structural_missingness", severity = "warning", condition = "observed_cells_not_in_design", 
                facets = object$structural_missingness$settings$key %||% character(0), message = paste0(unexpected_n, 
                  " observed rating cell(s) were not present in `expected_design`."), action = "Reconcile the assignment roster and observed data before fitting.")
        }
    }
    connectivity <- as.data.frame(object$design_connectivity %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(connectivity) > 0L && all(c("Connected", "Basis", "Facet", "Components") %in% names(connectivity))) {
        disconnected <- connectivity[!as.logical(connectivity$Connected), , drop = FALSE]
        for (i in seq_len(nrow(disconnected))) {
            basis <- as.character(disconnected$Basis[i])
            facet <- as.character(disconnected$Facet[i])
            components <- suppressWarnings(as.integer(disconnected$Components[i]))
            add_caveat(area = "design_connectivity", severity = "warning", condition = paste0("disconnected_", 
                basis, "_person_facet_graph"), facets = facet, message = paste0("The ", gsub("_", " ", 
                basis), " Person-", facet, " graph has ", components, " disconnected components."), action = paste0("Inspect the returned object's `design_components` table for ", 
                facet, " and add defensible linking observations or analyze components separately."))
        }
    }
    duplicates <- as.data.frame(object$duplicate_cell_summary %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(duplicates) > 0L && isTRUE(duplicates$HasDuplicates[1L])) {
        add_caveat(area = "duplicate_cells", severity = if (identical(object$repeated_ratings, "independent")) 
            "info"
        else "warning", condition = if (identical(object$repeated_ratings, "independent")) 
            "independent_repeated_ratings_declared"
        else "duplicate_person_facet_cells", facets = object$structural_missingness$settings$key %||% 
            character(0), message = paste0(duplicates$DuplicateCells[1L], " Person x facet cell(s) contain multiple observed rows."), 
            action = if (identical(object$repeated_ratings, "independent")) 
                "Conditional independence was declared by the analyst; the data check does not verify it."
            else "Review repeated events: correct accidental copies, model dependence, or explicitly declare conditional independence.")
    }
    linkage <- as.data.frame(object$linkage_summary %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(linkage) > 0L && all(c("Facet", "SparseLevels", "SparseLevelThreshold") %in% names(linkage))) {
        sparse <- linkage[suppressWarnings(as.integer(linkage$SparseLevels)) > 0L, , drop = FALSE]
        for (i in seq_len(nrow(sparse))) {
            add_caveat(area = "design_linkage", severity = "review", condition = "sparse_facet_levels", 
                facets = sparse$Facet[i], message = paste0(sparse$SparseLevels[i], " level(s) of ", sparse$Facet[i], 
                  " were observed for fewer than ", sparse$SparseLevelThreshold[i], " distinct persons."), 
                action = "Review the affected level support and intended inference; the threshold is descriptive, not an automatic exclusion rule.")
        }
    }
    out
}

summary.mfrm_data_description <- function(object, digits = 3, top_n = 10, ...) {
    digits <- max(0L, as.integer(digits))
    top_n <- max(1L, as.integer(top_n))
    overview <- as.data.frame(object$overview %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(overview) > 0L) {
        category_settings <- mfrm_category_settings(object$score_support %||% object$prep)
        for (field in setdiff(names(category_settings), names(overview))) {
            overview[[field]] <- category_settings[[field]]
        }
    }
    missing_tbl <- as.data.frame(object$missing_by_column %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(missing_tbl) > 0 && all(c("Column", "Missing") %in% names(missing_tbl))) {
        missing_tbl <- dplyr::slice_head(dplyr::arrange(missing_tbl, dplyr::desc(.data$Missing), .data$Column), 
            n = top_n)
    }
    score_dist_full <- as.data.frame(object$score_distribution %||% data.frame(), stringsAsFactors = FALSE)
    score_dist_full <- mfrm_original_score_labels(score_dist_full, object$score_support$score_map)
    score_dist <- score_dist_full
    if (nrow(score_dist) > 0) {
        score_dist <- utils::head(score_dist, n = top_n)
    }
    facet_tbl <- as.data.frame(object$facet_level_summary %||% data.frame(), stringsAsFactors = FALSE)
    facet_overview <- data.frame()
    if (nrow(facet_tbl) > 0 && all(c("Facet", "Level", "WeightedN") %in% names(facet_tbl))) {
        facet_overview <- as.data.frame(dplyr::arrange(dplyr::summarise(dplyr::group_by(facet_tbl, .data$Facet), 
            Levels = dplyr::n_distinct(.data$Level), TotalWeightedN = sum(.data$WeightedN, na.rm = TRUE), 
            MeanWeightedN = mean(.data$WeightedN, na.rm = TRUE), MinWeightedN = min(.data$WeightedN, 
                na.rm = TRUE), MaxWeightedN = max(.data$WeightedN, na.rm = TRUE), .groups = "drop"), 
            .data$Facet), stringsAsFactors = FALSE)
    }
    agreement_tbl <- as.data.frame(object$agreement$summary %||% data.frame(), stringsAsFactors = FALSE)
    row_retention <- as.data.frame(object$row_retention %||% data.frame(), stringsAsFactors = FALSE)
    preparation_notes <- as.data.frame(object$preparation_notes %||% data.frame(), stringsAsFactors = FALSE)
    structural_missingness <- as.data.frame(object$structural_missingness$summary %||% data.frame(), 
        stringsAsFactors = FALSE)
    structural_level_coverage <- as.data.frame(object$structural_missingness$level_coverage %||% data.frame(), 
        stringsAsFactors = FALSE)
    design_connectivity <- as.data.frame(object$design_connectivity %||% data.frame(), stringsAsFactors = FALSE)
    design_components <- as.data.frame(object$design_components %||% data.frame(), stringsAsFactors = FALSE)
    linkage_summary <- as.data.frame(object$linkage_summary %||% data.frame(), stringsAsFactors = FALSE)
    duplicate_cell_summary <- as.data.frame(object$duplicate_cell_summary %||% data.frame(), stringsAsFactors = FALSE)
    reporting_map <- data.frame(Area = c("Sample / design counts", "Missingness review", "Planned assignment coverage", 
        "Person-facet connectivity", "Score usage / category distribution", "Facet coverage", "Rater-facet agreement", 
        "Fit / reliability / residual PCA"), CoveredHere = c("yes", "yes", if (nrow(structural_missingness) > 
        0L && identical(as.character(structural_missingness$Status[1L]), "declared")) "yes" else "not declared", 
        "yes", "yes", "yes", if (nrow(agreement_tbl) > 0) "yes" else "no", "no"), CompanionOutput = c("summary(describe_mfrm_data(...))", 
        "summary(describe_mfrm_data(...))", "data_review$structural_missingness$missing_expected_cells", 
        "data_review$design_components", "summary(describe_mfrm_data(...))", "summary(describe_mfrm_data(...))", 
        "summary(describe_mfrm_data(...)) / plot(x, type = \"agreement\")", "summary(diagnose_mfrm(fit))"), 
        stringsAsFactors = FALSE)
    notes <- character(0)
    if (nrow(missing_tbl) > 0 && any(suppressWarnings(as.numeric(missing_tbl$Missing)) > 0, na.rm = TRUE)) {
        notes <- c(notes, "Missing values were detected in one or more input columns.")
    }
    else {
        notes <- c(notes, "No missing values were detected in selected input columns.")
    }
    caveat_prep <- object$score_support %||% object$prep %||% NULL
    caveats <- collect_mfrm_caveats(prep = caveat_prep, score_distribution = score_dist_full, include_recode = TRUE, 
        context = "data")
    if (nrow(caveats) > 0 && "Message" %in% names(caveats)) {
        notes <- c(notes, as.character(caveats$Message))
    }
    design_caveats <- collect_mfrm_design_caveats(object)
    caveats <- rbind(caveats, design_caveats)
    if (nrow(design_caveats) > 0L && "Message" %in% names(design_caveats)) {
        notes <- c(notes, as.character(design_caveats$Message))
    }
    structural_note <- as.character(object$structural_missingness$settings$note %||% "")
    if (nzchar(structural_note)) 
        notes <- c(notes, structural_note)
    prep_review_messages <- if (nrow(preparation_notes) > 0L && all(c("Severity", "Message") %in% names(preparation_notes))) {
        preparation_notes$Message[tolower(as.character(preparation_notes$Severity)) %in% c("review", 
            "warning", "error")]
    }
    else {
        character(0)
    }
    notes <- c(notes, prep_review_messages)
    out <- list(overview = overview, comparison_review = object$comparison_review, missing = missing_tbl, 
        score_distribution = score_dist, facet_overview = facet_overview, structural_missingness = structural_missingness, 
        structural_level_coverage = structural_level_coverage, design_connectivity = design_connectivity, 
        design_components = design_components, linkage_summary = linkage_summary, duplicate_cell_summary = duplicate_cell_summary, 
        agreement = agreement_tbl, agreement_settings = object$agreement$settings %||% list(), row_retention = row_retention, 
        preparation_notes = preparation_notes, reporting_map = reporting_map, caveats = caveats, notes = notes, 
        digits = digits)
    class(out) <- "summary.mfrm_data_description"
    out
}

print.summary.mfrm_data_description <- function(x, ...) {
    digits <- as.integer(x$digits %||% 3L)
    if (!is.finite(digits)) 
        digits <- 3L
    cat("mfrm Data Description Summary\n")
    mfrmr_print_comparison_review(x$comparison_review)
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_data_description_01"]], 
        digits = digits)
    if (!is.null(x$row_retention) && nrow(x$row_retention) > 0 && "DroppedRows" %in% names(x$row_retention) && 
        any(suppressWarnings(as.numeric(x$row_retention$DroppedRows)) > 0, na.rm = TRUE)) {
        cat("\nRow retention\n")
        print(round_numeric_df(as.data.frame(x$row_retention), digits = digits), row.names = FALSE)
    }
    print_note_section(notes = x$preparation_notes, title = "Data preparation notes", preparation = TRUE)
    if (!is.null(x$agreement) && nrow(x$agreement) > 0) {
        agreement_facet <- as.character(x$agreement_settings$rater_facet %||% "selected facet")
        cat("\nObserved agreement by ", agreement_facet, "\n", sep = "")
        print(round_numeric_df(as.data.frame(x$agreement), digits = digits), row.names = FALSE)
    }
    print_note_section(notes = x$caveats, preparation = FALSE)
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_data_description_02"]])
    note_lines <- as.character(x$notes %||% character(0))
    note_lines <- note_lines[nzchar(note_lines)]
    if (length(note_lines) > 0L) {
        cat("\nNotes\n")
        cat(paste0(" - ", note_lines, collapse = "\n"), "\n", sep = "")
    }
    invisible(x)
}


review_mfrm_prepared_anchors <- function(prep, anchors = NULL, group_anchors = NULL, min_common_anchors = 5L, 
    min_obs_per_element = 30, min_obs_per_category = 10, noncenter_facet = "Person", dummy_facets = NULL, 
    centering_scope = c("facet", "remainder", "anchor_origin")) {
    centering_scope <- match.arg(centering_scope)
    noncenter_facet <- sanitize_noncenter_facet(noncenter_facet, prep$facet_names)
    dummy_facets <- sanitize_dummy_facets(dummy_facets, prep$facet_names)
    review <- audit_anchor_tables(prep = prep, anchor_df = anchors, group_anchor_df = group_anchors, 
        min_common_anchors = min_common_anchors, min_obs_per_element = min_obs_per_element, min_obs_per_category = min_obs_per_category, 
        noncenter_facet = noncenter_facet, dummy_facets = dummy_facets, centering_scope = centering_scope)
    class(review) <- unique(c("mfrm_anchor_review", class(review)))
    constraint_specs <- prepare_constraint_specs(prep, noncenter_facet = noncenter_facet, dummy_facets = dummy_facets, 
        centering_scope = centering_scope, anchor_review = review)
    list(anchor_review = review, constraint_specs = constraint_specs)
}

prepare_mfrm_auto_gpcm_scaffold_inputs <- function(data, person, missing_codes) {
    estimation_person_ids <- enc2utf8(trimws(as.character(data[[person]])))
    default_missing_codes <- isTRUE(missing_codes) || (is.character(missing_codes) && length(missing_codes) == 
        1L && identical(tolower(missing_codes), "default"))
    if (!is.null(missing_codes) && !isFALSE(missing_codes) && !default_missing_codes) {
        estimation_person_ids[estimation_person_ids %in% enc2utf8(trimws(as.character(missing_codes)))] <- NA_character_
    }
    scaffold_data <- data
    scaffold_data[[person]] <- estimation_person_ids
    scaffold_data <- scaffold_data[!is.na(estimation_person_ids), , drop = FALSE]
    person_tbl <- data.frame(.mfrmr_person_id = unique(estimation_person_ids[!is.na(estimation_person_ids)]), 
        stringsAsFactors = FALSE)
    names(person_tbl) <- person
    list(estimation_person_ids = estimation_person_ids, scaffold_data = scaffold_data, population_formula = stats::as.formula("~ 1"), 
        person_data = person_tbl, person_id = person)
}

annotate_mfrm_population_scaffold <- function(population, data, scaffold_data, gpcm_mml_active, auto_gpcm_population, 
    population_sd = NULL) {
    if (!is.null(population_sd)) 
        population$fixed_sd <- population_sd
    population$source <- if (auto_gpcm_population) {
        "gpcm_mml_default_identification"
    }
    else if (isTRUE(population$active)) {
        "user_supplied"
    }
    else {
        "none"
    }
    population$identification_role <- if (gpcm_mml_active && isTRUE(population$active)) {
        "free_population_scale_with_geometric_mean_one_relative_slopes"
    }
    else if (gpcm_mml_active) {
        "fixed_standard_normal_with_geometric_mean_one_relative_slopes"
    }
    else {
        "not_applicable"
    }
    if (auto_gpcm_population) {
        population$response_rows_retained <- as.integer(nrow(scaffold_data))
        population$response_rows_omitted <- as.integer(nrow(data) - nrow(scaffold_data))
        population$notes <- unique(c(as.character(population$notes %||% character(0)), paste("An intercept-only person population model was activated automatically", 
            "to identify GPCM MML without fixing both latent variance and", "the slope geometric mean."), 
            if (population$response_rows_omitted > 0L) {
                paste0(population$response_rows_omitted, " response row(s) with missing person IDs were excluded from the ", 
                  "automatic population scaffold; ordinary response preparation ", "applies the same exclusion.")
            } else {
                character(0)
            }))
    }
    population
}

enforce_mfrm_anchor_review_policy <- function(anchor_review, anchor_policy = c("warn", "error", "silent")) {
    anchor_policy <- match.arg(tolower(anchor_policy), c("warn", "error", "silent"))
    schema_issues <- anchor_review$issues[c("anchor_schema_mismatch", "group_anchor_schema_mismatch")]
    if (any(vapply(schema_issues, nrow, integer(1)) > 0L)) 
        stop("Malformed anchor schema: nonempty constraints cannot be discarded. Direct anchors require facet, level and anchor/value/measure; group anchors also require group/subset and groupvalue/value/anchor.", 
            call. = FALSE)
    issue_counts <- anchor_review$issue_counts
    issue_total <- if (is.null(issue_counts) || nrow(issue_counts) == 0) 
        0L
    else sum(issue_counts$N, na.rm = TRUE)
    if (issue_total > 0) {
        msg <- format_anchor_review_message(anchor_review)
        if (anchor_policy == "error") {
            stop(msg, call. = FALSE)
        }
        else if (anchor_policy == "warn") {
            warning(msg, call. = FALSE)
        }
    }
    invisible(anchor_review)
}

print.mfrm_anchor_review <- function(x, ...) {
    issue_total <- if (!is.null(x$issue_counts) && nrow(x$issue_counts) > 0) 
        sum(x$issue_counts$N)
    else 0
    cat("mfrm anchor review\n")
    cat("  issue rows: ", issue_total, "\n", sep = "")
    if (!is.null(x$issue_counts) && nrow(x$issue_counts) > 0) {
        nonzero <- dplyr::filter(x$issue_counts, .data$N > 0)
        if (nrow(nonzero) > 0) {
            cat("\nIssue counts\n")
            print(nonzero, row.names = FALSE)
        }
    }
    print_summary_sections(x, .mfrmr_summary_print_sections[["print.mfrm_anchor_review_01"]])
    if (!is.null(x$design_checks) && !is.null(x$design_checks$level_observation_summary) && nrow(x$design_checks$level_observation_summary) > 
        0) {
        cat("\nLevel observation summary\n")
        print(x$design_checks$level_observation_summary, row.names = FALSE)
    }
    invisible(x)
}

summary.mfrm_anchor_review <- function(object, digits = 3, top_n = 10, ...) {
    digits <- max(0L, as.integer(digits))
    top_n <- max(1L, as.integer(top_n))
    issue_counts <- as.data.frame(object$issue_counts %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(issue_counts) > 0 && all(c("Issue", "N") %in% names(issue_counts))) {
        issue_counts <- dplyr::slice_head(dplyr::arrange(dplyr::filter(issue_counts, .data$N > 0), dplyr::desc(.data$N), 
            .data$Issue), n = top_n)
    }
    facet_summary <- as.data.frame(object$facet_summary %||% data.frame(), stringsAsFactors = FALSE)
    level_summary <- as.data.frame(object$design_checks$level_observation_summary %||% data.frame(), 
        stringsAsFactors = FALSE)
    category_summary <- as.data.frame(object$design_checks$category_counts %||% data.frame(), stringsAsFactors = FALSE)
    recommendations <- as.character(object$recommendations %||% character(0))
    if (length(recommendations) > top_n) {
        recommendations <- recommendations[seq_len(top_n)]
    }
    notes <- if (nrow(issue_counts) > 0) {
        "Anchor-review issues were detected. Review issue counts and recommendations."
    }
    else {
        "No anchor-table issue rows were detected."
    }
    out <- list(issue_counts = issue_counts, facet_summary = facet_summary, level_observation_summary = level_summary, 
        category_counts = category_summary, recommendations = recommendations, notes = notes, digits = digits)
    class(out) <- "summary.mfrm_anchor_review"
    out
}

make_anchor_table <- function(fit, facets = NULL, include_person = FALSE, digits = NULL, readiness_policy = c("error", 
    "review")) {
    if (inherits(fit, "mfrm_fast_fit")) {
        readiness_policy <- match.arg(readiness_policy)
        if (!isTRUE(fit$converged) && identical(readiness_policy, "error")) {
            stop("`fit` did not converge; resolve convergence or set `readiness_policy = 'review'`.", call. = FALSE)
        }
        out <- fit$facets[, c("Facet", "Level", "Estimate"), drop = FALSE]
        names(out)[3L] <- "Anchor"
        if (isTRUE(include_person)) {
            p_anc <- data.frame(Facet = "Person", Level = fit$person$Person, Anchor = fit$person$Estimate, stringsAsFactors = FALSE)
            out <- rbind(p_anc, out)
        }
        if (!is.null(facets)) out <- out[out$Facet %in% as.character(facets), , drop = FALSE]
        if (!is.null(digits)) out$Anchor <- round(out$Anchor, digits = as.integer(digits))
        rownames(out) <- NULL
        return(tibble::as_tibble(out))
    }
    stop_if_product_slopes(fit, "make_anchor_table()")
    if (!inherits(fit, "mfrm_fit")) {
        stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
    }
    readiness_policy <- match.arg(readiness_policy)
    source_readiness <- mfrm_convergence_state(fit)
    fit_readiness <- as.character(source_readiness$fit_readiness %||% "legacy_unknown")[1]
    if (is.na(fit_readiness) || !nzchar(fit_readiness)) {
        fit_readiness <- "legacy_unknown"
    }
    if (!isTRUE(source_readiness$inference_ready) && identical(readiness_policy, "error")) {
        stop("`fit` is not eligible for anchor export or reuse (FitReadiness = '", fit_readiness, "', InferenceReady = FALSE). Resolve the source fit or use ", 
            "`readiness_policy = \"review\"` only to inspect review-only ", "candidate values.", call. = FALSE)
    }
    if (!is.null(digits) && (!is.numeric(digits) || is.complex(digits) || length(digits) != 1L || !is.finite(digits) || 
        digits < 0 || digits != floor(digits))) {
        stop("`digits` must be NULL or one nonnegative integer.", call. = FALSE)
    }
    anchor_values <- function(x) {
        if (is.null(digits)) 
            as.numeric(x)
        else round(as.numeric(x), digits = digits)
    }
    out <- tibble::tibble()
    if (isTRUE(include_person) && !is.null(fit$facets$person) && nrow(fit$facets$person) > 0) {
        per <- tibble::as_tibble(fit$facets$person)
        if ("Person" %in% names(per) && "Estimate" %in% names(per)) {
            out <- dplyr::bind_rows(out, dplyr::transmute(per, Facet = "Person", Level = as.character(.data$Person), 
                Anchor = anchor_values(.data$Estimate)))
        }
    }
    others <- tibble::as_tibble(fit$facets$others)
    if (nrow(others) > 0 && all(c("Facet", "Level", "Estimate") %in% names(others))) {
        out <- dplyr::bind_rows(out, dplyr::transmute(others, Facet = as.character(.data$Facet), Level = as.character(.data$Level), 
            Anchor = anchor_values(.data$Estimate)))
    }
    if (!is.null(facets)) {
        keep <- as.character(facets)
        out <- dplyr::filter(out, .data$Facet %in% keep)
    }
    out <- dplyr::arrange(out, .data$Facet, .data$Level)
    attr(out, "source_fit_readiness") <- fit_readiness
    attr(out, "source_inference_ready") <- isTRUE(source_readiness$inference_ready)
    attr(out, "readiness_policy") <- readiness_policy
    out
}

diagnose_mfrm <- function(fit, interaction_pairs = NULL, top_n_interactions = 20, whexact = FALSE, fit_df_method = "facets", 
    diagnostic_mode = c("both", "legacy", "marginal_fit"), residual_pca = c("none", "overall", "facet", 
        "both"), pca_max_factors = 10L) {
    if (inherits(fit, "mfrm_fast_fit")) {
        return(.mfrm_diagnose_fast_fit(fit))
    }
    fit <- .mfrm_validate_diagnostic_fit(fit)
    fit_df_method <- match_fit_df_method(fit_df_method)
    diagnostic_mode <- match.arg(diagnostic_mode)
    residual_pca <- match.arg(tolower(residual_pca), c("none", "overall", "facet", "both"))
    out <- mfrm_diagnostics(fit, interaction_pairs = interaction_pairs, top_n_interactions = top_n_interactions, 
        whexact = whexact, fit_df_method = fit_df_method, diagnostic_mode = diagnostic_mode, residual_pca = residual_pca, 
        pca_max_factors = pca_max_factors)
    out$parameter_uncertainty$source <- mfrm_native_location_identity(fit)
    class(out) <- c("mfrm_diagnostics", class(out))
    out
}

mfrm_ic_stored_value_matches <- function(actual, expected, tolerance = 1e-10) {
    if (length(actual) == 0L || length(expected) == 0L) 
        return(FALSE)
    actual <- actual[1]
    expected <- expected[1]
    if (is.numeric(expected) || is.integer(expected)) {
        actual <- suppressWarnings(as.numeric(actual))
        expected <- suppressWarnings(as.numeric(expected))
        if (is.na(actual) && is.na(expected)) 
            return(TRUE)
        if (!is.finite(actual) || !is.finite(expected)) {
            return(identical(actual, expected))
        }
        return(abs(actual - expected) <= tolerance * max(1, abs(expected)))
    }
    if (is.logical(expected)) {
        actual <- suppressWarnings(as.logical(actual))
        if (is.na(actual) && is.na(expected)) 
            return(TRUE)
        return(identical(actual, expected))
    }
    actual <- as.character(actual)
    expected <- as.character(expected)
    if (is.na(actual) && is.na(expected)) 
        return(TRUE)
    identical(actual, expected)
}

mfrm_extract_fit_ic_contract <- function(fit, tolerance = 1e-10) {
    summary_row <- as.data.frame(fit$summary %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(summary_row) > 0L) 
        summary_row <- summary_row[1, , drop = FALSE]
    config <- fit$config %||% list()
    prep <- fit$prep %||% list()
    method <- public_mfrm_method_label(toupper(as.character(config$method %||% if ("Method" %in% names(summary_row)) summary_row$Method[1] else NA_character_)[1]))
    model <- toupper(as.character(config$model %||% if ("Model" %in% names(summary_row)) summary_row$Model[1] else NA_character_)[1])
    current_contract <- nrow(summary_row) > 0L && "ICContractVersion" %in% names(summary_row) && identical(as.character(summary_row$ICContractVersion[1]), 
        .mfrmr_const_mfrm_ic_contract_version)
    can_rebuild <- !is.null(fit$opt$value) && length(fit$opt$value) > 0L && !is.null(fit$opt$par) && 
        is.list(prep) && is.data.frame(prep$data)
    expected <- if (can_rebuild) {
        tryCatch(build_mfrm_ic_contract(loglik = -as.numeric(fit$opt$value[1]), npar = length(fit$opt$par), 
            prep = prep, config = config, method = method), error = function(e) NULL)
    }
    else {
        NULL
    }
    if (current_contract && !is.null(expected)) {
        required <- .mfrmr_const_mfrm_ic_contract_required_fields
        missing_fields <- setdiff(required, names(summary_row))
        comparable_fields <- intersect(required, names(expected))
        field_checks <- vapply(comparable_fields, function(field) {
            field %in% names(summary_row) && mfrm_ic_stored_value_matches(summary_row[[field]][1], expected[[field]], 
                tolerance = tolerance)
        }, logical(1))
        stored_consistent <- length(missing_fields) == 0L && all(field_checks)
        mismatch <- c(missing_fields, names(field_checks)[!field_checks])
        contract_state <- if (stored_consistent) 
            "current"
        else "current_inconsistent"
        values <- expected
    }
    else {
        stored_consistent <- NA
        mismatch <- if (current_contract) 
            "contract_rebuild_unavailable"
        else "missing_current_contract"
        contract_state <- "legacy_or_unknown"
        response_rows <- if (is.data.frame(prep$data)) 
            nrow(prep$data)
        else NA_integer_
        weighted_total <- if (is.data.frame(prep$data) && "Weight" %in% names(prep$data)) {
            legacy_weights <- suppressWarnings(as.numeric(prep$data$Weight))
            if (length(legacy_weights) > 0L && all(is.finite(legacy_weights))) {
                sum(legacy_weights)
            }
            else {
                NA_real_
            }
        }
        else {
            as.numeric(response_rows)
        }
        persons <- if (is.data.frame(prep$data) && "Person" %in% names(prep$data)) {
            person_values <- as.character(prep$data$Person)
            length(unique(person_values[!is.na(person_values)]))
        }
        else {
            suppressWarnings(as.integer(config$n_person %||% NA_integer_))
        }
        stored_loglik <- if ("LogLik" %in% names(summary_row)) {
            suppressWarnings(as.numeric(summary_row$LogLik[1]))
        }
        else if (!is.null(fit$opt$value)) {
            -suppressWarnings(as.numeric(fit$opt$value[1]))
        }
        else {
            NA_real_
        }
        stored_aic <- if ("LegacyAIC" %in% names(summary_row)) {
            suppressWarnings(as.numeric(summary_row$LegacyAIC[1]))
        }
        else if ("AIC" %in% names(summary_row)) {
            suppressWarnings(as.numeric(summary_row$AIC[1]))
        }
        else {
            NA_real_
        }
        stored_bic <- if ("LegacyBIC" %in% names(summary_row)) {
            suppressWarnings(as.numeric(summary_row$LegacyBIC[1]))
        }
        else if ("BIC" %in% names(summary_row)) {
            suppressWarnings(as.numeric(summary_row$BIC[1]))
        }
        else {
            NA_real_
        }
        legacy_n <- if ("N" %in% names(summary_row)) {
            suppressWarnings(as.numeric(summary_row$N[1]))
        }
        else {
            NA_real_
        }
        values <- list(ICContractVersion = "legacy_or_unknown", N = legacy_n, ResponseRows = as.integer(response_rows), 
            WeightedResponseTotal = as.numeric(weighted_total), Persons = as.integer(persons), Npar = if (!is.null(fit$opt$par)) length(fit$opt$par) else NA_integer_, 
            LogLik = stored_loglik, Deviance = if (is.finite(stored_loglik)) -2 * stored_loglik else NA_real_, 
            WeightPolicy = if (is.data.frame(prep$data)) {
                mfrm_ic_weight_policy(prep, config)
            } else {
                "unknown"
            }, ICEligible = FALSE, ICSelectable = FALSE, ICStatus = "suppressed_legacy_contract", ICSampleSize = NA_real_, 
            ICSampleSizeBasis = "legacy_or_unknown", AIC = NA_real_, BIC = NA_real_, SABIC = NA_real_, 
            SABICSelectable = FALSE, AICFormula = NA_character_, BICFormula = NA_character_, SABICFormula = NA_character_, 
            IntegrationEvaluationId = mfrm_ic_integration_evaluation_id(method, config), ICQuadraturePoints = NA_integer_, 
            ICIntegrationTier = "legacy_or_unknown", ICIntegrationStatus = "legacy_or_unknown", ICIntegrationSelectable = FALSE, 
            LegacyAIC = stored_aic, LegacyBIC = stored_bic, LegacyICSampleSize = legacy_n, LegacyICSampleSizeBasis = if (!is.null(config$weight_col)) {
                "sum_weights"
            } else {
                "row_count"
            })
    }
    tibble::tibble(Model = model, Method = method, nobs = values$ResponseRows, ResponseRows = values$ResponseRows, 
        WeightedN = values$WeightedResponseTotal, WeightedResponseTotal = values$WeightedResponseTotal, 
        Persons = values$Persons, ICSampleSize = values$ICSampleSize, ICSampleSizeBasis = values$ICSampleSizeBasis, 
        Npar = values$Npar, npar = values$Npar, LogLik = values$LogLik, Deviance = values$Deviance, AIC = values$AIC, 
        BIC = values$BIC, SABIC = values$SABIC, SABICSelectable = values$SABICSelectable, WeightPolicy = values$WeightPolicy, 
        ICEligible = values$ICEligible, ICSelectable = values$ICSelectable, ICStatus = values$ICStatus, 
        ICContractVersion = values$ICContractVersion, AICFormula = values$AICFormula, BICFormula = values$BICFormula, 
        SABICFormula = values$SABICFormula, IntegrationEvaluationId = values$IntegrationEvaluationId, 
        ICQuadraturePoints = values$ICQuadraturePoints, ICIntegrationTier = values$ICIntegrationTier, 
        ICIntegrationStatus = values$ICIntegrationStatus, ICIntegrationSelectable = values$ICIntegrationSelectable, 
        LegacyAIC = values$LegacyAIC, LegacyBIC = values$LegacyBIC, LegacyICSampleSize = values$LegacyICSampleSize, 
        LegacyICSampleSizeBasis = values$LegacyICSampleSizeBasis, ICContractState = contract_state, StoredICConsistent = stored_consistent, 
        StoredICMismatch = paste(unique(mismatch), collapse = ";"))
}

mfrm_ic_fit_check <- function(fit, contract, information = NULL, allow_singleton = FALSE) {
    readiness <- mfrmr_get_readiness_record(fit)$fit
    ordinary_ready <- mfrm_inference_ready(fit)
    out <- list(eligible = ordinary_ready, basis = "fit_inference_readiness", review = if (ordinary_ready) "" else as.character(mfrm_fit_decision_summary(readiness)$Why[1]))
    rasch_singleton <- isTRUE(allow_singleton) && fit$config$model %in% c("RSM", "PCM") && identical(as.character(readiness$CategoryState[1]), 
        "weak_information")
    if ((!identical(fit$config$model, "GPCM") && !isTRUE(fit$config$population_spec$active) && !rasch_singleton) || 
        !identical(fit$config$method, "MML")) 
        return(out)
    out$eligible <- FALSE
    out$basis <- "mml_local_solution_information"
    refuse <- function(reason) {
        out$review <- reason
        out
    }
    if (!isTRUE(contract$StoredICConsistent[1]) || !isTRUE(contract$ICSelectable[1])) {
        return(refuse("Current, consistent MML likelihood metadata and a sufficiently resolved quadrature grid are required."))
    }
    identification <- mfrm_mml_inference_identification(fit)
    if (isTRUE(identification$excluded)) 
        return(refuse(identification$detail))
    category_ready <- identical(as.character(readiness$CategoryState[1]), "adequate")
    singleton_review <- FALSE
    if (!category_ready && isTRUE(allow_singleton) && fit$config$model %in% c("RSM", "PCM", "GPCM") && 
        identical(as.character(readiness$CategoryState[1]), "weak_information")) {
        audit <- tryCatch(audit_mfrm_category_support(fit$prep, fit$config, build_param_sizes(fit$config)), 
            error = function(e) NULL)
        counts <- audit$category_table$WithinScopeCount
        local <- audit$local_support
        local_sparse <- rasch_singleton && is.data.frame(local) && nrow(local) > 0L && all(!is.na(local$MissingCategories)) && 
            isTRUE(any(nzchar(local$MissingCategories) | local$MinimumObservedCategoryCount == 1L))
        singleton_review <- isTRUE(audit$readiness$Complete) && identical(audit$readiness$CategoryState, 
            "weak_information") && identical(audit$readiness$ReasonCodes, "weak_category_information") && 
            isTRUE(audit$readiness$UnsupportedStepCoordinates == 0L) && isTRUE(audit$readiness$UnsupportedCategoryContrasts == 
            0L) && length(counts) > 0L && all(is.finite(counts)) && all(counts > 0L) && (any(counts == 
            1L) || local_sparse)
    }
    if (!identical(as.character(readiness$InputState[1]), "pass")) 
        return(refuse("Input preparation requires review before MML inference. See summary(fit)$preparation_notes."))
    if (!(category_ready || singleton_review)) 
        return(refuse("Category support requires review before MML inference."))
    if (!identical(as.character(readiness$NumericalState[1]), "ready") || !identical(fit$opt$optimizer_diagnostics$ConvergenceSeverity, 
        "pass")) {
        return(refuse("The MML optimizer has not passed the numerical convergence checks."))
    }
    gradient_tolerance <- as.numeric(fit$opt$optimizer_diagnostics$GradientReviewTolerance)
    if (length(gradient_tolerance) != 1L || !is.finite(gradient_tolerance) || gradient_tolerance <= 0 || 
        gradient_tolerance > 1e-04) 
        gradient_tolerance <- 1e-04
    information <- information %||% tryCatch({
        covariance <- compute_mml_parameter_covariance(fit, solution_tolerance = gradient_tolerance)
        covariance$solution_information %||% list(status = "unavailable", detail = covariance$detail)
    }, error = function(e) list(status = "unavailable", detail = conditionMessage(e)))
    if (identical(information$status, "rejected_local_solution")) {
        return(refuse(information$detail))
    }
    if (!identical(information$status, "evaluated_diagnostic_only")) {
        return(refuse(paste("MML solution information is unavailable:", information$detail)))
    }
    evaluation <- information$evaluation_summary
    eigenvalues <- information$eigenvalue_summary
    objective <- fit$opt$value
    reevaluated <- evaluation$ReevaluatedObjective
    gradient <- evaluation$GradientMaxAbs
    smallest <- eigenvalues$Smallest
    scale <- eigenvalues$AbsoluteScale
    scalars <- list(objective, reevaluated, gradient, smallest, scale, information$free_dimension)
    if (!all(vapply(scalars, function(x) is.numeric(x) && !is.complex(x) && length(x) == 1L && is.finite(x), 
        logical(1))) || length(fit$opt$par) != information$free_dimension || gradient < 0 || smallest > 
        scale) {
        return(refuse("Finite, dimensionally consistent likelihood, gradient and information are required."))
    }
    if (abs(reevaluated - objective) > 1e-10 * max(1, abs(objective))) {
        return(refuse("The retained objective does not match reevaluation at the supplied data and parameters."))
    }
    if (gradient > gradient_tolerance) {
        return(refuse("The reevaluated MML gradient exceeds the numerical convergence tolerance."))
    }
    inverse_review <- information$inverse_review
    refined <- isTRUE(inverse_review$Verified) && all(c("RelativeChange", "InverseResidual", "CurvatureScaledGradient") %in% 
        names(inverse_review)) && all(vapply(inverse_review[c("RelativeChange", "InverseResidual", "CurvatureScaledGradient")], 
        length, integer(1)) == 1L) && all(is.finite(c(inverse_review$RelativeChange, inverse_review$InverseResidual, 
        inverse_review$CurvatureScaledGradient))) && min(inverse_review$RelativeChange, inverse_review$InverseResidual, 
        inverse_review$CurvatureScaledGradient) >= 0 && inverse_review$RelativeChange <= 0.001 && inverse_review$InverseResidual <= 
        1e-06 && inverse_review$CurvatureScaledGradient <= 1e-04
    if (!is.null(inverse_review) && !isTRUE(refined)) {
        return(refuse(inverse_review$Detail %||% "Information refinement did not pass."))
    }
    if (scale <= 0 || smallest <= 0 || (smallest <= scale * sqrt(.Machine$double.eps) && !refined)) {
        return(refuse("MML information is singular, indefinite or too ill-conditioned for ordinary inference."))
    }
    out$eligible <- TRUE
    if (refined) 
        out$caution <- inverse_review$Detail
    if (singleton_review) 
        out$caution <- trimws(paste(out$caution %||% "", if (rasch_singleton) 
            "Some fitted category counts are singletons or some local category cells are empty/singletons. All categories remain supported in their fitted step scopes. Model-information intervals remain asymptotic approximations; sparse support can affect bias and coverage. The source fit retains its category-support review."
        else paste("Singleton score categories: the point estimate is retained for the basic bootstrap", 
            "after numerical and information checks. Sparse category support may affect accuracy;", "this does not establish Wald-interval eligibility.")))
    out$review <- paste("The retained MML solution has matching likelihood, a small gradient and", "positive unregularized local information. Check starting-value and", 
        "integration sensitivity when comparing close criteria; this is not a", "global-maximum certificate or permission for slope intervals or an LRT.", 
        out$caution %||% "")
    out
}

compare_mfrm <- function(..., labels = NULL, warn_constraints = TRUE, nested = FALSE, response_diagnostics = NULL, 
    person_scores = NULL) {
    if (!is.logical(nested) || length(nested) != 1L || is.na(nested)) {
        stop("`nested` must be a single logical value (TRUE or FALSE).", call. = FALSE)
    }
    fits <- list(...)
    if (length(fits) >= 2L && any(vapply(fits, inherits, logical(1), what = "mfrm_fast_fit"))) {
        if (!all(vapply(fits, inherits, logical(1), what = "mfrm_fast_fit"))) {
            stop("All compared fits must share the same estimation representation (`fast = TRUE` or canonical).", call. = FALSE)
        }
        return(.mfrm_compare_fast_fits(fits, labels = labels, nested = nested))
    }
    plan_input <- vapply(fits, inherits, logical(1), what = "mfrm_multivariate_d_study")
    if (any(plan_input)) {
        if (!plan_input[1L] || sum(plan_input) != 1L) 
            stop("Supply one D-study containing all plans to compare.", call. = FALSE)
        if (!missing(labels) || !missing(warn_constraints) || !missing(nested) || !missing(response_diagnostics) || 
            !missing(person_scores)) 
            stop("Model-comparison arguments do not apply to a D-study plan comparison.", call. = FALSE)
        x <- fits[[1L]]
        defaults <- list(reference = 1L, score = NULL, composite = NULL, assumption = NULL, level = 0.95)
        options <- fits[-1L]
        if (length(options) && (is.null(names(options)) || anyNA(names(options)) || any(!nzchar(names(options))) || 
            anyDuplicated(names(options)) || any(!names(options) %in% names(defaults)))) 
            stop("Name D-study options with `reference`, `score`, `composite`, `assumption` or `level`.", 
                call. = FALSE)
        defaults[names(options)] <- options
        reference <- defaults$reference
        score <- defaults$score
        composite <- defaults$composite
        assumption <- defaults$assumption
        level <- defaults$level
        if (!identical(assumption, "normal")) {
            stop("This approximation requires `assumption = 'normal'` for the random effects; it does not test that assumption.", 
                call. = FALSE)
        }
        .mfrm_mvds_require_raw(x)
        d <- mfrm_d_study(x$gstudy, x$design_grid, x$weights)
        g <- d$gstudy
        if (length(g$design$counts) != 3L || !is.null(g$design$nesting)) {
            stop("This interval method currently supports two common crossed random facets; nested-design intervals are not available.", 
                call. = FALSE)
        }
        nplans <- nrow(d$design_grid)
        if (nplans < 2L || !is.numeric(reference) || is.complex(reference) || is.object(reference) || 
            !is.null(dim(reference)) || length(reference) != 1L || !is.finite(reference) || reference != 
            floor(reference) || reference < 1L || reference > nplans) {
            stop("Supply at least two plans and a valid reference row number.", call. = FALSE)
        }
        if (!is.numeric(level) || is.complex(level) || is.object(level) || !is.null(dim(level)) || length(level) != 
            1L || !is.finite(level) || level <= 0 || level >= 1) {
            stop("`level` must be a number strictly between zero and one.", call. = FALSE)
        }
        target <- .mfrm_mvds_interval_target(d, score, composite, comparison = TRUE)
        kind <- target$kind
        selected <- target$selected
        w <- target$weights
        tab <- target$table
        weight_scale <- max(abs(w))
        unit_w <- w/weight_scale
        theta <- vapply(g$components, function(a) drop(crossprod(unit_w, a %*% unit_w)), numeric(1))
        component_scale <- max(abs(theta))
        if (component_scale == 0) 
            component_scale <- 1
        theta <- theta/component_scale
        sem_scale <- sqrt(component_scale) * weight_scale
        C <- .mfrm_mvgt_component_covariance(g, theta)
        eigenvalues <- eigen(C, symmetric = TRUE, only.values = TRUE)$values
        covariance_psd <- min(eigenvalues) >= -sqrt(.Machine$double.eps) * max(abs(eigenvalues))
        metrics <- c("G", "Phi", "RelativeSEM", "AbsoluteSEM")
        gradients <- lapply(seq_len(nplans), function(i) {
            counts <- as.numeric(d$design_grid[i, ])
            r <- unname(.mfrm_mvgt_profile_error(d, i, "G", counts))
            a <- unname(.mfrm_mvgt_profile_error(d, i, "Phi", counts))
            J <- matrix(NA_real_, 4, 7)
            for (j in 1:2) {
                c <- if (j == 1L) 
                  r
                else a
                e <- sum(c * theta)
                u <- theta[1L]
                if (u > 0 && e > 0) {
                  J[j, ] <- -u * c/(u + e)^2
                  J[j, 1L] <- e/(u + e)^2
                }
                if (e > 0) 
                  J[j + 2L, ] <- sem_scale * c/(2 * sqrt(e))
            }
            J
        })
        others <- setdiff(seq_len(nplans), reference)
        J <- do.call(rbind, lapply(others, function(i) gradients[[i]] - gradients[[reference]]))
        table <- do.call(rbind, lapply(others, function(i) data.frame(Reference = reference, Scenario = i, 
            Kind = kind, Score = selected, Metric = metrics, ReferenceValue = as.numeric(tab[reference, 
                metrics]), Value = as.numeric(tab[i, metrics]), Difference = as.numeric(tab[i, metrics]) - 
                as.numeric(tab[reference, metrics]), Status = ifelse(is.finite(as.numeric(tab[i, metrics])) & 
                is.finite(as.numeric(tab[reference, metrics])), "Available", "Point projection unavailable"), 
            row.names = NULL)))
        identical_plan <- vapply(others, function(i) all(d$design_grid[i, ] == d$design_grid[reference, 
            ]), logical(1))
        exact <- rep(identical_plan, each = 4L) & table$Status == "Available"
        J[exact, ] <- 0
        covariance <- J %*% C %*% t(J)
        rownames(covariance) <- colnames(covariance) <- paste(table$Scenario, table$Metric, sep = "/")
        variance <- diag(covariance)
        boundary <- rowSums(!is.finite(J)) > 0
        table$Status[table$Status == "Available" & boundary] <- "Interval unavailable at a boundary"
        table$Status[table$Status == "Available" & (!is.finite(variance) | variance <= 0) & !exact] <- "Nonpositive or nonfinite difference variance"
        ok <- table$Status == "Available"
        table$SE <- sqrt(ifelse(ok, variance, NA_real_))
        critical <- stats::qnorm((1 - level)/2, lower.tail = FALSE)
        table$Lower <- table$Difference - critical * table$SE
        table$Upper <- table$Difference + critical * table$SE
        return(structure(list(comparisons = table, covariance = covariance, design_grid = d$design_grid, 
            reference = as.integer(reference), score = selected, kind = kind, weights = w, level = level, 
            method = "Normal-theory paired delta approximation", source_design = g$design[c("method", 
                "counts", "rows", "complete", "balanced", "nesting", "score_convention")], source_rows = g$data_usage$counts, 
            component_diagnostics = d$component_diagnostics, sampling_covariance_psd = covariance_psd), 
            class = "mfrm_multivariate_d_comparison"))
    }
    controls <- fits[names(fits) %in% c("reference", "score", "composite", "assumption", "level")]
    if (any(!vapply(controls, inherits, logical(1), what = c("mfrm_fit", "mfrm_testlet", "mfrm_random_rater")))) 
        stop("Plan-comparison arguments require one D-study result.", call. = FALSE)
    for (fit in fits) stop_if_product_slopes(fit, "compare_mfrm()")
    if (any(vapply(fits, mfrm_extended_fit, logical(1)))) 
        return(mfrm_compare_extended(fits, labels, nested, response_diagnostics, person_scores))
    if (!is.null(response_diagnostics) || !is.null(person_scores)) 
        stop("Predictive or Person comparison currently requires one ordinary RSM MML and one testlet/shared-rater fit.", 
            call. = FALSE)
    if (length(fits) < 2) {
        stop("`compare_mfrm()` requires at least two `mfrm_fit` objects.", call. = FALSE)
    }
    for (i in seq_along(fits)) {
        if (!inherits(fits[[i]], "mfrm_fit")) {
            stop("Argument ", i, " is not an `mfrm_fit` object. Got: ", class(fits[[i]])[1], ".", call. = FALSE)
        }
    }
    if (is.null(labels)) {
        labels <- vapply(fits, function(f) {
            m <- if (!is.null(f$config$model)) 
                toupper(f$config$model[1])
            else "?"
            e <- if (!is.null(f$config$method)) 
                toupper(f$config$method[1])
            else "?"
            paste0(m, "/", e)
        }, character(1))
        if (anyDuplicated(labels)) {
            labels <- paste0(labels, " (", seq_along(labels), ")")
        }
    }
    if (length(labels) != length(fits)) {
        stop("`labels` must have the same length as the number of models (", length(fits), ").", call. = FALSE)
    }
    normalize_compare_col <- function(col) {
        if (is.factor(col)) 
            return(as.character(col))
        if (inherits(col, "POSIXt")) 
            return(format(col, tz = "UTC", usetz = TRUE))
        if (is.numeric(col)) 
            return(format(col, digits = 17, trim = TRUE, scientific = FALSE))
        if (is.logical(col)) 
            return(ifelse(is.na(col), "NA", ifelse(col, "TRUE", "FALSE")))
        if (is.character(col)) 
            return(col)
        as.character(col)
    }
    canonicalize_compare_data <- function(dat) {
        if (is.null(dat) || !is.data.frame(dat)) 
            return(NULL)
        dat <- as.data.frame(dat, stringsAsFactors = FALSE)
        dat <- dat[, sort(names(dat)), drop = FALSE]
        dat[] <- lapply(dat, normalize_compare_col)
        if (nrow(dat) > 0 && ncol(dat) > 0) {
            ord <- do.call(order, c(dat, list(na.last = TRUE, method = "radix")))
            dat <- dat[ord, , drop = FALSE]
        }
        rownames(dat) <- NULL
        dat
    }
    compare_data_equal <- function(fit_a, fit_b) {
        dat_a <- canonicalize_compare_data(fit_a$prep$data %||% NULL)
        dat_b <- canonicalize_compare_data(fit_b$prep$data %||% NULL)
        if (is.null(dat_a) || is.null(dat_b)) 
            return(FALSE)
        identical(dat_a, dat_b)
    }
    comparison_signatures <- lapply(fits, normalize_compare_signature)
    constraint_component_names <- c("person", "facets", "score", "rating_min", "rating_max", "score_map", 
        "noncenter_facet", "dummy_facets", "positive_facets", "anchors", "group_anchors", "centering_scope")
    constraint_components <- vapply(constraint_component_names, function(nm) {
        all(vapply(comparison_signatures[-1], function(sig) {
            same_signature_component(comparison_signatures[[1]][[nm]], sig[[nm]])
        }, logical(1)))
    }, logical(1))
    same_constraint_basis <- all(constraint_components)
    if (isTRUE(warn_constraints) && !same_constraint_basis) {
        mismatch <- names(constraint_components)[!constraint_components]
        if ("noncenter_facet" %in% mismatch) {
            noncenter <- vapply(comparison_signatures, function(sig) {
                as.character(sig$noncenter_facet[1])
            }, character(1))
            warning("Models use different centering constraints (", paste(unique(noncenter), collapse = ", "), 
                "). Information-criterion ranking is suppressed.", call. = FALSE)
        }
        if ("dummy_facets" %in% mismatch) {
            dummy_sigs <- vapply(comparison_signatures, function(sig) {
                paste(sig$dummy_facets, collapse = ",")
            }, character(1))
            warning("Models use different dummy-facet constraints (", paste(unique(dummy_sigs), collapse = " vs "), 
                "). Information-criterion ranking is suppressed.", call. = FALSE)
        }
        other_mismatch <- setdiff(mismatch, c("noncenter_facet", "dummy_facets"))
        if (length(other_mismatch) > 0L) {
            warning("Models differ in likelihood-basis coding or constraint settings: ", paste(other_mismatch, 
                collapse = ", "), ". Information-criterion ranking is suppressed.", call. = FALSE)
        }
    }
    rows <- lapply(seq_along(fits), function(i) {
        f <- fits[[i]]
        convergence <- mfrm_convergence_state(f)
        contract <- mfrm_extract_fit_ic_contract(f)
        ic_fit <- mfrm_ic_fit_check(f, contract)
        readiness <- mfrmr_get_readiness_record(f)$fit
        tibble::add_column(contract, Label = labels[i], Converged = convergence$code_converged, InferenceReady = convergence$inference_ready, 
            ICFitEligible = ic_fit$eligible, ICFitBasis = ic_fit$basis, ICFitReview = ic_fit$review, 
            ICFitCaution = ic_fit$caution %||% "", InferenceReview = if (convergence$inference_ready) 
                ""
            else as.character(mfrm_fit_decision_summary(readiness)$Why[1]), ReadinessReasonCodes = as.character(readiness$ReasonCodes[1]), 
            ConvergenceSeverity = convergence$severity, .before = 1L)
    })
    tbl <- bind_rows(rows)
    ic_cautions <- unique(tbl$ICFitCaution[nzchar(tbl$ICFitCaution)])
    if (length(ic_cautions)) 
        warning(paste(ic_cautions, collapse = " "), call. = FALSE)
    method_vals <- tbl$Method[!is.na(tbl$Method)]
    same_method <- length(unique(method_vals)) <= 1
    all_mml <- length(method_vals) > 0 && all(method_vals == "MML")
    obs_vals <- tbl$nobs[is.finite(tbl$nobs)]
    same_nobs <- length(unique(obs_vals)) <= 1
    same_data <- if (length(fits) >= 2) {
        all(vapply(fits[-1], function(f) compare_data_equal(fits[[1]], f), logical(1)))
    }
    else {
        TRUE
    }
    conv_vals <- tbl$InferenceReady
    all_converged <- length(conv_vals) > 0 && all(!is.na(conv_vals) & as.logical(conv_vals))
    all_ic_fit_eligible <- nrow(tbl) > 0L && all(!is.na(tbl$ICFitEligible) & tbl$ICFitEligible)
    ic_fit_review_reason <- if (!all_ic_fit_eligible) {
        pending <- which(is.na(tbl$ICFitEligible) | !tbl$ICFitEligible)
        paste0("IC solution checks are not satisfied: ", paste(paste0(labels[pending], ": ", tbl$ICFitReview[pending]), 
            collapse = "; "))
    }
    else ""
    inference_review_reason <- if (!all_converged) {
        pending <- which(is.na(conv_vals) | !as.logical(conv_vals))
        details <- vapply(pending, function(i) {
            paste0(labels[i], ": ", sub("[.]$", "", tbl$InferenceReview[i]))
        }, character(1))
        paste0("Inference readiness is not satisfied: ", paste(details, collapse = "; "), ".")
    }
    else {
        ""
    }
    all_current_contract <- nrow(tbl) > 0L && all(!is.na(tbl$ICContractVersion) & tbl$ICContractVersion == 
        .mfrmr_const_mfrm_ic_contract_version)
    all_stored_consistent <- nrow(tbl) > 0L && all(!is.na(tbl$StoredICConsistent) & tbl$StoredICConsistent)
    all_ic_eligible <- nrow(tbl) > 0L && all(!is.na(tbl$ICEligible) & tbl$ICEligible)
    all_ic_selectable <- nrow(tbl) > 0L && all(!is.na(tbl$ICSelectable) & tbl$ICSelectable) && all(!is.na(tbl$ICIntegrationSelectable) & 
        tbl$ICIntegrationSelectable)
    contract_vals <- tbl$ICContractVersion[!is.na(tbl$ICContractVersion)]
    same_contract <- length(contract_vals) > 0L && length(unique(contract_vals)) == 1L && identical(unique(contract_vals), 
        .mfrmr_const_mfrm_ic_contract_version)
    integration_vals <- tbl$IntegrationEvaluationId[!is.na(tbl$IntegrationEvaluationId) & nzchar(tbl$IntegrationEvaluationId)]
    same_integration <- length(integration_vals) == nrow(tbl) && length(unique(integration_vals)) == 
        1L
    same_formula <- length(unique(tbl$AICFormula)) == 1L && length(unique(tbl$BICFormula)) == 1L && length(unique(tbl$SABICFormula)) == 
        1L
    ic_comparable <- same_method && same_nobs && same_data && all_ic_fit_eligible && all_mml && all_current_contract && 
        all_stored_consistent && all_ic_eligible && all_ic_selectable && same_contract && same_integration && 
        same_formula && same_constraint_basis
    sabic_comparable <- ic_comparable && all(!is.na(tbl$SABICSelectable) & tbl$SABICSelectable)
    if (!isTRUE(nested)) {
        if (!same_method) {
            warning("Models use different estimation methods (", paste(unique(method_vals), collapse = ", "), 
                "). Canonical IC ranking, deltas, weights, ", "and automatic preferences are suppressed.", 
                call. = FALSE)
        }
        else if (!all_mml) {
            warning("Information-criterion ranking is limited to converged MML fits in this package. ", 
                "Legacy descriptive values remain separately labelled for ", paste(unique(method_vals), 
                  collapse = ", "), " models, but deltas, weights, automatic preferences, and LRT were suppressed.", 
                call. = FALSE)
        }
        if (!same_nobs) {
            warning("Models were fit to different numbers of observations (", paste(obs_vals, collapse = ", "), 
                "). Cross-sample deltas, weights, ", "and automatic preferences are suppressed.", call. = FALSE)
        }
        if (!same_data) {
            warning("Models were not fit to the same prepared response data. ", "Deltas, weights, automatic preferences, and likelihood-ratio testing were suppressed.", 
                call. = FALSE)
        }
        if (!all_ic_fit_eligible) {
            warning(ic_fit_review_reason, " ", "IC ranking, weights, and likelihood-ratio testing were suppressed.", 
                call. = FALSE)
        }
        if (!all_current_contract) {
            warning("At least one fit lacks current, complete information for comparing its information criteria. ", 
                "LegacyAIC/LegacyBIC remain descriptive, but canonical ranking was suppressed; ", "refit under the current package before comparison.", 
                call. = FALSE)
        }
        else if (!all_stored_consistent) {
            warning("At least one stored information-criterion value or identity does not match ", "the retained objective, parameter vector, prepared data, or integration setting. ", 
                "Canonical ranking was suppressed.", call. = FALSE)
        }
        if (all_mml && all_current_contract && !all_ic_eligible) {
            warning("At least one MML fit cannot be ranked by information criteria. ", "Check for non-unit observation weights or incomplete likelihood information.", 
                call. = FALSE)
        }
        if (all_mml && all_current_contract && all_ic_eligible && !all_ic_selectable) {
            warning("Information-criterion ranking is unavailable at the supplied ", "quadrature resolution. Raw criteria remain visible, but deltas, weights, preferences, and ", 
                "LRT are suppressed below q = 31. Refit every candidate with a common ", "q >= 31 grid and check a denser grid when the decision is close.", 
                call. = FALSE)
        }
        if (all_current_contract && all_mml && !same_integration) {
            warning("Models do not share one integration-evaluation identity. Refit or reevaluate ", 
                "all candidates with the same locked quadrature setting before IC ranking.", call. = FALSE)
        }
    }
    tbl$ICComparable <- ic_comparable
    tbl$SABICComparable <- sabic_comparable
    tbl$ConstraintComparable <- same_constraint_basis
    preferred <- list()
    if (ic_comparable && any(is.finite(tbl$AIC))) {
        min_aic <- min(tbl$AIC, na.rm = TRUE)
        tbl$Delta_AIC <- tbl$AIC - min_aic
        raw_w <- exp(-0.5 * tbl$Delta_AIC)
        tbl$AkaikeWeight <- ifelse(is.finite(raw_w), raw_w/sum(raw_w, na.rm = TRUE), NA_real_)
        preferred$AIC <- tbl$Label[which.min(tbl$AIC)]
    }
    else {
        tbl$Delta_AIC <- NA_real_
        tbl$AkaikeWeight <- NA_real_
    }
    if (ic_comparable && any(is.finite(tbl$BIC))) {
        min_bic <- min(tbl$BIC, na.rm = TRUE)
        tbl$Delta_BIC <- tbl$BIC - min_bic
        raw_bw <- exp(-0.5 * tbl$Delta_BIC)
        tbl$BICWeight <- ifelse(is.finite(raw_bw), raw_bw/sum(raw_bw, na.rm = TRUE), NA_real_)
        preferred$BIC <- tbl$Label[which.min(tbl$BIC)]
    }
    else {
        tbl$Delta_BIC <- NA_real_
        tbl$BICWeight <- NA_real_
    }
    if (sabic_comparable && any(is.finite(tbl$SABIC))) {
        min_sabic <- min(tbl$SABIC, na.rm = TRUE)
        tbl$Delta_SABIC <- tbl$SABIC - min_sabic
        raw_sw <- exp(-0.5 * tbl$Delta_SABIC)
        tbl$SABICWeight <- ifelse(is.finite(raw_sw), raw_sw/sum(raw_sw, na.rm = TRUE), NA_real_)
        preferred$SABIC <- tbl$Label[which.min(tbl$SABIC)]
    }
    else {
        tbl$Delta_SABIC <- NA_real_
        tbl$SABICWeight <- NA_real_
    }
    lrt <- NULL
    lrt_status <- if (isTRUE(nested)) 
        "requested"
    else "not_requested"
    lrt_reason <- if (isTRUE(nested)) {
        "Likelihood-ratio test was requested but not yet evaluated."
    }
    else {
        "Likelihood-ratio test was not requested; set `nested = TRUE` only for supported nested comparisons."
    }
    nesting_review <- audit_compare_mfrm_nesting(fits, labels = labels)
    pcm_gpcm_regular <- isTRUE(nesting_review$eligible) && identical(nesting_review$relation, "PCM_in_GPCM") && 
        all_ic_fit_eligible
    mml_regular_nested <- pcm_gpcm_regular || (all_mml && all_ic_fit_eligible && all(vapply(fits, function(f) isTRUE(f$config$population_spec$active), 
        logical(1))))
    if (isTRUE(nested)) {
        if (length(fits) != 2L) {
            lrt_status <- "not_computed"
            lrt_reason <- "Likelihood-ratio testing requires exactly two fitted models."
            warning("`nested = TRUE` was requested, but LRT requires exactly two fitted models. LRT was not computed.", 
                call. = FALSE)
        }
        else if (!ic_comparable || (!all_converged && !mml_regular_nested)) {
            lrt_status <- "not_computed"
            lrt_reason <- paste("Not all comparison requirements are satisfied: formal MML likelihood basis,", 
                "verified information criteria, common response data, constraints and", "integration settings, and adequate support for inference.")
            if (!all_ic_fit_eligible) 
                lrt_reason <- paste(lrt_reason, ic_fit_review_reason)
            if (!all_converged && !mml_regular_nested) 
                lrt_reason <- paste(lrt_reason, inference_review_reason)
            warning("`nested = TRUE` was requested. ", lrt_reason, " LRT was not computed.", call. = FALSE)
        }
        else if (!isTRUE(nesting_review$eligible)) {
            lrt_status <- "not_computed"
            lrt_reason <- paste0("Structural nesting review did not pass: ", nesting_review$reason)
            warning("`nested = TRUE` was requested, but the structural nesting review did not pass. ", 
                nesting_review$reason, " LRT was not computed.", call. = FALSE)
        }
        else {
            ll <- tbl$LogLik
            np <- tbl$npar
            if (!all(is.finite(ll)) || !all(is.finite(np))) {
                lrt_status <- "not_computed"
                lrt_reason <- "Log-likelihoods or parameter counts were non-finite."
                warning("`nested = TRUE` was requested, but at least one log-likelihood or parameter count was non-finite. LRT was not computed.", 
                  call. = FALSE)
            }
            else if (np[1] == np[2]) {
                lrt_status <- "not_computed"
                lrt_reason <- "Compared models have the same number of free parameters."
                warning("`nested = TRUE` was requested, but the compared models have the same number of free parameters. LRT was not computed.", 
                  call. = FALSE)
            }
            else {
                idx_simple <- if (!is.null(nesting_review$simpler_index)) {
                  as.integer(nesting_review$simpler_index)
                }
                else if (pcm_gpcm_regular) {
                  which(tbl$Model == "PCM")[1L]
                }
                else {
                  which.min(np)
                }
                idx_complex <- if (!is.null(nesting_review$complex_index)) {
                  as.integer(nesting_review$complex_index)
                }
                else if (pcm_gpcm_regular) {
                  which(tbl$Model == "GPCM")[1L]
                }
                else {
                  which.max(np)
                }
                chi_sq <- 2 * (ll[idx_complex] - ll[idx_simple])
                df_diff <- np[idx_complex] - np[idx_simple]
                df_verified <- is.null(nesting_review$df) || identical(as.numeric(df_diff), as.numeric(nesting_review$df))
                if (is.finite(chi_sq) && chi_sq >= 0 && df_diff > 0 && df_verified) {
                  p_val <- stats::pchisq(chi_sq, df = df_diff, lower.tail = FALSE)
                  lrt <- tibble(Simple = tbl$Label[idx_simple], Complex = tbl$Label[idx_complex], ChiSq = chi_sq, 
                    df = df_diff, p_value = p_val, ReferenceDistribution = "asymptotic_chi_square", Interpretation = "nested_fit_evidence_not_practical_preference")
                  lrt_status <- "computed"
                  lrt_reason <- paste("Likelihood-ratio test computed after the structural nesting review passed;", 
                    "the chi-square reference is asymptotic and assumes independent Persons,", "a correctly specified population/response model and regular interior solutions.", 
                    "Check starting-value and integration sensitivity; the p-value is not an automatic practical model preference.")
                }
                else {
                  lrt_status <- "not_computed"
                  lrt_reason <- if (!is.finite(chi_sq) || !is.finite(df_diff)) {
                    "Likelihood-ratio statistic or parameter-count difference was non-finite."
                  }
                  else if (!df_verified) {
                    "The parameter-count difference does not equal the verified number of null restrictions."
                  }
                  else if (df_diff <= 0) {
                    "Parameter-count difference was not positive."
                  }
                  else {
                    "The more complex model had a lower log-likelihood, producing a negative likelihood-ratio statistic."
                  }
                  warning("`nested = TRUE` was requested, but the LRT statistic was not interpretable. ", 
                    lrt_reason, " LRT was not computed.", call. = FALSE)
                }
            }
        }
    }
    if (isTRUE(nested) && length(ic_cautions)) {
        lrt_reason <- paste(lrt_reason, paste(ic_cautions, collapse = " "))
    }
    evidence_ratios <- NULL
    if (ic_comparable && "AkaikeWeight" %in% names(tbl) && nrow(tbl) >= 2) {
        er_rows <- list()
        for (i in 1:(nrow(tbl) - 1)) {
            for (j in (i + 1):nrow(tbl)) {
                log_er <- (tbl$AIC[j] - tbl$AIC[i])/2
                if (!is.finite(log_er)) 
                  log_er <- tbl$AIC[j]/2 - tbl$AIC[i]/2
                er <- exp(log_er)
                ratio_reason <- if (!is.finite(log_er)) 
                  "nonfinite_difference"
                else if (!is.finite(er)) 
                  "overflow"
                else if (er == 0) 
                  "underflow"
                else "available"
                if (ratio_reason != "available") 
                  er <- NA_real_
                er_rows[[length(er_rows) + 1]] <- tibble(Model1 = tbl$Label[i], Model2 = tbl$Label[j], 
                  EvidenceRatio = er, LogEvidenceRatio = log_er, RatioReason = ratio_reason)
            }
        }
        evidence_ratios <- bind_rows(er_rows)
    }
    comparison_basis <- list(same_method = same_method, all_mml = all_mml, same_nobs = same_nobs, same_data = same_data, 
        all_inference_ready = all_converged, all_ic_fit_eligible = all_ic_fit_eligible, all_converged = all_converged, 
        all_current_contract = all_current_contract, all_stored_ic_consistent = all_stored_consistent, 
        all_ic_eligible = all_ic_eligible, all_ic_selectable = all_ic_selectable, same_ic_contract = same_contract, 
        same_integration_evaluation = same_integration, same_formula_contract = same_formula, same_constraint_basis = same_constraint_basis, 
        constraint_components = constraint_components, ic_comparable = ic_comparable, sabic_comparable = sabic_comparable, 
        nested_requested = isTRUE(nested), nesting_review = nesting_review, lrt_status = lrt_status, 
        lrt_reason = lrt_reason)
    out <- list(table = tbl, lrt = lrt, evidence_ratios = evidence_ratios, preferred = preferred, comparison_basis = comparison_basis)
    class(out) <- c("mfrm_comparison", class(out))
    out
}

summary.mfrm_comparison <- function(object, ...) {
    out <- list(table = object$table, lrt = object$lrt, evidence_ratios = object$evidence_ratios, preferred = object$preferred, 
        comparison_basis = object$comparison_basis)
    class(out) <- "summary.mfrm_comparison"
    out
}


print.mfrm_comparison <- function(x, ...) {
    print(summary(x))
    invisible(x)
}
