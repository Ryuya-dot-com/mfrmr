mfrm_validate_person_scores <- function(fit, scores) {
    expected <- if (inherits(fit, "mfrm_testlet")) 
        "mfrm_testlet_scores"
    else if (inherits(fit, "mfrm_random_rater")) 
        "mfrm_random_rater_scores"
    else "mfrm_person_scores"
    input <- if (mfrm_extended_fit(fit)) 
        fit$input
    else mfrm_ordinary_response_input(fit)
    columns <- names(input$assigned_data %||% input$data)
    roster <- input$assigned_data %||% input$data
    if (!inherits(scores, expected) || !identical(scores$source, mfrm_response_source(fit)) || is.null(scores$scoring_data) || 
        !identical(mfrm_compare_events(scores$scoring_data, columns), mfrm_compare_events(input$assigned_data %||% 
            input$data, columns))) 
        stop("Supply saved Person scores with matching calibration and the complete source roster; regenerate older scores lacking scoring_data.", 
            call. = FALSE)
    if (!identical(scores$settings$calibration_uncertainty, FALSE) || !is.data.frame(scores$table) || 
        !all(c("Person", "Observed", "Estimate", "ConditionalSD", "Lower", "Upper", "Status", "Reason") %in% 
            names(scores$table)) || anyDuplicated(scores$table$Person) || !all(scores$table$Person %in% 
        roster[[input$columns$person]])) 
        stop("Saved Person-score identities or conditional uncertainty fields are invalid.", call. = FALSE)
    invisible(TRUE)
}

mfrm_compare_persons <- function(fits, scores) {
    if (!is.list(scores) || length(scores) != 2L) 
        stop("person_scores must contain two saved scoring results in fit order.", call. = FALSE)
    for (i in 1:2) mfrm_validate_person_scores(fits[[i]], scores[[i]])
    a <- scores[[1]]
    b <- scores[[2]]
    if (!setequal(a$table$Person, b$table$Person) || !identical(a$settings$level, b$settings$level)) 
        stop("Compare the same requested Persons and conditional interval level.", call. = FALSE)
    origin <- vapply(fits, function(f) if (mfrm_extended_fit(f)) 
        0
    else mfrm_ordinary_response_input(f)$mean, numeric(1))
    ids <- sort(a$table$Person)
    aa <- a$table[match(ids, a$table$Person), ]
    bb <- b$table[match(ids, b$table$Person), ]
    if (!identical(aa$Observed, bb$Observed)) 
        stop("Person observed-row counts differ.", call. = FALSE)
    available <- aa$Status == "available_conditional" & bb$Status == "available_conditional"
    status <- ifelse(available, "available_descriptive", ifelse(aa$Status == "prior_only" | bb$Status == 
        "prior_only", "prior_only", "unavailable"))
    table <- data.frame(Person = ids, Observed = aa$Observed, SourceReference = aa$Estimate, SourceComparison = bb$Estimate, 
        OriginReference = origin[1], OriginComparison = origin[2], Reference = aa$Estimate - origin[1], 
        Comparison = bb$Estimate - origin[2], ConditionalSDReference = aa$ConditionalSD, ConditionalSDComparison = bb$ConditionalSD, 
        LowerReference = aa$Lower - origin[1], UpperReference = aa$Upper - origin[1], LowerComparison = bb$Lower - 
            origin[2], UpperComparison = bb$Upper - origin[2], ReferenceStatus = aa$Status, ComparisonStatus = bb$Status, 
        Status = status, Reason = ifelse(available, "", paste0("Reference: ", aa$Status, " ", aa$Reason, 
            " | Comparison: ", bb$Status, " ", bb$Reason)))
    table$Difference <- ifelse(available, table$Comparison - table$Reference, NA_real_)
    list(table = table, level = a$settings$level, note = "EAPs and conditional endpoints are centered at each fitted population mean, on the unit-slope logit scale. Calibration is fixed; conditional intervals are not intervals for model differences. Prior-only and unavailable differences are withheld; no ranking or Person-difference test is supplied.")
}
