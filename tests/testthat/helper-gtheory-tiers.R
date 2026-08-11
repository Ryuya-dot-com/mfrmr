mfrmr_gtheory_slow_enabled <- function(
    value = Sys.getenv("MFRMR_RUN_GTHEORY_SLOW", unset = "")) {
  value <- trimws(tolower(value))
  isTRUE(length(value) == 1L && value %in% c("1", "true", "yes"))
}

mfrmr_skip_if_not_gtheory_slow <- function() {
  if (!mfrmr_gtheory_slow_enabled()) {
    testthat::skip(paste(
      "set MFRMR_RUN_GTHEORY_SLOW=true to run isolated G-theory",
      "execution and exact-resume validation"
    ))
  }
  invisible(TRUE)
}
