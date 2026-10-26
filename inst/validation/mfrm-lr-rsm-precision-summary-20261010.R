# Reporting-only continuation of the unchanged 3200-attempt frozen study.
# binom.test() retains conf.level after unname(); qbeta() has no such attribute.
# Compare numeric endpoints without changing their values, tolerance or rule.
source("inst/validation/mfrm-lr-rsm-precision-20261010.R")
pkgload::load_all(".", quiet = TRUE, compile = FALSE)
root <- precision_root
original <- deparse(body(precision_summarize))
needle <- "all.equal(ci, d$coverage, tolerance = 1e-13)"
stopifnot(sum(grepl(needle, original, fixed = TRUE)) == 1L)
repaired <- sub(needle,
  "all.equal(ci, as.numeric(d$coverage), tolerance = 1e-13)", original, fixed = TRUE)
for (k in c(0L, 1L, 1600L, 3000L, 3200L)) {
  n <- 3200L
  ci <- c(if (k == 0) 0 else qbeta(.025, k, n-k+1),
          if (k == n) 1 else qbeta(.975, k+1, n-k))
  reference <- rsm_confirm_cp(k, n)
  stopifnot(identical(attr(reference, "conf.level"), .95),
            isTRUE(all.equal(ci, as.numeric(reference), tolerance = 1e-13)))
}
body(precision_summarize) <- parse(text = repaired)[[1]]
precision_summarize()
saveRDS(list(
  correction = "Remove only conf.level attribute when comparing independent numeric interval endpoints.",
  changed_values_or_criteria = FALSE,
  original_body = original, executed_body = repaired,
  source = tools::md5sum(c("inst/validation/mfrm-lr-rsm-precision-summary-20261010.R",
                          "inst/validation/mfrm-lr-rsm-precision-20261010.R")),
  summary = tools::md5sum(file.path(root, c("summary.rds", "summary.csv"))),
  session = sessionInfo()), file.path(root, "summary-verification.rds"))
