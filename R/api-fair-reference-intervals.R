confint.mfrm_fair_average <- function(object, parm = NULL, level = 0.95, nsim, seed, contrasts = NULL, 
    anchor_source = NULL, generating_fit = NULL, response_map = NULL, anchor_uncertainty = c("estimated", 
        "fixed"), gradient_tol = 1e-04, method = c("refit", "delta", "bounded"), generator_method = c("ordinary", 
        "jeffreys"), mc_level = 0.95, ...) {
    rlang::check_dots_empty()
    anchor_uncertainty_supplied <- !missing(anchor_uncertainty)
    anchor_uncertainty <- match.arg(anchor_uncertainty)
    method <- match.arg(method)
    generator_method_supplied <- !missing(generator_method)
    if (method != "refit" && !missing(generator_method)) 
        stop("`generator_method` applies only to method = 'refit'.", call. = FALSE)
    generator_method <- match.arg(generator_method)
    scalar <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x)
    if (!scalar(level) || level <= 0 || level >= 1) 
        stop("`level` must be in (0, 1).", call. = FALSE)
    if (method != "refit" && !missing(mc_level)) 
        stop("`mc_level` applies only to method = 'refit'.", call. = FALSE)
    if (!scalar(mc_level) || mc_level <= 0 || mc_level >= 1) 
        stop("`mc_level` must be in (0, 1).", call. = FALSE)
    if (method == "refit" && (missing(nsim) || !scalar(nsim) || nsim < 2 || nsim != floor(nsim) || nsim > 
        .Machine$integer.max)) 
        stop("Supply an integer `nsim` of at least two.", call. = FALSE)
    if (method == "refit" && (missing(seed) || !scalar(seed) || seed < 0 || seed != floor(seed) || seed > 
        .Machine$integer.max)) 
        stop("Supply a nonnegative integer `seed`.", call. = FALSE)
    if (method != "refit" && (!missing(nsim) || !missing(seed))) 
        stop("`nsim` and `seed` apply only to method = 'refit'; omit them for deterministic intervals.", 
            call. = FALSE)
    if (!scalar(gradient_tol) || gradient_tol <= 0) 
        stop("`gradient_tol` must be positive.", call. = FALSE)
    fit <- object$reference_fit
    plan <- object$reference_plan
    if (is.null(fit) || is.null(plan)) 
        stop("Recreate fair_average_table() with an explicit reference_plan.", call. = FALSE)
    mfrm_fair_reference_fit(fit)
    penalized <- mfrm_is_jeffreys_fit(fit)
    if (penalized && method == "refit") {
        if (generator_method_supplied && generator_method != "jeffreys") 
            stop("Jeffreys point/refit estimation requires generator_method = 'jeffreys'.", call. = FALSE)
        generator_method <- "jeffreys"
    }
    if (!identical(object$reference_identity, mfrm_fair_fit_identity(fit))) 
        stop("The retained reference fit changed; recreate fair_average_table().", call. = FALSE)
    plan <- mfrm_fair_reference_plan(fit, plan[setdiff(names(plan), "NormalizedWeight")])
    scores <- mfrm_fair_reference_scores(fit, plan)
    if (!isTRUE(all.equal(scores, object$reference_scores, tolerance = 1e-12))) 
        stop("The retained reference plan or scores changed; recreate fair_average_table().", call. = FALSE)
    if (is.null(parm)) 
        parm <- scores$Person
    if (!is.character(parm) || !length(parm) || anyNA(parm) || anyDuplicated(parm) || any(!parm %in% 
        scores$Person)) 
        stop("`parm` must select distinct known Person identifiers.", call. = FALSE)
    if (is.null(contrasts)) {
        L <- diag(length(parm))
        dimnames(L) <- list(parm, parm)
    }
    else {
        if (!is.matrix(contrasts) || !is.numeric(contrasts) || !nrow(contrasts) || any(!is.finite(contrasts)) || 
            is.null(rownames(contrasts)) || anyNA(rownames(contrasts)) || any(!nzchar(rownames(contrasts))) || 
            anyDuplicated(rownames(contrasts)) || anyDuplicated(colnames(contrasts)) || !setequal(colnames(contrasts), 
            parm) || any(abs(rowSums(contrasts)) > 1e-12 * pmax(1, rowSums(abs(contrasts)))) || any(rowSums(abs(contrasts)) == 
            0)) 
            stop("`contrasts` needs finite nonzero, zero-sum rows and unique row/Person column names.", 
                call. = FALSE)
        L <- contrasts[, parm, drop = FALSE]
    }
    selected <- scores$Estimate[match(parm, scores$Person)]
    estimate <- vapply(seq_len(nrow(L)), function(i) {
        use <- L[i, ] != 0
        sum(L[i, use] * selected[use])
    }, 0)
    if (method == "bounded") {
        if (!is.null(anchor_source) || !is.null(generating_fit) || !is.null(response_map) || anchor_uncertainty_supplied || 
            !missing(gradient_tol)) 
            stop("Bounded-response intervals use scoring responses directly; omit calibration/generator inputs, anchor_uncertainty and gradient_tol.", 
                call. = FALSE)
        return(mfrm_fair_bounded_result(fit, plan, parm, L, estimate, level, has_contrasts = !is.null(contrasts)))
    }
    anchors <- fit$config$replay_inputs$anchors
    two_stage <- nrow(anchors) > 0L && anchor_uncertainty == "estimated"
    if (two_stage && is.null(anchor_source)) 
        stop("Estimated-anchor intervals are unavailable without the calibration fit and response-event maps. Use anchor_uncertainty = 'fixed' only for explicitly conditional inference.", 
            call. = FALSE)
    if (!two_stage && (!is.null(anchor_source) || !is.null(response_map) || !is.null(generating_fit))) 
        stop("Separate calibration/generator inputs require estimated anchors.", call. = FALSE)
    generator <- generating_fit %||% (if (two_stage) 
        anchor_source
    else fit)
    sources <- if (two_stage) 
        list(scoring = fit, calibration = anchor_source, generating = generator)
    else list(scoring = fit)
    source_checks <- lapply(sources, function(f) {
        mfrm_fair_reference_fit(f)
        if (!identical(mfrm_is_jeffreys_fit(f), penalized)) 
            stop("Calibration, scoring and generating sources must use the same estimator; ordinary and Jeffreys points cannot be mixed.", 
                call. = FALSE)
        replay <- f$config$replay_inputs
        if (is.null(replay) || any(f$prep$data$Weight != 1) || nrow(replay$group_anchors %||% data.frame()) || 
            !identical(as.numeric(f$prep$score_map$OriginalScore), as.numeric(f$prep$score_map$InternalScore))) 
            stop("Common-plan intervals require replay inputs, unit weights, identity score coding and no group anchors.", 
                call. = FALSE)
        keys <- c("model", "n_cat", "rating_min", "rating_max", "facet_names", "facet_signs", "step_facet", 
            "dummy_facets")
        if (!isTRUE(all.equal(f$config[keys], fit$config[keys], check.attributes = FALSE))) 
            stop("Calibration, scoring and generating models/coding must agree.", call. = FALSE)
        mfrm_fair_refit_check(f, gradient_tol)
    })
    if (two_stage) {
        if (nrow(anchor_source$config$replay_inputs$anchors)) 
            stop("The initial two-stage route requires an unanchored calibration source.", call. = FALSE)
        values <- mfrm_fair_anchor_values(anchor_source, anchors)
        if (any(abs(values - anchors$Anchor) > 1e-10 * pmax(1, abs(values)))) 
            stop("Scoring anchors do not match the unrounded calibration estimates.", call. = FALSE)
        if (!is.list(response_map) || !setequal(names(response_map), c("calibration", "scoring"))) 
            stop("Provide explicit calibration/scoring response-event row maps.", call. = FALSE)
        maps <- list(calibration = mfrm_fair_response_map(anchor_source, generator, response_map$calibration, 
            "response_map$calibration"), scoring = mfrm_fair_response_map(fit, generator, response_map$scoring, 
            "response_map$scoring"))
        if (!setequal(unlist(maps), seq_len(nrow(generator$prep$data)))) 
            stop("The response maps must cover the generating fit's union of events.", call. = FALSE)
    }
    else maps <- list(scoring = seq_len(nrow(fit$prep$data)))
    generator_theta <- generator$facets$person$PrimaryEstimate %||% generator$facets$person$Estimate
    generating_model <- if (penalized) 
        c(generator$checks, list(par = generator$opt$par, probabilities = mfrm_fair_generator_probs(generator), 
            parameter_map = generator$parameter_map))
    else if (generator_method == "jeffreys") 
        mfrm_fair_jeffreys_generator(generator, gradient_tol)
    else NULL
    probs <- if (!is.null(generating_model)) 
        generating_model$probabilities
    else if (method == "delta" && any(!is.finite(generator_theta))) 
        NULL
    else mfrm_fair_generator_probs(generator)
    if (!is.null(probs) && (any(!is.finite(probs)) || any(probs < 0) || any(abs(rowSums(probs) - 1) > 
        1e-10))) 
        stop("Invalid generating probabilities.", call. = FALSE)
    truth_scores <- if (!is.null(generating_model)) 
        mfrm_fair_jeffreys_target(generator, generating_model$par, plan, parm)
    else {
        tab <- mfrm_fair_reference_scores(generator, plan)
        tab$Estimate[match(parm, tab$Person)]
    }
    truth <- drop(L %*% truth_scores)
    allowed_status <- if (generator_method == "jeffreys") 
        c("point_estimate", "boundary_limit")
    else "point_estimate"
    if (any(!is.finite(truth)) || any(!is.finite(estimate)) || any(!scores$Status[match(parm, scores$Person)] %in% 
        allowed_status)) 
        stop("Selected targets require finite primary point estimates and generating targets.", call. = FALSE)
    if (method == "delta") 
        return(mfrm_fair_delta_result(fit, if (two_stage) anchor_source else NULL, generator, plan, parm, 
            L, estimate, truth, anchors, maps, probs, level, gradient_tol, anchor_uncertainty, sources, 
            source_checks, has_contrasts = !is.null(contrasts)))
    draws <- matrix(NA_real_, nsim, nrow(L), dimnames = list(NULL, rownames(L)))
    person_draws <- matrix(NA_real_, nsim, length(parm), dimnames = list(NULL, parm))
    anchor_draws <- matrix(NA_real_, nsim, nrow(anchors), dimnames = list(NULL, if (nrow(anchors)) paste(anchors$Facet, 
        anchors$Level, sep = ":") else NULL))
    trials <- data.frame(Replication = seq_len(nsim), CalibrationGradient = NA_real_, ScoringGradient = NA_real_, 
        BoundaryPersons = NA_integer_, Available = FALSE, Reason = "", Warnings = "", Seconds = NA_real_)
    rng_kind <- RNGkind()
    with_preserved_rng_seed(seed, {
        cumulative <- t(apply(probs, 1L, cumsum))
        for (b in seq_len(nsim)) {
            started <- proc.time()[[3]]
            messages <- character()
            result <- tryCatch(withCallingHandlers({
                u <- stats::runif(nrow(probs))
                y <- pmin(rowSums(u > cumulative), ncol(probs) - 1L) + generator$prep$rating_min
                a <- anchors
                if (two_stage) {
                  calibration <- mfrm_fair_refit(anchor_source, y[maps$calibration])
                  check <- mfrm_fair_refit_check(calibration, gradient_tol)
                  trials$CalibrationGradient[b] <- check$max_gradient
                  a$Anchor <- mfrm_fair_anchor_values(calibration, anchors)
                }
                if (nrow(a)) 
                  anchor_draws[b, ] <- a$Anchor
                scored <- mfrm_fair_refit(fit, y[maps$scoring], a)
                check <- mfrm_fair_refit_check(scored, gradient_tol)
                trials$ScoringGradient[b] <- check$max_gradient
                s <- mfrm_fair_reference_scores(scored, plan)
                v <- s$Estimate[match(parm, s$Person)]
                status <- s$Status[match(parm, s$Person)]
                trials$BoundaryPersons[b] <- sum(status == "boundary_limit")
                v[!status %in% c("point_estimate", "boundary_limit")] <- NA_real_
                person_draws[b, ] <- v
                draws[b, ] <- vapply(seq_len(nrow(L)), function(j) {
                  use <- L[j, ] != 0
                  sum(L[j, use] * v[use])
                }, 0)
                if (all(is.finite(draws[b, ]))) 
                  ""
                else "Selected Person expected score unavailable."
            }, warning = function(w) {
                messages <<- c(messages, conditionMessage(w))
                invokeRestart("muffleWarning")
            }), error = function(e) conditionMessage(e))
            trials$Available[b] <- all(is.finite(draws[b, ]))
            trials$Reason[b] <- result
            trials$Warnings[b] <- paste(unique(messages), collapse = " | ")
            trials$Seconds[b] <- proc.time()[[3]] - started
        }
    })
    bounds <- mfrm_fair_bootstrap_bounds(estimate, truth, draws, level)
    mc <- mfrm_fair_bootstrap_mc(estimate, bounds$roots, level, mc_level)
    mc_lower <- mc[mc$Endpoint == "lower", ]
    mc_upper <- mc[mc$Endpoint == "upper", ]
    available <- is.finite(bounds$lower) & is.finite(bounds$upper)
    out <- data.frame(Target = rownames(L), Estimate = unname(estimate), CI_Lower = ifelse(available, 
        bounds$lower, NA_real_), CI_Upper = ifelse(available, bounds$upper, NA_real_), Level = level, 
        Available = available, Status = ifelse(available, "experimental", "unresolved_tail"), Planned = nsim, 
        Resolved = bounds$available, Unresolved = nsim - bounds$available, ExpectedTailDraws = nsim * 
            (1 - level)/2, CIEligible = FALSE, LowerMCLower = mc_lower$Lower, LowerMCUpper = mc_lower$Upper, 
        UpperMCLower = mc_upper$Lower, UpperMCUpper = mc_upper$Upper, MCLevel = mc_level, MCFinite = is.finite(mc_lower$Lower) & 
            is.finite(mc_lower$Upper) & is.finite(mc_upper$Lower) & is.finite(mc_upper$Upper), Uncertainty = if (two_stage) 
            "calibration_and_scoring_refit"
        else if (nrow(anchors)) 
            "scoring_refit_conditional_on_fixed_anchors"
        else "joint_calibration_and_person_refit", InferenceReview = "Experimental pointwise fitted-model approximation; finite-sample coverage and JML bias remain unqualified.", 
        row.names = NULL)
    if (generator_method == "jeffreys") 
        out$InferenceReview <- paste(out$InferenceReview, if (penalized) 
            "Jeffreys estimation throughout original calibration, scoring and refits; this is not ordinary FACETS JML."
        else "Jeffreys generating model; the reported point and refits remain ordinary JML.")
    if (penalized) 
        out$InferenceReview <- paste(out$InferenceReview, "Basic refit limits can substantially under-cover in small samples even with exact refit quantiles; see help.")
    attr(out, "draws") <- draws
    attr(out, "person_draws") <- person_draws
    attr(out, "monte_carlo") <- mc
    attr(out, "anchor_draws") <- anchor_draws
    attr(out, "trials") <- trials
    attr(out, "generating_target") <- setNames(truth, rownames(L))
    if (!is.null(generating_model)) 
        attr(out, "generating_model") <- generating_model
    attr(out, "reference_plan") <- plan
    attr(out, "response_map") <- maps
    attr(out, "source_checks") <- source_checks
    attr(out, "source_identity") <- lapply(sources, mfrm_fair_fit_identity)
    attr(out, "settings") <- list(parm = parm, contrasts = L, level = level, nsim = nsim, seed = seed, 
        rng_kind = rng_kind, gradient_tol = gradient_tol, mc_level = mc_level, anchor_uncertainty = anchor_uncertainty, 
        anchors = anchors, method = "basic_fixed_person_parametric_refit", generator_method = generator_method, 
        estimator = if (penalized) "jeffreys_canonical_joint" else "ordinary_jml", quantile_type = 1L, 
        target = if (is.null(contrasts)) "common_plan_expected_average" else "common_plan_expected_average_contrast", 
        shared_responses = if (two_stage) length(intersect(maps$calibration, maps$scoring)) else 0L)
    class(out) <- c("mfrm_fair_intervals", "data.frame")
    out
}
