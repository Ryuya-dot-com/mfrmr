# From the package root: Rscript scripts/build-model-family-figure.R
# Run the exact, self-contained code displayed in the introduction.
lines <- readLines("vignettes/articles/mfrmr.Rmd", warn = FALSE)
start <- match("```{r model-family-figure-code, eval = FALSE}", lines)
stopifnot(!is.na(start))
rest <- lines[seq.int(start + 1L, length(lines))]
end <- match("```", rest)
stopifnot(!is.na(end), end > 1L)
code <- rest[seq_len(end - 1L)]
destination <- "vignettes/articles/model-comparison"
dir.create(destination, recursive = TRUE, showWarnings = FALSE)
invisible(local({
  previous <- setwd(destination)
  on.exit(setwd(previous))
  eval(parse(text = code), envir = new.env(parent = globalenv()))
}))
cat("PASS: figure regenerated from the article's displayed R code\n")
