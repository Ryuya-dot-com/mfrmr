
step_index_from_label <- function(step_labels) {
    step_labels <- as.character(step_labels)
    idx <- suppressWarnings(as.integer(gsub("[^0-9]+", "", step_labels)))
    if (all(is.na(idx))) 
        return(seq_along(step_labels))
    if (any(is.na(idx))) {
        fill_start <- max(idx, na.rm = TRUE)
        idx[is.na(idx)] <- fill_start + seq_len(sum(is.na(idx)))
    }
    idx
}
