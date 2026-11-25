anchor_review <- function(x, required = TRUE) {
    required <- isTRUE(required)
    if (inherits(x, "mfrm_anchor_review")) {
        return(x)
    }
    if (!is.list(x)) {
        stop("`x` must be an `mfrm_fit`, anchor-review object, or compatible list.", call. = FALSE)
    }
    config <- x$config %||% x
    out <- config$anchor_review
    if (is.null(out)) {
        if (!required) 
            return(NULL)
        stop("No anchor-review component was found. Use `fit$config$anchor_review`, ", "or run `review_mfrm_anchors()`.", 
            call. = FALSE)
    }
    out
}

precision_review <- function(x, required = TRUE) {
    required <- isTRUE(required)
    if (inherits(x, "mfrm_precision_review")) {
        validate_precision_review_profile(x$profile)
        return(x)
    }
    if (!is.list(x)) {
        stop("`x` must be an `mfrm_diagnostics`, precision-review object, or compatible list.", call. = FALSE)
    }
    validate_diagnostics_precision(x)
    out <- x$precision_review
    if (is.null(out)) {
        if (!required) 
            return(NULL)
        stop("No precision-review component was found. Run `diagnose_mfrm()` and use ", "`diagnostics$precision_review`.", 
            call. = FALSE)
    }
    out
}
