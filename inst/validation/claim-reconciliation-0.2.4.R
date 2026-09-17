# Repository-only reconciliation. Reuses the existing six-fit audit and tests;
# passing these checks does not issue a statistical or release approval.
# From the package root:
# Rscript inst/validation/claim-reconciliation-0.2.4.R /tmp/mfrmr-claim-reconciliation
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1L, file.exists("DESCRIPTION"))
out <- args[[1L]]
dir.create(out, recursive = TRUE, showWarnings = FALSE)
out <- normalizePath(out, mustWork = TRUE)
Sys.setenv(NOT_CRAN = "true")
source("inst/validation/public-claim-evidence-audit-0.2.4.R")
inventory <- read.csv("inst/validation/public-claim-evidence-inventory-0.2.4.csv")
inventory <- rbind(inventory, data.frame(
  Declaration = "export(plot_compare_mfrm)", Kind = "export",
  Symbol = "plot_compare_mfrm", SourceFile = "R/api-plotting-comparison.R",
  SourceLine = NA_integer_, HelpFile = "man/plot_compare_mfrm.Rd",
  ClaimGroups = "C02;C03;C04;C05;C17",
  ReviewStatus = "mapped_not_individually_validated"
))
write.csv(inventory, file.path(out, "inventory.csv"), row.names = FALSE)
public_claim_evidence_audit(out, file.path(out, "inventory.csv"))

# Resolve current locations from the loaded function source, preserving the
# original claim mapping and its explicit lack of individual validation.
namespace <- asNamespace("mfrmr")
inventory$CurrentSourceFile <- vapply(inventory$Symbol, function(symbol) {
  file <- getSrcFilename(get(symbol, namespace), full.names = TRUE)
  stopifnot(length(file) == 1L, nzchar(file), file.exists(file))
  substring(normalizePath(file), nchar(normalizePath(".")) + 2L)
}, character(1))
inventory$CurrentSourceLine <- vapply(inventory$Symbol, function(symbol) {
  as.integer(getSrcLocation(get(symbol, namespace), "line"))
}, integer(1))
stopifnot(all(file.exists(inventory$CurrentSourceFile)),
          all(inventory$CurrentSourceLine > 0L))
write.csv(inventory, file.path(out, "inventory.csv"), row.names = FALSE)

library(testthat)
files <- paste0("tests/testthat/test-", c(
  "facet-equivalence", "q3-and-person-fit", "shrinkage", "hierarchical-audit",
  "response-time-review", "report-functions", "facets-metric-contract",
  "facets-fit-table-import", "facets-multifacet-precision-contract"
), ".R")
results <- list()
for (file in files) {
  result <- test_file(file, reporter = "summary", stop_on_failure = FALSE)
  result <- as.data.frame(result)
  write.csv(result[, setdiff(names(result), "result")],
            file.path(out, paste0(basename(file), ".csv")), row.names = FALSE)
  results[[file]] <- data.frame(
    File = file, Blocks = nrow(result), Passed = sum(result$passed),
    Failed = sum(result$failed), Errors = sum(result$error),
    Warnings = sum(result$warning), Skipped = sum(result$skipped)
  )
}
results <- do.call(rbind, results)
write.csv(results, file.path(out, "tests.csv"), row.names = FALSE)
capture.output(sessionInfo(), file = file.path(out, "session-info.txt"))
stopifnot(sum(results$Failed) == 0L, sum(results$Errors) == 0L)
print(results, row.names = FALSE)

# Hand-calculated planning example: vary only rater counts, keep Criterion=4.
# These supplied components test projection arithmetic, not their estimation.
gt <- structure(list(
  variance_components = data.frame(
    Source = c("Person", "Rater", "Criterion", "Residual"),
    Variance = c(1, 0.4, 0.2, 0.8)
  ),
  design = list(object_facet = "Person", random_facets = c("Rater", "Criterion"),
                identification_status = "identified", boundary_fit = FALSE)
), class = "mfrm_generalizability")
ds <- mfrm_d_study(gt, data.frame(Rater = 2:4, Criterion = 4),
                   residual_scaling = "sensitivity")
ds$ReferenceG <- c(10/11, 5/7, 5/9, 15/16, 15/19, 5/9, 20/21, 5/6, 5/9)
ds$ReferencePhi <- c(20/27, 20/33, 20/41, 4/5, 20/29, 60/119,
                     5/6, 20/27, 20/39)
ds$ReferenceRelativeError <- c(1/10, 2/5, 4/5, 1/15, 4/15, 4/5, 1/20, 1/5, 4/5)
ds$ReferenceAbsoluteError <- c(7/20, 13/20, 21/20, 1/4, 9/20, 59/60,
                              1/5, 7/20, 19/20)
# Public G/Phi columns are intentionally rounded to four decimals. Check the
# unrounded error variances separately; do not demand full precision of display.
stopifnot(nrow(ds) == 9L, all(ds$n_Criterion == 4),
          identical(as.numeric(ds$n_Rater), rep(as.numeric(2:4), each = 3)),
          max(abs(ds$RelativeErrorVariance - ds$ReferenceRelativeError)) < 1e-12,
          max(abs(ds$AbsoluteErrorVariance - ds$ReferenceAbsoluteError)) < 1e-12,
          identical(ds$G, round(ds$ReferenceG, 4)),
          identical(ds$Phi, round(ds$ReferencePhi, 4)))
write.csv(ds, file.path(out, "d-study-fixed-counts.csv"), row.names = FALSE)
