# Run from the repository root: Rscript --vanilla scripts/check-reference-alt.R
local({
  hook <- normalizePath("pkgdown/post-reference.R", mustWork = TRUE)
  folder <- tempfile("mfrmr-reference-alt-")
  dir.create(folder)
  previous <- setwd(folder)
  on.exit({ setwd(previous); unlink(folder, recursive = TRUE) })
  run_hook <- function() sys.source(hook, envir = new.env(parent = globalenv()))
  page <- function(topic, n, alt = rep("", n)) {
    file <- paste0(topic, ".html")
    writeLines(c("<!DOCTYPE html><html><head><title>Example</title></head><body>",
      '<img class="logo" src="logo.png" alt="">',
      '<p id="keep">Keep &amp; preserve <a href="other.html">links</a>.</p>',
      sprintf('<span class="r-plt img"><img src="%s-%d.png" alt="%s"></span>',
        topic, seq_len(n), alt), "</body></html>"), file)
    file
  }
  get_alt <- function(file) xml2::xml_attr(
    xml2::xml_find_all(xml2::read_html(file), "//span/img"), "alt")
  without_alt <- function(file) {
    html <- xml2::read_html(file)
    images <- xml2::xml_find_all(html, "//span/img")
    xml2::xml_attr(images, "alt") <- ""
    as.character(html)
  }
  file <- page("plot.mfrm_fit", 3L, c("Authored description", "", ""))
  before <- without_alt(file)
  run_hook()
  stopifnot(identical(get_alt(file)[1], "Authored description"),
    all(nzchar(get_alt(file))), identical(before, without_alt(file)))
  hash <- tools::md5sum(file)
  run_hook()
  stopifnot(identical(hash, tools::md5sum(file)))
  unlink(file)

  # ggplot2 is optional in these examples. Test both actual image sequences.
  for (n in c(6L, 8L)) {
    file <- page("plot.mfrm_multivariate_d_study", n)
    run_hook()
    alt <- get_alt(file)
    equal_position <- if (n == 6L) 5L else 6L
    stopifnot(all(nzchar(alt)), grepl("equally weighted", alt[equal_position]),
      grepl("SEM", alt[equal_position + 1L]))
    if (n == 8L) stopifnot(grepl("SEM", alt[5]),
      grepl("equally weighted", alt[8]))
    unlink(file)
  }
  for (n in c(3L, 4L)) {
    file <- page("plot.mfrm_multivariate_gstudy", n)
    run_hook()
    stopifnot(all(nzchar(get_alt(file))),
      grepl("Variance-covariance", get_alt(file)[3]))
    unlink(file)
  }
  for (n in c(1L, 2L)) {
    file <- page("mfrmr_model_maps", n)
    run_hook()
    stopifnot(all(nzchar(get_alt(file))), grepl("Wright", get_alt(file)[1]))
    if (n == 2L) stopifnot(grepl("posterior Infit", get_alt(file)[2]))
    unlink(file)
  }
  for (case in list(c("new_plot", 1L), c("plot.mfrm_fit", 4L))) {
    file <- page(case[1], as.integer(case[2]))
    hash <- tools::md5sum(file)
    error <- tryCatch({run_hook(); NULL}, error = identity)
    stopifnot(inherits(error, "error"),
      grepl("Review reference figure descriptions", conditionMessage(error)),
      identical(hash, tools::md5sum(file)))
    unlink(file)
  }
  file <- page("plot.mfrm_fit", 3L)
  html <- xml2::read_html(file)
  images <- xml2::xml_find_all(html, "//span/img")
  xml2::xml_attr(images, "src") <- rev(xml2::xml_attr(images, "src"))
  xml2::write_html(html, file)
  error <- tryCatch({run_hook(); NULL}, error = identity)
  stopifnot(inherits(error, "error"))
  unlink(file)
  # A future renderer can supply its own alt text without a map entry.
  file <- page("new_plot", 1L, "Supplied by the renderer")
  run_hook()
  stopifnot(identical(get_alt(file), "Supplied by the renderer"))
  cat("Reference alt-text checks passed: preservation, repeat application,",
    "optional plot sequences, and refusal of unmapped empty descriptions.\n")
})
