.gpcm_capability_registry <- function(status = c("all", "supported", "supported_with_caveat", "blocked", 
    "deferred")) {
    status <- match.arg(status)
    out <- .mfrmr_table_.gpcm_capability_registry_out
    out <- rbind(out, .mfrmr_table_.gpcm_capability_registry_data)
    if (!identical(status, "all")) {
        out <- out[out$Status == status, , drop = FALSE]
    }
    rownames(out) <- NULL
    out
}
