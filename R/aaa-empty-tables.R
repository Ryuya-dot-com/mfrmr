# Construct private zero-row schemas once when the namespace is built.
# Ordinary R copy-on-modify keeps callers' edits separate from these values.
.mfrmr_empty_table <- function(types, tbl = FALSE) {
  x <- as.data.frame(lapply(types, vector, length = 0L), check.names = FALSE,
    stringsAsFactors = FALSE)
  if (tbl) tibble::as_tibble(x) else x
}
