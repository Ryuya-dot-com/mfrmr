mfrm_facet_rating_support <- function(fit, include_person = FALSE) {
    prep <- fit$prep
    d <- prep$data
    notes <- c("Ratings count retained rows without weighting; Persons count distinct recorded Person IDs, not effective sample sizes.", 
        "Ratings per Person refer only to the named facet level. Crossing counts describe other facets separately, not joint connectivity or identification.", 
        "Category counts include unused declared categories. Counts, count bands and numerical convergence do not establish precision or interval coverage.")
    empty <- list(table = data.frame(), crossings = data.frame(), categories = data.frame(), notes = notes)
    facets <- unique(c(if (include_person) "Person", prep$facet_names))
    if (!is.data.frame(d) || !nrow(d) || !all(c("Person", facets) %in% names(d))) {
        empty$notes <- c("Stored rating-level data are unavailable; counts were not reconstructed.", 
            notes)
        return(empty)
    }
    if (anyNA(d[unique(c("Person", facets))])) 
        stop("Stored Person and facet IDs must be observed to count rating support.", call. = FALSE)
    basis <- if (is.null(fit$config$gpcm_limit_source)) 
        "full_model"
    else "limiting_likelihood"
    map <- prep$score_map
    categories_available <- "score_k" %in% names(d) && is.data.frame(map) && all(c("InternalScore", "OriginalScore") %in% 
        names(map)) && nrow(map) > 0L && length(prep$rating_min) == 1L && is.finite(prep$rating_min)
    rows <- crossings <- categories <- list()
    for (facet in facets) {
        groups <- split(seq_len(nrow(d)), as.character(d[[facet]]), drop = TRUE)
        for (level in names(groups)) {
            ids <- groups[[level]]
            per_person <- tabulate(match(d$Person[ids], unique(d$Person[ids])))
            rows[[length(rows) + 1L]] <- data.frame(DataBasis = basis, Facet = facet, Level = level, 
                Ratings = length(ids), Persons = length(per_person), MinRatingsPerPerson = min(per_person), 
                MedianRatingsPerPerson = stats::median(per_person), MaxRatingsPerPerson = max(per_person), 
                ObservedCategories = if (categories_available) 
                  length(unique(d$score_k[ids]))
                else NA_integer_, DeclaredCategories = if (categories_available) 
                  nrow(map)
                else NA_integer_)
            for (other in setdiff(prep$facet_names, facet)) {
                crossings[[length(crossings) + 1L]] <- data.frame(DataBasis = basis, Facet = facet, Level = level, 
                  OtherFacet = other, ObservedLevels = length(unique(d[[other]][ids])), RetainedLevels = length(unique(d[[other]])))
            }
            if (categories_available) {
                ix <- match(d$score_k[ids], map$InternalScore - prep$rating_min)
                if (anyNA(ix)) 
                  stop("Stored rating categories do not match the score map.", call. = FALSE)
                categories[[length(categories) + 1L]] <- data.frame(DataBasis = basis, Facet = facet, 
                  Level = level, Score = map$OriginalScore, Ratings = tabulate(ix, nbins = nrow(map)))
            }
        }
    }
    list(table = dplyr::bind_rows(rows), crossings = dplyr::bind_rows(crossings), categories = dplyr::bind_rows(categories), 
        notes = if (categories_available) notes else c("Stored category coding is unavailable; category counts remain unavailable.", 
            notes))
}


mfrm_prepare_variance_data <- function(data, groups, score, needed_cols, missing, source, gstudy = FALSE) {
    group_label <- if (gstudy) 
        "Facet"
    else "Grouping column"
    score_label <- if (gstudy) 
        "`Score`"
    else "The score column"
    for (col in groups) {
        value <- data[[col]]
        if (!is.null(dim(value)) || !(is.factor(value) || (!is.object(value) && (is.character(value) || 
            is.logical(value) || (is.numeric(value) && !is.complex(value))))) || (is.numeric(value) && 
            any(is.infinite(value)))) {
            stop(group_label, " '", col, "' must contain finite numeric, character, factor, or logical labels, or NA.", 
                call. = FALSE)
        }
        if (any(!is.na(value) & !nzchar(trimws(as.character(value))))) {
            stop(group_label, " '", col, "' contains blank labels; use NA for missing values.", call. = FALSE)
        }
        if (!is.factor(data[[col]])) {
            labels <- as.character(value)
            labels[is.na(value)] <- NA_character_
            data[[col]] <- as.factor(labels)
        }
    }
    value <- data[[score]]
    if (!is.null(dim(value)) || !(is.factor(value) || (!is.object(value) && (is.character(value) || (is.numeric(value) && 
        !is.complex(value)))))) {
        stop(score_label, " must be numeric or numeric character/factor labels, with NA for missing values.", 
            call. = FALSE)
    }
    data[[score]] <- suppressWarnings(as.numeric(if (is.factor(value)) as.character(value) else value))
    if (any(!is.na(value) & !is.finite(data[[score]]))) {
        stop(score_label, " contains nonnumeric or infinite values; correct them explicitly and use NA for missing values.", 
            call. = FALSE)
    }
    absent <- is.na(data[, needed_cols, drop = FALSE])
    keep <- rowSums(absent) == 0L
    cells <- which(absent, arr.ind = TRUE)
    data_usage <- list(source = source, missing = missing, counts = c(InputRows = nrow(data), UsedRows = sum(keep), 
        ExcludedRows = sum(!keep)), excluded_rows = which(!keep), missing_cells = data.frame(InputRow = cells[, 
        1L], Column = needed_cols[cells[, 2L]], row.names = NULL))
    if (any(!keep) && missing == "error") {
        stop(sum(!keep), " row(s) have missing ", if (gstudy) 
            "Score or selected facet values"
        else "scores or selected grouping values", ". Review the data or choose missing = 'omit' explicitly.", 
            call. = FALSE)
    }
    if (!any(keep)) {
        stop(if (gstudy) 
            "No complete rows remain for the G-study."
        else "No complete rows remain for the ICC model.", call. = FALSE)
    }
    list(data = data[keep, , drop = FALSE], data_usage = data_usage)
}










