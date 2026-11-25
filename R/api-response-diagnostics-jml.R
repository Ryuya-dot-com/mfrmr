mfrm_jml_response_input <- function(fit) {
    if (!mfrm_has_jml_adjustment(fit) || !isTRUE(fit$jml_adjustment$point$available)) 
        stop("Corrected-JML response diagnostics require an unambiguous saved point solution.", call. = FALSE)
    cfg <- fit$config
    d <- fit$prep$data
    columns <- cfg$source_columns
    data <- as.data.frame(d[c("Person", cfg$facet_names, "Score")])
    names(data) <- c(columns$person, cfg$facet_names, columns$score)
    data[setdiff(names(data), columns$score)] <- lapply(data[setdiff(names(data), columns$score)], as.character)
    rownames(data) <- NULL
    theta <- fit$facets$person$Estimate[match(as.character(d$Person), fit$facets$person$Person)]
    offset <- rep(0, nrow(d))
    for (f in cfg$facet_names) {
        tab <- fit$facets$others[fit$facets$others$Facet == f, , drop = FALSE]
        if (anyDuplicated(tab$Level)) 
            stop("Saved facet levels are duplicated.", call. = FALSE)
        offset <- offset + tab$Estimate[match(as.character(d[[f]]), tab$Level)]
    }
    owners <- as.character(fit$slopes$SlopeFacet)
    slopes <- fit$slopes$Estimate
    ns <- cfg$n_cat - 1L
    steps <- t(vapply(owners, function(id) {
        tab <- fit$steps[fit$steps$StepFacet == id, , drop = FALSE]
        order <- match(paste0("Step_", seq_len(ns)), tab$Step)
        if (nrow(tab) != ns || anyDuplicated(tab$Step) || anyNA(order)) 
            stop("Saved category steps do not match the declared ladder.", call. = FALSE)
        tab <- tab[order, , drop = FALSE]
        c(0, cumsum(tab$Estimate))
    }, numeric(ns + 1L)))
    owner <- match(as.character(d[[cfg$step_facet]]), owners)
    if (anyDuplicated(owners) || anyNA(owner) || anyNA(theta) || any(!is.finite(offset)) || any(!is.finite(steps)) || 
        any(!is.finite(slopes) | slopes <= 0)) 
        stop("Saved corrected-JML locations, steps, slopes or Person profiles are unavailable.", call. = FALSE)
    list(data = data, columns = columns, score_levels = seq(cfg$rating_min, cfg$rating_max), eta = theta - 
        offset, theta = theta, step_cum = steps, owner = owner, slopes = slopes)
}
