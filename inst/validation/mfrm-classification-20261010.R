# Fixed-calibration classification arithmetic and persistence checks.
# Run from package root with the retained dependency library. This does not
# validate estimated-calibration bias/coverage or sample a rater population.
pkgload::load_all(".", quiet = TRUE, compile = FALSE)
root <- "validation-results/classification-20261010"
dir.create(root, recursive = TRUE, showWarnings = FALSE)

# Normal approximation and exact summed-score decisions share the same
# ordinary ML rule here, including infinite extreme MLs and upper-category
# ties. Keep discrepancies visible; no universal approximation tolerance.
comparison <- do.call(rbind, lapply(c(3L, 20L, 80L), function(n) {
  do.call(rbind, lapply(list(0, c(-.5, .5)), function(cuts) {
    # Binomial Rasch expectation is n * logistic(theta).
    sum_cuts <- ceiling(n * plogis(cuts))
    do.call(rbind, lapply(c(-8, -2, -.5, 0, .5, 2, 8), function(theta) {
      x <- mfrmr:::mfrm_classification_point(theta, rep(0, n), matrix(0, n, 2), sum_cuts, cuts)
      ref <- dbinom(0:n, n, plogis(theta))
      observed <- findInterval(0:n, sum_cuts) + 1L
      true <- findInterval(theta, cuts) + 1L
      exact <- vapply(seq_len(length(cuts) + 1L), function(h) sum(ref[observed == h]), 0)
      stopifnot(max(abs(x$lee - exact)) < 1e-13)
      data.frame(Ratings = n, Categories = length(cuts) + 1L, Theta = theta,
        LeeAccuracy = x$lee[true], RudnerAccuracy = x$rudner[true],
        LeeConsistency = sum(x$lee^2), RudnerConsistency = sum(x$rudner^2), SEM = x$sem,
        MaximumBinomialError = max(abs(x$pmf - ref)))
    }))
  }))
}))
write.csv(comparison, file.path(root, "matched-rule-comparison.csv"), row.names = FALSE)

# Execute the actual new help example once and reuse its RSM calibration.
rd <- tools::parse_Rd("man/classification_table.Rd")
tools::checkRd(rd)
tools::Rd2HTML(rd, out = file.path(root, "classification_table.html"))
tools::Rd2ex(rd, out = file.path(root, "example.R"))
example_env <- new.env(parent = globalenv())
timing <- system.time(sys.source(file.path(root, "example.R"), envir = example_env))
saveRDS(example_env$fit, file.path(root, "example-fit.rds"))

# Reuse retained eligible PCM fits and the example calibration.
fits <- readRDS("tests/testthat/fixtures/ordinary-score-integration.rds")$fits
fits[["RSM-MML"]] <- example_env$fit
saved <- lapply(fits, function(fit) {
  plan <- if (fit$config$model == "PCM") expand.grid(Rater = c("1", "2"), Criterion = c("1", "2")) else
    data.frame(Item = c("A", "B", "C"))
  max_sum <- nrow(plan) * (fit$config$n_cat - 1L)
  classification_table(fit, plan, c(Low = -.5, High = .5), ceiling(max_sum * c(.35, .65)),
    theta = c(-1, -.5, 0, .5, 1, 1000), theta_weights = c(1, 2, 3, 2, 1, 0))
})
saveRDS(saved, file.path(root, "saved-results.rds"))
csv <- list()
for (case in names(saved)) for (part in names(saved[[case]])) {
  x <- saved[[case]][[part]]
  if (!is.data.frame(x)) next
  path <- file.path(root, paste0(case, "-", part, ".csv"))
  write.csv(x, path, row.names = FALSE, na = "NA")
  csv[[length(csv) + 1L]] <- list(case = case, part = part, path = path,
    classes = vapply(x, function(column) class(column)[1], ""))
}
saveRDS(csv, file.path(root, "csv-manifest.rds"))

# Replay executes base R only: no package load and no calibration/prediction.
replay <- c(
  'root <- "validation-results/classification-20261010"',
  'stopifnot(!"mfrmr" %in% loadedNamespaces())',
  'saved <- readRDS(file.path(root,"saved-results.rds"))',
  'manifest <- readRDS(file.path(root,"csv-manifest.rds"))',
  'for (entry in manifest) {',
  '  original <- saved[[entry$case]][[entry$part]]',
  '  restored <- read.csv(entry$path, colClasses=entry$classes, check.names=FALSE)',
  '  rownames(original) <- rownames(restored) <- NULL',
  '  stopifnot(isTRUE(all.equal(original,restored,tolerance=1e-13)))',
  '}',
  'for (x in saved) {',
  '  stopifnot(x$source$ready, all(x$marginal$Status=="available"))',
  '  stopifnot(all(abs(x$marginal$Accuracy+x$marginal$Overclassification+x$marginal$Underclassification-1)<1e-13))',
  '  stopifnot(any(x$table$Status=="zero_information"))',
  '}',
  'stopifnot(!"mfrmr" %in% loadedNamespaces())',
  'cat(length(saved),"saved results and",length(manifest),"typed CSV tables replayed in base R\\n")')
writeLines(replay, file.path(root, "replay.R"))
status <- system2(file.path(R.home("bin"), "Rscript"), c("--vanilla", file.path(root, "replay.R")),
  stdout = file.path(root, "replay.log"), stderr = file.path(root, "replay-errors.log"))
stopifnot(status == 0L)

stopifnot("classification_table" %in% getNamespaceExports("mfrmr"))
writeLines(c(capture.output(sessionInfo()), capture.output(timing)), file.path(root, "session.txt"))
files <- c(list.files("R", pattern = "[.]R$", full.names = TRUE), "DESCRIPTION", "NAMESPACE",
  "tests/testthat/test-classification.R", "tests/testthat/fixtures/ordinary-score-integration.rds",
  "inst/validation/mfrm-classification-20261010.R", "man/classification_table.Rd",
  file.path(root, "example-fit.rds"))
write.csv(data.frame(File = files, SHA256 = vapply(files, function(f)
  digest::digest(file = f, algo = "sha256"), "")), file.path(root, "source-manifest.csv"), row.names = FALSE)
cat(nrow(comparison), "matched-rule comparisons; largest binomial PMF error:",
    max(comparison$MaximumBinomialError), "\n")
cat("Help example elapsed:", timing[["elapsed"]], "seconds\n")
cat(readLines(file.path(root, "replay.log")), sep = "\n")
