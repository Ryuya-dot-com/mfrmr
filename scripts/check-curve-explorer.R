# Website-only check; Node is a build-tool requirement, not an R package dependency.
node <- Sys.which("node")
if (!nzchar(node)) stop("Node is required for the website curve-explorer check.")
output <- tempfile(fileext = ".csv")
status <- system2(node, c("scripts/check-curve-explorer.js", shQuote(output)))
stopifnot(status == 0L)
values <- read.csv(output)
kernels <- new.env(parent = baseenv())
kernels$`%||%` <- function(x, y) if (is.null(x)) y else x
sys.source("R/core-category-probabilities.R", kernels)
expected <- t(vapply(seq_len(nrow(values)), function(i) {
  x <- values[i, ]
  cumulative_steps <- c(0, cumsum(c(-x$Spacing, 0, x$Spacing)))
  eta <- x$Theta - x$Delta
  switch(x$Model,
    RSM = as.numeric(kernels$category_prob_rsm(eta, cumulative_steps)),
    PCM = as.numeric(kernels$category_prob_pcm(eta, matrix(cumulative_steps, 1), 1L)),
    GPCM = as.numeric(kernels$category_prob_gpcm(eta, matrix(cumulative_steps, 1), 1L, x$Slope)))
}, numeric(4)))
error <- max(abs(expected - as.matrix(values[paste0("P", 0:3)])))
stopifnot(is.finite(error), error < 2e-14)
cat("PASS:", nrow(values), "widget probability vectors match the R likelihood kernels; max error", error, "\n")
unlink(output)
