# Verify conditional arithmetic and public result delivery without fitting MFRM.
# Run from package root with the retained dependency library.
pkgload::load_all(".", quiet = TRUE, compile = FALSE)
root <- "validation-results/mantel-haenszel-20261010"
dir.create(root, recursive = TRUE, showWarnings = FALSE)
rows_from_counts <- function(tables) do.call(rbind, lapply(seq_along(tables), function(k) {
  z <- tables[[k]]
  cells <- data.frame(Group = c("R", "F", "R", "F"), Score = c(1, 1, 0, 0))
  d <- cells[rep(seq_len(4), as.vector(z)), , drop = FALSE]
  d$Person <- paste(k, seq_len(nrow(d)), sep = "_")
  d$Target <- "Item"; d$Matching <- k
  rownames(d) <- NULL
  d
}))
compute <- function(d, ...) mantel_haenszel_table(d, "Person", "Target", "Score",
  "Group", "Matching", c("R", "F"), ...)

# Exhaust all conditional outcomes for two fixed margin sets. Neither the
# enumeration nor its probabilities call the MH backend.
N <- c(7, 6); success <- c(3, 4); reference <- c(3, 2)
patterns <- as.matrix(expand.grid(0:3, 0:2))
prob <- dhyper(patterns[, 1], success[1], N[1] - success[1], reference[1]) *
        dhyper(patterns[, 2], success[2], N[2] - success[2], reference[2])
s <- 0:5
null <- vapply(s, function(v) sum(prob[rowSums(patterns) == v]), 0)
stopifnot(abs(sum(null) - 1) < 1e-14)
outcomes <- do.call(rbind, lapply(c(.90, .95, .99), function(level) {
  do.call(rbind, lapply(seq_len(nrow(patterns)), function(j) {
    a <- patterns[j, ]
    tables <- lapply(1:2, function(k) matrix(c(a[k], success[k] - a[k],
      reference[k] - a[k], N[k] - success[k] - reference[k] + a[k]), 2))
    x <- compute(rows_from_counts(tables), conf_level = level)$table
    observed <- sum(a)
    oracle_p <- sum(null[null <= null[s == observed] * (1 + 1e-7)])
    stopifnot(x$Status == "available", x$IntervalStatus == "available",
              abs(x$PValue - oracle_p) < 1e-13)
    data.frame(A1 = a[1], A2 = a[2], Sum = observed, NullMass = prob[j],
      ConfidenceLevel = level, MHOddsRatio = x$MHOddsRatio, OddsRatio = x$OddsRatio,
      Lower = x$Lower, Upper = x$Upper, PValue = x$PValue, OracleP = oracle_p)
  }))
}))
coverage <- do.call(rbind, lapply(c(.25, 1, 4), function(truth) {
  do.call(rbind, lapply(c(.90, .95, .99), function(level) {
    d <- outcomes[outcomes$ConfidenceLevel == level, ]
    weights <- d$NullMass * truth^d$Sum; weights <- weights / sum(weights)
    cover <- sum(weights[d$Lower <= truth & d$Upper >= truth])
    rejection <- sum(weights[d$PValue <= 1 - level])
    stopifnot(cover >= level - 1e-12)
    if (truth == 1) stopifnot(rejection <= 1 - level + 1e-12)
    data.frame(OddsRatio = truth, ConfidenceLevel = level, Coverage = cover,
               RejectionOfOR1 = rejection)
  }))
}))
write.csv(outcomes, file.path(root, "exhaustive-outcomes.csv"), row.names = FALSE)
write.csv(coverage, file.path(root, "exhaustive-coverage.csv"), row.names = FALSE)

# Check numerical stability and orientation at small, medium and large
# count sizes. The symmetric conditional law implies a two-sided p of 1.
scales <- do.call(rbind, lapply(c(1, 10, 100, 400), function(multiplier) {
  d <- rows_from_counts(list(matrix(c(2, 2, 1, 1) * multiplier, 2),
                             matrix(c(1, 1, 2, 2) * multiplier, 2)))
  timing <- system.time(x <- compute(d))
  stopifnot(x$table$Status == "available", abs(x$table$PValue - 1) < 1e-13,
            abs(x$table$MHOddsRatio - 1) < 1e-13,
            abs(x$table$OddsRatio - 1) < 1e-4,
            x$table$Lower < 1, x$table$Upper > 1)
  data.frame(Persons = nrow(d), PValue = x$table$PValue, Lower = x$table$Lower,
             Upper = x$table$Upper, Elapsed = timing[["elapsed"]])
}))
write.csv(scales, file.path(root, "count-size-arithmetic.csv"), row.names = FALSE)

# Run the documented public example and bind persistence to its full result.
rd <- tools::parse_Rd("man/mantel_haenszel_table.Rd")
tools::checkRd(rd)
tools::Rd2HTML(rd, out = file.path(root, "mantel_haenszel_table.html"))
tools::Rd2ex(rd, out = file.path(root, "example.R"))
env <- new.env(parent = globalenv())
timing <- system.time(sys.source(file.path(root, "example.R"), envir = env))
saveRDS(list(data = env$d, result = env$mh), file.path(root, "example-and-result.rds"))
csv <- list()
for (part in c("table", "strata", "cases", "matching")) {
  path <- file.path(root, paste0(part, ".csv"))
  write.csv(env$mh[[part]], path, row.names = FALSE, na = "NA")
  csv[[part]] <- list(path = path, classes = vapply(env$mh[[part]], function(x) class(x)[1], ""))
}
saveRDS(csv, file.path(root, "csv-manifest.rds"))
writeLines(c(
  'stopifnot(!"mfrmr" %in% loadedNamespaces())',
  'root <- "validation-results/mantel-haenszel-20261010"',
  'saved <- readRDS(file.path(root,"example-and-result.rds"))$result',
  'csv <- readRDS(file.path(root,"csv-manifest.rds"))',
  'for (part in names(csv)) {',
  '  restored <- read.csv(csv[[part]]$path, colClasses=csv[[part]]$classes, check.names=FALSE)',
  '  stopifnot(isTRUE(all.equal(saved[[part]],restored,tolerance=1e-13)))',
  '}',
  'stopifnot(!"mfrmr" %in% loadedNamespaces())',
  'cat("Full result and four typed CSV tables replay in base R.\\n")'), file.path(root, "replay.R"))
status <- system2(file.path(R.home("bin"), "Rscript"), c("--vanilla", file.path(root, "replay.R")),
  stdout = file.path(root, "replay.log"), stderr = file.path(root, "replay-errors.log"))
stopifnot(status == 0L)
writeLines(c(capture.output(sessionInfo()), capture.output(timing)), file.path(root, "session.txt"))
files <- c("R/api-mantel-haenszel.R", "tests/testthat/test-mantel-haenszel.R",
  "inst/validation/mfrm-mantel-haenszel-20261010.R", "NAMESPACE", "man/mantel_haenszel_table.Rd")
write.csv(data.frame(File = files, SHA256 = vapply(files, function(f)
  digest::digest(file = f, algo = "sha256"), "")), file.path(root, "source-manifest.csv"), row.names = FALSE)
print(coverage, row.names = FALSE)
print(scales, row.names = FALSE)
cat("All 36 conditional outcomes and 9 coverage cells passed. No Monte Carlo or MFRM refits.\n")
cat("Public example elapsed:", timing[["elapsed"]], "seconds.\n")
cat(readLines(file.path(root, "replay.log")), sep = "\n")
