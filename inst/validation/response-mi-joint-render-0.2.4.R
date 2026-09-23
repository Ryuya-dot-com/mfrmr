# Execute changed tutorial data/import/plot code while replaying the exact fits
# already computed in the numerical record. No duplicate MCMC or eighty refits.
.libPaths(c(normalizePath(".r-library"), .libPaths()))
pkgload::load_all(".", quiet = TRUE)
directory <- normalizePath("validation-results/response-mi-joint-20260923")
baseline <- readRDS(file.path(directory, "analyses.rds"))
lower <- readRDS(file.path(directory, "lower-analyses.rds"))
result <- readRDS(file.path(directory, "results.rds"))
observed <- readRDS(file.path(directory, "observed-selected-q121.rds"))
example <- readRDS("inst/examples/response-imputation.rds")
replayed <- character()
env <- new.env(parent = globalenv())
env$fit_mfrm_imputed <- function(x, model, quad_points) {
  stopifnot(identical(model, "RSM"), quad_points == 61)
  saved <- if (identical(x$completed, baseline$imputations$completed)) baseline else lower
  stopifnot(identical(x$data, saved$imputations$data),
    identical(x$completed, saved$imputations$completed), identical(x$settings, saved$imputations$settings))
  saved$imputations <- x
  replayed <<- c(replayed, if (identical(saved$fits, baseline$fits)) "baseline" else "lower")
  saved
}
env$pool_mfrm_imputed <- function(x, facet, contrasts) {
  saved <- if (identical(x$fits, baseline$fits)) result$pooled else result$lower_pooled
  stopifnot(identical(x$fits, saved$analyses$fits), identical(facet, "Rater"),
    identical(unname(contrasts), unname(saved$contrasts)))
  saved$analyses <- x
  replayed <<- c(replayed, "pool")
  saved
}
env$fit_mfrm <- function(data, person, facets, score, model, method, rating_min,
  rating_max, quad_points, keep_original, attach_diagnostics) {
  stopifnot(identical(data, subset(example$ratings, Assigned & !is.na(Score))),
    identical(person, "Person"), identical(facets, c("Rater", "Criterion")),
    identical(score, "Score"), identical(model, "RSM"), identical(method, "MML"),
    rating_min == 1, rating_max == 4, quad_points == 121,
    identical(keep_original, TRUE), identical(attach_diagnostics, FALSE))
  replayed <<- c(replayed, "observed")
  observed
}
env$mfrm_facet_intervals <- function(fit, facet, contrasts) {
  stopifnot(identical(fit, observed), identical(facet, "Rater"),
    identical(unname(contrasts), unname(result$pooled$contrasts)))
  result$intervals[[2]]
}
html <- rmarkdown::render("vignettes/mfrmr-response-imputation.Rmd", envir = env,
  output_dir = directory, quiet = TRUE, clean = TRUE)
stopifnot(identical(replayed, c("baseline", "pool", "observed", "lower", "pool")),
  identical(summary(env$pooled), summary(result$pooled)),
  identical(summary(env$lower_pooled), summary(result$lower_pooled)))
saveRDS(list(replayed = replayed, html = basename(html),
  source = tools::md5sum("vignettes/mfrmr-response-imputation.Rmd")),
  file.path(directory, "tutorial-replay.rds"))
for (name in c("mfrm_response_imputations", "fit_mfrm_imputed", "pool_mfrm_imputed")) {
  path <- paste0("man/", name, ".Rd")
  tools::checkRd(path)
  tools::Rd2HTML(path, out = file.path(directory, paste0(name, ".html")))
}
cat("Tutorial executed with matching saved fits; changed Rd pages parsed and rendered.\n")
