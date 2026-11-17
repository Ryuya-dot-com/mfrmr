# Run from the package checkout: Rscript scripts/icnale-caf/test-preprocess.R
# Synthetic inputs only. No corpus files or corpus-derived fixtures.
source("scripts/icnale-caf/preprocess.R")
issues <- icnale_score_issues(c("0", "10", " 5 ", NA, "", "NA", "N/A", "word", "Inf", "-1", "11", "2.5"))
stopifnot(identical(issues$Issue, c(rep("valid", 3), rep("missing", 4),
  rep("non_numeric", 2), rep("out_of_range", 2), "non_integer")))
d <- data.frame(Person = c("fictional_A", "fictional_A", "fictional_B"),
  Rater = c("one", "two", "one"), Complexity = c("0", "2.5", "10"),
  Accuracy = c("1", "4", NA), Fluency = c("10", "8", "6"))
x <- icnale_clean_caf(d)
stopifnot(nrow(x$wide) == 1L, identical(x$ratings$Score, c(0L, 1L, 10L)),
  sum(x$audit$Included) == 3L, sum(x$audit$Reason == "invalid_other_caf_item") == 4L,
  identical(x$counts$Count, c(3L, 2L, 1L, 3L)),
  identical(icnale_clean_caf(d[1, ])$ratings, x$ratings))
rejects <- function(x, pattern) {
  ans <- tryCatch(icnale_clean_caf(x), error = identity)
  stopifnot(inherits(ans, "error"), grepl(pattern, conditionMessage(ans)))
}
rejects(rbind(d, d[1, ]), "Duplicate")
d$Person[1] <- NA; rejects(d, "Missing rating identifiers")
d$Person[1] <- " "; rejects(d, "Missing rating identifiers")
cat("Synthetic preprocessing checks passed.\n")
