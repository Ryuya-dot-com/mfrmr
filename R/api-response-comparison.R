mfrm_compare_responses <- function(fits, diagnostics, columns) {
    if (!is.list(diagnostics) || length(diagnostics) != 2L) 
        stop("`response_diagnostics` must be a list of two saved results in fit order.", call. = FALSE)
    for (i in 1:2) mfrm_validate_response_diagnostics(fits[[i]], diagnostics[[i]])
    a <- diagnostics[[1L]]
    b <- diagnostics[[2L]]
    if (!identical(a$settings$target, b$settings$target) || !identical(a$settings$calibration_uncertainty, 
        FALSE) || !identical(b$settings$calibration_uncertainty, FALSE) || !identical(colnames(a$probabilities), 
        colnames(b$probabilities))) 
        stop("Response diagnostics must use the same posterior predictive target and categories with calibration fixed.", 
            call. = FALSE)
    if (!setequal(a$settings$group_by, b$settings$group_by) || !all(a$settings$group_by %in% columns)) 
        stop("Choose the same group_by identifier columns, present in both fitted models.", call. = FALSE)
    events <- lapply(diagnostics, function(d) d$source_data[d$rows$InputRow, columns, drop = FALSE])
    if (!identical(mfrm_compare_events(events[[1]], columns), mfrm_compare_events(events[[2]], columns))) 
        stop("Selected rating events differ; select the same events and repeated-event multiplicities in both diagnostics.", 
            call. = FALSE)
    order_events <- function(d) do.call(order, c(lapply(d, as.character), list(na.last = TRUE, method = "radix")))
    indices <- lapply(events, order_events)
    events <- events[[1]][indices[[1]], , drop = FALSE]
    rownames(events) <- NULL
    r <- a$rows[indices[[1]], , drop = FALSE]
    s <- b$rows[indices[[2]], , drop = FALSE]
    available <- r$Status == "available_conditional" & s$Status == "available_conditional"
    status <- ifelse(available, "available_descriptive", ifelse(is.na(r$Score), "missing_score", "unavailable"))
    reason <- ifelse(available, "", paste0("Reference: ", r$Reason, " | Comparison: ", s$Reason))
    rows <- data.frame(MatchedRow = seq_len(nrow(r)), ReferenceInputRow = r$InputRow, ComparisonInputRow = s$InputRow, 
        ObservedScore = r$Score, ReferenceStatus = r$Status, ComparisonStatus = s$Status, Status = status, 
        Reason = reason)
    for (metric in c("ExpectedScore", "PredictiveVariance")) {
        rows[[paste0(metric, "Reference")]] <- r[[metric]]
        rows[[paste0(metric, "Comparison")]] <- s[[metric]]
        rows[[paste0(metric, "Difference")]] <- ifelse(available, s[[metric]] - r[[metric]], NA_real_)
    }
    pa <- a$probabilities[indices[[1]], , drop = FALSE]
    pb <- b$probabilities[indices[[2]], , drop = FALSE]
    probabilities <- data.frame(MatchedRow = rep(rows$MatchedRow, ncol(pa)), Score = rep(as.numeric(colnames(pa)), 
        each = nrow(pa)), Reference = as.vector(pa), Comparison = as.vector(pb), Difference = as.vector(pb - 
        pa), Status = rep(status, ncol(pa)))
    probabilities$Difference[probabilities$Status != "available_descriptive"] <- NA_real_
    ma <- a$measures
    mb <- b$measures
    oa <- order(ma$Facet, ma$Level, method = "radix")
    ob <- order(mb$Facet, mb$Level, method = "radix")
    ma <- ma[oa, , drop = FALSE]
    mb <- mb[ob, , drop = FALSE]
    rownames(ma) <- rownames(mb) <- NULL
    if (!identical(ma[c("Facet", "Level", "Selected", "Observed", "Missing")], mb[c("Facet", "Level", 
        "Selected", "Observed", "Missing")])) 
        stop("Saved group identities or selected-row accounting differ.", call. = FALSE)
    measures <- ma[c("Facet", "Level", "Selected", "Observed", "Missing")]
    measures$ReferenceAvailable <- ma$Available
    measures$ComparisonAvailable <- mb$Available
    complete <- ma$Status == "descriptive_only" & mb$Status == "descriptive_only"
    measures$Status <- ifelse(complete, "available_descriptive", "unavailable")
    measures$Reason <- ifelse(complete, "", paste0("Reference: ", ma$Reason, " | Comparison: ", mb$Reason))
    for (metric in c("Infit", "Outfit")) {
        measures[[paste0(metric, "Reference")]] <- ma[[metric]]
        measures[[paste0(metric, "Comparison")]] <- mb[[metric]]
        measures[[paste0(metric, "Difference")]] <- ifelse(complete, mb[[metric]] - ma[[metric]], NA_real_)
    }
    settings <- data.frame(Model = c("Reference", "Comparison"), Target = c(a$settings$target, b$settings$target), 
        Integration = c(a$settings$integration, b$settings$integration), QuadraturePoints = c(a$settings$quad_points, 
            b$settings$quad_points), CheckPoints = c(a$settings$check_points, b$settings$check_points), 
        SelectedRows = c(nrow(r), nrow(s)), ConditioningObservedRows = c(nrow(a$source_observed), nrow(b$source_observed)))
    list(events = events, rows = rows, probabilities = probabilities, measures = measures, settings = settings, 
        note = "Same-data posterior predictive quantities; calibration fixed in each model. Differences are comparison minus reference, not held-out performance, tests or automatic model preference. No ordinary plug-in fit cutoffs apply.")
}
